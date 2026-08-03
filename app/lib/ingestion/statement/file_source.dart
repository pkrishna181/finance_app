import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../core/db/database.dart';
import '../../core/models/parsed_transaction.dart';
import '../../core/models/transaction_type.dart';
import '../../core/result/result.dart';
import '../source.dart';
import 'header_mapper.dart';
import 'pdf/password_hints.dart';
import 'pdf/pdf_loader.dart';
import 'row_parser.dart';
import 'table_loader.dart';

/// Preview payload before confirm write.
class StatementImportPreview {
  StatementImportPreview({
    required this.fileName,
    required this.contentHash,
    required this.bytes,
    required this.grid,
    required this.columnMap,
    required this.parseResult,
    required this.newCount,
    required this.duplicateCount,
    required this.unparseableCount,
  }) : transactions = List<ParsedTransaction>.from(parseResult.transactions);

  final String fileName;
  final String contentHash;
  final Uint8List bytes;
  final TableGrid grid;
  final ColumnMap columnMap;
  final StatementParseResult parseResult;
  final int newCount;
  final int duplicateCount;
  final int unparseableCount;

  /// Mutable copy — user may flip direction on inferred rows before confirm.
  final List<ParsedTransaction> transactions;

  List<ParsedTransaction> get previewRows =>
      transactions.take(20).toList(growable: false);

  void flipDirection(int index) {
    if (index < 0 || index >= transactions.length) return;
    final t = transactions[index];
    final flipped = ParsedTransaction(
      amountPaise: t.amountPaise,
      direction: t.direction == TransactionDirection.debit
          ? TransactionDirection.credit
          : TransactionDirection.debit,
      type: t.type,
      bookedAt: t.bookedAt,
      bankCode: t.bankCode,
      rawMerchant: t.rawMerchant,
      rawDescription: t.rawDescription,
      upiPayerVpa: t.upiPayerVpa,
      upiPayeeVpa: t.upiPayeeVpa,
      upiRef: t.upiRef,
      remarks: t.remarks,
      externalRef: t.externalRef,
      balanceAfterPaise: t.balanceAfterPaise,
      dedupeKey: t.dedupeKey,
      directionInferred: false,
    );
    transactions[index] = flipped;
  }
}

/// CSV / Excel / PDF statement source — available on Android and iOS.
class StatementFileSource implements IngestionSource {
  StatementFileSource({
    TableLoader? tableLoader,
    PdfStatementLoader? pdfLoader,
  })  : _pdfLoader = pdfLoader ?? PdfStatementLoader();

  final PdfStatementLoader _pdfLoader;

  @override
  String get id => 'statement';

  @override
  String get displayName => 'CSV / Excel / PDF statement';

  @override
  SourceAvailability get availability => SourceAvailability.available;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<Result<void>> requestPermission() async => const Ok(null);

  Future<Result<StatementImportPreview>> pickAndPreview({
    required ArthDatabase db,
    PdfPasswordProvider? passwordProvider,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xls', 'xlsx', 'pdf'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return const Err('cancelled');
    }
    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) {
      return const Err('could_not_read_file');
    }
    return previewBytes(
      db: db,
      bytes: Uint8List.fromList(bytes),
      fileName: file.name,
      passwordProvider: passwordProvider,
    );
  }

  Future<Result<StatementImportPreview>> previewBytes({
    required ArthDatabase db,
    required Uint8List bytes,
    required String fileName,
    PdfPasswordProvider? passwordProvider,
  }) async {
    final contentHash = sha256.convert(bytes).toString();
    final existing = await db.findImportByHash(contentHash);
    if (existing != null && existing.status == 'succeeded') {
      return Err('duplicate_file', existing);
    }

    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    late final TableGrid grid;
    late final ColumnMap columnMap;

    if (isPdf) {
      final loaded = await _pdfLoader.loadBytes(
        bytes: bytes,
        passwordProvider: passwordProvider,
      );
      if (loaded.isErr) {
        return Err(loaded.errorOrNull ?? 'pdf_load_failed');
      }
      grid = loaded.okOrNull!;
      columnMap = HeaderMapper().map(grid.rows);
    } else {
      final payload =
          await Isolate.run(() => _parseTabularInIsolate(bytes, fileName));
      if (payload['error'] != null) {
        return Err(payload['error']! as String);
      }
      grid = TableGrid(
        rows: (payload['rows'] as List)
            .map((r) => (r as List).map((c) => c.toString()).toList())
            .toList(),
        sourceFormat: payload['source_format'] as String,
        detectedDelimiter: payload['delimiter'] as String?,
        detectedEncoding: payload['encoding'] as String?,
      );
      columnMap = ColumnMap(
        headerRowIndex: payload['header_row_index'] as int,
        bankCode: payload['bank_code'] as String,
        profileId: payload['profile_id'] as String,
        overallConfidence: (payload['overall_confidence'] as num).toDouble(),
        bindings: [
          for (final b in payload['bindings'] as List)
            ColumnBinding(
              field: StatementField.values.byName((b as Map)['field'] as String),
              index: b['index'] as int,
              confidence: (b['confidence'] as num).toDouble(),
              matchedHeader: b['matched_header'] as String,
            ),
        ],
      );
    }

    final parseResult = StatementRowParser().parse(
      rows: grid.rows,
      columnMap: columnMap,
    );

    var duplicateCount = 0;
    var newCount = 0;
    for (final t in parseResult.transactions) {
      final hash = buildDedupeHash(
        bankCode: t.bankCode,
        bookedAt: t.bookedAt,
        amountPaise: t.amountPaise.paise,
        ref: t.externalRef,
        normalizedBody: t.rawDescription,
      );
      final exists = await (db.select(db.transactions)
            ..where((row) => row.dedupeHash.equals(hash)))
          .getSingleOrNull();
      if (exists == null) {
        newCount++;
      } else {
        duplicateCount++;
      }
    }

    return Ok(
      StatementImportPreview(
        fileName: fileName,
        contentHash: contentHash,
        bytes: bytes,
        grid: grid,
        columnMap: columnMap,
        parseResult: parseResult,
        newCount: newCount,
        duplicateCount: duplicateCount,
        unparseableCount: parseResult.unparsed.length,
      ),
    );
  }

  Future<Result<int>> confirmImport({
    required ArthDatabase db,
    required StatementImportPreview preview,
  }) async {
    final existing = await db.findImportByHash(preview.contentHash);
    if (existing != null && existing.status == 'succeeded') {
      return const Err('This statement was already imported.');
    }

    final sourceType = switch (preview.grid.sourceFormat) {
      'csv' => 'csv',
      'pdf' => 'pdf',
      _ => 'excel',
    };
    final importId = await db.into(db.imports).insert(
          ImportsCompanion.insert(
            sourceType: sourceType,
            sourceLabel: preview.fileName,
            contentHash: preview.contentHash,
            status: const Value('pending'),
          ),
        );

    var inserted = 0;
    var duplicates = 0;
    for (final t in preview.transactions) {
      final hash = buildDedupeHash(
        bankCode: t.bankCode,
        bookedAt: t.bookedAt,
        amountPaise: t.amountPaise.paise,
        ref: t.externalRef,
        normalizedBody: t.rawDescription,
      );
      final result = await db.upsertTransactionWithProvenance(
        TransactionsCompanion.insert(
          amountPaise: t.amountPaise.paise,
          direction: t.direction.wireName,
          txnType: t.type.wireName,
          bookedAt: t.bookedAt,
          bankCode: t.bankCode,
          rawMerchant: t.rawMerchant,
          rawDescription: t.rawDescription,
          dedupeHash: hash,
          accountHint: Value(t.accountHint),
          upiPayerVpa: Value(t.upiPayerVpa),
          upiPayeeVpa: Value(t.upiPayeeVpa),
          upiRef: Value(t.upiRef),
          remarks: Value(t.remarks),
          externalRef: Value(t.externalRef),
          balanceAfterPaise: Value(t.balanceAfterPaise?.paise),
          importId: Value(importId),
        ),
        importId: importId,
      );
      if (result.inserted) {
        inserted++;
      } else {
        duplicates++;
      }
    }

    for (final u in preview.parseResult.unparsed) {
      await db.insertUnparsedStatementRow(
        UnparsedStatementRowsCompanion.insert(
          importId: importId,
          rowIndex: u.rowIndex,
          rawRowJson: u.rawRowJson,
          reason: u.reason,
        ),
      );
    }

    await (db.update(db.imports)..where((t) => t.id.equals(importId))).write(
      ImportsCompanion(
        status: const Value('succeeded'),
        rowCount: Value(inserted),
        parsedCount: Value(preview.transactions.length),
        skippedCount: Value(preview.parseResult.unparsed.length),
        duplicateCount: Value(duplicates),
        notes: Value(
          'profile=${preview.columnMap.profileId}; '
          'format=${preview.grid.sourceFormat}',
        ),
      ),
    );

    return Ok(inserted);
  }
}

Map<String, dynamic> _parseTabularInIsolate(Uint8List bytes, String fileName) {
  final loaded = TableLoader().loadBytes(bytes, fileName: fileName);
  if (loaded.isErr) {
    return {'error': loaded.errorOrNull ?? 'load_failed'};
  }
  final grid = loaded.okOrNull!;
  final map = HeaderMapper().map(grid.rows);
  return {
    'rows': grid.rows,
    'source_format': grid.sourceFormat,
    'delimiter': grid.detectedDelimiter,
    'encoding': grid.detectedEncoding,
    'header_row_index': map.headerRowIndex,
    'bank_code': map.bankCode,
    'profile_id': map.profileId,
    'overall_confidence': map.overallConfidence,
    'bindings': [
      for (final b in map.bindings)
        {
          'field': b.field.name,
          'index': b.index,
          'confidence': b.confidence,
          'matched_header': b.matchedHeader,
        },
    ],
  };
}

String statementDisplayName(String path) => p.basename(path);

String statementImportErrorMessage(String code, {String? bankCode}) {
  if (code == 'duplicate_file') {
    return 'This file was already imported.';
  }
  if (code == 'cancelled') return 'Import cancelled.';
  if (code == 'pdf_password_required') {
    return pdfPasswordRequiredMessage(passwordHintForBank(bankCode));
  }
  if (code == 'xls_unsupported_export_xlsx_or_csv') {
    return pdfLoadErrorMessage(code);
  }
  if (code.startsWith('pdf_') || code == 'scanned_pdf') {
    return pdfLoadErrorMessage(code);
  }
  return pdfLoadErrorMessage(code);
}

import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../core/db/database.dart';
import '../../core/result/result.dart';
import '../../insights/insight_format.dart';
import '../investments/cas_import.dart';
import '../investments/cas_parser.dart';
import 'file_source.dart';
import 'pdf/layout_to_grid.dart';
import 'pdf/password_vault.dart';
import 'pdf/pdf_loader.dart';
import 'pdf/positioned_text.dart';

enum BatchFileStatus {
  pending,
  working,
  imported,
  alreadyImported,
  skipped,
  failed,
}

/// Outcome for one file in a batch.
class BatchFileResult {
  const BatchFileResult({
    required this.name,
    this.status = BatchFileStatus.pending,
    this.inserted = 0,
    this.duplicates = 0,
    this.unparsed = 0,
    this.bankCode,
    this.message,
  });

  final String name;
  final BatchFileStatus status;

  /// New transactions written.
  final int inserted;

  /// Rows already in the ledger (from SMS or an overlapping statement).
  final int duplicates;

  /// Rows kept for review instead of imported.
  final int unparsed;
  final String? bankCode;
  final String? message;

  bool get done =>
      status != BatchFileStatus.pending && status != BatchFileStatus.working;

  BatchFileResult copyWith({
    BatchFileStatus? status,
    int? inserted,
    int? duplicates,
    int? unparsed,
    String? bankCode,
    String? message,
  }) => BatchFileResult(
    name: name,
    status: status ?? this.status,
    inserted: inserted ?? this.inserted,
    duplicates: duplicates ?? this.duplicates,
    unparsed: unparsed ?? this.unparsed,
    bankCode: bankCode ?? this.bankCode,
    message: message ?? this.message,
  );
}

/// A picked file's name and contents.
typedef StatementFile = ({String name, Uint8List bytes});

/// Prompt for a statement password. [failedAsks] counts wrong typed
/// passwords for this file so far; [savedTried] is how many saved passwords
/// were tried first. Return null to skip the file.
typedef BatchPasswordPrompt =
    Future<PasswordEntry?> Function(
      String fileName,
      int failedAsks,
      int savedTried,
    );

/// Imports many statements in one go, without a per-file preview. Locked PDFs
/// are opened with saved passwords first; the user is only asked when none
/// work. Rows already in the ledger are skipped by the usual dedupe hash, so
/// overlapping statements are safe.
class StatementBatchImporter {
  StatementBatchImporter({
    required this.db,
    required this.source,
    required this.vault,
    required this.askPassword,
  });

  final ArthDatabase db;
  final StatementFileSource source;
  final PdfPasswordVault vault;
  final BatchPasswordPrompt askPassword;

  /// Emits the full result list after every change; the last emission has
  /// every file done.
  Stream<List<BatchFileResult>> run(List<StatementFile> files) async* {
    final results = [for (final f in files) BatchFileResult(name: f.name)];
    yield List.unmodifiable(results);
    for (var i = 0; i < files.length; i++) {
      results[i] = results[i].copyWith(status: BatchFileStatus.working);
      yield List.unmodifiable(results);
      results[i] = await importOne(files[i]);
      yield List.unmodifiable(results);
    }
  }

  Future<BatchFileResult> importOne(StatementFile f) async {
    final base = BatchFileResult(name: f.name);
    late final PdfUnlockSession session;
    session = PdfUnlockSession(
      vault: vault,
      fileName: f.name,
      ask: (n) => askPassword(f.name, n, session.savedTried),
    );
    try {
      final opened = await openStatementFile(
        db: db,
        source: source,
        file: f,
        session: session,
      );
      if (opened.isErr) {
        final code = opened.errorOrNull!;
        return switch (code) {
          'duplicate_file' => base.copyWith(
              status: BatchFileStatus.alreadyImported,
              message: 'Already imported',
            ),
          'pdf_password_required' => base.copyWith(
              status: BatchFileStatus.skipped,
              message: 'Locked — no password worked',
            ),
          'cas_empty' => base.copyWith(
              status: BatchFileStatus.failed,
              message: 'Investment statement, but no holdings could be read',
            ),
          _ => base.copyWith(
              status: BatchFileStatus.failed,
              message: statementImportErrorMessage(code),
            ),
        };
      }
      switch (opened.okOrNull!) {
        case OpenedCas(:final result):
          return base.copyWith(
            status: BatchFileStatus.imported,
            inserted: result.newTxns,
            bankCode: result.providerLabel,
            message: casSummary(result),
          );
        case OpenedStatement(:final preview):
          final bank = preview.columnMap.bankCode;
          final written = await source.confirmImport(db: db, preview: preview);
          if (written.isErr) {
            return base.copyWith(
              status: BatchFileStatus.failed,
              message: written.errorOrNull,
              bankCode: bank,
            );
          }
          return base.copyWith(
            status: BatchFileStatus.imported,
            inserted: written.okOrNull,
            duplicates: preview.transactions.length - written.okOrNull!,
            unparsed: preview.unparseableCount,
            bankCode: bank,
          );
      }
    } catch (e) {
      return base.copyWith(
        status: BatchFileStatus.failed,
        message: 'Could not read this file',
      );
    }
  }
}

/// A file after [openStatementFile]: investment statements are already
/// stored; bank / card statements await confirmation.
sealed class OpenedFile {
  const OpenedFile();
}

class OpenedCas extends OpenedFile {
  const OpenedCas(this.result);
  final CasImportResult result;
}

class OpenedStatement extends OpenedFile {
  const OpenedStatement(this.preview);
  final StatementImportPreview preview;
}

/// Opens [file] once (PDF passwords via [session]), then routes it: a CAS
/// (CAMS / KFintech / NSDL / CDSL) is parsed and stored right away; anything
/// else becomes a bank / card statement preview. The session is committed
/// (password remembered / marked used) once the file opens.
Future<Result<OpenedFile>> openStatementFile({
  required ArthDatabase db,
  required StatementFileSource source,
  required StatementFile file,
  required PdfUnlockSession session,
  PdfStatementLoader? pdfLoader,
}) async {
  final isPdf = file.name.toLowerCase().endsWith('.pdf');
  List<PdfPageTextContent>? pages;
  if (isPdf) {
    final extracted = await (pdfLoader ?? PdfStatementLoader()).extractPages(
      bytes: file.bytes,
      passwordProvider: session.provide,
    );
    if (extracted.isErr) return Err(extracted.errorOrNull!);
    pages = extracted.okOrNull!;
    final lines = const LayoutToGrid().textLines(pages);
    if (looksLikeCas(lines)) {
      final st = const CasParser().parse(lines);
      await session.commit(bankCode: CasImporter.providerCode(st.provider));
      final stored = await CasImporter(db).store(
        st,
        fileName: file.name,
        contentHash: sha256.convert(file.bytes).toString(),
      );
      if (stored.error != null) return Err(stored.error!);
      return Ok(OpenedCas(stored.result!));
    }
  }
  final preview = await source.previewBytes(
    db: db,
    bytes: file.bytes,
    fileName: file.name,
    pages: pages,
  );
  if (preview.isErr) return Err(preview.errorOrNull!);
  await session.commit(bankCode: preview.okOrNull!.columnMap.bankCode);
  return Ok(OpenedStatement(preview.okOrNull!));
}

/// "5 funds · ₹4,12,000 on 30 Sep 2026 · 120 new transactions"
String casSummary(CasImportResult r) {
  final n = r.schemes + r.holdings;
  final d = r.asOf;
  return [
    '$n holding${n == 1 ? '' : 's'}',
    '${inrWhole(r.valuePaise)}${d == null ? '' : ' on ${d.day} ${monthShort(d.month)} ${d.year}'}',
    if (r.newTxns > 0) '${r.newTxns} new transactions',
    if (r.warnings.isNotEmpty) '${r.warnings.length} to check',
  ].join(' · ');
}

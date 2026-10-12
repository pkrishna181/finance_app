import 'dart:typed_data';

import '../../core/db/database.dart';
import 'file_source.dart';
import 'pdf/password_vault.dart';

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
    final isPdf = f.name.toLowerCase().endsWith('.pdf');
    late final PdfUnlockSession session;
    session = PdfUnlockSession(
      vault: vault,
      fileName: f.name,
      ask: (n) => askPassword(f.name, n, session.savedTried),
    );
    try {
      final preview = await source.previewBytes(
        db: db,
        bytes: f.bytes,
        fileName: f.name,
        passwordProvider: isPdf ? session.provide : null,
      );
      if (preview.isErr) {
        final code = preview.errorOrNull!;
        return switch (code) {
          'duplicate_file' => base.copyWith(
            status: BatchFileStatus.alreadyImported,
            message: 'Already imported',
          ),
          'pdf_password_required' => base.copyWith(
            status: BatchFileStatus.skipped,
            message: 'Locked — no password worked',
          ),
          _ => base.copyWith(
            status: BatchFileStatus.failed,
            message: statementImportErrorMessage(code),
          ),
        };
      }
      final p = preview.okOrNull!;
      final bank = p.columnMap.bankCode;
      await session.commit(bankCode: bank);
      final written = await source.confirmImport(db: db, preview: p);
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
        duplicates: p.transactions.length - written.okOrNull!,
        unparsed: p.unparseableCount,
        bankCode: bank,
      );
    } catch (e) {
      return base.copyWith(
        status: BatchFileStatus.failed,
        message: 'Could not read this file',
      );
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;

import '../crypto/db_key_store.dart';
import '../models/category_defaults.dart';
import '../../parsing/sms/template.dart' show buildDedupeKey;
import 'tables.dart';

part 'database.g.dart';

class UpsertResult {
  const UpsertResult({required this.transactionId, required this.inserted});
  final int transactionId;
  final bool inserted;
}

@DriftDatabase(
  tables: [
    Categories,
    Merchants,
    MerchantAliases,
    Imports,
    Transactions,
    TransactionImports,
    UserCorrections,
    UnparsedSmsRows,
    MandateNotices,
    ModelInfo,
    UnparsedStatementRows,
  ],
)
class ArthDatabase extends _$ArthDatabase {
  ArthDatabase(super.e);

  static Future<ArthDatabase> openEncrypted({DbKeyStore? keyStore}) async {
    final store = keyStore ?? DbKeyStore();
    final key = await store.getOrCreateKey();
    return ArthDatabase(_openEncryptedExecutor(key));
  }

  factory ArthDatabase.openEncryptedFile({
    required File file,
    required String key,
  }) {
    return ArthDatabase(
      NativeDatabase(
        file,
        setup: (db) => applyEncryptionKey(db, key),
      ),
    );
  }

  factory ArthDatabase.memory() {
    return ArthDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(unparsedSmsRows);
            await m.createTable(mandateNotices);
          }
          if (from < 3) {
            await m.addColumn(imports, imports.parsedCount);
            await m.addColumn(imports, imports.skippedCount);
            await m.addColumn(imports, imports.duplicateCount);
            await m.createTable(transactionImports);
            await m.createTable(unparsedStatementRows);
          }
          if (from < 4) {
            await m.createTable(modelInfo);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedCategories() async {
    await batch((b) {
      for (final c in kDefaultCategories) {
        b.insert(
          categories,
          CategoriesCompanion.insert(
            slug: c.slug,
            name: c.name,
            sortOrder: Value(c.sortOrder),
          ),
        );
      }
    });
  }

  /// Idempotent insert: skips rows whose [dedupeHash] already exists.
  Future<int> insertTransactionIdempotent(
    TransactionsCompanion row,
  ) async {
    return into(transactions).insert(
      row,
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Insert or attach provenance. Always records [importId] on the txn.
  Future<UpsertResult> upsertTransactionWithProvenance(
    TransactionsCompanion row, {
    required int importId,
  }) async {
    final hash = row.dedupeHash.value;
    final existing = await (select(transactions)
          ..where((t) => t.dedupeHash.equals(hash)))
        .getSingleOrNull();

    late final int txnId;
    var inserted = false;
    if (existing == null) {
      txnId = await into(transactions).insert(row);
      inserted = true;
    } else {
      txnId = existing.id;
    }

    await into(transactionImports).insert(
      TransactionImportsCompanion.insert(
        transactionId: txnId,
        importId: importId,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return UpsertResult(transactionId: txnId, inserted: inserted);
  }

  Future<Import?> findImportByHash(String contentHash) {
    return (select(imports)..where((t) => t.contentHash.equals(contentHash)))
        .getSingleOrNull();
  }

  Future<int> insertUnparsedSms(UnparsedSmsRowsCompanion row) {
    return into(unparsedSmsRows).insert(row);
  }

  Future<int> insertMandateNotice(MandateNoticesCompanion row) {
    return into(mandateNotices).insert(row);
  }

  Future<int> insertUnparsedStatementRow(UnparsedStatementRowsCompanion row) {
    return into(unparsedStatementRows).insert(row);
  }

  Future<void> upsertModelInfo(ModelInfoCompanion row) async {
    final existing = await (select(modelInfo)
          ..where((t) => t.modelName.equals(row.modelName.value)))
        .getSingleOrNull();
    if (existing == null) {
      await into(modelInfo).insert(row);
    } else {
      await (update(modelInfo)..where((t) => t.id.equals(existing.id))).write(row);
    }
  }
}

QueryExecutor _openEncryptedExecutor(String key) {
  return driftDatabase(
    name: 'arth_encrypted.db',
    native: DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
      setup: (db) {
        applyEncryptionKey(db, key);
      },
    ),
  );
}

void applyEncryptionKey(CommonDatabase db, String key) {
  assert(
    () {
      try {
        return db.select('PRAGMA cipher;').isNotEmpty;
      } catch (_) {
        return false;
      }
    }(),
    'SQLite3MultipleCiphers is required (hooks.user_defines.sqlite3.source=sqlite3mc)',
  );

  final escaped = key.replaceAll("'", "''");
  db.execute("PRAGMA key = '$escaped'");
  db.execute('SELECT count(*) FROM sqlite_master');
}

String buildDedupeHash({
  required String bankCode,
  required DateTime bookedAt,
  required int amountPaise,
  String? ref,
  String? normalizedBody,
}) {
  final material = buildDedupeKey(
    bankCode: bankCode,
    bookedAt: bookedAt,
    amountPaise: amountPaise,
    ref: ref,
    normalizedBody: normalizedBody,
  );
  return sha256.convert(utf8.encode(material)).toString();
}

Future<File> arthEncryptedDbFile() async {
  final dir = await getApplicationSupportDirectory();
  return File(p.join(dir.path, 'arth_encrypted.db'));
}

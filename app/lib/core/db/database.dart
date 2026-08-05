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
import '../../llm/jobs/llm_job_types.dart';
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
    LlmJobs,
    LlmReviewItems,
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
  int get schemaVersion => 5;

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
          if (from < 5) {
            await m.addColumn(merchantAliases, merchantAliases.confidence);
            await m.addColumn(transactions, transactions.suggestedCategorySlug);
            await m.addColumn(transactions, transactions.categorySource);
            await m.createTable(llmJobs);
            await m.createTable(llmReviewItems);
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

  // --- Phase 5: unparsed + LLM queue ---

  Future<int> countUnresolvedUnparsedSms() async {
    final q = selectOnly(unparsedSmsRows)
      ..addColumns([unparsedSmsRows.id.count()])
      ..where(unparsedSmsRows.resolved.equals(false));
    final row = await q.getSingle();
    return row.read(unparsedSmsRows.id.count()) ?? 0;
  }

  Stream<int> watchUnresolvedUnparsedSmsCount() {
    final q = selectOnly(unparsedSmsRows)
      ..addColumns([unparsedSmsRows.id.count()])
      ..where(unparsedSmsRows.resolved.equals(false));
    return q.watchSingle().map((row) => row.read(unparsedSmsRows.id.count()) ?? 0);
  }

  Future<List<UnparsedSmsRow>> listUnresolvedUnparsedSms({int limit = 100}) {
    return (select(unparsedSmsRows)
          ..where((t) => t.resolved.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<UnparsedSmsRow?> getUnparsedSms(int id) {
    return (select(unparsedSmsRows)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> markUnparsedSmsResolved(int id) {
    return (update(unparsedSmsRows)..where((t) => t.id.equals(id)))
        .write(const UnparsedSmsRowsCompanion(resolved: Value(true)));
  }

  Future<int> insertLlmJob(LlmJobsCompanion row) {
    return into(llmJobs).insert(row);
  }

  Future<bool> hasPendingMerchantJob(String rawMerchant) async {
    final key = rawMerchant.trim().toLowerCase();
    final pending = await (select(llmJobs)
          ..where((t) => t.jobType.equals('merchant_normalize'))
          ..where((t) => t.status.isIn(['pending', 'running'])))
        .get();
    for (final job in pending) {
      if (job.payloadJson.toLowerCase().contains(key)) return true;
    }
    final alias = await (select(merchantAliases)
          ..where((t) => t.rawName.equals(rawMerchant.trim())))
        .getSingleOrNull();
    return alias != null;
  }

  Future<List<LlmJob>> fetchPendingJobs({int limit = 50}) async {
    final rows = await (select(llmJobs)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
    rows.sort((a, b) {
      final ta = LlmJobType.fromWire(a.jobType);
      final tb = LlmJobType.fromWire(b.jobType);
      if (ta == null || tb == null) return a.id.compareTo(b.id);
      return llmJobTypeSortOrder(ta).compareTo(llmJobTypeSortOrder(tb));
    });
    return rows;
  }

  Future<void> updateLlmJob(int id, LlmJobsCompanion patch) {
    return (update(llmJobs)..where((t) => t.id.equals(id))).write(patch);
  }

  Future<int> insertReviewItem(LlmReviewItemsCompanion row) {
    return into(llmReviewItems).insert(row);
  }

  Future<List<LlmReviewItem>> listPendingReviewItems() {
    return (select(llmReviewItems)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<LlmReviewItem?> getReviewItem(int id) {
    return (select(llmReviewItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateReviewItem(int id, LlmReviewItemsCompanion patch) {
    return (update(llmReviewItems)..where((t) => t.id.equals(id))).write(patch);
  }

  Future<MerchantAliase?> findMerchantAlias(String rawName) {
    return (select(merchantAliases)..where((t) => t.rawName.equals(rawName.trim())))
        .getSingleOrNull();
  }

  Future<int> upsertMerchantAlias({
    required String rawName,
    required int merchantId,
    required String source,
    double? confidence,
  }) async {
    final existing = await findMerchantAlias(rawName);
    if (existing != null) {
      if (existing.source == 'user' && source != 'user') return existing.id;
      await (update(merchantAliases)..where((t) => t.id.equals(existing.id))).write(
        MerchantAliasesCompanion(
          merchantId: Value(merchantId),
          source: Value(source),
          confidence: Value(confidence),
        ),
      );
      return existing.id;
    }
    return into(merchantAliases).insert(
      MerchantAliasesCompanion.insert(
        rawName: rawName.trim(),
        merchantId: merchantId,
        source: source,
        confidence: Value(confidence),
      ),
    );
  }

  Future<int> findOrCreateMerchant(String canonicalName) async {
    final existing = await (select(merchants)
          ..where((t) => t.canonicalName.equals(canonicalName)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(merchants).insert(
      MerchantsCompanion.insert(canonicalName: canonicalName),
    );
  }

  Future<Category?> categoryBySlug(String slug) {
    return (select(categories)..where((t) => t.slug.equals(slug))).getSingleOrNull();
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

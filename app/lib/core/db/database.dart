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
import '../models/merchant_label.dart';
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
    Budgets,
    StatementSummaries,
    CreditCards,
    Goals,
    GoalContributions,
    Securities,
    InvestmentAccounts,
    InvestmentTxns,
    HoldingSnapshots,
    SecurityPrices,
    ManualAssets,
    ManualAssetValues,
    Loans,
    LoanPrepayments,
    AllocationTargets,
    RetirementPlans,
    Sheets,
  ],
)
class ArthDatabase extends _$ArthDatabase {
  ArthDatabase(super.e);

  static Future<ArthDatabase>? _shared;

  /// The app-wide connection. Every screen must use this rather than
  /// [openEncrypted]: separate connections to the same file contend for
  /// SQLite's write lock (e.g. one running migrations while another reads)
  /// and fail with "database is locked".
  static Future<ArthDatabase> shared() => _shared ??= openEncrypted();

  static Future<ArthDatabase> openEncrypted({DbKeyStore? keyStore}) async {
    final store = keyStore ?? DbKeyStore();
    // No key but a database file: the file came from somewhere else (an
    // Android backup restore, which never carries Keystore keys) and can't
    // be decrypted. Move it aside rather than fail on every launch.
    if (await store.readKey() == null) {
      await setAsideUnreadableDatabase(await arthEncryptedDbFile());
    }
    final key = await store.getOrCreateKey();
    return ArthDatabase(_openEncryptedExecutor(key));
  }

  factory ArthDatabase.openEncryptedFile({
    required File file,
    required String key,
  }) {
    return ArthDatabase(
      NativeDatabase(file, setup: (db) => applyEncryptionKey(db, key)),
    );
  }

  factory ArthDatabase.memory() {
    return ArthDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('''
CREATE TABLE IF NOT EXISTS llm_disagreements (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  job_id INTEGER REFERENCES llm_jobs(id),
  field TEXT NOT NULL,
  llm_value TEXT NOT NULL,
  resolved_value TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
)''');
      await _seedCategories();
      await _createInsightIndexes();
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
      if (from < 6) {
        await customStatement('''
CREATE TABLE IF NOT EXISTS llm_disagreements (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  job_id INTEGER REFERENCES llm_jobs(id),
  field TEXT NOT NULL,
  llm_value TEXT NOT NULL,
  resolved_value TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
)''');
      }
      if (from < 7) {
        await _createInsightIndexes();
      }
      if (from < 8) {
        await m.createTable(budgets);
      }
      if (from < 9) {
        await m.addColumn(transactions, transactions.accountKind);
        await m.createTable(statementSummaries);
        await m.createTable(creditCards);
      }
      if (from < 10) {
        await m.createTable(goals);
        await m.createTable(goalContributions);
      }
      if (from < 11) {
        await m.createTable(securities);
        await m.createTable(investmentAccounts);
        await m.createTable(investmentTxns);
        await m.createTable(holdingSnapshots);
        await m.createTable(securityPrices);
      }
      if (from < 12) {
        await m.createTable(manualAssets);
        await m.createTable(manualAssetValues);
      }
      if (from < 13) {
        await m.addColumn(securities, securities.taxCategory);
      }
      if (from < 14) {
        await m.createTable(loans);
        await m.createTable(loanPrepayments);
      }
      if (from < 15) {
        await m.createTable(allocationTargets);
      }
      if (from < 16) {
        await m.createTable(retirementPlans);
      }
      if (from < 17) {
        await m.createTable(sheets);
      }
      if (from < 18) {
        await m.addColumn(statementSummaries, statementSummaries.printedJson);
        await m.addColumn(
          statementSummaries,
          statementSummaries.instalmentsPaise,
        );
        await m.addColumn(
          statementSummaries,
          statementSummaries.instalmentCount,
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Indexes backing Phase 6 insights range / category queries.
  Future<void> _createInsightIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_booked_at '
      'ON transactions(booked_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_category_booked_at '
      'ON transactions(category_id, booked_at)',
    );
  }

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
  Future<int> insertTransactionIdempotent(TransactionsCompanion row) async {
    return into(transactions).insert(row, mode: InsertMode.insertOrIgnore);
  }

  /// Insert or attach provenance. Always records [importId] on the txn.
  Future<UpsertResult> upsertTransactionWithProvenance(
    TransactionsCompanion row, {
    required int importId,
  }) async {
    final hash = row.dedupeHash.value;
    final existing = await (select(
      transactions,
    )..where((t) => t.dedupeHash.equals(hash))).getSingleOrNull();

    late final int txnId;
    var inserted = false;
    if (existing == null) {
      txnId = await into(transactions).insert(row);
      inserted = true;
      if (row.categoryId.value == null) {
        await _applyMerchantCategoryRule(txnId, row.rawMerchant.value);
      }
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

  /// An SMS transaction that is the same payment as a statement row with no
  /// shared reference (card purchases: the SMS has no ref the statement
  /// prints). Same bank, amount and direction, booked within a day, card or
  /// account number compatible (one ends with the other — statements may
  /// print only the last two digits). Ids in [taken] were already matched to
  /// another row of this statement, so two identical payments on one day
  /// stay two.
  Future<int?> findSmsMatch({
    required String bankCode,
    required int amountPaise,
    required String direction,
    required DateTime bookedAt,
    String? accountHint,
    Set<int> taken = const {},
  }) async {
    final day = DateTime.utc(bookedAt.year, bookedAt.month, bookedAt.day);
    final rows = await customSelect(
      'SELECT t.id, t.account_hint, t.booked_at FROM transactions t '
      'WHERE t.bank_code = ? AND t.amount_paise = ? AND t.direction = ? '
      'AND t.booked_at >= ? AND t.booked_at < ? '
      'AND EXISTS (SELECT 1 FROM transaction_imports ti '
      'JOIN imports i ON i.id = ti.import_id '
      "WHERE ti.transaction_id = t.id AND i.source_type = 'sms') "
      'ORDER BY t.booked_at',
      variables: [
        Variable<String>(bankCode),
        Variable<int>(amountPaise),
        Variable<String>(direction),
        Variable<DateTime>(day.subtract(const Duration(days: 1))),
        Variable<DateTime>(day.add(const Duration(days: 2))),
      ],
      readsFrom: {transactions, transactionImports, imports},
    ).get();
    bool compatible(String? a, String? b) =>
        a == null || b == null || a.endsWith(b) || b.endsWith(a);
    // Same day first, then the day either side.
    final candidates = rows
        .where((r) => !taken.contains(r.read<int>('id')))
        .where((r) => compatible(r.read<String?>('account_hint'), accountHint))
        .toList()
      ..sort((a, b) {
        int gap(QueryRow r) =>
            r.read<DateTime>('booked_at').difference(day).inHours.abs();
        return gap(a).compareTo(gap(b));
      });
    return candidates.isEmpty ? null : candidates.first.read<int>('id');
  }

  /// Latest merchant-wide category rule for [rawMerchant]: a `category`
  /// correction with no transaction id whose normalized raw label matches.
  Future<String?> merchantCategoryRule(String rawMerchant) async {
    final key = normalizeMerchantLabel(rawMerchant);
    if (key.length < 3) return null;
    final rules =
        await (select(userCorrections)
              ..where((t) => t.transactionId.isNull())
              ..where((t) => t.field.equals('category'))
              ..orderBy([(t) => OrderingTerm.desc(t.id)]))
            .get();
    for (final r in rules) {
      if (normalizeMerchantLabel(r.rawMerchant) == key) return r.newValue;
    }
    return null;
  }

  Future<void> _applyMerchantCategoryRule(int txnId, String rawMerchant) async {
    final slug = await merchantCategoryRule(rawMerchant);
    if (slug == null) return;
    final cat = await categoryBySlug(slug);
    if (cat == null) return;
    await (update(transactions)..where((t) => t.id.equals(txnId))).write(
      TransactionsCompanion(
        categoryId: Value(cat.id),
        suggestedCategorySlug: Value(slug),
        categorySource: const Value('user_correction'),
      ),
    );
  }

  Future<Import?> findImportByHash(String contentHash) {
    return (select(
      imports,
    )..where((t) => t.contentHash.equals(contentHash))).getSingleOrNull();
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
    final existing = await (select(
      modelInfo,
    )..where((t) => t.modelName.equals(row.modelName.value))).getSingleOrNull();
    if (existing == null) {
      await into(modelInfo).insert(row);
    } else {
      await (update(
        modelInfo,
      )..where((t) => t.id.equals(existing.id))).write(row);
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
    return q.watchSingle().map(
      (row) => row.read(unparsedSmsRows.id.count()) ?? 0,
    );
  }

  Future<List<UnparsedSmsRow>> listUnresolvedUnparsedSms({int limit = 100}) {
    return (select(unparsedSmsRows)
          ..where((t) => t.resolved.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<UnparsedSmsRow?> getUnparsedSms(int id) {
    return (select(
      unparsedSmsRows,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> markUnparsedSmsResolved(int id) {
    return (update(unparsedSmsRows)..where((t) => t.id.equals(id))).write(
      const UnparsedSmsRowsCompanion(resolved: Value(true)),
    );
  }

  Future<int> insertLlmJob(LlmJobsCompanion row) {
    return into(llmJobs).insert(row);
  }

  Future<int> countPendingLlmJobs() async {
    final count = llmJobs.id.count();
    final row =
        await (selectOnly(llmJobs)
              ..addColumns([count])
              ..where(llmJobs.status.equals('pending')))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Stream<int> watchPendingLlmJobCount() {
    final count = llmJobs.id.count();
    final q = selectOnly(llmJobs)
      ..addColumns([count])
      ..where(llmJobs.status.equals('pending'));
    return q.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Jobs left `running` after a process kill return to `pending`.
  Future<int> recoverStaleRunningLlmJobs() async {
    return (update(llmJobs)..where((t) => t.status.equals('running'))).write(
      LlmJobsCompanion(
        status: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> hasPendingMerchantJob(String rawMerchant) async {
    final key = rawMerchant.trim().toLowerCase();
    final pending =
        await (select(llmJobs)
              ..where((t) => t.jobType.equals('merchant_normalize'))
              ..where((t) => t.status.isIn(['pending', 'running'])))
            .get();
    for (final job in pending) {
      if (job.payloadJson.toLowerCase().contains(key)) return true;
    }
    final alias = await (select(
      merchantAliases,
    )..where((t) => t.rawName.equals(rawMerchant.trim()))).getSingleOrNull();
    return alias != null;
  }

  Future<List<LlmJob>> fetchPendingJobs({int limit = 50}) async {
    final rows =
        await (select(llmJobs)
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
    return (select(
      llmReviewItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateReviewItem(int id, LlmReviewItemsCompanion patch) {
    return (update(llmReviewItems)..where((t) => t.id.equals(id))).write(patch);
  }

  Future<MerchantAliase?> findMerchantAlias(String rawName) {
    return (select(
      merchantAliases,
    )..where((t) => t.rawName.equals(rawName.trim()))).getSingleOrNull();
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
      await (update(
        merchantAliases,
      )..where((t) => t.id.equals(existing.id))).write(
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
    final existing = await (select(
      merchants,
    )..where((t) => t.canonicalName.equals(canonicalName))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(
      merchants,
    ).insert(MerchantsCompanion.insert(canonicalName: canonicalName));
  }

  Future<Category?> categoryBySlug(String slug) {
    return (select(
      categories,
    )..where((t) => t.slug.equals(slug))).getSingleOrNull();
  }

  Future<int> insertLlmDisagreement({
    int? jobId,
    required String field,
    required String llmValue,
    required String resolvedValue,
  }) {
    if (jobId == null) {
      return customInsert(
        'INSERT INTO llm_disagreements (field, llm_value, resolved_value) '
        'VALUES (?, ?, ?)',
        variables: [
          Variable<String>(field),
          Variable<String>(llmValue),
          Variable<String>(resolvedValue),
        ],
      );
    }
    return customInsert(
      'INSERT INTO llm_disagreements (job_id, field, llm_value, resolved_value) '
      'VALUES (?, ?, ?, ?)',
      variables: [
        Variable<int>(jobId),
        Variable<String>(field),
        Variable<String>(llmValue),
        Variable<String>(resolvedValue),
      ],
    );
  }

  Future<Map<String, int>> countLlmDisagreementsByField() async {
    final rows = await customSelect(
      'SELECT field, COUNT(*) AS c FROM llm_disagreements GROUP BY field',
    ).get();
    return {
      for (final row in rows) row.read<String>('field'): row.read<int>('c'),
    };
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
  // Wait for a competing writer instead of failing straight away.
  db.execute('PRAGMA busy_timeout = 5000');
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

/// Renames [db] and its WAL/SHM/journal files to `*.unreadable-<millis>`.
/// Returns whether anything was moved.
Future<bool> setAsideUnreadableDatabase(File db, {DateTime? now}) async {
  final stamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
  var moved = false;
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    final f = File('${db.path}$suffix');
    if (await f.exists()) {
      await f.rename('${f.path}.unreadable-$stamp');
      moved = true;
    }
  }
  return moved;
}

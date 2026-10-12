import 'dart:math';

import 'package:drift/drift.dart' show Value, Variable;

import '../core/db/database.dart';

/// Bank code for money that isn't in any account.
const kCashBankCode = 'CASH';

/// Prefix of `dedupe_hash` for rows the user typed in.
const kManualHashPrefix = 'manual:';

/// Adds, edits and deletes transactions the user enters by hand (cash
/// spending, things no SMS or statement covers). Imported rows can't be
/// edited or deleted here.
class ManualTransactionRepository {
  ManualTransactionRepository(this._db);

  final ArthDatabase _db;

  /// Bank codes seen in the ledger, plus [kCashBankCode] first.
  Future<List<String>> accounts() async {
    final rows = await _db.customSelect(
      'SELECT DISTINCT bank_code AS b FROM transactions '
      "WHERE bank_code <> ? AND bank_code <> 'UNKNOWN' ORDER BY b",
      variables: [Variable<String>(kCashBankCode)],
      readsFrom: {_db.transactions},
    ).get();
    return [kCashBankCode, for (final r in rows) r.read<String>('b')];
  }

  Future<int> add({
    required int amountPaise,
    required bool isDebit,
    required DateTime bookedAt,
    required String description,
    String? categorySlug,
    String bankCode = kCashBankCode,
  }) async {
    _check(amountPaise, description);
    final catId = await _categoryId(categorySlug);
    final r = Random.secure();
    final id = List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            amountPaise: amountPaise,
            direction: isDebit ? 'debit' : 'credit',
            txnType: 'other',
            bookedAt: bookedAt,
            bankCode: bankCode,
            rawMerchant: description.trim(),
            rawDescription: description.trim(),
            dedupeHash: '$kManualHashPrefix$id',
            categoryId: Value(catId),
            categorySource: Value(catId == null ? null : 'user'),
            suggestedCategorySlug: Value(categorySlug),
            accountKind: Value(bankCode == kCashBankCode ? 'cash' : null),
          ),
        );
  }

  Future<void> update(
    int id, {
    required int amountPaise,
    required bool isDebit,
    required DateTime bookedAt,
    required String description,
    String? categorySlug,
    String bankCode = kCashBankCode,
  }) async {
    _check(amountPaise, description);
    await _requireManual(id);
    final catId = await _categoryId(categorySlug);
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amountPaise: Value(amountPaise),
        direction: Value(isDebit ? 'debit' : 'credit'),
        bookedAt: Value(bookedAt),
        bankCode: Value(bankCode),
        rawMerchant: Value(description.trim()),
        rawDescription: Value(description.trim()),
        categoryId: Value(catId),
        categorySource: Value(catId == null ? null : 'user'),
        suggestedCategorySlug: Value(categorySlug),
        accountKind: Value(bankCode == kCashBankCode ? 'cash' : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(int id) async {
    await _requireManual(id);
    await _db.transaction(() async {
      await (_db.delete(_db.userCorrections)
            ..where((c) => c.transactionId.equals(id)))
          .go();
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<Transaction?> get(int id) => (_db.select(_db.transactions)
        ..where((t) => t.id.equals(id)))
      .getSingleOrNull();

  void _check(int amountPaise, String description) {
    if (amountPaise <= 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise', 'must be positive');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError.value(description, 'description', 'required');
    }
  }

  Future<int?> _categoryId(String? slug) async {
    if (slug == null) return null;
    final c = await _db.categoryBySlug(slug);
    if (c == null) throw ArgumentError.value(slug, 'slug', 'unknown category');
    return c.id;
  }

  Future<void> _requireManual(int id) async {
    final t = await get(id);
    if (t == null || !t.dedupeHash.startsWith(kManualHashPrefix)) {
      throw StateError('Only manually added transactions can be changed');
    }
  }
}

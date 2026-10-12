import 'package:arth/core/db/database.dart';
import 'package:arth/core/models/transaction_type.dart';
import 'package:arth/insights/insights.dart';
import 'package:arth/llm/category_rule_engine.dart';
import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ArthDatabase db;
  late InsightsRepository repo;
  late int importId;

  setUp(() async {
    db = ArthDatabase.memory();
    repo = InsightsRepository(db);
    importId = await db.into(db.imports).insert(ImportsCompanion.insert(
          sourceType: 'sms',
          sourceLabel: 'test',
          contentHash: 'h',
        ));
  });
  tearDown(() => db.close());

  Future<int> catId(String slug) async => (await db.categoryBySlug(slug))!.id;

  Future<int> insert(
    String hash,
    String raw, {
    String? categorySlug,
    String? source,
    int day = 3,
  }) async {
    final r = await db.upsertTransactionWithProvenance(
      TransactionsCompanion.insert(
        amountPaise: 25000,
        direction: 'debit',
        txnType: 'upi',
        bookedAt: DateTime(2026, 9, day, 10),
        bankCode: 'HDFC',
        rawMerchant: raw,
        rawDescription: raw,
        dedupeHash: hash,
        categoryId:
            Value(categorySlug == null ? null : await catId(categorySlug)),
        categorySource: Value(source),
      ),
      importId: importId,
    );
    return r.transactionId;
  }

  Future<InsightTxn> load(int id) async {
    final rows = await repo.loadRange(DateTime(2026), DateTime(2027));
    return rows.firstWhere((t) => t.id == id);
  }

  test('recategorize updates one row and records the correction', () async {
    final a = await insert('a', 'UPI-SWIGGY-1234');
    final b = await insert('b', 'UPI-SWIGGY-9876', day: 4);

    final n = await repo.recategorize(await load(a), 'food_delivery');
    expect(n, 1);

    final ta = await load(a);
    expect(ta.categorySlug, 'food_delivery');
    expect(ta.categorySource, 'user');
    expect((await load(b)).categorySlug, isNull);

    final corr = await db.select(db.userCorrections).get();
    expect(corr, hasLength(1));
    expect(corr.single.transactionId, a);
    expect(corr.single.field, 'category');
    expect(corr.single.oldValue, isNull);
    expect(corr.single.newValue, 'food_delivery');
  });

  test('applyToMerchant matches normalized label and skips user rows',
      () async {
    final a = await insert('a', 'UPI-SWIGGY-1234');
    final b = await insert('b', 'upi/swiggy/5555', day: 4,
        categorySlug: 'shopping', source: 'llm');
    final c = await insert('c', 'UPI-SWIGGY-7777', day: 5,
        categorySlug: 'groceries', source: 'user');
    final d = await insert('d', 'UPI-ZOMATO-1234', day: 6);

    expect(await repo.similarTransactionIds(await load(a)), [b]);

    final n = await repo.recategorize(
      await load(a),
      'food_delivery',
      applyToMerchant: true,
    );
    expect(n, 2);
    expect((await load(b)).categorySlug, 'food_delivery');
    expect((await load(b)).categorySource, 'user');
    expect((await load(c)).categorySlug, 'groceries');
    expect((await load(d)).categorySlug, isNull);

    final rules = await (db.select(db.userCorrections)
          ..where((t) => t.transactionId.isNull()))
        .get();
    expect(rules.single.newValue, 'food_delivery');
  });

  test('merchant rule applies to new imports and the rule engine', () async {
    final a = await insert('a', 'UPI-SWIGGY-1234');
    await repo.recategorize(await load(a), 'food_delivery',
        applyToMerchant: true);

    final later = await insert('later', 'UPI SWIGGY 42', day: 20);
    final t = await load(later);
    expect(t.categorySlug, 'food_delivery');
    expect(t.categorySource, 'user_correction');

    // Explicit categories on insert are kept.
    final explicit =
        await insert('x', 'UPI SWIGGY 43', day: 21, categorySlug: 'shopping');
    expect((await load(explicit)).categorySlug, 'shopping');

    final engine = CategoryRuleEngine(merchantMap: const {}, keywordRules: []);
    final hit = await engine.resolve(
      db: db,
      rawMerchant: 'upi/swiggy/99',
      narration: '',
      direction: TransactionDirection.debit,
    );
    expect(hit?.slug, 'food_delivery');
    expect(hit?.source, 'user_correction');
  });

  test('canonical merchant: matches by id and sets merchant default',
      () async {
    final mId = await db.findOrCreateMerchant('Swiggy');
    final a = await insert('a', 'SWIGGY BLR');
    final b = await insert('b', 'BUNDL TECH', day: 4);
    await db.customUpdate('UPDATE transactions SET merchant_id = ?',
        variables: [Variable<int>(mId)], updates: {db.transactions});

    await repo.recategorize(await load(a), 'food_delivery',
        applyToMerchant: true);
    expect((await load(b)).categorySlug, 'food_delivery');
    final m = await (db.select(db.merchants)..where((x) => x.id.equals(mId)))
        .getSingle();
    expect(m.defaultCategoryId, await catId('food_delivery'));
  });

  test('pickableCategories is in sort order', () async {
    final cats = await repo.pickableCategories();
    expect(cats.first.slug, 'groceries');
    expect(cats.last.slug, 'uncategorized');
  });
}

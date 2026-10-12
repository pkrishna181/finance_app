import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TxnQuery.parse', () {
    test('text terms, quotes, and unknown keys', () {
      final q = TxnQuery.parse('Swiggy "amazon pay" foo:bar');
      expect(q.terms, ['swiggy', 'amazon pay', 'foo:bar']);
      expect(q.isEmpty, isFalse);
      expect(TxnQuery.parse('   ').isEmpty, isTrue);
    });

    test('amount operators in rupees', () {
      expect(TxnQuery.parse('>500').minPaise, 50001);
      expect(TxnQuery.parse('>=500').minPaise, 50000);
      expect(TxnQuery.parse('<2000').maxPaise, 199999);
      expect(TxnQuery.parse('<=₹99.50').maxPaise, 9950);
      final eq = TxnQuery.parse('=499');
      expect((eq.minPaise, eq.maxPaise), (49900, 49900));
    });

    test('dates, months, direction, bank, category', () {
      final q = TxnQuery.parse(
          'from:2026-04-01 to:2026-06-30 debit bank:HDFC cat:"Food Delivery"');
      expect(q.from, DateTime(2026, 4, 1));
      expect(q.toExclusive, DateTime(2026, 7, 1));
      expect(q.isDebit, isTrue);
      expect(q.bank, 'hdfc');
      expect(q.category, 'food delivery');

      final m = TxnQuery.parse('in:2026-12 credit');
      expect(m.from, DateTime(2026, 12));
      expect(m.toExclusive, DateTime(2027, 1));
      expect(m.isDebit, isFalse);
    });

    test('invalid dates fall back to text', () {
      final q = TxnQuery.parse('from:2026-02-30 in:2026-13');
      expect(q.from, isNull);
      expect(q.terms, ['from:2026-02-30', 'in:2026-13']);
    });
  });

  group('InsightsRepository.search', () {
    late ArthDatabase db;
    late InsightsRepository repo;

    setUp(() async {
      db = ArthDatabase.memory();
      repo = InsightsRepository(db);
      Future<void> add(String h, String raw, int rupees, DateTime at,
          {String dir = 'debit', String? cat, String bank = 'HDFC'}) async {
        await db.into(db.transactions).insert(TransactionsCompanion.insert(
              amountPaise: rupees * 100,
              direction: dir,
              txnType: 'upi',
              bookedAt: at,
              bankCode: bank,
              rawMerchant: raw,
              rawDescription: '$raw ref',
              dedupeHash: h,
              categoryId: Value(
                  cat == null ? null : (await db.categoryBySlug(cat))!.id),
            ));
      }

      await add('a', 'SWIGGY BLR', 450, DateTime(2026, 9, 3),
          cat: 'food_delivery');
      await add('b', 'SWIGGY INSTAMART', 1200, DateTime(2026, 9, 10),
          cat: 'groceries');
      await add('c', 'ACME PAYROLL', 100000, DateTime(2026, 9, 1),
          dir: 'credit', cat: 'salary', bank: 'ICICI');
      await add('d', 'SHOP_50%OFF', 300, DateTime(2026, 8, 20));
    });
    tearDown(() => db.close());

    Future<List<String>> run(String q) async => [
          for (final t in await repo.search(TxnQuery.parse(q))) t.rawMerchant,
        ];

    test('filters combine and results are newest first', () async {
      expect(await run('swiggy'), ['SWIGGY INSTAMART', 'SWIGGY BLR']);
      expect(await run('swiggy >500'), ['SWIGGY INSTAMART']);
      expect(await run('cat:food'), ['SWIGGY BLR']); // name prefix
      expect(await run('cat:groceries'), ['SWIGGY INSTAMART']);
      expect(await run('cat:none'), ['SHOP_50%OFF']);
      expect(await run('credit bank:icici'), ['ACME PAYROLL']);
      expect(await run('in:2026-08'), ['SHOP_50%OFF']);
      expect(await run('from:2026-09-03 to:2026-09-03'), ['SWIGGY BLR']);
      expect(await run('ref'), hasLength(4)); // description match
    });

    test('LIKE wildcards in the query are literal', () async {
      expect(await run('50%'), ['SHOP_50%OFF']);
      expect(await run('p_5'), ['SHOP_50%OFF']);
      expect(await run('%'), ['SHOP_50%OFF']);
    });

    test('recategorizeMany updates rows and logs one correction each',
        () async {
      final rows = await repo.search(TxnQuery.parse('swiggy'));
      expect(await repo.recategorizeMany(rows, 'shopping'), 2);
      final after = await repo.search(TxnQuery.parse('cat:shopping'));
      expect(after.every((t) => t.categorySource == 'user'), isTrue);
      expect(after, hasLength(2));
      final corr = await db.select(db.userCorrections).get();
      expect(corr, hasLength(2));
      expect(corr.every((c) => c.transactionId != null), isTrue);
      expect(corr.map((c) => c.oldValue).toSet(),
          {'food_delivery', 'groceries'});
    });
  });
}

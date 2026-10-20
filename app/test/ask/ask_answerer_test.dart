import 'package:arth/ask/ask.dart';
import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20, 14);
  late ArthDatabase db;
  late AskAnswerer ask;
  final sep = AskPeriod.month(const MonthKey(2026, 9));
  final oct = AskPeriod.month(const MonthKey(2026, 10), now: now);

  setUp(() async {
    db = ArthDatabase.memory();
    ask = AskAnswerer(db);
    var n = 0;
    Future<void> add(
      String raw,
      int rupees,
      DateTime at, {
      String dir = 'debit',
      String? cat,
    }) async {
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              amountPaise: rupees * 100,
              direction: dir,
              txnType: 'upi',
              bookedAt: at,
              bankCode: 'HDFC',
              rawMerchant: raw,
              rawDescription: '$raw ref',
              dedupeHash: 'h${n++}',
              categoryId: Value(
                cat == null ? null : (await db.categoryBySlug(cat))!.id,
              ),
            ),
          );
    }

    await add(
      'ACME PAYROLL',
      100000,
      DateTime(2026, 9, 1),
      dir: 'credit',
      cat: 'salary',
    );
    await add('SWIGGY BLR', 450, DateTime(2026, 9, 3), cat: 'food_delivery');
    await add('SWIGGY BLR', 650, DateTime(2026, 9, 18), cat: 'food_delivery');
    await add(
      'SWIGGY BLR',
      150,
      DateTime(2026, 9, 19),
      dir: 'credit',
      cat: 'food_delivery',
    ); // refund
    await add(
      'SWIGGY INSTAMART',
      1200,
      DateTime(2026, 9, 10),
      cat: 'groceries',
    );
    await add('LANDLORD', 25000, DateTime(2026, 9, 5), cat: 'rent');
    await add('ZOMATO', 800, DateTime(2026, 8, 12), cat: 'food_delivery');
    await add('LANDLORD', 25000, DateTime(2026, 8, 5), cat: 'rent');
    await add('MYSTERY SHOP', 300, DateTime(2026, 9, 25));
    await add('LANDLORD', 25000, DateTime(2026, 10, 5), cat: 'rent');
  });
  tearDown(() => db.close());

  test(
    'category spend matches Insights, refunds netted, vs last month',
    () async {
      final a = await ask.answer(
        AskQuery(
          intent: AskIntent.spend,
          period: sep,
          categorySlug: 'food_delivery',
        ),
        now,
      );
      final agg = await InsightsRepository(
        db,
      ).aggregatorFor(const MonthKey(2026, 9));
      expect(
        agg.summarize(const MonthKey(2026, 9)).byCategory['food_delivery'],
        95000,
      );
      expect(
        a.headline,
        'You spent ₹950 on Food Delivery in Sep 2026 (2 payments).',
      );
      expect(a.understoodAs, 'Spending · Food Delivery · Sep 2026');
      expect(a.rows.single.label, 'Aug 2026');
      expect(a.rows.single.paise, 80000);
      expect(
        a.searchQuery,
        'cat:food_delivery from:2026-09-01 to:2026-09-30 debit',
      );
    },
  );

  test('total spend notes uncategorised money', () async {
    final a = await ask.answer(
      AskQuery(intent: AskIntent.spend, period: sep),
      now,
    );
    // 450 + 650 - 150 + 1200 + 25000 + 300
    expect(a.headline, startsWith('You spent ₹27,450 in Sep 2026'));
    expect(a.note, contains('₹300 of it isn\'t categorised yet.'));
    expect(a.rows.map((r) => r.label), contains('Rent'));
  });

  test('merchant spend counts payments only', () async {
    final a = await ask.answer(
      AskQuery(intent: AskIntent.spend, period: sep, merchant: 'swiggy'),
      now,
    );
    expect(
      a.headline,
      'You spent ₹2,300 at "swiggy" in Sep 2026 (3 payments).',
    );
  });

  test('no data for a period says so', () async {
    final a = await ask.answer(
      AskQuery(
        intent: AskIntent.spend,
        period: AskPeriod.month(const MonthKey(2025, 1)),
      ),
      now,
    );
    expect(a.headline, 'I don\'t have any transactions from Jan 2025.');
  });

  test('income, savings and top categories', () async {
    final income = await ask.answer(
      AskQuery(intent: AskIntent.income, period: sep),
      now,
    );
    expect(income.headline, 'Your income in Sep 2026 was ₹1,00,000.');
    expect(income.rows.single.label, 'Salary');

    final saved = await ask.answer(
      AskQuery(intent: AskIntent.savings, period: sep),
      now,
    );
    expect(
      saved.headline,
      'You saved ₹72,550 in Sep 2026 — 73% of your income.',
    );

    final top = await ask.answer(
      AskQuery(intent: AskIntent.topCategories, period: sep),
      now,
    );
    expect(top.rows.first.label, 'Rent');
    expect(top.headline, startsWith('Rent was your biggest category'));
  });

  test('top merchants and largest payments', () async {
    final m = await ask.answer(
      AskQuery(
        intent: AskIntent.topMerchants,
        period: sep,
        categorySlug: 'food_delivery',
      ),
      now,
    );
    expect(m.rows.single.label, 'SWIGGY BLR');
    expect(m.rows.single.paise, 110000);

    final big = await ask.answer(
      AskQuery(intent: AskIntent.largest, period: sep),
      now,
    );
    expect(big.transactions.first.rawMerchant, 'LANDLORD');
    expect(big.headline, contains('₹25,000 to LANDLORD on 5 Sep 2026'));
  });

  test('last paid looks across all time', () async {
    final a = await ask.answer(
      const AskQuery(intent: AskIntent.lastPaid, categorySlug: 'rent'),
      now,
    );
    expect(
      a.headline,
      'You last paid ₹25,000 for Rent on 5 Oct 2026 (LANDLORD).',
    );
    expect(a.transactions, hasLength(3));
  });

  test('average over months that have data', () async {
    final a = await ask.answer(
      const AskQuery(
        intent: AskIntent.average,
        categorySlug: 'rent',
        months: 3,
      ),
      now,
    );
    expect(
      a.headline,
      'On average you spend ₹25,000 a month on Rent '
      '(2 full months, Aug 2026 – Sep 2026).',
    );
    expect(a.note, 'Only 2 of the last 3 months have data.');
  });

  test('net worth and budgets when nothing is set up', () async {
    final b = await ask.answer(const AskQuery(intent: AskIntent.budgets), now);
    expect(b.headline, 'You haven\'t set any budgets yet.');
  });

  test('budgets report status', () async {
    await BudgetRepository(db).upsert(
      'rent',
      limitPaise: 20000 * 100,
      rollover: false,
      start: const MonthKey(2026, 10),
    );
    final b = await ask.answer(const AskQuery(intent: AskIntent.budgets), now);
    expect(b.headline, '1 over budget in Oct 2026 so far.');
    expect(b.rows.single.flagged, isTrue);
  });

  test('vocabulary lists merchants', () async {
    final v = await ask.vocabulary();
    expect(v.merchants, containsAll(['swiggy blr', 'landlord']));
    expect(v.categoryNames['rent'], 'Rent');
    expect(oct.label, 'Oct 2026 so far');
  });
}

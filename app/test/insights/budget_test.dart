import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(int rupees, DateTime at, String cat, {bool debit = true}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: debit,
      bookedAt: at,
      bankCode: 'HDFC',
      categorySlug: cat,
      rawMerchant: 'Shop',
    );

const calc = BudgetCalculator();
final sep = MonthKey(2026, 9);
const names = {'groceries': 'Groceries', 'fuel': 'Fuel'};

BudgetDef def(String slug, int rupees,
        {bool rollover = false, MonthKey? start}) =>
    BudgetDef(
      slug: slug,
      limitPaise: rupees * 100,
      rollover: rollover,
      start: start ?? MonthKey(2026, 1),
    );

void main() {
  test('status thresholds and ordering', () {
    final agg = InsightsAggregator([
      tx(9000, DateTime(2026, 9, 3), 'groceries'),
      tx(4000, DateTime(2026, 9, 4), 'fuel'),
    ]);
    final out = calc.compute(
      agg,
      sep,
      [def('fuel', 5000), def('groceries', 8000)],
      names,
    );
    expect(out.map((b) => b.slug), ['groceries', 'fuel']);
    expect(out[0].status, BudgetStatus.over);
    expect(out[0].remainingPaise, -100000);
    expect(out[1].status, BudgetStatus.warning); // 80% used
  });

  test('refunds net against spend', () {
    final agg = InsightsAggregator([
      tx(6000, DateTime(2026, 9, 3), 'groceries'),
      tx(2000, DateTime(2026, 9, 5), 'groceries', debit: false),
    ]);
    final b = calc.compute(agg, sep, [def('groceries', 8000)], names).single;
    expect(b.spentPaise, 400000);
    expect(b.status, BudgetStatus.ok);
  });

  test('rollover carries surplus and deficit from the start month', () {
    final agg = InsightsAggregator([
      tx(3000, DateTime(2026, 6, 3), 'groceries'), // before start: ignored
      tx(4000, DateTime(2026, 7, 3), 'groceries'), // +1000
      tx(7000, DateTime(2026, 8, 3), 'groceries'), // -2000
      tx(2000, DateTime(2026, 9, 3), 'groceries'),
    ]);
    final b = calc
        .compute(
          agg,
          sep,
          [def('groceries', 5000, rollover: true, start: MonthKey(2026, 7))],
          names,
        )
        .single;
    expect(b.carryPaise, -100000);
    expect(b.availablePaise, 400000);
    expect(b.remainingPaise, 200000);
  });

  test('budgets starting after the month are skipped', () {
    final agg = InsightsAggregator([tx(100, DateTime(2026, 9, 3), 'fuel')]);
    expect(
      calc.compute(agg, sep, [def('fuel', 500, start: MonthKey(2026, 10))],
          names),
      isEmpty,
    );
  });

  test('pace hint only for the current month', () {
    final agg =
        InsightsAggregator([tx(3000, DateTime(2026, 9, 2), 'groceries')]);
    final now = calc.compute(agg, sep, [def('groceries', 6000)], names,
        asOf: DateTime(2026, 9, 6)).single;
    expect(now.status, BudgetStatus.ok);
    expect(now.aheadOfPace, isTrue); // 50% spent, 20% of month gone
    final past = calc.compute(agg, sep, [def('groceries', 6000)], names,
        asOf: DateTime(2026, 10, 6)).single;
    expect(past.aheadOfPace, isFalse);
  });

  test('suggestLimit averages prior months with data, rounds up', () {
    final agg = InsightsAggregator([
      tx(4010, DateTime(2026, 7, 3), 'groceries'),
      tx(5000, DateTime(2026, 8, 3), 'groceries'),
    ]);
    expect(BudgetCalculator.suggestLimit(agg, sep, 'groceries'), 460000); // avg ₹4,505 → ₹4,600
    expect(BudgetCalculator.suggestLimit(agg, sep, 'fuel'), isNull);
  });

  test('isBudgetableSlug excludes income and transfers', () {
    expect(isBudgetableSlug('groceries'), isTrue);
    expect(isBudgetableSlug('salary'), isFalse);
    expect(isBudgetableSlug('transfers_self'), isFalse);
    expect(isBudgetableSlug('uncategorized'), isFalse);
  });

  group('BudgetRepository', () {
    late ArthDatabase db;
    setUp(() => db = ArthDatabase.memory());
    tearDown(() => db.close());

    test('upsert keeps start month, updates limit; delete removes', () async {
      final repo = BudgetRepository(db);
      await repo.upsert('groceries',
          limitPaise: 500000, rollover: false, start: MonthKey(2026, 8));
      await repo.upsert('groceries',
          limitPaise: 600000, rollover: true, start: MonthKey(2026, 9));
      final b = (await repo.list()).single;
      expect(b.slug, 'groceries');
      expect(b.limitPaise, 600000);
      expect(b.rollover, isTrue);
      expect(b.start, MonthKey(2026, 8));

      await repo.delete('groceries');
      expect(await repo.list(), isEmpty);
    });

    test('rejects bad input', () async {
      final repo = BudgetRepository(db);
      expect(
        () => repo.upsert('nope',
            limitPaise: 100, rollover: false, start: MonthKey(2026, 9)),
        throwsArgumentError,
      );
      expect(
        () => repo.upsert('fuel',
            limitPaise: 0, rollover: false, start: MonthKey(2026, 9)),
        throwsArgumentError,
      );
    });
  });
}

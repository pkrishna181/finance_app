import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(
  int rupees, {
  required DateTime at,
  bool debit = true,
  String? cat,
  String? source,
  String bank = 'HDFC',
  String? acct = '1234',
  String? merchant,
  int? merchantId,
}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: debit,
      bookedAt: at,
      bankCode: bank,
      accountHint: acct,
      categorySlug: cat,
      categorySource: source,
      merchantName: merchant,
      merchantId: merchantId,
      rawMerchant: merchant ?? 'RAW',
    );

void main() {
  final jul = MonthKey(2026, 7);
  DateTime d(int day, [int month = 7]) => DateTime(2026, month, day, 12);

  test('MonthKey arithmetic wraps years', () {
    expect(MonthKey(2026, 1).plusMonths(-1), MonthKey(2025, 12));
    expect(MonthKey(2026, 11).plusMonths(3), MonthKey(2027, 2));
  });

  test('income, spend, savings rate, uncategorized', () {
    final agg = InsightsAggregator([
      tx(50000, at: d(1), debit: false, cat: 'salary'),
      tx(1000, at: d(2), cat: 'groceries'),
      tx(500, at: d(3), cat: 'groceries'),
      tx(200, at: d(4)),
    ]);
    final s = agg.summarize(jul);
    expect(s.incomePaise, 5000000);
    expect(s.spendPaise, 170000);
    expect(s.byCategory['groceries'], 150000);
    expect(s.byCategory['uncategorized'], 20000);
    expect(s.uncategorizedCount, 1);
    expect(s.savingsRate, closeTo(0.966, 0.001));
  });

  test('refund nets against category and spend', () {
    final agg = InsightsAggregator([
      tx(1000, at: d(2), cat: 'shopping'),
      tx(400, at: d(5), debit: false, cat: 'shopping'),
    ]);
    final s = agg.summarize(jul);
    expect(s.spendPaise, 60000);
    expect(s.incomePaise, 0);
    expect(s.byCategory['shopping'], 60000);
    expect(s.savingsRate, isNull);
  });

  test('self-transfer category is excluded', () {
    final agg = InsightsAggregator([
      tx(9000, at: d(2), cat: 'transfers_self'),
      tx(100, at: d(2), cat: 'fuel'),
    ]);
    final s = agg.summarize(jul);
    expect(s.spendPaise, 10000);
    expect(s.excludedTransferCount, 1);
  });

  group('transfer pairing', () {
    test('pairs bank debit with card credit within window', () {
      final debit = tx(20000, at: d(10), bank: 'HDFC', acct: '1');
      final credit =
          tx(20000, at: d(12), debit: false, bank: 'ICICI', acct: '9');
      final agg = InsightsAggregator([debit, credit]);
      expect(agg.excludedIds, {debit.id, credit.id});
      final s = agg.summarize(jul);
      expect(s.spendPaise, 0);
      expect(s.incomePaise, 0);
    });

    test('same account, different amount, or outside window do not pair', () {
      final a = tx(500, at: d(10), acct: '1');
      final sameAcct = tx(500, at: d(10), debit: false, acct: '1');
      final other = tx(501, at: d(10), debit: false, bank: 'SBI', acct: '2');
      final late = tx(500, at: d(20), debit: false, bank: 'SBI', acct: '2');
      expect(InsightsAggregator([a, sameAcct, other, late]).excludedIds,
          isEmpty);
    });

    test('user-categorized rows never pair', () {
      final debit = tx(700, at: d(10), cat: 'shopping', source: 'user');
      final credit =
          tx(700, at: d(10), debit: false, bank: 'SBI', acct: '2');
      expect(InsightsAggregator([debit, credit]).excludedIds, isEmpty);
    });

    test('each row pairs once, nearest date wins', () {
      final debit = tx(300, at: d(10), acct: '1');
      final near = tx(300, at: d(11), debit: false, bank: 'SBI', acct: '2');
      final far = tx(300, at: d(13), debit: false, bank: 'SBI', acct: '3');
      final agg = InsightsAggregator([debit, near, far]);
      expect(agg.excludedIds, {debit.id, near.id});
    });

    test('pairs across a month boundary', () {
      final debit = tx(800, at: DateTime(2026, 6, 30, 23), acct: '1');
      final credit = tx(800,
          at: DateTime(2026, 7, 1, 1), debit: false, bank: 'SBI', acct: '2');
      final agg = InsightsAggregator([debit, credit]);
      expect(agg.summarize(jul).incomePaise, 0);
      expect(agg.summarize(MonthKey(2026, 6)).spendPaise, 0);
    });
  });

  test('top merchants group by id, else by raw label; sorted desc', () {
    final agg = InsightsAggregator([
      tx(300, at: d(1), merchant: 'Swiggy', merchantId: 1),
      tx(200, at: d(2), merchant: 'Swiggy', merchantId: 1),
      tx(600, at: d(3), merchant: 'Amazon', merchantId: 2),
      tx(50, at: d(4), debit: false, merchant: 'Swiggy', merchantId: 1),
    ]);
    final top = agg.topMerchants(jul);
    expect(top.map((m) => m.label), ['Amazon', 'Swiggy']);
    expect(top[1].spendPaise, 50000);
    expect(top[1].count, 2);
    expect(agg.topMerchants(jul, limit: 1), hasLength(1));
  });

  test('trend fills empty months and orders oldest first', () {
    final agg = InsightsAggregator([
      tx(100, at: d(5, 5), cat: 'fuel'),
      tx(200, at: d(5), cat: 'fuel'),
    ]);
    final t = agg.trend(jul, months: 3);
    expect(t.map((s) => s.month.toString()), ['2026-05', '2026-06', '2026-07']);
    expect(t.map((s) => s.spendPaise), [10000, 0, 20000]);
  });

  test('daily and weekday spend', () {
    // 2026-07-06 is a Monday.
    final agg = InsightsAggregator([
      tx(100, at: d(6)),
      tx(50, at: d(6)),
      tx(70, at: d(12)),
    ]);
    final daily = agg.dailySpend(jul);
    expect(daily, hasLength(31));
    expect(daily[5], 15000);
    final wd = agg.weekdaySpend(jul);
    expect(wd[0], 15000);
    expect(wd[6], 7000); // 12 Jul is Sunday
  });

  test('month-over-month and category deltas', () {
    final agg = InsightsAggregator([
      tx(1000, at: d(5, 6), cat: 'fuel'),
      tx(500, at: d(5, 6), cat: 'rent'),
      tx(1500, at: d(5), cat: 'fuel'),
      tx(200, at: d(6), cat: 'rent'),
    ]);
    final mom = agg.monthOverMonth(jul);
    expect(mom.spend.previous, 150000);
    expect(mom.spend.current, 170000);
    expect(mom.spend.pct, closeTo(0.133, 0.001));
    expect(mom.income.pct, isNull);
    final deltas = agg.categoryDeltas(jul);
    expect(deltas.first.slug, 'fuel');
    expect(deltas.first.delta.diffPaise, 50000);
    expect(deltas.last.slug, 'rent');
  });
}

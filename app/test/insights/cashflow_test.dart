import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(
  int rupees,
  DateTime at, {
  bool debit = true,
  String merchant = 'Shop',
  String bank = 'HDFC',
  String? acct = '1',
  int? balance,
  String? cat,
}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: debit,
      bookedAt: at,
      bankCode: bank,
      accountHint: acct,
      categorySlug: cat,
      merchantName: merchant,
      rawMerchant: merchant,
      balanceAfterPaise: balance == null ? null : balance * 100,
    );

void main() {
  group('BalanceSeries', () {
    DateTime aug(int d, [int h = 12]) => DateTime(2026, 8, d, h);

    List<InsightTxn> data() => [
          // Account A
          tx(1, aug(1), balance: 10000),
          tx(1, aug(3, 9), balance: 11000),
          tx(1, aug(3, 18), balance: 12000), // day's closing
          tx(1, aug(5), balance: 9000),
          // Account B
          tx(1, aug(2), bank: 'SBI', acct: '2', balance: 5000),
          tx(1, aug(4), bank: 'SBI', acct: '2', balance: 6000),
          tx(1, aug(6), bank: 'SBI', acct: '2', balance: 7000),
          // Too sparse: ignored
          tx(1, aug(2), bank: 'ICICI', acct: '3', balance: 99999),
          tx(1, aug(4), bank: 'ICICI', acct: '3', balance: 99999),
          // No balance at all
          tx(1, aug(2), bank: 'AXIS', acct: '4'),
        ];

    test('sums per-account closing balances with carry-forward', () {
      final s = BalanceSeries.build(data(),
          from: aug(1), to: aug(6));
      expect(s.map((p) => p.day.day), [1, 2, 3, 4, 5, 6]);
      expect(s.map((p) => p.paise ~/ 100),
          [10000, 15000, 17000, 18000, 15000, 16000]);
    });

    test('carries balances from before the window', () {
      final s = BalanceSeries.build(data(), from: aug(3), to: aug(4));
      expect(s.map((p) => p.paise ~/ 100), [17000, 18000]);
    });

    test('empty when no account has enough points', () {
      expect(
        BalanceSeries.build([tx(1, aug(1), balance: 5)],
            from: aug(1), to: aug(2)),
        isEmpty,
      );
    });
  });

  group('CashflowForecaster', () {
    const forecaster = CashflowForecaster();
    final sep = MonthKey(2026, 9);

    List<InsightTxn> mid() => [
          for (final m in [7, 8, 9])
            tx(649, DateTime(2026, m, 5, 10), merchant: 'Netflix'),
          for (final m in [6, 7, 8])
            tx(1500, DateTime(2026, m, 25, 10), merchant: 'Gym Fit'),
          tx(1000, DateTime(2026, 9, 2, 10), merchant: 'Grocer'),
          tx(1500, DateTime(2026, 9, 9, 10), merchant: 'Grocer'),
          tx(1500, DateTime(2026, 9, 16, 10), merchant: 'Grocer'),
        ];

    test('projects spend so far + recurring due + daily rate', () {
      final txns = mid();
      final agg = InsightsAggregator(txns);
      final now = DateTime(2026, 9, 20, 12);
      final rec = const RecurringDetector().detect(
        agg.counted.where((t) => t.isDebit).toList(),
        asOf: now,
      );
      expect(rec.map((r) => r.label).toSet(), {'Netflix', 'Gym Fit'});

      final f = forecaster.forecast(agg, sep, rec,
          asOf: now, currentBalancePaise: 5000000)!;
      expect(f.spentSoFarPaise, 464900);
      expect(f.variableDailyPaise, 20000); // ₹4,000 / 20 days
      expect(f.daysRemaining, 10);
      expect(f.remainingVariablePaise, 200000);
      expect(f.upcoming, hasLength(1));
      expect(f.upcoming.single.label, 'Gym Fit');
      expect(f.upcoming.single.date, DateTime(2026, 9, 24));
      expect(f.projectedSpendPaise, 464900 + 150000 + 200000);
      expect(f.projectedBalancePaise, 5000000 - 350000);
    });

    test('null unless asOf is inside the month', () {
      final agg = InsightsAggregator(mid());
      expect(
        forecaster.forecast(agg, MonthKey(2026, 8), const [],
            asOf: DateTime(2026, 9, 20)),
        isNull,
      );
    });

    test('early in the month uses the trailing daily rate', () {
      final agg = InsightsAggregator([
        tx(3100, DateTime(2026, 7, 10), merchant: 'Grocer'),
        tx(3100, DateTime(2026, 8, 10), merchant: 'Grocer'),
      ]);
      final f = forecaster.forecast(agg, sep, const [],
          asOf: DateTime(2026, 9, 3, 9))!;
      expect(f.variableDailyPaise, 10000);
      expect(f.daysRemaining, 27);
      expect(f.projectedSpendPaise, 270000);
      expect(f.projectedBalancePaise, isNull);
    });

    test('weekly series can be due more than once', () {
      final now = DateTime(2026, 9, 10);
      final series = RecurringSeries(
        key: 'k',
        label: 'Milk',
        merchantId: null,
        cadence: Cadence.weekly,
        kind: 'subscription',
        lastAmountPaise: 6000,
        lastSeen: DateTime(2026, 9, 8),
        nextExpected: DateTime(2026, 9, 15),
        occurrences: 5,
        txnIds: const [],
        confidence: 1,
        active: true,
      );
      final f = forecaster.forecast(
          InsightsAggregator(const []), sep, [series], asOf: now)!;
      expect(f.upcoming.map((u) => u.date.day), [15, 22, 29]);
    });
  });

  test('snapshot: category increases, forecast only for current month', () {
    final agg = InsightsAggregator([
      tx(1000, DateTime(2026, 8, 5), cat: 'fuel'),
      tx(2000, DateTime(2026, 9, 5), cat: 'fuel'),
      tx(900, DateTime(2026, 9, 6), cat: 'rent'), // no prior → excluded
      tx(100, DateTime(2026, 8, 5), cat: 'food_delivery'),
      tx(300, DateTime(2026, 9, 5), cat: 'food_delivery'), // +₹200 < ₹500
    ]);
    final snap = InsightsSnapshot.build(
      agg,
      MonthKey(2026, 9),
      const {'fuel': 'Fuel'},
      now: DateTime(2026, 9, 20),
    );
    expect(snap.changes.map((c) => c.name), ['Fuel']);
    expect(snap.forecast, isNotNull);

    final past = InsightsSnapshot.build(
      agg,
      MonthKey(2026, 8),
      const {},
      now: DateTime(2026, 9, 20),
    );
    expect(past.forecast, isNull);
  });
}

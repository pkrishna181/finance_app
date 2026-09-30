import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatting', () {
    test('inrWhole uses Indian grouping without paise', () {
      expect(inrWhole(12500000), '₹1,25,000');
      expect(inrWhole(99), '₹0');
      expect(inrWhole(-150000), '-₹1,500');
    });

    test('inrCompact', () {
      expect(inrCompact(95000), '₹950');
      expect(inrCompact(1250000), '₹12.5k');
      expect(inrCompact(15000000), '₹1.5L');
      expect(inrCompact(100000000), '₹10L');
      expect(inrCompact(20000000000), '₹20Cr');
    });
  });

  group('buildSlices', () {
    const names = {'groceries': 'Groceries', 'fuel': 'Fuel'};

    test('sorts desc, fractions sum to 1, unknown slug falls back', () {
      final s = InsightsSnapshot.buildSlices(
        {'fuel': 300, 'groceries': 700, 'mystery': 0},
        names,
      );
      expect(s.map((e) => e.name), ['Groceries', 'Fuel']);
      expect(s.first.fraction, closeTo(0.7, 1e-9));
    });

    test('folds tail into Other when over maxSlices', () {
      final s = InsightsSnapshot.buildSlices(
        {'a': 500, 'b': 400, 'c': 300, 'd': 200, 'uncategorized': 100},
        const {},
        maxSlices: 3,
      );
      expect(s.map((e) => e.slug), ['a', 'b', kOtherSliceSlug]);
      expect(s.last.paise, 600);
      expect(s.last.isOther, isTrue);
    });

    test('names uncategorized and handles empty', () {
      final s = InsightsSnapshot.buildSlices({'uncategorized': 10}, const {});
      expect(s.single.name, 'Uncategorized');
      expect(InsightsSnapshot.buildSlices(const {}, const {}), isEmpty);
    });
  });

  test('build wires summary, trend, merchants, slices', () {
    var id = 0;
    InsightTxn t(int rupees, DateTime at, {String? cat, String? m}) =>
        InsightTxn(
          id: ++id,
          amountPaise: rupees * 100,
          isDebit: true,
          bookedAt: at,
          bankCode: 'HDFC',
          categorySlug: cat,
          merchantName: m,
          rawMerchant: m ?? 'x',
        );
    final agg = InsightsAggregator([
      t(100, DateTime(2026, 6, 5), cat: 'fuel'),
      t(300, DateTime(2026, 7, 5), cat: 'fuel', m: 'HP'),
    ]);
    final snap = InsightsSnapshot.build(
        agg, MonthKey(2026, 7), const {'fuel': 'Fuel'});
    expect(snap.isEmpty, isFalse);
    expect(snap.summary.spendPaise, 30000);
    expect(snap.spendDelta.pct, closeTo(2.0, 1e-9));
    expect(snap.trend, hasLength(6));
    expect(snap.slices.single.name, 'Fuel');
    expect(snap.merchants.single.label, 'HP');
    expect(agg.transactionsIn(MonthKey(2026, 7), categorySlug: 'fuel'),
        hasLength(1));
    expect(agg.transactionsIn(MonthKey(2026, 7), categorySlug: 'rent'),
        isEmpty);
  });

  test('monthly commitment sums active recurring only', () {
    RecurringSeries series(int paise, bool active) => RecurringSeries(
          key: 'k$paise',
          label: 'x',
          merchantId: null,
          cadence: Cadence.monthly,
          kind: 'subscription',
          lastAmountPaise: paise,
          lastSeen: DateTime(2026, 7, 1),
          nextExpected: DateTime(2026, 7, 31),
          occurrences: 3,
          txnIds: const [],
          confidence: 1,
          active: active,
        );
    final snap = InsightsSnapshot.build(
      InsightsAggregator(const []),
      MonthKey(2026, 7),
      const {},
      recurring: [series(10000, true), series(5000, true), series(9999, false)],
    );
    expect(snap.monthlyCommitmentPaise, 15000);
    expect(snap.activeRecurring, hasLength(2));
  });
}

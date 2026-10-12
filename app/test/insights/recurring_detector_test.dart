import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(
  String merchant,
  int rupees,
  DateTime at, {
  int? merchantId,
  String? cat,
  String type = 'upi',
}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: true,
      bookedAt: at,
      bankCode: 'HDFC',
      txnType: type,
      categorySlug: cat,
      merchantId: merchantId,
      merchantName: merchant,
      rawMerchant: merchant,
    );

void main() {
  const detector = RecurringDetector();
  final asOf = DateTime(2026, 9, 15);

  List<InsightTxn> monthly(String m, int rupees, List<int> months,
          {int day = 5, String? cat, String type = 'upi'}) =>
      [
        for (final mo in months)
          tx(m, rupees, DateTime(2026, mo, day, 10), cat: cat, type: type),
      ];

  test('detects a clean monthly subscription', () {
    final s = detector.detect(monthly('Netflix', 649, [5, 6, 7, 8, 9]),
        asOf: asOf);
    expect(s, hasLength(1));
    expect(s.single.cadence, Cadence.monthly);
    expect(s.single.kind, 'subscription');
    expect(s.single.occurrences, 5);
    expect(s.single.active, isTrue);
    expect(s.single.confidence, 1.0);
    expect(s.single.monthlyEquivalentPaise, 64900);
    expect(s.single.nextExpected, DateTime(2026, 10, 5));
    expect(s.single.priceChange, isNull);
  });

  test('needs at least three monthly charges', () {
    expect(detector.detect(monthly('Netflix', 649, [8, 9]), asOf: asOf),
        isEmpty);
  });

  test('tolerates one missed month', () {
    final s = detector.detect(monthly('Spotify', 119, [3, 4, 6, 7, 8]),
        asOf: asOf);
    expect(s.single.cadence, Cadence.monthly);
    expect(s.single.confidence, 1.0);
  });

  test('flags a price increase', () {
    final txns = [
      ...monthly('Netflix', 499, [5, 6, 7]),
      ...monthly('Netflix', 649, [8, 9]),
    ];
    final s = detector.detect(txns, asOf: asOf).single;
    expect(s.priceChange, isNotNull);
    expect(s.priceChange!.isIncrease, isTrue);
    expect(s.priceChange!.fromPaise, 49900);
    expect(s.lastAmountPaise, 64900);
  });

  test('variable spend at the same merchant is not recurring', () {
    final txns = [
      tx('BigBasket', 820, DateTime(2026, 6, 5)),
      tx('BigBasket', 1430, DateTime(2026, 7, 5)),
      tx('BigBasket', 290, DateTime(2026, 8, 5)),
      tx('BigBasket', 2100, DateTime(2026, 9, 5)),
    ];
    expect(detector.detect(txns, asOf: asOf), isEmpty);
  });

  test('irregular intervals are not recurring', () {
    final txns = [
      tx('Cafe', 200, DateTime(2026, 8, 1)),
      tx('Cafe', 200, DateTime(2026, 8, 3)),
      tx('Cafe', 200, DateTime(2026, 8, 20)),
      tx('Cafe', 200, DateTime(2026, 9, 9)),
    ];
    expect(detector.detect(txns, asOf: asOf), isEmpty);
  });

  test('weekly needs four charges', () {
    final base = DateTime(2026, 9, 1);
    List<InsightTxn> weeks(int n) => [
          for (var i = 0; i < n; i++)
            tx('Milk Sub', 60, base.add(Duration(days: 7 * i))),
        ];
    expect(detector.detect(weeks(3), asOf: asOf), isEmpty);
    expect(detector.detect(weeks(4), asOf: asOf).single.cadence,
        Cadence.weekly);
  });

  test('quarterly and annual cadences', () {
    final q = [
      tx('Insurance', 3000, DateTime(2026, 1, 10)),
      tx('Insurance', 3000, DateTime(2026, 4, 10)),
      tx('Insurance', 3000, DateTime(2026, 7, 10)),
    ];
    final s = detector.detect(q, asOf: asOf).single;
    expect(s.cadence, Cadence.quarterly);
    expect(s.monthlyEquivalentPaise, 100000);

    final a = [
      tx('Domain', 1200, DateTime(2025, 9, 1)),
      tx('Domain', 1200, DateTime(2026, 9, 1)),
    ];
    expect(detector.detect(a, asOf: asOf).single.cadence, Cadence.annual);
  });

  test('lapsed series is inactive and sorted after active ones', () {
    final txns = [
      ...monthly('OldGym', 1500, [1, 2, 3]),
      ...monthly('Netflix', 649, [7, 8, 9]),
    ];
    final s = detector.detect(txns, asOf: asOf);
    expect(s.map((e) => e.label), ['Netflix', 'OldGym']);
    expect(s.last.active, isFalse);
  });

  test('kind: SIP by category, eNACH by txn type or EMI category', () {
    final sip = detector.detect(
        monthly('Groww', 5000, [7, 8, 9], cat: 'investments_sip'),
        asOf: asOf);
    expect(sip.single.kind, 'sip');
    final emi = detector.detect(
        monthly('HDFC Loan', 12000, [7, 8, 9], type: 'enach'),
        asOf: asOf);
    expect(emi.single.kind, 'enach');
    final emiCat =
        detector.detect(monthly('Bajaj', 4000, [7, 8, 9], cat: 'emi'),
            asOf: asOf);
    expect(emiCat.single.kind, 'enach');
  });

  test('groups by merchantId across differing raw text', () {
    final txns = [
      tx('NETFLIX.COM', 649, DateTime(2026, 7, 5), merchantId: 7),
      tx('Netflix India', 649, DateTime(2026, 8, 5), merchantId: 7),
      tx('NETFLIX', 649, DateTime(2026, 9, 5), merchantId: 7),
    ];
    expect(detector.detect(txns, asOf: asOf).single.occurrences, 3);
  });

  test('raw-label grouping ignores digits and short labels', () {
    expect(RecurringDetector.normalizeLabel('NETFLIX 4432 *IN'), 'netflix in');
    final txns = [
      tx('A1', 100, DateTime(2026, 7, 5)),
      tx('A1', 100, DateTime(2026, 8, 5)),
      tx('A1', 100, DateTime(2026, 9, 5)),
    ];
    expect(detector.detect(txns, asOf: asOf), isEmpty);
  });

  test('credits are ignored', () {
    final credits = [
      for (final m in [7, 8, 9])
        InsightTxn(
          id: ++_id,
          amountPaise: 100000,
          isDebit: false,
          bookedAt: DateTime(2026, m, 1),
          bankCode: 'HDFC',
          rawMerchant: 'Employer',
        ),
    ];
    expect(detector.detect(credits, asOf: asOf), isEmpty);
  });

  group('mandate matching', () {
    final series = detector.detect(
        monthly('Netflix India', 649, [7, 8, 9]),
        asOf: asOf);

    test('attaches the earliest upcoming matching notice', () {
      final out = RecurringDetector.matchMandates(
        series,
        [
          MandateHint(
              merchant: 'NETFLIX',
              amountPaise: 64900,
              scheduledDate: DateTime(2026, 10, 7)),
          MandateHint(
              merchant: 'NETFLIX',
              amountPaise: 64900,
              scheduledDate: DateTime(2026, 9, 20)),
          MandateHint(
              merchant: 'NETFLIX',
              amountPaise: 64900,
              scheduledDate: DateTime(2026, 9, 1)), // past
          MandateHint(
              merchant: 'Other',
              amountPaise: 64900,
              scheduledDate: DateTime(2026, 9, 16)),
        ],
        asOf: asOf,
      );
      expect(out.single.mandateDate, DateTime(2026, 9, 20));
    });

    test('rejects amount mismatch', () {
      final out = RecurringDetector.matchMandates(
        series,
        [
          MandateHint(
              merchant: 'Netflix',
              amountPaise: 200000,
              scheduledDate: DateTime(2026, 9, 20)),
        ],
        asOf: asOf,
      );
      expect(out.single.mandateDate, isNull);
    });
  });
}

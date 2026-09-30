import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(
  int rupees,
  DateTime at, {
  String? cat,
  String merchant = 'Shop',
}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: true,
      bookedAt: at,
      bankCode: 'HDFC',
      categorySlug: cat,
      merchantName: merchant,
      rawMerchant: merchant,
    );

const detector = AnomalyDetector();
final sep = MonthKey(2026, 9);
const names = {'fuel': 'Fuel'};

List<Anomaly> run(List<InsightTxn> txns, {Set<String> dismissed = const {}}) =>
    detector.detect(InsightsAggregator(txns), sep,
        categoryNames: names, dismissed: dismissed);

/// One txn on the 5th of each of the six months before September.
List<InsightTxn> history(List<int> rupees,
        {String? cat = 'fuel', String merchant = 'Shop'}) =>
    [
      for (var i = 0; i < rupees.length; i++)
        tx(rupees[i], DateTime(2026, 3 + i, 5, 10),
            cat: cat, merchant: merchant),
    ];

Iterable<Anomaly> ofKind(List<Anomaly> a, AnomalyKind k) =>
    a.where((x) => x.kind == k);

void main() {
  test('steady spending raises nothing', () {
    final txns = [
      ...history([3000, 3000, 3000, 3000, 3000, 3000]),
      tx(3050, DateTime(2026, 9, 5), cat: 'fuel'),
    ];
    expect(run(txns), isEmpty);
  });

  test('category spike is flagged with readable text', () {
    final txns = [
      ...history([2900, 3100, 3000, 3000, 2950, 3050]),
      tx(9000, DateTime(2026, 9, 5), cat: 'fuel'),
    ];
    final spikes = ofKind(run(txns), AnomalyKind.categorySpike).toList();
    expect(spikes, hasLength(1));
    expect(spikes.single.title, 'Fuel spending is up');
    expect(spikes.single.detail, contains('₹9,000'));
    expect(spikes.single.key, 'cat:fuel:2026-09');
  });

  test('spike needs 3 prior months of data', () {
    final txns = [
      tx(3000, DateTime(2026, 7, 5), cat: 'fuel'),
      tx(3000, DateTime(2026, 8, 5), cat: 'fuel'),
      tx(9000, DateTime(2026, 9, 5), cat: 'fuel'),
    ];
    expect(ofKind(run(txns), AnomalyKind.categorySpike), isEmpty);
  });

  test('small absolute increase is not a spike', () {
    final txns = [
      ...history([100, 100, 100, 100, 100, 100]),
      tx(500, DateTime(2026, 9, 5), cat: 'fuel'), // +₹400 < ₹1,000
    ];
    expect(ofKind(run(txns), AnomalyKind.categorySpike), isEmpty);
  });

  test('large transaction vs category history', () {
    // Several small charges per month so the category total stays modest.
    final small = [
      for (var m = 3; m <= 8; m++)
        for (var d = 1; d <= 3; d++)
          tx(500, DateTime(2026, m, d * 5), cat: 'fuel'),
    ];
    final txns = [...small, tx(5000, DateTime(2026, 9, 10), cat: 'fuel')];
    final large = ofKind(run(txns), AnomalyKind.largeTransaction).toList();
    expect(large, hasLength(1));
    expect(large.single.detail, contains('typical is ₹500'));
  });

  test('duplicate charge within 24h; tiny amounts ignored', () {
    final txns = [
      tx(450, DateTime(2026, 9, 3, 10), merchant: 'Zomato'),
      tx(450, DateTime(2026, 9, 3, 11), merchant: 'Zomato'),
      tx(50, DateTime(2026, 9, 4, 10), merchant: 'Tea'),
      tx(50, DateTime(2026, 9, 4, 11), merchant: 'Tea'),
      tx(450, DateTime(2026, 9, 9, 11), merchant: 'Zomato'), // days later
    ];
    final a = run(txns);
    expect(a, hasLength(1));
    expect(a.single.kind, AnomalyKind.duplicateCharge);
    expect(a.single.title, contains('Zomato'));
  });

  test('new high-value payee needs history and a big amount', () {
    final hist = [
      for (var i = 1; i <= 24; i++)
        tx(i * 100, DateTime(2026, 3 + (i % 6), 2 + (i % 20)), merchant: 'Shop'),
    ];
    final a = run([...hist, tx(60000, DateTime(2026, 9, 12), merchant: 'Jeweller')]);
    expect(a, hasLength(1));
    expect(a.single.kind, AnomalyKind.newMerchant);
    expect(a.single.detail, contains('₹60,000'));

    // Sparse history → no new-payee flag.
    final sparse = run([
      tx(200, DateTime(2026, 8, 2)),
      tx(60000, DateTime(2026, 9, 12), merchant: 'Jeweller'),
    ]);
    expect(ofKind(sparse, AnomalyKind.newMerchant), isEmpty);

    // Known payee is not "new".
    final known = run([...hist, tx(60000, DateTime(2026, 9, 12), merchant: 'Shop')]);
    expect(ofKind(known, AnomalyKind.newMerchant), isEmpty);
  });

  test('one flag per transaction: duplicate beats large', () {
    final small = [
      for (var m = 3; m <= 8; m++)
        for (var d = 1; d <= 3; d++)
          tx(500, DateTime(2026, m, d * 5), cat: 'fuel'),
    ];
    final txns = [
      ...small,
      tx(5000, DateTime(2026, 9, 10, 9), cat: 'fuel', merchant: 'Pump'),
      tx(5000, DateTime(2026, 9, 10, 10), cat: 'fuel', merchant: 'Pump'),
    ];
    final a = run(txns);
    final perTxn = a.where((x) => x.txnId != null).map((x) => x.txnId).toList();
    expect(perTxn.toSet().length, perTxn.length);
    expect(ofKind(a, AnomalyKind.duplicateCharge), hasLength(1));
  });

  test('dismissed keys are hidden', () {
    final txns = [
      tx(450, DateTime(2026, 9, 3, 10), merchant: 'Zomato'),
      tx(450, DateTime(2026, 9, 3, 11), merchant: 'Zomato'),
    ];
    final a = run(txns);
    expect(a, hasLength(1));
    expect(run(txns, dismissed: {a.single.key}), isEmpty);
  });

  test('results are ranked by impact and capped', () {
    final txns = [
      for (var i = 0; i < 8; i++) ...[
        tx(1000 + i * 100, DateTime(2026, 9, 1 + i, 9), merchant: 'M$i'),
        tx(1000 + i * 100, DateTime(2026, 9, 1 + i, 10), merchant: 'M$i'),
      ],
    ];
    final a = detector.detect(InsightsAggregator(txns), sep, limit: 5);
    expect(a, hasLength(5));
    final impacts = a.map((x) => x.impactPaise).toList();
    expect(impacts, [...impacts]..sort((x, y) => y.compareTo(x)));
  });
}

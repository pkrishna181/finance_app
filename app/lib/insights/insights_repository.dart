import 'package:drift/drift.dart' show Variable;

import '../core/db/database.dart';
import 'insight_models.dart';
import 'insights_aggregator.dart';
import 'recurring_detector.dart';

/// Loads slim transaction projections from the encrypted DB.
class InsightsRepository {
  InsightsRepository(this._db);

  final ArthDatabase _db;

  /// Rows booked in `[from, to)`. Callers that need transfer pairing across a
  /// period edge should pad the range by a few days (see [aggregatorFor]).
  Future<List<InsightTxn>> loadRange(DateTime from, DateTime to) async {
    final rows = await _db.customSelect(
      '''
SELECT t.id AS id,
       t.amount_paise AS amount_paise,
       t.direction AS direction,
       t.booked_at AS booked_at,
       t.bank_code AS bank_code,
       t.account_hint AS account_hint,
       t.txn_type AS txn_type,
       t.category_source AS category_source,
       t.merchant_id AS merchant_id,
       t.raw_merchant AS raw_merchant,
       c.slug AS category_slug,
       m.canonical_name AS merchant_name
FROM transactions t
LEFT JOIN categories c ON c.id = t.category_id
LEFT JOIN merchants m ON m.id = t.merchant_id
WHERE t.booked_at >= ? AND t.booked_at < ?
ORDER BY t.booked_at ASC, t.id ASC
''',
      variables: [
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ],
      readsFrom: {_db.transactions, _db.categories, _db.merchants},
    ).get();

    return [
      for (final r in rows)
        InsightTxn(
          id: r.read<int>('id'),
          amountPaise: r.read<int>('amount_paise'),
          isDebit: r.read<String>('direction') == 'debit',
          bookedAt: r.read<DateTime>('booked_at'),
          bankCode: r.read<String>('bank_code'),
          accountHint: r.readNullable<String>('account_hint'),
          txnType: r.read<String>('txn_type'),
          categorySlug: r.readNullable<String>('category_slug'),
          categorySource: r.readNullable<String>('category_source'),
          merchantId: r.readNullable<int>('merchant_id'),
          merchantName: r.readNullable<String>('merchant_name'),
          rawMerchant: r.read<String>('raw_merchant'),
        ),
    ];
  }

  /// Aggregator covering [months] months ending at [end], padded by a week on
  /// each side so transfers straddling a month boundary still pair up.
  Future<InsightsAggregator> aggregatorFor(
    MonthKey end, {
    int months = 7,
  }) async {
    final from = end.plusMonths(-(months - 1)).start
        .subtract(const Duration(days: 7));
    final to = end.endExclusive.add(const Duration(days: 7));
    return InsightsAggregator(await loadRange(from, to));
  }

  /// slug → display name.
  Future<Map<String, String>> categoryNames() async {
    final rows = await _db.select(_db.categories).get();
    return {for (final c in rows) c.slug: c.name};
  }

  /// Months that contain at least one transaction, newest first.
  Future<List<MonthKey>> availableMonths() async {
    final rows = await _db.customSelect(
      "SELECT DISTINCT strftime('%Y-%m', booked_at, 'unixepoch', 'localtime') "
      'AS ym FROM transactions',
      readsFrom: {_db.transactions},
    ).get();
    final out = <MonthKey>[
      for (final r in rows)
        if (r.readNullable<String>('ym') case final ym?)
          MonthKey(int.parse(ym.substring(0, 4)), int.parse(ym.substring(5))),
    ]..sort((a, b) => b.compareTo(a));
    return out;
  }

  /// Detects recurring debits over the 13 months before [asOf], attaches
  /// upcoming mandate dates, and flags the underlying rows
  /// (`is_recurring_candidate`, and `recurring_kind` when still unset).
  Future<List<RecurringSeries>> loadRecurring({
    required DateTime asOf,
    bool persist = true,
  }) async {
    final from = DateTime(asOf.year, asOf.month - 13, asOf.day);
    final to = DateTime(asOf.year, asOf.month, asOf.day + 1);
    final txns = await loadRange(from, to);
    final agg = InsightsAggregator(txns);
    final counted = [
      for (final t in txns)
        if (t.isDebit && !agg.excludedIds.contains(t.id)) t,
    ];
    final found = const RecurringDetector().detect(counted, asOf: asOf);
    if (persist) await _persistRecurring(found);

    final notices = await _db.select(_db.mandateNotices).get();
    return RecurringDetector.matchMandates(
      found,
      [
        for (final n in notices)
          MandateHint(
            merchant: n.merchant,
            amountPaise: n.amountPaise,
            scheduledDate: n.scheduledDate,
          ),
      ],
      asOf: asOf,
    );
  }

  Future<void> _persistRecurring(List<RecurringSeries> series) async {
    for (final s in series) {
      for (var i = 0; i < s.txnIds.length; i += 500) {
        final chunk = s.txnIds.sublist(
          i,
          i + 500 > s.txnIds.length ? s.txnIds.length : i + 500,
        );
        final marks = List.filled(chunk.length, '?').join(',');
        await _db.customUpdate(
          'UPDATE transactions SET is_recurring_candidate = 1, '
          'recurring_kind = COALESCE(recurring_kind, ?) '
          'WHERE id IN ($marks)',
          variables: [
            Variable<String>(s.kind),
            for (final id in chunk) Variable<int>(id),
          ],
          updates: {_db.transactions},
        );
      }
    }
  }
}

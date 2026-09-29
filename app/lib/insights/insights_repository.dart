import 'package:drift/drift.dart' show Variable;

import '../core/db/database.dart';
import 'insight_models.dart';
import 'insights_aggregator.dart';

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
}

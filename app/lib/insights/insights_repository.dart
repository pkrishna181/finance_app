import 'package:drift/drift.dart' show OrderingTerm, QueryRow, Value, Variable;

import '../core/db/database.dart';
import 'insight_models.dart';
import 'anomaly_detector.dart';
import 'insights_aggregator.dart';
import 'recurring_detector.dart';
import 'yearly.dart';

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
       t.balance_after_paise AS balance_after_paise,
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
          balanceAfterPaise: r.readNullable<int>('balance_after_paise'),
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

  /// Aggregator over financial year [fy], padded a week each side so
  /// transfers straddling the year edge still pair up.
  Future<InsightsAggregator> yearAggregator(FinancialYear fy) async {
    return InsightsAggregator(await loadRange(
      fy.start.subtract(const Duration(days: 7)),
      fy.endExclusive.add(const Duration(days: 7)),
    ));
  }

  /// Financial years containing at least one transaction, newest first.
  Future<List<FinancialYear>> availableYears() async {
    final years = {
      for (final m in await availableMonths()) FinancialYear.ofMonth(m),
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
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

  /// Keys of anomalies the user has dismissed.
  Future<Set<String>> dismissedAnomalyKeys() async {
    final rows = await (_db.select(_db.userCorrections)
          ..where((t) => t.field.equals(kAnomalyDismissedField)))
        .get();
    return {for (final r in rows) r.newValue};
  }

  Future<void> dismissAnomaly(Anomaly a) async {
    await _db.into(_db.userCorrections).insert(
          UserCorrectionsCompanion.insert(
            transactionId: Value(a.txnId),
            rawMerchant: a.title,
            field: kAnomalyDismissedField,
            newValue: a.key,
          ),
        );
  }

  /// Categories in display order, for the recategorize picker.
  Future<List<Category>> pickableCategories() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// Other rows from the same merchant as [t] (same `merchant_id`, else same
  /// normalized raw label) that the user has not categorized by hand.
  Future<List<int>> similarTransactionIds(InsightTxn t) async {
    final List<QueryRow> rows;
    if (t.merchantId != null) {
      rows = await _db.customSelect(
        'SELECT id, raw_merchant, category_source FROM transactions '
        'WHERE merchant_id = ? AND id <> ?',
        variables: [Variable<int>(t.merchantId!), Variable<int>(t.id)],
        readsFrom: {_db.transactions},
      ).get();
    } else {
      rows = await _db.customSelect(
        'SELECT id, raw_merchant, category_source FROM transactions '
        'WHERE merchant_id IS NULL AND id <> ?',
        variables: [Variable<int>(t.id)],
        readsFrom: {_db.transactions},
      ).get();
    }
    final key = RecurringDetector.normalizeLabel(t.rawMerchant);
    if (t.merchantId == null && key.length < 3) return const [];
    return [
      for (final r in rows)
        if (!_isUserSource(r.readNullable<String>('category_source')) &&
            (t.merchantId != null ||
                RecurringDetector.normalizeLabel(
                      r.read<String>('raw_merchant'),
                    ) ==
                    key))
          r.read<int>('id'),
    ];
  }

  /// Sets [t]'s category to [slug] (`category_source = 'user'`) and records a
  /// `user_corrections` row. With [applyToMerchant], also recategorizes
  /// [similarTransactionIds] and stores a merchant-wide rule (correction with
  /// no transaction id) that `CategoryRuleEngine` applies to future rows.
  /// Returns the number of transactions changed.
  Future<int> recategorize(
    InsightTxn t,
    String slug, {
    bool applyToMerchant = false,
  }) async {
    final cat = await _db.categoryBySlug(slug);
    if (cat == null) throw ArgumentError.value(slug, 'slug', 'unknown category');
    final similar =
        applyToMerchant ? await similarTransactionIds(t) : const <int>[];
    final ids = [t.id, ...similar];
    await _db.transaction(() async {
      for (var i = 0; i < ids.length; i += 500) {
        final chunk =
            ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
        final marks = List.filled(chunk.length, '?').join(',');
        await _db.customUpdate(
          'UPDATE transactions SET category_id = ?, '
          "category_source = 'user', suggested_category_slug = ?, "
          'updated_at = ? WHERE id IN ($marks)',
          variables: [
            Variable<int>(cat.id),
            Variable<String>(slug),
            Variable<DateTime>(DateTime.now()),
            for (final id in chunk) Variable<int>(id),
          ],
          updates: {_db.transactions},
        );
      }
      await _db.into(_db.userCorrections).insert(
            UserCorrectionsCompanion.insert(
              transactionId: Value(t.id),
              rawMerchant: t.rawMerchant,
              field: 'category',
              oldValue: Value(t.categorySlug),
              newValue: slug,
            ),
          );
      if (applyToMerchant) {
        await _db.into(_db.userCorrections).insert(
              UserCorrectionsCompanion.insert(
                rawMerchant: t.rawMerchant,
                field: 'category',
                oldValue: Value(t.categorySlug),
                newValue: slug,
              ),
            );
        if (t.merchantId != null) {
          await (_db.update(_db.merchants)
                ..where((m) => m.id.equals(t.merchantId!)))
              .write(
            MerchantsCompanion(
              defaultCategoryId: Value(cat.id),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    });
    return ids.length;
  }

  static bool _isUserSource(String? s) => s == 'user' || s == 'user_correction';
}

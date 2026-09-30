import 'insight_models.dart';
import 'transfer_pairing.dart';

/// Pure, deterministic aggregation over a list of [InsightTxn].
///
/// Rules:
/// - Transfers (see [TransferPairing]) are excluded from everything.
/// - Debits are spend. Credits in [kIncomeSlugs] (or uncategorized) are
///   income. Other categorized credits are refunds netting against spend.
/// - Amounts are paise; nothing is rounded or converted here.
class InsightsAggregator {
  InsightsAggregator(
    List<InsightTxn> txns, {
    TransferPairing pairing = const TransferPairing(),
  })  : _excluded = pairing.excludedIds(txns),
        _txns = txns;

  final List<InsightTxn> _txns;
  final Set<int> _excluded;

  Set<int> get excludedIds => _excluded;

  bool _counted(InsightTxn t) => !_excluded.contains(t.id);

  Iterable<InsightTxn> _inMonth(MonthKey m) => _txns.where(
        (t) => _counted(t) && MonthKey.of(t.bookedAt) == m,
      );

  /// Counted (non-transfer) transactions in [month], newest first. With
  /// [categorySlug], only that category (null category = uncategorized).
  List<InsightTxn> transactionsIn(MonthKey month, {String? categorySlug}) {
    final out = _inMonth(month)
        .where((t) =>
            categorySlug == null ||
            (t.categorySlug ?? kUncategorizedSlug) == categorySlug)
        .toList()
      ..sort((a, b) {
        final c = b.bookedAt.compareTo(a.bookedAt);
        return c != 0 ? c : b.id.compareTo(a.id);
      });
    return out;
  }

  MonthSummary summarize(MonthKey month) {
    var income = 0;
    var spend = 0;
    var uncatCount = 0;
    var uncatPaise = 0;
    var count = 0;
    final byCat = <String, int>{};

    for (final t in _inMonth(month)) {
      count++;
      final slug = t.categorySlug ?? kUncategorizedSlug;
      if (t.isDebit) {
        spend += t.amountPaise;
        byCat[slug] = (byCat[slug] ?? 0) + t.amountPaise;
        if (t.isUncategorized) {
          uncatCount++;
          uncatPaise += t.amountPaise;
        }
      } else if (kIncomeSlugs.contains(slug) || t.isUncategorized) {
        income += t.amountPaise;
        if (t.isUncategorized) {
          uncatCount++;
          uncatPaise += t.amountPaise;
        }
      } else {
        // Refund: nets against the category's spend.
        spend -= t.amountPaise;
        byCat[slug] = (byCat[slug] ?? 0) - t.amountPaise;
      }
    }

    byCat.updateAll((_, v) => v < 0 ? 0 : v);
    byCat.removeWhere((_, v) => v == 0);

    return MonthSummary(
      month: month,
      incomePaise: income,
      spendPaise: spend,
      byCategory: byCat,
      uncategorizedCount: uncatCount,
      uncategorizedPaise: uncatPaise,
      txnCount: count,
      excludedTransferCount:
          _txns.where((t) => !_counted(t) && MonthKey.of(t.bookedAt) == month)
              .length,
    );
  }

  /// [months] summaries ending at [end], oldest first (gaps filled with zeros).
  List<MonthSummary> trend(MonthKey end, {int months = 6}) => [
        for (var i = months - 1; i >= 0; i--) summarize(end.plusMonths(-i)),
      ];

  /// Top merchants by net debit spend in [month], largest first.
  List<MerchantTotal> topMerchants(MonthKey month, {int limit = 10}) {
    final totals = <String, _MerchantAcc>{};
    for (final t in _inMonth(month)) {
      if (!t.isDebit) continue;
      final key = t.merchantId != null
          ? 'm${t.merchantId}'
          : 'r${t.merchantLabel.toLowerCase()}';
      final acc = totals.putIfAbsent(
        key,
        () => _MerchantAcc(t.merchantLabel, t.merchantId),
      );
      acc.paise += t.amountPaise;
      acc.count++;
    }
    final list = totals.values
        .map((a) => MerchantTotal(
              label: a.label,
              merchantId: a.id,
              spendPaise: a.paise,
              count: a.count,
            ))
        .toList()
      ..sort((a, b) {
        final c = b.spendPaise.compareTo(a.spendPaise);
        return c != 0 ? c : a.label.compareTo(b.label);
      });
    return list.take(limit).toList();
  }

  /// Debit spend per day-of-month (index 0 = day 1), for the whole month.
  List<int> dailySpend(MonthKey month) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final out = List<int>.filled(days, 0);
    for (final t in _inMonth(month)) {
      if (t.isDebit) out[t.bookedAt.day - 1] += t.amountPaise;
    }
    return out;
  }

  /// Debit spend by weekday (index 0 = Monday … 6 = Sunday).
  List<int> weekdaySpend(MonthKey month) {
    final out = List<int>.filled(7, 0);
    for (final t in _inMonth(month)) {
      if (t.isDebit) out[t.bookedAt.weekday - 1] += t.amountPaise;
    }
    return out;
  }

  /// Month-over-month change per metric.
  ({MonthDelta spend, MonthDelta income}) monthOverMonth(MonthKey month) {
    final cur = summarize(month);
    final prev = summarize(month.plusMonths(-1));
    return (
      spend: MonthDelta(current: cur.spendPaise, previous: prev.spendPaise),
      income: MonthDelta(current: cur.incomePaise, previous: prev.incomePaise),
    );
  }

  /// Per-category change vs previous month, largest increase first.
  List<({String slug, MonthDelta delta})> categoryDeltas(MonthKey month) {
    final cur = summarize(month).byCategory;
    final prev = summarize(month.plusMonths(-1)).byCategory;
    final slugs = {...cur.keys, ...prev.keys};
    final out = [
      for (final s in slugs)
        (
          slug: s,
          delta: MonthDelta(current: cur[s] ?? 0, previous: prev[s] ?? 0),
        ),
    ]..sort((a, b) => b.delta.diffPaise.compareTo(a.delta.diffPaise));
    return out;
  }
}

class _MerchantAcc {
  _MerchantAcc(this.label, this.id);
  final String label;
  final int? id;
  int paise = 0;
  int count = 0;
}

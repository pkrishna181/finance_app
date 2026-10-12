import 'dart:math' as math;

import 'insight_format.dart';
import 'insight_models.dart';
import 'insights_aggregator.dart';
import 'recurring_detector.dart';

/// `user_corrections.field` value for a dismissed anomaly.
const kAnomalyDismissedField = 'anomaly_dismissed';

enum AnomalyKind { categorySpike, largeTransaction, newMerchant, duplicateCharge }

class Anomaly {
  const Anomaly({
    required this.kind,
    required this.key,
    required this.title,
    required this.detail,
    required this.impactPaise,
    this.txnId,
  });

  final AnomalyKind kind;

  /// Stable across reloads; stored when the user dismisses it.
  final String key;
  final String title;
  final String detail;

  /// Ordering weight: how much money the anomaly is "about".
  final int impactPaise;
  final int? txnId;
}

/// Flags unusual spending in one month against the trailing history that the
/// aggregator holds (Repository loads 6 prior months).
///
/// Rules (all thresholds in one place, see constants):
/// - **Category spike**: ≥3 prior months of data, z-score ≥ [spikeZ], spend
///   ≥ [spikeRatio]× the prior mean and ≥ [spikeMinPaise] above it.
/// - **Large transaction**: ≥5 prior debits in the category, amount above
///   mean+[largeSigma]σ, ≥ [largeMedianRatio]× the median, ≥ [largeMinPaise].
/// - **New merchant**: never seen before (with ≥ [newMerchantMinHistory] prior
///   debits overall) and ≥ [newMerchantMinPaise] and ≥ the prior 90th pct.
/// - **Duplicate charge**: same merchant + amount within 24h, ≥ [dupMinPaise].
/// One flag per transaction (duplicate > new merchant > large).
class AnomalyDetector {
  const AnomalyDetector({
    this.spikeZ = 2.0,
    this.spikeRatio = 1.3,
    this.spikeMinPaise = 100000,
    this.largeSigma = 3.0,
    this.largeMedianRatio = 3.0,
    this.largeMinPaise = 200000,
    this.newMerchantMinPaise = 500000,
    this.newMerchantMinHistory = 20,
    this.dupMinPaise = 10000,
    this.historyMonths = 6,
  });

  final double spikeZ;
  final double spikeRatio;
  final int spikeMinPaise;
  final double largeSigma;
  final double largeMedianRatio;
  final int largeMinPaise;
  final int newMerchantMinPaise;
  final int newMerchantMinHistory;
  final int dupMinPaise;
  final int historyMonths;

  List<Anomaly> detect(
    InsightsAggregator agg,
    MonthKey month, {
    Map<String, String> categoryNames = const {},
    Set<String> dismissed = const {},
    int limit = 5,
  }) {
    final histStart = month.plusMonths(-historyMonths).start;
    final monthStart = month.start;
    final monthEnd = month.endExclusive;

    final all = agg.counted.where((t) => t.isDebit).toList();
    final cur = all
        .where((t) => !t.bookedAt.isBefore(monthStart) &&
            t.bookedAt.isBefore(monthEnd))
        .toList()
      ..sort((a, b) => a.bookedAt.compareTo(b.bookedAt));
    final hist = all
        .where((t) => !t.bookedAt.isBefore(histStart) &&
            t.bookedAt.isBefore(monthStart))
        .toList();

    String nameOf(String? slug) =>
        categoryNames[slug ?? kUncategorizedSlug] ?? slug ?? 'Uncategorized';

    final out = <Anomaly>[];
    final flaggedTxn = <int>{};

    // Duplicates (highest priority per txn).
    final dupSeen = <String, InsightTxn>{};
    for (final t in cur) {
      if (t.amountPaise < dupMinPaise) continue;
      final k = RecurringDetector.groupKey(t);
      if (k == null) continue;
      final id = '$k|${t.amountPaise}';
      final prev = dupSeen[id];
      if (prev != null &&
          t.bookedAt.difference(prev.bookedAt) <= const Duration(hours: 24)) {
        out.add(Anomaly(
          kind: AnomalyKind.duplicateCharge,
          key: 'dup:${t.id}',
          title: 'Possible duplicate: ${t.merchantLabel}',
          detail: '${inrWhole(t.amountPaise)} charged twice within 24 hours',
          impactPaise: t.amountPaise,
          txnId: t.id,
        ));
        flaggedTxn.add(t.id);
      }
      dupSeen[id] = t;
    }

    // New merchant with a high amount.
    if (hist.length >= newMerchantMinHistory) {
      final known = {
        for (final t in hist)
          if (RecurringDetector.groupKey(t) case final k?) k,
      };
      final amounts = hist.map((t) => t.amountPaise).toList()..sort();
      final p90 = amounts[((amounts.length - 1) * 0.9).round()];
      final seenNew = <String>{};
      for (final t in cur) {
        if (flaggedTxn.contains(t.id)) continue;
        final k = RecurringDetector.groupKey(t);
        if (k == null || known.contains(k)) continue;
        // Only the first sighting counts as "new".
        if (!seenNew.add(k)) continue;
        if (t.amountPaise < newMerchantMinPaise || t.amountPaise < p90) {
          continue;
        }
        out.add(Anomaly(
          kind: AnomalyKind.newMerchant,
          key: 'new:${t.id}',
          title: 'New payee: ${t.merchantLabel}',
          detail: '${inrWhole(t.amountPaise)} to a payee not seen in the '
              'last $historyMonths months',
          impactPaise: t.amountPaise,
          txnId: t.id,
        ));
        flaggedTxn.add(t.id);
      }
    }

    // Large single transaction vs its category history.
    final histByCat = <String, List<int>>{};
    for (final t in hist) {
      histByCat
          .putIfAbsent(t.categorySlug ?? kUncategorizedSlug, () => [])
          .add(t.amountPaise);
    }
    for (final t in cur) {
      if (flaggedTxn.contains(t.id)) continue;
      final slug = t.categorySlug ?? kUncategorizedSlug;
      final h = histByCat[slug];
      if (h == null || h.length < 5 || t.amountPaise < largeMinPaise) continue;
      final mean = _mean(h);
      final sd = _std(h, mean);
      final med = _median(h);
      if (t.amountPaise > mean + largeSigma * sd &&
          t.amountPaise >= largeMedianRatio * med) {
        out.add(Anomaly(
          kind: AnomalyKind.largeTransaction,
          key: 'large:${t.id}',
          title: 'Large ${nameOf(t.categorySlug)} payment',
          detail: '${inrWhole(t.amountPaise)} at ${t.merchantLabel} — '
              'typical is ${inrWhole(med.round())}',
          impactPaise: t.amountPaise - med.round(),
          txnId: t.id,
        ));
        flaggedTxn.add(t.id);
      }
    }

    // Category spikes vs prior monthly totals.
    final priors = [
      for (var i = 1; i <= historyMonths; i++) agg.summarize(month.plusMonths(-i)),
    ].where((s) => s.txnCount > 0).toList();
    if (priors.length >= 3) {
      final now = agg.summarize(month).byCategory;
      for (final e in now.entries) {
        if (e.key == kUncategorizedSlug) continue;
        final series = [for (final p in priors) (p.byCategory[e.key] ?? 0)];
        final mean = _mean(series);
        if (mean <= 0) continue;
        final sd = math.max(_std(series, mean), mean * 0.1);
        final z = (e.value - mean) / sd;
        if (z >= spikeZ &&
            e.value >= mean * spikeRatio &&
            e.value - mean >= spikeMinPaise) {
          out.add(Anomaly(
            kind: AnomalyKind.categorySpike,
            key: 'cat:${e.key}:$month',
            title: '${nameOf(e.key)} spending is up',
            detail: '${inrWhole(e.value)} this month vs '
                '${inrWhole(mean.round())} average',
            impactPaise: (e.value - mean).round(),
          ));
        }
      }
    }

    return (out.where((a) => !dismissed.contains(a.key)).toList()
          ..sort((a, b) {
            final c = b.impactPaise.compareTo(a.impactPaise);
            return c != 0 ? c : a.key.compareTo(b.key);
          }))
        .take(limit)
        .toList();
  }

  static double _mean(List<int> v) =>
      v.isEmpty ? 0 : v.fold<int>(0, (a, b) => a + b) / v.length;

  static double _std(List<int> v, double mean) {
    if (v.length < 2) return 0;
    final ss = v.fold<double>(0, (a, b) => a + (b - mean) * (b - mean));
    return math.sqrt(ss / v.length);
  }

  static double _median(List<int> v) {
    final s = [...v]..sort();
    final n = s.length;
    return n.isOdd ? s[n ~/ 2].toDouble() : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
  }
}

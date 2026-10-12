import 'insight_models.dart';
import 'insights_aggregator.dart';

/// A monthly spending limit for one category.
class BudgetDef {
  const BudgetDef({
    required this.slug,
    required this.limitPaise,
    required this.start,
    this.rollover = false,
  });

  final String slug;
  final int limitPaise;

  /// First month the budget applies to; rollover never reaches before it.
  final MonthKey start;

  /// Envelope style: unspent money (or overspend) carries into next month.
  final bool rollover;
}

enum BudgetStatus { ok, warning, over }

class BudgetProgress {
  const BudgetProgress({
    required this.slug,
    required this.name,
    required this.limitPaise,
    required this.carryPaise,
    required this.spentPaise,
    required this.status,
    this.expectedFraction,
  });

  final String slug;
  final String name;
  final int limitPaise;

  /// Rolled over from earlier months; negative after overspending.
  final int carryPaise;
  final int spentPaise;
  final BudgetStatus status;

  /// Share of the month elapsed (current month only), for pace hints.
  final double? expectedFraction;

  int get availablePaise => limitPaise + carryPaise;
  int get remainingPaise => availablePaise - spentPaise;

  /// Spent / available; 1.0+ when nothing is available.
  double get fraction => availablePaise <= 0
      ? (spentPaise > 0 ? double.infinity : 0)
      : spentPaise / availablePaise;

  /// Spending faster than the month is passing (by more than 10 points).
  bool get aheadOfPace =>
      status == BudgetStatus.ok &&
      expectedFraction != null &&
      fraction > expectedFraction! + 0.1;
}

/// Pure budget maths over an [InsightsAggregator]. Spend per category is the
/// aggregator's (debits net of refunds, transfers excluded).
class BudgetCalculator {
  const BudgetCalculator({this.warnAt = 0.8, this.maxCarryMonths = 6});

  /// Fraction of the available amount at which a budget turns [warning].
  final double warnAt;

  /// Rollover looks back at most this many months (the aggregator holds 7).
  final int maxCarryMonths;

  /// Progress for every budget in effect in [month], over-budget first, then
  /// by fraction used. [asOf] enables pace hints for the current month.
  List<BudgetProgress> compute(
    InsightsAggregator agg,
    MonthKey month,
    List<BudgetDef> defs,
    Map<String, String> names, {
    DateTime? asOf,
  }) {
    final spendCache = <MonthKey, Map<String, int>>{};
    int spent(MonthKey m, String slug) =>
        (spendCache[m] ??= agg.summarize(m).byCategory)[slug] ?? 0;

    double? expected;
    if (asOf != null && MonthKey.of(asOf) == month) {
      final days = month.endExclusive.difference(month.start).inDays;
      expected = asOf.day / days;
    }

    final out = <BudgetProgress>[
      for (final d in defs)
        if (d.start.compareTo(month) <= 0)
          _progress(d, month, names, spent, expected),
    ];
    out.sort((a, b) {
      final s = b.status.index.compareTo(a.status.index);
      if (s != 0) return s;
      final f = b.fraction.compareTo(a.fraction);
      return f != 0 ? f : a.name.compareTo(b.name);
    });
    return out;
  }

  BudgetProgress _progress(
    BudgetDef d,
    MonthKey month,
    Map<String, String> names,
    int Function(MonthKey, String) spent,
    double? expected,
  ) {
    var carry = 0;
    if (d.rollover) {
      var m = month.plusMonths(-maxCarryMonths);
      if (m.compareTo(d.start) < 0) m = d.start;
      for (; m.compareTo(month) < 0; m = m.plusMonths(1)) {
        carry += d.limitPaise - spent(m, d.slug);
      }
    }
    final s = spent(month, d.slug);
    final available = d.limitPaise + carry;
    final status = s > available
        ? BudgetStatus.over
        : s >= available * warnAt
        ? BudgetStatus.warning
        : BudgetStatus.ok;
    return BudgetProgress(
      slug: d.slug,
      name: names[d.slug] ?? d.slug,
      limitPaise: d.limitPaise,
      carryPaise: carry,
      spentPaise: s,
      status: status,
      expectedFraction: expected,
    );
  }

  /// Suggested limit: average spend over the [months] full months before
  /// [month], rounded up to ₹100. Null when there is no history.
  static int? suggestLimit(
    InsightsAggregator agg,
    MonthKey month,
    String slug, {
    int months = 3,
  }) {
    var total = 0;
    var seen = 0;
    for (var i = 1; i <= months; i++) {
      final s = agg.summarize(month.plusMonths(-i));
      if (s.txnCount == 0) continue;
      seen++;
      total += s.byCategory[slug] ?? 0;
    }
    if (seen == 0 || total == 0) return null;
    final avg = total / seen;
    return ((avg / 10000).ceil()) * 10000;
  }
}

/// Categories that can carry a spending budget (not income or transfers).
bool isBudgetableSlug(String slug) =>
    !kIncomeSlugs.contains(slug) &&
    slug != kSelfTransferSlug &&
    slug != kUncategorizedSlug;

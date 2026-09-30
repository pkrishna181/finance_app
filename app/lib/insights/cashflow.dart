import 'insight_models.dart';
import 'insights_aggregator.dart';
import 'recurring_detector.dart';

class BalancePoint {
  const BalancePoint(this.day, this.paise);
  final DateTime day;
  final int paise;
}

/// Combined closing balance per day across accounts that report balances.
///
/// Per account, the day's last transaction (by time, then id) sets that day's
/// closing balance, which is carried forward on days without activity. An
/// account joins the sum from its first known balance. Accounts with fewer
/// than [minPointsPerAccount] balance points are ignored (too sparse to trust).
class BalanceSeries {
  static List<BalancePoint> build(
    List<InsightTxn> txns, {
    required DateTime from,
    required DateTime to,
    int minPointsPerAccount = 3,
  }) {
    final byAccount = <String, List<InsightTxn>>{};
    for (final t in txns) {
      if (t.balanceAfterPaise == null) continue;
      byAccount.putIfAbsent(t.accountKey, () => []).add(t);
    }
    byAccount.removeWhere((_, v) => v.length < minPointsPerAccount);
    if (byAccount.isEmpty) return const [];

    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (end.isBefore(start)) return const [];

    // Per account: day → closing balance.
    final closings = <List<MapEntry<DateTime, int>>>[];
    for (final list in byAccount.values) {
      list.sort((a, b) {
        final c = a.bookedAt.compareTo(b.bookedAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
      final perDay = <DateTime, int>{};
      for (final t in list) {
        perDay[DateTime(t.bookedAt.year, t.bookedAt.month, t.bookedAt.day)] =
            t.balanceAfterPaise!;
      }
      closings.add(perDay.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)));
    }

    final idx = List<int>.filled(closings.length, 0);
    final cur = List<int?>.filled(closings.length, null);
    final out = <BalancePoint>[];
    for (var d = start;
        !d.isAfter(end);
        d = DateTime(d.year, d.month, d.day + 1)) {
      var any = false;
      var sum = 0;
      for (var a = 0; a < closings.length; a++) {
        while (idx[a] < closings[a].length &&
            !closings[a][idx[a]].key.isAfter(d)) {
          cur[a] = closings[a][idx[a]].value;
          idx[a]++;
        }
        final v = cur[a];
        if (v != null) {
          any = true;
          sum += v;
        }
      }
      if (any) out.add(BalancePoint(d, sum));
    }
    return out;
  }
}

class UpcomingCharge {
  const UpcomingCharge(this.label, this.date, this.paise);
  final String label;
  final DateTime date;
  final int paise;
}

class MonthForecast {
  const MonthForecast({
    required this.spentSoFarPaise,
    required this.upcoming,
    required this.variableDailyPaise,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.remainingVariablePaise,
    this.currentBalancePaise,
  });

  final int spentSoFarPaise;
  final List<UpcomingCharge> upcoming;

  /// Non-recurring spend per day used for the projection.
  final int variableDailyPaise;
  final int daysElapsed;
  final int daysRemaining;
  final int remainingVariablePaise;
  final int? currentBalancePaise;

  int get upcomingRecurringPaise =>
      upcoming.fold(0, (s, u) => s + u.paise);

  int get projectedRemainingPaise =>
      upcomingRecurringPaise + remainingVariablePaise;

  int get projectedSpendPaise => spentSoFarPaise + projectedRemainingPaise;

  int? get projectedBalancePaise => currentBalancePaise == null
      ? null
      : currentBalancePaise! - projectedRemainingPaise;
}

/// Projects month-end spend: spend so far + recurring charges still due +
/// (non-recurring daily rate × days left).
///
/// Rate: this month's non-recurring spend / days elapsed once ≥ [minDays] have
/// passed; before that (or if this month has no spend) the average of the up to
/// 3 prior months. Recurring charges that are overdue (expected earlier than
/// today but not yet seen) are not projected.
class CashflowForecaster {
  const CashflowForecaster({this.minDays = 7, this.priorMonths = 3});

  final int minDays;
  final int priorMonths;

  /// Null unless [asOf] falls inside [month].
  MonthForecast? forecast(
    InsightsAggregator agg,
    MonthKey month,
    List<RecurringSeries> recurring, {
    required DateTime asOf,
    int? currentBalancePaise,
  }) {
    if (MonthKey.of(asOf) != month) return null;
    final today = DateTime(asOf.year, asOf.month, asOf.day);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final elapsed = asOf.day;
    final remaining = daysInMonth - elapsed;

    final recurringIds = {for (final r in recurring) ...r.txnIds};
    int variableIn(MonthKey m) {
      var v = 0;
      for (final t in agg.transactionsIn(m)) {
        if (t.isDebit && !recurringIds.contains(t.id)) v += t.amountPaise;
      }
      return v;
    }

    final spent = agg.summarize(month).spendPaise;
    final variableSoFar = variableIn(month);

    int rate;
    final prior = <int>[
      for (var i = 1; i <= priorMonths; i++)
        if (agg.summarize(month.plusMonths(-i)).txnCount > 0)
          (variableIn(month.plusMonths(-i)) /
                  DateTime(month.year, month.month - i + 1, 0).day)
              .round(),
    ];
    if (elapsed >= minDays || prior.isEmpty) {
      rate = (variableSoFar / elapsed).round();
    } else {
      rate = prior.reduce((a, b) => a + b) ~/ prior.length;
    }

    final monthEnd = DateTime(month.year, month.month, daysInMonth);
    final upcoming = <UpcomingCharge>[];
    for (final r in recurring) {
      if (!r.active) continue;
      final first = r.mandateDate ?? r.nextExpected;
      var d = DateTime(first.year, first.month, first.day);
      while (!d.isAfter(monthEnd)) {
        if (!d.isBefore(today)) {
          upcoming.add(UpcomingCharge(r.label, d, r.lastAmountPaise));
        }
        if (r.cadence != Cadence.weekly || r.mandateDate != null) break;
        d = DateTime(d.year, d.month, d.day + r.cadence.days);
      }
    }
    upcoming.sort((a, b) => a.date.compareTo(b.date));

    return MonthForecast(
      spentSoFarPaise: spent,
      upcoming: upcoming,
      variableDailyPaise: rate,
      daysElapsed: elapsed,
      daysRemaining: remaining,
      remainingVariablePaise: rate * remaining,
      currentBalancePaise: currentBalancePaise,
    );
  }
}

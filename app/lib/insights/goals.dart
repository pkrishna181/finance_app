import 'dart:math' as math;

/// Where a goal's progress comes from.
enum GoalSource {
  /// Starting amount + contributions the user logs.
  manual,

  /// Latest known balance of one bank account (`sourceRef` = `BANK|last4`).
  account,

  /// Starting amount + debits in a category since the start date
  /// (`sourceRef` = category slug, e.g. `investments_sip`).
  category,
}

class GoalDef {
  const GoalDef({
    required this.id,
    required this.name,
    required this.targetPaise,
    required this.startDate,
    this.targetDate,
    this.startPaise = 0,
    this.annualReturnPct = 0,
    this.source = GoalSource.manual,
    this.sourceRef,
  });

  final int id;
  final String name;
  final int targetPaise;
  final DateTime startDate;
  final DateTime? targetDate;

  /// Already saved when the goal was created (manual / category sources).
  final int startPaise;

  /// Expected yearly return on the money, e.g. 7 for 7%.
  final double annualReturnPct;
  final GoalSource source;
  final String? sourceRef;
}

/// A dated amount added toward a goal (logged, or a category debit).
class GoalFlow {
  const GoalFlow(this.date, this.paise);
  final DateTime date;
  final int paise;
}

enum GoalState { reached, onTrack, behind, noDeadline }

class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.currentPaise,
    required this.state,
    this.monthsLeft,
    this.requiredMonthlyPaise,
    this.recentMonthlyPaise,
    this.projectedDate,
  });

  final GoalDef goal;
  final int currentPaise;
  final GoalState state;

  /// Whole months until the target date (at least 1), when there is one.
  final int? monthsLeft;

  /// Monthly saving needed to reach the target by the target date.
  final int? requiredMonthlyPaise;

  /// Average monthly contribution over the last 3 months (for an account:
  /// average monthly balance growth).
  final int? recentMonthlyPaise;

  /// When the target is reached at the recent pace (null if never).
  final DateTime? projectedDate;

  int get remainingPaise {
    final r = goal.targetPaise - currentPaise;
    return r < 0 ? 0 : r;
  }

  double get fraction => goal.targetPaise <= 0
      ? 1
      : (currentPaise / goal.targetPaise).clamp(0.0, 1.0);
}

/// Pure goal maths. Returns compound monthly at `annualReturnPct / 12`.
class GoalCalculator {
  const GoalCalculator();

  GoalProgress progress(
    GoalDef g, {
    required DateTime asOf,
    List<GoalFlow> flows = const [],
    int? accountBalancePaise,
    int? accountBalance3MonthsAgoPaise,
  }) {
    final current = switch (g.source) {
      GoalSource.account => accountBalancePaise ?? 0,
      _ => g.startPaise + flows.fold<int>(0, (s, f) => s + f.paise),
    };

    // Recent pace: contributions in the last 3 months / 3.
    int? recent;
    if (g.source == GoalSource.account) {
      if (accountBalancePaise != null &&
          accountBalance3MonthsAgoPaise != null) {
        recent =
            ((accountBalancePaise - accountBalance3MonthsAgoPaise) / 3).round();
      }
    } else {
      final since = DateTime(asOf.year, asOf.month - 3, asOf.day);
      final sum = flows
          .where((f) => f.date.isAfter(since) && !f.date.isAfter(asOf))
          .fold<int>(0, (s, f) => s + f.paise);
      recent = (sum / 3).round();
    }

    final r = g.annualReturnPct / 100 / 12;
    int? monthsLeft;
    int? required;
    final td = g.targetDate;
    if (td != null) {
      final m = (td.year - asOf.year) * 12 + td.month - asOf.month;
      monthsLeft = m < 1 ? 1 : m;
      required = requiredMonthly(current, g.targetPaise, monthsLeft, r);
    }

    DateTime? projected;
    if (current >= g.targetPaise) {
      projected = asOf;
    } else if (recent != null && recent > 0) {
      final n = monthsToReach(current, g.targetPaise, recent, r);
      if (n != null) projected = DateTime(asOf.year, asOf.month + n, asOf.day);
    }

    final GoalState state;
    if (current >= g.targetPaise) {
      state = GoalState.reached;
    } else if (required == null) {
      state = GoalState.noDeadline;
    } else {
      state = (recent ?? 0) >= required ? GoalState.onTrack : GoalState.behind;
    }

    return GoalProgress(
      goal: g,
      currentPaise: current,
      state: state,
      monthsLeft: monthsLeft,
      requiredMonthlyPaise: required,
      recentMonthlyPaise: recent,
      projectedDate: projected,
    );
  }

  /// Monthly payment so that [current] grows to [target] in [months] at
  /// monthly rate [r] (payments at month end). Never negative.
  static int requiredMonthly(int current, int target, int months, double r) {
    final growth = math.pow(1 + r, months).toDouble();
    final gap = target - current * growth;
    if (gap <= 0) return 0;
    final pmt = r == 0 ? gap / months : gap * r / (growth - 1);
    return pmt.ceil();
  }

  /// Months until [current] + [monthly] payments reach [target] at rate [r];
  /// null if it takes more than 100 years.
  static int? monthsToReach(int current, int target, int monthly, double r) {
    var v = current.toDouble();
    for (var n = 1; n <= 1200; n++) {
      v = v * (1 + r) + monthly;
      if (v >= target) return n;
    }
    return null;
  }
}

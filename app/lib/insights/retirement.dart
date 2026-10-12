import 'dart:math' as math;

import 'allocation.dart';

class RetirementInputs {
  const RetirementInputs({
    required this.currentAge,
    required this.retireAge,
    required this.monthlyExpensePaise,
    this.lifeExpectancy = 85,
    this.inflation = 0.06,
    this.returnPre = 0.10,
    this.returnPost = 0.07,
    this.swr,
    this.classes = const {
      AssetClass.equity,
      AssetClass.debt,
      AssetClass.gold,
      AssetClass.other,
    },
  });

  final int currentAge;
  final int retireAge;
  final int lifeExpectancy;

  /// Today's monthly expenses.
  final int monthlyExpensePaise;
  final double inflation;

  /// Yearly return before / after retirement.
  final double returnPre;
  final double returnPost;

  /// Safe withdrawal rate (e.g. 0.035). Null = corpus that lasts until
  /// [lifeExpectancy] with expenses growing at [inflation].
  final double? swr;
  final Set<AssetClass> classes;
}

class RetirementPlanResult {
  const RetirementPlanResult({
    required this.inputs,
    required this.yearsToRetire,
    required this.annualExpenseAtRetirePaise,
    required this.corpusNeededPaise,
    required this.currentCorpusPaise,
    required this.projectedCorpusPaise,
    required this.monthlySavingNeededPaise,
    this.recentMonthlySavingPaise,
  });

  final RetirementInputs inputs;
  final int yearsToRetire;
  final int annualExpenseAtRetirePaise;

  /// At retirement, in future rupees.
  final int corpusNeededPaise;
  final int currentCorpusPaise;

  /// Current corpus grown at [RetirementInputs.returnPre] to retirement.
  final int projectedCorpusPaise;

  /// Monthly saving (from now, at month end) that closes the gap.
  final int monthlySavingNeededPaise;

  /// Average monthly income − spend recently, from the ledger.
  final int? recentMonthlySavingPaise;

  int get gapPaise => math.max(0, corpusNeededPaise - projectedCorpusPaise);

  /// Corpus needed in today's rupees.
  int get corpusNeededTodayPaise =>
      (corpusNeededPaise / math.pow(1 + inputs.inflation, yearsToRetire))
          .round();

  /// Share of the target the current corpus alone reaches.
  double get fundedFraction => corpusNeededPaise <= 0
      ? 1
      : (projectedCorpusPaise / corpusNeededPaise).clamp(0.0, 1.0);

  bool? get onTrack => recentMonthlySavingPaise == null
      ? null
      : recentMonthlySavingPaise! >= monthlySavingNeededPaise;
}

/// Pure retirement maths (yearly compounding for growth, monthly for
/// savings).
class RetirementCalculator {
  const RetirementCalculator();

  RetirementPlanResult plan(
    RetirementInputs i, {
    required int currentCorpusPaise,
    int? recentMonthlySavingPaise,
  }) {
    final n = math.max(0, i.retireAge - i.currentAge);
    final expenseAtRetire =
        i.monthlyExpensePaise * 12 * math.pow(1 + i.inflation, n).toDouble();
    final corpus = i.swr != null && i.swr! > 0
        ? expenseAtRetire / i.swr!
        : _growingAnnuity(
            expenseAtRetire,
            math.max(1, i.lifeExpectancy - i.retireAge),
            i.returnPost,
            i.inflation,
          );
    final projected =
        currentCorpusPaise * math.pow(1 + i.returnPre, n).toDouble();
    final gap = math.max(0.0, corpus - projected);
    final months = n * 12;
    final r = math.pow(1 + i.returnPre, 1 / 12) - 1; // effective monthly
    final sip = months == 0
        ? gap
        : r == 0
        ? gap / months
        : gap * r / (math.pow(1 + r, months) - 1);
    return RetirementPlanResult(
      inputs: i,
      yearsToRetire: n,
      annualExpenseAtRetirePaise: expenseAtRetire.round(),
      corpusNeededPaise: corpus.round(),
      currentCorpusPaise: currentCorpusPaise,
      projectedCorpusPaise: projected.round(),
      monthlySavingNeededPaise: sip.ceil(),
      recentMonthlySavingPaise: recentMonthlySavingPaise,
    );
  }

  /// Present value at retirement of [years] yearly withdrawals starting at
  /// [first] (taken at the start of each year) growing at [g], earning [r].
  static double _growingAnnuity(double first, int years, double r, double g) {
    if ((r - g).abs() < 1e-9) return first * years;
    final q = (1 + g) / (1 + r);
    return first * (1 - math.pow(q, years)) / (1 - q);
  }
}

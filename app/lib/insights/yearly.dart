import 'insight_models.dart';
import 'insights_aggregator.dart';

/// Indian financial year: April [startYear] – March [startYear] + 1.
class FinancialYear implements Comparable<FinancialYear> {
  const FinancialYear(this.startYear);

  factory FinancialYear.of(DateTime d) =>
      FinancialYear(d.month >= 4 ? d.year : d.year - 1);

  factory FinancialYear.ofMonth(MonthKey m) =>
      FinancialYear(m.month >= 4 ? m.year : m.year - 1);

  final int startYear;

  MonthKey get firstMonth => MonthKey(startYear, 4);
  MonthKey get lastMonth => MonthKey(startYear + 1, 3);
  DateTime get start => firstMonth.start;
  DateTime get endExclusive => lastMonth.endExclusive;

  /// April first.
  List<MonthKey> get months => [
    for (var i = 0; i < 12; i++) firstMonth.plusMonths(i),
  ];

  /// "FY 2026-27"
  String get label =>
      'FY $startYear-${((startYear + 1) % 100).toString().padLeft(2, '0')}';

  FinancialYear get previous => FinancialYear(startYear - 1);
  FinancialYear get next => FinancialYear(startYear + 1);

  @override
  int compareTo(FinancialYear other) => startYear.compareTo(other.startYear);

  @override
  bool operator ==(Object other) =>
      other is FinancialYear && other.startYear == startYear;

  @override
  int get hashCode => startYear.hashCode;

  @override
  String toString() => label;
}

/// Income source key for uncategorized credits.
const kOtherIncomeSlug = 'other_income';

/// One financial year of cash flow, built from monthly summaries so the
/// totals always match the monthly Insights view.
class YearSummary {
  const YearSummary({
    required this.year,
    required this.months,
    required this.incomeBySource,
    required this.spendByCategory,
    required this.dailySpend,
  });

  final FinancialYear year;

  /// Twelve months, April first.
  final List<MonthSummary> months;

  /// `salary`, `interest`, or [kOtherIncomeSlug] → paise.
  final Map<String, int> incomeBySource;

  /// Category slug → spend (monthly figures, refunds netted, summed).
  final Map<String, int> spendByCategory;

  /// Gross debits per calendar day (date at local midnight → paise). Days
  /// without spend are absent.
  final Map<DateTime, int> dailySpend;

  int get incomePaise => months.fold(0, (s, m) => s + m.incomePaise);
  int get spendPaise => months.fold(0, (s, m) => s + m.spendPaise);
  int get netPaise => incomePaise - spendPaise;
  int get txnCount => months.fold(0, (s, m) => s + m.txnCount);
  bool get isEmpty => txnCount == 0;

  /// Net / income, or null without income.
  double? get savingsRate => incomePaise <= 0 ? null : netPaise / incomePaise;

  static YearSummary build(InsightsAggregator agg, FinancialYear fy) {
    final months = [for (final m in fy.months) agg.summarize(m)];
    final byCat = <String, int>{};
    for (final m in months) {
      m.byCategory.forEach((k, v) => byCat[k] = (byCat[k] ?? 0) + v);
    }
    final income = <String, int>{};
    final daily = <DateTime, int>{};
    for (final t in agg.counted) {
      if (t.bookedAt.isBefore(fy.start) ||
          !t.bookedAt.isBefore(fy.endExclusive)) {
        continue;
      }
      if (t.isDebit) {
        final d = DateTime(t.bookedAt.year, t.bookedAt.month, t.bookedAt.day);
        daily[d] = (daily[d] ?? 0) + t.amountPaise;
      } else if (t.isUncategorized) {
        income[kOtherIncomeSlug] =
            (income[kOtherIncomeSlug] ?? 0) + t.amountPaise;
      } else if (kIncomeSlugs.contains(t.categorySlug)) {
        income[t.categorySlug!] =
            (income[t.categorySlug!] ?? 0) + t.amountPaise;
      }
    }
    return YearSummary(
      year: fy,
      months: months,
      incomeBySource: income,
      spendByCategory: byCat,
      dailySpend: daily,
    );
  }
}

/// Splits positive [values] into [buckets] intensity levels by quantile:
/// returns the upper bound of each level except the last (ascending).
List<int> quantileThresholds(Iterable<int> values, {int buckets = 4}) {
  final sorted = values.where((v) => v > 0).toList()..sort();
  if (sorted.isEmpty) return const [];
  return [
    for (var i = 1; i < buckets; i++)
      sorted[((sorted.length * i) / buckets).floor().clamp(
        0,
        sorted.length - 1,
      )],
  ];
}

/// Level 0 = no spend; 1..[thresholds.length]+1 by threshold.
int intensityLevel(int value, List<int> thresholds) {
  if (value <= 0) return 0;
  var level = 1;
  for (final t in thresholds) {
    if (value > t) level++;
  }
  return level;
}

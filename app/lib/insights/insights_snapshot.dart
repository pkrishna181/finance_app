import 'insight_models.dart';
import 'anomaly_detector.dart';
import 'insights_aggregator.dart';
import 'recurring_detector.dart';

const kOtherSliceSlug = '_other';

class CategorySlice {
  const CategorySlice({
    required this.slug,
    required this.name,
    required this.paise,
    required this.fraction,
  });

  final String slug;
  final String name;
  final int paise;

  /// Share of total categorized spend, 0..1.
  final double fraction;

  bool get isOther => slug == kOtherSliceSlug;
}

/// Everything the Insights overview renders for one month.
class InsightsSnapshot {
  const InsightsSnapshot({
    required this.month,
    required this.summary,
    required this.spendDelta,
    required this.trend,
    required this.slices,
    required this.merchants,
    required this.aggregator,
    this.recurring = const [],
    this.anomalies = const [],
  });

  final MonthKey month;
  final MonthSummary summary;
  final MonthDelta spendDelta;

  /// Oldest first.
  final List<MonthSummary> trend;
  final List<CategorySlice> slices;
  final List<MerchantTotal> merchants;
  final InsightsAggregator aggregator;
  final List<RecurringSeries> recurring;
  final List<Anomaly> anomalies;

  /// Active series only, for monthly-commitment totals.
  List<RecurringSeries> get activeRecurring =>
      [for (final r in recurring) if (r.active) r];

  int get monthlyCommitmentPaise =>
      activeRecurring.fold(0, (s, r) => s + r.monthlyEquivalentPaise);

  bool get isEmpty => summary.txnCount == 0;

  static InsightsSnapshot build(
    InsightsAggregator agg,
    MonthKey month,
    Map<String, String> categoryNames, {
    int maxSlices = 6,
    int trendMonths = 6,
    int merchantLimit = 5,
    List<RecurringSeries> recurring = const [],
    Set<String> dismissedAnomalies = const {},
  }) {
    final summary = agg.summarize(month);
    return InsightsSnapshot(
      month: month,
      summary: summary,
      spendDelta: agg.monthOverMonth(month).spend,
      trend: agg.trend(month, months: trendMonths),
      slices: buildSlices(summary.byCategory, categoryNames,
          maxSlices: maxSlices),
      merchants: agg.topMerchants(month, limit: merchantLimit),
      aggregator: agg,
      recurring: recurring,
      anomalies: const AnomalyDetector().detect(
        agg,
        month,
        categoryNames: categoryNames,
        dismissed: dismissedAnomalies,
      ),
    );
  }

  /// Largest [maxSlices]-1 categories, the rest folded into "Other".
  static List<CategorySlice> buildSlices(
    Map<String, int> byCategory,
    Map<String, String> names, {
    int maxSlices = 6,
  }) {
    final entries = byCategory.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    if (total == 0) return const [];

    String nameOf(String slug) =>
        names[slug] ?? (slug == kUncategorizedSlug ? 'Uncategorized' : slug);

    final keep = entries.length <= maxSlices
        ? entries
        : entries.take(maxSlices - 1).toList();
    final rest = entries.length <= maxSlices
        ? const <MapEntry<String, int>>[]
        : entries.skip(maxSlices - 1).toList();

    return [
      for (final e in keep)
        CategorySlice(
          slug: e.key,
          name: nameOf(e.key),
          paise: e.value,
          fraction: e.value / total,
        ),
      if (rest.isNotEmpty)
        CategorySlice(
          slug: kOtherSliceSlug,
          name: 'Other',
          paise: rest.fold<int>(0, (s, e) => s + e.value),
          fraction: rest.fold<int>(0, (s, e) => s + e.value) / total,
        ),
    ];
  }
}

import '../insights/insight_format.dart';
import '../insights/insight_models.dart';
import '../insights/yearly.dart';

/// What a question asks for. Every intent is answered by existing,
/// deterministic code; the model (when used) only picks one of these.
enum AskIntent {
  spend,
  income,
  savings,
  topCategories,
  topMerchants,
  largest,
  lastPaid,
  average,
  netWorth,
  budgets,
  upcoming,
}

extension AskIntentWire on AskIntent {
  /// Wire name used in model output (`top_categories`, …).
  String get wire => switch (this) {
    AskIntent.spend => 'spend',
    AskIntent.income => 'income',
    AskIntent.savings => 'savings',
    AskIntent.topCategories => 'top_categories',
    AskIntent.topMerchants => 'top_merchants',
    AskIntent.largest => 'largest',
    AskIntent.lastPaid => 'last_paid',
    AskIntent.average => 'average',
    AskIntent.netWorth => 'net_worth',
    AskIntent.budgets => 'budgets',
    AskIntent.upcoming => 'upcoming',
  };

  static AskIntent? fromWire(String s) {
    for (final i in AskIntent.values) {
      if (i.wire == s) return i;
    }
    return null;
  }

  /// Intents that read a date range (others are "as of now").
  bool get usesPeriod => switch (this) {
    AskIntent.lastPaid ||
    AskIntent.netWorth ||
    AskIntent.budgets ||
    AskIntent.upcoming ||
    AskIntent.average => false,
    _ => true,
  };
}

/// A date range `[from, toExclusive)` with a human label.
class AskPeriod {
  const AskPeriod(this.from, this.toExclusive, this.label);

  factory AskPeriod.month(MonthKey m, {DateTime? now}) {
    final current = now != null && MonthKey.of(now) == m;
    return AskPeriod(
      m.start,
      m.endExclusive,
      current
          ? '${monthLabel(m.year, m.month)} so far'
          : monthLabel(m.year, m.month),
    );
  }

  factory AskPeriod.financialYear(FinancialYear fy, {DateTime? now}) {
    final current = now != null && FinancialYear.of(now) == fy;
    return AskPeriod(
      fy.start,
      fy.endExclusive,
      current ? '${fy.label} so far' : fy.label,
    );
  }

  factory AskPeriod.calendarYear(int year, {DateTime? now}) => AskPeriod(
    DateTime(year),
    DateTime(year + 1),
    now != null && now.year == year ? '$year so far' : '$year',
  );

  /// The [days] days ending today (inclusive).
  factory AskPeriod.lastDays(int days, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final from = today.subtract(Duration(days: days - 1));
    return AskPeriod(
      from,
      today.add(const Duration(days: 1)),
      'the last $days days (${shortDate(from)} – ${shortDate(today)})',
    );
  }

  /// The [months] months ending today, e.g. 21 Jul – 20 Oct for 3.
  factory AskPeriod.lastMonths(int months, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(now.year, now.month - months, now.day + 1);
    return AskPeriod.lastDays(today.difference(from).inDays + 1, now);
  }

  /// Everything up to today.
  factory AskPeriod.allTime(DateTime now) => AskPeriod(
    kAllTimeStart,
    DateTime(now.year, now.month, now.day + 1),
    'all time',
  );

  static final kAllTimeStart = DateTime(2000);

  final DateTime from;
  final DateTime toExclusive;
  final String label;

  /// Same length immediately before, for comparisons (whole months only).
  AskPeriod? get previousMonth {
    final m = MonthKey.of(from);
    if (from != m.start || toExclusive != m.endExclusive) return null;
    return AskPeriod.month(m.plusMonths(-1));
  }

  /// Calendar months touched by this period, oldest first.
  List<MonthKey> get months {
    final last = MonthKey.of(
      toExclusive.subtract(const Duration(microseconds: 1)),
    );
    return [
      for (
        var m = MonthKey.of(from);
        m.compareTo(last) <= 0;
        m = m.plusMonths(1)
      )
        m,
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is AskPeriod &&
      other.from == from &&
      other.toExclusive == toExclusive;

  @override
  int get hashCode => Object.hash(from, toExclusive);

  @override
  String toString() => label;
}

/// "3 Sep"
String shortDate(DateTime d) => '${d.day} ${monthShort(d.month)}';

/// A structured question. Built by [AskParser] or from validated model output.
class AskQuery {
  const AskQuery({
    required this.intent,
    this.period,
    this.categorySlug,
    this.merchant,
    this.months = 6,
    this.days = 30,
  });

  final AskIntent intent;

  /// Null for intents that don't use one ([AskIntentWire.usesPeriod]).
  final AskPeriod? period;
  final String? categorySlug;

  /// Lowercased merchant text, matched against merchant names.
  final String? merchant;

  /// Full months for [AskIntent.average].
  final int months;

  /// Look-ahead for [AskIntent.upcoming].
  final int days;

  @override
  bool operator ==(Object other) =>
      other is AskQuery &&
      other.intent == intent &&
      other.period == period &&
      other.categorySlug == categorySlug &&
      other.merchant == merchant &&
      other.months == months &&
      other.days == days;

  @override
  int get hashCode =>
      Object.hash(intent, period, categorySlug, merchant, months, days);

  @override
  String toString() =>
      'AskQuery(${intent.wire}, $period, cat=$categorySlug, '
      'merchant=$merchant, months=$months, days=$days)';
}

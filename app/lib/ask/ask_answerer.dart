import '../core/db/database.dart';
import '../insights/budget.dart';
import '../insights/budget_repository.dart';
import '../insights/insight_format.dart';
import '../insights/insight_models.dart';
import '../insights/insights_aggregator.dart';
import '../insights/insights_repository.dart';
import '../insights/net_worth.dart';
import '../insights/net_worth_repository.dart';
import '../insights/txn_query.dart';
import '../insights/upcoming.dart';
import '../insights/upcoming_repository.dart';
import 'ask_parser.dart';
import 'ask_query.dart';

/// One line of an answer's breakdown.
class AskRow {
  const AskRow(this.label, {this.paise, this.detail, this.flagged = false});

  final String label;
  final int? paise;
  final String? detail;

  /// Over budget, overdue, or a liability — shown in the error colour.
  final bool flagged;
}

/// An answer, computed entirely by deterministic code.
class AskAnswer {
  const AskAnswer({
    required this.query,
    required this.understoodAs,
    required this.headline,
    this.rows = const [],
    this.transactions = const [],
    this.note,
    this.searchQuery,
  });

  final AskQuery query;

  /// The question as the app read it, e.g. "Spending · Food Delivery · Sep 2026".
  final String understoodAs;
  final String headline;
  final List<AskRow> rows;
  final List<InsightTxn> transactions;
  final String? note;

  /// [TxnQuery] syntax that opens the matching transactions in Search.
  final String? searchQuery;
}

typedef _Build =
    AskAnswer Function(
      String headline, {
      List<AskRow> rows,
      List<InsightTxn> txns,
      String? note,
      String? search,
    });

/// "3 Oct 2026"
String longDate(DateTime d) => '${shortDate(d)} ${d.year}';

/// Answers [AskQuery]s with the same repositories and rules as the rest of
/// the app, so a number here always matches Insights, Budgets and Net worth.
class AskAnswerer {
  AskAnswerer(this._db) : _repo = InsightsRepository(_db);

  final ArthDatabase _db;
  final InsightsRepository _repo;
  Map<String, String>? _names;

  Future<Map<String, String>> _categoryNames() async =>
      _names ??= await _repo.categoryNames();

  /// Category and merchant words for [AskParser].
  Future<AskVocabulary> vocabulary() async {
    final rows = await _db
        .customSelect(
          '''
SELECT DISTINCT LOWER(COALESCE(m.canonical_name, t.raw_merchant)) AS label
FROM transactions t LEFT JOIN merchants m ON m.id = t.merchant_id
UNION
SELECT DISTINCT LOWER(raw_merchant) FROM transactions
''',
          readsFrom: {_db.transactions, _db.merchants},
        )
        .get();
    return AskVocabulary(
      categoryNames: await _categoryNames(),
      merchants: [
        for (final r in rows)
          if (r.readNullable<String>('label') case final l?)
            if (l.trim().isNotEmpty) l.trim(),
      ],
    );
  }

  /// "Spending · Food Delivery · Sep 2026"
  Future<String> describe(AskQuery q) async {
    final names = await _categoryNames();
    final what = switch (q.intent) {
      AskIntent.spend => 'Spending',
      AskIntent.income => 'Income',
      AskIntent.savings => 'Savings',
      AskIntent.topCategories => 'Top categories',
      AskIntent.topMerchants => 'Top merchants',
      AskIntent.largest => 'Largest payments',
      AskIntent.lastPaid => 'Last payment',
      AskIntent.average => 'Monthly average (last ${q.months} months)',
      AskIntent.netWorth => 'Net worth',
      AskIntent.budgets => 'Budgets this month',
      AskIntent.upcoming => 'Due in the next ${q.days} days',
    };
    return [
      what,
      if (q.categorySlug != null) names[q.categorySlug] ?? q.categorySlug!,
      if (q.merchant != null) '"${q.merchant}"',
      if (q.period != null) q.period!.label,
    ].join(' · ');
  }

  Future<AskAnswer> answer(AskQuery q, DateTime now) async {
    final understood = await describe(q);
    AskAnswer build(
      String headline, {
      List<AskRow> rows = const [],
      List<InsightTxn> txns = const [],
      String? note,
      String? search,
    }) => AskAnswer(
      query: q,
      understoodAs: understood,
      headline: headline,
      rows: rows,
      transactions: txns,
      note: note,
      searchQuery: search,
    );

    switch (q.intent) {
      case AskIntent.netWorth:
        return _netWorth(now, build);
      case AskIntent.budgets:
        return _budgets(now, build);
      case AskIntent.upcoming:
        return _upcoming(q, now, build);
      case AskIntent.lastPaid:
        return _lastPaid(q, build);
      case AskIntent.average:
        return _average(q, now, build);
      default:
        break;
    }

    final p = q.period!;
    final agg = await _aggregatorFor(p);
    final inPeriod = [
      for (final t in agg.counted)
        if (!t.bookedAt.isBefore(p.from) && t.bookedAt.isBefore(p.toExclusive))
          t,
    ];
    if (inPeriod.isEmpty) {
      return build(
        'I don\'t have any transactions from ${p.label}.',
        note: 'Import statements or scan SMS to fill this period in.',
      );
    }
    return switch (q.intent) {
      AskIntent.spend => _spend(q, p, agg, inPeriod, build),
      AskIntent.income => _income(q, p, agg, inPeriod, build),
      AskIntent.savings => _savings(p, agg, build),
      AskIntent.topCategories => _topCategories(p, agg, build),
      AskIntent.topMerchants => _topMerchants(q, p, agg, build),
      AskIntent.largest => _largest(q, p, inPeriod, build),
      _ => throw StateError('unreachable: ${q.intent}'),
    };
  }

  // ---------------------------------------------------------------- helpers

  /// Covers [p] and, for a whole month, the month before (for comparisons).
  Future<InsightsAggregator> _aggregatorFor(AskPeriod p) async =>
      InsightsAggregator(
        await _repo.loadRange(
          (p.previousMonth?.from ?? p.from).subtract(const Duration(days: 7)),
          p.toExclusive.add(const Duration(days: 7)),
        ),
      );

  /// Spend, income and per-category spend over [p] with the aggregator's
  /// monthly rules (refunds net per category per month), so whole months
  /// match Insights exactly.
  static ({int spend, int income, Map<String, int> byCategory, int uncat})
  _totals(InsightsAggregator agg, AskPeriod p) {
    var spend = 0;
    var income = 0;
    var uncat = 0;
    final byCat = <String, int>{};
    for (final m in p.months) {
      final from = p.from.isAfter(m.start) ? p.from : m.start;
      final to = p.toExclusive.isBefore(m.endExclusive)
          ? p.toExclusive
          : m.endExclusive;
      final s = agg.summarizeWithin(m, from, to);
      spend += s.spendPaise;
      income += s.incomePaise;
      uncat += s.byCategory[kUncategorizedSlug] ?? 0;
      s.byCategory.forEach((k, v) => byCat[k] = (byCat[k] ?? 0) + v);
    }
    return (spend: spend, income: income, byCategory: byCat, uncat: uncat);
  }

  static bool _matchesMerchant(InsightTxn t, String term) =>
      t.merchantLabel.toLowerCase().contains(term) ||
      t.rawMerchant.toLowerCase().contains(term);

  static bool _inCategory(InsightTxn t, String slug) =>
      (t.categorySlug ?? kUncategorizedSlug) == slug;

  static String _dateFilter(AskPeriod p) {
    String d(DateTime x) =>
        '${x.year}-${x.month.toString().padLeft(2, '0')}-'
        '${x.day.toString().padLeft(2, '0')}';
    return 'from:${d(p.from)} '
        'to:${d(p.toExclusive.subtract(const Duration(days: 1)))}';
  }

  static String _search(AskQuery q, {AskPeriod? period, bool? debit}) => [
    if (q.categorySlug != null) 'cat:${q.categorySlug}',
    if (q.merchant != null) '"${q.merchant}"',
    if (period != null) _dateFilter(period),
    if (debit != null) debit ? 'debit' : 'credit',
  ].join(' ');

  static String _count(int n, String noun) =>
      n == 1 ? '1 $noun' : '$n ${noun}s';

  String _catName(String slug) => _names?[slug] ?? slug;

  // ---------------------------------------------------------------- intents

  AskAnswer _spend(
    AskQuery q,
    AskPeriod p,
    InsightsAggregator agg,
    List<InsightTxn> inPeriod,
    _Build build,
  ) {
    final search = _search(q, period: p, debit: true);
    ({int paise, int count}) measure(AskPeriod period, List<InsightTxn> txns) {
      if (q.merchant != null) {
        final hits = [
          for (final t in txns)
            if (t.isDebit &&
                _matchesMerchant(t, q.merchant!) &&
                (q.categorySlug == null || _inCategory(t, q.categorySlug!)))
              t,
        ];
        return (
          paise: hits.fold(0, (s, t) => s + t.amountPaise),
          count: hits.length,
        );
      }
      final totals = _totals(agg, period);
      final slug = q.categorySlug;
      return (
        paise: slug == null ? totals.spend : totals.byCategory[slug] ?? 0,
        count: txns
            .where((t) => t.isDebit && (slug == null || _inCategory(t, slug)))
            .length,
      );
    }

    final cur = measure(p, inPeriod);
    final on = q.merchant != null
        ? ' at "${q.merchant}"'
        : q.categorySlug != null
        ? ' on ${_catName(q.categorySlug!)}'
        : '';
    if (cur.count == 0) {
      return build(
        'You didn\'t spend anything$on in ${p.label}.',
        search: search,
      );
    }

    final rows = <AskRow>[];
    final prev = p.previousMonth;
    if (prev != null) {
      final prevTxns = [
        for (final t in agg.counted)
          if (!t.bookedAt.isBefore(prev.from) &&
              t.bookedAt.isBefore(prev.toExclusive))
            t,
      ];
      final before = measure(prev, prevTxns);
      if (before.count > 0) {
        rows.add(AskRow(prev.label, paise: before.paise));
      }
    }
    if (q.categorySlug == null && q.merchant == null) {
      final totals = _totals(agg, p);
      final top = totals.byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in top.take(3)) {
        rows.add(AskRow(_catName(e.key), paise: e.value));
      }
    }

    final uncat = q.categorySlug == null && q.merchant == null
        ? _totals(agg, p).uncat
        : 0;
    return build(
      'You spent ${inrWhole(cur.paise)}$on in ${p.label} '
      '(${_count(cur.count, 'payment')}).',
      rows: rows,
      note: [
        if (q.categorySlug != null && q.merchant == null)
          'Refunds in this category are subtracted.',
        if (uncat > 0) '${inrWhole(uncat)} of it isn\'t categorised yet.',
        'Transfers between your own accounts aren\'t counted.',
      ].join(' '),
      search: search,
    );
  }

  AskAnswer _income(
    AskQuery q,
    AskPeriod p,
    InsightsAggregator agg,
    List<InsightTxn> inPeriod,
    _Build build,
  ) {
    final bySource = <String, int>{};
    for (final t in inPeriod) {
      if (t.isDebit) continue;
      final slug = t.isUncategorized ? kUncategorizedSlug : t.categorySlug!;
      if (!kIncomeSlugs.contains(slug) && slug != kUncategorizedSlug) continue;
      bySource[slug] = (bySource[slug] ?? 0) + t.amountPaise;
    }
    if (q.categorySlug != null) {
      final paise = bySource[q.categorySlug] ?? 0;
      final name = _catName(q.categorySlug!);
      return build(
        paise == 0
            ? 'No $name came in during ${p.label}.'
            : '${inrWhole(paise)} of $name came in during ${p.label}.',
        search: _search(q, period: p, debit: false),
      );
    }
    final total = _totals(agg, p).income;
    if (total == 0) {
      return build('No income came in during ${p.label}.');
    }
    final sorted = bySource.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return build(
      'Your income in ${p.label} was ${inrWhole(total)}.',
      rows: [
        for (final e in sorted)
          AskRow(
            e.key == kUncategorizedSlug
                ? 'Other credits (uncategorised)'
                : _catName(e.key),
            paise: e.value,
          ),
      ],
      note: bySource.containsKey(kUncategorizedSlug)
          ? 'Uncategorised credits count as income until you categorise them.'
          : null,
      search: '${_dateFilter(p)} credit',
    );
  }

  AskAnswer _savings(AskPeriod p, InsightsAggregator agg, _Build build) {
    final t = _totals(agg, p);
    final net = t.income - t.spend;
    final rate = t.income > 0 ? (net * 100 / t.income).round() : null;
    final headline = net >= 0
        ? 'You saved ${inrWhole(net)} in ${p.label}'
              '${rate == null ? '' : ' — $rate% of your income'}.'
        : 'You spent ${inrWhole(-net)} more than you earned in ${p.label}.';
    return build(
      headline,
      rows: [
        AskRow('Income', paise: t.income),
        AskRow('Spending', paise: t.spend),
        AskRow('Saved', paise: net, flagged: net < 0),
      ],
      note: 'Money moved into investments counts as spending here.',
    );
  }

  AskAnswer _topCategories(AskPeriod p, InsightsAggregator agg, _Build build) {
    final t = _totals(agg, p);
    final sorted = t.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) {
      return build('You didn\'t spend anything in ${p.label}.');
    }
    final gross = sorted.fold<int>(0, (s, e) => s + e.value);
    return build(
      '${_catName(sorted.first.key)} was your biggest category in '
      '${p.label}: ${inrWhole(sorted.first.value)} of '
      '${inrWhole(t.spend)}.',
      rows: [
        for (final e in sorted.take(8))
          AskRow(
            _catName(e.key),
            paise: e.value,
            detail: gross == 0 ? null : '${(e.value * 100 / gross).round()}%',
          ),
      ],
      search: '${_dateFilter(p)} debit',
    );
  }

  AskAnswer _topMerchants(
    AskQuery q,
    AskPeriod p,
    InsightsAggregator agg,
    _Build build,
  ) {
    final top = agg.topMerchantsWithin(
      p.from,
      p.toExclusive,
      limit: 8,
      categorySlug: q.categorySlug,
    );
    final within = q.categorySlug == null
        ? ''
        : ' on ${_catName(q.categorySlug!)}';
    if (top.isEmpty) {
      return build('You didn\'t spend anything$within in ${p.label}.');
    }
    return build(
      'You spent the most$within at ${top.first.label} in ${p.label}: '
      '${inrWhole(top.first.spendPaise)} '
      '(${_count(top.first.count, 'payment')}).',
      rows: [
        for (final m in top)
          AskRow(
            m.label,
            paise: m.spendPaise,
            detail: _count(m.count, 'payment'),
          ),
      ],
      note: 'Totals are payments before refunds.',
      search: _search(q, period: p, debit: true),
    );
  }

  AskAnswer _largest(
    AskQuery q,
    AskPeriod p,
    List<InsightTxn> inPeriod,
    _Build build,
  ) {
    final hits = [
      for (final t in inPeriod)
        if (t.isDebit &&
            (q.categorySlug == null || _inCategory(t, q.categorySlug!)) &&
            (q.merchant == null || _matchesMerchant(t, q.merchant!)))
          t,
    ]..sort((a, b) => b.amountPaise.compareTo(a.amountPaise));
    if (hits.isEmpty) {
      return build('No matching payments in ${p.label}.');
    }
    final top = hits.first;
    return build(
      'Your largest payment in ${p.label} was ${inrWhole(top.amountPaise)} '
      'to ${top.merchantLabel} on ${longDate(top.bookedAt)}.',
      txns: hits.take(5).toList(),
      search: _search(q, period: p, debit: true),
    );
  }

  Future<AskAnswer> _lastPaid(AskQuery q, _Build build) async {
    final txns = await _repo.search(
      TxnQuery(
        terms: [if (q.merchant != null) q.merchant!],
        category: q.categorySlug,
        isDebit: true,
      ),
      limit: 3,
    );
    final what = q.merchant != null
        ? '"${q.merchant}"'
        : _catName(q.categorySlug ?? '');
    if (txns.isEmpty) {
      return build('I couldn\'t find any payment for $what.');
    }
    final last = txns.first;
    return build(
      'You last paid ${inrWhole(last.amountPaise)} for $what on '
      '${longDate(last.bookedAt)} (${last.merchantLabel}).',
      txns: txns,
      search: _search(q, debit: true),
    );
  }

  Future<AskAnswer> _average(AskQuery q, DateTime now, _Build build) async {
    final current = MonthKey.of(now);
    final withData = (await _repo.availableMonths()).toSet();
    final months = [
      for (var i = q.months; i >= 1; i--)
        if (withData.contains(current.plusMonths(-i))) current.plusMonths(-i),
    ];
    final what = q.merchant != null
        ? ' at "${q.merchant}"'
        : q.categorySlug != null
        ? ' on ${_catName(q.categorySlug!)}'
        : '';
    if (months.isEmpty) {
      return build(
        'I don\'t have any full months of data before '
        '${monthLabel(current.year, current.month)} yet.',
      );
    }
    final agg = await _repo.aggregatorFor(
      current.plusMonths(-1),
      months: q.months,
    );
    int valueFor(MonthKey m) {
      if (q.merchant != null) {
        return agg
            .transactionsIn(m, categorySlug: q.categorySlug)
            .where((t) => t.isDebit && _matchesMerchant(t, q.merchant!))
            .fold(0, (s, t) => s + t.amountPaise);
      }
      final s = agg.summarize(m);
      return q.categorySlug == null
          ? s.spendPaise
          : s.byCategory[q.categorySlug] ?? 0;
    }

    final values = {for (final m in months) m: valueFor(m)};
    final avg = values.values.fold(0, (s, v) => s + v) ~/ months.length;
    final span = months.length == 1
        ? monthLabel(months.first.year, months.first.month)
        : '${monthLabel(months.first.year, months.first.month)} – '
              '${monthLabel(months.last.year, months.last.month)}';
    return build(
      'On average you spend ${inrWhole(avg)} a month$what '
      '(${_count(months.length, 'full month')}, $span).',
      rows: [
        for (final e in values.entries.toList().reversed)
          AskRow(monthLabel(e.key.year, e.key.month), paise: e.value),
      ],
      note: months.length < q.months
          ? 'Only ${months.length} of the last ${q.months} months have data.'
          : null,
    );
  }

  Future<AskAnswer> _netWorth(DateTime now, _Build build) async {
    final nw = await NetWorthRepository(_db).netWorth(now);
    if (nw.isEmpty) {
      return build(
        'I don\'t know any balances yet.',
        note: 'Import a bank statement or add assets under Net worth.',
      );
    }
    return build(
      'Your net worth is ${inrWhole(nw.totalPaise)}.',
      rows: [
        for (final e in nw.byGroup.entries)
          AskRow(
            e.key.label,
            paise: e.key.isLiability ? -e.value : e.value,
            flagged: e.key.isLiability,
          ),
      ],
      note: 'Bank balances are from your latest statements or SMS.',
    );
  }

  Future<AskAnswer> _budgets(DateTime now, _Build build) async {
    final defs = await BudgetRepository(_db).list();
    if (defs.isEmpty) {
      return build(
        'You haven\'t set any budgets yet.',
        note: 'Add them from Insights → Budgets.',
      );
    }
    final month = MonthKey.of(now);
    final progress = const BudgetCalculator().compute(
      await _repo.aggregatorFor(month),
      month,
      defs,
      await _categoryNames(),
      asOf: now,
    );
    int count(BudgetStatus s) => progress.where((b) => b.status == s).length;
    final over = count(BudgetStatus.over);
    final close = count(BudgetStatus.warning);
    final ok = count(BudgetStatus.ok);
    final parts = [
      if (over > 0) '$over over budget',
      if (close > 0) '$close close to the limit',
      if (ok > 0) '$ok on track',
    ].join(', ');
    return build(
      '${parts[0].toUpperCase()}${parts.substring(1)} '
      'in ${monthLabel(month.year, month.month)} so far.',
      rows: [
        for (final b in progress)
          AskRow(
            b.name,
            paise: b.remainingPaise,
            detail:
                '${inrWhole(b.spentPaise)} of ${inrWhole(b.availablePaise)}'
                '${b.remainingPaise < 0 ? ' · over' : ' · left'}',
            flagged: b.status == BudgetStatus.over,
          ),
      ],
    );
  }

  Future<AskAnswer> _upcoming(AskQuery q, DateTime now, _Build build) async {
    final today = DateTime(now.year, now.month, now.day);
    final events = await UpcomingRepository(_db).events(today, days: q.days);
    if (events.isEmpty) {
      return build('Nothing I know of is due in the next ${q.days} days.');
    }
    final total = events.fold<int>(0, (s, e) => s + e.amountPaise);
    final overdue = events.where((e) => e.overdue).length;
    return build(
      '${_count(events.length, 'payment')} totalling ${inrWhole(total)} '
      '${events.length == 1 ? 'is' : 'are'} due in the next ${q.days} days'
      '${overdue > 0 ? ', $overdue overdue' : ''}.',
      rows: [
        for (final e in events)
          AskRow(
            e.label,
            paise: e.amountPaise,
            detail:
                '${e.overdue ? 'Overdue · ' : ''}${longDate(e.date)}'
                ' · ${e.kind.label}${e.estimated ? ' (estimated)' : ''}',
            flagged: e.overdue,
          ),
      ],
      note: events.any((e) => e.estimated)
          ? 'Estimated dates are predicted from past payments.'
          : null,
    );
  }
}

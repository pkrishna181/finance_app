import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import 'category_transactions_screen.dart';

/// Categorical chart colors (Okabe-Ito inspired); grey is reserved for
/// "Uncategorized" / "Other".
const _kSliceColors = <Color>[
  Color(0xFF0B6E4F),
  Color(0xFF3B6FB6),
  Color(0xFFE08A1E),
  Color(0xFF8E5BB5),
  Color(0xFFD1495B),
  Color(0xFF2AA7A0),
];

Color sliceColor(BuildContext context, CategorySlice s, int index) {
  if (s.isOther || s.slug == kUncategorizedSlug) {
    return Theme.of(context).colorScheme.outline;
  }
  return _kSliceColors[index % _kSliceColors.length];
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, this.database, this.reloadToken = 0});

  final ArthDatabase? database;

  /// Bump to force a reload (e.g. when the tab is re-selected after an import).
  final int reloadToken;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<MonthKey> _months = const [];
  MonthKey? _selected;
  InsightsSnapshot? _snapshot;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(InsightsScreen old) {
    super.didUpdateWidget(old);
    if (old.database != widget.database ||
        old.reloadToken != widget.reloadToken) {
      _load();
    }
  }

  Future<void> _load({MonthKey? month}) async {
    final db = widget.database;
    if (db == null) {
      if (_loading) setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = InsightsRepository(db);
      final months = await repo.availableMonths();
      if (!mounted) return;
      if (months.isEmpty) {
        setState(() {
          _months = const [];
          _selected = null;
          _snapshot = null;
          _loading = false;
        });
        return;
      }
      final want = month ?? _selected;
      final selected = want != null && months.contains(want) ? want : months.first;
      final agg = await repo.aggregatorFor(selected);
      final names = await repo.categoryNames();
      if (!mounted) return;
      setState(() {
        _months = months;
        _selected = selected;
        _snapshot = InsightsSnapshot.build(agg, selected, names);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _step(int delta) {
    final i = _months.indexOf(_selected!);
    // _months is newest first: older month = higher index.
    final j = i + delta;
    if (j < 0 || j >= _months.length) return;
    _load(month: _months[j]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (widget.database == null) {
      return const _Message('Opening your data…');
    }
    if (_error != null) {
      return _Message(
        'Could not load insights.',
        action: TextButton(onPressed: _load, child: const Text('Retry')),
      );
    }
    if (_loading && _snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final snap = _snapshot;
    if (snap == null) {
      return const _Message(
        'No transactions yet.\nImport a statement or scan SMS to see insights.',
      );
    }
    final i = _months.indexOf(snap.month);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _MonthSelector(
            month: snap.month,
            canGoOlder: i < _months.length - 1,
            canGoNewer: i > 0,
            onOlder: () => _step(1),
            onNewer: () => _step(-1),
          ),
          const SizedBox(height: 8),
          if (snap.isEmpty)
            const _Message('Nothing recorded this month.')
          else ...[
            _SummaryTiles(snapshot: snap),
            if (snap.summary.uncategorizedCount > 0) ...[
              const SizedBox(height: 12),
              _UncategorizedBanner(snapshot: snap),
            ],
            const SizedBox(height: 12),
            _CategoryCard(snapshot: snap),
            const SizedBox(height: 12),
            _TrendCard(snapshot: snap),
            const SizedBox(height: 12),
            _MerchantsCard(snapshot: snap),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.action});
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.canGoOlder,
    required this.canGoNewer,
    required this.onOlder,
    required this.onNewer,
  });

  final MonthKey month;
  final bool canGoOlder;
  final bool canGoNewer;
  final VoidCallback onOlder;
  final VoidCallback onNewer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoOlder ? onOlder : null,
        ),
        Text(
          monthLabel(month.year, month.month),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNewer ? onNewer : null,
        ),
      ],
    );
  }
}

class _SummaryTiles extends StatelessWidget {
  const _SummaryTiles({required this.snapshot});
  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final s = snapshot.summary;
    final rate = s.savingsRate;
    final delta = snapshot.spendDelta;
    String? deltaText;
    if (delta.pct != null) {
      final pct = (delta.pct! * 100).round();
      deltaText = '${pct >= 0 ? '+' : ''}$pct% vs last month';
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.1,
      children: [
        _Tile(label: 'Income', value: inrWhole(s.incomePaise)),
        _Tile(
          label: 'Spend',
          value: inrWhole(s.spendPaise),
          footnote: deltaText,
        ),
        _Tile(label: 'Net', value: inrWhole(s.netPaise)),
        _Tile(
          label: 'Savings rate',
          value: rate == null ? '—' : '${(rate * 100).round()}%',
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, this.footnote});
  final String label;
  final String value;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: t.labelMedium),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: t.titleLarge),
            ),
            if (footnote != null) Text(footnote!, style: t.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _UncategorizedBanner extends StatelessWidget {
  const _UncategorizedBanner({required this.snapshot});
  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final s = snapshot.summary;
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: ListTile(
        leading: const Icon(Icons.help_outline),
        title: Text('${s.uncategorizedCount} uncategorized '
            '(${inrWhole(s.uncategorizedPaise)})'),
        subtitle: const Text('Totals above include them as-is.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CategoryTransactionsScreen(
              title: 'Uncategorized',
              txns: snapshot.aggregator.transactionsIn(
                snapshot.month,
                categorySlug: kUncategorizedSlug,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.snapshot});
  final InsightsSnapshot snapshot;

  void _open(BuildContext context, CategorySlice slice) {
    final agg = snapshot.aggregator;
    final month = snapshot.month;
    final List<InsightTxn> txns;
    if (slice.isOther) {
      final shown = {
        for (final s in snapshot.slices)
          if (!s.isOther) s.slug,
      };
      txns = agg
          .transactionsIn(month)
          .where((t) => !shown.contains(t.categorySlug ?? kUncategorizedSlug))
          .toList();
    } else {
      txns = agg.transactionsIn(month, categorySlug: slice.slug);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryTransactionsScreen(
          title: slice.name,
          txns: txns,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slices = snapshot.slices;
    final t = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending by category', style: t.titleMedium),
            const SizedBox(height: 12),
            if (slices.isEmpty)
              const Text('No spending this month.')
            else ...[
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 62,
                        sections: [
                          for (var i = 0; i < slices.length; i++)
                            PieChartSectionData(
                              value: slices[i].paise.toDouble(),
                              color: sliceColor(context, slices[i], i),
                              radius: 28,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Spent', style: t.labelMedium),
                        Text(
                          inrCompact(snapshot.summary.spendPaise),
                          style: t.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < slices.length; i++)
                InkWell(
                  onTap: () => _open(context, slices[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: sliceColor(context, slices[i], i),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(slices[i].name)),
                        Text(
                          '${(slices[i].fraction * 100).round()}%',
                          style: t.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Text(inrWhole(slices[i].paise)),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.snapshot});
  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final trend = snapshot.trend;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final maxY = trend
        .map((m) => m.spendPaise)
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();
    final summary = 'Monthly spend, last ${trend.length} months: ' +
        trend
            .map((m) => '${monthShort(m.month.month)} '
                '${inrCompact(m.spendPaise)}')
            .join(', ');
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spend trend', style: t.titleMedium),
            const SizedBox(height: 12),
            Semantics(
              label: summary,
              child: ExcludeSemantics(
                child: SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY == 0 ? 1 : maxY * 1.15,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final m = trend[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  children: [
                                    Text(
                                      inrCompact(m.spendPaise),
                                      style: t.labelSmall,
                                    ),
                                    Text(
                                      monthShort(m.month.month),
                                      style: t.labelSmall,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < trend.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: trend[i].spendPaise
                                    .clamp(0, 1 << 62)
                                    .toDouble(),
                                width: 22,
                                borderRadius: BorderRadius.circular(4),
                                color: trend[i].month == snapshot.month
                                    ? scheme.primary
                                    : scheme.primary.withValues(alpha: 0.35),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantsCard extends StatelessWidget {
  const _MerchantsCard({required this.snapshot});
  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final merchants = snapshot.merchants;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top merchants', style: t.titleMedium),
            const SizedBox(height: 8),
            if (merchants.isEmpty)
              const Text('No spending this month.')
            else
              for (final m in merchants)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(m.label, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text('${m.count} transaction'
                      '${m.count == 1 ? '' : 's'}'),
                  trailing: Text(inrWhole(m.spendPaise)),
                ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import '../theme/chart_colors.dart';

/// Financial-year view: totals, where the income went, a daily spending
/// heatmap and the income statement. Pops with a [MonthKey] when the user taps
/// a month row.
class YearlyScreen extends StatefulWidget {
  const YearlyScreen({super.key, required this.database, this.initial});

  final ArthDatabase database;
  final FinancialYear? initial;

  @override
  State<YearlyScreen> createState() => _YearlyScreenState();
}

class _YearlyScreenState extends State<YearlyScreen> {
  List<FinancialYear> _years = const [];
  FinancialYear? _selected;
  YearSummary? _summary;
  Map<String, String> _names = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(widget.initial);
  }

  Future<void> _load(FinancialYear? want) async {
    setState(() => _loading = true);
    final repo = InsightsRepository(widget.database);
    final years = await repo.availableYears();
    if (years.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final fy = want != null && years.contains(want) ? want : years.first;
    final agg = await repo.yearAggregator(fy);
    final names = await repo.categoryNames();
    if (!mounted) return;
    setState(() {
      _years = years;
      _selected = fy;
      _summary = YearSummary.build(agg, fy);
      _names = names;
      _loading = false;
    });
  }

  String _nameOf(String slug) => switch (slug) {
    kOtherIncomeSlug => 'Other credits',
    kUncategorizedSlug => 'Uncategorized',
    _ => _names[slug] ?? slug,
  };

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    final fy = _selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Year in review')),
      body: _loading && s == null
          ? const Center(child: CircularProgressIndicator())
          : s == null || fy == null
          ? const Center(child: Text('No transactions yet.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _YearSelector(
                  year: fy,
                  canGoOlder: _years.contains(fy.previous),
                  canGoNewer: _years.contains(fy.next),
                  onOlder: () => _load(fy.previous),
                  onNewer: () => _load(fy.next),
                ),
                const SizedBox(height: 8),
                if (s.isEmpty)
                  const Text('Nothing recorded this year.')
                else ...[
                  _Totals(summary: s),
                  const SizedBox(height: 12),
                  _WhereItWent(summary: s, nameOf: _nameOf),
                  const SizedBox(height: 12),
                  _HeatmapCard(summary: s),
                  const SizedBox(height: 12),
                  _IncomeStatement(summary: s, nameOf: _nameOf),
                  const SizedBox(height: 12),
                  _MonthTable(
                    summary: s,
                    onMonth: (m) => Navigator.of(context).pop(m),
                  ),
                ],
              ],
            ),
    );
  }
}

class _YearSelector extends StatelessWidget {
  const _YearSelector({
    required this.year,
    required this.canGoOlder,
    required this.canGoNewer,
    required this.onOlder,
    required this.onNewer,
  });

  final FinancialYear year;
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
          tooltip: 'Previous year',
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoOlder ? onOlder : null,
        ),
        Text(year.label, style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: 'Next year',
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNewer ? onNewer : null,
        ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.summary});
  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final rate = s.savingsRate;
    Widget tile(String label, String value) => Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            tile('Income', inrWhole(s.incomePaise)),
            const SizedBox(width: 8),
            tile('Spend', inrWhole(s.spendPaise)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            tile('Saved', inrWhole(s.netPaise)),
            const SizedBox(width: 8),
            tile(
              'Savings rate',
              rate == null ? '—' : '${(rate * 100).round()}%',
            ),
          ],
        ),
      ],
    );
  }
}

/// One stacked bar: spend by category as a share of income; the unfilled
/// remainder is what was saved. Legend doubles as the data table.
class _WhereItWent extends StatelessWidget {
  const _WhereItWent({required this.summary, required this.nameOf});
  final YearSummary summary;
  final String Function(String) nameOf;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = summary;
    final cats = s.spendByCategory.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    // Top 5 named slices (uncategorized stays neutral), rest folded to Other.
    final shown = <({String label, int paise, Color color})>[];
    var other = 0;
    var slot = 0;
    for (final e in cats) {
      if (e.key == kUncategorizedSlug) {
        other += e.value;
      } else if (slot < kCategoricalSlots - 1) {
        shown.add((
          label: nameOf(e.key),
          paise: e.value,
          color: categoricalColor(context, slot++),
        ));
      } else {
        other += e.value;
      }
    }
    if (other > 0) {
      shown.add((
        label: 'Other',
        paise: other,
        color: neutralSeriesColor(context),
      ));
    }
    final spend = shown.fold<int>(0, (a, x) => a + x.paise);
    final scale = s.incomePaise > spend ? s.incomePaise : spend;
    final saved = s.incomePaise - spend;
    String pct(int p) =>
        s.incomePaise <= 0 ? '' : ' · ${(p * 100 / s.incomePaise).round()}%';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where the income went', style: t.titleMedium),
            const SizedBox(height: 12),
            Semantics(
              label:
                  'Spent ${inrWhole(spend)} of ${inrWhole(s.incomePaise)} '
                  'income; ${saved >= 0 ? 'saved ${inrWhole(saved)}' : 'overspent ${inrWhole(-saved)}'}',
              excludeSemantics: true,
              child: SizedBox(
                height: 16,
                child: scale <= 0
                    ? const SizedBox.shrink()
                    : _StackedBar(
                        segments: [
                          for (final x in shown) (x.paise / scale, x.color),
                        ],
                        track: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            for (final x in shown)
              _LegendRow(
                color: x.color,
                label: x.label,
                value: '${inrWhole(x.paise)}${pct(x.paise)}',
              ),
            _LegendRow(
              color: null,
              label: saved >= 0 ? 'Saved' : 'Spent beyond income',
              value: '${inrWhole(saved.abs())}${pct(saved.abs())}',
            ),
          ],
        ),
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.segments, required this.track});

  /// (fraction of full width, color), in order.
  final List<(double, Color)> segments;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 2.0;
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: track,
            child: Row(
              children: [
                for (final (i, (f, color)) in segments.indexed)
                  Container(
                    width: (c.maxWidth * f - (i == 0 ? 0 : gap)).clamp(
                      0,
                      c.maxWidth,
                    ),
                    margin: EdgeInsets.only(left: i == 0 ? 0 : gap),
                    color: color,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  /// Null = outlined swatch (unfilled remainder).
  final Color? color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: color == null
                  ? Border.all(color: Theme.of(context).colorScheme.outline)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(value, style: t.bodySmall),
        ],
      ),
    );
  }
}

/// Daily spend: one row per month (Apr → Mar), one cell per day. Tap a cell
/// to read its value.
class _HeatmapCard extends StatefulWidget {
  const _HeatmapCard({required this.summary});
  final YearSummary summary;

  @override
  State<_HeatmapCard> createState() => _HeatmapCardState();
}

class _HeatmapCardState extends State<_HeatmapCard> {
  DateTime? _picked;

  static const _labelWidth = 32.0;
  static const _rowHeight = 14.0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = widget.summary;
    final thresholds = quantileThresholds(
      s.dailySpend.values,
      buckets: kSequentialLevels,
    );
    final months = s.year.months;
    final spendDays = s.dailySpend.length;
    MapEntry<DateTime, int>? top;
    for (final e in s.dailySpend.entries) {
      if (top == null || e.value > top.value) top = e;
    }
    final picked = _picked;
    String dayLabel(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily spending', style: t.titleMedium),
            const SizedBox(height: 4),
            Text(
              picked == null
                  ? 'Tap a day to see what was spent.'
                  : '${dayLabel(picked)}: '
                        '${inrWhole(s.dailySpend[picked] ?? 0)}',
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            Semantics(
              label:
                  'Spending on $spendDays days this year'
                  '${top == null ? '' : '; highest ${inrWhole(top.value)} on ${dayLabel(top.key)}'}',
              excludeSemantics: true,
              child: LayoutBuilder(
                builder: (context, c) {
                  final cell = (c.maxWidth - _labelWidth) / 31;
                  Color colorFor(DateTime d) => sequentialColor(
                    context,
                    intensityLevel(s.dailySpend[d] ?? 0, thresholds),
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (e) {
                      final row = (e.localPosition.dy / _rowHeight).floor();
                      final col = ((e.localPosition.dx - _labelWidth) / cell)
                          .floor();
                      if (row < 0 || row >= 12 || col < 0 || col >= 31) return;
                      final m = months[row];
                      final days = DateTime(m.year, m.month + 1, 0).day;
                      if (col >= days) return;
                      setState(
                        () => _picked = DateTime(m.year, m.month, col + 1),
                      );
                    },
                    child: CustomPaint(
                      size: Size(c.maxWidth, _rowHeight * 12),
                      painter: _HeatmapPainter(
                        months: months,
                        labelWidth: _labelWidth,
                        rowHeight: _rowHeight,
                        cell: cell,
                        colorFor: colorFor,
                        picked: picked,
                        pickedColor: Theme.of(context).colorScheme.onSurface,
                        labelStyle: t.labelSmall!,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Less', style: t.labelSmall),
                for (var l = 0; l <= kSequentialLevels; l++)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: sequentialColor(context, l),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Text('More', style: t.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.months,
    required this.labelWidth,
    required this.rowHeight,
    required this.cell,
    required this.colorFor,
    required this.picked,
    required this.pickedColor,
    required this.labelStyle,
  });

  final List<MonthKey> months;
  final double labelWidth;
  final double rowHeight;
  final double cell;
  final Color Function(DateTime) colorFor;
  final DateTime? picked;
  final Color pickedColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 2.0;
    final paint = Paint();
    for (var r = 0; r < months.length; r++) {
      final m = months[r];
      final y = r * rowHeight;
      final tp = TextPainter(
        text: TextSpan(text: monthShort(m.month), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y + (rowHeight - tp.height) / 2));
      final days = DateTime(m.year, m.month + 1, 0).day;
      for (var d = 1; d <= days; d++) {
        final date = DateTime(m.year, m.month, d);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            labelWidth + (d - 1) * cell,
            y + gap / 2,
            cell - gap,
            rowHeight - gap,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, paint..color = colorFor(date));
        if (date == picked) {
          canvas.drawRRect(
            rect,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = pickedColor,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.picked != picked || old.months != months || old.cell != cell;
}

class _IncomeStatement extends StatelessWidget {
  const _IncomeStatement({required this.summary, required this.nameOf});
  final YearSummary summary;
  final String Function(String) nameOf;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = summary;
    List<MapEntry<String, int>> sorted(Map<String, int> m) =>
        m.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    Widget line(String label, int paise, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? t.titleSmall : null,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(inrWhole(paise), style: bold ? t.titleSmall : null),
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Income statement', style: t.titleMedium),
            const SizedBox(height: 8),
            Text('Income', style: t.labelLarge),
            for (final e in sorted(s.incomeBySource))
              line(nameOf(e.key), e.value),
            line('Total income', s.incomePaise, bold: true),
            const Divider(),
            Text('Spending', style: t.labelLarge),
            for (final e in sorted(s.spendByCategory))
              line(nameOf(e.key), e.value),
            line('Total spending', s.spendPaise, bold: true),
            const Divider(),
            line(
              s.netPaise >= 0 ? 'Net saved' : 'Net overspent',
              s.netPaise.abs(),
              bold: true,
            ),
            const SizedBox(height: 4),
            Text(
              'Transfers between your own accounts are excluded. Refunds '
              'reduce their category.',
              style: t.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthTable extends StatelessWidget {
  const _MonthTable({required this.summary, required this.onMonth});
  final YearSummary summary;
  final ValueChanged<MonthKey> onMonth;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget cell(String s, {TextStyle? style, bool end = true}) => Expanded(
      child: Text(
        s,
        textAlign: end ? TextAlign.end : TextAlign.start,
        style: style,
      ),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Month by month', style: t.titleMedium),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  cell('Month', style: t.labelMedium, end: false),
                  cell('Income', style: t.labelMedium),
                  cell('Spend', style: t.labelMedium),
                  cell('Net', style: t.labelMedium),
                ],
              ),
            ),
            for (final m in summary.months)
              InkWell(
                onTap: m.txnCount == 0 ? null : () => onMonth(m.month),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      cell(monthLabel(m.month.year, m.month.month), end: false),
                      cell(inrCompact(m.incomePaise)),
                      cell(inrCompact(m.spendPaise)),
                      cell(inrCompact(m.incomePaise - m.spendPaise)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

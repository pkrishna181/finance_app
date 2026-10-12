import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

String _d(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';

/// Capital gains by financial year with set-off, the equity exemption and an
/// estimated tax, plus each fund's tax category (editable).
class CapitalGainsScreen extends StatefulWidget {
  const CapitalGainsScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<CapitalGainsScreen> createState() => _CapitalGainsScreenState();
}

class _CapitalGainsScreenState extends State<CapitalGainsScreen> {
  late final _repo = CapitalGainsRepository(widget.database);
  List<FyGains>? _years;
  Map<int, TaxCategoryView> _cats = const {};
  List<HarvestIdea> _ideas = const [];
  int _index = 0;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var years = await _repo.byYear(_now);
    final cats = await _repo.categories();
    final ideas = await _repo.harvestIdeas(_now);
    // Always show the current year (for planning), even without sales.
    final current = FinancialYear.of(_now);
    if (!years.any((y) => y.fy == current)) {
      years = [FyGains(current), ...years];
    }
    if (!mounted) return;
    setState(() {
      _years = years;
      _cats = cats;
      _ideas = ideas;
      _index = _index.clamp(0, years.length - 1);
    });
  }

  Future<void> _editCategory(TaxCategoryView v) async {
    final picked = await showDialog<Object>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(v.name, maxLines: 3, overflow: TextOverflow.ellipsis),
        children: [
          for (final c in TaxCategory.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(c),
              child: Row(
                children: [
                  Expanded(child: Text(c.label)),
                  if (c == v.category) const Icon(Icons.check, size: 18),
                ],
              ),
            ),
          if (v.isOverride)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop('reset'),
              child: const Text('Use Arth\'s guess'),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await _repo.setCategory(
        v.securityId, picked is TaxCategory ? picked : null);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final years = _years;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Capital gains')),
      body: years == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Older year',
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _index < years.length - 1
                          ? () => setState(() => _index++)
                          : null,
                    ),
                    Text(years[_index].fy.label, style: t.titleMedium),
                    IconButton(
                      tooltip: 'Newer year',
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          _index > 0 ? () => setState(() => _index--) : null,
                    ),
                  ],
                ),
                _YearCard(gains: years[_index]),
                const SizedBox(height: 16),
                if (years[_index].fy == FinancialYear.of(_now)) ...[
                  _HarvestSection(ideas: _ideas),
                  const SizedBox(height: 16),
                ],
                if (years[_index].legs.isNotEmpty) ...[
                  Text('Sales', style: t.titleSmall),
                  for (final l in years[_index].legs) _LegTile(leg: l),
                  const SizedBox(height: 16),
                ],
                Text('Fund categories', style: t.titleSmall),
                Text(
                  'Tax depends on the fund type. Arth guesses from the name — '
                  'tap to correct it.',
                  style: t.bodySmall,
                ),
                for (final v in _cats.values.toList()
                  ..sort((a, b) => a.name.compareTo(b.name)))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(v.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${v.category.label}${v.isOverride ? '' : ' (guessed)'}'),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => _editCategory(v),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Estimate only — not tax advice. Uses the rules for each '
                  'year (Budget 2024 rates from FY 2024-25: 20% short-term '
                  'and 12.5% long-term equity with ₹1.25 lakh exempt). Leaves '
                  'out cess and surcharge, losses brought forward from '
                  'earlier years, indexation on sales before 23 Jul 2024, and '
                  'exit loads. Check with a tax professional before filing.',
                  style: t.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _YearCard extends StatelessWidget {
  const _YearCard({required this.gains});
  final FyGains gains;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final y = gains;
    final tax = const CapitalGainsCalculator().tax(y);
    final gross = y.gross;
    String signed(int p) => '${p < 0 ? '−' : ''}${inrWhole(p.abs())}';
    Widget row(String k, String v, {bool bold = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(k, style: bold ? t.titleSmall : null)),
              Text(v,
                  style: (bold ? t.titleSmall : t.bodyMedium)
                      ?.copyWith(color: color)),
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
            if (y.legs.isEmpty)
              Text('No sales recorded this year.', style: t.bodyMedium)
            else ...[
              for (final k in GainKind.values)
                if (gross[k] != 0) row(k.label, signed(gross[k]!)),
              const Divider(),
              row('Equity LTCG exemption used',
                  '${inrWhole(tax.exemptionUsedPaise)} of '
                      '${inrWhole(tax.exemptionUsedPaise + tax.exemptionLeftPaise)}'),
              if (tax.slabGainPaise > 0)
                row('Added to income (slab rate)',
                    inrWhole(tax.slabGainPaise)),
              if (tax.lossCarriedPaise > 0)
                row('Loss to carry forward', inrWhole(tax.lossCarriedPaise)),
              row('Estimated tax', inrWhole(tax.taxPaise),
                  bold: true, color: scheme.error),
              if (y.hasEstimates)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Some sales used units bought before your first statement '
                    'or before 2018 without a 31 Jan 2018 price, so their '
                    'cost is estimated. Import an older CAS (from your first '
                    'investment) for exact figures.',
                    style: t.bodySmall,
                  ),
                ),
            ],
            if (y.legs.isEmpty || tax.exemptionLeftPaise > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${inrWhole(tax.exemptionLeftPaise)} of long-term equity '
                  'gains can still be booked tax-free this year.',
                  style: t.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HarvestSection extends StatelessWidget {
  const _HarvestSection({required this.ideas});
  final List<HarvestIdea> ideas;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gains = ideas.where((i) => i.kind == HarvestKind.exemptGain).toList();
    final losses = ideas.where((i) => i.kind == HarvestKind.loss).toList();
    String units(int e4) => (e4 / 1e4).toStringAsFixed(3);
    Widget tile(HarvestIdea i, String what) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(i.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            'Sell ${units(i.unitsE4)} units (~${inrWhole(i.saleValuePaise)}) '
            'from ${i.accountLabel} → $what'
            '${i.costEstimated ? ' · cost estimated' : ''}',
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Save tax this year', style: t.titleSmall),
        if (ideas.isEmpty)
          Text(
            'Nothing to harvest right now: no long-term equity gains to book '
            'within the exemption, and no losses that would cut this year\'s '
            'tax.',
            style: t.bodySmall,
          ),
        if (gains.isNotEmpty) ...[
          Text(
            'Book long-term gains tax-free (within the ₹1.25 lakh exemption), '
            'then buy back to raise your cost:',
            style: t.bodySmall,
          ),
          for (final i in gains)
            tile(i, '${inrWhole(i.gainPaise)} gain, no tax'),
        ],
        if (losses.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Book losses to offset this year\'s taxable gains:',
              style: t.bodySmall),
          for (final i in losses)
            tile(
              i,
              '${inrWhole(-i.gainPaise)} ${i.longTerm ? 'long' : 'short'}-term '
              'loss, saves ~${inrWhole(i.taxSavedPaise)}',
            ),
        ],
        if (ideas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Units are sold oldest first. Check exit loads and the bid-ask '
              'cost before selling; India has no wash-sale rule, so buying '
              'back the same day is allowed. ELSS units in their 3-year '
              'lock-in are excluded.',
              style: t.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _LegTile extends StatelessWidget {
  const _LegTile({required this.leg});
  final SaleLeg leg;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l = leg;
    final g = l.gainPaise;
    final notes = [
      if (l.costEstimated) 'cost estimated',
      if (l.grandfathered) 'grandfathered to 31 Jan 2018 price',
      if (l.grandfatheringMissing) '31 Jan 2018 price unknown',
    ];
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(l.securityName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${l.kind.label} · bought ${_d(l.bought)}, sold ${_d(l.sold)}'
        '${notes.isEmpty ? '' : ' · ${notes.join(', ')}'}',
      ),
      trailing: Text(
        '${g < 0 ? '−' : '+'}${inrWhole(g.abs())}',
        style: t.bodyMedium?.copyWith(
          color: g < 0 ? scheme.error : scheme.primary,
        ),
      ),
    );
  }
}

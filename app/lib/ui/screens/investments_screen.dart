import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import '../../ingestion/investments/amfi_nav.dart';
import '../theme/chart_colors.dart';
import '../widgets/price_feed_opt_in.dart';
import 'capital_gains_screen.dart';

String _pct(double f) {
  final v = f * 100;
  final s = v.abs() >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  return '${v >= 0 ? '+' : ''}$s%';
}

String _units(int e4) {
  final s = (e4 / 1e4).toStringAsFixed(3);
  return s.endsWith('.000') ? s.substring(0, s.length - 4) : s;
}

/// Mutual funds and shares from imported CAS statements: value, invested,
/// gain and XIRR, overall and per holding.
class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({
    super.key,
    required this.database,
    this.now,
    this.updater,
  });

  final ArthDatabase database;
  final DateTime? now;

  /// Price updater override (tests).
  final AmfiNavUpdater? updater;

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  PortfolioSummary? _s;
  bool _updating = false;
  late final _updater = widget.updater ?? AmfiNavUpdater(widget.database);

  @override
  void initState() {
    super.initState();
    _load();
    _autoUpdate();
  }

  /// Once a day when the user opted in; silent on failure.
  Future<void> _autoUpdate() async {
    final r = await _updater.updateIfStale();
    if (r != null && r.isOk && mounted) await _load();
  }

  Future<void> _updatePrices() async {
    if (!await PriceFeedSettings().isEnabled()) {
      if (!mounted || !await showPriceFeedOptIn(context)) return;
    }
    setState(() => _updating = true);
    final r = await _updater.update();
    if (!mounted) return;
    setState(() => _updating = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r.isOk
          ? 'Updated ${r.okOrNull} fund price${r.okOrNull == 1 ? '' : 's'}'
          : 'Couldn\'t reach AMFI — try again later'),
    ));
    if (r.isOk) await _load();
  }

  Future<void> _load() async {
    final s = await PortfolioRepository(
      widget.database,
    ).summary(widget.now ?? DateTime.now());
    if (mounted) setState(() => _s = s);
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        actions: [
          IconButton(
            tooltip: 'Update fund prices',
            icon: _updating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _updating ? null : _updatePrices,
          ),
        ],
      ),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : s.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Import your Consolidated Account Statement (CAS) to see '
                'your mutual funds and shares here. Request it from CAMS '
                '(camsonline.com) or KFintech for mutual funds, and NSDL or '
                'CDSL for demat holdings — it arrives as a password-'
                'protected PDF by email. Then use Import → Statements.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  PortfolioSummaryCard(summary: s),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Capital gains & tax'),
                    subtitle: const Text('Gains by year, exemption left, estimated tax'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CapitalGainsScreen(
                          database: widget.database,
                          now: widget.now,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final p in s.positions)
                    _PositionTile(
                      position: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _PositionScreen(
                            database: widget.database,
                            position: p,
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

/// Value, invested, gain, XIRR and the split by kind.
class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({super.key, required this.summary, this.onTap});

  final PortfolioSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = summary;
    final gain = s.gainPaise;
    final gainColor = gain >= 0 ? scheme.primary : scheme.error;
    final kinds = s.byKind.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    String kindName(String k) => switch (k) {
      'mf' => 'Mutual funds',
      'equity' => 'Shares',
      _ => 'Other',
    };
    final total = s.valuePaise;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Investments', style: t.titleMedium),
              const SizedBox(height: 4),
              Text(inrWhole(total), style: t.headlineSmall),
              if (s.investedPaise > 0)
                Text(
                  '${gain >= 0 ? '+' : '-'}${inrWhole(gain.abs())} on '
                  '${inrWhole(s.investedPaise)} invested'
                  '${s.xirr == null ? '' : ' · XIRR ${_pct(s.xirr!)}'}',
                  style: t.bodyMedium?.copyWith(color: gainColor),
                ),
              if (s.realisedPaise != 0)
                Text(
                  'Booked ${s.realisedPaise >= 0 ? 'gains' : 'losses'}: '
                  '${inrWhole(s.realisedPaise.abs())}',
                  style: t.bodySmall,
                ),
              if (kinds.length > 1 && total > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: [
                        for (final (i, e) in kinds.indexed)
                          Expanded(
                            flex: (e.value * 1000 ~/ total).clamp(1, 1000),
                            child: Container(
                              margin: EdgeInsets.only(left: i == 0 ? 0 : 2),
                              color: categoricalColor(context, i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                for (final (i, e) in kinds.indexed)
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: categoricalColor(context, i),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(kindName(e.key))),
                      Text(
                        '${inrWhole(e.value)} · '
                        '${(e.value * 100 / total).round()}%',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({required this.position, required this.onTap});
  final Position position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = position;
    final g = p.gainFraction;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(p.input.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          p.input.accountLabel,
          if (p.xirr != null) 'XIRR ${_pct(p.xirr!)}',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(inrWhole(p.valuePaise)),
          if (g != null)
            Text(
              _pct(g),
              style: t.bodySmall?.copyWith(
                color: g >= 0 ? scheme.primary : scheme.error,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _PositionScreen extends StatelessWidget {
  const _PositionScreen({required this.database, required this.position});
  final ArthDatabase database;
  final Position position;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = position;
    final i = p.input;
    String date(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';
    final facts = <(String, String)>[
      ('Units', _units(p.unitsE4)),
      if (i.priceE4 != null)
        (
          'Price',
          '₹${(i.priceE4! / 1e4).toStringAsFixed(4)}'
              '${i.priceDate == null ? '' : ' on ${date(i.priceDate!)}'}',
        ),
      ('Value', inrWhole(p.valuePaise)),
      if (p.investedPaise != null) ('Invested', inrWhole(p.investedPaise!)),
      if (p.gainPaise != null)
        (
          'Gain',
          '${p.gainPaise! >= 0 ? '+' : '-'}${inrWhole(p.gainPaise!.abs())}'
              '${p.gainFraction == null ? '' : ' (${_pct(p.gainFraction!)})'}',
        ),
      if (p.realisedPaise != 0) ('Booked', inrWhole(p.realisedPaise)),
      if (p.dividendsPaise != 0) ('Dividends', inrWhole(p.dividendsPaise)),
      if (p.xirr != null) ('XIRR', _pct(p.xirr!)),
      if (i.isin != null) ('ISIN', i.isin!),
      ('Account', i.accountLabel),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Holding')),
      body: FutureBuilder<List<InvestmentTxn>>(
        future: PortfolioRepository(database).txnsOf(i.accountId, i.securityId),
        builder: (context, snap) {
          final txns = snap.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(i.name, style: t.titleMedium),
              if (i.amc != null) Text(i.amc!, style: t.bodySmall),
              const SizedBox(height: 12),
              for (final (k, v) in facts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(k, style: t.bodyMedium)),
                      Text(v, style: t.bodyMedium),
                    ],
                  ),
                ),
              if (txns.isNotEmpty) ...[
                const Divider(height: 24),
                Text('Transactions', style: t.titleSmall),
                for (final x in txns)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      x.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        date(x.date),
                        if (x.unitsE4 != null) '${_units(x.unitsE4!)} units',
                      ].join(' · '),
                    ),
                    trailing: x.amountPaise == null
                        ? null
                        : Text(inrWhole(x.amountPaise!)),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

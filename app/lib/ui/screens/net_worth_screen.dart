import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import 'loans_screen.dart';

String _date(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';

/// Everything owned minus everything owed: bank balances, investments,
/// other assets, card dues and loans, with a 12-month history.
class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  late final _repo = NetWorthRepository(widget.database);
  NetWorth? _nw;
  List<NetWorthPoint> _history = const [];
  List<ManualAssetView> _assets = const [];

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final nw = await _repo.netWorth(_now);
    final hist = await _repo.history(_now);
    final assets = await _repo.assets(_now);
    if (!mounted) return;
    setState(() {
      _nw = nw;
      _history = hist;
      _assets = assets;
    });
  }

  Future<void> _edit([ManualAssetView? asset]) async {
    final r = await showDialog<_AssetForm>(
      context: context,
      builder: (_) => _AssetDialog(asset: asset),
    );
    if (r == null) return;
    if (r.delete) {
      await _repo.deleteAsset(asset!.id);
    } else {
      await _repo.saveAsset(
        id: asset?.id,
        name: r.name,
        kind: r.kind,
        valuePaise: r.valuePaise,
        interestBp: r.interestBp,
        maturityDate: r.maturity,
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final nw = _nw;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Net worth'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => LoansScreen(database: widget.database),
              ));
              await _load();
            },
            icon: const Icon(Icons.account_balance_outlined),
            label: const Text('Loans'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Asset or loan'),
      ),
      body: nw == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                children: [
                  Text(inrWhole(nw.totalPaise), style: t.headlineMedium),
                  Text(
                    '${inrWhole(nw.assetsPaise)} owned · '
                    '${inrWhole(nw.liabilitiesPaise)} owed',
                    style: t.bodyMedium,
                  ),
                  if (_history.length >= 2) ...[
                    const SizedBox(height: 16),
                    NetWorthChart(points: _history),
                    Text(
                      'Month-end values; card dues are only in today\'s total.',
                      style: t.bodySmall,
                    ),
                  ],
                  if (nw.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'Import bank statements (for balances) and your CAS '
                        '(for investments), and add things like gold, FDs, '
                        'PPF or property here.',
                      ),
                    ),
                  for (final g in nw.byGroup.entries) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text(g.key.label, style: t.titleSmall)),
                        Text(
                          '${g.key.isLiability ? '−' : ''}${inrWhole(g.value)}',
                          style: t.titleSmall?.copyWith(
                            color: g.key.isLiability ? scheme.error : null,
                          ),
                        ),
                      ],
                    ),
                    for (final i in nw.items.where((i) => i.group == g.key))
                      _ItemTile(
                        item: i,
                        now: _now,
                        onTap: i.assetId == null
                            ? null
                            : () => _edit(
                                _assets.firstWhere((a) => a.id == i.assetId),
                              ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.now, this.onTap});
  final NetWorthItem item;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final asOf = item.asOf;
    final stale = asOf != null && now.difference(asOf).inDays > 45;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: asOf == null || item.group == NetWorthGroup.cards
          ? null
          : Text(
              '${item.group == NetWorthGroup.investments ? 'Price' : 'As'} '
              'of ${_date(asOf)}${stale ? ' — may be out of date' : ''}',
              style: t.bodySmall?.copyWith(color: stale ? scheme.error : null),
            ),
      trailing: Text(inrWhole(item.valuePaise)),
      onTap: onTap,
    );
  }
}

/// Month-end net worth line; tap a point for its value.
class NetWorthChart extends StatelessWidget {
  const NetWorthChart({super.key, required this.points});
  final List<NetWorthPoint> points;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final values = points.map((p) => p.paise);
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final first = points.first;
    final last = points.last;
    String m(DateTime d) => '${monthShort(d.month)} ${d.year % 100}';
    return Semantics(
      label:
          'Net worth from ${inrCompact(first.paise)} in '
          '${monthLabel(first.date.year, first.date.month)} to '
          '${inrCompact(last.paise)} now',
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  minY: lo == hi ? lo - 1.0 : lo.toDouble(),
                  maxY: lo == hi ? hi + 1.0 : hi.toDouble(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => scheme.inverseSurface,
                      getTooltipItems: (spots) => [
                        for (final s in spots)
                          LineTooltipItem(
                            '${m(points[s.x.toInt()].date)}\n'
                            '${inrWhole(points[s.x.toInt()].paise)}',
                            TextStyle(color: scheme.onInverseSurface),
                          ),
                      ],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < points.length; i++)
                          FlSpot(i.toDouble(), points[i].paise.toDouble()),
                      ],
                      barWidth: 2,
                      color: scheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: scheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(m(first.date), style: t.labelSmall),
                Text(m(last.date), style: t.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetForm {
  const _AssetForm({
    required this.name,
    required this.kind,
    required this.valuePaise,
    this.interestBp,
    this.maturity,
    this.delete = false,
  });

  final String name;
  final String kind;
  final int valuePaise;
  final int? interestBp;
  final DateTime? maturity;
  final bool delete;
}

class _AssetDialog extends StatefulWidget {
  const _AssetDialog({this.asset});
  final ManualAssetView? asset;

  @override
  State<_AssetDialog> createState() => _AssetDialogState();
}

class _AssetDialogState extends State<_AssetDialog> {
  late final _name = TextEditingController(text: widget.asset?.name);
  late final _value = TextEditingController(
    text: widget.asset == null ? '' : '${widget.asset!.currentPaise ~/ 100}',
  );
  late final _rate = TextEditingController(
    text: widget.asset?.interestBp == null
        ? ''
        : '${widget.asset!.interestBp! / 100}',
  );
  late String _kind = widget.asset?.kind ?? 'gold';
  late DateTime? _maturity = widget.asset?.maturityDate;

  int? get _paise {
    final v = int.tryParse(_value.text.trim());
    return v == null || v < 0 ? null : v * 100;
  }

  bool get _valid => _name.text.trim().isNotEmpty && _paise != null;

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rate = double.tryParse(_rate.text.trim());
    return AlertDialog(
      title: Text(widget.asset == null ? 'Add asset or loan' : 'Update'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final e in kAssetKinds.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _kind = v ?? _kind),
            ),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: isLiabilityKind(_kind)
                    ? 'e.g. Home loan (SBI)'
                    : 'e.g. Gold coins, SBI FD',
              ),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _value,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: isLiabilityKind(_kind)
                    ? 'Amount still owed today'
                    : 'Value today',
                prefixText: '₹',
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_kind == 'fd') ...[
              TextField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Interest rate (optional)',
                  suffixText: '% a year',
                  helperText: 'Grows the value automatically (quarterly)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _maturity == null
                      ? 'Maturity date (optional)'
                      : 'Matures ${_date(_maturity!)}',
                ),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                    context: context,
                    initialDate:
                        _maturity ?? DateTime(now.year + 1, now.month, now.day),
                    firstDate: DateTime(now.year - 10),
                    lastDate: DateTime(now.year + 30),
                  );
                  if (d != null) setState(() => _maturity = d);
                },
              ),
            ],
            if (widget.asset == null || _kind != 'fd')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Update the value now and then; Arth keeps the history.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (widget.asset != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              const _AssetForm(name: '', kind: '', valuePaise: 0, delete: true),
            ),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: !_valid
              ? null
              : () => Navigator.of(context).pop(
                  _AssetForm(
                    name: _name.text.trim(),
                    kind: _kind,
                    valuePaise: _paise!,
                    interestBp: _kind == 'fd' && rate != null && rate > 0
                        ? (rate * 100).round()
                        : null,
                    maturity: _kind == 'fd' ? _maturity : null,
                  ),
                ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

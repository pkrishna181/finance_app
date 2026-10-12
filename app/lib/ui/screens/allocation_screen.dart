import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Current mix of asset classes against the user's targets, with how much to
/// add or trim per class.
class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  late final _repo = AllocationRepository(widget.database);
  Allocation? _a;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await _repo.allocation(widget.now ?? DateTime.now());
    if (mounted) setState(() => _a = a);
  }

  Future<void> _editTargets() async {
    final current = await _repo.targets();
    if (!mounted) return;
    final r = await showDialog<Map<AssetClass, int>>(
      context: context,
      builder: (_) => _TargetsDialog(initial: current),
    );
    if (r == null) return;
    await _repo.setTargets(r);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final a = _a;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset allocation'),
        actions: [
          TextButton(onPressed: _editTargets, child: const Text('Targets')),
        ],
      ),
      body: a == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!a.hasPlan)
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: const Text('Set target percentages'),
                      subtitle: const Text(
                        'For example 60% equity, 30% debt, 10% gold. Classes '
                        'you leave out (like property) are not counted.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _editTargets,
                    ),
                  )
                else
                  Text(
                    a.needsRebalance
                        ? 'Off target by up to '
                            '${a.maxDriftPoints.toStringAsFixed(0)} points — '
                            'consider rebalancing.'
                        : 'Within ${Allocation.driftThresholdPoints.toStringAsFixed(0)} '
                            'points of your targets.',
                    style: t.titleMedium?.copyWith(
                      color: a.needsRebalance ? scheme.error : scheme.primary,
                    ),
                  ),
                const SizedBox(height: 16),
                for (final r in a.rows) _ClassRow(row: r),
                if (a.hasPlan) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Percentages are of the classes in your plan '
                    '(${inrWhole(a.plannedTotalPaise)}). Rebalance with new '
                    'money first — selling can trigger capital-gains tax.',
                    style: t.bodySmall,
                  ),
                ],
              ],
            ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.row});
  final AllocationRow row;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = row;
    final cur = r.currentFraction;
    final tgt = r.targetFraction;
    final reb = r.rebalancePaise;
    final drift = r.driftPoints;
    final off = drift != null && drift.abs() >= Allocation.driftThresholdPoints;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        label: '${r.assetClass.label}: ${inrWhole(r.valuePaise)}'
            '${tgt == null ? ', not in plan' : ', ${(cur * 100).round()}% now, target ${(tgt * 100).round()}%'}',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(r.assetClass.label, style: t.titleSmall)),
                Text(inrWhole(r.valuePaise)),
              ],
            ),
            const SizedBox(height: 4),
            if (tgt != null)
              LayoutBuilder(builder: (context, c) {
                return SizedBox(
                  height: 14,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: cur.clamp(0.0, 1.0),
                            minHeight: 14,
                            color: off ? scheme.error : scheme.primary,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      // Target marker.
                      Positioned(
                        left: (c.maxWidth * tgt - 1).clamp(0, c.maxWidth - 2),
                        top: 0,
                        bottom: 0,
                        child: Container(width: 2, color: scheme.onSurface),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 2),
            Text(
              tgt == null
                  ? 'Not in your plan'
                  : '${(cur * 100).toStringAsFixed(1)}% now · target '
                      '${(tgt * 100).toStringAsFixed(0)}%'
                      '${reb == null || reb.abs() < 100 ? '' : reb > 0 ? ' · add ${inrWhole(reb)}' : ' · trim ${inrWhole(-reb)}'}',
              style: t.bodySmall?.copyWith(color: off ? scheme.error : null),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetsDialog extends StatefulWidget {
  const _TargetsDialog({required this.initial});
  final Map<AssetClass, int> initial;

  @override
  State<_TargetsDialog> createState() => _TargetsDialogState();
}

class _TargetsDialogState extends State<_TargetsDialog> {
  late final _c = {
    for (final c in AssetClass.values)
      c: TextEditingController(
        text: widget.initial[c] == null ? '' : '${widget.initial[c]! ~/ 100}',
      ),
  };

  static const _presets = <String, Map<AssetClass, int>>{
    'Growth 70/20/10': {
      AssetClass.equity: 70,
      AssetClass.debt: 20,
      AssetClass.gold: 10,
    },
    'Balanced 60/30/10': {
      AssetClass.equity: 60,
      AssetClass.debt: 30,
      AssetClass.gold: 10,
    },
    'Cautious 40/50/10': {
      AssetClass.equity: 40,
      AssetClass.debt: 50,
      AssetClass.gold: 10,
    },
  };

  int get _sum => _c.values
      .fold(0, (s, c) => s + (int.tryParse(c.text.trim()) ?? 0));

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sum = _sum;
    return AlertDialog(
      title: const Text('Target allocation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in _presets.entries)
                  ActionChip(
                    label: Text(p.key),
                    onPressed: () => setState(() {
                      for (final e in _c.entries) {
                        e.value.text = p.value[e.key]?.toString() ?? '';
                      }
                    }),
                  ),
              ],
            ),
            for (final e in _c.entries)
              TextField(
                controller: e.value,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: e.key.label,
                  suffixText: '%',
                ),
                onChanged: (_) => setState(() {}),
              ),
            const SizedBox(height: 8),
            Text(
              sum == 100 ? 'Adds up to 100%' : 'Adds up to $sum% (needs 100%)',
              style: TextStyle(
                color: sum == 100 || sum == 0
                    ? null
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.initial.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.of(context).pop(<AssetClass, int>{}),
            child: const Text('Clear'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: sum != 100
              ? null
              : () => Navigator.of(context).pop({
                    for (final e in _c.entries)
                      if ((int.tryParse(e.value.text.trim()) ?? 0) > 0)
                        e.key: int.parse(e.value.text.trim()) * 100,
                  }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

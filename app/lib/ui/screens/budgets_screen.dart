import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Lists budgets for the current month and lets the user add, edit or remove
/// a monthly limit per category.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key, required this.database, this.now});

  final ArthDatabase database;

  /// Injectable clock for tests.
  final DateTime? now;

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  bool _loading = true;
  List<BudgetProgress> _progress = const [];
  Map<String, BudgetDef> _defs = const {};
  List<Category> _unbudgeted = const [];
  Map<String, int?> _suggested = const {};

  DateTime get _now => widget.now ?? DateTime.now();
  MonthKey get _month => MonthKey.of(_now);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = widget.database;
    final repo = InsightsRepository(db);
    final defs = await BudgetRepository(db).list();
    final cats = await repo.pickableCategories();
    final agg = await repo.aggregatorFor(_month);
    if (!mounted) return;
    final names = {for (final c in cats) c.slug: c.name};
    final bySlug = {for (final d in defs) d.slug: d};
    final unbudgeted = [
      for (final c in cats)
        if (isBudgetableSlug(c.slug) && !bySlug.containsKey(c.slug)) c,
    ];
    setState(() {
      _defs = bySlug;
      _progress = const BudgetCalculator().compute(
        agg,
        _month,
        defs,
        names,
        asOf: _now,
      );
      _unbudgeted = unbudgeted;
      _suggested = {
        for (final c in cats)
          c.slug: BudgetCalculator.suggestLimit(agg, _month, c.slug),
      };
      _loading = false;
    });
  }

  Future<void> _edit(String slug, String name) async {
    final existing = _defs[slug];
    final result = await showDialog<_EditResult>(
      context: context,
      builder: (_) => _BudgetDialog(
        name: name,
        initialPaise: existing?.limitPaise ?? _suggested[slug],
        initialRollover: existing?.rollover ?? false,
        canRemove: existing != null,
      ),
    );
    if (result == null) return;
    final repo = BudgetRepository(widget.database);
    if (result.remove) {
      await repo.delete(slug);
    } else {
      await repo.upsert(
        slug,
        limitPaise: result.limitPaise!,
        rollover: result.rollover,
        start: _month,
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets · ${monthLabel(_month.year, _month.month)}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (_progress.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No budgets yet. Pick a category below.'),
                  ),
                for (final p in _progress)
                  InkWell(
                    onTap: () => _edit(p.slug, p.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: BudgetProgressRow(progress: p, detailed: true),
                    ),
                  ),
                if (_unbudgeted.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text('Add a budget', style: t.titleSmall),
                  ),
                  for (final c in _unbudgeted)
                    ListTile(
                      title: Text(c.name),
                      subtitle: _suggested[c.slug] == null
                          ? null
                          : Text('Avg ${inrWhole(_suggested[c.slug]!)}/month'),
                      trailing: const Icon(Icons.add),
                      onTap: () => _edit(c.slug, c.name),
                    ),
                ],
              ],
            ),
    );
  }
}

/// Name, amounts and a progress bar for one budget.
class BudgetProgressRow extends StatelessWidget {
  const BudgetProgressRow({
    super.key,
    required this.progress,
    this.detailed = false,
  });

  final BudgetProgress progress;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = progress;
    final color = switch (p.status) {
      BudgetStatus.over => scheme.error,
      BudgetStatus.warning => const Color(0xFFE08A1E),
      BudgetStatus.ok => scheme.primary,
    };
    final remaining = p.remainingPaise;
    final String note;
    if (remaining < 0) {
      note = '${inrWhole(-remaining)} over';
    } else if (p.aheadOfPace) {
      note = '${inrWhole(remaining)} left · spending fast';
    } else {
      note = '${inrWhole(remaining)} left';
    }
    final value = p.fraction.isFinite ? p.fraction.clamp(0.0, 1.0) : 1.0;
    return Semantics(
      label:
          '${p.name}: spent ${inrWhole(p.spentPaise)} of '
          '${inrWhole(p.availablePaise)}, $note',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${inrWhole(p.spentPaise)} / ${inrWhole(p.availablePaise)}',
                style: t.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.toDouble(),
              minHeight: 6,
              color: color,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detailed && p.carryPaise != 0
                ? '$note · ${p.carryPaise > 0 ? '+' : '-'}'
                      '${inrWhole(p.carryPaise.abs())} rolled over'
                : note,
            style: t.bodySmall?.copyWith(
              color: p.status == BudgetStatus.ok && !p.aheadOfPace
                  ? null
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditResult {
  const _EditResult({
    this.limitPaise,
    this.rollover = false,
    this.remove = false,
  });
  final int? limitPaise;
  final bool rollover;
  final bool remove;
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({
    required this.name,
    required this.initialPaise,
    required this.initialRollover,
    required this.canRemove,
  });

  final String name;
  final int? initialPaise;
  final bool initialRollover;
  final bool canRemove;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final _amount = TextEditingController(
    text: widget.initialPaise == null
        ? ''
        : (widget.initialPaise! ~/ 100).toString(),
  );
  late bool _rollover = widget.initialRollover;

  int? get _paise {
    final v = int.tryParse(_amount.text.trim());
    return v == null || v <= 0 ? null : v * 100;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Monthly limit',
              prefixText: '₹',
            ),
            onChanged: (_) => setState(() {}),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _rollover,
            onChanged: (v) => setState(() => _rollover = v),
            title: const Text('Roll over'),
            subtitle: const Text(
              'Carry unspent money (or overspending) '
              'into next month',
            ),
          ),
        ],
      ),
      actions: [
        if (widget.canRemove)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(const _EditResult(remove: true)),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _paise == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop(_EditResult(limitPaise: _paise, rollover: _rollover)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

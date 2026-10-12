import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Savings goals with progress, the monthly amount needed, and the date the
/// goal is reached at the recent pace.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late final _repo = GoalRepository(widget.database);
  List<GoalProgress>? _goals;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await _repo.progressAll(_now);
    if (mounted) setState(() => _goals = g);
  }

  Future<void> _edit([GoalDef? goal]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GoalEditScreen(database: widget.database, goal: goal),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _addMoney(GoalDef g) async {
    final paise = await showDialog<int>(
      context: context,
      builder: (_) => _AmountDialog(title: 'Add to ${g.name}'),
    );
    if (paise == null) return;
    await _repo.addContribution(g.id, paise, _now);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final goals = _goals;
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: goals == null
          ? const Center(child: CircularProgressIndicator())
          : goals.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Save toward something — an emergency fund, a trip, a '
                    'house. Arth works out how much to put aside each month '
                    'and tells you if you\'re on track.',
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  children: [
                    for (final g in goals) ...[
                      GoalTile(
                        progress: g,
                        onTap: () => _edit(g.goal),
                        onAddMoney: g.goal.source == GoalSource.manual
                            ? () => _addMoney(g.goal)
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
    );
  }
}

/// One goal: progress bar, amount needed per month, projected date.
class GoalTile extends StatelessWidget {
  const GoalTile({
    super.key,
    required this.progress,
    this.onTap,
    this.onAddMoney,
    this.compact = false,
  });

  final GoalProgress progress;
  final VoidCallback? onTap;
  final VoidCallback? onAddMoney;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = progress;
    final g = p.goal;
    String month(DateTime d) => monthLabel(d.year, d.month);

    final (String status, Color? color) = switch (p.state) {
      GoalState.reached => ('Reached', scheme.primary),
      GoalState.onTrack => ('On track', scheme.primary),
      GoalState.behind => ('Behind', scheme.error),
      GoalState.noDeadline => ('', null),
    };
    final lines = <String>[
      if (p.requiredMonthlyPaise != null && p.state != GoalState.reached)
        'Save ${inrWhole(p.requiredMonthlyPaise!)}/month to reach it by '
            '${month(g.targetDate!)}',
      if (p.recentMonthlyPaise != null && p.state != GoalState.reached)
        'Recently ${inrWhole(p.recentMonthlyPaise!)}/month'
            '${p.projectedDate == null ? '' : ' → ${month(p.projectedDate!)}'}',
    ];

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                g.name,
                style: compact ? t.bodyLarge : t.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (status.isNotEmpty)
              Text(status, style: t.labelMedium?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          label: '${g.name}: ${inrWhole(p.currentPaise)} of '
              '${inrWhole(g.targetPaise)}',
          excludeSemantics: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p.fraction,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${inrWhole(p.currentPaise)} of ${inrWhole(g.targetPaise)} · '
          '${(p.fraction * 100).round()}%',
          style: t.bodySmall,
        ),
        if (!compact)
          for (final l in lines) Text(l, style: t.bodySmall),
        if (!compact && onAddMoney != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAddMoney,
              icon: const Icon(Icons.add),
              label: const Text('Add money'),
            ),
          ),
      ],
    );
    if (compact) return body;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(padding: const EdgeInsets.all(16), child: body),
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.title});
  final String title;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _c = TextEditingController();

  int? get _paise {
    final v = int.tryParse(_c.text.trim());
    return v == null || v <= 0 ? null : v * 100;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _c,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              _paise == null ? null : () => Navigator.of(context).pop(_paise),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Create or edit a goal. Pops `true` when saved or deleted.
class GoalEditScreen extends StatefulWidget {
  const GoalEditScreen({super.key, required this.database, this.goal});

  final ArthDatabase database;
  final GoalDef? goal;

  @override
  State<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends State<GoalEditScreen> {
  late final _repo = GoalRepository(widget.database);
  late final _name = TextEditingController(text: widget.goal?.name);
  late final _target = TextEditingController(
    text: widget.goal == null ? '' : '${widget.goal!.targetPaise ~/ 100}',
  );
  late final _start = TextEditingController(
    text: widget.goal == null || widget.goal!.startPaise == 0
        ? ''
        : '${widget.goal!.startPaise ~/ 100}',
  );
  late final _rate = TextEditingController(
    text: widget.goal == null || widget.goal!.annualReturnPct == 0
        ? ''
        : '${widget.goal!.annualReturnPct}',
  );
  late DateTime? _targetDate = widget.goal?.targetDate;
  late GoalSource _source = widget.goal?.source ?? GoalSource.manual;
  late String? _ref = widget.goal?.sourceRef;
  List<BalanceAccount> _accounts = const [];
  List<Category> _categories = const [];
  List<GoalContribution> _contribs = const [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final accounts = await _repo.balanceAccounts();
    final cats = await InsightsRepository(widget.database).pickableCategories();
    final contribs =
        widget.goal == null ? <GoalContribution>[] : await _repo.contributions(widget.goal!.id);
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _categories = [for (final c in cats) if (isBudgetableSlug(c.slug)) c];
      _contribs = contribs;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _target, _start, _rate]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _rupees(TextEditingController c) {
    final v = int.tryParse(c.text.trim());
    return v == null ? null : v * 100;
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      (_rupees(_target) ?? 0) > 0 &&
      (_source == GoalSource.manual || (_ref ?? '').isNotEmpty) &&
      (_rate.text.trim().isEmpty || double.tryParse(_rate.text.trim()) != null);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 60),
    );
    if (d != null) setState(() => _targetDate = d);
  }

  Future<void> _save() async {
    await _repo.save(
      id: widget.goal?.id,
      name: _name.text,
      targetPaise: _rupees(_target)!,
      targetDate: _targetDate,
      startPaise: _rupees(_start) ?? 0,
      annualReturnPct: double.tryParse(_rate.text.trim()) ?? 0,
      source: _source,
      sourceRef: _ref,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${widget.goal!.name}"?'),
        content: const Text('Your transactions are not affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _repo.delete(widget.goal!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    void changed(String _) => setState(() {});
    final td = _targetDate;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'New goal' : 'Edit goal'),
        actions: [
          if (widget.goal != null)
            IconButton(
              tooltip: 'Delete goal',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Goal',
              hintText: 'e.g. Emergency fund',
            ),
            onChanged: changed,
          ),
          TextField(
            controller: _target,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration:
                const InputDecoration(labelText: 'Target', prefixText: '₹'),
            onChanged: changed,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(td == null
                ? 'No target date'
                : 'By ${td.day} ${monthShort(td.month)} ${td.year}'),
            trailing: td == null
                ? const Text('Set')
                : IconButton(
                    tooltip: 'Clear date',
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _targetDate = null),
                  ),
            onTap: _pickDate,
          ),
          TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Expected return per year (optional)',
              suffixText: '%',
              helperText: 'e.g. 7 for an FD or debt fund; leave empty for 0',
            ),
            onChanged: changed,
          ),
          const SizedBox(height: 16),
          Text('Track progress from', style: t.titleSmall),
          RadioGroup<GoalSource>(
            groupValue: _source,
            onChanged: (v) => setState(() {
              _source = v ?? _source;
              _ref = null;
            }),
            child: Column(
              children: [
                const RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  value: GoalSource.manual,
                  title: Text('Money I add here'),
                ),
                RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  value: GoalSource.account,
                  enabled: _accounts.isNotEmpty,
                  title: const Text('A bank account\'s balance'),
                  subtitle: _accounts.isEmpty
                      ? const Text('Import a statement with balances first')
                      : null,
                ),
                const RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  value: GoalSource.category,
                  title: Text('What I put into a category'),
                  subtitle: Text('e.g. Investments / SIP since today'),
                ),
              ],
            ),
          ),
          if (_source == GoalSource.account)
            DropdownButtonFormField<String>(
              initialValue: _accounts.any((a) => a.ref == _ref) ? _ref : null,
              decoration: const InputDecoration(labelText: 'Account'),
              items: [
                for (final a in _accounts)
                  DropdownMenuItem(
                    value: a.ref,
                    child: Text(
                        '${a.bankCode} ••${a.last4} · ${inrWhole(a.balancePaise)}'),
                  ),
              ],
              onChanged: (v) => setState(() => _ref = v),
            ),
          if (_source == GoalSource.category)
            DropdownButtonFormField<String>(
              initialValue:
                  _categories.any((c) => c.slug == _ref) ? _ref : null,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(value: c.slug, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _ref = v),
            ),
          if (_source != GoalSource.account)
            TextField(
              controller: _start,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                labelText: 'Already saved (optional)',
                prefixText: '₹',
              ),
              onChanged: changed,
            ),
          if (_contribs.isNotEmpty && _source == GoalSource.manual) ...[
            const SizedBox(height: 16),
            Text('Added', style: t.titleSmall),
            for (final c in _contribs)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(inrWhole(c.amountPaise)),
                subtitle: Text(
                    '${c.date.day} ${monthShort(c.date.month)} ${c.date.year}'),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await _repo.deleteContribution(c.id);
                    await _loadOptions();
                  },
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _valid ? _save : null,
            child: const Text('Save'),
          ),
        ),
      ),
    );
  }
}

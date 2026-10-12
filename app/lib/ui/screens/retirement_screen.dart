import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Retirement corpus needed, what today's investments grow to, and the
/// monthly saving that closes the gap.
class RetirementScreen extends StatefulWidget {
  const RetirementScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<RetirementScreen> createState() => _RetirementScreenState();
}

class _RetirementScreenState extends State<RetirementScreen> {
  late final _repo = RetirementRepository(widget.database);
  final _age = TextEditingController();
  final _retire = TextEditingController(text: '60');
  final _life = TextEditingController(text: '85');
  final _expense = TextEditingController();
  final _inflation = TextEditingController(text: '6');
  final _pre = TextEditingController(text: '10');
  final _post = TextEditingController(text: '7');
  final _swr = TextEditingController();
  Set<AssetClass> _classes = {
    AssetClass.equity,
    AssetClass.debt,
    AssetClass.gold,
    AssetClass.other,
  };
  int? _avgSpend;
  RetirementPlanResult? _result;
  bool _loading = true;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _age,
      _retire,
      _life,
      _expense,
      _inflation,
      _pre,
      _post,
      _swr,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final p = await _repo.row();
    final avg = await _repo.recentAverages(_now);
    final res = await _repo.result(_now);
    if (!mounted) return;
    setState(() {
      _avgSpend = avg?.spend;
      if (p != null) {
        _age.text = '${p.currentAge}';
        _retire.text = '${p.retireAge}';
        _life.text = '${p.lifeExpectancy}';
        _expense.text = p.monthlyExpensePaise == null
            ? ''
            : '${p.monthlyExpensePaise! ~/ 100}';
        _inflation.text = _pct(p.inflationBp);
        _pre.text = _pct(p.returnPreBp);
        _post.text = _pct(p.returnPostBp);
        _swr.text = p.swrBp == null ? '' : _pct(p.swrBp!);
        _classes = {
          for (final c in p.classes.split(','))
            if (c.isNotEmpty) AssetClass.values.byName(c),
        };
      }
      _result = res;
      _loading = false;
    });
  }

  static String _pct(int bp) {
    final v = bp / 100;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  }

  int? _bp(TextEditingController c) {
    final v = double.tryParse(c.text.trim());
    return v == null ? null : (v * 100).round();
  }

  bool get _valid {
    final a = int.tryParse(_age.text.trim());
    final r = int.tryParse(_retire.text.trim());
    final l = int.tryParse(_life.text.trim());
    final hasExpense =
        int.tryParse(_expense.text.trim()) != null || _avgSpend != null;
    return a != null &&
        r != null &&
        l != null &&
        a > 0 &&
        r >= a &&
        l > r &&
        hasExpense &&
        _bp(_inflation) != null &&
        _bp(_pre) != null &&
        _bp(_post) != null &&
        (_swr.text.trim().isEmpty || (_bp(_swr) ?? 0) > 0);
  }

  Future<void> _save() async {
    final e = int.tryParse(_expense.text.trim());
    await _repo.save(
      currentAge: int.parse(_age.text.trim()),
      retireAge: int.parse(_retire.text.trim()),
      lifeExpectancy: int.parse(_life.text.trim()),
      monthlyExpensePaise: e == null ? null : e * 100,
      inflationBp: _bp(_inflation)!,
      returnPreBp: _bp(_pre)!,
      returnPostBp: _bp(_post)!,
      swrBp: _swr.text.trim().isEmpty ? null : _bp(_swr),
      classes: _classes,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void changed(String _) => setState(() {});
    Widget num(
      TextEditingController c,
      String label, {
      String? suffix,
      String? helper,
      bool decimal = false,
    }) => Expanded(
      child: TextField(
        controller: c,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: decimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          helperText: helper,
          helperMaxLines: 2,
        ),
        onChanged: changed,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Retirement')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_result != null) ...[
                  _ResultCard(result: _result!),
                  const SizedBox(height: 16),
                ],
                Text('Your assumptions', style: t.titleSmall),
                Row(
                  children: [
                    num(_age, 'Age now'),
                    const SizedBox(width: 12),
                    num(_retire, 'Retire at'),
                    const SizedBox(width: 12),
                    num(_life, 'Plan until age'),
                  ],
                ),
                Row(
                  children: [
                    num(
                      _expense,
                      'Monthly expenses today',
                      helper: _avgSpend == null
                          ? null
                          : 'Leave empty to use your average: '
                                '${inrWhole(_avgSpend!)}',
                    ),
                  ],
                ),
                Row(
                  children: [
                    num(_inflation, 'Inflation', suffix: '%', decimal: true),
                    const SizedBox(width: 12),
                    num(
                      _pre,
                      'Return until retiring',
                      suffix: '%',
                      decimal: true,
                    ),
                    const SizedBox(width: 12),
                    num(_post, 'Return after', suffix: '%', decimal: true),
                  ],
                ),
                Row(
                  children: [
                    num(
                      _swr,
                      'Safe withdrawal rate (optional)',
                      suffix: '%',
                      decimal: true,
                      helper:
                          'e.g. 3.5. Leave empty to plan money lasting '
                          'until the age above.',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Counted as retirement money', style: t.bodyMedium),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final c in AssetClass.values)
                      FilterChip(
                        label: Text(c.label),
                        selected: _classes.contains(c),
                        onSelected: (v) => setState(() {
                          v ? _classes.add(c) : _classes.remove(c);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _valid ? _save : null,
                  child: Text(_result == null ? 'Calculate' : 'Update'),
                ),
                const SizedBox(height: 12),
                Text(
                  'A projection, not a promise: returns and inflation vary. '
                  'Revisit it every year.',
                  style: t.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final RetirementPlanResult result;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final r = result;
    final onTrack = r.onTrack;
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v),
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
            Text(
              'You need ${inrWhole(r.corpusNeededPaise)}',
              style: t.titleLarge,
            ),
            Text(
              'at ${r.inputs.retireAge} (${inrWhole(r.corpusNeededTodayPaise)} '
              'in today\'s money)',
              style: t.bodySmall,
            ),
            const SizedBox(height: 12),
            Semantics(
              label:
                  '${(r.fundedFraction * 100).round()}% funded by '
                  'what you have now',
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: r.fundedFraction,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: 8),
            row('Saved for retirement now', inrWhole(r.currentCorpusPaise)),
            row(
              'Grows to by ${r.inputs.retireAge}',
              inrWhole(r.projectedCorpusPaise),
            ),
            row('Yearly expenses then', inrWhole(r.annualExpenseAtRetirePaise)),
            const Divider(),
            Text(
              r.gapPaise == 0
                  ? 'What you have is enough if it keeps growing.'
                  : 'Invest ${inrWhole(r.monthlySavingNeededPaise)} a month '
                        'from now to close the gap.',
              style: t.titleMedium,
            ),
            if (r.recentMonthlySavingPaise != null)
              Text(
                'You\'ve been saving about '
                '${inrWhole(r.recentMonthlySavingPaise!)} a month'
                '${onTrack == true ? ' — on track.' : '.'}',
                style: t.bodyMedium?.copyWith(
                  color: onTrack == true ? scheme.primary : scheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

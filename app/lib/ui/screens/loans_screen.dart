import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

String _d(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';
String _m(DateTime d) => monthLabel(d.year, d.month);

/// Loans: outstanding, EMI, payoff date; tap for the details.
class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  late final _repo = LoanRepository(widget.database);
  List<LoanStatus>? _loans;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = await _repo.statuses(_now);
    if (mounted) setState(() => _loans = l);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final loans = _loans;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(LoanEditScreen(database: widget.database)),
        icon: const Icon(Icons.add),
        label: const Text('Add loan'),
      ),
      body: loans == null
          ? const Center(child: CircularProgressIndicator())
          : loans.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Add a home, car or personal loan to see what you still '
                'owe, when it ends, interest by financial year and what '
                'a prepayment would save.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              children: [
                Text(
                  '${inrWhole(loans.fold(0, (s, l) => s + l.outstandingPaise))} '
                  'outstanding · EMIs '
                  '${inrWhole(loans.where((l) => !l.isClosed).fold(0, (s, l) => s + l.emiPaise))}/month',
                  style: t.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final l in loans)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _open(
                        LoanDetailScreen(
                          database: widget.database,
                          loanId: l.loan.id,
                          now: _now,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.loan.name, style: t.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              l.isClosed
                                  ? 'Repaid'
                                  : '${inrWhole(l.outstandingPaise)} left · '
                                        'EMI ${inrWhole(l.emiPaise)} · ends '
                                        '${_m(l.payoffDate!)}',
                            ),
                            const SizedBox(height: 8),
                            Semantics(
                              label:
                                  '${(l.fractionRepaid * 100).round()}% repaid',
                              excludeSemantics: true,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: l.fractionRepaid,
                                  minHeight: 6,
                                  backgroundColor:
                                      scheme.surfaceContainerHighest,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(l.fractionRepaid * 100).round()}% repaid · '
                              '${l.remainingEmis} EMIs left',
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// One loan: status, this year's interest / principal, EMIs seen in the
/// bank data, and a prepayment calculator.
class LoanDetailScreen extends StatefulWidget {
  const LoanDetailScreen({
    super.key,
    required this.database,
    required this.loanId,
    required this.now,
  });

  final ArthDatabase database;
  final int loanId;
  final DateTime now;

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  late final _repo = LoanRepository(widget.database);
  LoanStatus? _s;
  List<DateTime> _seen = const [];
  final _prepay = TextEditingController();
  PrepayMode _mode = PrepayMode.tenure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _prepay.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await _repo.statuses(widget.now);
    final s = all.where((l) => l.loan.id == widget.loanId).firstOrNull;
    if (s == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final seen = await _repo.emisSeen(s);
    if (!mounted) return;
    setState(() {
      _s = s;
      _seen = seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final t = Theme.of(context).textTheme;
    if (s == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l = s.loan;
    final fy = FinancialYear.of(widget.now);
    final yr = const LoanCalculator().year(l, fy);
    final prev = const LoanCalculator().year(l, fy.previous);
    final amt = (int.tryParse(_prepay.text.trim()) ?? 0) * 100;
    final effect = amt > 0 && !s.isClosed
        ? const LoanCalculator().prepayEffect(l, amt, widget.now, mode: _mode)
        : null;
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l.name),
        actions: [
          IconButton(
            tooltip: 'Edit loan',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      LoanEditScreen(database: widget.database, loan: l),
                ),
              );
              await _load();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          row('Outstanding', inrWhole(s.outstandingPaise)),
          row('EMI', inrWhole(s.emiPaise)),
          row('Rate', '${(l.rateBp / 100).toStringAsFixed(2)}% a year'),
          row('EMIs paid / left', '${s.paidEmis} / ${s.remainingEmis}'),
          if (s.nextEmiDate != null) row('Next EMI', _d(s.nextEmiDate!)),
          if (s.payoffDate != null) row('Last EMI', _m(s.payoffDate!)),
          row('Interest still to pay', inrWhole(s.interestRemainingPaise)),
          const Divider(height: 24),
          Text('Interest and principal', style: t.titleSmall),
          for (final y in [yr, prev])
            if (y.interestPaise + y.principalPaise > 0)
              row(
                y.fy.label,
                '${inrWhole(y.interestPaise)} interest · ${inrWhole(y.principalPaise)} principal',
              ),
          if (l.kind == 'home')
            Text(
              'Old tax regime: home-loan interest can be deducted under '
              'section 24(b) (up to ₹2 lakh for a self-occupied home) and '
              'principal under 80C (within ₹1.5 lakh). The new regime allows '
              'neither for a self-occupied home.',
              style: t.bodySmall,
            ),
          const Divider(height: 24),
          Text('EMIs seen in your accounts', style: t.titleSmall),
          Text(
            _seen.isEmpty
                ? 'No debits matching ${inrWhole(s.emiPaise)} found yet.'
                : _seen.map(_d).join(' · '),
            style: t.bodySmall,
          ),
          if (!s.isClosed) ...[
            const Divider(height: 24),
            Text('What if I prepay?', style: t.titleSmall),
            TextField(
              controller: _prepay,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Extra payment now',
                prefixText: '₹',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PrepayMode>(
              segments: const [
                ButtonSegment(
                  value: PrepayMode.tenure,
                  label: Text('Finish sooner'),
                ),
                ButtonSegment(value: PrepayMode.emi, label: Text('Lower EMI')),
              ],
              selected: {_mode},
              onSelectionChanged: (v) => setState(() => _mode = v.first),
            ),
            if (effect != null) ...[
              const SizedBox(height: 8),
              Text(
                _mode == PrepayMode.tenure
                    ? 'Saves ${inrWhole(effect.interestSavedPaise)} interest and '
                          '${effect.emisSaved} EMIs.'
                    : 'EMI drops to ${inrWhole(effect.newEmiPaise)}; saves '
                          '${inrWhole(effect.interestSavedPaise)} interest.',
                style: t.bodyLarge,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await _repo.addPrepayment(
                      l.id,
                      widget.now,
                      amt,
                      mode: _mode,
                    );
                    _prepay.clear();
                    await _load();
                  },
                  child: const Text('I made this payment'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Add or edit a loan.
class LoanEditScreen extends StatefulWidget {
  const LoanEditScreen({super.key, required this.database, this.loan});

  final ArthDatabase database;
  final LoanDef? loan;

  @override
  State<LoanEditScreen> createState() => _LoanEditScreenState();
}

class _LoanEditScreenState extends State<LoanEditScreen> {
  late final _name = TextEditingController(text: widget.loan?.name);
  late final _lender = TextEditingController(text: widget.loan?.lender);
  late final _principal = TextEditingController(
    text: widget.loan == null ? '' : '${widget.loan!.principalPaise ~/ 100}',
  );
  late final _rate = TextEditingController(
    text: widget.loan == null ? '' : '${widget.loan!.rateBp / 100}',
  );
  late final _years = TextEditingController(
    text: widget.loan == null
        ? ''
        : (widget.loan!.tenureMonths / 12).toStringAsFixed(
            widget.loan!.tenureMonths % 12 == 0 ? 0 : 1,
          ),
  );
  late final _emi = TextEditingController(
    text: widget.loan?.emiPaise == null
        ? ''
        : '${widget.loan!.emiPaise! ~/ 100}',
  );
  late String _kind = widget.loan?.kind ?? 'home';
  late DateTime _first =
      widget.loan?.firstEmiDate ??
      DateTime(DateTime.now().year, DateTime.now().month, 5);

  int? get _principalPaise {
    final v = int.tryParse(_principal.text.trim());
    return v == null || v <= 0 ? null : v * 100;
  }

  double? get _rateValue => double.tryParse(_rate.text.trim());

  int? get _months {
    final y = double.tryParse(_years.text.trim());
    return y == null || y <= 0 ? null : (y * 12).round();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _principalPaise != null &&
      _rateValue != null &&
      _rateValue! >= 0 &&
      _months != null;

  @override
  void dispose() {
    for (final c in [_name, _lender, _principal, _rate, _years, _emi]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final emi = int.tryParse(_emi.text.trim());
    await LoanRepository(widget.database).save(
      id: widget.loan?.id,
      name: _name.text,
      kind: _kind,
      lender: _lender.text.trim().isEmpty ? null : _lender.text.trim(),
      principalPaise: _principalPaise!,
      rateBp: (_rateValue! * 100).round(),
      tenureMonths: _months!,
      firstEmiDate: _first,
      emiPaise: emi == null || emi <= 0 ? null : emi * 100,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "${widget.loan!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await LoanRepository(widget.database).delete(widget.loan!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    void changed(String _) => setState(() {});
    final computed = _valid
        ? LoanCalculator.emiFor(
            _principalPaise!,
            (_rateValue! * 100).round(),
            _months!,
          )
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loan == null ? 'Add loan' : 'Edit loan'),
        actions: [
          if (widget.loan != null)
            IconButton(
              tooltip: 'Remove loan',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Type'),
            items: [
              for (final e in kLoanKinds.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => _kind = v ?? _kind),
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. SBI home loan',
            ),
            onChanged: changed,
          ),
          TextField(
            controller: _lender,
            decoration: const InputDecoration(labelText: 'Lender (optional)'),
          ),
          TextField(
            controller: _principal,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Amount borrowed',
              prefixText: '₹',
            ),
            onChanged: changed,
          ),
          TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Interest rate',
              suffixText: '% a year',
            ),
            onChanged: changed,
          ),
          TextField(
            controller: _years,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tenure',
              suffixText: 'years',
            ),
            onChanged: changed,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('First EMI on ${_d(_first)}'),
            trailing: const Icon(Icons.event),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _first,
                firstDate: DateTime(1990),
                lastDate: DateTime(DateTime.now().year + 5),
              );
              if (d != null) setState(() => _first = d);
            },
          ),
          TextField(
            controller: _emi,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'EMI from your lender (optional)',
              prefixText: '₹',
              helperText: computed == null
                  ? null
                  : 'Calculated: ${inrWhole(computed)}',
            ),
          ),
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

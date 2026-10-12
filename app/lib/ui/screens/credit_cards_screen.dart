import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Tracked credit cards: bill, due date, payments and how much of the limit
/// is used. Cards found in imported card statements are offered for setup.
class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  late final _repo = CreditCardRepository(widget.database);
  List<CardStatus>? _cards;
  List<CardSuggestion> _suggestions = const [];

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await _repo.statuses(_now);
    final sugg = await _repo.suggestions();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _suggestions = sugg;
    });
  }

  Future<void> _edit({CardDef? card, CardSuggestion? from}) async {
    final result = await showDialog<_CardForm>(
      context: context,
      builder: (_) => _CardDialog(card: card, suggestion: from),
    );
    if (result == null) return;
    if (result.delete && card != null) {
      await _repo.delete(card.id);
    } else {
      await _repo.save(
        id: card?.id,
        bankCode: result.bankCode,
        name: result.name,
        last4: result.last4,
        creditLimitPaise: result.limitPaise,
        statementDay: result.statementDay,
        dueDay: result.dueDay,
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Credit cards')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Add card'),
      ),
      body: cards == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              children: [
                if (cards.isEmpty && _suggestions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Add a card to track its bill, due date and how much '
                      'of the limit you use. Importing card statements fills '
                      'most of this in automatically.',
                    ),
                  ),
                for (final c in cards) ...[
                  CardStatusTile(
                    status: c,
                    onTap: () => _edit(card: c.card),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_suggestions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Found in your statements',
                      style: t.titleSmall,
                    ),
                  ),
                  for (final s in _suggestions)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.credit_card),
                      title: Text(
                        '${s.bankCode} card${s.last4 == null ? '' : ' ••${s.last4}'}',
                      ),
                      subtitle: Text(
                        '${s.txnCount} transaction${s.txnCount == 1 ? '' : 's'}',
                      ),
                      trailing: TextButton(
                        onPressed: () => _edit(from: s),
                        child: const Text('Track'),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

/// One card's bill, due date and limit use.
class CardStatusTile extends StatelessWidget {
  const CardStatusTile({super.key, required this.status, this.onTap});

  final CardStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = status;
    final c = s.card;
    String date(DateTime d) => '${d.day} ${monthShort(d.month)}';

    final days = s.daysToDue;
    final (String headline, Color? color) = switch (s.state) {
      CardBillState.overdue => (
        '${inrWhole(s.remainingDuePaise)} overdue since ${date(s.dueDate!)}',
        scheme.error,
      ),
      CardBillState.due => (
        '${inrWhole(s.remainingDuePaise)} due'
            '${s.dueDate == null
                ? ''
                : days == 0
                ? ' today'
                : days == 1
                ? ' tomorrow'
                : ' ${date(s.dueDate!)} (in $days days)'}',
        days != null && days <= 3 ? scheme.error : null,
      ),
      CardBillState.paid => ('Last bill paid', scheme.primary),
      CardBillState.noBill => ('No bill due', null),
    };
    final util = s.utilization;
    final details = [
      if (s.billPaise != null)
        'Bill ${inrWhole(s.billPaise!)}${s.billIsEstimate ? ' (estimated)' : ''}',
      if (s.minDuePaise != null && s.state == CardBillState.due)
        'min ${inrWhole(s.minDuePaise!)}',
      if (s.paidPaise > 0) 'paid ${inrWhole(s.paidPaise)}',
    ].join(' · ');

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
              Row(
                children: [
                  const Icon(Icons.credit_card, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${c.name}${c.last4 == null ? '' : ' ••${c.last4}'}',
                      style: t.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(headline, style: t.bodyLarge?.copyWith(color: color)),
              if (details.isNotEmpty) Text(details, style: t.bodySmall),
              const SizedBox(height: 4),
              Text(
                'Since ${s.lastClose == null ? 'last 30 days' : date(s.lastClose!)}: '
                '${inrWhole(s.unbilledPaise)} unbilled'
                '${s.nextClose == null ? '' : ' · closes ${date(s.nextClose!)}'}',
                style: t.bodySmall,
              ),
              if (util != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  label:
                      'Using ${(util * 100).round()}% of '
                      '${inrWhole(s.limitPaise!)} limit',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: util.clamp(0.0, 1.0),
                          minHeight: 6,
                          color: util >= 0.9
                              ? scheme.error
                              : util >= 0.3
                              ? const Color(0xFFE08A1E)
                              : scheme.primary,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(util * 100).round()}% of ${inrWhole(s.limitPaise!)} limit used'
                        '${util >= 0.3 ? ' — above 30% can affect your credit score' : ''}',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CardForm {
  const _CardForm({
    required this.bankCode,
    required this.name,
    this.last4,
    this.limitPaise,
    this.statementDay,
    this.dueDay,
    this.delete = false,
  });

  final String bankCode;
  final String name;
  final String? last4;
  final int? limitPaise;
  final int? statementDay;
  final int? dueDay;
  final bool delete;
}

class _CardDialog extends StatefulWidget {
  const _CardDialog({this.card, this.suggestion});

  final CardDef? card;
  final CardSuggestion? suggestion;

  @override
  State<_CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<_CardDialog> {
  late final _bank = TextEditingController(
    text: widget.card?.bankCode ?? widget.suggestion?.bankCode ?? '',
  );
  late final _name = TextEditingController(
    text:
        widget.card?.name ??
        (widget.suggestion == null
            ? ''
            : '${widget.suggestion!.bankCode} credit card'),
  );
  late final _last4 = TextEditingController(
    text: widget.card?.last4 ?? widget.suggestion?.last4 ?? '',
  );
  late final _limit = TextEditingController(
    text: _rupees(
      widget.card?.creditLimitPaise ?? widget.suggestion?.creditLimitPaise,
    ),
  );
  late final _stmtDay = TextEditingController(
    text: widget.card?.statementDay?.toString() ?? '',
  );
  late final _dueDay = TextEditingController(
    text: widget.card?.dueDay?.toString() ?? '',
  );

  static String _rupees(int? paise) =>
      paise == null ? '' : (paise ~/ 100).toString();

  int? _day(TextEditingController c) {
    final v = int.tryParse(c.text.trim());
    return v != null && v >= 1 && v <= 31 ? v : null;
  }

  bool get _valid =>
      _bank.text.trim().isNotEmpty &&
      _name.text.trim().isNotEmpty &&
      (_last4.text.isEmpty || _last4.text.length == 4) &&
      (_stmtDay.text.isEmpty || _day(_stmtDay) != null) &&
      (_dueDay.text.isEmpty || _day(_dueDay) != null);

  @override
  void dispose() {
    for (final c in [_bank, _name, _last4, _limit, _stmtDay, _dueDay]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    void changed(String _) => setState(() {});
    return AlertDialog(
      title: Text(widget.card == null ? 'Track a card' : 'Edit card'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: changed,
            ),
            TextField(
              controller: _bank,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Bank',
                hintText: 'e.g. HDFC, AXIS, SBI',
              ),
              onChanged: changed,
            ),
            TextField(
              controller: _last4,
              keyboardType: TextInputType.number,
              inputFormatters: [...digits, LengthLimitingTextInputFormatter(4)],
              decoration: const InputDecoration(
                labelText: 'Last 4 digits',
                helperText: 'Leave empty if you have one card with this bank',
              ),
              onChanged: changed,
            ),
            TextField(
              controller: _limit,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(
                labelText: 'Credit limit',
                prefixText: '₹',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stmtDay,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: const InputDecoration(
                      labelText: 'Statement day',
                    ),
                    onChanged: changed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dueDay,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: const InputDecoration(labelText: 'Due day'),
                    onChanged: changed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        if (widget.card != null)
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(_CardForm(bankCode: '', name: '', delete: true)),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: !_valid
              ? null
              : () {
                  final lim = int.tryParse(_limit.text.trim());
                  Navigator.of(context).pop(
                    _CardForm(
                      bankCode: _bank.text.trim().toUpperCase(),
                      name: _name.text.trim(),
                      last4: _last4.text.isEmpty ? null : _last4.text,
                      limitPaise: lim == null || lim <= 0 ? null : lim * 100,
                      statementDay: _day(_stmtDay),
                      dueDay: _day(_dueDay),
                    ),
                  );
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

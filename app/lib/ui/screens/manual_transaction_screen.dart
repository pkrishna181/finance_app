import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Add a transaction by hand, or edit / delete one added earlier. Pops with
/// `true` when something was saved or deleted.
class ManualTransactionScreen extends StatefulWidget {
  const ManualTransactionScreen({
    super.key,
    required this.database,
    this.editId,
  });

  final ArthDatabase database;

  /// Id of a manual transaction to edit; null to add a new one.
  final int? editId;

  @override
  State<ManualTransactionScreen> createState() =>
      _ManualTransactionScreenState();
}

class _ManualTransactionScreenState extends State<ManualTransactionScreen> {
  late final _repo = ManualTransactionRepository(widget.database);
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  bool _isDebit = true;
  DateTime _date = DateTime.now();
  String? _category;
  String _account = kCashBankCode;
  List<Category> _categories = const [];
  List<String> _accounts = const [kCashBankCode];
  bool _loading = true;
  bool _saving = false;

  bool get _editing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await InsightsRepository(widget.database).pickableCategories();
    final accounts = await _repo.accounts();
    if (_editing) {
      final t = await _repo.get(widget.editId!);
      if (t != null) {
        final slug = t.categoryId == null
            ? null
            : cats.where((c) => c.id == t.categoryId).firstOrNull?.slug;
        _amount.text = _formatRupees(t.amountPaise);
        _desc.text = t.rawMerchant;
        _isDebit = t.direction == 'debit';
        _date = t.bookedAt;
        _category = slug;
        _account = t.bankCode;
        if (!accounts.contains(t.bankCode)) accounts.add(t.bankCode);
      }
    }
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _accounts = accounts;
      _loading = false;
    });
  }

  static String _formatRupees(int paise) => paise % 100 == 0
      ? (paise ~/ 100).toString()
      : (paise / 100).toStringAsFixed(2);

  int? get _paise {
    final v = double.tryParse(_amount.text.trim());
    if (v == null || v <= 0) return null;
    return (v * 100).round();
  }

  bool get _valid => _paise != null && _desc.text.trim().isNotEmpty;

  @override
  void dispose() {
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) {
      setState(() => _date = DateTime(d.year, d.month, d.day, 12));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    if (_editing) {
      await _repo.update(
        widget.editId!,
        amountPaise: _paise!,
        isDebit: _isDebit,
        bookedAt: _date,
        description: _desc.text,
        categorySlug: _category,
        bankCode: _account,
      );
    } else {
      await _repo.add(
        amountPaise: _paise!,
        isDebit: _isDebit,
        bookedAt: _date,
        description: _desc.text,
        categorySlug: _category,
        bankCode: _account,
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this transaction?'),
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
    await _repo.delete(widget.editId!);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit transaction' : 'Add transaction'),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Spent')),
                    ButtonSegment(value: false, label: Text('Received')),
                  ],
                  selected: {_isDebit},
                  onSelectionChanged: (v) => setState(() => _isDebit = v.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amount,
                  autofocus: !_editing,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: _desc,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'What for',
                    hintText: 'e.g. Vegetables at the market',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    for (final c in _categories)
                      if (c.slug != kUncategorizedSlug)
                        DropdownMenuItem(value: c.slug, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _account,
                  decoration: const InputDecoration(labelText: 'Paid with'),
                  items: [
                    for (final a in _accounts)
                      DropdownMenuItem(
                        value: a,
                        child: Text(a == kCashBankCode ? 'Cash' : a),
                      ),
                  ],
                  onChanged: (v) => setState(() => _account = v ?? _account),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text(
                    '${_date.day} ${monthShort(_date.month)} ${_date.year}',
                  ),
                  trailing: const Text('Change'),
                  onTap: _pickDate,
                ),
                if (_account == kCashBankCode && _isDebit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Tip: ATM withdrawals already count as spending. If you '
                      'log what you buy with that cash too, mark the '
                      'withdrawal as "Transfers (self)" so it isn\'t counted '
                      'twice.',
                      style: t.bodySmall,
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _valid && !_saving ? _save : null,
            child: const Text('Save'),
          ),
        ),
      ),
    );
  }
}

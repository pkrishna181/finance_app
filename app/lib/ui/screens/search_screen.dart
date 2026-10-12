import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import '../widgets/category_picker.dart';
import 'manual_transaction_screen.dart';

/// Search all transactions with [TxnQuery] syntax. Tap a row to change its
/// category; long-press to select rows and change them together.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.database, this.onChanged});

  final ArthDatabase database;

  /// Called after categories are changed (e.g. to reload Insights).
  final VoidCallback? onChanged;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _limit = 500;
  static const _examples = [
    'cat:none',
    '>1000',
    'debit',
    'in:2026-09',
    'bank:hdfc',
    'cat:groceries <500',
  ];

  final _field = TextEditingController();
  Timer? _debounce;
  List<InsightTxn> _results = const [];
  List<Category> _categories = const [];
  final Set<int> _selected = {};
  bool _searching = false;
  bool _busy = false;
  int _seq = 0;

  late final _repo = InsightsRepository(widget.database);

  bool get _selecting => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _repo.pickableCategories().then((c) {
      if (mounted) setState(() => _categories = c);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _run);
  }

  Future<void> _run() async {
    final q = TxnQuery.parse(_field.text);
    final seq = ++_seq;
    if (q.isEmpty) {
      setState(() {
        _results = const [];
        _selected.clear();
      });
      return;
    }
    setState(() => _searching = true);
    final rows = await _repo.search(q, limit: _limit);
    if (!mounted || seq != _seq) return;
    setState(() {
      _results = rows;
      _selected.retainAll(rows.map((r) => r.id));
      _searching = false;
    });
  }

  void _insertExample(String ex) {
    final text = _field.text.trim();
    _field.text = text.isEmpty ? ex : '$text $ex';
    _field.selection = TextSelection.collapsed(offset: _field.text.length);
    _run();
  }

  String _nameOf(String? slug) {
    final s = slug ?? kUncategorizedSlug;
    for (final c in _categories) {
      if (c.slug == s) return c.name;
    }
    return s;
  }

  Future<void> _editOne(InsightTxn t) async {
    if (t.isManual) {
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              ManualTransactionScreen(database: widget.database, editId: t.id),
        ),
      );
      if (changed == true) {
        widget.onChanged?.call();
        await _run();
      }
      return;
    }
    if (_categories.isEmpty) return;
    final similar = await _repo.similarTransactionIds(t);
    if (!mounted) return;
    final choice = await showCategoryPicker(
      context,
      title: 'Category for ${t.merchantLabel}',
      categories: _categories,
      current: t.categorySlug ?? kUncategorizedSlug,
      similarCount: similar.length,
    );
    if (choice == null) return;
    await _apply(
      () => _repo.recategorize(
        t,
        choice.slug,
        applyToMerchant: choice.applyToMerchant,
      ),
      choice.slug,
    );
  }

  Future<void> _editSelected() async {
    if (_categories.isEmpty) return;
    final rows = [
      for (final r in _results)
        if (_selected.contains(r.id)) r,
    ];
    final choice = await showCategoryPicker(
      context,
      title: 'Category for ${rows.length} transactions',
      categories: _categories,
    );
    if (choice == null) return;
    await _apply(() => _repo.recategorizeMany(rows, choice.slug), choice.slug);
    if (mounted) setState(_selected.clear);
  }

  Future<void> _apply(Future<int> Function() change, String slug) async {
    setState(() => _busy = true);
    try {
      final n = await change();
      widget.onChanged?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            n == 1
                ? 'Moved to ${_nameOf(slug)}'
                : 'Moved $n transactions to ${_nameOf(slug)}',
          ),
        ),
      );
      await _run();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not change category')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggle(InsightTxn t) => setState(() {
    if (!_selected.remove(t.id)) _selected.add(t.id);
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final out = _results
        .where((r) => r.isDebit)
        .fold<int>(0, (s, r) => s + r.amountPaise);
    final inn = _results
        .where((r) => !r.isDebit)
        .fold<int>(0, (s, r) => s + r.amountPaise);
    final showBar = _searching || _busy;
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_selected.clear);
      },
      child: Scaffold(
        appBar: _selecting
            ? AppBar(
                leading: IconButton(
                  tooltip: 'Clear selection',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(_selected.clear),
                ),
                title: Text('${_selected.length} selected'),
                actions: [
                  IconButton(
                    tooltip: 'Select all',
                    icon: const Icon(Icons.select_all),
                    onPressed: () => setState(
                      () => _selected.addAll(_results.map((r) => r.id)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Change category',
                    icon: const Icon(Icons.label_outline),
                    onPressed: _busy ? null : _editSelected,
                  ),
                ],
              )
            : AppBar(
                title: TextField(
                  controller: _field,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search transactions',
                    border: InputBorder.none,
                  ),
                  onChanged: _onChanged,
                  onSubmitted: (_) => _run(),
                ),
                actions: [
                  if (_field.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _field.clear();
                        _run();
                      },
                    ),
                ],
              ),
        body: Column(
          children: [
            SizedBox(
              height: 2,
              child: showBar ? const LinearProgressIndicator() : null,
            ),
            if (TxnQuery.parse(_field.text).isEmpty)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Try', style: t.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final ex in _examples)
                          ActionChip(
                            label: Text(ex),
                            onPressed: () => _insertExample(ex),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Words match the merchant or description. '
                      'cat: category (or cat:none) · >, <, = amount in ₹ · '
                      'from:/to: yyyy-mm-dd · in: yyyy-mm · '
                      'debit / credit · bank: · "quoted phrases".\n'
                      'Long-press a result to select several.',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_results.length == _limit ? 'First $_limit' : _results.length} '
                    'result${_results.length == 1 ? '' : 's'}'
                    '${out > 0 ? ' · out ${inrWhole(out)}' : ''}'
                    '${inn > 0 ? ' · in ${inrWhole(inn)}' : ''}',
                    style: t.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: _results.isEmpty
                    ? Center(child: Text(_searching ? '' : 'No matches.'))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final r = _results[i];
                          final d = r.bookedAt;
                          final sel = _selected.contains(r.id);
                          return ListTile(
                            selected: sel,
                            leading: _selecting
                                ? Icon(
                                    sel
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                  )
                                : null,
                            title: Text(
                              r.merchantLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${d.day} ${monthShort(d.month)} ${d.year}'
                              ' · ${r.bankCode} · ${_nameOf(r.categorySlug)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${r.isDebit ? '-' : '+'}'
                              '${inrWhole(r.amountPaise)}',
                              style: TextStyle(
                                color: r.isDebit
                                    ? scheme.error
                                    : scheme.primary,
                              ),
                            ),
                            onTap: _busy
                                ? null
                                : _selecting
                                ? () => _toggle(r)
                                : () => _editOne(r),
                            onLongPress: _busy ? null : () => _toggle(r),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

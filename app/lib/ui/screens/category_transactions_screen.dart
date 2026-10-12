import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';
import '../widgets/category_picker.dart';
import 'manual_transaction_screen.dart';

/// The transactions behind an Insights number. With a [database], tapping a
/// row recategorizes it (optionally every row from the same merchant).
class CategoryTransactionsScreen extends StatefulWidget {
  const CategoryTransactionsScreen({
    super.key,
    required this.title,
    required this.txns,
    this.database,
    this.onChanged,
  });

  final String title;
  final List<InsightTxn> txns;
  final ArthDatabase? database;

  /// Called after a category change is saved (e.g. to reload Insights).
  final VoidCallback? onChanged;

  @override
  State<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends State<CategoryTransactionsScreen> {
  late List<InsightTxn> _txns = [...widget.txns];
  List<Category> _categories = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = widget.database;
    if (db == null) return;
    final cats = await InsightsRepository(db).pickableCategories();
    if (mounted) setState(() => _categories = cats);
  }

  String _nameOf(String? slug) {
    final s = slug ?? kUncategorizedSlug;
    for (final c in _categories) {
      if (c.slug == s) return c.name;
    }
    return s;
  }

  Future<void> _editManual(int index) async {
    final db = widget.database!;
    final t = _txns[index];
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManualTransactionScreen(database: db, editId: t.id),
      ),
    );
    if (changed != true || !mounted) return;
    final fresh = await InsightsRepository(db).loadByIds([t.id]);
    if (!mounted) return;
    setState(() {
      _txns = [
        for (final x in _txns)
          if (x.id != t.id) x else ...fresh,
      ];
    });
    widget.onChanged?.call();
  }

  Future<void> _edit(int index) async {
    final db = widget.database;
    if (db == null || _busy || _categories.isEmpty) return;
    final t = _txns[index];
    if (t.isManual) return _editManual(index);
    final repo = InsightsRepository(db);
    final similar = await repo.similarTransactionIds(t);
    if (!mounted) return;
    final choice = await showCategoryPicker(
      context,
      title: 'Category for ${t.merchantLabel}',
      categories: _categories,
      current: t.categorySlug ?? kUncategorizedSlug,
      similarCount: similar.length,
    );
    if (choice == null || !mounted) return;
    if (choice.slug == (t.categorySlug ?? kUncategorizedSlug) &&
        !choice.applyToMerchant) {
      return;
    }
    setState(() => _busy = true);
    try {
      final n = await repo.recategorize(
        t,
        choice.slug,
        applyToMerchant: choice.applyToMerchant,
      );
      if (!mounted) return;
      final changed = {t.id, if (choice.applyToMerchant) ...similar};
      setState(() {
        _txns = [
          for (final x in _txns)
            changed.contains(x.id) ? _withCategory(x, choice.slug) : x,
        ];
      });
      final label = _nameOf(choice.slug);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(n == 1
              ? 'Moved to $label'
              : 'Moved $n transactions to $label'),
        ),
      );
      widget.onChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not change category')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editable = widget.database != null && _categories.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _txns.isEmpty
          ? const Center(child: Text('No transactions.'))
          : ListView.separated(
              itemCount: _txns.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = _txns[i];
                final d = t.bookedAt;
                final date = '${d.day} ${monthShort(d.month)} ${d.year}'
                    ' · ${t.bankCode}';
                return ListTile(
                  title: Text(
                    t.merchantLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    editable ? '$date · ${_nameOf(t.categorySlug)}' : date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${t.isDebit ? '-' : '+'}${inrWhole(t.amountPaise)}',
                    style: TextStyle(
                      color: t.isDebit ? scheme.error : scheme.primary,
                    ),
                  ),
                  onTap: editable ? () => _edit(i) : null,
                );
              },
            ),
    );
  }
}

InsightTxn _withCategory(InsightTxn t, String slug) => InsightTxn(
      id: t.id,
      amountPaise: t.amountPaise,
      isDebit: t.isDebit,
      bookedAt: t.bookedAt,
      bankCode: t.bankCode,
      accountHint: t.accountHint,
      txnType: t.txnType,
      categorySlug: slug,
      categorySource: 'user',
      merchantId: t.merchantId,
      merchantName: t.merchantName,
      rawMerchant: t.rawMerchant,
      balanceAfterPaise: t.balanceAfterPaise,
      accountKind: t.accountKind,
      isManual: t.isManual,
    );

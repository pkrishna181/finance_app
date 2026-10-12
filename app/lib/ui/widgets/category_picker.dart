import 'package:flutter/material.dart';

import '../../core/db/database.dart';

/// Result of [showCategoryPicker].
class CategoryChoice {
  const CategoryChoice(this.slug, this.applyToMerchant);
  final String slug;

  /// "Also apply to N other transactions" was switched on.
  final bool applyToMerchant;
}

/// Bottom sheet listing [categories]; with [similarCount] > 0 it also offers
/// to apply the choice to that many other rows from the same merchant.
Future<CategoryChoice?> showCategoryPicker(
  BuildContext context, {
  required String title,
  required List<Category> categories,
  String? current,
  int similarCount = 0,
}) {
  return showModalBottomSheet<CategoryChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CategoryPicker(
      title: title,
      categories: categories,
      current: current,
      similarCount: similarCount,
    ),
  );
}

class _CategoryPicker extends StatefulWidget {
  const _CategoryPicker({
    required this.title,
    required this.categories,
    required this.current,
    required this.similarCount,
  });

  final String title;
  final List<Category> categories;
  final String? current;
  final int similarCount;

  @override
  State<_CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<_CategoryPicker> {
  bool _applyAll = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.similarCount;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (n > 0)
            SwitchListTile(
              value: _applyAll,
              onChanged: (v) => setState(() => _applyAll = v),
              title: Text(
                'Also apply to $n other '
                '${n == 1 ? 'transaction' : 'transactions'}',
              ),
              subtitle: const Text(
                'Same merchant; future imports will follow too. '
                'Rows you set by hand are left alone.',
              ),
            ),
          const Divider(height: 1),
          for (final c in widget.categories)
            ListTile(
              title: Text(c.name),
              trailing: c.slug == widget.current
                  ? const Icon(Icons.check)
                  : null,
              onTap: () =>
                  Navigator.of(context).pop(CategoryChoice(c.slug, _applyAll)),
            ),
        ],
      ),
    );
  }
}

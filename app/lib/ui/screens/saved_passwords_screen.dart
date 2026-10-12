import 'package:flutter/material.dart';

import '../../ingestion/statement/pdf/password_vault.dart';

/// Lists remembered statement passwords by name (never showing them) and
/// lets the user add, rename or delete them.
class SavedPasswordsScreen extends StatefulWidget {
  const SavedPasswordsScreen({super.key, this.vault});

  final PdfPasswordVault? vault;

  @override
  State<SavedPasswordsScreen> createState() => _SavedPasswordsScreenState();
}

class _SavedPasswordsScreenState extends State<SavedPasswordsScreen> {
  late final _vault = widget.vault ?? PdfPasswordVault();
  List<SavedPdfPassword>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _vault.list();
    items.sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    if (mounted) setState(() => _items = items);
  }

  Future<void> _add() async {
    final r = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _EditDialog(),
    );
    if (r == null) return;
    await _vault.add(r.$1, r.$2);
    await _load();
  }

  Future<void> _rename(SavedPdfPassword p) async {
    final r = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _EditDialog(initialLabel: p.label),
    );
    if (r == null) return;
    await _vault.rename(p.id, r.$1);
    await _load();
  }

  Future<void> _delete(SavedPdfPassword p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Forget "${p.label}"?'),
        content: const Text(
          'You will be asked for this password next time a statement needs it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _vault.remove(p.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Statement passwords')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Saved passwords unlock statement PDFs automatically. '
                    'They are kept in this phone\'s secure storage (Android '
                    'Keystore / iOS Keychain), are never shown again, and '
                    'never leave the device.',
                    style: t.bodySmall,
                  ),
                ),
                if (items.isEmpty)
                  const ListTile(
                    title: Text('No saved passwords'),
                    subtitle: Text(
                      'Add one now, or tick "Remember" when a statement '
                      'asks for its password.',
                    ),
                  ),
                for (final p in items)
                  ListTile(
                    leading: const Icon(Icons.key_outlined),
                    title: Text(p.label),
                    subtitle: Text(
                      [
                        if (p.bankCode != null)
                          'Opens ${p.bankCode} statements',
                        if (p.lastUsed != null)
                          'Last used ${p.lastUsed!.day}/${p.lastUsed!.month}/${p.lastUsed!.year}',
                      ].join(' · '),
                    ),
                    onTap: () => _rename(p),
                    trailing: IconButton(
                      tooltip: 'Forget',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(p),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Name + password (new) or name only (rename).
class _EditDialog extends StatefulWidget {
  const _EditDialog({this.initialLabel});
  final String? initialLabel;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final _label = TextEditingController(text: widget.initialLabel);
  final _password = TextEditingController();
  bool get _renaming => widget.initialLabel != null;

  bool get _valid =>
      _label.text.trim().isNotEmpty && (_renaming || _password.text.isNotEmpty);

  @override
  void dispose() {
    _label.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_renaming ? 'Rename' : 'Add statement password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _label,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. SBI credit card',
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (!_renaming)
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (_) => setState(() {}),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _valid
              ? () => Navigator.of(
                  context,
                ).pop((_label.text.trim(), _password.text))
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

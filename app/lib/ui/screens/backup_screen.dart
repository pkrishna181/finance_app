import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/backup/backup_crypto.dart';
import '../../core/backup/backup_service.dart';
import '../../core/db/database.dart';
import '../../ingestion/statement/pdf/password_vault.dart';

/// Create an encrypted backup file, or restore one (replacing all data).
class BackupScreen extends StatefulWidget {
  const BackupScreen({
    super.key,
    this.database,
    this.saveFile,
    this.pickFile,
    this.iterations,
  });

  final ArthDatabase? database;

  /// Overrides for tests: write bytes under a name / pick a file's bytes.
  final Future<String?> Function(String name, Uint8List bytes)? saveFile;
  final Future<Uint8List?> Function()? pickFile;
  final int? iterations;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  ArthDatabase? _db;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final db = widget.database ?? await ArthDatabase.openEncrypted();
    if (mounted) setState(() => _db = db);
  }

  BackupService get _service => BackupService(
        _db!,
        vault: PdfPasswordVault(),
        iterations: widget.iterations,
      );

  void _say(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static String _err(Object e) => switch (e) {
        BackupException(code: 'wrong_passphrase') =>
          'Wrong passphrase, or the file is damaged.',
        BackupException(code: 'not_a_backup') => 'That isn\'t an Arth backup.',
        BackupException(code: 'newer_version') =>
          'This backup is from a newer version of Arth — update the app first.',
        _ => 'Couldn\'t read that backup.',
      };

  Future<void> _create() async {
    final r = await showDialog<(String, bool)>(
      context: context,
      builder: (_) => const _PassphraseDialog(create: true),
    );
    if (r == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await _service.export(r.$1, includePasswords: r.$2);
      final now = DateTime.now();
      final name = 'arth-backup-${now.year}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}.arthbak';
      final saved = await (widget.saveFile ?? _defaultSave)(name, bytes);
      _say(saved == null ? 'Backup not saved.' : 'Backup saved.');
    } catch (e) {
      _say('Backup failed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static Future<String?> _defaultSave(String name, Uint8List bytes) =>
      FilePicker.platform.saveFile(
        dialogTitle: 'Save Arth backup',
        fileName: name,
        bytes: bytes,
      );

  static Future<Uint8List?> _defaultPick() async {
    final r = await FilePicker.platform.pickFiles(withData: true);
    final f = r?.files.singleOrNull;
    if (f == null) return null;
    return f.bytes ??
        (f.path == null ? null : await File(f.path!).readAsBytes());
  }

  Future<void> _restore() async {
    final bytes = await (widget.pickFile ?? _defaultPick)();
    if (bytes == null || !mounted) return;
    final r = await showDialog<(String, bool)>(
      context: context,
      builder: (_) => const _PassphraseDialog(create: false),
    );
    if (r == null) return;
    setState(() => _busy = true);
    try {
      final s = await _service.inspect(bytes, r.$1);
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Replace all data?'),
          content: Text(
            'Backup from ${s.createdAt.day}/${s.createdAt.month}/'
            '${s.createdAt.year} with ${s.transactions} transactions'
            '${s.savedPasswords > 0 ? ' and ${s.savedPasswords} saved passwords' : ''}. '
            'Everything currently in Arth will be replaced.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await _service.restore(bytes, r.$1);
      _say('Restored. Restart Arth to see everything.');
    } catch (e) {
      _say(_err(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ready = _db != null && !_busy;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & restore'),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'A backup is one file, encrypted with a passphrase you choose '
            '(AES-256). Keep it wherever you like — Arth never uploads it. '
            'Without the passphrase it can\'t be opened, by you or anyone.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: ready ? _create : null,
            icon: const Icon(Icons.save_alt),
            label: const Text('Create backup'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: ready ? _restore : null,
            icon: const Icon(Icons.settings_backup_restore),
            label: const Text('Restore from backup'),
          ),
          const SizedBox(height: 16),
          Text(
            'Restoring replaces everything in Arth with the backup. The AI '
            'model and app settings aren\'t included.',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.create});
  final bool create;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  bool _withPasswords = false;
  bool _obscure = true;

  static const minLength = 10;

  bool get _valid => widget.create
      ? _p1.text.length >= minLength && _p1.text == _p2.text
      : _p1.text.isNotEmpty;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void changed(String _) => setState(() {});
    return AlertDialog(
      title: Text(widget.create ? 'Choose a passphrase' : 'Backup passphrase'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _p1,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Passphrase',
                helperText: widget.create
                    ? 'At least $minLength characters. A few unrelated words '
                        'work well.'
                    : null,
                helperMaxLines: 2,
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show' : 'Hide',
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onChanged: changed,
            ),
            if (widget.create) ...[
              TextField(
                controller: _p2,
                obscureText: _obscure,
                decoration: const InputDecoration(labelText: 'Repeat it'),
                onChanged: changed,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _withPasswords,
                onChanged: (v) => setState(() => _withPasswords = v ?? false),
                title: const Text('Include saved statement passwords'),
              ),
              Text(
                'If you forget this passphrase the backup is lost — there is '
                'no recovery.',
                style: t.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _valid
              ? () => Navigator.of(context).pop((_p1.text, _withPasswords))
              : null,
          child: Text(widget.create ? 'Create' : 'Open'),
        ),
      ],
    );
  }
}

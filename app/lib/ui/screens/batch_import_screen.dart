import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../ingestion/statement/batch_import.dart';
import '../../ingestion/statement/file_source.dart';
import '../../ingestion/statement/pdf/password_vault.dart';
import '../widgets/pdf_password_dialog.dart';

/// Imports several statements one after another and shows how each went.
class BatchImportScreen extends StatefulWidget {
  const BatchImportScreen({
    super.key,
    required this.files,
    required this.db,
    required this.source,
    this.vault,
  });

  final List<StatementFile> files;
  final ArthDatabase db;
  final StatementFileSource source;
  final PdfPasswordVault? vault;

  @override
  State<BatchImportScreen> createState() => _BatchImportScreenState();
}

class _BatchImportScreenState extends State<BatchImportScreen> {
  List<BatchFileResult> _results = const [];
  StreamSubscription<List<BatchFileResult>>? _sub;

  bool get _finished => _results.isNotEmpty && _results.every((r) => r.done);

  @override
  void initState() {
    super.initState();
    final importer = StatementBatchImporter(
      db: widget.db,
      source: widget.source,
      vault: widget.vault ?? PdfPasswordVault(),
      askPassword: (name, failed, saved) async {
        if (!mounted) return null;
        return showPdfPasswordDialog(
          context,
          fileName: name,
          failedAsks: failed,
          savedTried: saved,
        );
      },
    );
    _sub = importer.run(widget.files).listen((r) {
      if (mounted) setState(() => _results = r);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final inserted = _results.fold<int>(0, (s, r) => s + r.inserted);
    final ok = _results.where((r) => r.status == BatchFileStatus.imported);
    final problems = _results.where(
      (r) =>
          r.status == BatchFileStatus.failed ||
          r.status == BatchFileStatus.skipped,
    );
    final doneCount = _results.where((r) => r.done).length;
    return PopScope(
      canPop: _finished,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: _finished,
          title: Text(
            _finished
                ? 'Import finished'
                : 'Importing $doneCount of ${widget.files.length}',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (!_finished)
              LinearProgressIndicator(
                value: widget.files.isEmpty
                    ? null
                    : doneCount / widget.files.length,
              ),
            if (_finished)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '$inserted new transaction${inserted == 1 ? '' : 's'} '
                  'from ${ok.length} of ${_results.length} '
                  'file${_results.length == 1 ? '' : 's'}'
                  '${problems.isEmpty ? '' : ' · ${problems.length} need attention'}',
                  style: t.titleMedium,
                ),
              ),
            for (final r in _results) _ResultTile(result: r),
          ],
        ),
        bottomNavigationBar: _finished
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(inserted),
                    child: const Text('Done'),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});
  final BatchFileResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = result;
    final (Widget icon, String subtitle) = switch (r.status) {
      BatchFileStatus.pending => (
        Icon(Icons.schedule, color: scheme.outline),
        'Waiting',
      ),
      BatchFileStatus.working => (
        const SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        'Reading…',
      ),
      BatchFileStatus.imported => (
        Icon(Icons.check_circle, color: scheme.primary),
        [
          if (r.bankCode != null && r.bankCode != 'UNKNOWN') r.bankCode!,
          '${r.inserted} new',
          if (r.duplicates > 0) '${r.duplicates} already had',
          if (r.unparsed > 0) '${r.unparsed} to review',
        ].join(' · '),
      ),
      BatchFileStatus.alreadyImported => (
        Icon(Icons.check_circle_outline, color: scheme.outline),
        r.message ?? 'Already imported',
      ),
      BatchFileStatus.skipped => (
        Icon(Icons.lock_outline, color: scheme.error),
        r.message ?? 'Skipped',
      ),
      BatchFileStatus.failed => (
        Icon(Icons.error_outline, color: scheme.error),
        r.message ?? 'Failed',
      ),
    };
    return ListTile(
      leading: icon,
      title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
    );
  }
}

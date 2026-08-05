import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/result/result.dart';
import '../../ingestion/registry.dart';
import '../../ingestion/sms/consent_screen.dart';
import '../../ingestion/sms/sms_source.dart';
import '../../ingestion/source.dart';
import '../../ingestion/statement/file_source.dart';
import '../../ingestion/statement/pdf/password_hints.dart';
import '../../llm/jobs/llm_job_service.dart';
import '../../llm/llm_review_service.dart';
import 'llm_resolve_screen.dart';
import 'statement_preview_screen.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key, this.database});

  /// Optional injected DB (tests). Production opens encrypted on demand.
  final ArthDatabase? database;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  ArthDatabase? _db;

  @override
  void initState() {
    super.initState();
    _openDb();
  }

  Future<void> _openDb() async {
    if (widget.database != null) {
      setState(() => _db = widget.database);
      return;
    }
    try {
      final db = await ArthDatabase.openEncrypted();
      if (mounted) setState(() => _db = db);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final registry = IngestionRegistry();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import'),
        actions: [
          if (_db != null)
            StreamBuilder<int>(
              stream: _db!.watchUnresolvedUnparsedSmsCount(),
              builder: (context, snap) {
                final n = snap.data ?? 0;
                if (n == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () async {
                    final rows = await _db!.listUnresolvedUnparsedSms();
                    final jobs = LlmJobService(_db!);
                    for (final row in rows) {
                      await jobs.enqueueSmsExtract(row.id);
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LlmResolveScreen(
                          db: _db!,
                          reviewService: LlmReviewService(db: _db!),
                        ),
                      ),
                    );
                  },
                  child: Text('$n unrecognized — resolve'),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose a source',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...registry.sources.map((source) {
            final available =
                source.availability == SourceAvailability.available;
            final subtitle = switch (source.availability) {
              SourceAvailability.available => 'Available on this device',
              SourceAvailability.unsupportedOnPlatform =>
                'Not available on this platform — use statement import',
              SourceAvailability.notImplemented => 'Coming soon',
            };
            return ListTile(
              leading: Icon(_iconFor(source.id)),
              title: Text(source.displayName),
              subtitle: Text(subtitle),
              enabled: available,
              onTap: available ? () => _onSourceTap(context, source) : null,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _onSourceTap(
    BuildContext context,
    IngestionSource source,
  ) async {
    if (source is SmsIngestionSource) {
      final consent = SmsConsentStore();
      if (!await consent.hasConsent()) {
        if (!context.mounted) return;
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (ctx) => SmsConsentScreen(
              onAccepted: () async {
                Navigator.of(ctx).pop();
                final result = await source.requestPermission();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.isOk
                          ? 'SMS permission granted.'
                          : 'SMS permission not granted — statement import still works.',
                    ),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }
      final result = await source.requestPermission();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isOk
                ? 'SMS ready for historical scan.'
                : 'SMS permission denied — statement import still works.',
          ),
        ),
      );
      return;
    }

    if (source is StatementFileSource) {
      final db = widget.database ?? await ArthDatabase.openEncrypted();
      if (!context.mounted) return;

      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xls', 'xlsx', 'pdf'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.single;
      final bytes = file.bytes ??
          (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file.')),
        );
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parsing statement…')),
      );

      Result<StatementImportPreview> preview = const Err('not_started');
      var bankHint = passwordHintForBank(null);

      while (true) {
        preview = await source.previewBytes(
          db: db,
          bytes: Uint8List.fromList(bytes),
          fileName: file.name,
          passwordProvider: file.name.toLowerCase().endsWith('.pdf')
              ? (_) async {
                  if (!context.mounted) return null;
                  return _promptPdfPassword(context, bankHint);
                }
              : null,
        );
        if (!context.mounted) return;
        if (preview.isOk) break;
        final code = preview.errorOrNull;
        if (code == 'pdf_password_required') {
          bankHint = passwordHintForBank(null);
          continue;
        }
        break;
      }

      await preview.when(
        ok: (p) async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => StatementPreviewScreen(
                preview: p,
                db: db,
                source: source,
              ),
            ),
          );
        },
        err: (msg, _) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                statementImportErrorMessage(msg, bankCode: bankHint),
              ),
            ),
          );
        },
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${source.displayName}: not available yet.'),
      ),
    );
  }

  Future<String?> _promptPdfPassword(
    BuildContext context,
    String? hint,
  ) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('PDF password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hint != null) ...[
                Text(hint),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                onSubmitted: (_) =>
                    Navigator.of(ctx).pop(controller.text.trim()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }

  IconData _iconFor(String id) {
    return switch (id) {
      'sms' => Icons.sms_outlined,
      'statement' => Icons.table_chart_outlined,
      'pdf' => Icons.picture_as_pdf_outlined,
      'csv' => Icons.table_chart_outlined,
      _ => Icons.input,
    };
  }
}

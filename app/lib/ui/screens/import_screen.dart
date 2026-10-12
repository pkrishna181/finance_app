import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../core/db/database.dart';
import '../../ingestion/registry.dart';
import '../../ingestion/sms/consent_screen.dart';
import '../../ingestion/sms/sms_source.dart';
import '../../ingestion/source.dart';
import '../../ingestion/statement/file_source.dart';
import '../../ingestion/statement/batch_import.dart';
import '../../ingestion/statement/pdf/password_vault.dart';
import '../../llm/jobs/llm_batch_coordinator.dart';
import '../../llm/llm_resolve_flow.dart';
import '../widgets/pdf_password_dialog.dart';
import 'batch_import_screen.dart';
import 'sms_historical_scan_screen.dart';
import 'statement_preview_screen.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({
    super.key,
    this.database,
    this.registry,
    this.consentStore,
    this.coordinator,
    this.showUnparsedBadge = true,
    this.vault,
    this.pickFiles,
  });

  /// Optional injected DB (tests). Production opens encrypted on demand.
  final ArthDatabase? database;

  /// Optional registry override (tests).
  final IngestionRegistry? registry;

  /// Optional consent store override (tests).
  final SmsConsentStore? consentStore;

  /// Opportunistic LLM batch runner (Phase 5.5).
  final LlmBatchCoordinator? coordinator;

  /// When false, skips the unresolved-SMS badge stream (widget tests).
  final bool showUnparsedBadge;

  /// Statement password vault override (tests).
  final PdfPasswordVault? vault;

  /// File picker override (tests). Returns null when cancelled.
  final Future<List<StatementFile>?> Function()? pickFiles;

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
      final db = await ArthDatabase.shared();
      if (mounted) setState(() => _db = db);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final registry = widget.registry ?? IngestionRegistry();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import'),
        actions: [
          if (_db != null && widget.showUnparsedBadge)
            StreamBuilder<int>(
              stream: _db!.watchUnresolvedUnparsedSmsCount(),
              builder: (context, snap) {
                final n = snap.data ?? 0;
                if (n == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () async {
                    final coordinator = widget.coordinator;
                    if (coordinator == null || !context.mounted) return;
                    await openLlmResolveFlow(
                      context,
                      db: _db!,
                      coordinator: coordinator,
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
      await _startSmsHistoricalScan(context, source);
      return;
    }

    if (source is StatementFileSource) {
      final db = widget.database ?? await ArthDatabase.shared();
      if (!context.mounted) return;

      final picked = await (widget.pickFiles ?? _pickStatementFiles)();
      if (picked == null || picked.isEmpty || !context.mounted) return;
      final vault = widget.vault ?? PdfPasswordVault();

      if (picked.length > 1) {
        await Navigator.of(context).push<int>(
          MaterialPageRoute(
            builder: (_) => BatchImportScreen(
              files: picked,
              db: db,
              source: source,
              vault: vault,
            ),
          ),
        );
        return;
      }

      final file = picked.single;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parsing statement…')),
      );
      late final PdfUnlockSession session;
      session = PdfUnlockSession(
        vault: vault,
        fileName: file.name,
        ask: (failed) async {
          if (!context.mounted) return null;
          return showPdfPasswordDialog(
            context,
            fileName: file.name,
            failedAsks: failed,
            savedTried: session.savedTried,
          );
        },
      );
      final opened = await openStatementFile(
        db: db,
        source: source,
        file: file,
        session: session,
      );
      if (!context.mounted) return;

      await opened.when(
        ok: (o) async {
          switch (o) {
            case OpenedCas(:final result):
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('${result.providerLabel} statement imported'),
                  content: Text(casSummary(result)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            case OpenedStatement(:final preview):
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => StatementPreviewScreen(
                    preview: preview,
                    db: db,
                    source: source,
                  ),
                ),
              );
          }
        },
        err: (msg, _) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg == 'cas_empty'
                    ? 'This looks like an investment statement, but no '
                        'holdings could be read.'
                    : statementImportErrorMessage(
                        msg,
                        bankCode: guessIssuer(file.name),
                      ),
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

  Future<void> _startSmsHistoricalScan(
    BuildContext context,
    SmsIngestionSource source,
  ) async {
    final consent = widget.consentStore ?? SmsConsentStore();
    if (!await consent.hasConsent()) {
      if (!context.mounted) return;
      final accepted = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (ctx) => SmsConsentScreen(
            onAccepted: () => Navigator.of(ctx).pop(true),
            onDeclined: () => Navigator.of(ctx).pop(false),
          ),
        ),
      );
      if (accepted != true) return;
    }

    final result = await source.requestPermission();
    if (!context.mounted) return;
    if (result.isErr) {
      await _showSmsPermissionError(context, result.errorOrNull);
      return;
    }

    final db = _db;
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database not ready — try again.')),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SmsHistoricalScanScreen(
          source: source,
          db: db,
          coordinator: widget.coordinator,
        ),
      ),
    );
  }

  Future<void> _showSmsPermissionError(
    BuildContext context,
    String? code,
  ) async {
    final permanently = code == 'sms_permission_permanently_denied';
    final consentRequired = code == 'sms_consent_required';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SMS access'),
        content: Text(
          consentRequired
              ? 'SMS consent is required before Arth can read transaction messages.'
              : permanently
                  ? 'SMS read permission was denied. Open Settings to grant '
                      'READ_SMS, or import a bank statement instead.'
                  : 'SMS read permission is required for a historical scan. '
                      'Statement import still works.',
        ),
        actions: [
          if (permanently)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<List<StatementFile>?> _pickStatementFiles() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xls', 'xlsx', 'pdf'],
      allowMultiple: true,
      withData: true,
    );
    if (picked == null) return null;
    final out = <StatementFile>[];
    for (final f in picked.files) {
      final bytes = f.bytes ??
          (f.path != null ? await File(f.path!).readAsBytes() : null);
      if (bytes != null) {
        out.add((name: f.name, bytes: Uint8List.fromList(bytes)));
      }
    }
    return out;
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

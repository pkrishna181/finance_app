import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../ingestion/sms/sms_scan_checkpoint.dart';
import '../../ingestion/sms/sms_scan_session.dart';
import '../../ingestion/sms/sms_source.dart';
import '../../llm/jobs/llm_job_service.dart';
import '../../llm/llm_review_service.dart';
import 'llm_resolve_screen.dart';

/// Runs [SmsIngestionSource.scanHistorical] with cancel, resume, and progress UI.
class SmsHistoricalScanScreen extends StatefulWidget {
  const SmsHistoricalScanScreen({
    super.key,
    required this.source,
    required this.db,
    this.restart = false,
  });

  final SmsIngestionSource source;
  final ArthDatabase db;

  /// When true, clears any saved checkpoint before scanning.
  final bool restart;

  @override
  State<SmsHistoricalScanScreen> createState() =>
      _SmsHistoricalScanScreenState();
}

class _SmsHistoricalScanScreenState extends State<SmsHistoricalScanScreen>
    with WidgetsBindingObserver {
  final _session = SmsScanSession();
  SmsIngestProgress? _progress;
  Object? _error;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _maybeStartScan();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_scanning && !_session.isCancelled) {
        _session.requestCancel();
      }
    }
  }

  Future<void> _maybeStartScan() async {
    if (widget.restart) {
      await _runScan(restart: true);
      return;
    }

    final checkpoint = await widget.source.checkpointStore.load();
    if (checkpoint == null) {
      await _runScan(restart: false);
      return;
    }

    if (!mounted) return;
    final choice = await showDialog<_ScanChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resume SMS scan?'),
        content: Text(
          'Previous scan stopped after ${checkpoint.scanned} messages '
          '(${checkpoint.parsed} transactions, ${checkpoint.unparsed} unrecognized).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_ScanChoice.restart),
            child: const Text('Restart'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_ScanChoice.continue_),
            child: const Text('Continue scan'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (choice == null) {
      Navigator.of(context).pop();
      return;
    }

    await _runScan(restart: choice == _ScanChoice.restart);
  }

  Future<void> _runScan({required bool restart}) async {
    setState(() {
      _scanning = true;
      _error = null;
    });

    try {
      await for (final event in widget.source.scanHistorical(
        db: widget.db,
        restart: restart,
        session: _session,
      )) {
        if (!mounted) return;
        setState(() => _progress = event);
        if (event.error != null) {
          setState(() {
            _error = event.error;
            _scanning = false;
          });
          return;
        }
        if (event.done) {
          setState(() => _scanning = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _scanning = false;
        });
      }
    }
  }

  void _requestStop() {
    if (!_scanning || _session.isCancelled) return;
    _session.requestCancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stopping after current chunk…'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _resolveUnrecognized() async {
    final rows = await widget.db.listUnresolvedUnparsedSms();
    final jobs = LlmJobService(widget.db);
    for (final row in rows) {
      await jobs.enqueueSmsExtract(row.id);
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LlmResolveScreen(
          db: widget.db,
          reviewService: LlmReviewService(db: widget.db),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    final done = p?.done ?? false;
    final error = _error ?? p?.error;
    final cancelled = p?.cancelled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS scan'),
        automaticallyImplyLeading: done || error != null || cancelled,
        actions: [
          if (_scanning && !done)
            TextButton(
              onPressed: _requestStop,
              child: const Text('Stop scan'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage(error.toString()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else if (p == null) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Starting SMS scan…'),
            ] else if (!done) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _scannedLine(p),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Transactions found: ${p.parsed} (${p.inserted} new)'),
              Text('Unrecognized: ${p.unparsed}'),
              Text('Skipped (non-transactional): ${p.skipped}'),
              if (p.mandates > 0) Text('Mandate notices: ${p.mandates}'),
              if (p.lastChunkMs != null && p.chunkMessageCount != null)
                Text(
                  'Last chunk: ${p.chunkMessageCount} candidates, ${p.lastChunkMs}ms',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ] else if (cancelled) ...[
              Icon(
                Icons.pause_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Scan paused',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(_stoppedSummary(p)),
              const SizedBox(height: 24),
              if (p.unparsed > 0) ...[
                FilledButton(
                  onPressed: _resolveUnrecognized,
                  child: Text('${p.unparsed} unrecognized — resolve'),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ] else ...[
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Scan complete',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(_scannedLine(p)),
              Text('Transactions found: ${p.parsed} (${p.inserted} new)'),
              Text('Unrecognized: ${p.unparsed}'),
              Text('Skipped (non-transactional): ${p.skipped}'),
              if (p.mandates > 0) Text('Mandate notices: ${p.mandates}'),
              const SizedBox(height: 24),
              if (p.unparsed > 0) ...[
                FilledButton(
                  onPressed: _resolveUnrecognized,
                  child: Text('${p.unparsed} unrecognized — resolve'),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _scannedLine(SmsIngestProgress p) {
    final total = p.estimatedTotal;
    if (total != null && total > 0) {
      return 'Scanned ${p.scanned} of ~$total messages';
    }
    return 'Scanned ${p.scanned} messages';
  }

  String _stoppedSummary(SmsIngestProgress p) {
    final base = _scannedLine(p);
    return '$base, ${p.parsed} transactions, ${p.unparsed} unrecognized — you can continue later.';
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'sms_permission_denied':
        return 'SMS permission is required to scan your inbox.';
      case 'sms_permission_permanently_denied':
        return 'SMS permission was denied. Grant READ_SMS in Settings or use statement import.';
      default:
        return 'SMS scan failed: $code';
    }
  }
}

enum _ScanChoice { continue_, restart }

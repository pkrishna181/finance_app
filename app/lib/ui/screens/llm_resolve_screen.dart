import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../llm/anchoring.dart';
import '../../llm/jobs/llm_batch_coordinator.dart';
import '../../llm/llama_cpp_engine.dart';
import '../../llm/llm_review_service.dart';
import 'llm_debug_settings_screen.dart';

/// Review LLM-suggested transactions before ledger insert.
class LlmResolveScreen extends StatelessWidget {
  const LlmResolveScreen({
    super.key,
    required this.db,
    required this.reviewService,
    this.coordinator,
  });

  final ArthDatabase db;
  final LlmReviewService reviewService;
  final LlmBatchCoordinator? coordinator;

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<int>(
      stream: db.watchPendingLlmJobCount(),
      builder: (context, pendingSnap) {
        final pendingJobs = pendingSnap.data ?? 0;
        return _ResolveBody(
          db: db,
          reviewService: reviewService,
          coordinator: coordinator,
          pendingJobs: pendingJobs,
        );
      },
    );

    if (coordinator == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Needs review')),
        body: body,
      );
    }

    return StreamBuilder<LlmBatchState>(
      stream: coordinator!.states,
      initialData: coordinator!.state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Needs review')),
          body: body,
        );
      },
    );
  }
}

class _ResolveBody extends StatelessWidget {
  const _ResolveBody({
    required this.db,
    required this.reviewService,
    required this.coordinator,
    required this.pendingJobs,
  });

  final ArthDatabase db;
  final LlmReviewService reviewService;
  final LlmBatchCoordinator? coordinator;
  final int pendingJobs;

  @override
  Widget build(BuildContext context) {
    final batchRunning = coordinator?.state.running ?? false;

    return StreamBuilder<List<LlmReviewItem>>(
      stream: (db.select(db.llmReviewItems)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        if (items.isEmpty && (pendingJobs > 0 || batchRunning)) {
          return _ProcessingPane(
            pendingJobs: pendingJobs,
            running: batchRunning,
            skipped: coordinator?.state.skipped,
          );
        }

        if (items.isEmpty) {
          final skipped = coordinator?.state.skipped;
          if (skipped == 'model_not_downloaded') {
            return _ModelRequiredPane(
              onOpenDebug: kDebugMode &&
                      coordinator?.engine is LlamaCppEngine
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LlmDebugSettingsScreen(
                            engine: coordinator!.engine as LlamaCppEngine,
                          ),
                        ),
                      )
                  : null,
            );
          }
          return const Center(child: Text('No pending suggestions.'));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ReviewTile(
              item: item,
              onConfirm: () async {
                await reviewService.confirmReviewItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction confirmed')),
                  );
                }
              },
              onDiscard: () => reviewService.discardReviewItem(item.id),
            );
          },
        );
      },
    );
  }
}

class _ProcessingPane extends StatelessWidget {
  const _ProcessingPane({
    required this.pendingJobs,
    required this.running,
    this.skipped,
  });

  final int pendingJobs;
  final bool running;
  final String? skipped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (running) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              running
                  ? 'Processing $pendingJobs job${pendingJobs == 1 ? '' : 's'}…'
                  : 'Queued $pendingJobs job${pendingJobs == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'On-device model is parsing unrecognized SMS. '
              'This can take a minute per message.',
              textAlign: TextAlign.center,
            ),
            if (skipped == 'battery_guard') ...[
              const SizedBox(height: 12),
              Text(
                'Paused — battery low. Plug in or charge to continue.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModelRequiredPane extends StatelessWidget {
  const _ModelRequiredPane({this.onOpenDebug});

  final VoidCallback? onOpenDebug;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Model not ready',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Download and load the on-device model before Arth can '
              'parse unrecognized SMS.',
              textAlign: TextAlign.center,
            ),
            if (onOpenDebug != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onOpenDebug,
                child: const Text('Open LLM settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.item,
    required this.onConfirm,
    required this.onDiscard,
  });

  final LlmReviewItem item;
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    AnchorReport? report;
    try {
      report = AnchorReport.fromJson(
        Map<String, Object?>.from(jsonDecode(item.anchorReportJson) as Map),
      );
    } catch (_) {}

    Map<String, Object?>? fields;
    try {
      fields = Map<String, Object?>.from(jsonDecode(item.suggestedJson) as Map);
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raw SMS', style: Theme.of(context).textTheme.labelSmall),
            Text(item.rawText, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            if (fields != null)
              ...fields.entries.map(
                (e) => ListTile(
                  dense: true,
                  title: Text('${e.key}: ${e.value}'),
                  trailing: _anchorIcon(report, e.key),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onDiscard, child: const Text('Discard')),
                FilledButton(onPressed: onConfirm, child: const Text('Confirm')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _anchorIcon(AnchorReport? report, String field) {
    if (report == null) return null;
    final hits = report.fields.where((f) => f.field == field);
    if (hits.isEmpty) return null;
    final hit = hits.first;
    return Icon(
      switch (hit.status) {
        AnchorFieldStatus.pass => Icons.check_circle_outline,
        AnchorFieldStatus.infer => Icons.info_outline,
        AnchorFieldStatus.override => Icons.swap_horiz,
        AnchorFieldStatus.demote => Icons.warning_amber,
        AnchorFieldStatus.reject => Icons.cancel_outlined,
      },
      size: 16,
    );
  }
}

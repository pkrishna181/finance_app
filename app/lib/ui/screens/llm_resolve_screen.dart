import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../llm/anchoring.dart';
import '../../llm/llm_review_service.dart';

/// Review LLM-suggested transactions before ledger insert.
class LlmResolveScreen extends StatelessWidget {
  const LlmResolveScreen({
    super.key,
    required this.db,
    required this.reviewService,
  });

  final ArthDatabase db;
  final LlmReviewService reviewService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Needs review')),
      body: StreamBuilder<List<LlmReviewItem>>(
        stream: (db.select(db.llmReviewItems)
              ..where((t) => t.status.equals('pending'))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .watch(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
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

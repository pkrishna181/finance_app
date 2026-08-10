import 'package:flutter/material.dart';

import '../core/db/database.dart';
import 'jobs/llm_batch_coordinator.dart';
import 'jobs/llm_job_service.dart';
import 'llm_review_service.dart';
import '../ui/screens/llm_resolve_screen.dart';

/// Enqueue unparsed SMS jobs, kick the batch coordinator, open review UI.
Future<void> openLlmResolveFlow(
  BuildContext context, {
  required ArthDatabase db,
  required LlmBatchCoordinator coordinator,
}) async {
  final rows = await db.listUnresolvedUnparsedSms();
  final jobs = LlmJobService(db);
  for (final row in rows) {
    await jobs.enqueueSmsExtract(row.id);
  }
  coordinator.scheduleRun(db);
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LlmResolveScreen(
        db: db,
        reviewService: LlmReviewService(db: db),
        coordinator: coordinator,
      ),
    ),
  );
}

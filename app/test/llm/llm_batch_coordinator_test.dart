import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arth/core/db/database.dart';
import 'package:arth/llm/fake_llm_engine.dart';
import 'package:arth/llm/jobs/llm_batch_coordinator.dart';
import 'package:arth/llm/jobs/llm_job_service.dart';
import 'package:arth/llm/llm_review_service.dart';
import 'package:arth/llm/model_download_manager.dart';

void main() {
  test('scheduleRun processes pending sms_extract jobs', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final db = ArthDatabase.memory();
    addTearDown(db.close);

    const rawBody =
        'Rs.275.00 debited for UPI Ref 812233445566 to shop@ybl on 01-08-26.';
    const goodJson =
        '{"a":"Rs.275.00","d":"01-08-26","t":null,"y":"upi","r":"debit",'
        '"m":"shop@ybl","f":"812233445566","v":"shop@ybl"}';

    final engine = FakeLlmEngine(jsonResponse: goodJson);
    await engine.load(modelPath: 'fake');

    final smsId = await db.insertUnparsedSms(
      UnparsedSmsRowsCompanion.insert(
        rawBody: rawBody,
        reason: 'no_template_match',
      ),
    );
    await LlmJobService(db).enqueueSmsExtract(smsId);

    final coordinator = LlmBatchCoordinator(
      engine: engine,
      downloader: _AlwaysDownloadedDownloader(),
      loadGrammar: (_) async => 'root ::= "true"',
    );

    await coordinator.runNow(db);

    final reviews = await db.listPendingReviewItems();
    expect(reviews, isNotEmpty);

    final confirm = await LlmReviewService(db: db).confirmReviewItem(
      reviews.first.id,
    );
    expect(confirm.isOk, isTrue);
  });

  test('recoverStaleRunningLlmJobs resets running rows', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);

    final id = await db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: 'sms_extract',
        payloadJson: '{"unparsed_sms_id":1}',
        status: const Value('running'),
      ),
    );

    await db.recoverStaleRunningLlmJobs();
    final row = await (db.select(db.llmJobs)..where((t) => t.id.equals(id)))
        .getSingle();
    expect(row.status, 'pending');
  });
}

class _AlwaysDownloadedDownloader extends ModelDownloadManager {
  @override
  Future<bool> isDownloaded() async => true;

  @override
  Future<File> modelFilePath() async => File('fake.gguf');
}

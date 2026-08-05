import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:arth/core/db/database.dart';
import 'package:arth/llm/fake_llm_engine.dart';
import 'package:arth/llm/jobs/battery_guard.dart';
import 'package:arth/llm/jobs/llm_job_payload.dart';
import 'package:arth/llm/jobs/llm_job_runner.dart';
import 'package:arth/llm/jobs/llm_job_service.dart';
import 'package:arth/llm/jobs/llm_job_types.dart';

class _BlockBattery implements BatteryGuard {
  @override
  Future<bool> mayRunLlmBatch() async => false;
}

void main() {
  test('jobs sorted by type for prefix locality', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);

    await db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: LlmJobType.categorize.wire,
        payloadJson: encodeJobPayload(CategorizePayload(transactionId: 1)),
      ),
    );
    await db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: LlmJobType.smsExtract.wire,
        payloadJson: encodeJobPayload(SmsExtractPayload(unparsedSmsId: 1)),
      ),
    );
    final jobs = await db.fetchPendingJobs();
    expect(jobs.first.jobType, LlmJobType.smsExtract.wire);
  });

  test('battery guard skips batch', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final engine = FakeLlmEngine();
    await engine.load(modelPath: 'fake');

    final runner = LlmJobRunner(
      db: db,
      engine: engine,
      batteryGuard: _BlockBattery(),
      loadGrammar: (_) async => 'root ::= "true"',
    );
    final report = await runner.runPendingBatch();
    expect(report.skipped, 'battery_guard');
  });

  test('merchant job deduped by raw string', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final svc = LlmJobService(db);
    final a = await svc.enqueueMerchantNormalize('Zomato@paytm');
    final b = await svc.enqueueMerchantNormalize('Zomato@paytm');
    expect(a, isNotNull);
    expect(b, isNull);
  });

  test('poison job fails after max attempts', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final engine = FakeLlmEngine(jsonResponse: 'not-json');
    await engine.load(modelPath: 'fake');

    final smsId = await db.insertUnparsedSms(
      UnparsedSmsRowsCompanion.insert(
        rawBody: 'Rs.10 debited',
        reason: 'test',
      ),
    );
    await db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: LlmJobType.smsExtract.wire,
        payloadJson: encodeJobPayload(SmsExtractPayload(unparsedSmsId: smsId)),
        attempts: const Value(2),
      ),
    );

    final runner = LlmJobRunner(
      db: db,
      engine: engine,
      maxAttempts: 2,
      loadGrammar: (_) async => 'root ::= "true"',
    );
    final report = await runner.runPendingBatch(force: true);
    expect(report.failed, 1);
  });
}

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:arth/core/db/database.dart';
import 'package:arth/llm/fake_llm_engine.dart';
import 'package:arth/llm/jobs/llm_job_runner.dart';
import 'package:arth/llm/jobs/llm_job_service.dart';
import 'package:arth/llm/llm_review_service.dart';
import 'package:arth/llm/parsed_transaction_validator.dart';

void main() {
  test('unparsed SMS → review → confirm inserts deduped txn', () async {
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
    final runner = LlmJobRunner(
      db: db,
      engine: engine,
      loadGrammar: (_) async =>
          await FakeAssetIO.read('test/fixtures/parsed_transaction.gbnf'),
    );
    final batch = await runner.runPendingBatch(force: true);
    expect(batch.processed, 1);

    final reviews = await db.listPendingReviewItems();
    expect(reviews, isNotEmpty);

    final reviewSvc = LlmReviewService(db: db);
    final confirm = await reviewSvc.confirmReviewItem(reviews.first.id);
    expect(confirm.isOk, isTrue);

    final txns = await db.select(db.transactions).get();
    expect(txns.length, 1);

    final again = await reviewSvc.confirmReviewItem(reviews.first.id);
    expect(again.isErr, isTrue);
  });
}

/// Test helper — minimal grammar stub when assets unavailable in test.
class FakeAssetIO {
  static Future<String> read(String path) async => 'root ::= "true"';
}

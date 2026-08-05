import '../../core/db/database.dart';
import 'llm_job_payload.dart';
import 'llm_job_types.dart';

/// Enqueue LLM background jobs (deduped where noted).
class LlmJobService {
  LlmJobService(this.db);

  final ArthDatabase db;

  Future<int> enqueueSmsExtract(int unparsedSmsId) {
    return db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: LlmJobType.smsExtract.wire,
        payloadJson: encodeJobPayload(SmsExtractPayload(unparsedSmsId: unparsedSmsId)),
      ),
    );
  }

  Future<int?> enqueueMerchantNormalize(String rawMerchant) async {
    final raw = rawMerchant.trim();
    if (raw.isEmpty) return null;
    if (await db.hasPendingMerchantJob(raw)) return null;
    return db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: LlmJobType.merchantNormalize.wire,
        payloadJson: encodeJobPayload(MerchantNormalizePayload(rawMerchant: raw)),
      ),
    );
  }

  Future<int> enqueueCategorize(int transactionId) {
    return db.insertLlmJob(
      LlmJobsCompanion.insert(
        jobType: LlmJobType.categorize.wire,
        payloadJson: encodeJobPayload(CategorizePayload(transactionId: transactionId)),
      ),
    );
  }

  Future<void> enqueueSmsExtractBatch(Iterable<int> unparsedSmsIds) async {
    for (final id in unparsedSmsIds) {
      await enqueueSmsExtract(id);
    }
  }
}

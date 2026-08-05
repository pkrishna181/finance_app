/// LLM background job types (Phase 5).
enum LlmJobType {
  smsExtract('sms_extract'),
  stmtRowExtract('stmt_row_extract'),
  merchantNormalize('merchant_normalize'),
  categorize('categorize');

  const LlmJobType(this.wire);
  final String wire;

  static LlmJobType? fromWire(String wire) {
    for (final t in values) {
      if (t.wire == wire) return t;
    }
    return null;
  }
}

enum LlmJobStatus {
  pending('pending'),
  running('running'),
  done('done'),
  failed('failed');

  const LlmJobStatus(this.wire);
  final String wire;
}

/// Sort weight — lower runs first within a batch (prefix cache locality).
int llmJobTypeSortOrder(LlmJobType type) => switch (type) {
      LlmJobType.smsExtract => 0,
      LlmJobType.stmtRowExtract => 1,
      LlmJobType.merchantNormalize => 2,
      LlmJobType.categorize => 3,
    };

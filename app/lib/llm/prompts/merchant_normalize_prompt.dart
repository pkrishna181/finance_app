/// Short single-task merchant normalization prompt (no few-shot bloat).
class MerchantNormalizePrompt {
  MerchantNormalizePrompt._();

  static String build(String rawMerchant) {
    return '''Normalize this payment merchant string to a canonical brand name.
Output JSON only: {"canonical_name":"...","confidence":0.0}
Rules:
- canonical_name must share a word with the input OR be a well-known brand
- confidence 0-1

Merchant: ${rawMerchant.trim()}
JSON:''';
  }
}

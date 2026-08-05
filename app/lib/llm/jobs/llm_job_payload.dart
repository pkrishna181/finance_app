import 'dart:convert';

import 'llm_job_types.dart';

sealed class LlmJobPayload {
  Map<String, Object?> toJson();
}

class SmsExtractPayload extends LlmJobPayload {
  SmsExtractPayload({required this.unparsedSmsId});

  factory SmsExtractPayload.fromJson(Map<String, Object?> json) {
    return SmsExtractPayload(unparsedSmsId: json['unparsed_sms_id'] as int);
  }

  final int unparsedSmsId;

  @override
  Map<String, Object?> toJson() => {'unparsed_sms_id': unparsedSmsId};
}

class StmtRowExtractPayload extends LlmJobPayload {
  StmtRowExtractPayload({required this.unparsedStatementRowId});

  factory StmtRowExtractPayload.fromJson(Map<String, Object?> json) {
    return StmtRowExtractPayload(
      unparsedStatementRowId: json['unparsed_statement_row_id'] as int,
    );
  }

  final int unparsedStatementRowId;

  @override
  Map<String, Object?> toJson() => {
        'unparsed_statement_row_id': unparsedStatementRowId,
      };
}

class MerchantNormalizePayload extends LlmJobPayload {
  MerchantNormalizePayload({required this.rawMerchant});

  factory MerchantNormalizePayload.fromJson(Map<String, Object?> json) {
    return MerchantNormalizePayload(rawMerchant: json['raw_merchant'] as String);
  }

  final String rawMerchant;

  @override
  Map<String, Object?> toJson() => {'raw_merchant': rawMerchant};
}

class CategorizePayload extends LlmJobPayload {
  CategorizePayload({required this.transactionId});

  factory CategorizePayload.fromJson(Map<String, Object?> json) {
    return CategorizePayload(transactionId: json['transaction_id'] as int);
  }

  final int transactionId;

  @override
  Map<String, Object?> toJson() => {'transaction_id': transactionId};
}

LlmJobPayload decodeJobPayload(LlmJobType type, String json) {
  final map = Map<String, Object?>.from(jsonDecode(json) as Map);
  return switch (type) {
    LlmJobType.smsExtract => SmsExtractPayload.fromJson(map),
    LlmJobType.stmtRowExtract => StmtRowExtractPayload.fromJson(map),
    LlmJobType.merchantNormalize => MerchantNormalizePayload.fromJson(map),
    LlmJobType.categorize => CategorizePayload.fromJson(map),
  };
}

String encodeJobPayload(LlmJobPayload payload) => jsonEncode(payload.toJson());

/// Dedupe key for merchant_normalize jobs.
String merchantJobDedupeKey(String rawMerchant) =>
    rawMerchant.trim().toLowerCase();

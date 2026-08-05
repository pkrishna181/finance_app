import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../core/db/database.dart';
import '../core/models/parsed_transaction.dart';
import '../core/result/result.dart';
import 'anchoring.dart';
import 'parsed_transaction_validator.dart';

/// Confirm/discard LLM-suggested transactions (Phase 5 review queue).
class LlmReviewService {
  LlmReviewService({
    required this.db,
    this.validator = const ParsedTransactionJsonValidator(),
  });

  final ArthDatabase db;
  final ParsedTransactionJsonValidator validator;

  Future<Result<int>> confirmReviewItem(int reviewId, {int? importId}) async {
    final item = await db.getReviewItem(reviewId);
    if (item == null) return const Err('review_not_found');
    if (item.status != 'pending') return Err('invalid_status', item.status);

    final validated = validator.validate(item.suggestedJson);
    if (validated.isErr) return Err(validated.errorOrNull!, validated);

    final txn = validated.okOrNull!;
    final hash = buildDedupeHash(
      bankCode: txn.bankCode,
      bookedAt: txn.bookedAt,
      amountPaise: txn.amountPaise.paise,
      ref: txn.upiRef ?? txn.externalRef,
      normalizedBody: txn.rawDescription,
    );

    final companion = TransactionsCompanion.insert(
      amountPaise: txn.amountPaise.paise,
      direction: txn.direction.wireName,
      txnType: txn.type.wireName,
      bookedAt: txn.bookedAt,
      bankCode: txn.bankCode,
      accountHint: Value(txn.accountHint),
      rawMerchant: txn.rawMerchant,
      rawDescription: txn.rawDescription,
      upiPayerVpa: Value(txn.upiPayerVpa),
      upiPayeeVpa: Value(txn.upiPayeeVpa),
      upiRef: Value(txn.upiRef),
      remarks: Value(txn.remarks),
      externalRef: Value(txn.externalRef),
      balanceAfterPaise: Value(txn.balanceAfterPaise?.paise),
      dedupeHash: hash,
      importId: Value(importId),
    );

    late final int txnId;
    if (importId != null) {
      final upsert = await db.upsertTransactionWithProvenance(
        companion,
        importId: importId,
      );
      txnId = upsert.transactionId;
    } else {
      txnId = await db.insertTransactionIdempotent(companion);
    }

    await db.updateReviewItem(
      reviewId,
      LlmReviewItemsCompanion(
        status: const Value('confirmed'),
        transactionId: Value(txnId),
      ),
    );
    return Ok(txnId);
  }

  Future<void> discardReviewItem(int reviewId) async {
    await db.updateReviewItem(
      reviewId,
      LlmReviewItemsCompanion(status: const Value('discarded')),
    );
  }

  AnchorReport parseAnchorReport(String json) =>
      AnchorReport.fromJson(Map<String, Object?>.from(jsonDecode(json) as Map));
}

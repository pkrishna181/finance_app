import 'dart:convert';

import '../core/models/money.dart';
import '../core/models/parsed_transaction.dart';
import '../core/models/transaction_type.dart';
import '../core/result/result.dart';

/// Validates LLM JSON output for [ParsedTransaction] before acceptance.
class ParsedTransactionJsonValidator {
  const ParsedTransactionJsonValidator();

  Result<ParsedTransaction> validate(String rawJson) {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) {
      return const Err('empty_json');
    }

    Map<String, Object?> map;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) {
        return const Err('json_not_object');
      }
      map = Map<String, Object?>.from(decoded);
    } catch (_) {
      return const Err('json_parse_failed');
    }

    final amount = map['amount_paise'];
    if (amount is! int || amount <= 0) {
      return Err('invalid_amount_paise', amount);
    }

    final direction = map['direction'];
    if (direction is! String ||
        !TransactionDirection.values.any((e) => e.name == direction)) {
      return Err('invalid_direction', direction);
    }
    final dir = TransactionDirection.fromWire(direction);

    final typeWire = map['type'];
    if (typeWire is! String ||
        !TransactionType.values.any((e) => e.name == typeWire)) {
      return Err('invalid_type', typeWire);
    }
    final type = TransactionType.fromWire(typeWire);

    final bookedAtRaw = map['booked_at'];
    if (bookedAtRaw is! String) {
      return const Err('invalid_booked_at');
    }
    late final DateTime bookedAt;
    try {
      bookedAt = DateTime.parse(bookedAtRaw).toUtc();
    } catch (_) {
      return Err('invalid_booked_at', bookedAtRaw);
    }

    final bank = map['bank_code'];
    if (bank is! String || bank.trim().isEmpty) {
      return const Err('invalid_bank_code');
    }

    final merchant = map['raw_merchant'];
    final description = map['raw_description'];
    if (merchant is! String || description is! String) {
      return const Err('invalid_merchant_or_description');
    }

    final dedupe = map['dedupe_key'];
    if (dedupe is! String || dedupe.isEmpty) {
      return const Err('invalid_dedupe_key');
    }

    final directionInferred = map['direction_inferred'];
    if (directionInferred != null && directionInferred is! bool) {
      return const Err('invalid_direction_inferred');
    }

    int? balancePaise;
    final bal = map['balance_after_paise'];
    if (bal != null) {
      if (bal is! int) return const Err('invalid_balance_after_paise');
      balancePaise = bal;
    }

    return Ok(
      ParsedTransaction(
        amountPaise: MoneyPaise(amount),
        direction: dir,
        type: type,
        bookedAt: bookedAt,
        bankCode: bank.trim(),
        accountHint: map['account_hint'] as String?,
        rawMerchant: merchant,
        rawDescription: description,
        upiPayerVpa: map['upi_payer_vpa'] as String?,
        upiPayeeVpa: map['upi_payee_vpa'] as String?,
        upiRef: map['upi_ref'] as String?,
        remarks: map['remarks'] as String?,
        externalRef: map['external_ref'] as String?,
        balanceAfterPaise:
            balancePaise == null ? null : MoneyPaise(balancePaise),
        dedupeKey: dedupe,
        directionInferred: directionInferred as bool? ?? false,
      ),
    );
  }
}

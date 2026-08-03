import 'money.dart';
import 'transaction_type.dart';

/// Normalized transaction produced by a parser before persistence.
///
/// Amounts are always in paise. [dedupeKey] is a stable hash input:
/// bank + date + amount + ref (see ARCHITECTURE.md).
class ParsedTransaction {
  const ParsedTransaction({
    required this.amountPaise,
    required this.direction,
    required this.type,
    required this.bookedAt,
    required this.bankCode,
    required this.rawMerchant,
    required this.rawDescription,
    required this.dedupeKey,
    this.accountHint,
    this.upiPayerVpa,
    this.upiPayeeVpa,
    this.upiRef,
    this.remarks,
    this.externalRef,
    this.balanceAfterPaise,
    this.directionInferred = false,
  });

  final MoneyPaise amountPaise;
  final TransactionDirection direction;
  final TransactionType type;
  final DateTime bookedAt;
  final String bankCode;
  final String? accountHint;
  final String rawMerchant;
  final String rawDescription;
  final String? upiPayerVpa;
  final String? upiPayeeVpa;
  final String? upiRef;
  final String? remarks;
  final String? externalRef;
  final MoneyPaise? balanceAfterPaise;

  /// True when direction was guessed (single-amount column, default debit).
  final bool directionInferred;

  /// Stable key used for idempotent imports (pre-hash material).
  /// Strong ref: `bank|amount|ref`; weak ref: `bank|date|amount|ref`;
  /// refless: `bank|date|amount|time|body`.
  final String dedupeKey;

  Map<String, Object?> toJson() => {
        'amount_paise': amountPaise.paise,
        'direction': direction.wireName,
        'type': type.wireName,
        'booked_at': bookedAt.toUtc().toIso8601String(),
        'bank_code': bankCode,
        'account_hint': accountHint,
        'raw_merchant': rawMerchant,
        'raw_description': rawDescription,
        'upi_payer_vpa': upiPayerVpa,
        'upi_payee_vpa': upiPayeeVpa,
        'upi_ref': upiRef,
        'remarks': remarks,
        'external_ref': externalRef,
        'balance_after_paise': balanceAfterPaise?.paise,
        'dedupe_key': dedupeKey,
        'direction_inferred': directionInferred,
      };

  factory ParsedTransaction.fromJson(Map<String, Object?> json) {
    return ParsedTransaction(
      amountPaise: MoneyPaise(json['amount_paise']! as int),
      direction: TransactionDirection.fromWire(json['direction']! as String),
      type: TransactionType.fromWire(json['type']! as String),
      bookedAt: DateTime.parse(json['booked_at']! as String),
      bankCode: json['bank_code']! as String,
      accountHint: json['account_hint'] as String?,
      rawMerchant: json['raw_merchant']! as String,
      rawDescription: json['raw_description']! as String,
      upiPayerVpa: json['upi_payer_vpa'] as String?,
      upiPayeeVpa: json['upi_payee_vpa'] as String?,
      upiRef: json['upi_ref'] as String?,
      remarks: json['remarks'] as String?,
      externalRef: json['external_ref'] as String?,
      balanceAfterPaise: json['balance_after_paise'] == null
          ? null
          : MoneyPaise(json['balance_after_paise']! as int),
      dedupeKey: json['dedupe_key']! as String,
      directionInferred: json['direction_inferred'] as bool? ?? false,
    );
  }
}

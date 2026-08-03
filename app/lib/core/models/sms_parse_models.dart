import 'money.dart';
import 'parsed_transaction.dart';

/// Transactional SMS that matched no template (Phase-5 LLM fallback input).
/// Raw body is stored only in the encrypted DB — never logged.
class UnparsedSms {
  const UnparsedSms({
    required this.rawBody,
    this.sender,
    this.receivedAt,
    this.bankCode,
    this.reason = 'no_template_match',
  });

  final String rawBody;
  final String? sender;
  final DateTime? receivedAt;
  final String? bankCode;
  final String reason;
}

/// Future-tense mandate / e-NACH / "will be debited" notice.
/// Kept for recurring detection — not a ledger transaction.
class ParsedMandateNotice {
  const ParsedMandateNotice({
    required this.rawBody,
    required this.bankCode,
    this.amountPaise,
    this.merchant,
    this.scheduledDate,
    this.accountHint,
    this.sender,
    this.receivedAt,
  });

  final String rawBody;
  final String bankCode;
  final MoneyPaise? amountPaise;
  final String? merchant;
  final DateTime? scheduledDate;
  final String? accountHint;
  final String? sender;
  final DateTime? receivedAt;

  Map<String, Object?> toJson() => {
        'bank_code': bankCode,
        'amount_paise': amountPaise?.paise,
        'merchant': merchant,
        'scheduled_date': scheduledDate?.toUtc().toIso8601String(),
        'account_hint': accountHint,
        'raw_body': rawBody,
      };
}

/// Successful cascade outcome. Unparsed SMS is returned as [Err] with
/// [UnparsedSms] as the cause.
class SmsParseSuccess {
  const SmsParseSuccess.transactions(this.transactions)
      : mandate = null,
        skippedReason = null;

  const SmsParseSuccess.mandate(this.mandate)
      : transactions = const [],
        skippedReason = null;

  const SmsParseSuccess.skipped(this.skippedReason)
      : transactions = const [],
        mandate = null;

  final List<ParsedTransaction> transactions;
  final ParsedMandateNotice? mandate;
  final String? skippedReason;

  bool get isSkipped => skippedReason != null;
  bool get hasMandate => mandate != null;
}

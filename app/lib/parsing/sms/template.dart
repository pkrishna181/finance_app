import '../../core/models/models.dart';
import 'extractors.dart';

/// Data-driven SMS template: regex with named groups + fixed metadata.
///
/// Supported named groups (optional unless noted):
/// `amount` (required), `date`, `time`, `merchant`, `payee_vpa`, `payer_vpa`,
/// `ref`, `account`, `balance`, `remarks`.
class SmsTemplate {
  const SmsTemplate({
    required this.id,
    required this.bankCode,
    required this.type,
    required this.pattern,
    this.fixedDirection,
    this.externalRefBuilder,
  });

  final String id;
  final String bankCode;
  final TransactionType type;
  final RegExp pattern;
  final TransactionDirection? fixedDirection;

  /// When no `ref` group / extractor hit, build a synthetic external ref
  /// (used to keep legacy Axis card golden stable).
  final String Function(TemplateFields fields)? externalRefBuilder;

  ParsedTransaction? tryParse(
    String normalizedBody, {
    String? bankOverride,
    DateTime? receivedAt,
  }) {
    final m = pattern.firstMatch(normalizedBody);
    if (m == null) return null;

    final amountRaw = m.namedGroupOrNull('amount');
    if (amountRaw == null) return null;
    final amount =
        parseAmountToken(amountRaw) ?? parseAmountToken('Rs.$amountRaw');
    if (amount == null) return null;

    final dateRaw = m.namedGroupOrNull('date');
    final timeRaw = m.namedGroupOrNull('time');
    var bookedAt = dateRaw != null
        ? extractDateTime(
            timeRaw != null ? '$dateRaw $timeRaw' : dateRaw,
            fallback: receivedAt,
          )
        : extractDateTime(normalizedBody, fallback: receivedAt);
    bookedAt ??= receivedAt ?? DateTime.now().toUtc();

    final direction =
        fixedDirection ??
        extractDirection(normalizedBody) ??
        TransactionDirection.debit;

    final payer = m.namedGroupOrNull('payer_vpa');
    // A UPI ID found elsewhere in the text is the payee — unless it's the
    // payer's, already captured.
    final payee =
        m.namedGroupOrNull('payee_vpa') ??
        (type == TransactionType.upi && payer == null
            ? extractVpa(normalizedBody)
            : null);
    final merchant =
        (m.namedGroupOrNull('merchant') ??
                payee ??
                payer ??
                m.namedGroupOrNull('remarks') ??
                'Unknown')
            .trim();
    var remarks = m.namedGroupOrNull('remarks')?.trim();
    // UPI dash-suffix merchants (e.g. -SWIGGY) double as remarks; VPAs do not.
    if (remarks == null &&
        !merchant.contains('@') &&
        type == TransactionType.upi) {
      remarks = merchant;
    }
    final account =
        m.namedGroupOrNull('account') ??
        extractAccountMask(normalizedBody) ??
        extractCardLast4(normalizedBody);

    final ref =
        m.namedGroupOrNull('ref') ??
        extractUpiRef(normalizedBody) ??
        extractImpsRef(normalizedBody) ??
        extractNeftUtr(normalizedBody);

    // Axis "Avl Limit" must not be treated as ledger balance.
    MoneyPaise? balance;
    final balRaw = m.namedGroupOrNull('balance');
    if (balRaw != null) {
      balance = parseAmountToken(balRaw) ?? parseAmountToken('Rs.$balRaw');
    } else if (!RegExp(
      r'avl\.?\s*(?:lmt|limit)',
      caseSensitive: false,
    ).hasMatch(normalizedBody)) {
      balance = extractBalance(normalizedBody);
    }

    final bank = bankOverride ?? bankCode;
    final fields = TemplateFields(
      amountPaise: amount.paise,
      bookedAt: bookedAt,
      accountHint: account,
      merchant: merchant,
      ref: ref,
      normalizedBody: normalizedBody,
    );

    final externalRef = ref ?? externalRefBuilder?.call(fields);
    final dedupeKey = buildDedupeKey(
      bankCode: bank,
      bookedAt: bookedAt,
      amountPaise: amount.paise,
      ref: externalRef,
      normalizedBody: normalizedBody,
    );

    return ParsedTransaction(
      amountPaise: amount,
      direction: direction,
      type: type,
      bookedAt: bookedAt,
      bankCode: bank,
      accountHint: account,
      rawMerchant: merchant,
      rawDescription: normalizedBody,
      upiPayerVpa: payer,
      upiPayeeVpa: payee,
      upiRef: type == TransactionType.upi ? (ref ?? externalRef) : null,
      remarks: remarks,
      externalRef: externalRef,
      balanceAfterPaise: balance,
      dedupeKey: dedupeKey,
    );
  }
}

class TemplateFields {
  const TemplateFields({
    required this.amountPaise,
    required this.bookedAt,
    required this.normalizedBody,
    this.accountHint,
    this.merchant,
    this.ref,
  });

  final int amountPaise;
  final DateTime bookedAt;
  final String normalizedBody;
  final String? accountHint;
  final String? merchant;
  final String? ref;
}

extension NamedGroupX on RegExpMatch {
  String? namedGroupOrNull(String name) {
    try {
      return namedGroup(name);
    } on ArgumentError {
      return null;
    }
  }
}

/// Pre-hash dedupe material (see [buildDedupeHash]).
///
/// Strong refs (UPI/IMPS 12-digit, NEFT UTR) omit date so SMS txn date and
/// statement posting date still collide. Refless rows keep date+time+body.
String buildDedupeKey({
  required String bankCode,
  required DateTime bookedAt,
  required int amountPaise,
  String? ref,
  String? normalizedBody,
}) {
  if (ref != null && ref.isNotEmpty && isStrongRef(ref)) {
    return '$bankCode|$amountPaise|$ref';
  }
  final day = formatDayKey(bookedAt);
  if (ref != null && ref.isNotEmpty) {
    return '$bankCode|$day|$amountPaise|$ref';
  }
  final time = formatTimeKey(bookedAt);
  final body = normalizedBody ?? '';
  return '$bankCode|$day|$amountPaise|$time|$body';
}

/// Try mandate / future-debit notice patterns.
ParsedMandateNotice? tryParseMandate(
  String normalizedBody, {
  required String bankCode,
  String? sender,
  DateTime? receivedAt,
}) {
  final future = RegExp(
    r'(will\s+be\s+debited|to\s+be\s+debited|mandate\s+(?:for|of)|e-?nach|'
    r'standing\s+instruction|auto[- ]?debit|will\s+be\s+processed|'
    r'is\s+scheduled\s+on|will\s+be\s+executed)',
    caseSensitive: false,
  );
  if (!future.hasMatch(normalizedBody)) return null;

  // Exclude completed past-tense "has been debited"
  if (RegExp(
    r'\b(?:has\s+been|is)\s+debited\b',
    caseSensitive: false,
  ).hasMatch(normalizedBody)) {
    // Could still be mandate if also "will be" — prefer future if both
    if (!RegExp(
      r'will\s+be\s+debited',
      caseSensitive: false,
    ).hasMatch(normalizedBody)) {
      return null;
    }
  }

  final amount =
      extractSoleTxnAmount(normalizedBody).okOrNull ??
      parseAmountToken(
        RegExp(
              r'(?:Rs\.?|INR|₹)\s*[0-9,]+(?:\.[0-9]{1,2})?',
              caseSensitive: false,
            ).firstMatch(normalizedBody)?.group(0) ??
            '',
      );

  return ParsedMandateNotice(
    rawBody: normalizedBody,
    bankCode: bankCode,
    amountPaise: amount,
    merchant: extractVpa(normalizedBody),
    scheduledDate: extractDateTime(normalizedBody, fallback: receivedAt),
    accountHint: extractAccountMask(normalizedBody),
    sender: sender,
    receivedAt: receivedAt,
  );
}

/// Not a transaction, though it mentions money (from real inboxes).
final _notTransactions = <String, RegExp>{
  // "…has been declined", "was declined as International usage…"
  'declined': RegExp(
    r'\b(?:has been|was|been|is) declined\b',
    caseSensitive: false,
  ),
  'fraud_check': RegExp(
    r'\bis suspicious\b|\bTo confirm transaction\b',
    caseSensitive: false,
  ),
  'bill_alert': RegExp(
    r'\bTotal (?:Amount|Amt\.?) Due\b|\bMin(?:imum)?\.? (?:amt|amount) due\b|'
    r'\bStmt Alert\b|\bstatement for .{0,40}generated\b|\bE-statement\b|'
    r'\boutstanding of Rs\b|\bNew Bill for\b|\bBill for .{0,60}\bis due\b',
    caseSensitive: false,
  ),
  'collect_request': RegExp(
    r'\bhas requested Rs|\bcollect request\b|\bis requesting payment\b',
    caseSensitive: false,
  ),
  'hold': RegExp(r'\bhold for (?:INR|Rs)', caseSensitive: false),
  'limit_alert': RegExp(
    r'\bconsumed \d+% Credit Limit\b',
    caseSensitive: false,
  ),
  'mandate_setup': RegExp(
    r'e-?Mandate .{0,80}(?:has been registered|has been cancelled)|'
    r'registered with the following details',
    caseSensitive: false,
  ),
  'emi_offer': RegExp(
    r'\bconvert .{0,80}\binto (?:Flexipay )?EMIs?\b|\bconverted into EMI\b',
    caseSensitive: false,
  ),
  // Credits *to* the loan account (repayments); the savings side has its own
  // message. Disbursals into savings are transactions.
  'loan_account': RegExp(r'\bYour loan A/C\b', caseSensitive: false),
  // The CAS statement covers fund purchases; the bank SMS covers the debit.
  'investment': RegExp(
    r'\bFolio No\b|\bin Scheme\b|\bIndex Fund\b.{0,40}\bprocessed\b|\bMutual Fund\b',
    caseSensitive: false,
  ),
  'mandate_setup_upi': RegExp(
    r'\bUPI-Mandate successfully (?:Revoked|created)\b',
    caseSensitive: false,
  ),
  'fraud_call': RegExp(
    r'\bwe tried calling you to confirm\b',
    caseSensitive: false,
  ),
};

// The first amount is in a foreign currency ("Spent USD 3.54", "USD23.60
// spent"): the INR amount only appears on the statement.
final _foreignFirst = RegExp(
  r'^[^₹]*?(?<!INR )\b(?:USD|EUR|GBP|AED|SGD)\s?\d*\.?\d',
  caseSensitive: false,
);
final _inrFirst = RegExp(
  r'^[^₹]*?\b(?:Rs\.?|INR\.?)\s?\d|₹\s?\d|\b(?:debited|credited) by \d',
  caseSensitive: false,
);
final _anyAmount = RegExp(
  r'(?:Rs\.?|INR\.?|₹|USD|EUR)\s?\d|\b(?:debited|credited) (?:by|with) \d',
  caseSensitive: false,
);

/// Early noise filter: OTP / promo / balance-only / EMI reminder.
String? detectNoise(String normalizedBody) {
  // Notices, logins, applications, advisories in other languages.
  if (!_anyAmount.hasMatch(normalizedBody)) return 'no_amount';
  for (final e in _notTransactions.entries) {
    if (e.value.hasMatch(normalizedBody)) return e.key;
  }
  final foreign = _foreignFirst.firstMatch(normalizedBody);
  final inr = _inrFirst.firstMatch(normalizedBody);
  if (foreign != null && (inr == null || foreign.end < inr.end)) {
    return 'foreign_currency';
  }
  if (RegExp(
    r'\b(otp|one[- ]time\s+password|verification\s+code)\b',
    caseSensitive: false,
  ).hasMatch(normalizedBody)) {
    return 'otp';
  }
  if (RegExp(
        r'\b(offer|discount|apply\s+now|click\s+here|congratulations|'
        r'pre[- ]?approved|limited\s+period|apply\s+(?:before|by)|'
        r'joining\s+fee|instant\s+approval|cashback|hurry|recharge\s+code)\b|'
        r'\bT&C\b|\bTnC\b|\bTCA\b|expires\s+(?:today|tomorrow)',
        caseSensitive: false,
      ).hasMatch(normalizedBody) &&
      !RegExp(
        r'\b(debited|credited|spent|withdrawn|paid)\b',
        caseSensitive: false,
      ).hasMatch(normalizedBody)) {
    return 'promo';
  }
  if (RegExp(
    r'\bemi\s+(?:due|reminder|overdue)\b',
    caseSensitive: false,
  ).hasMatch(normalizedBody)) {
    return 'emi_reminder';
  }
  // Balance-only alert: has balance cue but no debit/credit/spent/paid
  final hasBal = RegExp(
    r'(?:avl\.?\s*(?:bal|lmt)|available\s+bal)',
    caseSensitive: false,
  ).hasMatch(normalizedBody);
  final hasTxn = RegExp(
    r'\b(debited|credited|spent|withdrawn|paid|imps|neft|upi\s*ref|debit|'
    r'credit|transaction\s+number)\b',
    caseSensitive: false,
  ).hasMatch(normalizedBody);
  if (hasBal && !hasTxn) {
    return 'balance_only';
  }
  return null;
}

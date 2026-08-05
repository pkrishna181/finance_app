import 'dart:convert';

import '../core/models/money.dart';
import '../core/models/parsed_transaction.dart';
import '../core/models/transaction_type.dart';
import '../core/result/result.dart';
import '../parsing/common/extractors.dart';
import '../parsing/sms/template.dart' show buildDedupeKey;
import 'anchoring.dart' show guessBankFromSender;

/// Validates LLM JSON output and maps compact span keys to [ParsedTransaction].
class ParsedTransactionJsonValidator {
  const ParsedTransactionJsonValidator();

  static const _compactKeys = {'a', 'd', 't', 'y', 'r', 'm', 'f', 'v'};

  /// Rough decode-token estimate for compact JSON (reporting only).
  static int estimateOutputTokens(String json) =>
      (json.trim().length / 4).ceil();

  /// Validates LLM compact extraction or stored domain JSON.
  ///
  /// Compact path (keys `a`…`v`) requires [sourceSms] for span anchoring and dedupe.
  /// Domain path accepts full [ParsedTransaction] wire JSON (review confirm).
  Result<ParsedTransaction> validate(
    String rawJson, {
    String? sourceSms,
    String? sender,
  }) {
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

    if (map.containsKey('a') && !map.containsKey('amount_paise')) {
      if (sourceSms == null || sourceSms.trim().isEmpty) {
        return const Err('missing_source_sms');
      }
      return _validateCompact(map, sourceSms.trim(), sender);
    }
    return _validateDomain(map);
  }

  Result<ParsedTransaction> _validateCompact(
    Map<String, Object?> map,
    String sourceSms,
    String? sender,
  ) {
    for (final key in map.keys) {
      if (!_compactKeys.contains(key)) {
        return Err('unexpected_compact_key', key);
      }
    }
    for (final key in _compactKeys) {
      if (!map.containsKey(key)) {
        return Err('missing_compact_key', key);
      }
    }

    final amountSpan = map['a'];
    if (amountSpan is! String || amountSpan.trim().isEmpty) {
      return Err('invalid_amount_span', amountSpan);
    }
    if (!amountSpanAppearsInSource(sourceSms, amountSpan)) {
      return const Err('amount_span_not_in_source');
    }
    final amount = parseAmountSpan(amountSpan);
    if (amount == null) {
      return Err('invalid_amount_span', amountSpan);
    }

    final dateSpan = map['d'];
    if (dateSpan is! String || dateSpan.trim().isEmpty) {
      return Err('invalid_date_span', dateSpan);
    }
    if (!spanAppearsInSource(sourceSms, dateSpan)) {
      return const Err('date_span_not_in_source');
    }

    final timeRaw = map['t'];
    String? timeSpan;
    if (timeRaw == null) {
      timeSpan = null;
    } else if (timeRaw is String) {
      if (timeRaw.isNotEmpty && !spanAppearsInSource(sourceSms, timeRaw)) {
        return const Err('time_span_not_in_source');
      }
      timeSpan = timeRaw.isEmpty ? null : timeRaw;
    } else {
      return Err('invalid_time_span', timeRaw);
    }

    final bookedAt = parseDateTimeSpans(dateSpan, timeSpan);
    if (bookedAt == null) {
      return Err('invalid_date_span', dateSpan);
    }

    final typeWire = map['y'];
    if (typeWire is! String ||
        !TransactionType.values.any((e) => e.name == typeWire)) {
      return Err('invalid_type', typeWire);
    }
    final type = TransactionType.fromWire(typeWire);

    final direction = map['r'];
    if (direction is! String ||
        !TransactionDirection.values.any((e) => e.name == direction)) {
      return Err('invalid_direction', direction);
    }
    final dir = TransactionDirection.fromWire(direction);

    final merchantRaw = map['m'];
    if (merchantRaw != null && merchantRaw is! String) {
      return Err('invalid_merchant', merchantRaw);
    }

    final refRaw = map['f'];
    if (refRaw != null && refRaw is! String) {
      return Err('invalid_ref', refRaw);
    }

    final vpaRaw = map['v'];
    if (vpaRaw != null && vpaRaw is! String) {
      return Err('invalid_vpa', vpaRaw);
    }

    final bankCode = guessBankFromSender(sender, sourceSms) ?? 'UNKNOWN';
    final merchant = (merchantRaw as String?)?.trim() ?? '';
    final ref = (refRaw as String?)?.trim();
    final vpa = (vpaRaw as String?)?.trim();

    String? upiRef;
    String? externalRef;
    String? upiPayeeVpa;
    if (type == TransactionType.upi) {
      upiRef = ref?.isNotEmpty == true ? ref : null;
      upiPayeeVpa = vpa?.isNotEmpty == true ? vpa : null;
    } else {
      externalRef = ref?.isNotEmpty == true ? ref : null;
    }

    final dedupeKey = buildDedupeKey(
      bankCode: bankCode,
      bookedAt: bookedAt,
      amountPaise: amount.paise,
      ref: ref,
      normalizedBody: sourceSms,
    );

    return Ok(
      ParsedTransaction(
        amountPaise: amount,
        direction: dir,
        type: type,
        bookedAt: bookedAt,
        bankCode: bankCode,
        rawMerchant: merchant,
        rawDescription: sourceSms,
        upiPayeeVpa: upiPayeeVpa,
        upiRef: upiRef,
        externalRef: externalRef,
        dedupeKey: dedupeKey,
      ),
    );
  }

  Result<ParsedTransaction> _validateDomain(Map<String, Object?> map) {
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

/// Span must appear verbatim in the source SMS.
bool spanAppearsInSource(String sourceSms, String span) {
  final s = span.trim();
  if (s.isEmpty) return false;
  return sourceSms.contains(s);
}

/// Amount span in source — strict first, then common Rs./Rs/INR punctuation variants.
bool amountSpanAppearsInSource(String sourceSms, String span) {
  if (spanAppearsInSource(sourceSms, span)) return true;
  for (final variant in _amountSpanMatchVariants(span)) {
    if (variant != span && spanAppearsInSource(sourceSms, variant)) {
      return true;
    }
  }
  return false;
}

Iterable<String> _amountSpanMatchVariants(String span) sync* {
  final s = span.trim();
  yield s.replaceFirst(RegExp(r'^Rs\.\s*', caseSensitive: false), 'Rs ');
  yield s.replaceFirst(RegExp(r'^Rs\s+', caseSensitive: false), 'Rs.');
  yield s.replaceFirst(RegExp(r'^INR\s+', caseSensitive: false), 'INR ');
}

/// Parse a verbatim amount span via existing extractors (no LLM arithmetic).
MoneyPaise? parseAmountSpan(String span) {
  final trimmed = span.trim();
  if (trimmed.isEmpty) return null;
  return parseAmountToken(trimmed) ?? parseAmountToken('Rs.$trimmed');
}

/// Parse verbatim date/time spans into UTC [DateTime].
DateTime? parseDateTimeSpans(String dateSpan, String? timeSpan) {
  final dateOnly = extractDateTime(dateSpan.trim());
  if (dateOnly == null) return null;
  if (timeSpan == null || timeSpan.trim().isEmpty) {
    return dateOnly;
  }
  final t = timeSpan.trim();
  final tm = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(t);
  if (tm != null) {
    return DateTime.utc(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      int.parse(tm.group(1)!),
      int.parse(tm.group(2)!),
    );
  }
  return extractDateTime('$dateSpan $timeSpan') ?? dateOnly;
}

import 'dart:convert';

import '../core/models/money.dart';
import '../core/models/transaction_type.dart';
import '../parsing/common/extractors.dart';
import '../parsing/sms/sender_matcher.dart';

/// Per-field anchor validation outcome.
enum AnchorFieldStatus { pass, reject, infer, demote, override }

class AnchorFieldReport {
  const AnchorFieldReport({
    required this.field,
    required this.status,
    this.detail,
  });

  final String field;
  final AnchorFieldStatus status;
  final String? detail;

  Map<String, Object?> toJson() => {
        'field': field,
        'status': status.name,
        if (detail != null) 'detail': detail,
      };

  factory AnchorFieldReport.fromJson(Map<String, Object?> json) {
    return AnchorFieldReport(
      field: json['field'] as String,
      status: AnchorFieldStatus.values.byName(json['status'] as String),
      detail: json['detail'] as String?,
    );
  }
}

class AnchorReport {
  const AnchorReport({required this.fields, required this.allCriticalPassed});

  final List<AnchorFieldReport> fields;
  final bool allCriticalPassed;

  Map<String, Object?> toJson() => {
        'fields': fields.map((f) => f.toJson()).toList(),
        'all_critical_passed': allCriticalPassed,
      };

  factory AnchorReport.fromJson(Map<String, Object?> json) {
    final raw = json['fields'] as List<Object?>;
    return AnchorReport(
      fields: raw
          .map((e) => AnchorFieldReport.fromJson(Map<String, Object?>.from(e as Map)))
          .toList(),
      allCriticalPassed: json['all_critical_passed'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Validates LLM JSON against [rawText] using deterministic extractors.
/// Returns cleaned JSON map + per-field anchor report.
({Map<String, Object?> cleaned, AnchorReport report}) validateAgainstSource(
  String rawText,
  Map<String, Object?> llmJson, {
  String? sender,
  double merchantTokenOverlapThreshold = 0.34,
}) {
  final cleaned = Map<String, Object?>.from(llmJson);
  final reports = <AnchorFieldReport>[];

  // amount_paise — validator parsed verbatim span; corroborate with sole-txn extractor
  final amountField = cleaned['amount_paise'];
  if (amountField is int) {
    final extracted = extractSoleTxnAmount(rawText);
    if (extracted.isOk && extracted.okOrNull!.paise == amountField) {
      reports.add(const AnchorFieldReport(field: 'amount_paise', status: AnchorFieldStatus.pass));
    } else {
      reports.add(AnchorFieldReport(
        field: 'amount_paise',
        status: AnchorFieldStatus.reject,
        detail: extracted.errorOrNull ?? 'mismatch',
      ));
      cleaned.remove('amount_paise');
    }
  } else {
    reports.add(const AnchorFieldReport(
      field: 'amount_paise',
      status: AnchorFieldStatus.reject,
      detail: 'missing_or_invalid',
    ));
    cleaned.remove('amount_paise');
  }

  // direction — corroborate with keyword sets
  final dirWire = cleaned['direction'];
  if (dirWire is String) {
    final extracted = extractDirection(rawText);
    if (extracted != null && extracted.name == dirWire) {
      reports.add(const AnchorFieldReport(field: 'direction', status: AnchorFieldStatus.pass));
      cleaned['direction_inferred'] = false;
    } else if (extracted == null) {
      reports.add(const AnchorFieldReport(
        field: 'direction',
        status: AnchorFieldStatus.infer,
        detail: 'no_direction_cue',
      ));
      cleaned['direction_inferred'] = true;
    } else {
      reports.add(AnchorFieldReport(
        field: 'direction',
        status: AnchorFieldStatus.reject,
        detail: 'contradicted_by_text',
      ));
      cleaned.remove('direction');
    }
  }

  // booked_at — validator parsed verbatim date span; normalize from full text
  final bookedRaw = cleaned['booked_at'];
  if (bookedRaw is String) {
    final extractedDate = extractDateTime(rawText);
    if (extractedDate != null) {
      cleaned['booked_at'] = extractedDate.toUtc().toIso8601String();
      reports.add(const AnchorFieldReport(field: 'booked_at', status: AnchorFieldStatus.pass));
    } else {
      reports.add(const AnchorFieldReport(
        field: 'booked_at',
        status: AnchorFieldStatus.reject,
        detail: 'date_not_in_source',
      ));
      cleaned.remove('booked_at');
    }
  } else {
    reports.add(const AnchorFieldReport(
      field: 'booked_at',
      status: AnchorFieldStatus.reject,
      detail: 'missing',
    ));
  }

  // bank_code — never trust LLM; use sender guess
  final guessedBank = guessBankFromSender(sender, rawText);
  cleaned['bank_code'] = guessedBank ?? 'UNKNOWN';
  reports.add(AnchorFieldReport(
    field: 'bank_code',
    status: AnchorFieldStatus.override,
    detail: 'from_sender_not_llm',
  ));

  // refs / VPA / account mask — if present must appear in raw text
  for (final key in ['upi_ref', 'external_ref', 'account_hint']) {
    final val = cleaned[key];
    if (val is! String || val.isEmpty) continue;
    if (_appearsInSource(rawText, val)) {
      reports.add(AnchorFieldReport(field: key, status: AnchorFieldStatus.pass));
    } else {
      reports.add(AnchorFieldReport(field: key, status: AnchorFieldStatus.reject, detail: 'not_in_source'));
      cleaned.remove(key);
    }
  }

  // dedupe_key is Dart-computed (never from LLM); verify ref material when present
  final dedupe = cleaned['dedupe_key'];
  if (dedupe is String) {
    final parts = dedupe.split('|');
    if (parts.length >= 3) {
      final refPart = parts[2];
      if (RegExp(r'^\d{6,}$').hasMatch(refPart) && !_appearsInSource(rawText, refPart)) {
        reports.add(const AnchorFieldReport(
          field: 'dedupe_key',
          status: AnchorFieldStatus.reject,
          detail: 'ref_not_in_source',
        ));
      } else {
        reports.add(const AnchorFieldReport(field: 'dedupe_key', status: AnchorFieldStatus.pass));
      }
    }
  }

  // merchant — fuzzy substring; demote balance-adjacent phrases
  final merchant = cleaned['raw_merchant'];
  if (merchant is String && merchant.isNotEmpty) {
    if (_isBalanceAdjacentMerchant(rawText, merchant)) {
      reports.add(const AnchorFieldReport(
        field: 'raw_merchant',
        status: AnchorFieldStatus.demote,
        detail: 'balance_adjacent_phrase',
      ));
      cleaned['raw_merchant'] = '';
    } else if (_merchantAnchored(rawText, merchant, merchantTokenOverlapThreshold)) {
      reports.add(const AnchorFieldReport(field: 'raw_merchant', status: AnchorFieldStatus.pass));
    } else {
      reports.add(const AnchorFieldReport(
        field: 'raw_merchant',
        status: AnchorFieldStatus.demote,
        detail: 'not_substring_of_source',
      ));
      cleaned['raw_merchant'] = '';
    }
  }

  final critical = {'amount_paise', 'booked_at', 'direction'};
  final criticalPassed = reports
      .where((r) => critical.contains(r.field))
      .every((r) => r.status == AnchorFieldStatus.pass || r.status == AnchorFieldStatus.infer);

  return (
    cleaned: cleaned,
    report: AnchorReport(fields: reports, allCriticalPassed: criticalPassed),
  );
}

String? guessBankFromSender(String? sender, String rawText) {
  if (sender != null && sender.isNotEmpty) {
    final match = matchSender(sender);
    if (match.bankCode != 'UNKNOWN') return match.bankCode;
  }
  final upper = rawText.toUpperCase();
  for (final code in ['HDFC', 'ICICI', 'SBI', 'AXIS', 'KOTAK', 'PNB', 'BOB']) {
    if (upper.contains(code)) return code;
  }
  return null;
}

bool _appearsInSource(String rawText, String value) {
  final norm = value.replaceAll(RegExp(r'[\s*\-]'), '').toLowerCase();
  final src = rawText.replaceAll(RegExp(r'[\s*\-]'), '').toLowerCase();
  return src.contains(norm);
}

bool _merchantAnchored(String rawText, String merchant, double threshold) {
  final m = merchant.trim().toLowerCase();
  if (m.isEmpty) return false;
  final src = rawText.toLowerCase();
  if (src.contains(m)) return true;

  final mTokens = _tokens(m);
  if (mTokens.isEmpty) return false;
  final srcTokens = _tokens(src);
  final overlap = mTokens.where(srcTokens.contains).length / mTokens.length;
  return overlap >= threshold;
}

bool _isBalanceAdjacentMerchant(String rawText, String merchant) {
  final lower = rawText.toLowerCase();
  final m = merchant.toLowerCase();
  if (!lower.contains('avl') && !lower.contains('available bal')) return false;
  if (m.contains('avl') || m.contains('bal') || m.contains('balance')) {
    return true;
  }
  final balance = extractBalance(rawText);
  if (balance == null) return false;
  return m.contains((balance.paise / 100).toString());
}

Set<String> _tokens(String text) {
  return text
      .split(RegExp(r'[^a-z0-9@]+'))
      .where((t) => t.length >= 3)
      .toSet();
}

/// Convenience: parse JSON string then anchor.
({Map<String, Object?> cleaned, AnchorReport report}) validateJsonAgainstSource(
  String rawText,
  String llmJson, {
  String? sender,
}) {
  final decoded = jsonDecode(llmJson.trim());
  if (decoded is! Map) {
    return (
      cleaned: <String, Object?>{},
      report: const AnchorReport(fields: [], allCriticalPassed: false),
    );
  }
  return validateAgainstSource(
    rawText,
    Map<String, Object?>.from(decoded),
    sender: sender,
  );
}

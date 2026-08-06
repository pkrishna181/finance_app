import 'dart:convert';

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

  // direction — keyword precedence overrides LLM; never rejects
  final dirWire = cleaned['direction'];
  if (dirWire is String) {
    final cue = classifyDirectionCue(rawText);
    final llmDir = TransactionDirection.fromWire(dirWire);
    switch (cue) {
      case DirectionCueKind.unambiguousDebit:
        cleaned['direction'] = TransactionDirection.debit.wireName;
        cleaned['direction_inferred'] = false;
        if (llmDir != TransactionDirection.debit) {
          reports.add(const AnchorFieldReport(
            field: 'direction',
            status: AnchorFieldStatus.override,
            detail: 'keyword_override',
          ));
        } else {
          reports.add(const AnchorFieldReport(field: 'direction', status: AnchorFieldStatus.pass));
        }
      case DirectionCueKind.unambiguousCredit:
        cleaned['direction'] = TransactionDirection.credit.wireName;
        cleaned['direction_inferred'] = false;
        if (llmDir != TransactionDirection.credit) {
          reports.add(const AnchorFieldReport(
            field: 'direction',
            status: AnchorFieldStatus.override,
            detail: 'keyword_override',
          ));
        } else {
          reports.add(const AnchorFieldReport(field: 'direction', status: AnchorFieldStatus.pass));
        }
      case DirectionCueKind.conflicting:
      case DirectionCueKind.none:
        reports.add(AnchorFieldReport(
          field: 'direction',
          status: AnchorFieldStatus.infer,
          detail: cue == DirectionCueKind.conflicting
              ? 'conflicting_cues'
              : 'no_direction_cue',
        ));
        cleaned['direction_inferred'] = true;
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
  for (final key in [
    'upi_ref',
    'external_ref',
    'account_hint',
    'upi_payee_vpa',
    'upi_payer_vpa',
  ]) {
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
      .every((r) =>
          r.status == AnchorFieldStatus.pass ||
          r.status == AnchorFieldStatus.infer ||
          r.status == AnchorFieldStatus.override);

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

/// Benchmark / debug one-line anchor verdict after validation.
String formatAnchorVerdictLine(AnchorReport report, Map<String, Object?> cleaned) {
  AnchorFieldStatus? statusFor(String field) {
    for (final f in report.fields) {
      if (f.field == field) return f.status;
    }
    return null;
  }

  if (statusFor('amount_paise') == AnchorFieldStatus.reject) {
    return 'anchor: rejected (amount)';
  }
  if (statusFor('booked_at') == AnchorFieldStatus.reject) {
    return 'anchor: rejected (date)';
  }

  final dropped = <String>[];
  if (statusFor('raw_merchant') == AnchorFieldStatus.demote) dropped.add('m');
  for (final key in ['upi_payee_vpa', 'upi_payer_vpa']) {
    if (statusFor(key) == AnchorFieldStatus.reject && !dropped.contains('v')) {
      dropped.add('v');
    }
  }
  for (final key in ['upi_ref', 'external_ref']) {
    if (statusFor(key) == AnchorFieldStatus.reject && !dropped.contains('f')) {
      dropped.add('f');
    }
  }

  final directionOverridden =
      statusFor('direction') == AnchorFieldStatus.override;
  final directionInferred = cleaned['direction_inferred'] == true;
  final merchantOnlyDrop = dropped.length == 1 && dropped.first == 'm';
  final label = merchantOnlyDrop ? 'partial' : 'usable';

  final buf = StringBuffer('anchor: $label');
  if (dropped.isNotEmpty) {
    buf.write(' (dropped: ${dropped.join(', ')})');
  }
  if (directionOverridden) buf.write(' (direction: overridden)');
  if (directionInferred) buf.write(' (directionInferred)');
  return buf.toString();
}

/// Running batch tally for benchmark output.
class AnchorBatchTally {
  int usable = 0;
  int rejected = 0;
  int directionOverrides = 0;

  void add(AnchorReport report, Map<String, Object?> cleaned) {
    final line = formatAnchorVerdictLine(report, cleaned);
    if (line.contains('rejected')) {
      rejected++;
    } else {
      usable++;
    }
    if (report.fields.any(
      (f) => f.field == 'direction' && f.status == AnchorFieldStatus.override,
    )) {
      directionOverrides++;
    }
  }

  String summaryLine() =>
      'batch verdict: $usable usable / $rejected rejected ($directionOverrides direction overrides)';
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

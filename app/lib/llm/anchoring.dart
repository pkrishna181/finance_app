import 'dart:convert';

import '../core/models/transaction_type.dart';
import '../parsing/common/extractors.dart';
import '../parsing/sms/sender_matcher.dart';
import 'merchant_seed_catalog.dart';

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
  MerchantSeedCatalog? merchantSeeds,
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

  // merchant — balance demote; VPA-in-slot routing; fuzzy anchor + shape gate
  final merchant = cleaned['raw_merchant'];
  if (merchant is String && merchant.isNotEmpty) {
    if (_isBalanceAdjacentMerchant(rawText, merchant)) {
      reports.add(const AnchorFieldReport(
        field: 'raw_merchant',
        status: AnchorFieldStatus.demote,
        detail: 'balance_adjacent_phrase',
      ));
      cleaned['raw_merchant'] = '';
    } else if (_routeMerchantVpaIfApplicable(
      cleaned,
      merchant,
      rawText,
      reports,
      merchantSeeds,
    )) {
      // merchant slot held a VPA — routed to v + hint from local part
    } else if (_vpaPassesShapeGate(merchant.trim()) &&
        _appearsInSource(rawText, merchant)) {
      cleaned['raw_merchant'] = merchantSeeds?.merchantHintFromVpa(merchant) ??
          MerchantSeedCatalog.vpaLocalPart(merchant);
      reports.add(const AnchorFieldReport(
        field: 'raw_merchant',
        status: AnchorFieldStatus.override,
        detail: 'from_vpa_local_part',
      ));
    } else if (!_merchantAnchored(rawText, merchant, merchantTokenOverlapThreshold)) {
      reports.add(const AnchorFieldReport(
        field: 'raw_merchant',
        status: AnchorFieldStatus.demote,
        detail: 'not_substring_of_source',
      ));
      cleaned['raw_merchant'] = '';
    } else if (_merchantFailsShapeGate(merchant, rawText)) {
      reports.add(const AnchorFieldReport(
        field: 'raw_merchant',
        status: AnchorFieldStatus.demote,
        detail: 'bad_shape',
      ));
      cleaned['raw_merchant'] = '';
    } else {
      reports.add(const AnchorFieldReport(field: 'raw_merchant', status: AnchorFieldStatus.pass));
    }
  }

  // refs / VPA / account mask — verbatim in source, then shape gate
  for (final key in [
    'upi_ref',
    'external_ref',
    'account_hint',
    'upi_payee_vpa',
    'upi_payer_vpa',
  ]) {
    final val = cleaned[key];
    if (val is! String || val.isEmpty) continue;
    if (!_appearsInSource(rawText, val)) {
      reports.add(AnchorFieldReport(field: key, status: AnchorFieldStatus.reject, detail: 'not_in_source'));
      cleaned.remove(key);
      continue;
    }
    if (key == 'upi_payee_vpa' || key == 'upi_payer_vpa') {
      if (!_vpaPassesShapeGate(val)) {
        reports.removeWhere((r) => r.field == key);
        reports.add(AnchorFieldReport(field: key, status: AnchorFieldStatus.reject, detail: 'bad_shape'));
        cleaned.remove(key);
        continue;
      }
    } else if (key == 'upi_ref' || key == 'external_ref') {
      if (!_refPassesShapeGate(val, rawText)) {
        reports.removeWhere((r) => r.field == key);
        reports.add(AnchorFieldReport(field: key, status: AnchorFieldStatus.reject, detail: 'bad_shape'));
        cleaned.remove(key);
        continue;
      }
    }
    reports.removeWhere((r) => r.field == key);
    reports.add(AnchorFieldReport(field: key, status: AnchorFieldStatus.pass));
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

const _bankGuessCodes = [
  'HDFC',
  'ICICI',
  'SBI',
  'AXIS',
  'KOTAK',
  'PNB',
  'BOB',
  'PAYTM',
];

const _bankProductTerms = {
  'a',
  'c',
  'ac',
  'acct',
  'account',
  'bank',
  'xx',
  'xxx',
  'xxxx',
  'ending',
  'no',
};

bool _vpaPassesShapeGate(String vpa) {
  final extracted = extractVpa(vpa.trim());
  return extracted != null && extracted == vpa.trim();
}

bool _refPassesShapeGate(String ref, String rawText) {
  final t = ref.trim();
  if (!isStrongRef(t)) return false;
  final mask = extractAccountMask(rawText);
  if (mask != null && t == mask) return false;
  final card4 = extractCardLast4(rawText);
  if (card4 != null && t == card4) return false;
  return true;
}

bool _merchantFailsShapeGate(String merchant, String rawText) {
  final m = merchant.trim();
  if (m.isEmpty) return false;
  if (extractAccountMask(m) != null || extractCardLast4(m) != null) {
    return true;
  }
  final mask = extractAccountMask(rawText);
  if (mask != null && m == mask) return true;
  return _isBankOrProductOnlyMerchant(m);
}

bool _routeMerchantVpaIfApplicable(
  Map<String, Object?> cleaned,
  String merchant,
  String rawText,
  List<AnchorFieldReport> reports,
  MerchantSeedCatalog? merchantSeeds,
) {
  if (cleaned['type'] != TransactionType.upi.wireName) return false;
  final vpa = merchant.trim();
  if (!_vpaPassesShapeGate(vpa) || !_appearsInSource(rawText, vpa)) {
    return false;
  }

  final dir = cleaned['direction'] as String? ?? TransactionDirection.debit.wireName;
  final vpaKey = dir == TransactionDirection.credit.wireName
      ? 'upi_payer_vpa'
      : 'upi_payee_vpa';
  final existing = (cleaned[vpaKey] as String?)?.trim() ?? '';
  if (existing.isNotEmpty && existing != vpa) return false;

  if (existing.isEmpty) {
    cleaned[vpaKey] = vpa;
  }

  cleaned['raw_merchant'] = merchantSeeds?.merchantHintFromVpa(vpa) ??
      MerchantSeedCatalog.vpaLocalPart(vpa);
  reports.add(const AnchorFieldReport(
    field: 'raw_merchant',
    status: AnchorFieldStatus.override,
    detail: 'from_vpa_local_part',
  ));
  return true;
}

bool _isBankOrProductOnlyMerchant(String merchant) {
  final tokens = merchant
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9@]+'))
      .where((t) => t.isNotEmpty);
  if (tokens.isEmpty) return true;
  final bankLower = _bankGuessCodes.map((c) => c.toLowerCase()).toSet();
  return tokens.every(
    (t) => bankLower.contains(t) || _bankProductTerms.contains(t),
  );
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
    AnchorFieldStatus? worst;
    for (final f in report.fields) {
      if (f.field != field) continue;
      worst = _worstAnchorStatus(worst, f.status);
    }
    return worst;
  }

  if (statusFor('amount_paise') == AnchorFieldStatus.reject) {
    return 'anchor: rejected (amount)';
  }
  if (statusFor('booked_at') == AnchorFieldStatus.reject) {
    return 'anchor: rejected (date)';
  }

  final dropped = <String>[];
  if (statusFor('raw_merchant') == AnchorFieldStatus.demote) dropped.add('m');
  for (final key in ['upi_ref', 'external_ref']) {
    if (statusFor(key) == AnchorFieldStatus.reject && !dropped.contains('f')) {
      dropped.add('f');
    }
  }
  for (final key in ['upi_payee_vpa', 'upi_payer_vpa']) {
    if (statusFor(key) == AnchorFieldStatus.reject && !dropped.contains('v')) {
      dropped.add('v');
    }
  }

  final directionOverridden =
      statusFor('direction') == AnchorFieldStatus.override;
  final directionInferred = cleaned['direction_inferred'] == true;

  final buf = StringBuffer('anchor: usable');
  if (dropped.isNotEmpty) {
    buf.write(' (dropped: ${dropped.join(', ')})');
  }
  if (directionOverridden) buf.write(' (direction: overridden)');
  if (directionInferred) buf.write(' (direction: inferred)');
  return buf.toString();
}

AnchorFieldStatus _worstAnchorStatus(
  AnchorFieldStatus? current,
  AnchorFieldStatus next,
) {
  if (current == null) return next;
  return _anchorStatusRank(next) < _anchorStatusRank(current) ? next : current;
}

int _anchorStatusRank(AnchorFieldStatus status) => switch (status) {
      AnchorFieldStatus.reject => 0,
      AnchorFieldStatus.demote => 1,
      AnchorFieldStatus.override => 2,
      AnchorFieldStatus.infer => 3,
      AnchorFieldStatus.pass => 4,
    };

/// Running batch tally for benchmark output.
class AnchorBatchTally {
  int usable = 0;
  int rejected = 0;
  int directionOverrides = 0;
  int directionInferred = 0;

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
    if (cleaned['direction_inferred'] == true) {
      directionInferred++;
    }
  }

  String summaryLine() =>
      'batch verdict: $usable usable / $rejected rejected '
      '($directionOverrides overridden, $directionInferred inferred)';
}

/// Convenience: parse JSON string then anchor.
({Map<String, Object?> cleaned, AnchorReport report}) validateJsonAgainstSource(
  String rawText,
  String llmJson, {
  String? sender,
  MerchantSeedCatalog? merchantSeeds,
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
    merchantSeeds: merchantSeeds,
  );
}

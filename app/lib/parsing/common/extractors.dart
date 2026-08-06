import '../../core/models/money.dart';
import '../../core/models/transaction_type.dart';
import '../../core/result/result.dart';

// ---------------------------------------------------------------------------
// Amount
// ---------------------------------------------------------------------------

final _amountToken = RegExp(
  r'(?:Rs\.?|INR|₹)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
  caseSensitive: false,
);

final _balanceCue = RegExp(
  r'(?:avl\.?\s*(?:bal(?:ance)?|lmt|limit)|available\s+(?:bal(?:ance)?|limit)|bal(?:ance)?\s*:)',
  caseSensitive: false,
);

/// Parse a statement amount cell: may include Rs/INR, Indian grouping,
/// trailing Dr/Cr, or be a bare number string.
({MoneyPaise? amount, TransactionDirection? suffixDirection}) parseAmountCell(
  String raw,
) {
  var t = raw.trim();
  if (t.isEmpty || t == '-' || t.toLowerCase() == 'null') {
    return (amount: null, suffixDirection: null);
  }
  TransactionDirection? dir;
  final suffix = RegExp(
    r'[\s,]*(cr|dr)\.?\s*$',
    caseSensitive: false,
  ).firstMatch(t);
  if (suffix != null) {
    dir = suffix.group(1)!.toLowerCase().startsWith('c')
        ? TransactionDirection.credit
        : TransactionDirection.debit;
    t = t.substring(0, suffix.start).trim();
  } else {
    // Also handle "1,000.00Cr" with no space.
    final glued = RegExp(
      r'^(.*\d)\s*(cr|dr)\.?$',
      caseSensitive: false,
    ).firstMatch(t);
    if (glued != null) {
      dir = glued.group(2)!.toLowerCase().startsWith('c')
          ? TransactionDirection.credit
          : TransactionDirection.debit;
      t = glued.group(1)!.trim();
    }
  }
  t = t
      .replaceAll('₹', '')
      .replaceAll(RegExp(r'^(?:rs\.?|inr)\s*', caseSensitive: false), '');
  t = t.replaceAll('"', '').trim();
  if (t.isEmpty) return (amount: null, suffixDirection: dir);

  final amt = parseAmountToken('Rs.$t') ?? parseAmountToken(t);
  if (amt != null) return (amount: amt, suffixDirection: dir);

  final cleaned = t.replaceAll(',', '');
  final n = num.tryParse(cleaned);
  if (n == null) return (amount: null, suffixDirection: dir);
  return (amount: MoneyPaise((n * 100).round()), suffixDirection: dir);
}

/// Parse a single amount token like "Rs.1,23,456.78" or "INR 500" → paise.
MoneyPaise? parseAmountToken(String raw) {
  final m = _amountToken.firstMatch(raw.trim());
  if (m == null) return null;
  return _digitsToPaise(m.group(1)!);
}

MoneyPaise _digitsToPaise(String grouped) {
  final cleaned = grouped.replaceAll(',', '');
  if (cleaned.contains('.')) {
    final parts = cleaned.split('.');
    final whole = int.parse(parts[0]);
    final frac = parts[1].padRight(2, '0').substring(0, 2);
    return MoneyPaise(whole * 100 + int.parse(frac));
  }
  return MoneyPaise(int.parse(cleaned) * 100);
}

/// Find txn-like amounts in [body], excluding balance/limit phrases.
/// Returns Err when zero or multiple candidates (templates must decide).
Result<MoneyPaise> extractSoleTxnAmount(String body) {
  final matches = _amountToken.allMatches(body).toList();
  final txn = <MoneyPaise>[];
  for (final m in matches) {
    final before = body.substring(0, m.start);
    final windowStart = before.length > 24 ? before.length - 24 : 0;
    final prelude = before.substring(windowStart);
    if (_balanceCue.hasMatch(prelude)) continue;
    // Also skip if the match itself is right after Avl Bal
    final line = body.substring(
      m.start > 40 ? m.start - 40 : 0,
      m.end,
    );
    if (_balanceCue.hasMatch(line) &&
        _balanceCue.firstMatch(line)!.start <
            line.toLowerCase().indexOf(m.group(0)!.toLowerCase().substring(0, 2))) {
      continue;
    }
    // Simpler: if amount is within 30 chars after a balance cue, skip.
    final cueMatches = _balanceCue.allMatches(body);
    var isBalance = false;
    for (final c in cueMatches) {
      if (m.start >= c.end && m.start - c.end <= 30) {
        isBalance = true;
        break;
      }
    }
    if (isBalance) continue;
    txn.add(_digitsToPaise(m.group(1)!));
  }
  if (txn.isEmpty) {
    return const Err('no_txn_amount');
  }
  if (txn.length > 1) {
    return const Err('ambiguous_multiple_amounts');
  }
  return Ok(txn.single);
}

/// Extract available balance / limit amount, or null.
MoneyPaise? extractBalance(String body) {
  final cue = _balanceCue.firstMatch(body);
  if (cue == null) return null;
  final rest = body.substring(cue.end);
  final m = _amountToken.firstMatch(rest);
  if (m == null) return null;
  return _digitsToPaise(m.group(1)!);
}

// ---------------------------------------------------------------------------
// Date / time
// ---------------------------------------------------------------------------

const _months = <String, int>{
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

final _datePatterns = <RegExp>[
  // dd-MM-yyyy or dd/MM/yyyy
  RegExp(r'\b(\d{2})[-/](\d{2})[-/](\d{4})\b'),
  // dd-MM-yy or dd/MM/yy
  RegExp(r'\b(\d{2})[-/](\d{2})[-/](\d{2})\b'),
  // 01-Aug-26 or 01-Aug-2026
  RegExp(
    r'\b(\d{2})-([A-Za-z]{3})-(\d{2,4})\b',
    caseSensitive: false,
  ),
  // 01 Aug 2026 / 01 Aug 26
  RegExp(
    r'\b(\d{2})\s+([A-Za-z]{3})\s+(\d{2,4})\b',
    caseSensitive: false,
  ),
  // 01Aug26
  RegExp(
    r'\b(\d{2})([A-Za-z]{3})(\d{2,4})\b',
    caseSensitive: false,
  ),
];

final _timePattern = RegExp(r'\b(\d{1,2}):(\d{2})(?::(\d{2}))?\b');

/// Parse the first recognizable Indian date in [text]; attach time if present.
DateTime? extractDateTime(String text, {DateTime? fallback}) {
  DateTime? date;
  for (final pat in _datePatterns) {
    final m = pat.firstMatch(text);
    if (m == null) continue;
    date = _matchToDate(m);
    if (date != null) break;
  }
  date ??= fallback;
  if (date == null) return null;

  final t = _timePattern.firstMatch(text);
  if (t != null) {
    final hour = int.parse(t.group(1)!);
    final minute = int.parse(t.group(2)!);
    final second = int.parse(t.group(3) ?? '0');
    return DateTime.utc(date.year, date.month, date.day, hour, minute, second);
  }
  return DateTime.utc(date.year, date.month, date.day);
}

DateTime? _matchToDate(RegExpMatch m) {
  final a = m.group(1)!;
  final b = m.group(2)!;
  final c = m.group(3)!;

  final day = int.tryParse(a);
  if (day == null || day < 1 || day > 31) return null;

  int? month;
  int? year;

  final monthNum = int.tryParse(b);
  if (monthNum != null) {
    month = monthNum;
    year = _normalizeYear(int.parse(c));
  } else {
    month = _months[b.toLowerCase()];
    if (month == null) return null;
    year = _normalizeYear(int.parse(c));
  }
  if (month < 1 || month > 12) return null;
  return DateTime.utc(year, month, day);
}

int _normalizeYear(int y) => y < 100 ? 2000 + y : y;

String formatDayKey(DateTime dt) {
  final u = dt.toUtc();
  return '${u.year.toString().padLeft(4, '0')}-'
      '${u.month.toString().padLeft(2, '0')}-'
      '${u.day.toString().padLeft(2, '0')}';
}

String formatTimeKey(DateTime dt) {
  final u = dt.toUtc();
  return '${u.hour.toString().padLeft(2, '0')}:'
      '${u.minute.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Direction
// ---------------------------------------------------------------------------

final _debitWords = RegExp(
  r'\b(debited|debit|spent|withdrawn|paid|purchase|dr\.?)\b',
  caseSensitive: false,
);
final _creditWords = RegExp(
  r'\b(credited|credit|received|deposited|cr\.?|refund(?:ed)?)\b',
  caseSensitive: false,
);

TransactionDirection? extractDirection(String body) {
  final hasDebit = _debitWords.hasMatch(body);
  final hasCredit = _creditWords.hasMatch(body);
  if (hasDebit && !hasCredit) return TransactionDirection.debit;
  if (hasCredit && !hasDebit) return TransactionDirection.credit;
  // "Paid Rs.X" is debit (Paytm style)
  if (RegExp(r'\bpaid\b', caseSensitive: false).hasMatch(body)) {
    return TransactionDirection.debit;
  }
  if (hasDebit) return TransactionDirection.debit;
  if (hasCredit) return TransactionDirection.credit;
  return null;
}

/// How confidently [body] signals debit vs credit for anchor precedence.
///
/// Strong `Dr`/`Cr` abbreviations (e.g. "Dr Rs") win even when reversal
/// phrasing also mentions the opposite keyword.
enum DirectionCueKind { unambiguousDebit, unambiguousCredit, conflicting, none }

final _strongDrCue = RegExp(r'\bDr\.?\s', caseSensitive: false);
final _strongCrCue = RegExp(r'\bCr\.?\s', caseSensitive: false);

DirectionCueKind classifyDirectionCue(String body) {
  final hasStrongDr = _strongDrCue.hasMatch(body);
  final hasStrongCr = _strongCrCue.hasMatch(body);
  if (hasStrongDr && !hasStrongCr) return DirectionCueKind.unambiguousDebit;
  if (hasStrongCr && !hasStrongDr) return DirectionCueKind.unambiguousCredit;
  if (hasStrongDr && hasStrongCr) return DirectionCueKind.conflicting;

  final hasDebit = _debitWords.hasMatch(body);
  final hasCredit = _creditWords.hasMatch(body);
  if (hasDebit && !hasCredit) return DirectionCueKind.unambiguousDebit;
  if (hasCredit && !hasDebit) return DirectionCueKind.unambiguousCredit;
  if (hasDebit && hasCredit) return DirectionCueKind.conflicting;
  if (RegExp(r'\bpaid\b', caseSensitive: false).hasMatch(body)) {
    return DirectionCueKind.unambiguousDebit;
  }
  return DirectionCueKind.none;
}

// ---------------------------------------------------------------------------
// Refs / VPA / account
// ---------------------------------------------------------------------------

final _upiRef = RegExp(
  r'(?:UPI\s*Ref(?:\s*No)?\.?|UPI:)\s*([0-9]{12})\b',
  caseSensitive: false,
);
final _impsRef = RegExp(
  r'(?:IMPS(?:/[A-Z0-9]+)?/|IMPS\s*Ref(?:\s*No)?\.?\s*)([0-9]{12})\b',
  caseSensitive: false,
);
final _neftUtr = RegExp(
  r'(?:NEFT(?:\s*UTR)?|UTR)\s*:?\s*([A-Z0-9]{12,22})\b',
  caseSensitive: false,
);
final _cardLast4 = RegExp(
  r'(?:card|a/?c|acct|account|xx+)\s*(?:ending\s*)?(?:\*{0,2}|x{0,4}|X{0,4})(\d{4})\b',
  caseSensitive: false,
);
final _vpa = RegExp(
  r'\b([a-zA-Z0-9._-]{2,}@[a-zA-Z][a-zA-Z0-9]{2,})\b',
);
final _accountMask = RegExp(
  r'(?:A/?c|Acct|Account)\s*(?:No\.?\s*)?(?:XX+|X+|\*{2,}|ending\s+)?(\d{4})\b',
  caseSensitive: false,
);

String? extractUpiRef(String body) => _upiRef.firstMatch(body)?.group(1);

String? extractImpsRef(String body) => _impsRef.firstMatch(body)?.group(1);

String? extractNeftUtr(String body) => _neftUtr.firstMatch(body)?.group(1);

final _upiPathRef = RegExp(r'UPI/(\d{12})/', caseSensitive: false);
final _embeddedStrongRef = RegExp(r'\b([A-Z0-9]{12,22})\b');

/// UPI/412345678901/merchant@ybl style refs in statement narration.
String? extractUpiPathRef(String body) => _upiPathRef.firstMatch(body)?.group(1);

/// First token in [body] that passes [isStrongRef].
String? extractEmbeddedStrongRef(String body) {
  for (final m in _embeddedStrongRef.allMatches(body)) {
    final candidate = m.group(1)!;
    if (isStrongRef(candidate)) return candidate;
  }
  return null;
}

/// Best-effort ref extraction from any statement text blob.
String? extractAnyRef(String body) =>
    extractUpiRef(body) ??
    extractUpiPathRef(body) ??
    extractImpsRef(body) ??
    extractNeftUtr(body) ??
    extractEmbeddedStrongRef(body);

/// Strip a leading statement date when narration spills into the date column.
String stripLeadingStatementDate(String cell) {
  final t = cell.trim();
  for (final pat in _datePatterns) {
    final m = pat.firstMatch(t);
    if (m != null && m.start == 0) {
      return t.substring(m.end).trimLeft();
    }
  }
  return t;
}

/// Normalize ref across dedicated ref column, narration, and date spill.
String? resolveStatementRef({
  required String refCol,
  required String narration,
  String? dateCell,
}) {
  for (final text in [refCol, narration]) {
    if (text.trim().isEmpty) continue;
    final extracted = extractAnyRef(text);
    if (extracted != null) return extracted;
    if (isStrongRef(text)) return text.trim();
  }
  if (dateCell != null && dateCell.trim().isNotEmpty) {
    final spill = stripLeadingStatementDate(dateCell);
    if (spill != dateCell.trim()) {
      final extracted = extractAnyRef(spill);
      if (extracted != null) return extracted;
    }
  }
  return refCol.trim().isEmpty ? null : refCol.trim();
}

/// UPI/IMPS 12-digit refs and NEFT UTRs are stable across SMS vs statement.
bool isStrongRef(String ref) {
  final t = ref.trim();
  if (t.isEmpty) return false;
  if (RegExp(r'^\d{12}$').hasMatch(t)) return true;
  if (RegExp(r'^[A-Z0-9]{12,22}$', caseSensitive: false).hasMatch(t)) {
    return true;
  }
  return false;
}

String? extractCardLast4(String body) => _cardLast4.firstMatch(body)?.group(1);

String? extractAccountMask(String body) =>
    _accountMask.firstMatch(body)?.group(1);

String? extractVpa(String body) => _vpa.firstMatch(body)?.group(1);

List<String> extractAllVpas(String body) =>
    _vpa.allMatches(body).map((m) => m.group(1)!).toList(growable: false);

/// Collapse whitespace and strip common unicode oddities.
String normalizeSmsBody(String body) {
  var s = body.replaceAll('\u00a0', ' ');
  s = s.replaceAll(RegExp(r'[\u200b\u200c\u200d\ufeff]'), '');
  s = s.replaceAll(RegExp(r'[ \t\r\n]+'), ' ');
  return s.trim();
}

/// Alias used by statement parsers.
String normalizeText(String body) => normalizeSmsBody(body);

/// Parse Excel serial date (Windows 1900 date system) to UTC.
DateTime? excelSerialToDate(num serial) {
  if (serial <= 0) return null;
  final whole = serial.floor();
  final frac = serial - whole;
  final base = DateTime.utc(1899, 12, 30);
  final day = base.add(Duration(days: whole));
  if (frac == 0) {
    return DateTime.utc(day.year, day.month, day.day);
  }
  final millis = (frac * Duration.millisecondsPerDay).round();
  final withTime = day.add(Duration(milliseconds: millis));
  return DateTime.utc(
    withTime.year,
    withTime.month,
    withTime.day,
    withTime.hour,
    withTime.minute,
    withTime.second,
  );
}

/// Parse a statement cell that may be a date string or Excel serial.
DateTime? parseStatementDate(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final asNum = num.tryParse(t.replaceAll(',', ''));
  if (asNum != null && asNum > 20000 && asNum < 80000) {
    // Likely Excel serial (≈1954–2119).
    return excelSerialToDate(asNum);
  }
  return extractDateTime(t);
}

import '../../parsing/common/extractors.dart';

/// Facts printed around a statement's transaction table: which card/account
/// it is, and (for cards) the bill. Every field is optional — banks vary.
class StatementSummary {
  const StatementSummary({
    this.last4,
    this.statementDate,
    this.dueDate,
    this.totalDuePaise,
    this.minDuePaise,
    this.creditLimitPaise,
  });

  /// Last four digits of the card or account number.
  final String? last4;
  final DateTime? statementDate;
  final DateTime? dueDate;
  final int? totalDuePaise;
  final int? minDuePaise;
  final int? creditLimitPaise;

  bool get hasBill => totalDuePaise != null || dueDate != null;

  bool get isEmpty =>
      last4 == null &&
      statementDate == null &&
      dueDate == null &&
      totalDuePaise == null &&
      minDuePaise == null &&
      creditLimitPaise == null;
}

// Card / account number: masked forms ("XXXX XXXX XXXX 1234",
// "5241XXXXXXXX1234", "Card ending 4455") or a plain account number after a
// label ("Account No : 50100012345678").
final _maskedNumber = RegExp(
  r'(?:\d{4}|[x*•]{4})[\s-]?(?:[x*•\d]{4}[\s-]?){1,3}?[x*•]{2,}[\s-]?[x*•]*(\d{4})\b',
  caseSensitive: false,
);
final _endingIn = RegExp(
  r'\b(?:card|account|a/?c)\b[^0-9]{0,20}?ending\s*(?:in|with)?\s*[x*•]*(\d{4})\b',
  caseSensitive: false,
);
final _labelledNumber = RegExp(
  r'\b(?:card|account|a/?c)\s*(?:no\.?|number|num)\s*[:#,-]?\s*[x*•\s-]*(\d{6,18})\b',
  caseSensitive: false,
);
final _labelledMasked = RegExp(
  r'\b(?:card|account|a/?c)\s*(?:no\.?|number|num)\s*[:#,-]?\s*[x*•\d\s-]*?[x*•]+[\s-]*(\d{4})\b',
  caseSensitive: false,
);

String? _last4In(String line) {
  for (final re in [_endingIn, _labelledMasked, _maskedNumber]) {
    final m = re.firstMatch(line);
    if (m != null) return m.group(1);
  }
  final m = _labelledNumber.firstMatch(line);
  if (m != null) {
    final digits = m.group(1)!;
    return digits.substring(digits.length - 4);
  }
  return null;
}

final _dueDateLabel = RegExp(
  r'payment\s+due\s+date|due\s+date',
  caseSensitive: false,
);
final _stmtDateLabel = RegExp(
  r'statement\s+date|bill(?:ing)?\s+date',
  caseSensitive: false,
);
final _totalDueLabel = RegExp(
  r'total\s+(?:amount\s+)?(?:due|payable)|total\s+outstanding|amount\s+payable',
  caseSensitive: false,
);
final _minDueLabel = RegExp(
  r'min(?:imum)?\.?\s+(?:amount\s+)?due',
  caseSensitive: false,
);
final _limitLabel = RegExp(
  r'(?<!available\s)(?<!avl\.?\s)credit\s+limit|total\s+credit\s+limit',
  caseSensitive: false,
);

/// Scans [rows] (the whole grid, including text above and below the table)
/// for card/account number and bill facts. Values are read from the same row
/// as their label, else from the same column of the next row (summary boxes
/// laid out as a header row over a value row).
StatementSummary extractStatementSummary(List<List<String>> rows) {
  final last4s = <String>{};
  DateTime? stmtDate;
  DateTime? dueDate;
  int? total;
  int? minDue;
  int? limit;

  for (var r = 0; r < rows.length; r++) {
    final row = rows[r];
    final line = row.join(' ');
    if (line.trim().isEmpty) continue;
    final l4 = _last4In(line);
    if (l4 != null) last4s.add(l4);

    for (var c = 0; c < row.length; c++) {
      final cell = row[c];
      if (cell.trim().isEmpty) continue;
      // Text in this cell after the label, then the following cells, then the
      // same column one row down.
      Iterable<String> after(RegExpMatch m) sync* {
        yield cell.substring(m.end);
        for (var k = c + 1; k < row.length; k++) {
          yield row[k];
        }
        if (r + 1 < rows.length && c < rows[r + 1].length) {
          yield rows[r + 1][c];
        }
      }

      DateTime? dateAfter(RegExp label) {
        final m = label.firstMatch(cell);
        if (m == null) return null;
        for (final s in after(m)) {
          final d = extractDateTime(s);
          if (d != null) return DateTime(d.year, d.month, d.day);
        }
        return null;
      }

      int? amountAfter(RegExp label) {
        final m = label.firstMatch(cell);
        if (m == null) return null;
        for (final s in after(m)) {
          final t = s.replaceAll(RegExp(r'^[\s:=-]+'), '').trim();
          if (t.isEmpty || extractDateTime(t) != null) continue;
          if (!RegExp(r'\d').hasMatch(t)) continue;
          final a = parseAmountCell(t).amount;
          if (a != null) return a.paise;
        }
        return null;
      }

      // Minimum due first so "Minimum Amount Due" isn't read as total.
      if (minDue == null && _minDueLabel.hasMatch(cell)) {
        minDue = amountAfter(_minDueLabel);
        continue;
      }
      dueDate ??= dateAfter(_dueDateLabel);
      stmtDate ??= dateAfter(_stmtDateLabel);
      if (total == null && !_minDueLabel.hasMatch(cell)) {
        total = amountAfter(_totalDueLabel);
      }
      limit ??= amountAfter(_limitLabel);
    }
  }

  return StatementSummary(
    // Several different numbers (e.g. add-on cards) → don't guess.
    last4: last4s.length == 1 ? last4s.single : null,
    statementDate: stmtDate,
    dueDate: dueDate,
    totalDuePaise: total,
    minDuePaise: minDue,
    creditLimitPaise: limit,
  );
}

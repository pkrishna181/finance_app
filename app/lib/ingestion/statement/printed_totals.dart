import 'dart:convert';

import '../../parsing/common/extractors.dart';
import 'pdf/layout_to_grid.dart';
import 'pdf/positioned_text.dart';

/// Totals a statement prints about itself — what the parsed rows are checked
/// against. Every field is optional; banks print different subsets.
class PrintedTotals {
  const PrintedTotals({
    this.periodStart,
    this.periodEnd,
    this.openingPaise,
    this.closingPaise,
    this.debitsPaise,
    this.creditsPaise,
    this.feesPaise,
    this.debitCount,
    this.creditCount,
    this.totalDuePaise,
    this.minDuePaise,
    this.dueDate,
    this.statementDate,
    this.creditLimitPaise,
    this.availableLimitPaise,
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;

  /// Account: opening balance / brought forward. Card: previous balance.
  final int? openingPaise;

  /// Account: closing balance. Card: total outstanding.
  final int? closingPaise;

  /// Account: total debits. Card: purchases & other debits.
  final int? debitsPaise;

  /// Account: total credits. Card: payments, reversals & other credits.
  final int? creditsPaise;

  /// Card: fees, taxes & interest charges.
  final int? feesPaise;
  final int? debitCount;
  final int? creditCount;
  final int? totalDuePaise;
  final int? minDuePaise;
  final DateTime? dueDate;
  final DateTime? statementDate;
  final int? creditLimitPaise;
  final int? availableLimitPaise;

  bool get isEmpty => toJson().isEmpty;

  Map<String, Object> toJson() => {
    if (periodStart != null) 'period_start': _day(periodStart!),
    if (periodEnd != null) 'period_end': _day(periodEnd!),
    'opening': ?openingPaise,
    'closing': ?closingPaise,
    'debits': ?debitsPaise,
    'credits': ?creditsPaise,
    'fees': ?feesPaise,
    'debit_count': ?debitCount,
    'credit_count': ?creditCount,
    'total_due': ?totalDuePaise,
    'min_due': ?minDuePaise,
    if (dueDate != null) 'due_date': _day(dueDate!),
    if (statementDate != null) 'statement_date': _day(statementDate!),
    'credit_limit': ?creditLimitPaise,
    'available_limit': ?availableLimitPaise,
  };

  String encode() => jsonEncode(toJson());

  static PrintedTotals decode(String? json) {
    if (json == null || json.isEmpty) return const PrintedTotals();
    final m = jsonDecode(json) as Map<String, dynamic>;
    DateTime? d(String k) =>
        m[k] == null ? null : DateTime.parse(m[k] as String);
    int? i(String k) => m[k] as int?;
    return PrintedTotals(
      periodStart: d('period_start'),
      periodEnd: d('period_end'),
      openingPaise: i('opening'),
      closingPaise: i('closing'),
      debitsPaise: i('debits'),
      creditsPaise: i('credits'),
      feesPaise: i('fees'),
      debitCount: i('debit_count'),
      creditCount: i('credit_count'),
      totalDuePaise: i('total_due'),
      minDuePaise: i('min_due'),
      dueDate: d('due_date'),
      statementDate: d('statement_date'),
      creditLimitPaise: i('credit_limit'),
      availableLimitPaise: i('available_limit'),
    );
  }

  static String _day(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);
}

enum _Field {
  opening,
  closing,
  closingFallback,
  debits,
  credits,
  fees,
  debitCount,
  creditCount,
  totalDue,
  minDue,
  dueDate,
  statementDate,
  creditLimit,
  availableLimit,

  /// Recognised but not kept (cash limits), so its value isn't read as
  /// another field.
  ignored,
}

/// Label → field, most specific first ("available credit limit" before
/// "credit limit", "minimum amount due" before "total amount due").
final _labels = <(RegExp, _Field)>[
  (
    RegExp(
      r'available\s+credit\s+limit|available\s+limit',
      caseSensitive: false,
    ),
    _Field.availableLimit,
  ),
  (
    RegExp(r'available\s+cash\s+limit|cash\s+limit', caseSensitive: false),
    _Field.ignored,
  ),
  (
    RegExp(r'min(?:imum)?\.?\s+(?:amt\.?|amount)\s+due', caseSensitive: false),
    _Field.minDue,
  ),
  (
    RegExp(
      r'total\s+(?:amt\.?|amount)\s+due|total\s+dues?\b',
      caseSensitive: false,
    ),
    _Field.totalDue,
  ),
  (
    RegExp(
      r'payment\s+due\s+date|due\s+date|payable\s+by',
      caseSensitive: false,
    ),
    _Field.dueDate,
  ),
  (RegExp(r'statement\s+date', caseSensitive: false), _Field.statementDate),
  (RegExp(r'credit\s+limit', caseSensitive: false), _Field.creditLimit),
  (
    RegExp(
      r'brought\s+forward|opening\s+balance|previous\s+balance',
      caseSensitive: false,
    ),
    _Field.opening,
  ),
  (
    RegExp(r'closing\s+balance|total\s+outstanding', caseSensitive: false),
    _Field.closing,
  ),
  (RegExp(r'clear\s+balance', caseSensitive: false), _Field.closingFallback),
  (
    RegExp(
      r'fee,?\s+taxes|interest\s+charges|finance\s+charges|fees\s+(?:&|and)\s+charges',
      caseSensitive: false,
    ),
    _Field.fees,
  ),
  (
    RegExp(
      r'payments?,?\s+reversals?|total\s+credits?|total\s+deposits?',
      caseSensitive: false,
    ),
    _Field.credits,
  ),
  (
    RegExp(
      r'purchases?\s+&\s+other|total\s+debits?|total\s+withdrawals?',
      caseSensitive: false,
    ),
    _Field.debits,
  ),
  (
    RegExp(
      r'\bdr\.?\s+count|debit\s+count|no\.?\s+of\s+debits',
      caseSensitive: false,
    ),
    _Field.debitCount,
  ),
  (
    RegExp(
      r'\bcr\.?\s+count|credit\s+count|no\.?\s+of\s+credits',
      caseSensitive: false,
    ),
    _Field.creditCount,
  ),
];

final _money = RegExp(
  r'^-?(?:\d{1,3}(?:,\d{2,3})+|\d+)(?:\.\d{1,2})?(?:cr|dr)?$',
  caseSensitive: false,
);
final _count = RegExp(r'^\d{1,5}$');
final _period = RegExp(
  r'(?:statement\s+(?:period|from|summary)|period)\s*:?\s*'
  r'(\d{1,2}[-/ ][A-Za-z0-9]{2,3}[-/ ]\d{2,4})\s+to\s+'
  r'(\d{1,2}[-/ ][A-Za-z0-9]{2,3}[-/ ]\d{2,4})',
  caseSensitive: false,
);

class _Value {
  _Value(this.line, this.words, {this.date, this.paise, this.count});

  final PdfTextLine line;
  final List<PositionedWord> words;
  final DateTime? date;
  final int? paise;
  final int? count;

  double get left => words.first.x;
  double get right => words.last.x + words.last.width;
}

/// Reads [PrintedTotals] from a PDF's positioned lines. A value's label is
/// the text before it on its line, else the text stacked directly above it
/// (summary boxes: labels over values, sometimes over several lines).
PrintedTotals extractPrintedTotals(List<PdfTextLine> lines) {
  final found = <_Field, Object>{};
  DateTime? periodStart, periodEnd;

  for (var li = 0; li < lines.length; li++) {
    final line = lines[li];
    final p = _period.firstMatch(line.text);
    if (p != null && periodStart == null) {
      periodStart = _date(p.group(1)!);
      periodEnd = _date(p.group(2)!);
    }
    final values = _values(line);
    for (var vi = 0; vi < values.length; vi++) {
      final v = values[vi];
      final before = [
        for (final w in line.words)
          if (w.x + w.width <= v.left &&
              (vi == 0 || w.x >= values[vi - 1].right))
            w.text,
      ].join(' ');
      final field = _match(before) ?? _match(_labelAbove(lines, li, v));
      if (field == null || found.containsKey(field)) continue;
      final value = _valueFor(field, v);
      if (value != null) found[field] = value;
    }
  }

  int? paise(_Field f) => found[f] as int?;
  return PrintedTotals(
    periodStart: periodStart,
    periodEnd: periodEnd,
    openingPaise: paise(_Field.opening),
    closingPaise: paise(_Field.closing) ?? paise(_Field.closingFallback),
    debitsPaise: paise(_Field.debits),
    creditsPaise: paise(_Field.credits),
    feesPaise: paise(_Field.fees),
    debitCount: paise(_Field.debitCount),
    creditCount: paise(_Field.creditCount),
    totalDuePaise: paise(_Field.totalDue),
    minDuePaise: paise(_Field.minDue),
    dueDate: found[_Field.dueDate] as DateTime?,
    statementDate: found[_Field.statementDate] as DateTime?,
    creditLimitPaise: paise(_Field.creditLimit),
    availableLimitPaise: paise(_Field.availableLimit),
  );
}

_Field? _match(String label) {
  if (label.trim().isEmpty) return null;
  for (final (re, field) in _labels) {
    if (re.hasMatch(label)) return field;
  }
  return null;
}

Object? _valueFor(_Field f, _Value v) => switch (f) {
  _Field.dueDate || _Field.statementDate => v.date,
  _Field.debitCount || _Field.creditCount => v.count,
  _ => v.paise,
};

/// Text in the lines just above [v] that sits over it horizontally, read top
/// down; stops at another row of values or a wide gap.
String _labelAbove(List<PdfTextLine> lines, int li, _Value v) {
  final parts = <String>[];
  var lastY = v.line.y;
  for (var k = li - 1; k >= 0 && k >= li - 5; k--) {
    final above = lines[k];
    if (above.pageIndex != v.line.pageIndex || lastY - above.y > 34) break;
    final ws = above.words;
    final hit = [
      for (var i = 0; i < ws.length; i++)
        if (ws[i].x <= v.right + 14 && ws[i].x + ws[i].width >= v.left - 14) i,
    ];
    if (hit.isEmpty) continue;
    // The rest of the phrase: neighbours a word space away (about 3pt;
    // columns are further apart).
    var a = hit.first, b = hit.last;
    while (a > 0 && ws[a].x - (ws[a - 1].x + ws[a - 1].width) < 5) {
      a--;
    }
    while (b < ws.length - 1 && ws[b + 1].x - (ws[b].x + ws[b].width) < 5) {
      b++;
    }
    final over = ws.sublist(a, b + 1);
    // Another value directly above: a different row of figures.
    if (over.any((w) => _money.hasMatch(w.text) && w.text.contains('.'))) break;
    parts.insert(0, over.map((w) => w.text).join(' '));
    lastY = above.y;
  }
  return parts.join(' ');
}

/// Money amounts, small whole numbers (counts) and dates on a line.
List<_Value> _values(PdfTextLine line) {
  final out = <_Value>[];
  final w = line.words;
  for (var i = 0; i < w.length; i++) {
    // "19 Oct 2026" / "08-11-2026"
    for (final n in const [3, 1]) {
      if (i + n > w.length) continue;
      final text = w.sublist(i, i + n).map((e) => e.text).join(' ');
      final isDate = n == 3
          ? RegExp(r'^\d{1,2} [A-Za-z]{3} \d{2,4}$').hasMatch(text)
          : RegExp(r'^\d{1,2}[-/]\d{1,2}[-/]\d{2,4}$').hasMatch(text);
      if (!isDate) continue;
      final d = extractDateTime(text);
      if (d != null) {
        out.add(
          _Value(
            line,
            w.sublist(i, i + n),
            date: DateTime(d.year, d.month, d.day),
          ),
        );
        i += n - 1;
        break;
      }
    }
    if (out.isNotEmpty && out.last.words.contains(w[i])) continue;
    final t = w[i].text;
    if (_money.hasMatch(t) && (t.contains('.') || t.contains(','))) {
      final cell = parseAmountCell(t);
      if (cell.amount != null) {
        final signed = cell.suffixDirection?.name == 'debit'
            ? -cell.amount!.paise
            : cell.amount!.paise;
        out.add(_Value(line, [w[i]], paise: signed));
      }
    } else if (_count.hasMatch(t)) {
      out.add(
        _Value(line, [w[i]], count: int.parse(t), paise: int.parse(t) * 100),
      );
    }
  }
  return out;
}

DateTime? _date(String s) {
  final d = extractDateTime(s);
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

import '../../core/models/models.dart';
import '../../parsing/common/extractors.dart';
import '../../parsing/sms/template.dart' show buildDedupeKey;
import 'header_mapper.dart';
import 'pdf/layout_to_grid.dart';
import 'pdf/positioned_text.dart';
import 'row_parser.dart';

/// Transactions read line by line from word positions — for PDF layouts the
/// header-based grid can't map: headers drawn as graphics (SBI accounts),
/// centred headers over wide columns (SBI Card), descriptions wrapped above
/// and below the date line.
///
/// A transaction line starts with a date and has an amount in one of the
/// amount columns, which are found from where amounts line up across rows,
/// not from the header. Direction comes from a running balance when there is
/// one, else a C/D/M or Cr/Dr marker, else the column.
class LineStatementResult {
  const LineStatementResult({
    required this.transactions,
    required this.unparsed,
    required this.isCard,
    required this.bankCode,
    required this.amountColumns,
    required this.hasBalance,
    required this.balanceBreaks,
    this.instalmentsPaise = 0,
    this.instalmentCount = 0,
  });

  final List<ParsedTransaction> transactions;

  /// Card EMI instalments ("M" rows). Not transactions: the purchase they
  /// repay was already spent.
  final int instalmentsPaise;
  final int instalmentCount;

  /// Lines that start with a date and carry money but couldn't be read.
  final List<String> unparsed;
  final bool isCard;
  final String bankCode;
  final int amountColumns;
  final bool hasBalance;

  /// Rows where previous balance ± amount ≠ printed balance.
  final int balanceBreaks;

  /// Profile ids for results read line by line.
  static const cardProfileId = 'line_card';
  static const accountProfileId = 'line_account';

  StatementParseResult toParseResult() => StatementParseResult(
    transactions: transactions,
    unparsed: [
      for (final (i, line) in unparsed.indexed)
        UnparsedStatementRow(
          rowIndex: i,
          rawCells: [line],
          reason: 'line_unreadable',
        ),
    ],
    columnMap: ColumnMap(
      headerRowIndex: 0,
      bindings: const [],
      bankCode: bankCode,
      profileId: isCard ? cardProfileId : accountProfileId,
      overallConfidence: 1,
    ),
    skippedFooterRows: 0,
  );

  static const empty = LineStatementResult(
    transactions: [],
    unparsed: [],
    isCard: false,
    bankCode: 'UNKNOWN',
    amountColumns: 0,
    hasBalance: false,
    balanceBreaks: 0,
  );
}

final _money = RegExp(
  r'^-?(?:\d{1,3}(?:,\d{2,3})+|\d+)\.\d{2}(?:cr|dr)?$',
  caseSensitive: false,
);
final _numericDate = RegExp(r'^\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}$');
final _compactDate = RegExp(
  r'^\d{1,2}[-]?[A-Za-z]{3}[-,]?\d{2,4}$',
  caseSensitive: false,
);
final _spacedDate = RegExp(
  r'^\d{1,2} [A-Za-z]{3},? \d{2,4}$',
  caseSensitive: false,
);
const _creditMarkers = {'C', 'CR', 'T'};
const _debitMarkers = {'D', 'DR', 'M'};

class _Row {
  _Row(this.line, this.date, this.dateWords);

  final PdfTextLine line;
  DateTime? date;
  final int dateWords;

  /// Column index → amount (paise, unsigned) and its Cr/Dr suffix.
  final values = <int, ({int paise, TransactionDirection? suffix})>{};
  String? marker;
  final narration = <(double, String)>[];

  /// Left edge of the description on this row's lines.
  double? textLeft;

  double get y => line.y;
}

class LineStatementParser {
  const LineStatementParser();

  LineStatementResult parse(List<PdfTextLine> lines) {
    if (lines.isEmpty) return LineStatementResult.empty;
    final blob = lines.take(60).map((l) => l.text).join(' ');
    final bank = guessStatementBank(blob);
    final isCard = looksLikeCardStatement(blob);

    // 1. Lines that start with a date and carry an amount after it.
    final dated = <_Row>[];
    for (final l in lines) {
      final d = _leadingDate(l.words);
      if (d == null) continue;
      final hasMoney = l.words
          .skip(d.words)
          .any((w) => _money.hasMatch(w.text));
      if (hasMoney) dated.add(_Row(l, d.date, d.words));
    }
    if (dated.length < 2) return LineStatementResult.empty;

    // 2. Amount columns, page by page (layouts shift between pages): right
    // edges of the amounts that end each line, ranked from the right so the
    // balance column has the same index on every page.
    final pageColumns = <int, List<(double, double)>>{};
    final datedByPage = <int, List<_Row>>{};
    for (final r in dated) {
      datedByPage.putIfAbsent(r.line.pageIndex, () => []).add(r);
    }
    for (final e in datedByPage.entries) {
      final cols = _amountColumns([
        for (final r in e.value) ..._trailingMoney(r.line.words),
      ]);
      if (cols.isNotEmpty) pageColumns[e.key] = cols;
    }
    if (pageColumns.isEmpty) return LineStatementResult.empty;
    final columnCount = pageColumns.values
        .map((c) => c.length)
        .reduce((a, b) => a > b ? a : b);
    int? columnOf(PdfTextLine l, PositionedWord w) {
      final cols = pageColumns[l.pageIndex];
      if (cols == null) return null;
      final centre = w.centerX;
      for (var i = 0; i < cols.length; i++) {
        if (centre >= cols[i].$1 - 2 && centre <= cols[i].$2 + 2) {
          return columnCount - cols.length + i;
        }
      }
      return null;
    }

    double descriptionEnd(int page) =>
        (pageColumns[page]?.first.$1 ?? double.infinity) - 4;

    // 3. Undated rows inside the table (fees, taxes) count too.
    final rows = <_Row>[...dated];
    final datedLines = {for (final r in dated) r.line};
    for (final l in lines) {
      if (datedLines.contains(l)) continue;
      final page = datedByPage[l.pageIndex];
      if (page == null) continue;
      if (l.y < page.first.y || l.y > page.last.y) continue;
      final inColumn = _trailingMoney(
        l.words,
      ).where((w) => columnOf(l, w) != null);
      final hasMarker =
          l.words.isNotEmpty &&
          {
            ..._creditMarkers,
            ..._debitMarkers,
          }.contains(l.words.last.text.toUpperCase());
      if (inColumn.length == 1 && (hasMarker || columnCount == 1)) {
        rows.add(_Row(l, null, 0));
      }
    }
    rows.sort((a, b) {
      final p = a.line.pageIndex.compareTo(b.line.pageIndex);
      return p != 0 ? p : a.y.compareTo(b.y);
    });

    // 4. Amounts, markers and the description on each row's own line.
    final unparsed = <String>[];
    for (final r in rows) {
      final words = r.line.words;
      final trailing = _trailingMoney(words).toSet();
      var i = r.dateWords;
      // A second date (value date / post date) right after the first.
      final second = _leadingDate(words.sublist(i));
      if (second != null) i += second.words;
      for (; i < words.length; i++) {
        final w = words[i];
        final col = trailing.contains(w) ? columnOf(r.line, w) : null;
        if (col != null) {
          final cell = parseAmountCell(w.text);
          if (cell.amount != null) {
            r.values[col] = (
              paise: cell.amount!.paise.abs(),
              suffix: cell.suffixDirection,
            );
          }
          continue;
        }
        final upper = w.text.toUpperCase();
        if (r.values.isNotEmpty &&
            (_creditMarkers.contains(upper) || _debitMarkers.contains(upper))) {
          r.marker = upper;
          continue;
        }
        if (w.text == '-' || r.values.isNotEmpty) continue;
        r.textLeft ??= w.x;
        r.narration.add((r.y, w.text));
      }
    }

    // A date line with no amount whose amount sits on the line just below
    // (description wrapped around the amount): one row.
    final merged = <PdfTextLine>{};
    for (var i = rows.length - 2; i >= 0; i--) {
      final r = rows[i], next = rows[i + 1];
      if (r.date == null || r.values.isNotEmpty) continue;
      if (next.date != null || next.values.isEmpty) continue;
      if (next.line.pageIndex != r.line.pageIndex || next.y - r.y > 12) {
        continue;
      }
      next
        ..date = r.date
        ..textLeft = r.textLeft ?? next.textLeft
        ..narration.insertAll(0, r.narration);
      merged.add(r.line);
      rows.removeAt(i);
    }

    // 5. Wrapped description lines go to the nearest row, if close enough.
    _attachWrappedLines(lines, rows, merged, descriptionEnd);

    // 6. Which column is the balance, and which way the others go.
    final balanceCol = _balanceColumn(rows, columnCount);
    final roles = _columnRoles(rows, columnCount, balanceCol, lines);

    final txns = <ParsedTransaction>[];
    var breaks = 0, instalments = 0, instalmentCount = 0;
    int? prevBalance;
    DateTime? lastDate;
    for (final r in rows) {
      r.date ??= lastDate;
      final date = r.date;
      if (date == null) continue;
      lastDate = date;

      final balance = balanceCol == null ? null : _signed(r.values[balanceCol]);
      final amounts = {
        for (final e in r.values.entries)
          if (e.key != balanceCol) e.key: e.value,
      };
      if (amounts.isEmpty) {
        if (balance != null) prevBalance = balance;
        // A dated line with only a balance is an opening/closing line.
        if (balance == null) unparsed.add(r.line.text);
        continue;
      }
      final entry = amounts.entries.first;
      final paise = entry.value.paise;
      if (paise == 0) continue;

      TransactionDirection? dir;
      var inferred = false;
      if (balance != null && prevBalance != null) {
        final delta = balance - prevBalance;
        if (delta == -paise) dir = TransactionDirection.debit;
        if (delta == paise) dir = TransactionDirection.credit;
        if (dir == null) breaks++;
      }
      dir ??= switch (r.marker) {
        final m? when _creditMarkers.contains(m) => TransactionDirection.credit,
        final m? when _debitMarkers.contains(m) => TransactionDirection.debit,
        _ => null,
      };
      dir ??= entry.value.suffix;
      dir ??= roles[entry.key];
      if (dir == null) {
        final narr = r.narration.map((e) => e.$2).join(' ');
        dir = extractDirection(narr);
      }
      if (dir == null) {
        dir = TransactionDirection.debit;
        inferred = true;
      }
      if (balance != null) prevBalance = balance;
      if (r.marker == 'M') {
        instalments += paise;
        instalmentCount++;
        continue;
      }

      final narration = cleanStatementNarration(
        r.narration.map((e) => e.$2).join(' '),
      );
      txns.add(
        _txn(
          bank: bank,
          date: date,
          paise: paise,
          direction: dir,
          inferred: inferred,
          narration: narration,
          balance: balance,
          isCard: isCard,
        ),
      );
    }

    return LineStatementResult(
      transactions: txns,
      unparsed: unparsed,
      isCard: isCard,
      bankCode: bank,
      amountColumns: columnCount,
      hasBalance: balanceCol != null,
      balanceBreaks: breaks,
      instalmentsPaise: instalments,
      instalmentCount: instalmentCount,
    );
  }

  static ({DateTime date, int words})? _leadingDate(
    List<PositionedWord> words,
  ) {
    if (words.isEmpty) return null;
    for (final n in const [3, 1]) {
      if (words.length < n) continue;
      final text = words.take(n).map((w) => w.text).join(' ');
      final ok = n == 3
          ? _spacedDate.hasMatch(text)
          : _numericDate.hasMatch(text) || _compactDate.hasMatch(text);
      if (!ok) continue;
      final d = extractDateTime(text);
      if (d != null) return (date: d, words: n);
    }
    return null;
  }

  /// The amounts (and "-" placeholders) that end a line, after any C/D/M
  /// marker — the amount columns. Amounts inside a description ("5.96 USD")
  /// are followed by other words, so they never count.
  static List<PositionedWord> _trailingMoney(List<PositionedWord> words) {
    final out = <PositionedWord>[];
    var i = words.length - 1;
    if (i >= 0 &&
        {
          ..._creditMarkers,
          ..._debitMarkers,
        }.contains(words[i].text.toUpperCase())) {
      i--;
    }
    for (; i >= 0; i--) {
      final t = words[i].text;
      if (t == '-') continue;
      if (!_money.hasMatch(t)) break;
      out.add(words[i]);
    }
    return out.reversed.toList();
  }

  /// Column spans, left to right: amounts whose horizontal extents overlap
  /// share a column, whether the bank right-aligns or centres them.
  static List<(double, double)> _amountColumns(List<PositionedWord> words) {
    final spans = [for (final w in words) (w.x, w.x + w.width)]
      ..sort((a, b) => a.$1.compareTo(b.$1));
    final out = <(double, double)>[];
    for (final s in spans) {
      if (out.isNotEmpty && s.$1 <= out.last.$2 + 1) {
        final last = out.removeLast();
        out.add((last.$1, s.$2 > last.$2 ? s.$2 : last.$2));
      } else {
        out.add(s);
      }
    }
    return out;
  }

  static int? _signed(({int paise, TransactionDirection? suffix})? v) {
    if (v == null) return null;
    return v.suffix == TransactionDirection.debit ? -v.paise : v.paise;
  }

  /// The rightmost column, if nearly every row has it and consecutive values
  /// differ by the row's other amount.
  static int? _balanceColumn(List<_Row> rows, int columnCount) {
    if (columnCount < 2) return null;
    final col = columnCount - 1;
    final withBal = rows.where((r) => r.values.containsKey(col)).toList();
    if (withBal.length < rows.length * 0.8) return null;
    var checked = 0, matched = 0;
    for (var i = 1; i < withBal.length; i++) {
      final amount = withBal[i].values.entries
          .where((e) => e.key != col)
          .map((e) => e.value.paise)
          .firstOrNull;
      if (amount == null) continue;
      final delta =
          _signed(withBal[i].values[col])! -
          _signed(withBal[i - 1].values[col])!;
      checked++;
      if (delta.abs() == amount) matched++;
    }
    return checked >= 2 && matched >= checked * 0.7 ? col : null;
  }

  /// Debit/credit for each non-balance column: voted from balance changes
  /// when there is a balance, else from header words above the first row,
  /// else left = debit, right = credit when there are exactly two.
  static Map<int, TransactionDirection> _columnRoles(
    List<_Row> rows,
    int columnCount,
    int? balanceCol,
    List<PdfTextLine> lines,
  ) {
    final amountCols = [
      for (var i = 0; i < columnCount; i++)
        if (i != balanceCol) i,
    ];
    if (amountCols.length < 2) return const {};
    final roles = <int, TransactionDirection>{};
    if (balanceCol != null) {
      final votes = <int, int>{};
      for (var i = 1; i < rows.length; i++) {
        final a = rows[i - 1].values[balanceCol];
        final b = rows[i].values[balanceCol];
        if (a == null || b == null) continue;
        final delta = _signed(b)! - _signed(a)!;
        for (final c in amountCols) {
          final v = rows[i].values[c];
          if (v == null) continue;
          if (delta == -v.paise) votes[c] = (votes[c] ?? 0) - 1;
          if (delta == v.paise) votes[c] = (votes[c] ?? 0) + 1;
        }
      }
      for (final e in votes.entries) {
        if (e.value != 0) {
          roles[e.key] = e.value < 0
              ? TransactionDirection.debit
              : TransactionDirection.credit;
        }
      }
      if (roles.isNotEmpty) return roles;
    }
    if (amountCols.length == 2) {
      roles[amountCols[0]] = TransactionDirection.debit;
      roles[amountCols[1]] = TransactionDirection.credit;
    }
    return roles;
  }

  /// Lines with no date and no column amount, between rows, belong to the
  /// nearest row — when it's closer than most of the gap between rows.
  static void _attachWrappedLines(
    List<PdfTextLine> lines,
    List<_Row> rows,
    Set<PdfTextLine> merged,
    double Function(int page) descriptionEnd,
  ) {
    final rowLines = {for (final r in rows) r.line, ...merged};
    final byPage = <int, List<_Row>>{};
    for (final r in rows) {
      byPage.putIfAbsent(r.line.pageIndex, () => []).add(r);
    }
    final gaps = <double>[];
    for (final page in byPage.values) {
      for (var i = 1; i < page.length; i++) {
        gaps.add(page[i].y - page[i - 1].y);
      }
    }
    if (gaps.isEmpty) return;
    gaps.sort();
    final reach = gaps[gaps.length ~/ 2] * 0.75;

    for (final l in lines) {
      if (rowLines.contains(l)) continue;
      final page = byPage[l.pageIndex];
      if (page == null) continue;
      final words = [
        for (final w in l.words)
          if (w.x + w.width < descriptionEnd(l.pageIndex) && w.text != '-') w,
      ];
      if (words.isEmpty || words.length < l.words.length - 1) continue;
      // Descriptions run on below their date line more than above it.
      _Row? nearest;
      var best = double.infinity;
      for (final r in page) {
        final d = l.y >= r.y ? l.y - r.y : (r.y - l.y) * 2;
        if (d < best) {
          best = d;
          nearest = r;
        }
      }
      if (nearest == null || best > reach) continue;
      // Only text in the description column, not the date column.
      final left = nearest.textLeft;
      final kept = [
        for (final w in words)
          if (left == null || w.x >= left - 8) w.text,
      ];
      if (kept.isNotEmpty) nearest.narration.add((l.y, kept.join(' ')));
    }
    for (final r in rows) {
      r.narration.sort((a, b) => a.$1.compareTo(b.$1));
    }
  }

  static ParsedTransaction _txn({
    required String bank,
    required DateTime date,
    required int paise,
    required TransactionDirection direction,
    required bool inferred,
    required String narration,
    required int? balance,
    required bool isCard,
  }) {
    final guessed = inferStatementTxnType(narration);
    final type = isCard && guessed == TransactionType.other
        ? TransactionType.card
        : guessed;
    final ref = resolveStatementRef(refCol: '', narration: narration);
    final vpa = extractVpa(narration);
    return ParsedTransaction(
      amountPaise: MoneyPaise(paise),
      direction: direction,
      type: type,
      bookedAt: date,
      bankCode: bank,
      rawMerchant: merchantFromNarration(narration, vpa),
      rawDescription: narration,
      upiPayeeVpa: vpa,
      upiRef: type == TransactionType.upi ? ref : null,
      remarks: narration,
      externalRef: ref,
      balanceAfterPaise: balance == null ? null : MoneyPaise(balance),
      dedupeKey: buildDedupeKey(
        bankCode: bank,
        bookedAt: date,
        amountPaise: paise,
        ref: ref,
        normalizedBody: narration,
      ),
      directionInferred: inferred,
    );
  }
}

/// Joins wrapped description lines and drops boilerplate: SBI's
/// "WDL TFR"/"DEP TFR" prefix and `<txn no> AT <branch code> <branch>` suffix.
String cleanStatementNarration(String raw) {
  var s = normalizeText(raw);
  // A path split across lines: "KUMAR/ HDFC" → "KUMAR/HDFC".
  s = s.replaceAll(RegExp(r'/ (?=\S)'), '/');
  s = s.replaceFirst(RegExp(r'^(?:WDL|DEP) TFR\s+', caseSensitive: false), '');
  s = s.replaceFirst(RegExp(r'\s+\d{10,16} AT \d{3,6}\b.*$'), '');
  return s.trim();
}

/// Bank named in a statement's text.
String guessStatementBank(String text) {
  final u = text.toUpperCase();
  if (RegExp(r'\bHDFC\b').hasMatch(u)) return 'HDFC';
  if (RegExp(r'\bICICI\b').hasMatch(u)) return 'ICICI';
  if (RegExp(r'\bAXIS\b').hasMatch(u)) return 'AXIS';
  if (RegExp(r'\bKOTAK\b').hasMatch(u)) return 'KOTAK';
  if (RegExp(r'\bIDFC\b').hasMatch(u)) return 'IDFC';
  if (RegExp(r'\bINDUSIND\b').hasMatch(u)) return 'INDUSIND';
  if (RegExp(r'\bSBI\b|\bSTATE BANK\b|\bSBIN0').hasMatch(u)) return 'SBI';
  return 'UNKNOWN';
}

/// Card bills print a due date and minimum due; account statements don't.
bool looksLikeCardStatement(String text) {
  final t = text.toLowerCase();
  return t.contains('credit card') &&
      (t.contains('minimum amount due') ||
          t.contains('total amount due') ||
          t.contains('payment due date'));
}

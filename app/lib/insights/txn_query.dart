/// Transaction search query, parsed from a single line of text.
///
/// Syntax (space-separated, case-insensitive; quote phrases with "..."):
///
/// | Token | Meaning |
/// |---|---|
/// | `swiggy`, `"amazon pay"` | merchant / description contains |
/// | `cat:groceries`, `cat:"food delivery"` | category slug or name prefix |
/// | `cat:none` | uncategorized |
/// | `>500`, `<2000`, `>=500`, `=499` | amount in rupees |
/// | `from:2026-04-01`, `to:2026-06-30` | booked date range (inclusive) |
/// | `in:2026-05` | one calendar month |
/// | `debit`, `credit` | direction |
/// | `bank:hdfc` | bank code |
/// | `type:atm` | transaction type (upi, atm, card, neft, …) |
///
/// Unrecognized `key:value` tokens are treated as text.
class TxnQuery {
  const TxnQuery({
    this.terms = const [],
    this.category,
    this.minPaise,
    this.maxPaise,
    this.from,
    this.toExclusive,
    this.isDebit,
    this.bank,
    this.type,
  });

  /// Lowercased text terms; every one must match.
  final List<String> terms;

  /// Lowercased category filter ([kNoCategory] = uncategorized).
  final String? category;
  final int? minPaise;
  final int? maxPaise;
  final DateTime? from;
  final DateTime? toExclusive;
  final bool? isDebit;
  final String? bank;
  final String? type;

  static const kNoCategory = 'none';

  bool get isEmpty =>
      terms.isEmpty &&
      category == null &&
      minPaise == null &&
      maxPaise == null &&
      from == null &&
      toExclusive == null &&
      isDebit == null &&
      bank == null &&
      type == null;

  static final _amount = RegExp(r'^(>=|<=|>|<|=)₹?(\d+(?:\.\d{1,2})?)$');
  static final _date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static final _month = RegExp(r'^(\d{4})-(\d{2})$');

  static TxnQuery parse(String input) {
    final terms = <String>[];
    String? category;
    int? minP;
    int? maxP;
    DateTime? from;
    DateTime? to;
    bool? debit;
    String? bank;
    String? type;

    for (final raw in _tokenize(input)) {
      final tok = raw.toLowerCase();
      final a = _amount.firstMatch(tok);
      if (a != null) {
        final p = (double.parse(a[2]!) * 100).round();
        switch (a[1]) {
          case '>':
            minP = p + 1;
          case '>=':
            minP = p;
          case '<':
            maxP = p - 1;
          case '<=':
            maxP = p;
          case '=':
            minP = p;
            maxP = p;
        }
        continue;
      }
      if (tok == 'debit' || tok == 'credit') {
        debit = tok == 'debit';
        continue;
      }
      final colon = tok.indexOf(':');
      if (colon > 0 && colon < tok.length - 1) {
        final key = tok.substring(0, colon);
        final value = tok.substring(colon + 1);
        switch (key) {
          case 'cat':
            category = value;
            continue;
          case 'bank':
            bank = value;
            continue;
          case 'type':
            type = value;
            continue;
          case 'from':
            final d = _parseDate(value);
            if (d != null) {
              from = d;
              continue;
            }
          case 'to':
            final d = _parseDate(value);
            if (d != null) {
              to = d.add(const Duration(days: 1));
              continue;
            }
          case 'in':
            final m = _month.firstMatch(value);
            if (m != null) {
              final y = int.parse(m[1]!);
              final mo = int.parse(m[2]!);
              if (mo >= 1 && mo <= 12) {
                from = DateTime(y, mo);
                to = DateTime(y, mo + 1);
                continue;
              }
            }
        }
      }
      terms.add(tok);
    }
    return TxnQuery(
      terms: terms,
      category: category,
      minPaise: minP,
      maxPaise: maxP,
      from: from,
      toExclusive: to,
      isDebit: debit,
      bank: bank,
      type: type,
    );
  }

  static DateTime? _parseDate(String s) {
    final m = _date.firstMatch(s);
    if (m == null) return null;
    final y = int.parse(m[1]!);
    final mo = int.parse(m[2]!);
    final d = int.parse(m[3]!);
    final dt = DateTime(y, mo, d);
    return dt.month == mo && dt.day == d ? dt : null;
  }

  /// Splits on whitespace, keeping "quoted phrases" (also after `key:`).
  static List<String> _tokenize(String s) {
    final out = <String>[];
    final buf = StringBuffer();
    var quoted = false;
    for (final ch in s.runes.map(String.fromCharCode)) {
      if (ch == '"') {
        quoted = !quoted;
      } else if (!quoted && ch.trim().isEmpty) {
        if (buf.isNotEmpty) out.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    return out;
  }
}

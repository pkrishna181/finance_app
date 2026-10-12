import 'dart:math' as math;

/// Numbers a sheet can read from the user's data (rupees). Precomputed so
/// evaluation stays synchronous and pure.
class SheetData {
  const SheetData({
    this.netWorth = 0,
    this.investments = 0,
    this.cash = 0,
    this.spendByMonth = const [],
    this.incomeByMonth = const [],
    this.categoryNames = const {},
  });

  final double netWorth;
  final double investments;
  final double cash;

  /// Index 0 = this month, 1 = last month …; category slug → rupees.
  final List<Map<String, double>> spendByMonth;
  final List<double> incomeByMonth;

  /// Lower-case name → slug, so `spend("food delivery")` works too.
  final Map<String, String> categoryNames;

  double spend(String? category, int monthsAgo) {
    if (monthsAgo < 0 || monthsAgo >= spendByMonth.length) return 0;
    final m = spendByMonth[monthsAgo];
    if (category == null || category == 'all') {
      return m.values.fold(0.0, (s, v) => s + v);
    }
    final key = category.toLowerCase();
    final slug = categoryNames[key] ?? key.replaceAll(' ', '_');
    return m[slug] ?? 0;
  }

  double income(int monthsAgo) =>
      monthsAgo < 0 || monthsAgo >= incomeByMonth.length
      ? 0
      : incomeByMonth[monthsAgo];
}

enum SheetLineKind { blank, heading, comment, value, error }

class SheetLine {
  const SheetLine(this.kind, {this.value, this.name, this.error});
  final SheetLineKind kind;
  final double? value;

  /// Variable assigned on this line.
  final String? name;
  final String? error;
}

class SheetError implements Exception {
  const SheetError(this.message);
  final String message;
}

/// Evaluates a sheet line by line (pure).
class SheetEvaluator {
  const SheetEvaluator();

  List<SheetLine> evaluate(String text, {SheetData data = const SheetData()}) {
    final vars = <String, double>{};
    final out = <SheetLine>[];
    final block = <double>[];
    for (final raw in text.split('\n')) {
      final line = _stripComment(raw).trim();
      if (line.isEmpty) {
        // Blank lines start a new block for sum / total; comments don't.
        if (raw.trim().startsWith('//')) {
          out.add(const SheetLine(SheetLineKind.comment));
        } else {
          block.clear();
          out.add(const SheetLine(SheetLineKind.blank));
        }
        continue;
      }
      if (line.startsWith('#')) {
        block.clear();
        out.add(const SheetLine(SheetLineKind.heading));
        continue;
      }
      try {
        String? name;
        var expr = line;
        final m = RegExp(
          r'^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=)\s*(.+)$',
        ).firstMatch(line);
        if (m != null) {
          name = m[1]!;
          if (_reserved.contains(name.toLowerCase())) {
            throw SheetError('"$name" is a built-in name');
          }
          expr = m[2]!;
        }
        final v = _Parser(expr, vars, data, List.of(block)).parse();
        if (name != null) vars[name] = v;
        block.add(v);
        out.add(SheetLine(SheetLineKind.value, value: v, name: name));
      } on SheetError catch (e) {
        out.add(SheetLine(SheetLineKind.error, error: e.message));
      }
    }
    return out;
  }

  static String _stripComment(String s) {
    final i = s.indexOf('//');
    return i < 0 ? s : s.substring(0, i);
  }

  static const _reserved = {
    'sum',
    'total',
    'networth',
    'investments',
    'cash',
    'pi',
    'e',
  };
}

/// "1,23,456.78" with Indian grouping; up to 2 decimals.
String formatSheetNumber(double v) {
  if (v.isNaN) return '—';
  if (v.isInfinite) return v > 0 ? '∞' : '−∞';
  final neg = v < 0;
  final a = v.abs();
  var s = a.toStringAsFixed(2);
  if (s.endsWith('.00')) {
    s = s.substring(0, s.length - 3);
  } else if (s.endsWith('0')) {
    s = s.substring(0, s.length - 1);
  }
  final parts = s.split('.');
  var w = parts[0];
  if (w.length > 3) {
    final last3 = w.substring(w.length - 3);
    var rest = w.substring(0, w.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    w = '${groups.join(',')},$last3';
  }
  return '${neg ? '−' : ''}$w${parts.length > 1 ? '.${parts[1]}' : ''}';
}

// --- recursive-descent parser ---------------------------------------------

class _Tok {
  const _Tok(this.type, this.text, [this.num]);
  final String type; // num, id, str, op, end
  final String text;
  final double? num;
}

class _Parser {
  _Parser(String src, this.vars, this.data, this.block) : toks = _lex(src);

  final List<_Tok> toks;
  final Map<String, double> vars;
  final SheetData data;
  final List<double> block;
  var i = 0;

  // Grouped numbers need proper groups (Indian 1,23,456 or western
  // 123,456; last group 3 digits), so "emi(4000000,9,20)" still splits.
  static final _number = RegExp(
    r'^(?:\d{1,3}(?:,\d{3})+(?!\d|,\d)|\d{1,2}(?:,\d{2})*,\d{3}(?!\d)|\d+)'
    r'(?:\.\d+)?|^\.\d+',
  );
  static final _ident = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*');

  static List<_Tok> _lex(String s) {
    final out = <_Tok>[];
    var p = 0;
    while (p < s.length) {
      final c = s[p];
      if (c.trim().isEmpty || c == '₹') {
        p++;
        continue;
      }
      final rest = s.substring(p);
      final n = _number.firstMatch(rest);
      if (n != null) {
        final text = n[0]!;
        out.add(_Tok('num', text, double.parse(text.replaceAll(',', ''))));
        p += text.length;
        continue;
      }
      final id = _ident.firstMatch(rest);
      if (id != null) {
        out.add(_Tok('id', id[0]!));
        p += id[0]!.length;
        continue;
      }
      if (c == '"' || c == "'") {
        final end = s.indexOf(c, p + 1);
        if (end < 0) throw const SheetError('missing closing quote');
        out.add(_Tok('str', s.substring(p + 1, end)));
        p = end + 1;
        continue;
      }
      if ('+-*/^()%,×÷−'.contains(c)) {
        out.add(
          _Tok('op', switch (c) {
            '×' => '*',
            '÷' => '/',
            '−' => '-',
            _ => c,
          }),
        );
        p++;
        continue;
      }
      throw SheetError('unexpected "$c"');
    }
    out.add(const _Tok('end', ''));
    return out;
  }

  _Tok get peek => toks[i];
  bool _op(String o) {
    if (peek.type == 'op' && peek.text == o) {
      i++;
      return true;
    }
    return false;
  }

  bool _word(String w) {
    if (peek.type == 'id' && peek.text.toLowerCase() == w) {
      i++;
      return true;
    }
    return false;
  }

  double parse() {
    final v = _expr();
    if (peek.type != 'end') throw SheetError('unexpected "${peek.text}"');
    return v;
  }

  double _expr() {
    var v = _term();
    while (true) {
      if (_op('+')) {
        v += _term();
      } else if (_op('-')) {
        v -= _term();
      } else {
        return v;
      }
    }
  }

  double _term() {
    var v = _power();
    while (true) {
      if (_op('*')) {
        v *= _power();
      } else if (_op('/')) {
        final d = _power();
        if (d == 0) throw const SheetError('division by zero');
        v /= d;
      } else if (_word('of')) {
        // "20% of x" — the percent already became 0.2.
        v *= _power();
      } else {
        return v;
      }
    }
  }

  double _power() {
    final b = _unary();
    if (_op('^')) return math.pow(b, _power()).toDouble(); // right-assoc
    return b;
  }

  double _unary() {
    if (_op('-')) return -_unary();
    if (_op('+')) return _unary();
    return _postfix(_primary());
  }

  /// Units (k, L / lakh, cr / crore) and %.
  double _postfix(double v) {
    while (true) {
      if (_op('%')) {
        v /= 100;
      } else if (peek.type == 'id' &&
          _units.containsKey(peek.text.toLowerCase())) {
        v *= _units[peek.text.toLowerCase()]!;
        i++;
      } else {
        return v;
      }
    }
  }

  static const _units = <String, double>{
    'k': 1e3,
    'thousand': 1e3,
    'l': 1e5,
    'lakh': 1e5,
    'lakhs': 1e5,
    'lac': 1e5,
    'cr': 1e7,
    'crore': 1e7,
    'crores': 1e7,
  };

  double _primary() {
    final t = peek;
    if (t.type == 'num') {
      i++;
      return t.num!;
    }
    if (_op('(')) {
      final v = _expr();
      if (!_op(')')) throw const SheetError('missing )');
      return v;
    }
    if (t.type == 'id') {
      i++;
      final name = t.text;
      if (_op('(')) return _call(name.toLowerCase(), _args());
      final low = name.toLowerCase();
      if (vars.containsKey(name)) return vars[name]!;
      switch (low) {
        case 'sum' || 'total':
          return block.fold(0.0, (s, v) => s + v);
        case 'networth':
          return data.netWorth;
        case 'investments':
          return data.investments;
        case 'cash':
          return data.cash;
        case 'pi':
          return math.pi;
        case 'e':
          return math.e;
      }
      throw SheetError('unknown name "$name"');
    }
    throw SheetError(
      t.type == 'end' ? 'incomplete line' : 'unexpected "${t.text}"',
    );
  }

  List<Object> _args() {
    final args = <Object>[];
    if (_op(')')) return args;
    while (true) {
      if (peek.type == 'str') {
        args.add(peek.text);
        i++;
      } else {
        args.add(_expr());
      }
      if (_op(')')) return args;
      if (!_op(',')) throw const SheetError('expected , or )');
    }
  }

  static double _n(List<Object> a, int i, String fn, [double? dflt]) {
    if (i < a.length) {
      final v = a[i];
      if (v is double) return v;
      throw SheetError('$fn: argument ${i + 1} should be a number');
    }
    if (dflt != null) return dflt;
    throw SheetError('$fn: needs ${i + 1} arguments');
  }

  static String? _s(List<Object> a, int i) =>
      i < a.length && a[i] is String ? a[i] as String : null;

  double _call(String fn, List<Object> a) {
    switch (fn) {
      // Loan EMI: principal, yearly rate %, years.
      case 'emi':
        final p = _n(a, 0, fn), r = _n(a, 1, fn) / 1200, n = _n(a, 2, fn) * 12;
        if (n <= 0) throw const SheetError('emi: years must be > 0');
        if (r == 0) return p / n;
        final f = math.pow(1 + r, n);
        return p * r * f / (f - 1);
      // Future value of a monthly SIP: amount, yearly return %, years.
      case 'sip':
        final m = _n(a, 0, fn), r = _n(a, 1, fn) / 1200, n = _n(a, 2, fn) * 12;
        if (r == 0) return m * n;
        return m * (math.pow(1 + r, n) - 1) / r * (1 + r);
      // Lump sum growth: amount, yearly %, years.
      case 'fv':
        return _n(a, 0, fn) * math.pow(1 + _n(a, 1, fn) / 100, _n(a, 2, fn));
      case 'pv':
        return _n(a, 0, fn) / math.pow(1 + _n(a, 1, fn) / 100, _n(a, 2, fn));
      case 'round':
        final d = _n(a, 1, fn, 0).toInt();
        final f = math.pow(10, d);
        return (_n(a, 0, fn) * f).round() / f;
      case 'min':
        if (a.isEmpty) throw const SheetError('min: needs numbers');
        return [
          for (var k = 0; k < a.length; k++) _n(a, k, fn),
        ].reduce(math.min);
      case 'max':
        if (a.isEmpty) throw const SheetError('max: needs numbers');
        return [
          for (var k = 0; k < a.length; k++) _n(a, k, fn),
        ].reduce(math.max);
      case 'abs':
        return _n(a, 0, fn).abs();
      case 'sqrt':
        return math.sqrt(_n(a, 0, fn));
      // Your data. spend("groceries"), spend("all", 1) = last month.
      case 'spend':
        final cat = _s(a, 0);
        final ago = (cat == null ? _n(a, 0, fn, 0) : _n(a, 1, fn, 0)).toInt();
        return data.spend(cat, ago);
      case 'income':
        return data.income(_n(a, 0, fn, 0).toInt());
      // Average of the last N full months (default 3).
      case 'avg_spend':
        final cat = _s(a, 0);
        final months = (cat == null ? _n(a, 0, fn, 3) : _n(a, 1, fn, 3))
            .toInt();
        if (months <= 0) {
          throw const SheetError('avg_spend: months must be > 0');
        }
        var s = 0.0;
        for (var k = 1; k <= months; k++) {
          s += data.spend(cat, k);
        }
        return s / months;
    }
    throw SheetError('unknown function "$fn"');
  }
}

/// Parser for Consolidated Account Statements (CAS) — the PDFs CAMS /
/// KFintech (mutual funds) and NSDL / CDSL (demat) send investors.
///
/// Works on plain text lines (see `LayoutToGrid.textLines`). Pure Dart.
///
/// - **Detailed CAMS / KFintech CAS**: per folio and scheme, the opening and
///   closing unit balance, every transaction, and the closing NAV / value.
/// - **Holdings tables** (NSDL / CDSL CAS, CAMS summary CAS): any line with an
///   ISIN followed by a quantity, price and value that multiply out
///   (quantity × price ≈ value) becomes a holding snapshot.
library;

enum CasProvider { cams, kfintech, nsdl, cdsl, unknown }

enum CasTxnType {
  purchase,
  sip,
  redemption,
  switchIn,
  switchOut,
  dividendPayout,
  dividendReinvest,
  tax,
  reversal,
  misc,
}

class CasTxn {
  const CasTxn({
    required this.date,
    required this.description,
    required this.type,
    this.amountPaise,
    this.unitsE4,
    this.navE4,
    this.balanceE4,
  });

  final DateTime date;
  final String description;
  final CasTxnType type;

  /// Signed: negative for redemptions / switch-outs.
  final int? amountPaise;

  /// Units × 10⁴, signed.
  final int? unitsE4;

  /// NAV (₹) × 10⁴.
  final int? navE4;

  /// Running unit balance × 10⁴.
  final int? balanceE4;
}

class CasScheme {
  CasScheme({
    required this.name,
    this.isin,
    this.registrar,
    this.openingE4 = 0,
  });

  final String name;
  final String? isin;
  final String? registrar;
  final int openingE4;
  final List<CasTxn> txns = [];
  int? closingE4;
  int? navE4;
  DateTime? navDate;
  int? costPaise;
  int? valuePaise;

  /// Opening + the units of every transaction.
  int get computedClosingE4 =>
      openingE4 + txns.fold<int>(0, (s, t) => s + (t.unitsE4 ?? 0));
}

class CasFolio {
  CasFolio({required this.folio, this.amc, this.pan});

  final String folio;
  final String? amc;
  final String? pan;
  final List<CasScheme> schemes = [];
}

/// One row of a holdings table (no transaction history).
class CasHolding {
  const CasHolding({
    required this.isin,
    required this.name,
    required this.unitsE4,
    required this.priceE4,
    required this.valuePaise,
    this.account,
  });

  final String isin;
  final String name;
  final int unitsE4;
  final int priceE4;
  final int valuePaise;

  /// Demat account (`DP ID / Client ID`) or folio, when printed nearby.
  final String? account;

  bool get isMutualFund => isin.startsWith('INF');
}

class CasStatement {
  CasStatement({required this.provider});

  final CasProvider provider;
  DateTime? periodFrom;
  DateTime? periodTo;
  final List<CasFolio> folios = [];
  final List<CasHolding> holdings = [];

  /// Non-fatal problems, e.g. a scheme whose units don't add up.
  final List<String> warnings = [];

  Iterable<CasScheme> get schemes => folios.expand((f) => f.schemes);

  bool get isEmpty => folios.every((f) => f.schemes.isEmpty) && holdings.isEmpty;

  /// Date the closing values refer to.
  DateTime? get asOf =>
      periodTo ??
      schemes.map((s) => s.navDate).whereType<DateTime>().fold<DateTime?>(
            null,
            (a, b) => a == null || b.isAfter(a) ? b : a,
          );
}

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

final _dateRe = RegExp(r'(\d{1,2})[-\s]([A-Za-z]{3})[-\s](\d{4})');
final _numericDateRe = RegExp(r'\b(\d{2})[-/](\d{2})[-/](\d{4})\b');

/// "05-Aug-2025", "5 Aug 2025" or "05-08-2025" (day first).
DateTime? parseCasDate(String s) {
  final m = _dateRe.firstMatch(s);
  if (m == null) {
    final n = _numericDateRe.firstMatch(s);
    if (n == null) return null;
    final d = int.parse(n[1]!);
    final mo = int.parse(n[2]!);
    final y = int.parse(n[3]!);
    if (mo < 1 || mo > 12) return null;
    final dt = DateTime(y, mo, d);
    return dt.month == mo && dt.day == d ? dt : null;
  }
  final mo = _months[m[2]!.toLowerCase()];
  if (mo == null) return null;
  final d = int.parse(m[1]!);
  final y = int.parse(m[3]!);
  final dt = DateTime(y, mo, d);
  return dt.month == mo ? dt : null;
}

/// "1,23,456.789" / "(1,234.50)" / "-12.5" → value × 10^[scale], or null.
int? parseScaled(String s, int scale) {
  var t = s.trim();
  var neg = false;
  if (t.startsWith('(') && t.endsWith(')')) {
    neg = true;
    t = t.substring(1, t.length - 1);
  }
  if (t.startsWith('-')) {
    neg = !neg;
    t = t.substring(1);
  }
  t = t.replaceAll(',', '');
  if (!RegExp(r'^\d*\.?\d+$').hasMatch(t)) return null;
  final parts = t.split('.');
  final whole = parts[0].isEmpty ? 0 : int.parse(parts[0]);
  var frac = parts.length > 1 ? parts[1] : '';
  if (frac.length > scale) {
    // Round half up on the dropped digits.
    final keep = int.parse(frac.substring(0, scale).padRight(scale, '0'));
    final roundUp = int.parse(frac[scale]) >= 5 ? 1 : 0;
    final v = whole * _pow10(scale) + keep + roundUp;
    return neg ? -v : v;
  }
  frac = frac.padRight(scale, '0');
  final v = whole * _pow10(scale) + (scale == 0 ? 0 : int.parse(frac));
  return neg ? -v : v;
}

int _pow10(int n) {
  var v = 1;
  for (var i = 0; i < n; i++) {
    v *= 10;
  }
  return v;
}

// --- patterns -------------------------------------------------------------

final _periodRe = RegExp(
  r'(\d{2}-[A-Za-z]{3}-\d{4})\s+(?:To|to)\s+(\d{2}-[A-Za-z]{3}-\d{4})',
);
final _folioRe = RegExp(
  r'Folio\s+No\s*[:.]?\s*([0-9A-Z]+(?:\s*/\s*[0-9A-Z]+)?)'
  r'(?:.*?PAN\s*:\s*([A-Z]{5}\d{4}[A-Z]))?',
  caseSensitive: false,
);
final _amcRe = RegExp(r'^[A-Za-z][A-Za-z0-9 &.()\-]*?\s(?:Mutual\s*Fund|MF)$');
final _isinRe = RegExp(r'\b(IN[EF9][0-9A-Z]{8}\d)\b');
final _registrarRe = RegExp(r'Registrar\s*:\s*([A-Za-z]+)', caseSensitive: false);
final _openRe = RegExp(r'Opening\s+Unit\s+Balance\s*:?\s*([\d,.]+)', caseSensitive: false);
final _closeRe = RegExp(r'Closing\s+Unit\s+Balance\s*:?\s*([\d,.]+)', caseSensitive: false);
final _navRe = RegExp(
  r'NAV\s+on\s+(\d{1,2}-[A-Za-z]{3}-\d{4})\s*:\s*(?:INR|Rs\.?|₹)?\s*([\d,.]+)',
  caseSensitive: false,
);
final _valueRe = RegExp(
  r'(?:Market\s+Value|Valuation)\s+on\s+\d{1,2}-[A-Za-z]{3}-\d{4}\s*:\s*(?:INR|Rs\.?|₹)?\s*([\d,.]+)',
  caseSensitive: false,
);
final _costRe = RegExp(r'Total\s+Cost\s+Value\s*:?\s*([\d,.]+)', caseSensitive: false);
final _txnLineRe = RegExp(r'^(\d{1,2}-[A-Za-z]{3}-\d{4})\s+(.+)$');
final _decimalToken = RegExp(r'^\(?-?[\d,]*\.\d+\)?$');
final _numberToken = RegExp(r'^\(?-?[\d,]*\.?\d+\)?$');
final _dpClientRe = RegExp(
  r'DP\s*ID\s*:?\s*(\S+?)\s+Client\s*ID\s*:?\s*(\d+)',
  caseSensitive: false,
);
final _boIdRe = RegExp(r'BO\s*ID\s*:?\s*(\d{16})', caseSensitive: false);
final _asOnRe = RegExp(
  r'(?:as\s+on|as\s+of)\s+(\d{1,2}[-\s][A-Za-z]{3}[-\s]\d{4}|\d{2}[-/]\d{2}[-/]\d{4})',
  caseSensitive: false,
);

CasProvider detectCasProvider(List<String> lines) {
  final text = lines.take(200).join('\n');
  if (text.contains('CAMSCASWS')) return CasProvider.cams;
  if (text.contains('KFINCASWS')) return CasProvider.kfintech;
  if (text.contains('NSDL Consolidated Account Statement') ||
      text.contains('About NSDL') ||
      text.contains('National Securities Depository')) {
    return CasProvider.nsdl;
  }
  if (text.contains('Central Depository Services')) return CasProvider.cdsl;
  if (RegExp(r'Registrar\s*:\s*CAMS', caseSensitive: false).hasMatch(text)) {
    return CasProvider.cams;
  }
  if (RegExp(r'Registrar\s*:\s*(KFIN|KARVY)', caseSensitive: false)
      .hasMatch(text)) {
    return CasProvider.kfintech;
  }
  return CasProvider.unknown;
}

/// Whether [lines] look like a CAS rather than a bank / card statement.
bool looksLikeCas(List<String> lines) {
  final text = lines.take(300).join('\n');
  final heading = RegExp(r'consolidated\s+account\s+(statement|summary)',
          caseSensitive: false)
      .hasMatch(text);
  final markers = text.contains('CAMSCASWS') ||
      text.contains('KFINCASWS') ||
      RegExp(r'Folio\s+No', caseSensitive: false).hasMatch(text) ||
      RegExp(r'Demat\s+Account|DP\s*ID|BO\s*ID', caseSensitive: false)
          .hasMatch(text);
  return heading && markers;
}

CasTxnType classifyCasTxn(String description, int? unitsE4) {
  final d = description.toLowerCase();
  final isDividend = RegExp(r'(?:div\.|dividend|idcw)').hasMatch(d);
  if (isDividend && d.contains('reinvest')) return CasTxnType.dividendReinvest;
  if (isDividend && (unitsE4 == null || unitsE4 == 0)) {
    return CasTxnType.dividendPayout;
  }
  if (unitsE4 == null || unitsE4 == 0) {
    if (RegExp(r'stamp\s*duty|\bstt\b|\btds\b').hasMatch(d)) {
      return CasTxnType.tax;
    }
    return CasTxnType.misc;
  }
  final isSwitch =
      d.contains('switch') || RegExp(r'\bs\s*t\s*p\b|systematic\s+transfer').hasMatch(d);
  if (unitsE4 > 0) {
    if (isSwitch) return CasTxnType.switchIn;
    if (d.contains('sip') ||
        d.contains('systematic') ||
        RegExp(r'instal+ment').hasMatch(d)) {
      return CasTxnType.sip;
    }
    return CasTxnType.purchase;
  }
  if (RegExp(r'reversal|rejection|dishonou?red|insufficient|not\s+received')
      .hasMatch(d)) {
    return CasTxnType.reversal;
  }
  if (isSwitch) return CasTxnType.switchOut;
  return CasTxnType.redemption;
}

/// Scheme name from a CAS scheme header, without scheme code, ISIN,
/// advisor, registrar and (Non-)Demat trailers.
String cleanSchemeName(String header) {
  var s = header;
  for (final re in [
    RegExp(r'\s*-?\s*ISIN\s*:.*$', caseSensitive: false),
    RegExp(r'\s*\(\s*Advisor\s*:.*$', caseSensitive: false),
    RegExp(r'\s*Registrar\s*:.*$', caseSensitive: false),
    RegExp(r'\s*\((?:Non-)?Demat\).*$', caseSensitive: false),
    RegExp(r'\s*\((?:formerly|erstwhile)[^)]*\)', caseSensitive: false),
  ]) {
    s = s.replaceAll(re, '');
  }
  // Leading scheme code like "B92Z-" or "128TSGPG - ".
  s = s.replaceFirst(RegExp(r'^[A-Z0-9]{2,12}\s*-\s*(?=[A-Za-z])'), '');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s.replaceAll(RegExp(r'[\s\-–:]+$'), '');
}

class CasParser {
  const CasParser();

  CasStatement parse(List<String> rawLines) {
    final lines = [
      for (final l in rawLines)
        if (l.trim().isNotEmpty) l.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ];
    final st = CasStatement(provider: detectCasProvider(lines));

    for (final l in lines.take(80)) {
      final m = _periodRe.firstMatch(l);
      if (m != null) {
        st.periodFrom = parseCasDate(m[1]!);
        st.periodTo = parseCasDate(m[2]!);
        break;
      }
    }

    _parseDetailed(lines, st);
    _parseHoldings(lines, st);
    return st;
  }

  void _parseDetailed(List<String> lines, CasStatement st) {
    String? amc;
    CasFolio? folio;
    CasScheme? scheme;
    final header = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];

      if (_amcRe.hasMatch(l) && !l.contains('Folio')) {
        amc = l;
        continue;
      }

      final fm = _folioRe.firstMatch(l);
      if (fm != null && l.toLowerCase().startsWith('folio')) {
        final no = fm[1]!.replaceAll(RegExp(r'\s+'), '');
        var f = st.folios
            .where((x) => x.folio == no && x.amc == amc)
            .firstOrNull;
        if (f == null) {
          f = CasFolio(folio: no, amc: amc, pan: fm[2]);
          st.folios.add(f);
        }
        folio = f;
        scheme = null;
        header.clear();
        continue;
      }
      if (folio == null) continue;

      final om = _openRe.firstMatch(l);
      if (om != null) {
        final text = _schemeHeader(header);
        scheme = CasScheme(
          name: cleanSchemeName(text),
          isin: _isinRe.firstMatch(text)?.group(1),
          registrar: _registrarRe.firstMatch(text)?.group(1)?.toUpperCase(),
          openingE4: parseScaled(om[1]!, 4) ?? 0,
        );
        folio.schemes.add(scheme);
        header.clear();
        continue;
      }

      final cm = _closeRe.firstMatch(l);
      if (cm != null && scheme != null) {
        // Closing facts may wrap onto the next lines.
        final tail = [l, if (i + 1 < lines.length) lines[i + 1],
            if (i + 2 < lines.length) lines[i + 2]].join(' ');
        scheme.closingE4 = parseScaled(cm[1]!, 4);
        final nm = _navRe.firstMatch(tail);
        if (nm != null) {
          scheme.navDate = parseCasDate(nm[1]!);
          scheme.navE4 = parseScaled(nm[2]!, 4);
        }
        final vm = _valueRe.firstMatch(tail);
        if (vm != null) scheme.valuePaise = parseScaled(vm[1]!, 2);
        final cv = _costRe.firstMatch(tail);
        if (cv != null) scheme.costPaise = parseScaled(cv[1]!, 2);
        final closing = scheme.closingE4;
        if (closing != null &&
            (scheme.computedClosingE4 - closing).abs() > 10) {
          st.warnings.add(
            '${scheme.name}: transactions add up to '
            '${scheme.computedClosingE4 / 1e4} units, statement says '
            '${closing / 1e4}',
          );
        }
        scheme = null;
        continue;
      }

      if (scheme != null) {
        final tm = _txnLineRe.firstMatch(l);
        if (tm != null) {
          final txn = _parseTxn(tm[1]!, tm[2]!, scheme);
          if (txn != null) scheme.txns.add(txn);
        }
        continue;
      }

      // Between schemes: collect the next scheme's header lines, skipping
      // obvious column headings and page furniture.
      if (_isNoise(l)) continue;
      header.add(l);
      if (header.length > 6) header.removeAt(0);
    }
  }

  /// The scheme's header out of the lines between folio / previous scheme
  /// and "Opening Unit Balance": from the line starting with a scheme code
  /// ("B92Z-…"), else from the line before the ISIN when the ISIN line is a
  /// continuation, else the ISIN line itself.
  static String _schemeHeader(List<String> buf) {
    if (buf.isEmpty) return '';
    final codeRe = RegExp(r'^[A-Z0-9]{2,12}\s*-\s*[A-Za-z]');
    var isinAt = buf.lastIndexWhere(
        (l) => _isinRe.hasMatch(l) || l.toUpperCase().contains('ISIN'));
    if (isinAt < 0) isinAt = buf.length - 1;
    var start = -1;
    for (var i = isinAt; i >= 0; i--) {
      if (codeRe.hasMatch(buf[i])) {
        start = i;
        break;
      }
    }
    if (start < 0) {
      final continuation = RegExp(r'^(?:ISIN|INF|\(|Registrar)', caseSensitive: false)
          .hasMatch(buf[isinAt]);
      start = continuation && isinAt > 0 ? isinAt - 1 : isinAt;
    }
    return buf.sublist(start).join(' ');
  }

  static bool _isNoise(String l) {
    final d = l.toLowerCase();
    return d.startsWith('date ') ||
        d.contains('transaction amount') ||
        d.startsWith('page ') ||
        d.contains('(inr)') ||
        RegExp(r'^\d+$').hasMatch(d) ||
        d.startsWith('nominee') ||
        d.startsWith('kyc');
  }

  CasTxn? _parseTxn(String dateStr, String rest, CasScheme scheme) {
    final date = parseCasDate(dateStr);
    if (date == null) return null;
    final tokens = rest.split(' ');
    final nums = <String>[];
    var cut = tokens.length;
    while (cut > 0 && nums.length < 4 && _decimalToken.hasMatch(tokens[cut - 1])) {
      nums.insert(0, tokens[--cut]);
    }
    final desc = tokens.take(cut).join(' ').trim();
    if (desc.isEmpty) return null;

    int? amount;
    int? units;
    int? nav;
    int? balance;
    final prevBal = scheme.txns.isEmpty
        ? scheme.openingE4
        : (scheme.txns.last.balanceE4 ?? scheme.computedClosingE4);
    switch (nums.length) {
      case 4:
        amount = parseScaled(nums[0], 2);
        units = parseScaled(nums[1], 4);
        nav = parseScaled(nums[2], 4);
        balance = parseScaled(nums[3], 4);
      case 3:
        final a = parseScaled(nums[0], 4)!;
        final c = parseScaled(nums[2], 4)!;
        if ((prevBal + a - c).abs() <= 10) {
          // units, NAV, balance (no amount, e.g. bonus / merger)
          units = a;
          nav = parseScaled(nums[1], 4);
          balance = c;
        } else {
          amount = parseScaled(nums[0], 2);
          units = parseScaled(nums[1], 4);
          nav = parseScaled(nums[2], 4);
        }
      case 2:
        final a = parseScaled(nums[0], 4)!;
        final b = parseScaled(nums[1], 4)!;
        if ((prevBal + a - b).abs() <= 10) {
          units = a;
          balance = b;
        } else {
          amount = parseScaled(nums[0], 2);
        }
      case 1:
        amount = parseScaled(nums[0], 2);
      default:
        // Marker rows ("*** Registration of Nominee ***") carry no money.
        if (!desc.startsWith('***')) return null;
    }
    // Redemptions sometimes print the amount unsigned with signed units.
    if (amount != null && units != null && units < 0 && amount > 0) {
      amount = -amount;
    }
    return CasTxn(
      date: date,
      description: desc,
      type: classifyCasTxn(desc, units),
      amountPaise: amount,
      unitsE4: units,
      navE4: nav,
      balanceE4: balance,
    );
  }

  /// Rows with an ISIN and a (quantity, price, value) triple that multiplies
  /// out. ISINs already covered by detailed schemes are skipped.
  void _parseHoldings(List<String> lines, CasStatement st) {
    final detailed = {for (final s in st.schemes) if (s.isin != null) s.isin!};
    final seen = <String>{};
    String? account;
    DateTime? asOn;
    for (final l in lines) {
      final dp = _dpClientRe.firstMatch(l);
      if (dp != null) account = '${dp[1]}/${dp[2]}';
      final bo = _boIdRe.firstMatch(l);
      if (bo != null) account = bo[1];
      final ao = _asOnRe.firstMatch(l);
      if (ao != null) asOn ??= parseCasDate(ao[1]!);

      final im = _isinRe.firstMatch(l);
      if (im == null) continue;
      final isin = im[1]!;
      if (detailed.contains(isin)) continue;
      final after = l.substring(im.end).trim().split(' ');
      final h = _holdingFrom(isin, after, account);
      if (h == null) continue;
      final key = '$isin|${h.account}';
      if (seen.add(key)) st.holdings.add(h);
    }
    st.periodTo ??= asOn;
  }

  CasHolding? _holdingFrom(String isin, List<String> tokens, String? account) {
    // Trailing run of numbers after the name.
    var start = tokens.length;
    while (start > 0 && _numberToken.hasMatch(tokens[start - 1])) {
      start--;
    }
    final nums = tokens.sublist(start);
    if (nums.length < 3) return null;
    final nameTokens = tokens.take(start).toList();
    // Drop a leading code (NSDL's UCC, e.g. "MFHDFC0001") and a trailing
    // folio number ("1234567/89").
    if (nameTokens.length > 1 &&
        RegExp(r'^[A-Z]{2,}\d+$').hasMatch(nameTokens.first)) {
      nameTokens.removeAt(0);
    }
    if (nameTokens.length > 1 &&
        RegExp(r'^\d+(/\d+)?$').hasMatch(nameTokens.last)) {
      nameTokens.removeLast();
    }
    final name = nameTokens
        .join(' ')
        .replaceAll(RegExp(r'^[\s\-:]+|[\s\-:]+$'), '');
    // Find quantity < price < value positions with quantity × price ≈ value.
    // Prefer the value furthest right (it's normally the last column), then
    // the leftmost quantity (columns like face value sit between).
    final q = [for (final n in nums) parseScaled(n, 4)];
    final v = [for (final n in nums) parseScaled(n, 2)];
    for (var k = nums.length - 1; k >= 2; k--) {
      final value = v[k];
      if (value == null || value <= 0) continue;
      for (var i = 0; i < k - 1; i++) {
        final qty = q[i];
        if (qty == null || qty <= 0) continue;
        for (var j = k - 1; j > i; j--) {
          final price = q[j];
          if (price == null || price <= 0) continue;
          final product = qty * price / 1e8; // rupees
          final rupees = value / 100;
          if ((product - rupees).abs() <= rupees * 0.005 + 1) {
            return CasHolding(
              isin: isin,
              name: name.isEmpty ? isin : name,
              unitsE4: qty,
              priceE4: price,
              valuePaise: value,
              account: account,
            );
          }
        }
      }
    }
    return null;
  }
}

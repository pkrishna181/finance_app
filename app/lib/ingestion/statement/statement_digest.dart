import '../../core/models/merchant_label.dart';
import 'printed_totals.dart';

/// One transaction as the summary sees it — from a parsed statement before
/// import, or from the database after.
class DigestRow {
  const DigestRow({
    required this.date,
    required this.paise,
    required this.isDebit,
    required this.merchant,
    required this.description,
  });

  final DateTime date;
  final int paise;
  final bool isDebit;
  final String merchant;
  final String description;
}

/// Money to or from one payee.
class PayeeTotal {
  const PayeeTotal(this.name, this.paise, this.count);

  final String name;
  final int paise;
  final int count;
}

/// A parsed figure against the one the statement prints.
class DigestCheck {
  const DigestCheck({
    required this.what,
    required this.printedPaise,
    required this.parsedPaise,
    this.isCount = false,
  });

  /// moneyOut | moneyIn | debitCount | creditCount | closing
  final String what;
  final int printedPaise;
  final int parsedPaise;

  /// Counts, not money (stored ×100 like paise).
  final bool isCount;

  /// Banks round some totals; a rupee either way is a match.
  bool get ok => (printedPaise - parsedPaise).abs() <= (isCount ? 0 : 100);
  int get differencePaise => parsedPaise - printedPaise;
}

/// Everything the statement summary shows. Pure: built from rows and the
/// statement's own printed totals; no amounts come from anywhere else.
class StatementDigest {
  const StatementDigest({
    required this.bankCode,
    required this.isCard,
    required this.last4,
    required this.from,
    required this.to,
    required this.inPaise,
    required this.outPaise,
    required this.inCount,
    required this.outCount,
    required this.charges,
    required this.interestEarnedPaise,
    required this.topPayees,
    required this.topSources,
    required this.largest,
    required this.instalmentsPaise,
    required this.instalmentCount,
    required this.printed,
    required this.checks,
  });

  final String bankCode;
  final bool isCard;
  final String? last4;
  final DateTime? from;
  final DateTime? to;
  final int inPaise;
  final int outPaise;
  final int inCount;
  final int outCount;

  /// Fees, charges, taxes and interest the bank or card took.
  final List<DigestRow> charges;
  final int interestEarnedPaise;

  /// Where money went (debits), largest first.
  final List<PayeeTotal> topPayees;

  /// Where money came from (credits), largest first.
  final List<PayeeTotal> topSources;

  /// Largest single debits.
  final List<DigestRow> largest;

  /// Card EMI instalments billed this cycle (not in money out: the purchase
  /// they repay was spent earlier).
  final int instalmentsPaise;
  final int instalmentCount;
  final PrintedTotals printed;
  final List<DigestCheck> checks;

  int get chargesPaise => charges.fold(0, (a, r) => a + r.paise);

  /// null: the statement prints nothing to check against.
  bool? get reconciled => checks.isEmpty ? null : checks.every((c) => c.ok);

  static StatementDigest build({
    required List<DigestRow> rows,
    required PrintedTotals printed,
    required String bankCode,
    required bool isCard,
    String? last4,
    int instalmentsPaise = 0,
    int instalmentCount = 0,
  }) {
    final debits = [
      for (final r in rows)
        if (r.isDebit) r,
    ];
    final credits = [
      for (final r in rows)
        if (!r.isDebit) r,
    ];
    int sum(Iterable<DigestRow> rs) => rs.fold(0, (a, r) => a + r.paise);
    final outPaise = sum(debits);
    final inPaise = sum(credits);
    final charges = [
      for (final r in debits)
        if (_charge.hasMatch(r.description)) r,
    ];
    final interestEarned = sum(
      credits.where((r) => _interestEarned.hasMatch(r.description)),
    );

    DateTime? from = printed.periodStart, to = printed.periodEnd;
    for (final r in rows) {
      if (printed.periodStart == null &&
          (from == null || r.date.isBefore(from))) {
        from = r.date;
      }
      if (printed.periodEnd == null && (to == null || r.date.isAfter(to))) {
        to = r.date;
      }
    }

    final checks = <DigestCheck>[];
    final chargesPaise = sum(charges);
    if (printed.debitsPaise != null) {
      // Cards print purchases apart from fees; accounts print one total.
      final parsed = isCard && printed.feesPaise != null
          ? outPaise - chargesPaise
          : outPaise;
      checks.add(
        DigestCheck(
          what: 'moneyOut',
          printedPaise: printed.debitsPaise!,
          parsedPaise: parsed,
        ),
      );
    }
    if (printed.creditsPaise != null) {
      checks.add(
        DigestCheck(
          what: 'moneyIn',
          printedPaise: printed.creditsPaise!,
          parsedPaise: inPaise,
        ),
      );
    }
    if (printed.debitCount != null) {
      checks.add(
        DigestCheck(
          what: 'debitCount',
          printedPaise: printed.debitCount! * 100,
          parsedPaise: debits.length * 100,
          isCount: true,
        ),
      );
    }
    if (printed.creditCount != null) {
      checks.add(
        DigestCheck(
          what: 'creditCount',
          printedPaise: printed.creditCount! * 100,
          parsedPaise: credits.length * 100,
          isCount: true,
        ),
      );
    }
    if (printed.openingPaise != null && printed.closingPaise != null) {
      // Account: balance + in − out. Card: amount owed − paid + spent.
      final closing = isCard
          ? printed.openingPaise! - inPaise + outPaise
          : printed.openingPaise! + inPaise - outPaise;
      checks.add(
        DigestCheck(
          what: 'closing',
          printedPaise: printed.closingPaise!,
          parsedPaise: closing,
        ),
      );
    }

    return StatementDigest(
      bankCode: bankCode,
      isCard: isCard,
      last4: last4,
      from: from,
      to: to,
      inPaise: inPaise,
      outPaise: outPaise,
      inCount: credits.length,
      outCount: debits.length,
      charges: charges,
      interestEarnedPaise: interestEarned,
      topPayees: _byPayee(debits.where((r) => !charges.contains(r))),
      topSources: _byPayee(credits),
      largest: ([
        ...debits,
      ]..sort((a, b) => b.paise.compareTo(a.paise))).take(5).toList(),
      instalmentsPaise: instalmentsPaise,
      instalmentCount: instalmentCount,
      printed: printed,
      checks: checks,
    );
  }
}

final _charge = RegExp(
  r'\b(?:fees?|charges?|chgs|gst|igst|cgst|sgst|interest|markup|penalty|'
  r'late\s+payment|finance\s+charges?|tds)\b',
  caseSensitive: false,
);
final _interestEarned = RegExp(
  r'\binterest\b|\bint\.?\s*pd\b|\bsbint\b|\bint\s+credit\b',
  caseSensitive: false,
);

/// Words that don't name a payee: places, company suffixes, card-network
/// prefixes.
const _noise = {
  'in',
  'ind',
  'pvt',
  'priv',
  'private',
  'ltd',
  'limited',
  'llp',
  'india',
  'technologies',
  'marketplace',
  'online',
  'com',
  'www',
  'bangalore',
  'bengaluru',
  'mumbai',
  'newdelhi',
  'delhi',
  'new',
  'hyderabad',
  'noida',
  'gurgaon',
  'gurugram',
  'chennai',
  'pune',
  'kolkata',
  'ka',
  'ca',
  'us',
  'upi',
  'mr',
  'mrs',
  'ms',
};

/// Platforms that carry many merchants: keep the next word too
/// ("Google Play" and "Google Cloud" are different).
const _platforms = {'google', 'amazon', 'paytm', 'apple', 'microsoft'};

/// Grouping key and display name for a payee.
(String, String) payeeKey(String merchant) {
  var s = merchant.replaceFirst(RegExp(r'^[A-Za-z]{2,4}\*\s*'), '');
  final words = normalizeMerchantLabel(
    s,
  ).split(' ').where((w) => w.length > 1 && !_noise.contains(w)).toList();
  if (words.isEmpty) {
    final plain = normalizeMerchantLabel(merchant);
    return (plain, _title(plain.isEmpty ? merchant : plain));
  }
  final take = _platforms.contains(words.first) && words.length > 1 ? 2 : 1;
  // A first word of two letters ("D Sivana") names nobody on its own.
  final key = words.take(words.first.length < 3 ? 2 : take).join(' ');
  return (key, _title(key));
}

String _title(String s) => s
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

List<PayeeTotal> _byPayee(Iterable<DigestRow> rows) {
  final totals = <String, (String, int, int)>{};
  for (final r in rows) {
    final (key, name) = payeeKey(r.merchant);
    final t = totals[key];
    totals[key] = (name, (t?.$2 ?? 0) + r.paise, (t?.$3 ?? 0) + 1);
  }
  final out = [for (final t in totals.values) PayeeTotal(t.$1, t.$2, t.$3)]
    ..sort((a, b) => b.paise.compareTo(a.paise));
  return out.take(5).toList();
}

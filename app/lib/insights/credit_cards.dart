import 'insight_models.dart';

/// A card the user tracks.
class CardDef {
  const CardDef({
    required this.id,
    required this.bankCode,
    required this.name,
    this.last4,
    this.creditLimitPaise,
    this.statementDay,
    this.dueDay,
  });

  final int id;
  final String bankCode;
  final String name;
  final String? last4;
  final int? creditLimitPaise;

  /// Day of month the statement closes (1–31; clamped to short months).
  final int? statementDay;

  /// Day of month payment is due.
  final int? dueDay;
}

/// Bill facts read from an imported card statement.
class CardBill {
  const CardBill({
    this.statementDate,
    this.periodEnd,
    this.dueDate,
    this.totalDuePaise,
    this.minDuePaise,
    this.creditLimitPaise,
  });

  final DateTime? statementDate;

  /// Latest transaction on the statement (when no statement date printed).
  final DateTime? periodEnd;
  final DateTime? dueDate;
  final int? totalDuePaise;
  final int? minDuePaise;
  final int? creditLimitPaise;

  DateTime? get closedOn => statementDate ?? periodEnd;
}

enum CardBillState { noBill, due, paid, overdue }

class CardStatus {
  const CardStatus({
    required this.card,
    required this.state,
    required this.unbilledPaise,
    this.lastClose,
    this.nextClose,
    this.dueDate,
    this.billPaise,
    this.billIsEstimate = false,
    this.minDuePaise,
    this.paidPaise = 0,
    this.limitPaise,
    this.asOf,
  });

  final CardDef card;
  final CardBillState state;

  /// Spends minus refunds since the last statement closed.
  final int unbilledPaise;
  final DateTime? lastClose;
  final DateTime? nextClose;
  final DateTime? dueDate;

  /// Last statement's total due (printed, or estimated from transactions).
  final int? billPaise;
  final bool billIsEstimate;
  final int? minDuePaise;

  /// Payments received since the last statement closed.
  final int paidPaise;
  final int? limitPaise;
  final DateTime? asOf;

  int get remainingDuePaise {
    final b = billPaise;
    if (b == null) return 0;
    final r = b - paidPaise;
    return r < 0 ? 0 : r;
  }

  /// Outstanding now: unpaid bill + unbilled spend.
  int get outstandingPaise => remainingDuePaise + unbilledPaise;

  double? get utilization {
    final l = limitPaise;
    if (l == null || l <= 0) return null;
    return outstandingPaise / l;
  }

  int? get daysToDue {
    final d = dueDate;
    final now = asOf;
    if (d == null || now == null) return null;
    return DateTime(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
  }
}

/// Credits that look like a bill payment rather than a merchant refund.
final _paymentWords = RegExp(
  r'payment|thank\s*you|received|autopay|auto\s*debit|bbps|neft|imps|upi|'
  r'net\s*banking|netbanking|billdesk|bill\s*pay',
  caseSensitive: false,
);

bool isCardPayment(InsightTxn t) =>
    !t.isDebit && _paymentWords.hasMatch(t.rawMerchant);

/// The [day]-th of [year]/[month], clamped to the month's last day.
DateTime clampedDay(int year, int month, int day) {
  final last = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > last ? last : day);
}

/// Pure card-cycle maths.
class CardCycleCalculator {
  const CardCycleCalculator();

  CardStatus status(
    CardDef card,
    List<InsightTxn> txns, {
    required DateTime asOf,
    List<CardBill> bills = const [],
  }) {
    final today = DateTime(asOf.year, asOf.month, asOf.day);
    final latestBill = _latestBill(bills, today);

    // Cycle boundaries: statement day wins, else the latest bill's close.
    DateTime? lastClose;
    DateTime? prevClose;
    DateTime? nextClose;
    final sd = card.statementDay;
    if (sd != null) {
      var c = clampedDay(today.year, today.month, sd);
      if (c.isAfter(today)) c = clampedDay(today.year, today.month - 1, sd);
      lastClose = c;
      prevClose = clampedDay(c.year, c.month - 1, sd);
      nextClose = clampedDay(c.year, c.month + 1, sd);
    } else if (latestBill?.closedOn case final closed?) {
      lastClose = closed;
      prevClose = DateTime(closed.year, closed.month - 1, closed.day);
      nextClose = DateTime(closed.year, closed.month + 1, closed.day);
    }

    final limit = card.creditLimitPaise ?? latestBill?.creditLimitPaise;
    if (lastClose == null) {
      // No cycle known: everything in the last 30 days counts as unbilled.
      final from = today.subtract(const Duration(days: 30));
      return CardStatus(
        card: card,
        state: CardBillState.noBill,
        unbilledPaise: _net(txns, from, today, excludePayments: true),
        limitPaise: limit,
        asOf: asOf,
      );
    }

    // Printed bill applies when it closed within 5 days of our cycle close.
    final printed =
        latestBill != null &&
            latestBill.closedOn != null &&
            latestBill.closedOn!.difference(lastClose).inDays.abs() <= 5
        ? latestBill
        : null;

    int? bill = printed?.totalDuePaise;
    var estimate = false;
    if (bill == null) {
      final b = _net(txns, prevClose!, lastClose, excludePayments: true);
      if (b > 0) {
        bill = b;
        estimate = true;
      }
    }

    DateTime? due = printed?.dueDate;
    if (due == null && card.dueDay != null) {
      var d = clampedDay(lastClose.year, lastClose.month, card.dueDay!);
      if (!d.isAfter(lastClose)) {
        d = clampedDay(lastClose.year, lastClose.month + 1, card.dueDay!);
      }
      due = d;
    }

    var paid = 0;
    for (final t in txns) {
      if (_inRange(t, lastClose, today) && isCardPayment(t)) {
        paid += t.amountPaise;
      }
    }
    final unbilled = _net(txns, lastClose, today, excludePayments: true);

    final state = bill == null || bill <= 0
        ? CardBillState.noBill
        : paid >= bill
        ? CardBillState.paid
        : due != null && today.isAfter(due)
        ? CardBillState.overdue
        : CardBillState.due;

    return CardStatus(
      card: card,
      state: state,
      unbilledPaise: unbilled < 0 ? 0 : unbilled,
      lastClose: lastClose,
      nextClose: nextClose,
      dueDate: due,
      billPaise: bill,
      billIsEstimate: estimate,
      minDuePaise: printed?.minDuePaise,
      paidPaise: paid,
      limitPaise: limit,
      asOf: asOf,
    );
  }

  CardBill? _latestBill(List<CardBill> bills, DateTime today) {
    CardBill? best;
    for (final b in bills) {
      final c = b.closedOn;
      if (c == null || c.isAfter(today)) continue;
      if (best == null || c.isAfter(best.closedOn!)) best = b;
    }
    return best;
  }

  /// (from, to] by calendar day.
  static bool _inRange(InsightTxn t, DateTime from, DateTime to) {
    final d = DateTime(t.bookedAt.year, t.bookedAt.month, t.bookedAt.day);
    return d.isAfter(from) && !d.isAfter(to);
  }

  /// Debits minus non-payment credits in (from, to].
  static int _net(
    List<InsightTxn> txns,
    DateTime from,
    DateTime to, {
    required bool excludePayments,
  }) {
    var n = 0;
    for (final t in txns) {
      if (!_inRange(t, from, to)) continue;
      if (t.isDebit) {
        n += t.amountPaise;
      } else if (!(excludePayments && isCardPayment(t))) {
        n -= t.amountPaise;
      }
    }
    return n;
  }
}

import 'credit_cards.dart';
import 'loans.dart';
import 'recurring_detector.dart';

enum UpcomingKind { subscription, sip, emi, loanEmi, cardDue }

extension UpcomingKindLabel on UpcomingKind {
  String get label => switch (this) {
    UpcomingKind.subscription => 'Subscription',
    UpcomingKind.sip => 'SIP',
    UpcomingKind.emi => 'EMI / mandate',
    UpcomingKind.loanEmi => 'Loan EMI',
    UpcomingKind.cardDue => 'Card bill',
  };
}

class UpcomingEvent {
  const UpcomingEvent({
    required this.date,
    required this.kind,
    required this.label,
    required this.amountPaise,
    this.overdue = false,
    this.estimated = false,
  });

  final DateTime date;
  final UpcomingKind kind;
  final String label;
  final int amountPaise;

  /// Was expected already and hasn't happened / been paid.
  final bool overdue;

  /// Date predicted from past payments (not a bank notice or a schedule).
  final bool estimated;
}

/// Pure merge of everything due in `[from, to]`.
class UpcomingCalendar {
  const UpcomingCalendar();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _step(DateTime d, Cadence c, int n) => switch (c) {
    Cadence.weekly => d.add(Duration(days: 7 * n)),
    Cadence.monthly => DateTime(d.year, d.month + n, d.day),
    Cadence.quarterly => DateTime(d.year, d.month + 3 * n, d.day),
    Cadence.annual => DateTime(d.year + n, d.month, d.day),
  };

  List<UpcomingEvent> build({
    required DateTime from,
    required DateTime to,
    List<RecurringSeries> recurring = const [],
    List<LoanDef> loans = const [],
    List<CardStatus> cards = const [],
    int overdueGraceDays = 7,
  }) {
    final start = _day(from);
    final end = _day(to);
    final out = <UpcomingEvent>[];

    // Loans first: their EMIs are authoritative.
    for (final l in loans) {
      for (final r in const LoanCalculator().schedule(l)) {
        if (r.isPrepayment) continue;
        final d = _day(r.date);
        if (d.isBefore(start) || d.isAfter(end)) continue;
        out.add(
          UpcomingEvent(
            date: d,
            kind: UpcomingKind.loanEmi,
            label: l.name,
            amountPaise: r.interestPaise + r.principalPaise,
          ),
        );
      }
    }

    bool coveredByLoan(DateTime d, int amount) => out.any(
      (e) =>
          e.kind == UpcomingKind.loanEmi &&
          (e.date.difference(d).inDays).abs() <= 3 &&
          (e.amountPaise - amount).abs() <= e.amountPaise ~/ 100,
    );

    for (final s in recurring) {
      if (!s.active) continue;
      final kind = switch (s.kind) {
        'sip' => UpcomingKind.sip,
        'enach' => UpcomingKind.emi,
        _ => UpcomingKind.subscription,
      };
      final first = _day(s.mandateDate ?? s.nextExpected);
      for (var n = 0; n < 60; n++) {
        final d = _day(_step(first, s.cadence, n));
        if (d.isAfter(end)) break;
        final overdue = d.isBefore(start);
        if (overdue && start.difference(d).inDays > overdueGraceDays) continue;
        if (coveredByLoan(d, s.lastAmountPaise)) continue;
        out.add(
          UpcomingEvent(
            date: overdue ? start : d,
            kind: kind,
            label: s.label,
            amountPaise: s.lastAmountPaise,
            overdue: overdue,
            estimated: !(n == 0 && s.mandateDate != null),
          ),
        );
      }
    }

    for (final c in cards) {
      final due = c.dueDate;
      if (due == null) continue;
      if (c.state != CardBillState.due && c.state != CardBillState.overdue) {
        continue;
      }
      final d = _day(due);
      if (d.isAfter(end)) continue;
      final overdue = c.state == CardBillState.overdue;
      out.add(
        UpcomingEvent(
          date: overdue || d.isBefore(start) ? start : d,
          kind: UpcomingKind.cardDue,
          label:
              '${c.card.name}${c.card.last4 == null ? '' : ' ••${c.card.last4}'}',
          amountPaise: c.remainingDuePaise,
          overdue: overdue,
        ),
      );
    }

    out.sort((a, b) {
      final c = a.date.compareTo(b.date);
      return c != 0 ? c : b.amountPaise.compareTo(a.amountPaise);
    });
    return out;
  }
}

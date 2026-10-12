import 'dart:math' as math;

import 'yearly.dart';

const kLoanKinds = <String, String>{
  'home': 'Home loan',
  'car': 'Car loan',
  'personal': 'Personal loan',
  'education': 'Education loan',
  'gold': 'Gold loan',
  'other': 'Other loan',
};

enum PrepayMode {
  /// Keep the EMI, finish sooner.
  tenure,

  /// Keep the end date, lower the EMI.
  emi,
}

class Prepayment {
  const Prepayment(
    this.date,
    this.amountPaise, {
    this.mode = PrepayMode.tenure,
  });
  final DateTime date;
  final int amountPaise;
  final PrepayMode mode;
}

class LoanDef {
  const LoanDef({
    required this.id,
    required this.name,
    required this.kind,
    required this.principalPaise,
    required this.rateBp,
    required this.tenureMonths,
    required this.firstEmiDate,
    this.lender,
    this.emiPaise,
    this.prepayments = const [],
  });

  final int id;
  final String name;
  final String kind;
  final String? lender;
  final int principalPaise;
  final int rateBp;
  final int tenureMonths;
  final DateTime firstEmiDate;

  /// Lender's EMI, if entered; otherwise computed.
  final int? emiPaise;
  final List<Prepayment> prepayments;
}

/// One EMI (or prepayment) row of the schedule.
class LoanRow {
  const LoanRow({
    required this.date,
    required this.interestPaise,
    required this.principalPaise,
    required this.balancePaise,
    this.isPrepayment = false,
  });

  final DateTime date;
  final int interestPaise;
  final int principalPaise;

  /// Outstanding after this row.
  final int balancePaise;
  final bool isPrepayment;
}

class LoanStatus {
  const LoanStatus({
    required this.loan,
    required this.emiPaise,
    required this.outstandingPaise,
    required this.paidEmis,
    required this.remainingEmis,
    required this.interestRemainingPaise,
    required this.interestPaidPaise,
    this.payoffDate,
    this.nextEmiDate,
  });

  final LoanDef loan;

  /// Current EMI (after any EMI-reducing prepayment).
  final int emiPaise;
  final int outstandingPaise;
  final int paidEmis;
  final int remainingEmis;
  final int interestRemainingPaise;
  final int interestPaidPaise;
  final DateTime? payoffDate;
  final DateTime? nextEmiDate;

  double get fractionRepaid => loan.principalPaise <= 0
      ? 1
      : (1 - outstandingPaise / loan.principalPaise).clamp(0.0, 1.0);

  bool get isClosed => outstandingPaise <= 0;
}

/// Interest and principal paid in one financial year.
class LoanYear {
  const LoanYear(this.fy, this.interestPaise, this.principalPaise);
  final FinancialYear fy;
  final int interestPaise;
  final int principalPaise;
}

/// Pure amortisation maths (reducing balance, monthly rest).
class LoanCalculator {
  const LoanCalculator();

  static int emiFor(int principalPaise, int rateBp, int months) {
    if (months <= 0) return principalPaise;
    final r = rateBp / 10000 / 12;
    if (r == 0) return (principalPaise / months).ceil();
    final f = math.pow(1 + r, months);
    return (principalPaise * r * f / (f - 1)).round();
  }

  /// Full schedule: one row per EMI, plus prepayment rows.
  List<LoanRow> schedule(LoanDef l) {
    final r = l.rateBp / 10000 / 12;
    var emi = l.emiPaise ?? emiFor(l.principalPaise, l.rateBp, l.tenureMonths);
    var balance = l.principalPaise;
    final pre = [...l.prepayments]..sort((a, b) => a.date.compareTo(b.date));
    var pi = 0;
    final out = <LoanRow>[];
    for (var m = 0; balance > 0 && m < l.tenureMonths + 600; m++) {
      final date = DateTime(
        l.firstEmiDate.year,
        l.firstEmiDate.month + m,
        l.firstEmiDate.day,
      );
      // Prepayments made before this EMI.
      while (pi < pre.length && pre[pi].date.isBefore(date)) {
        final p = pre[pi++];
        final amt = math.min(p.amountPaise, balance);
        balance -= amt;
        out.add(
          LoanRow(
            date: p.date,
            interestPaise: 0,
            principalPaise: amt,
            balancePaise: balance,
            isPrepayment: true,
          ),
        );
        if (p.mode == PrepayMode.emi && balance > 0) {
          final left = l.tenureMonths - m;
          emi = emiFor(balance, l.rateBp, math.max(1, left));
        }
      }
      if (balance <= 0) break;
      final interest = (balance * r).round();
      var principal = emi - interest;
      if (principal <= 0) principal = 1; // EMI below interest: avoid looping
      // Rounding leaves a few paise: fold them into this EMI.
      if (principal > balance || balance - principal <= emi ~/ 100) {
        principal = balance;
      }
      balance -= principal;
      out.add(
        LoanRow(
          date: date,
          interestPaise: interest,
          principalPaise: principal,
          balancePaise: balance,
        ),
      );
    }
    return out;
  }

  LoanStatus status(LoanDef l, DateTime asOf) {
    final rows = schedule(l);
    final paid = [
      for (final r in rows)
        if (!r.date.isAfter(asOf)) r,
    ];
    final left = [
      for (final r in rows)
        if (r.date.isAfter(asOf)) r,
    ];
    final emis = rows.where((r) => !r.isPrepayment);
    final currentEmi =
        left
            .where((r) => !r.isPrepayment)
            .map((r) => r.interestPaise + r.principalPaise)
            .firstOrNull ??
        (emis.isEmpty ? 0 : emis.last.interestPaise + emis.last.principalPaise);
    return LoanStatus(
      loan: l,
      emiPaise: currentEmi,
      outstandingPaise: paid.isEmpty
          ? l.principalPaise
          : paid.last.balancePaise,
      paidEmis: paid.where((r) => !r.isPrepayment).length,
      remainingEmis: left.where((r) => !r.isPrepayment).length,
      interestRemainingPaise: left.fold(0, (s, r) => s + r.interestPaise),
      interestPaidPaise: paid.fold(0, (s, r) => s + r.interestPaise),
      payoffDate: rows.isEmpty ? null : rows.last.date,
      nextEmiDate: left.where((r) => !r.isPrepayment).firstOrNull?.date,
    );
  }

  /// Interest and principal paid in [fy] (EMIs and prepayments).
  LoanYear year(LoanDef l, FinancialYear fy) {
    var i = 0;
    var p = 0;
    for (final r in schedule(l)) {
      if (r.date.isBefore(fy.start) || !r.date.isBefore(fy.endExclusive)) {
        continue;
      }
      i += r.interestPaise;
      p += r.principalPaise;
    }
    return LoanYear(fy, i, p);
  }

  /// Effect of prepaying [amountPaise] on [date]: interest saved and EMIs
  /// saved (tenure mode) or the new EMI (EMI mode).
  ({int interestSavedPaise, int emisSaved, int newEmiPaise}) prepayEffect(
    LoanDef l,
    int amountPaise,
    DateTime date, {
    PrepayMode mode = PrepayMode.tenure,
  }) {
    final before = status(l, date);
    final with_ = LoanDef(
      id: l.id,
      name: l.name,
      kind: l.kind,
      lender: l.lender,
      principalPaise: l.principalPaise,
      rateBp: l.rateBp,
      tenureMonths: l.tenureMonths,
      firstEmiDate: l.firstEmiDate,
      emiPaise: l.emiPaise,
      prepayments: [
        ...l.prepayments,
        Prepayment(date, amountPaise, mode: mode),
      ],
    );
    // Evaluate just after the prepayment so it counts as "paid".
    final after = status(with_, date.add(const Duration(seconds: 1)));
    return (
      interestSavedPaise:
          before.interestRemainingPaise - after.interestRemainingPaise,
      emisSaved: before.remainingEmis - after.remainingEmis,
      newEmiPaise: after.emiPaise,
    );
  }
}

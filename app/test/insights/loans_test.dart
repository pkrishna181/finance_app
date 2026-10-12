import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

const calc = LoanCalculator();

LoanDef loan({List<Prepayment> pre = const [], int? emi}) => LoanDef(
      id: 1,
      name: 'Home loan',
      kind: 'home',
      principalPaise: 100000000, // ₹10 L
      rateBp: 900,
      tenureMonths: 120,
      firstEmiDate: DateTime(2025, 5, 5),
      emiPaise: emi,
      prepayments: pre,
    );

void main() {
  test('EMI formula', () {
    expect(LoanCalculator.emiFor(100000000, 900, 120), closeTo(1266758, 1));
    expect(LoanCalculator.emiFor(1200000, 0, 12), 100000);
  });

  test('schedule pays off in the tenure; interest falls, principal rises', () {
    final rows = calc.schedule(loan());
    expect(rows, hasLength(120));
    expect(rows.last.balancePaise, 0);
    expect(rows.first.interestPaise, 750000); // 0.75% of ₹10 L
    expect(rows[1].interestPaise, lessThan(rows[0].interestPaise));
    expect(rows.last.date, DateTime(2035, 4, 5));
  });

  test('status on a date', () {
    final s = calc.status(loan(), DateTime(2026, 10, 12));
    expect(s.paidEmis, 18); // May 2025 … Oct 2026
    expect(s.remainingEmis, 102);
    expect(s.nextEmiDate, DateTime(2026, 11, 5));
    // P(1+r)^18 − EMI·((1+r)^18 − 1)/r = ₹9,00,805
    expect(s.outstandingPaise, closeTo(90080500, 1000));
    expect(s.fractionRepaid, closeTo(1 - s.outstandingPaise / 100000000, 1e-9));
  });

  test('FY split of interest and principal', () {
    final y = calc.year(loan(), const FinancialYear(2025));
    // Apr 2025 – Mar 2026: EMIs May … Mar = 11.
    expect(y.interestPaise + y.principalPaise, closeTo(11 * 1266758, 20));
    expect(y.interestPaise, greaterThan(y.principalPaise));
  });

  test('prepayments: shorter tenure or lower EMI', () {
    final when = DateTime(2026, 10, 12);
    final t = calc.prepayEffect(loan(), 20000000, when);
    expect(t.interestSavedPaise, greaterThan(0));
    expect(t.emisSaved, greaterThan(20));
    expect(t.newEmiPaise, closeTo(1266758, 1));

    final e = calc.prepayEffect(loan(), 20000000, when, mode: PrepayMode.emi);
    expect(e.emisSaved, 0);
    expect(e.newEmiPaise, lessThan(1266758));
    expect(e.interestSavedPaise, greaterThan(0));
    expect(e.interestSavedPaise, lessThan(t.interestSavedPaise));

    // Recorded prepayment shows up in the schedule.
    final rows = calc.schedule(loan(pre: [Prepayment(when, 20000000)]));
    expect(rows.where((r) => r.isPrepayment).single.principalPaise, 20000000);
    expect(rows.last.balancePaise, 0);
  });

  test('lender EMI overrides the computed one', () {
    final s = calc.status(loan(emi: 1300000), DateTime(2025, 6, 1));
    expect(s.emiPaise, 1300000);
    expect(s.remainingEmis, lessThan(119));
  });

  test('repository, EMIs seen in the ledger, and net worth', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final repo = LoanRepository(db);
    final id = await repo.save(
      name: 'Home loan',
      kind: 'home',
      lender: 'SBI',
      principalPaise: 100000000,
      rateBp: 900,
      tenureMonths: 120,
      firstEmiDate: DateTime(2025, 5, 5),
    );
    await repo.addPrepayment(id, DateTime(2026, 1, 10), 5000000);
    expect((await repo.list()).single.prepayments, hasLength(1));
    for (final (i, d) in [DateTime(2026, 8, 5), DateTime(2026, 9, 5)].indexed) {
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 1266758,
            direction: 'debit',
            txnType: 'enach',
            bookedAt: d,
            bankCode: 'HDFC',
            rawMerchant: 'SBI HOME LOAN EMI',
            rawDescription: 'x',
            dedupeHash: 'e$i',
            accountHint: const Value('1234'),
          ));
    }
    final s = (await repo.statuses(DateTime(2026, 10, 12))).single;
    expect(await repo.emisSeen(s),
        [DateTime(2026, 9, 5), DateTime(2026, 8, 5)]);
    final nw = await NetWorthRepository(db).netWorth(DateTime(2026, 10, 12));
    expect(nw.byGroup[NetWorthGroup.loans], s.outstandingPaise);
    await repo.delete(id);
    expect(await repo.list(), isEmpty);
    expect(() => repo.save(
        name: 'x', kind: 'boat', principalPaise: 1, rateBp: 1,
        tenureMonths: 1, firstEmiDate: DateTime(2026)), throwsArgumentError);
  });
}

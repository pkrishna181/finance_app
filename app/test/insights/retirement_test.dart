import 'dart:math' as math;

import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

const calc = RetirementCalculator();

void main() {
  test('SWR corpus: ₹50k/month, 30 → 60, 6% inflation, 4% SWR', () {
    final r = calc.plan(
      const RetirementInputs(
        currentAge: 30,
        retireAge: 60,
        monthlyExpensePaise: 5000000,
        swr: 0.04,
      ),
      currentCorpusPaise: 0,
    );
    final yearly = 600000 * math.pow(1.06, 30); // ₹ at 60
    expect(r.annualExpenseAtRetirePaise / 100, closeTo(yearly, 1));
    expect(r.corpusNeededPaise / 100, closeTo(yearly / 0.04, 25));
    // Today's rupees: 6 L / 4% = 1.5 Cr.
    expect(r.corpusNeededTodayPaise / 100, closeTo(15000000, 1));
  });

  test('monthly saving grows exactly to the gap', () {
    final r = calc.plan(
      const RetirementInputs(
        currentAge: 40,
        retireAge: 50,
        monthlyExpensePaise: 5000000,
        swr: 0.04,
        returnPre: 0.12,
      ),
      currentCorpusPaise: 100000000, // ₹10 L
    );
    expect(r.projectedCorpusPaise,
        closeTo(100000000 * math.pow(1.12, 10), 1));
    final m = math.pow(1.12, 1 / 12) - 1;
    final fv = r.monthlySavingNeededPaise *
        (math.pow(1 + m, 120) - 1) / m;
    expect(fv, closeTo(r.gapPaise, r.monthlySavingNeededPaise));
    expect(r.fundedFraction, lessThan(1));
  });

  test('life-expectancy corpus: equal return and inflation = years × expense',
      () {
    final r = calc.plan(
      const RetirementInputs(
        currentAge: 60,
        retireAge: 60,
        lifeExpectancy: 85,
        monthlyExpensePaise: 100000,
        inflation: 0.06,
        returnPost: 0.06,
      ),
      currentCorpusPaise: 0,
    );
    expect(r.corpusNeededPaise, 25 * 1200000);
    expect(r.monthlySavingNeededPaise, r.corpusNeededPaise); // retiring now
  });

  test('already funded: nothing more needed; on-track flag', () {
    final r = calc.plan(
      const RetirementInputs(
        currentAge: 50,
        retireAge: 55,
        monthlyExpensePaise: 100000,
        swr: 0.04,
      ),
      currentCorpusPaise: 1000000000,
      recentMonthlySavingPaise: 0,
    );
    expect(r.gapPaise, 0);
    expect(r.monthlySavingNeededPaise, 0);
    expect(r.fundedFraction, 1);
    expect(r.onTrack, isTrue);
  });

  test('repository: needs a plan and expenses; validates ages', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final repo = RetirementRepository(db);
    expect(await repo.result(DateTime(2026, 10, 12)), isNull);
    expect(() => repo.save(currentAge: 40, retireAge: 30), throwsArgumentError);
    await repo.save(
        currentAge: 35, retireAge: 55, monthlyExpensePaise: 6000000, swrBp: 350);
    await NetWorthRepository(db).saveAsset(
        name: 'EPF', kind: 'epf', valuePaise: 50000000,
        valueDate: DateTime(2026, 1, 1));
    final r = (await repo.result(DateTime(2026, 10, 12)))!;
    expect(r.currentCorpusPaise, 50000000); // EPF is debt → counted
    expect(r.inputs.swr, 0.035);
    expect(r.recentMonthlySavingPaise, isNull); // no ledger yet
    expect(r.onTrack, isNull);
  });
}

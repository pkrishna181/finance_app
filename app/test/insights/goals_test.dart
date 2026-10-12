import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalCalculator', () {
    const calc = GoalCalculator();
    final asOf = DateTime(2026, 10, 12);

    test('requiredMonthly without and with returns', () {
      // ₹1,20,000 more in 12 months at 0% → ₹10,000/month.
      expect(GoalCalculator.requiredMonthly(0, 12000000, 12, 0), 1000000);
      // With 12%/yr (1%/month) less is needed: PMT = 1.2L·0.01/(1.01^12−1).
      expect(GoalCalculator.requiredMonthly(0, 12000000, 12, 0.01),
          946186);
      // Existing money growing past the target → nothing needed.
      expect(GoalCalculator.requiredMonthly(12000000, 12000000, 6, 0.01), 0);
    });

    test('monthsToReach', () {
      expect(GoalCalculator.monthsToReach(0, 300000, 100000, 0), 3);
      expect(GoalCalculator.monthsToReach(0, 300000, 0, 0), isNull);
    });

    test('manual goal on track vs behind, projected date', () {
      final g = GoalDef(
        id: 1,
        name: 'Trip',
        targetPaise: 10000000, // ₹1,00,000
        startDate: DateTime(2026, 1, 1),
        targetDate: DateTime(2027, 4, 1), // 6 months away
        startPaise: 4000000,
      );
      final flows = [
        GoalFlow(DateTime(2026, 8, 1), 1000000),
        GoalFlow(DateTime(2026, 9, 1), 1000000),
        GoalFlow(DateTime(2026, 10, 1), 1000000),
      ];
      final p = calc.progress(g, asOf: asOf, flows: flows);
      expect(p.currentPaise, 7000000);
      expect(p.monthsLeft, 6);
      expect(p.requiredMonthlyPaise, 500000);
      expect(p.recentMonthlyPaise, 1000000);
      expect(p.state, GoalState.onTrack);
      expect(p.projectedDate, DateTime(2027, 1, 12)); // 3 more months
      expect(p.fraction, 0.7);

      final slow = calc.progress(g,
          asOf: asOf, flows: [GoalFlow(DateTime(2026, 9, 1), 300000)]);
      expect(slow.state, GoalState.behind);
    });

    test('reached and no-deadline states', () {
      final g = GoalDef(
        id: 1,
        name: 'x',
        targetPaise: 100,
        startDate: DateTime(2026),
        startPaise: 150,
      );
      expect(calc.progress(g, asOf: asOf).state, GoalState.reached);
      expect(calc.progress(g, asOf: asOf).remainingPaise, 0);
      final open = GoalDef(
          id: 2, name: 'y', targetPaise: 1000, startDate: DateTime(2026));
      expect(calc.progress(open, asOf: asOf).state, GoalState.noDeadline);
    });

    test('account goal uses balance and its 3-month growth', () {
      final g = GoalDef(
        id: 1,
        name: 'Emergency fund',
        targetPaise: 30000000,
        startDate: DateTime(2026),
        targetDate: DateTime(2027, 10, 1),
        source: GoalSource.account,
        sourceRef: 'HDFC|1234',
      );
      final p = calc.progress(g,
          asOf: asOf,
          accountBalancePaise: 18000000,
          accountBalance3MonthsAgoPaise: 15000000);
      expect(p.currentPaise, 18000000);
      expect(p.recentMonthlyPaise, 1000000);
      expect(p.requiredMonthlyPaise, 1000000); // ₹1.2L over 12 months
      expect(p.state, GoalState.onTrack);
    });
  });

  group('GoalRepository', () {
    late ArthDatabase db;
    late GoalRepository repo;
    setUp(() {
      db = ArthDatabase.memory();
      repo = GoalRepository(db);
    });
    tearDown(() => db.close());

    Future<void> txn(String h, int paise, DateTime at,
        {String? cat, int? bal, String dir = 'debit'}) async {
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amountPaise: paise,
            direction: dir,
            txnType: 'neft',
            bookedAt: at,
            bankCode: 'HDFC',
            accountHint: const Value('1234'),
            rawMerchant: 'X',
            rawDescription: 'X',
            dedupeHash: h,
            balanceAfterPaise: Value(bal),
            categoryId: Value(
                cat == null ? null : (await db.categoryBySlug(cat))!.id),
          ));
    }

    test('manual: save, contributions, progress, delete', () async {
      final id = await repo.save(
        name: 'Trip',
        targetPaise: 5000000,
        startPaise: 100000,
        annualReturnPct: 7.25,
      );
      final g = (await repo.list()).single;
      expect(g.annualReturnPct, 7.25);
      expect(g.source, GoalSource.manual);
      await repo.addContribution(id, 200000, DateTime(2026, 10, 1));
      final p = await repo.progressOf(g, DateTime(2026, 10, 12));
      expect(p.currentPaise, 300000);
      await repo.delete(id);
      expect(await repo.list(), isEmpty);
    });

    test('category: SIP debits since start, net of redemptions', () async {
      await txn('a', 500000, DateTime(2026, 6, 5), cat: 'investments_sip');
      await txn('b', 500000, DateTime(2026, 8, 5), cat: 'investments_sip');
      await txn('c', 100000, DateTime(2026, 9, 5),
          cat: 'investments_sip', dir: 'credit');
      await txn('d', 999900, DateTime(2026, 8, 6), cat: 'shopping');
      await repo.save(
        name: 'Retirement',
        targetPaise: 100000000,
        startDate: DateTime(2026, 7, 1),
        source: GoalSource.category,
        sourceRef: 'investments_sip',
      );
      final p = await repo.progressOf(
          (await repo.list()).single, DateTime(2026, 10, 12));
      expect(p.currentPaise, 400000);
    });

    test('account: latest balance, and listed for linking', () async {
      await txn('a', 1, DateTime(2026, 6, 30), bal: 15000000);
      await txn('b', 1, DateTime(2026, 10, 1), bal: 18000000);
      final accounts = await repo.balanceAccounts();
      expect(accounts.single.ref, 'HDFC|1234');
      expect(accounts.single.balancePaise, 18000000);
      await repo.save(
        name: 'EF',
        targetPaise: 30000000,
        source: GoalSource.account,
        sourceRef: 'HDFC|1234',
      );
      final p = await repo.progressOf(
          (await repo.list()).single, DateTime(2026, 10, 12));
      expect(p.currentPaise, 18000000);
      expect(p.recentMonthlyPaise, 1000000);
    });

    test('validation', () async {
      expect(() => repo.save(name: 'x', targetPaise: 0), throwsArgumentError);
      expect(
        () => repo.save(
            name: 'x', targetPaise: 1, source: GoalSource.account),
        throwsArgumentError,
      );
    });
  });
}

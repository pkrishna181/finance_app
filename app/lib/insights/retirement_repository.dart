import 'package:drift/drift.dart';

import '../core/db/database.dart';
import 'allocation.dart';
import 'allocation_repository.dart';
import 'insight_models.dart';
import 'insights_repository.dart';
import 'retirement.dart';

class RetirementRepository {
  RetirementRepository(this._db);

  final ArthDatabase _db;

  Future<RetirementPlan?> row() => (_db.select(
    _db.retirementPlans,
  )..where((p) => p.id.equals(1))).getSingleOrNull();

  Future<void> save({
    required int currentAge,
    required int retireAge,
    int lifeExpectancy = 85,
    int? monthlyExpensePaise,
    int inflationBp = 600,
    int returnPreBp = 1000,
    int returnPostBp = 700,
    int? swrBp,
    Set<AssetClass> classes = const {
      AssetClass.equity,
      AssetClass.debt,
      AssetClass.gold,
      AssetClass.other,
    },
  }) async {
    if (currentAge <= 0 ||
        retireAge < currentAge ||
        lifeExpectancy <= retireAge) {
      throw ArgumentError('ages must satisfy now ≤ retire < life expectancy');
    }
    await _db
        .into(_db.retirementPlans)
        .insertOnConflictUpdate(
          RetirementPlansCompanion.insert(
            id: const Value(1),
            currentAge: currentAge,
            retireAge: retireAge,
            lifeExpectancy: Value(lifeExpectancy),
            monthlyExpensePaise: Value(monthlyExpensePaise),
            inflationBp: Value(inflationBp),
            returnPreBp: Value(returnPreBp),
            returnPostBp: Value(returnPostBp),
            swrBp: Value(swrBp),
            classes: Value(classes.map((c) => c.name).join(',')),
          ),
        );
  }

  /// Average monthly spend and income − spend over the last [months] full
  /// months that have data (null when there is none).
  Future<({int spend, int saving})?> recentAverages(
    DateTime asOf, {
    int months = 12,
  }) async {
    final last = MonthKey.of(asOf).plusMonths(-1);
    final agg = await InsightsRepository(
      _db,
    ).aggregatorFor(last, months: months);
    var spend = 0;
    var saving = 0;
    var seen = 0;
    for (var i = 0; i < months; i++) {
      final s = agg.summarize(last.plusMonths(-i));
      if (s.txnCount == 0) continue;
      seen++;
      spend += s.spendPaise;
      saving += s.incomePaise - s.spendPaise;
    }
    if (seen == 0) return null;
    return (spend: spend ~/ seen, saving: saving ~/ seen);
  }

  /// The plan with today's corpus and recent savings, or null if not set up.
  Future<RetirementPlanResult?> result(DateTime asOf) async {
    final p = await row();
    if (p == null) return null;
    final avg = await recentAverages(asOf);
    final expense = p.monthlyExpensePaise ?? avg?.spend;
    if (expense == null) return null;
    final classes = {
      for (final c in p.classes.split(','))
        if (c.isNotEmpty) AssetClass.values.byName(c),
    };
    final values = await AllocationRepository(_db).values(asOf);
    final corpus = classes.fold<int>(0, (s, c) => s + (values[c] ?? 0));
    return const RetirementCalculator().plan(
      RetirementInputs(
        currentAge: p.currentAge,
        retireAge: p.retireAge,
        lifeExpectancy: p.lifeExpectancy,
        monthlyExpensePaise: expense,
        inflation: p.inflationBp / 10000,
        returnPre: p.returnPreBp / 10000,
        returnPost: p.returnPostBp / 10000,
        swr: p.swrBp == null ? null : p.swrBp! / 10000,
        classes: classes,
      ),
      currentCorpusPaise: corpus,
      recentMonthlySavingPaise: avg?.saving,
    );
  }
}

import '../core/db/database.dart';
import 'allocation.dart';
import 'capital_gains_repository.dart';
import 'goal_repository.dart';
import 'net_worth_repository.dart';
import 'portfolio_repository.dart';

class AllocationRepository {
  AllocationRepository(this._db);

  final ArthDatabase _db;

  Future<Map<AssetClass, int>> targets() async => {
        for (final r in await _db.select(_db.allocationTargets).get())
          AssetClass.values.byName(r.bucket): r.targetBp,
      };

  /// Replaces all targets; they must add up to 100%.
  Future<void> setTargets(Map<AssetClass, int> bp) async {
    final sum = bp.values.fold<int>(0, (s, v) => s + v);
    if (bp.isNotEmpty && sum != 10000) {
      throw ArgumentError.value(sum, 'targets', 'must add up to 100%');
    }
    await _db.transaction(() async {
      await _db.delete(_db.allocationTargets).go();
      for (final e in bp.entries) {
        if (e.value <= 0) continue;
        await _db.into(_db.allocationTargets).insert(
              AllocationTargetsCompanion.insert(
                bucket: e.key.name,
                targetBp: e.value,
              ),
            );
      }
    });
  }

  /// Current value by asset class (liabilities and vehicles excluded).
  Future<Map<AssetClass, int>> values(DateTime on) async {
    final m = <AssetClass, int>{};
    void add(AssetClass c, int v) => m[c] = (m[c] ?? 0) + v;

    final goals = GoalRepository(_db);
    for (final a in await goals.balanceAccounts()) {
      final b = await goals.balanceAt(a.ref, on);
      if (b != null && b > 0) add(AssetClass.cash, b);
    }
    final cats = await CapitalGainsRepository(_db).categories();
    final portfolio = await PortfolioRepository(_db).summary(on);
    for (final p in portfolio.positions) {
      final tax = cats[p.input.securityId]?.category;
      if (tax == null) continue;
      add(assetClassOfSecurity(p.input.name, p.input.kind, tax), p.valuePaise);
    }
    for (final a in await NetWorthRepository(_db).assets(on)) {
      final c = assetClassOfManual(a.kind);
      if (c != null) add(c, a.currentPaise);
    }
    return m;
  }

  Future<Allocation> allocation(DateTime on) async =>
      Allocation.build(await values(on), await targets());
}

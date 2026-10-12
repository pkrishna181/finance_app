import 'package:drift/drift.dart';

import '../core/db/database.dart';
import 'capital_gains.dart';
import 'portfolio_repository.dart';
import 'tax_harvest.dart';
import 'yearly.dart';

/// A fund / share with its tax category (guessed or chosen).
class TaxCategoryView {
  const TaxCategoryView({
    required this.securityId,
    required this.name,
    required this.category,
    required this.isOverride,
  });

  final int securityId;
  final String name;
  final TaxCategory category;
  final bool isOverride;
}

class CapitalGainsRepository {
  CapitalGainsRepository(this._db);

  final ArthDatabase _db;

  Future<Map<int, TaxCategoryView>> categories() async {
    final rows = await _db.select(_db.securities).get();
    return {
      for (final s in rows)
        s.id: TaxCategoryView(
          securityId: s.id,
          name: s.name,
          category: s.taxCategory == null
              ? guessTaxCategory(s.name, s.kind)
              : TaxCategory.values.byName(s.taxCategory!),
          isOverride: s.taxCategory != null,
        ),
    };
  }

  /// [category] null = back to the guess from the name.
  Future<void> setCategory(int securityId, TaxCategory? category) =>
      (_db.update(_db.securities)..where((s) => s.id.equals(securityId)))
          .write(SecuritiesCompanion(taxCategory: Value(category?.name)));

  Future<List<GainsInput>> inputs(DateTime asOf) async {
    final cats = await categories();
    final fmv = await _fmv2018();
    return [
      for (final p in await PortfolioRepository(_db).inputs(asOf))
        if (p.txns.isNotEmpty)
          GainsInput(
            name: p.name,
            category: cats[p.securityId]!.category,
            txns: p.txns,
            fmv2018E4: fmv[p.securityId],
          ),
    ];
  }

  /// Harvesting ideas for the financial year containing [asOf].
  Future<List<HarvestIdea>> harvestIdeas(DateTime asOf) async {
    final cats = await categories();
    final fmv = await _fmv2018();
    final positions = await PortfolioRepository(_db).inputs(asOf);
    final holdings = <HarvestInput>[];
    for (final p in positions) {
      if (p.txns.isEmpty || p.priceE4 == null) continue;
      holdings.add(HarvestInput(
        gains: GainsInput(
          name: p.name,
          category: cats[p.securityId]!.category,
          txns: p.txns,
          fmv2018E4: fmv[p.securityId],
        ),
        accountLabel: p.accountLabel,
        priceE4: p.priceE4!,
      ));
    }
    final fy = FinancialYear.of(asOf);
    final booked = (await byYear(asOf)).where((y) => y.fy == fy).firstOrNull ??
        FyGains(fy);
    return const TaxHarvester().ideas(holdings, booked, asOf: asOf);
  }

  /// Prices on 31 Jan 2018 (grandfathering), by security.
  Future<Map<int, int>> _fmv2018() async {
    final rows = await (_db.select(_db.securityPrices)
          ..where((p) => p.date.equals(DateTime(2018, 1, 31))))
        .get();
    return {for (final r in rows) r.securityId: r.priceE4};
  }

  Future<List<FyGains>> byYear(DateTime asOf) async =>
      const CapitalGainsCalculator().byYear(await inputs(asOf));
}

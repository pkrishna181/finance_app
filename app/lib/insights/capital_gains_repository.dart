import 'package:drift/drift.dart';

import '../core/db/database.dart';
import 'capital_gains.dart';
import 'portfolio_repository.dart';

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
    final fmv = <int, int>{};
    final rows = await (_db.select(_db.securityPrices)
          ..where((p) => p.date.equals(DateTime(2018, 1, 31))))
        .get();
    for (final r in rows) {
      fmv[r.securityId] = r.priceE4;
    }
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

  Future<List<FyGains>> byYear(DateTime asOf) async =>
      const CapitalGainsCalculator().byYear(await inputs(asOf));
}

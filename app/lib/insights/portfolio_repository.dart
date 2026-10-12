import 'package:drift/drift.dart' show OrderingTerm, Variable;

import '../core/db/database.dart';
import 'portfolio.dart';

/// Builds [PositionInput]s from the holdings tables.
class PortfolioRepository {
  PortfolioRepository(this._db);

  final ArthDatabase _db;

  Future<List<PositionInput>> inputs(DateTime asOf) async {
    final accounts = {
      for (final a in await _db.select(_db.investmentAccounts).get()) a.id: a,
    };
    final securities = {
      for (final s in await _db.select(_db.securities).get()) s.id: s,
    };

    final txns = <(int, int), List<PositionTxn>>{};
    for (final t in await _db.select(_db.investmentTxns).get()) {
      txns
          .putIfAbsent((t.accountId, t.securityId), () => [])
          .add(
            PositionTxn(
              date: t.date,
              type: t.type,
              amountPaise: t.amountPaise,
              unitsE4: t.unitsE4,
            ),
          );
    }

    // Latest snapshot per account + security on or before asOf.
    final snaps = <(int, int), HoldingSnapshot>{};
    for (final s in await _db.select(_db.holdingSnapshots).get()) {
      if (s.asOf.isAfter(asOf)) continue;
      final k = (s.accountId, s.securityId);
      final cur = snaps[k];
      if (cur == null || s.asOf.isAfter(cur.asOf)) snaps[k] = s;
    }

    // Latest price per security on or before asOf.
    final prices = <int, (DateTime, int)>{};
    final rows = await _db
        .customSelect(
          'SELECT p.security_id AS s, p.date AS d, p.price_e4 AS v '
          'FROM security_prices p WHERE p.date <= ? AND p.date = '
          '(SELECT MAX(p2.date) FROM security_prices p2 '
          ' WHERE p2.security_id = p.security_id AND p2.date <= ?)',
          variables: [Variable<DateTime>(asOf), Variable<DateTime>(asOf)],
          readsFrom: {_db.securityPrices},
        )
        .get();
    for (final r in rows) {
      prices[r.read<int>('s')] = (r.read<DateTime>('d'), r.read<int>('v'));
    }

    final keys = {...txns.keys, ...snaps.keys};
    return [
      for (final k in keys)
        if (accounts[k.$1] != null && securities[k.$2] != null)
          PositionInput(
            accountId: k.$1,
            securityId: k.$2,
            name: securities[k.$2]!.name,
            kind: securities[k.$2]!.kind,
            isin: securities[k.$2]!.isin.startsWith('NOISIN:')
                ? null
                : securities[k.$2]!.isin,
            amc: securities[k.$2]!.amc ?? accounts[k.$1]!.amc,
            accountLabel: _label(accounts[k.$1]!),
            txns: txns[k] ?? const [],
            snapshotDate: snaps[k]?.asOf,
            snapshotUnitsE4: snaps[k]?.unitsE4,
            snapshotCostPaise: snaps[k]?.costPaise,
            priceDate: prices[k.$2]?.$1 ?? snaps[k]?.asOf,
            priceE4: prices[k.$2]?.$2 ?? snaps[k]?.priceE4,
          ),
    ];
  }

  static String _label(InvestmentAccount a) =>
      a.kind == 'folio' ? 'Folio ${a.number}' : '${a.provider} ${a.number}';

  Future<PortfolioSummary> summary(DateTime asOf) async =>
      const PortfolioCalculator().summarize(await inputs(asOf), asOf);

  /// Transactions of one position, newest first (for the detail view).
  Future<List<InvestmentTxn>> txnsOf(int accountId, int securityId) =>
      (_db.select(_db.investmentTxns)
            ..where((t) => t.accountId.equals(accountId))
            ..where((t) => t.securityId.equals(securityId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();
}

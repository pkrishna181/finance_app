import 'package:drift/drift.dart';

import '../core/db/database.dart';
import 'credit_card_repository.dart';
import 'goal_repository.dart';
import 'loan_repository.dart';
import 'net_worth.dart';
import 'portfolio_repository.dart';

/// A manual asset / loan with its latest value.
class ManualAssetView {
  const ManualAssetView({
    required this.id,
    required this.name,
    required this.kind,
    required this.recordedPaise,
    required this.recordedOn,
    required this.currentPaise,
    this.interestBp,
    this.startDate,
    this.maturityDate,
  });

  final int id;
  final String name;
  final String kind;

  /// Last value the user entered, and when.
  final int recordedPaise;
  final DateTime recordedOn;

  /// Value today (FDs grow from the recorded value).
  final int currentPaise;
  final int? interestBp;
  final DateTime? startDate;
  final DateTime? maturityDate;
}

class NetWorthRepository {
  NetWorthRepository(this._db);

  final ArthDatabase _db;

  // --- manual assets ---

  Future<int> saveAsset({
    int? id,
    required String name,
    required String kind,
    required int valuePaise,
    DateTime? valueDate,
    int? interestBp,
    DateTime? startDate,
    DateTime? maturityDate,
  }) async {
    if (!kAssetKinds.containsKey(kind)) {
      throw ArgumentError.value(kind, 'kind', 'unknown');
    }
    if (valuePaise < 0) {
      throw ArgumentError.value(valuePaise, 'valuePaise', 'must be ≥ 0');
    }
    final now = DateTime.now();
    final day = valueDate ?? DateTime(now.year, now.month, now.day);
    return _db.transaction(() async {
      final row = ManualAssetsCompanion(
        name: Value(name.trim()),
        kind: Value(kind),
        interestBp: Value(kind == 'fd' ? interestBp : null),
        startDate: Value(kind == 'fd' ? (startDate ?? day) : null),
        maturityDate: Value(kind == 'fd' ? maturityDate : null),
      );
      final assetId = id ?? await _db.into(_db.manualAssets).insert(row);
      if (id != null) {
        await (_db.update(
          _db.manualAssets,
        )..where((a) => a.id.equals(id))).write(row);
      }
      await _db
          .into(_db.manualAssetValues)
          .insert(
            ManualAssetValuesCompanion.insert(
              assetId: assetId,
              date: DateTime(day.year, day.month, day.day),
              valuePaise: valuePaise,
            ),
            onConflict: DoUpdate(
              (_) => ManualAssetValuesCompanion(valuePaise: Value(valuePaise)),
              target: [
                _db.manualAssetValues.assetId,
                _db.manualAssetValues.date,
              ],
            ),
          );
      return assetId;
    });
  }

  Future<void> deleteAsset(int id) => _db.transaction(() async {
    await (_db.delete(
      _db.manualAssetValues,
    )..where((v) => v.assetId.equals(id))).go();
    await (_db.delete(_db.manualAssets)..where((a) => a.id.equals(id))).go();
  });

  /// Manual assets with their value on [on] (latest entry on or before it).
  Future<List<ManualAssetView>> assets(DateTime on) async {
    final assets = await _db.select(_db.manualAssets).get();
    final values = await (_db.select(
      _db.manualAssetValues,
    )..orderBy([(v) => OrderingTerm.asc(v.date)])).get();
    final out = <ManualAssetView>[];
    for (final a in assets) {
      ManualAssetValue? last;
      for (final v in values) {
        if (v.assetId == a.id && !v.date.isAfter(on)) last = v;
      }
      if (last == null) continue;
      final current = a.kind == 'fd' && a.interestBp != null
          ? fdValue(
              last.valuePaise,
              a.interestBp!,
              last.date,
              on,
              maturity: a.maturityDate,
            )
          : last.valuePaise;
      out.add(
        ManualAssetView(
          id: a.id,
          name: a.name,
          kind: a.kind,
          recordedPaise: last.valuePaise,
          recordedOn: last.date,
          currentPaise: current,
          interestBp: a.interestBp,
          startDate: a.startDate,
          maturityDate: a.maturityDate,
        ),
      );
    }
    out.sort((x, y) => y.currentPaise.compareTo(x.currentPaise));
    return out;
  }

  // --- net worth ---

  /// Net worth on [on]. Credit cards are included only for today's value
  /// ([includeCards]); history leaves them out.
  Future<NetWorth> netWorth(DateTime on, {bool includeCards = true}) async {
    final items = <NetWorthItem>[];
    final goals = GoalRepository(_db);
    for (final a in await goals.balanceAccounts()) {
      final bal = await goals.balanceAt(a.ref, on);
      if (bal == null) continue;
      items.add(
        NetWorthItem(
          group: NetWorthGroup.bank,
          label: '${a.bankCode} ••${a.last4}',
          valuePaise: bal < 0 ? 0 : bal,
          asOf: await _balanceDate(a.bankCode, a.last4, on),
        ),
      );
    }
    final portfolio = await PortfolioRepository(_db).summary(on);
    for (final p in portfolio.positions) {
      items.add(
        NetWorthItem(
          group: NetWorthGroup.investments,
          label: p.input.name,
          valuePaise: p.valuePaise,
          asOf: p.input.priceDate,
        ),
      );
    }
    for (final a in await assets(on)) {
      items.add(
        NetWorthItem(
          group: isLiabilityKind(a.kind)
              ? NetWorthGroup.loans
              : NetWorthGroup.assets,
          label: a.name,
          valuePaise: a.currentPaise,
          asOf: a.recordedOn,
          assetId: a.id,
        ),
      );
    }
    for (final l in await LoanRepository(_db).statuses(on)) {
      if (l.outstandingPaise <= 0 || l.loan.firstEmiDate.isAfter(on)) continue;
      items.add(NetWorthItem(
        group: NetWorthGroup.loans,
        label: l.loan.name,
        valuePaise: l.outstandingPaise,
        asOf: on,
      ));
    }
    if (includeCards) {
      for (final c in await CreditCardRepository(_db).statuses(on)) {
        if (c.outstandingPaise <= 0) continue;
        items.add(
          NetWorthItem(
            group: NetWorthGroup.cards,
            label:
                '${c.card.name}${c.card.last4 == null ? '' : ' ••${c.card.last4}'}',
            valuePaise: c.outstandingPaise,
            asOf: on,
          ),
        );
      }
    }
    return NetWorth(items);
  }

  Future<DateTime?> _balanceDate(String bank, String last4, DateTime on) async {
    final row =
        await (_db.select(_db.transactions)
              ..where((t) => t.bankCode.equals(bank))
              ..where((t) => t.accountHint.equals(last4))
              ..where((t) => t.balanceAfterPaise.isNotNull())
              ..where((t) => t.bookedAt.isSmallerOrEqualValue(on))
              ..orderBy([(t) => OrderingTerm.desc(t.bookedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.bookedAt;
  }

  /// Month-end net worth for the last [months] months (the current month
  /// valued today), oldest first. Credit cards excluded.
  Future<List<NetWorthPoint>> history(DateTime today, {int months = 12}) async {
    final out = <NetWorthPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final end = i == 0
          ? today
          : DateTime(today.year, today.month - i + 1, 0, 23, 59);
      final nw = await netWorth(end, includeCards: false);
      out.add(NetWorthPoint(end, nw.totalPaise));
    }
    // Drop leading months before any data.
    while (out.isNotEmpty && out.first.paise == 0) {
      out.removeAt(0);
    }
    return out;
  }
}

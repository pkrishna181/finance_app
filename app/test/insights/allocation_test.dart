import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('asset class mapping', () {
    expect(assetClassOfSecurity('Infosys', 'equity', TaxCategory.equity),
        AssetClass.equity);
    expect(assetClassOfSecurity('Nippon Gold Savings Fund', 'mf',
        TaxCategory.other), AssetClass.gold);
    expect(assetClassOfSecurity('Motilal Oswal Nasdaq 100 FOF', 'mf',
        TaxCategory.other), AssetClass.equity);
    expect(assetClassOfSecurity('ICICI Multi Asset Fund', 'mf',
        TaxCategory.other), AssetClass.other);
    expect(assetClassOfSecurity('Liquid Fund', 'mf', TaxCategory.debt),
        AssetClass.debt);
    expect(assetClassOfManual('ppf'), AssetClass.debt);
    expect(assetClassOfManual('property'), AssetClass.realEstate);
    expect(assetClassOfManual('vehicle'), isNull);
    expect(assetClassOfManual('loan'), isNull);
  });

  test('drift and rebalance over planned classes only', () {
    final a = Allocation.build(
      {
        AssetClass.equity: 7000000,
        AssetClass.debt: 2000000,
        AssetClass.gold: 1000000,
        AssetClass.realEstate: 50000000, // not in plan
      },
      {AssetClass.equity: 6000, AssetClass.debt: 3000, AssetClass.gold: 1000},
    );
    expect(a.plannedTotalPaise, 10000000);
    final eq = a.rows.firstWhere((r) => r.assetClass == AssetClass.equity);
    expect(eq.currentFraction, 0.7);
    expect(eq.driftPoints, closeTo(10, 1e-9));
    expect(eq.rebalancePaise, -1000000);
    final debt = a.rows.firstWhere((r) => r.assetClass == AssetClass.debt);
    expect(debt.rebalancePaise, 1000000);
    final re = a.rows.firstWhere((r) => r.assetClass == AssetClass.realEstate);
    expect(re.inPlan, isFalse);
    expect(a.needsRebalance, isTrue);
    expect(a.maxDriftPoints, closeTo(10, 1e-9));
  });

  test('repository: targets must add to 100; values from all sources',
      () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final repo = AllocationRepository(db);
    expect(() => repo.setTargets({AssetClass.equity: 5000}), throwsArgumentError);
    await repo.setTargets({AssetClass.equity: 7000, AssetClass.debt: 3000});
    expect(await repo.targets(),
        {AssetClass.equity: 7000, AssetClass.debt: 3000});

    for (final (i, d) in [DateTime(2026, 9, 1), DateTime(2026, 9, 2)].indexed) {
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 1,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: d,
            bankCode: 'HDFC',
            rawMerchant: 'X',
            rawDescription: 'X',
            dedupeHash: 'b$i',
            accountHint: const Value('1234'),
            balanceAfterPaise: const Value(5000000),
          ));
    }
    final f = ['../test/golden/cas', 'test/golden/cas']
        .map((d) => File('$d/cams_detailed.txt'))
        .firstWhere((f) => f.existsSync());
    await CasImporter(db).store(const CasParser().parse(f.readAsLinesSync()),
        fileName: 'x', contentHash: 'x');
    await NetWorthRepository(db)
        .saveAsset(name: 'PPF', kind: 'ppf', valuePaise: 30000000, valueDate: DateTime(2026, 9, 1));
    await NetWorthRepository(db)
        .saveAsset(name: 'Car', kind: 'vehicle', valuePaise: 99900000, valueDate: DateTime(2026, 9, 1));

    final v = await repo.values(DateTime(2026, 9, 30));
    expect(v[AssetClass.cash], 5000000);
    // HDFC Flexi + Mirae ELSS are equity; the liquid fund is debt.
    expect(v[AssetClass.equity], closeTo(2722649 + 1105662, 300));
    expect(v[AssetClass.debt], closeTo(2537276 + 30000000, 300));
    expect(v.containsKey(AssetClass.realEstate), isFalse);

    await repo.setTargets({});
    expect(await repo.targets(), isEmpty);
  });
}

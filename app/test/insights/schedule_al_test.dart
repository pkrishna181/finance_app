import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual kinds map to sections', () {
    expect(alSectionOfManual('property'), AlSection.immovable);
    expect(alSectionOfManual('gold'), AlSection.jewellery);
    expect(alSectionOfManual('vehicle'), AlSection.vehicles);
    expect(alSectionOfManual('ppf'), AlSection.bank);
    expect(alSectionOfManual('nps'), AlSection.securities);
    expect(alSectionOfManual('loan'), AlSection.liabilities);
    expect(alSectionOfManual('other'), AlSection.unmapped);
  });

  test('builds FY 2025-26 as on 31 Mar 2026', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    // Bank: balance on 28 Mar counts; April's doesn't.
    for (final (i, d, b) in [
      (0, DateTime(2026, 3, 20), 400000000),
      (1, DateTime(2026, 3, 28), 450000000),
      (2, DateTime(2026, 4, 2), 999999999),
    ]) {
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
            balanceAfterPaise: Value(b),
          ));
    }
    final f = ['../test/golden/cas', 'test/golden/cas']
        .map((d) => File('$d/cams_detailed.txt'))
        .firstWhere((f) => f.existsSync());
    await CasImporter(db).store(const CasParser().parse(f.readAsLinesSync()),
        fileName: 'x', contentHash: 'x');
    final nw = NetWorthRepository(db);
    final d = DateTime(2025, 6, 1);
    await nw.saveAsset(name: 'Flat', kind: 'property', valuePaise: 800000000, valueDate: d);
    await nw.saveAsset(name: 'Gold coins', kind: 'gold', valuePaise: 30000000, valueDate: d);
    await nw.saveAsset(name: 'SBI FD', kind: 'fd', valuePaise: 50000000,
        interestBp: 700, valueDate: d);
    await LoanRepository(db).save(
      name: 'Home loan',
      kind: 'home',
      principalPaise: 500000000,
      rateBp: 850,
      tenureMonths: 240,
      firstEmiDate: DateTime(2024, 5, 5),
    );

    final al = await ScheduleAlRepository(db).build(const FinancialYear(2025));
    expect(al.asOf, DateTime(2026, 3, 31));
    final t = al.totals;
    expect(t[AlSection.immovable], 800000000);
    expect(t[AlSection.jewellery], 30000000);
    // Bank = balance on 28 Mar + FD principal (cost, not grown value).
    expect(t[AlSection.bank], 450000000 + 50000000);
    // Funds at cost: HDFC Flexi Cap printed cost was on 30 Sep 2026, after
    // this date, so FIFO cost is used; all three funds held on 31 Mar 2026.
    expect(al.items.where((i) => i.section == AlSection.securities),
        hasLength(3));
    expect(al.items.where((i) => i.section == AlSection.securities)
        .every((i) => i.atCost), isTrue);
    expect(t[AlSection.liabilities], greaterThan(400000000));
    expect(al.items.firstWhere((i) => i.label == 'Flat').atCost, isFalse);
    expect(al.hasValuesNotAtCost, isTrue);
    expect(al.assetsPaise,
        t.entries.where((e) => e.key != AlSection.liabilities)
            .fold<int>(0, (s, e) => s + e.value));
  });
}

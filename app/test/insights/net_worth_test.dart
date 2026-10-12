import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fdValue compounds quarterly and stops at maturity', () {
    final from = DateTime(2025, 1, 1);
    // ₹1,00,000 at 7% for one year, quarterly: 1.0175^4 = 1.07186
    expect(fdValue(10000000, 700, from, DateTime(2026, 1, 1)),
        closeTo(10718590, 50));
    expect(
      fdValue(10000000, 700, from, DateTime(2030, 1, 1),
          maturity: DateTime(2026, 1, 1)),
      closeTo(10718590, 50),
    );
    expect(fdValue(10000000, 700, from, from), 10000000);
  });

  group('NetWorthRepository', () {
    late ArthDatabase db;
    late NetWorthRepository repo;
    final today = DateTime(2026, 9, 30, 12);
    setUp(() {
      db = ArthDatabase.memory();
      repo = NetWorthRepository(db);
    });
    tearDown(() => db.close());

    Future<void> bankRow(String h, DateTime at, int bal,
        {String hint = '1234', String? kind}) =>
        db.into(db.transactions).insert(TransactionsCompanion.insert(
              amountPaise: 100,
              direction: 'debit',
              txnType: 'upi',
              bookedAt: at,
              bankCode: 'HDFC',
              accountHint: Value(hint),
              rawMerchant: 'X',
              rawDescription: 'X',
              dedupeHash: h,
              balanceAfterPaise: Value(bal),
              accountKind: Value(kind),
            ));

    test('combines banks, investments, assets, cards and loans', () async {
      await bankRow('a', DateTime(2026, 8, 31), 5000000);
      await bankRow('b', DateTime(2026, 9, 28), 6000000);
      // Card rows never count as bank balance.
      await bankRow('c', DateTime(2026, 9, 28), 999999, hint: '4455', kind: 'card');
      final lines = File('../test/golden/cas/cams_detailed.txt').existsSync()
          ? File('../test/golden/cas/cams_detailed.txt').readAsLinesSync()
          : File('test/golden/cas/cams_detailed.txt').readAsLinesSync();
      await CasImporter(db).store(const CasParser().parse(lines),
          fileName: 'c', contentHash: 'c');
      await repo.saveAsset(
          name: 'Gold coins', kind: 'gold', valuePaise: 20000000,
          valueDate: DateTime(2026, 1, 1));
      await repo.saveAsset(
          name: 'Car loan', kind: 'loan', valuePaise: 30000000,
          valueDate: DateTime(2026, 9, 1));
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 250000,
            direction: 'debit',
            txnType: 'card',
            bookedAt: DateTime(2026, 9, 20),
            bankCode: 'AXIS',
            accountHint: const Value('9012'),
            rawMerchant: 'SHOP',
            rawDescription: 'SHOP',
            dedupeHash: 'card',
            accountKind: const Value('card'),
          ));
      await CreditCardRepository(db)
          .save(bankCode: 'AXIS', name: 'Axis', last4: '9012');

      final nw = await repo.netWorth(today);
      final g = nw.byGroup;
      expect(g[NetWorthGroup.bank], 6000000); // latest balance
      expect(g[NetWorthGroup.investments], closeTo(6365587, 300));
      expect(g[NetWorthGroup.assets], 20000000);
      expect(g[NetWorthGroup.loans], 30000000);
      expect(g[NetWorthGroup.cards], 250000);
      expect(nw.totalPaise,
          nw.assetsPaise - nw.liabilitiesPaise);
      expect(nw.items.firstWhere((i) => i.group == NetWorthGroup.bank).asOf,
          DateTime(2026, 9, 28));

      // History: month ends, cards excluded, starts when data starts.
      final h = await repo.history(today);
      expect(h.last.paise, nw.totalPaise + 250000);
      expect(h.first.date.isBefore(DateTime(2026, 2)), isTrue);
    });

    test('asset value history and FD growth', () async {
      final id = await repo.saveAsset(
          name: 'Gold', kind: 'gold', valuePaise: 100,
          valueDate: DateTime(2026, 1, 1));
      await repo.saveAsset(
          id: id, name: 'Gold', kind: 'gold', valuePaise: 150,
          valueDate: DateTime(2026, 6, 1));
      expect((await repo.assets(DateTime(2026, 3, 1))).single.currentPaise, 100);
      expect((await repo.assets(DateTime(2026, 7, 1))).single.currentPaise, 150);
      expect(await repo.assets(DateTime(2025, 12, 1)), isEmpty);

      await repo.saveAsset(
          name: 'SBI FD', kind: 'fd', valuePaise: 10000000, interestBp: 700,
          valueDate: DateTime(2025, 9, 30));
      final fd = (await repo.assets(today))
          .firstWhere((a) => a.kind == 'fd');
      expect(fd.currentPaise, closeTo(10718590, 300));

      await repo.deleteAsset(id);
      expect((await repo.assets(today)).map((a) => a.name), ['SBI FD']);
    });

    test('validation', () async {
      expect(() => repo.saveAsset(name: 'x', kind: 'yacht', valuePaise: 1),
          throwsArgumentError);
      expect(() => repo.saveAsset(name: 'x', kind: 'gold', valuePaise: -1),
          throwsArgumentError);
    });
  });
}

import 'dart:io';
import 'dart:typed_data';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/statement/batch_import.dart';
import 'package:arth/ingestion/statement/file_source.dart';
import 'package:arth/ingestion/statement/pdf/password_vault.dart';
import 'package:arth/insights/insights.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(int rupees, DateTime at,
        {bool debit = true, String raw = 'SHOP', String? kind = 'card'}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: debit,
      bookedAt: at,
      bankCode: 'HDFC',
      accountHint: '4455',
      rawMerchant: raw,
      accountKind: kind,
      balanceAfterPaise: null,
    );

const card = CardDef(
  id: 1,
  bankCode: 'HDFC',
  name: 'HDFC Regalia',
  last4: '4455',
  creditLimitPaise: 10000000, // ₹1,00,000
  statementDay: 12,
  dueDay: 2,
);

const calc = CardCycleCalculator();

void main() {
  test('clampedDay handles short months', () {
    expect(clampedDay(2026, 2, 31), DateTime(2026, 2, 28));
    expect(clampedDay(2026, 13, 5), DateTime(2027, 1, 5));
  });

  test('estimated bill, due date from due day, payment and unbilled', () {
    final txns = [
      tx(1000, DateTime(2026, 8, 10)), // previous cycle (Jul 12–Aug 12]
      tx(5000, DateTime(2026, 8, 20)), // closed cycle (Aug 12–Sep 12]
      tx(3000, DateTime(2026, 9, 5)),
      tx(500, DateTime(2026, 9, 6), debit: false, raw: 'MERCHANT REFUND'),
      tx(2000, DateTime(2026, 9, 15)), // current cycle
      tx(4000, DateTime(2026, 9, 20), debit: false, raw: 'PAYMENT RECEIVED - THANK YOU'),
    ];
    final s = calc.status(card, txns, asOf: DateTime(2026, 9, 25));
    expect(s.lastClose, DateTime(2026, 9, 12));
    expect(s.nextClose, DateTime(2026, 10, 12));
    expect(s.billPaise, 750000); // 5000 + 3000 − 500 refund
    expect(s.billIsEstimate, isTrue);
    expect(s.dueDate, DateTime(2026, 10, 2));
    expect(s.paidPaise, 400000);
    expect(s.remainingDuePaise, 350000);
    expect(s.unbilledPaise, 200000);
    expect(s.outstandingPaise, 550000);
    expect(s.utilization, closeTo(0.055, 1e-9));
    expect(s.state, CardBillState.due);
    expect(s.daysToDue, 7);
  });

  test('printed bill wins over estimate; overdue after due date', () {
    final txns = [tx(9000, DateTime(2026, 8, 20))];
    final bills = [
      CardBill(
        statementDate: DateTime(2026, 9, 12),
        dueDate: DateTime(2026, 10, 1),
        totalDuePaise: 1234500,
        minDuePaise: 61700,
      ),
    ];
    final s = calc.status(card, txns, asOf: DateTime(2026, 10, 4), bills: bills);
    expect(s.billPaise, 1234500);
    expect(s.billIsEstimate, isFalse);
    expect(s.minDuePaise, 61700);
    expect(s.dueDate, DateTime(2026, 10, 1));
    expect(s.state, CardBillState.overdue);
  });

  test('paid in full', () {
    final txns = [
      tx(3000, DateTime(2026, 8, 20)),
      tx(3000, DateTime(2026, 9, 14), debit: false, raw: 'BBPS PAYMENT'),
    ];
    final s = calc.status(card, txns, asOf: DateTime(2026, 9, 20));
    expect(s.state, CardBillState.paid);
    expect(s.remainingDuePaise, 0);
  });

  test('no statement day: cycle from latest printed bill', () {
    const noDays = CardDef(id: 2, bankCode: 'HDFC', name: 'x', last4: '4455');
    final s = calc.status(
      noDays,
      [tx(700, DateTime(2026, 8, 3))],
      asOf: DateTime(2026, 8, 5),
      bills: [
        CardBill(
          periodEnd: DateTime(2026, 7, 31),
          dueDate: DateTime(2026, 8, 15),
          totalDuePaise: 250000,
          creditLimitPaise: 5000000,
        ),
      ],
    );
    expect(s.lastClose, DateTime(2026, 7, 31));
    expect(s.billPaise, 250000);
    expect(s.dueDate, DateTime(2026, 8, 15));
    expect(s.limitPaise, 5000000);
    expect(s.unbilledPaise, 70000);
  });

  test('no cycle info at all: last 30 days unbilled, no bill', () {
    const bare = CardDef(id: 3, bankCode: 'HDFC', name: 'x');
    final s = calc.status(bare, [tx(700, DateTime(2026, 8, 3))],
        asOf: DateTime(2026, 8, 5));
    expect(s.state, CardBillState.noBill);
    expect(s.unbilledPaise, 70000);
  });

  test('BalanceSeries ignores card accounts', () {
    InsightTxn b(int id, int bal, DateTime at, String kind) => InsightTxn(
          id: id,
          amountPaise: 100,
          isDebit: true,
          bookedAt: at,
          bankCode: 'HDFC',
          accountHint: kind,
          balanceAfterPaise: bal,
          accountKind: kind,
        );
    final pts = BalanceSeries.build([
      for (var d = 1; d <= 3; d++) b(d, 100000, DateTime(2026, 9, d), 'bank'),
      for (var d = 1; d <= 3; d++) b(10 + d, 999999, DateTime(2026, 9, d), 'card'),
    ], from: DateTime(2026, 9, 1), to: DateTime(2026, 9, 3));
    expect(pts.map((p) => p.paise).toSet(), {100000});
  });

  group('end to end with a real card statement', () {
    late ArthDatabase db;
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      db = ArthDatabase.memory();
    });
    tearDown(() => db.close());

    test('import tags card rows, stores the bill, suggests and tracks the card',
        () async {
      final dir = [
        Directory('../test/golden/statement'),
        Directory('test/golden/statement'),
      ].firstWhere((d) => d.existsSync());
      StatementFile f(String n) => (
            name: n,
            bytes: Uint8List.fromList(File('${dir.path}/$n').readAsBytesSync()),
          );
      final out = await StatementBatchImporter(
        db: db,
        source: StatementFileSource(),
        vault: PdfPasswordVault(),
        askPassword: (_, _, _) async => null,
      ).run([f('hdfc_cc.csv'), f('hdfc_account.csv')]).last;
      expect(out.every((r) => r.status == BatchFileStatus.imported), isTrue);

      final rows = await db.select(db.transactions).get();
      final cardRows = rows.where((r) => r.accountKind == 'card').toList();
      expect(cardRows, isNotEmpty);
      expect(cardRows.every((r) => r.accountHint == '4455'), isTrue);
      expect(rows.where((r) => r.accountKind == 'bank').every(
          (r) => r.accountHint == '1234'), isTrue);

      final repo = CreditCardRepository(db);
      final sugg = await repo.suggestions();
      expect(sugg.single.bankCode, 'HDFC');
      expect(sugg.single.last4, '4455');

      await repo.save(bankCode: 'HDFC', name: 'Regalia', last4: '4455');
      expect(await repo.suggestions(), isEmpty);

      final statuses = await repo.statuses(DateTime(2026, 8, 5));
      final s = statuses.single;
      expect(s.dueDate, DateTime(2026, 8, 15)); // printed on the statement
      expect(s.billPaise, isNotNull);
      expect(s.state, CardBillState.due);
    });
  });
}

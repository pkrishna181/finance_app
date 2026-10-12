import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(
  int rupees,
  DateTime at, {
  bool debit = true,
  int? bal,
  String bank = 'HDFC',
  String? hint = '1234',
  String? cat = 'shopping',
  String type = 'upi',
  bool manual = false,
  String? kind,
}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: debit,
      bookedAt: at,
      bankCode: bank,
      accountHint: hint,
      categorySlug: cat,
      txnType: type,
      balanceAfterPaise: bal == null ? null : bal * 100,
      isManual: manual,
      accountKind: kind,
    );

const doctor = DataDoctor();
final asOf = DateTime(2026, 10, 12);
DoctorContext ctx([int sms = 0, int rows = 0, int cards = 0]) => DoctorContext(
      asOf: asOf,
      unresolvedSms: sms,
      unresolvedStatementRows: rows,
      untrackedCards: cards,
    );

Set<String> keys(List<DoctorFinding> f) => {for (final x in f) x.key};

void main() {
  test('clean ledger has no findings', () {
    final txns = [
      tx(100, DateTime(2026, 9, 1, 10), bal: 900),
      tx(200, DateTime(2026, 9, 2, 10), bal: 700),
      tx(500, DateTime(2026, 10, 3, 10), debit: false, bal: 1200),
    ];
    expect(doctor.run(txns, ctx()), isEmpty);
  });

  test('balance gap: closing balance not explained by the day\'s rows', () {
    final txns = [
      tx(100, DateTime(2026, 9, 1, 10), bal: 900),
      // Same day, order within the day doesn't matter.
      tx(50, DateTime(2026, 9, 2, 18), bal: 800),
      tx(50, DateTime(2026, 9, 2, 9), bal: 850),
      // ₹300 missing before this one.
      tx(100, DateTime(2026, 9, 9, 10), bal: 400),
      tx(10, DateTime(2026, 10, 1, 10)), // no balance: rolled into the next
      tx(10, DateTime(2026, 10, 2, 10), bal: 380),
    ];
    final f = doctor.run(txns, ctx());
    final gap = f.firstWhere((x) => x.key.startsWith('balance_gap'));
    expect(gap.severity, DoctorSeverity.warning);
    expect(gap.title, 'HDFC ••1234: balance doesn\'t add up');
    expect(gap.detail, contains('₹300 unaccounted for across 1 place'));
    expect(gap.detail, contains('2 Sep 2026 and 9 Sep 2026'));
    expect(gap.action, DoctorAction.importData);
  });

  test('card accounts are not balance-checked', () {
    final txns = [
      tx(100, DateTime(2026, 9, 1), bal: 900, kind: 'card'),
      tx(100, DateTime(2026, 9, 5), bal: 100, kind: 'card'),
      tx(100, DateTime(2026, 10, 5), bal: 100, kind: 'card'),
    ];
    expect(keys(doctor.run(txns, ctx())).any((k) => k.startsWith('balance')),
        isFalse);
  });

  test('missing months and stale accounts', () {
    final txns = [
      tx(1, DateTime(2026, 5, 3)),
      tx(1, DateTime(2026, 8, 3)), // Jun, Jul missing
      tx(1, DateTime(2026, 10, 3)), // Sep missing
      tx(1, DateTime(2026, 6, 1), bank: 'SBI', hint: '9999'),
    ];
    final f = doctor.run(txns, ctx());
    final gap = f.firstWhere((x) => x.key == 'month_gap:HDFC|1234');
    expect(gap.title, 'HDFC ••1234: no data for 3 months');
    expect(gap.detail, startsWith('Jun 2026, Jul 2026, Sep 2026.'));
    final stale = f.firstWhere((x) => x.key == 'stale:SBI|9999');
    expect(stale.title, 'SBI ••9999: nothing since 1 Jun 2026');
    expect(keys(f).contains('stale:HDFC|1234'), isFalse);
  });

  test('uncategorized share and search link', () {
    final txns = [
      tx(800, DateTime(2026, 10, 1), cat: null),
      tx(200, DateTime(2026, 10, 1)),
      tx(5000, DateTime(2026, 10, 1), cat: 'transfers_self'),
    ];
    final f =
        doctor.run(txns, ctx()).firstWhere((x) => x.key == 'uncategorized');
    expect(f.title, '80% of recent spending is uncategorized');
    expect(f.query, 'cat:none debit');
    expect(TxnQuery.parse(f.query!).category, TxnQuery.kNoCategory);
  });

  test('possible duplicates link to a search for that day', () {
    final txns = [
      tx(1499, DateTime(2026, 10, 1, 10)),
      tx(1499, DateTime(2026, 10, 1, 19)),
      tx(1499, DateTime(2026, 10, 2, 10)),
      tx(20, DateTime(2026, 10, 2, 11)),
      tx(20, DateTime(2026, 10, 2, 12)), // below threshold
    ];
    final f = doctor.run(txns, ctx()).firstWhere((x) => x.key == 'duplicates');
    expect(f.title, '1 possible duplicate');
    final q = TxnQuery.parse(f.query!);
    expect((q.minPaise, q.maxPaise), (149900, 149900));
    expect(q.bank, 'hdfc');
    expect(q.from, DateTime(2026, 10, 1));
    expect(q.toExclusive, DateTime(2026, 10, 2));
  });

  test('cash double count only when cash is logged in the same month', () {
    final atm = tx(2000, DateTime(2026, 9, 5), type: 'atm', cat: null);
    final cash = tx(300, DateTime(2026, 9, 6),
        bank: 'CASH', hint: null, manual: true, kind: 'cash');
    expect(keys(doctor.run([atm], ctx())).contains('cash_double_count'),
        isFalse);
    final f = doctor
        .run([atm, cash], ctx())
        .firstWhere((x) => x.key == 'cash_double_count');
    expect(f.detail, contains('1 ATM withdrawal (₹2,000)'));
    expect(TxnQuery.parse(f.query!).type, 'atm');

    final fixed = tx(2000, DateTime(2026, 9, 5),
        type: 'atm', cat: 'transfers_self');
    expect(keys(doctor.run([fixed, cash], ctx())).contains('cash_double_count'),
        isFalse);
  });

  test('context counts become findings; warnings sort first', () {
    final f = doctor.run(const [], ctx(3, 2, 1));
    expect(keys(f), {'unparsed_sms', 'unparsed_rows', 'untracked_cards'});
    expect(f.first.key, 'unparsed_sms');
    expect(f.first.title, '3 bank messages not understood');
  });

  test('runDataDoctor reads counts from the database', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    await db.insertUnparsedSms(UnparsedSmsRowsCompanion.insert(
      rawBody: 'x',
      reason: 'no_template',
    ));
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
          amountPaise: 100,
          direction: 'debit',
          txnType: 'card',
          bookedAt: DateTime(2026, 10, 1),
          bankCode: 'AXIS',
          rawMerchant: 'X',
          rawDescription: 'X',
          dedupeHash: 'a',
          accountHint: const Value('9012'),
          accountKind: const Value('card'),
        ));
    final f = await runDataDoctor(db, asOf: asOf);
    expect(keys(f), containsAll(['unparsed_sms', 'untracked_cards']));
  });
}

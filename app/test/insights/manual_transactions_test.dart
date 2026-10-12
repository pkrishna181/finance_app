import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ArthDatabase db;
  late ManualTransactionRepository repo;
  setUp(() {
    db = ArthDatabase.memory();
    repo = ManualTransactionRepository(db);
  });
  tearDown(() => db.close());

  test('add shows up in insights as manual cash spend', () async {
    final id = await repo.add(
      amountPaise: 25000,
      isDebit: true,
      bookedAt: DateTime(2026, 9, 3, 12),
      description: ' Vegetables ',
      categorySlug: 'groceries',
    );
    final rows = await InsightsRepository(db).loadByIds([id]);
    final t = rows.single;
    expect(t.isManual, isTrue);
    expect(t.bankCode, kCashBankCode);
    expect(t.accountKind, 'cash');
    expect(t.categorySlug, 'groceries');
    expect(t.categorySource, 'user');
    expect(t.rawMerchant, 'Vegetables');
    final agg = await InsightsRepository(db).aggregatorFor(MonthKey(2026, 9));
    expect(agg.summarize(MonthKey(2026, 9)).byCategory['groceries'], 25000);
  });

  test('update and delete manual rows; imported rows are protected', () async {
    final id = await repo.add(
      amountPaise: 100,
      isDebit: true,
      bookedAt: DateTime(2026, 9, 3),
      description: 'x',
    );
    await repo.update(id,
        amountPaise: 5000,
        isDebit: false,
        bookedAt: DateTime(2026, 9, 4),
        description: 'Sold old phone',
        bankCode: 'HDFC');
    final t = (await repo.get(id))!;
    expect(t.amountPaise, 5000);
    expect(t.direction, 'credit');
    expect(t.bankCode, 'HDFC');
    expect(t.accountKind, isNull);
    expect(t.categoryId, isNull);

    // A correction pointing at the row must not block deletion.
    await InsightsRepository(db).recategorize(
        (await InsightsRepository(db).loadByIds([id])).single, 'shopping');
    await repo.delete(id);
    expect(await repo.get(id), isNull);

    final imported = await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            amountPaise: 1,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime(2026, 9, 1),
            bankCode: 'HDFC',
            rawMerchant: 'X',
            rawDescription: 'X',
            dedupeHash: 'real',
          ),
        );
    expect(() => repo.delete(imported), throwsStateError);
    expect(
      () => repo.update(imported,
          amountPaise: 1,
          isDebit: true,
          bookedAt: DateTime(2026),
          description: 'y'),
      throwsStateError,
    );
  });

  test('validation and accounts list', () async {
    expect(
      () => repo.add(
          amountPaise: 0,
          isDebit: true,
          bookedAt: DateTime(2026),
          description: 'x'),
      throwsArgumentError,
    );
    expect(
      () => repo.add(
          amountPaise: 1, isDebit: true, bookedAt: DateTime(2026), description: ' '),
      throwsArgumentError,
    );
    await repo.add(
        amountPaise: 1,
        isDebit: true,
        bookedAt: DateTime(2026),
        description: 'x',
        bankCode: 'SBI');
    expect(await repo.accounts(), [kCashBankCode, 'SBI']);
  });
}

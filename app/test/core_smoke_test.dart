import 'package:arth/core/db/database.dart';
import 'package:arth/core/models/money.dart';
import 'package:arth/llm/fake_llm_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MoneyPaise formats with Indian grouping', () {
    expect(const MoneyPaise(10000000).formatInr(), '₹1,00,000.00');
    expect(const MoneyPaise(125000).formatInr(), '₹1,250.00');
  });

  test('FakeLlmEngine returns canned JSON after load', () async {
    final engine = FakeLlmEngine(jsonResponse: '{"merchant":"Amazon"}');
    expect(engine.isReady, isFalse);

    final loaded = await engine.load(modelPath: '/dev/null');
    expect(loaded.isOk, isTrue);
    expect(engine.isReady, isTrue);

    final out = await engine.completeJson(prompt: 'normalize');
    expect(out.okOrNull, '{"merchant":"Amazon"}');
  });

  test('in-memory DB seeds categories and dedupes transactions', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);

    final cats = await db.select(db.categories).get();
    expect(cats.length, greaterThanOrEqualTo(10));
    expect(cats.any((c) => c.slug == 'groceries'), isTrue);

    final hash = buildDedupeHash(
      bankCode: 'HDFC',
      bookedAt: DateTime.utc(2026, 7, 15),
      amountPaise: 125000,
      ref: '412345678901',
    );

    final row = TransactionsCompanion.insert(
      amountPaise: 125000,
      direction: 'debit',
      txnType: 'upi',
      bookedAt: DateTime.utc(2026, 7, 15),
      bankCode: 'HDFC',
      rawMerchant: 'merchant@okhdfcbank',
      rawDescription: 'test',
      dedupeHash: hash,
    );

    final first = await db.insertTransactionIdempotent(row);
    expect(first, greaterThan(0));

    await db.insertTransactionIdempotent(row);

    final count = await db.select(db.transactions).get();
    expect(count, hasLength(1));
  });
}

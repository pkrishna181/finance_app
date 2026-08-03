import 'package:arth/core/db/database.dart';
import 'package:arth/parsing/sms/template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dedupe key / hash', () {
    test('strong ref uses bank|amount|ref (no date)', () {
      final key = buildDedupeKey(
        bankCode: 'HDFC',
        bookedAt: DateTime.utc(2026, 7, 15),
        amountPaise: 125000,
        ref: '412345678901',
      );
      expect(key, 'HDFC|125000|412345678901');
    });

    test('SMS txn date vs statement posting date collide on strong ref', () {
      final smsKey = buildDedupeKey(
        bankCode: 'HDFC',
        bookedAt: DateTime.utc(2026, 8, 1),
        amountPaise: 125000,
        ref: '412345678901',
      );
      final stmtKey = buildDedupeKey(
        bankCode: 'HDFC',
        bookedAt: DateTime.utc(2026, 8, 3),
        amountPaise: 125000,
        ref: '412345678901',
      );
      expect(smsKey, stmtKey);
      expect(buildDedupeHash(
        bankCode: 'HDFC',
        bookedAt: DateTime.utc(2026, 8, 3),
        amountPaise: 125000,
        ref: '412345678901',
      ), buildDedupeHash(
        bankCode: 'HDFC',
        bookedAt: DateTime.utc(2026, 8, 1),
        amountPaise: 125000,
        ref: '412345678901',
      ));
    });

    test('without ref uses bank|date|amount|time|body', () {
      final body = 'spent at MERCHANT A on 28-07-26 19:42';
      final key = buildDedupeKey(
        bankCode: 'AXIS',
        bookedAt: DateTime.utc(2026, 7, 28, 19, 42),
        amountPaise: 89900,
        normalizedBody: body,
      );
      expect(key, 'AXIS|2026-07-28|89900|19:42|$body');
    });

    test('two same-day same-amount refless txns do not collide', () async {
      final db = ArthDatabase.memory();
      addTearDown(db.close);

      final day = DateTime.utc(2026, 8, 1, 10, 0);
      final bodyA = 'spent at CAFE A on 01-08-26 10:00';
      final bodyB = 'spent at CAFE B on 01-08-26 10:00';

      final hashA = buildDedupeHash(
        bankCode: 'AXIS',
        bookedAt: day,
        amountPaise: 50000,
        normalizedBody: bodyA,
      );
      final hashB = buildDedupeHash(
        bankCode: 'AXIS',
        bookedAt: day,
        amountPaise: 50000,
        normalizedBody: bodyB,
      );
      expect(hashA, isNot(equals(hashB)));

      await db.insertTransactionIdempotent(
        TransactionsCompanion.insert(
          amountPaise: 50000,
          direction: 'debit',
          txnType: 'pos',
          bookedAt: day,
          bankCode: 'AXIS',
          rawMerchant: 'CAFE A',
          rawDescription: bodyA,
          dedupeHash: hashA,
        ),
      );
      await db.insertTransactionIdempotent(
        TransactionsCompanion.insert(
          amountPaise: 50000,
          direction: 'debit',
          txnType: 'pos',
          bookedAt: day,
          bankCode: 'AXIS',
          rawMerchant: 'CAFE B',
          rawDescription: bodyB,
          dedupeHash: hashB,
        ),
      );

      final rows = await db.select(db.transactions).get();
      expect(rows, hasLength(2));
    });

    test('identical ref hashes still collide (idempotent)', () async {
      final db = ArthDatabase.memory();
      addTearDown(db.close);

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
        rawMerchant: 'm@upi',
        rawDescription: 'dup',
        dedupeHash: hash,
      );
      await db.insertTransactionIdempotent(row);
      await db.insertTransactionIdempotent(row);
      expect(await db.select(db.transactions).get(), hasLength(1));
    });
  });
}

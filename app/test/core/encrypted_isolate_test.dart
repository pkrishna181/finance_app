import 'dart:io';
import 'dart:isolate';

import 'package:arth/core/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  test('encrypted DB open + write works from a background isolate', () async {
    // Confirm sqlite3mc is linked in this test process.
    final probe = sqlite3.sqlite3.openInMemory();
    addTearDown(probe.close);
    expect(
      probe.select('PRAGMA cipher;'),
      isNotEmpty,
      reason: 'sqlite3mc hooks required for isolate encryption test',
    );
    probe.close();

    final tmp = await Directory.systemTemp.createTemp('arth_iso_');
    addTearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });
    final dbPath = p.join(tmp.path, 'iso.db');
    const key = 'phase1-isolate-test-key';

    final writtenId = await Isolate.run(() async {
      final db = ArthDatabase.openEncryptedFile(
        file: File(dbPath),
        key: key,
      );
      try {
        final hash = buildDedupeHash(
          bankCode: 'HDFC',
          bookedAt: DateTime.utc(2026, 8, 1),
          amountPaise: 10000,
          ref: '999888777666',
        );
        return db.insertTransactionIdempotent(
          TransactionsCompanion.insert(
            amountPaise: 10000,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime.utc(2026, 8, 1),
            bankCode: 'HDFC',
            rawMerchant: 'iso@upi',
            rawDescription: 'isolate write',
            dedupeHash: hash,
          ),
        );
      } finally {
        await db.close();
      }
    });

    expect(writtenId, greaterThan(0));

    // Re-open on the main isolate with the same key and read back.
    final mainDb = ArthDatabase.openEncryptedFile(
      file: File(dbPath),
      key: key,
    );
    addTearDown(mainDb.close);
    final rows = await mainDb.select(mainDb.transactions).get();
    expect(rows, hasLength(1));
    expect(rows.single.amountPaise, 10000);
    expect(rows.single.rawMerchant, 'iso@upi');
  });
}

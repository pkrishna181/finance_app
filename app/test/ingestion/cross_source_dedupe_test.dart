import 'package:arth/core/db/database.dart';
import 'package:arth/core/models/transaction_type.dart';
import 'package:arth/ingestion/statement/file_source.dart';
import 'package:arth/parsing/sms/regex_sms_parser.dart';
import 'package:arth/parsing/sms/template.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SMS + statement of same txn collide; both imports recorded', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);

    const body =
        'HDFC Bank: Rs.1,250.00 debited from a/c **1234 on 15-07-26 to VPA '
        'merchant@okhdfcbank (UPI Ref 412345678901). Not you? Call 18002586161';

    final smsParsed = RegexSmsParser().parse(body: body).okOrNull!.single;
    final smsImportId = await db
        .into(db.imports)
        .insert(
          ImportsCompanion.insert(
            sourceType: 'sms',
            sourceLabel: 'sms-test',
            contentHash: 'sms-hash-1',
            status: const Value('succeeded'),
          ),
        );
    final smsHash = buildDedupeHash(
      bankCode: smsParsed.bankCode,
      bookedAt: smsParsed.bookedAt,
      amountPaise: smsParsed.amountPaise.paise,
      ref: smsParsed.externalRef,
      normalizedBody: smsParsed.rawDescription,
    );
    await db.upsertTransactionWithProvenance(
      TransactionsCompanion.insert(
        amountPaise: smsParsed.amountPaise.paise,
        direction: smsParsed.direction.wireName,
        txnType: smsParsed.type.wireName,
        bookedAt: smsParsed.bookedAt,
        bankCode: smsParsed.bankCode,
        rawMerchant: smsParsed.rawMerchant,
        rawDescription: smsParsed.rawDescription,
        dedupeHash: smsHash,
        externalRef: Value(smsParsed.externalRef),
        upiRef: Value(smsParsed.upiRef),
        upiPayeeVpa: Value(smsParsed.upiPayeeVpa),
        importId: Value(smsImportId),
      ),
      importId: smsImportId,
    );

    // Statement row with same bank/date/amount/ref
    final stmtImportId = await db
        .into(db.imports)
        .insert(
          ImportsCompanion.insert(
            sourceType: 'csv',
            sourceLabel: 'hdfc.csv',
            contentHash: 'stmt-hash-1',
            status: const Value('succeeded'),
          ),
        );
    final stmtKey = buildDedupeKey(
      bankCode: 'HDFC',
      bookedAt: DateTime.utc(2026, 7, 15),
      amountPaise: 125000,
      ref: '412345678901',
    );
    expect(stmtKey, smsParsed.dedupeKey);

    final upsert = await db.upsertTransactionWithProvenance(
      TransactionsCompanion.insert(
        amountPaise: 125000,
        direction: TransactionDirection.debit.wireName,
        txnType: TransactionType.upi.wireName,
        bookedAt: DateTime.utc(2026, 7, 15),
        bankCode: 'HDFC',
        rawMerchant: 'merchant@okhdfcbank',
        rawDescription: 'UPI/412345678901/merchant@okhdfcbank/FOOD',
        dedupeHash: buildDedupeHash(
          bankCode: 'HDFC',
          bookedAt: DateTime.utc(2026, 7, 15),
          amountPaise: 125000,
          ref: '412345678901',
        ),
        externalRef: const Value('412345678901'),
        importId: Value(stmtImportId),
      ),
      importId: stmtImportId,
    );

    expect(upsert.inserted, isFalse);
    final txns = await db.select(db.transactions).get();
    expect(txns, hasLength(1));

    final links = await db.select(db.transactionImports).get();
    expect(links, hasLength(2));
    expect(links.map((l) => l.importId).toSet(), {smsImportId, stmtImportId});
  });

  test(
    'SMS Aug 1 + statement Aug 3 same UPI ref → one row, earlier date kept',
    () async {
      final db = ArthDatabase.memory();
      addTearDown(db.close);

      const ref = '412345678901';
      const amount = 125000;
      final smsDate = DateTime.utc(2026, 8, 1);
      final stmtDate = DateTime.utc(2026, 8, 3);

      final smsImportId = await db
          .into(db.imports)
          .insert(
            ImportsCompanion.insert(
              sourceType: 'sms',
              sourceLabel: 'sms-date-test',
              contentHash: 'sms-hash-date',
              status: const Value('succeeded'),
            ),
          );
      await db.upsertTransactionWithProvenance(
        TransactionsCompanion.insert(
          amountPaise: amount,
          direction: TransactionDirection.debit.wireName,
          txnType: TransactionType.upi.wireName,
          bookedAt: smsDate,
          bankCode: 'HDFC',
          rawMerchant: 'merchant@okhdfcbank',
          rawDescription: 'UPI/$ref/merchant@okhdfcbank/FOOD',
          dedupeHash: buildDedupeHash(
            bankCode: 'HDFC',
            bookedAt: smsDate,
            amountPaise: amount,
            ref: ref,
          ),
          externalRef: const Value(ref),
          importId: Value(smsImportId),
        ),
        importId: smsImportId,
      );

      final stmtImportId = await db
          .into(db.imports)
          .insert(
            ImportsCompanion.insert(
              sourceType: 'pdf',
              sourceLabel: 'hdfc.pdf',
              contentHash: 'stmt-hash-date',
              status: const Value('succeeded'),
            ),
          );
      final upsert = await db.upsertTransactionWithProvenance(
        TransactionsCompanion.insert(
          amountPaise: amount,
          direction: TransactionDirection.debit.wireName,
          txnType: TransactionType.upi.wireName,
          bookedAt: stmtDate,
          bankCode: 'HDFC',
          rawMerchant: 'merchant@okhdfcbank',
          rawDescription: 'UPI/$ref/merchant@okhdfcbank/FOOD',
          dedupeHash: buildDedupeHash(
            bankCode: 'HDFC',
            bookedAt: stmtDate,
            amountPaise: amount,
            ref: ref,
          ),
          externalRef: const Value(ref),
          importId: Value(stmtImportId),
        ),
        importId: stmtImportId,
      );

      expect(upsert.inserted, isFalse);
      final txns = await db.select(db.transactions).get();
      expect(txns, hasLength(1));
      expect(txns.single.bookedAt.toUtc(), smsDate);

      final links = await db.select(db.transactionImports).get();
      expect(links, hasLength(2));
    },
  );

  test('re-import same file hash is a no-op', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final source = StatementFileSource();

    final csv = utf8Bytes('''
HDFC Bank Ltd
Statement of account

Date,Narration,Chq/Ref No,Withdrawal Amt.,Deposit Amt.,Closing Balance
01/07/2026,UPI/412345678901/merchant@okhdfcbank/FOOD,412345678901,1250.00,,45000.00
''');

    final preview1 = await source.previewBytes(
      db: db,
      bytes: csv,
      fileName: 'hdfc_reimport.csv',
    );
    expect(preview1.isOk, isTrue);
    final confirmed = await source.confirmImport(
      db: db,
      preview: preview1.okOrNull!,
    );
    expect(confirmed.isOk, isTrue);
    expect(confirmed.okOrNull, greaterThan(0));

    final preview2 = await source.previewBytes(
      db: db,
      bytes: csv,
      fileName: 'hdfc_reimport.csv',
    );
    expect(preview2.isErr, isTrue);
    expect(preview2.errorOrNull, 'duplicate_file');
  });

  test('card statement rows link to SMS purchases one to one', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final smsImport = await db
        .into(db.imports)
        .insert(
          ImportsCompanion.insert(
            sourceType: 'sms',
            sourceLabel: 'sms',
            contentHash: 'sms-card',
            status: const Value('succeeded'),
          ),
        );
    // One SMS for 85.00 on 9 Oct (the statement has two such purchases).
    final sms = RegexSmsParser()
        .parse(
          body:
              'Rs.85.00 spent on your SBI Credit Card ending 4455 at PAYTM '
              'on 09/10/26. Trxn. not done by you? Report at https://x.y/D',
          sender: 'VM-SBICRD-T',
        )
        .okOrNull!
        .single;
    await db.upsertTransactionWithProvenance(
      TransactionsCompanion.insert(
        amountPaise: sms.amountPaise.paise,
        direction: sms.direction.wireName,
        txnType: sms.type.wireName,
        bookedAt: sms.bookedAt,
        bankCode: sms.bankCode,
        rawMerchant: sms.rawMerchant,
        rawDescription: sms.rawDescription,
        dedupeHash: buildDedupeHash(
          bankCode: sms.bankCode,
          bookedAt: sms.bookedAt,
          amountPaise: sms.amountPaise.paise,
          ref: sms.externalRef,
          normalizedBody: sms.rawDescription,
        ),
        accountHint: Value(sms.accountHint),
        externalRef: Value(sms.externalRef),
        importId: Value(smsImport),
      ),
      importId: smsImport,
    );

    final source = StatementFileSource();
    final preview = (await source.previewBytes(
      db: db,
      bytes: utf8Bytes('''
SBI Card
Credit Card Statement
Card Number,XXXX XXXX XXXX XX65
Date,Transaction Details,Amount
09/10/2026,PAYTM TRAVEL NOIDA IN,85.00 D
09/10/2026,PAYTM TRAVEL NOIDA IN,85.00 D
10/10/2026,PHP*Zepto Bengaluru IN,310.00 D
'''),
      fileName: 'sbi_card.csv',
    )).okOrNull!;
    expect(preview.columnMap.bankCode, 'SBI');
    expect(preview.newCount, 2);
    expect(preview.duplicateCount, 1);

    await source.confirmImport(db: db, preview: preview);
    final txns = await db.select(db.transactions).get();
    expect(txns, hasLength(3));
    final linked = txns.where((t) => t.rawDescription.contains('spent')).single;
    expect(linked.accountKind, 'card');
    expect(linked.accountHint, '4455');
  });
}

Uint8List utf8Bytes(String s) => Uint8List.fromList(s.codeUnits);

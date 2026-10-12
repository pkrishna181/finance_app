import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arth/core/backup/backup_crypto.dart';
import 'package:arth/core/backup/backup_service.dart';
import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/ingestion/statement/pdf/password_vault.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const fast = 1000; // PBKDF2 iterations for tests

Future<int> count(ArthDatabase db, String table) async => (await db
        .customSelect('SELECT COUNT(*) AS n FROM "$table"')
        .getSingle())
    .read<int>('n');

void main() {
  group('BackupCrypto', () {
    final data = Uint8List.fromList(utf8.encode('hello ledger ' * 50));

    test('round trip; wrong passphrase and tampering are rejected', () async {
      final enc =
          await BackupCrypto.encrypt(data, 'correct horse', iterations: fast);
      expect(ascii.decode(enc.sublist(0, 8)), 'ARTHBAK1');
      expect(await BackupCrypto.decrypt(enc, 'correct horse'), data);

      await expectLater(
        BackupCrypto.decrypt(enc, 'wrong horse'),
        throwsA(isA<BackupException>()
            .having((e) => e.code, 'code', 'wrong_passphrase')),
      );
      final tampered = Uint8List.fromList(enc)..[enc.length - 20] ^= 1;
      await expectLater(BackupCrypto.decrypt(tampered, 'correct horse'),
          throwsA(isA<BackupException>()));
      final header = Uint8List.fromList(enc)..[15] ^= 1; // salt byte
      await expectLater(BackupCrypto.decrypt(header, 'correct horse'),
          throwsA(isA<BackupException>()));
      await expectLater(
        BackupCrypto.decrypt(Uint8List.fromList(utf8.encode('PK not ours')), 'x'),
        throwsA(isA<BackupException>()
            .having((e) => e.code, 'code', 'not_a_backup')),
      );
    });

    test('each backup uses a fresh salt and nonce', () async {
      final a = await BackupCrypto.encrypt(data, 'p', iterations: fast);
      final b = await BackupCrypto.encrypt(data, 'p', iterations: fast);
      expect(a.sublist(12, 40), isNot(b.sublist(12, 40)));
    });
  });

  group('BackupService', () {
    late ArthDatabase src;
    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      src = ArthDatabase.memory();
      await src.into(src.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 45000,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime(2026, 9, 3, 10),
            bankCode: 'HDFC',
            rawMerchant: 'SWIGGY',
            rawDescription: 'UPI SWIGGY',
            dedupeHash: 'a',
            accountHint: const Value('1234'),
            categoryId: Value((await src.categoryBySlug('food_delivery'))!.id),
          ));
      await BudgetRepository(src).upsert('groceries',
          limitPaise: 500000, rollover: true, start: MonthKey(2026, 9));
      final f = ['../test/golden/cas', 'test/golden/cas']
          .map((d) => File('$d/cams_detailed.txt'))
          .firstWhere((f) => f.existsSync());
      await CasImporter(src).store(
          const CasParser().parse(f.readAsLinesSync()),
          fileName: 'x',
          contentHash: 'x');
      await NetWorthRepository(src).saveAsset(
          name: 'Gold', kind: 'gold', valuePaise: 100, valueDate: DateTime(2026));
      await LoanRepository(src).save(
          name: 'Car',
          kind: 'car',
          principalPaise: 100000000,
          rateBp: 900,
          tenureMonths: 60,
          firstEmiDate: DateTime(2026, 1, 5));
      await PdfPasswordVault().add('Axis card', 'secret123');
    });
    tearDown(() => src.close());

    test('restores everything into a fresh database', () async {
      final file = await BackupService(src, vault: PdfPasswordVault(),
              iterations: fast)
          .export('my long passphrase');
      // The file contains no readable ledger text.
      expect(latin1.decode(file, allowInvalid: true).contains('SWIGGY'),
          isFalse);

      final dst = ArthDatabase.memory();
      addTearDown(dst.close);
      await dst.into(dst.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 1,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime(2020),
            bankCode: 'X',
            rawMerchant: 'OLD',
            rawDescription: 'OLD',
            dedupeHash: 'old',
          ));
      final summary = await BackupService(dst, iterations: fast)
          .restore(file, 'my long passphrase');
      expect(summary.transactions, 1);
      expect(summary.savedPasswords, 0); // not included

      for (final t in [
        'transactions',
        'categories',
        'budgets',
        'securities',
        'investment_txns',
        'holding_snapshots',
        'manual_assets',
        'loans',
        'imports',
      ]) {
        expect(await count(dst, t), await count(src, t), reason: t);
      }
      final row = await dst.select(dst.transactions).getSingle();
      expect(row.rawMerchant, 'SWIGGY');
      expect(row.bookedAt, DateTime(2026, 9, 3, 10));
      expect((await BudgetRepository(dst).list()).single.rollover, isTrue);
      final p = await PortfolioRepository(dst).summary(DateTime(2026, 9, 30));
      expect(p.positions, hasLength(3));
    });

    test('saved passwords only when asked; restored into the vault',
        () async {
      final file = await BackupService(src, vault: PdfPasswordVault(),
              iterations: fast)
          .export('pass phrase 1', includePasswords: true);
      FlutterSecureStorage.setMockInitialValues({}); // "new phone"
      final dst = ArthDatabase.memory();
      addTearDown(dst.close);
      final s = await BackupService(dst, vault: PdfPasswordVault(),
              iterations: fast)
          .restore(file, 'pass phrase 1');
      expect(s.savedPasswords, 1);
      expect((await PdfPasswordVault().list()).single.password, 'secret123');
    });

    test('inspect describes without changing; newer versions refused',
        () async {
      final svc = BackupService(src, iterations: fast);
      final file = await svc.export('passphrase!');
      final s = await svc.inspect(file, 'passphrase!');
      expect(s.schemaVersion, src.schemaVersion);
      expect(s.transactions, 1);

      // Forge a backup from a future app version.
      final plain = await BackupCrypto.decrypt(file, 'passphrase!');
      final json = jsonDecode(utf8.decode(GZipCodec().decode(plain))) as Map;
      json['schemaVersion'] = src.schemaVersion + 1;
      final future = await BackupCrypto.encrypt(
          Uint8List.fromList(GZipCodec().encode(utf8.encode(jsonEncode(json)))),
          'passphrase!',
          iterations: fast);
      await expectLater(
        svc.restore(future, 'passphrase!'),
        throwsA(isA<BackupException>()
            .having((e) => e.code, 'code', 'newer_version')),
      );
      expect(await count(src, 'transactions'), 1); // untouched
    });
  });
}

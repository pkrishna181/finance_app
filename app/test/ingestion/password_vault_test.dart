import 'dart:io';
import 'dart:typed_data';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/statement/batch_import.dart';
import 'package:arth/ingestion/statement/file_source.dart';
import 'package:arth/ingestion/statement/pdf/password_vault.dart';
import 'package:arth/ingestion/statement/pdf/pdf_loader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

Directory goldenDir() {
  for (final d in [
    Directory('../test/golden/statement'),
    Directory('test/golden/statement'),
  ]) {
    if (d.existsSync()) return d;
  }
  fail('golden dir missing');
}

StatementFile golden(String name) => (
      name: name,
      bytes: Uint8List.fromList(
        File('${goldenDir().path}/$name').readAsBytesSync(),
      ),
    );

void main() {
  late PdfPasswordVault vault;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vault = PdfPasswordVault();
  });

  group('PdfPasswordVault', () {
    test('add, dedupe by password, rename, remove', () async {
      final a = await vault.add('Axis credit card', 'axis123');
      await vault.add('SBI card', 'sbi456');
      final again = await vault.add('Axis card (new name)', 'axis123');
      expect(again.id, a.id);
      expect((await vault.list()).map((p) => p.label),
          ['Axis card (new name)', 'SBI card']);

      await vault.rename(a.id, 'Axis CC');
      await vault.remove((await vault.list())[1].id);
      final left = await vault.list();
      expect(left.single.label, 'Axis CC');
      expect(left.single.password, 'axis123');
    });

    test('candidatesFor puts file-name matches first, then recent', () async {
      final old = await vault.add('HDFC savings', 'h');
      await vault.add('SBI credit card', 's');
      await vault.add('Kotak', 'k');
      await vault.markUsed(old.id, bankCode: 'HDFC');

      final forSbi = await vault.candidatesFor('SBI_Card_Statement_Sep.pdf');
      expect(forSbi.first.label, 'SBI credit card');

      // Bank code learnt from a previous unlock also matches.
      await vault.rename(old.id, 'Main account');
      final forHdfc = await vault.candidatesFor('hdfc-acct-2026-09.pdf');
      expect(forHdfc.first.label, 'Main account');

      // No match: most recently used first.
      final other = await vault.candidatesFor('statement.pdf');
      expect(other.first.label, 'Main account');
    });

    test('fileNameWords drops generic words', () {
      expect(fileNameWords('Axis_Credit_Card_Statement_2026.pdf'), {'axis'});
      expect(guessIssuer('axis_cc_sep.pdf'), 'AXIS');
      expect(guessIssuer('random.pdf'), isNull);
    });
  });

  group('PdfUnlockSession with an encrypted statement', () {
    late Uint8List locked;
    final loader = PdfStatementLoader();

    setUp(() {
      locked = golden('hdfc_account_password.pdf').bytes;
    });

    test('tries saved passwords before asking, then marks the match',
        () async {
      await vault.add('Old card', 'wrong-1');
      final good = await vault.add('HDFC', 'hdfc1234');
      var asked = 0;
      final session = PdfUnlockSession(
        vault: vault,
        fileName: 'statement.pdf',
        ask: (_) async {
          asked++;
          return null;
        },
      );
      final r = await loader.loadBytes(
        bytes: locked,
        passwordProvider: session.provide,
      );
      expect(r.isOk, isTrue, reason: r.errorOrNull);
      expect(asked, 0);
      await session.commit(bankCode: 'HDFC');
      final saved = (await vault.list()).firstWhere((p) => p.id == good.id);
      expect(saved.bankCode, 'HDFC');
    });

    test('asks when nothing saved works; remembers on request', () async {
      await vault.add('Other', 'nope');
      final asks = <int>[];
      final session = PdfUnlockSession(
        vault: vault,
        fileName: 'hdfc_sep.pdf',
        ask: (failed) async {
          asks.add(failed);
          return PasswordEntry(
            password: failed == 0 ? 'typo' : 'hdfc1234',
            remember: true,
            label: 'HDFC savings',
          );
        },
      );
      final r = await loader.loadBytes(
        bytes: locked,
        passwordProvider: session.provide,
      );
      expect(r.isOk, isTrue, reason: r.errorOrNull);
      expect(asks, [0, 1]);
      expect(session.savedTried, 1);
      await session.commit(bankCode: 'HDFC');
      final saved = await vault.list();
      expect(saved.map((p) => p.label), containsAll(['Other', 'HDFC savings']));
      expect(saved.firstWhere((p) => p.label == 'HDFC savings').password,
          'hdfc1234');
    });

    test('does not store a password the user did not want remembered',
        () async {
      final session = PdfUnlockSession(
        vault: vault,
        fileName: 'x.pdf',
        ask: (_) async => const PasswordEntry(
          password: 'hdfc1234',
          remember: false,
          label: 'x',
        ),
      );
      final r = await loader.loadBytes(
        bytes: locked,
        passwordProvider: session.provide,
      );
      expect(r.isOk, isTrue);
      await session.commit(bankCode: 'HDFC');
      expect(await vault.list(), isEmpty);
    });

    test('gives up after maxAsks wrong passwords', () async {
      final session = PdfUnlockSession(
        vault: vault,
        fileName: 'x.pdf',
        maxAsks: 2,
        ask: (_) async =>
            const PasswordEntry(password: 'bad', remember: true, label: 'x'),
      );
      final r = await loader.loadBytes(
        bytes: locked,
        passwordProvider: session.provide,
      );
      expect(r.errorOrNull, 'pdf_password_required');
    });
  });

  group('StatementBatchImporter', () {
    late ArthDatabase db;
    setUp(() => db = ArthDatabase.memory());
    tearDown(() => db.close());

    test('imports many files, unlocks with the vault, reports each', () async {
      await vault.add('HDFC', 'hdfc1234');
      final prompts = <String>[];
      final importer = StatementBatchImporter(
        db: db,
        source: StatementFileSource(),
        vault: vault,
        askPassword: (name, failed, saved) async {
          prompts.add(name);
          return null;
        },
      );
      final files = [
        golden('hdfc_account.csv'),
        golden('hdfc_account_password.pdf'),
        golden('icici_account.csv'),
        golden('scanned_image_only.pdf'),
      ];
      final emissions = await importer.run(files).toList();
      final last = emissions.last;
      expect(last.every((r) => r.done), isTrue);
      expect(prompts, isEmpty);

      final byName = {for (final r in last) r.name: r};
      final csv = byName['hdfc_account.csv']!;
      expect(csv.status, BatchFileStatus.imported);
      expect(csv.inserted, greaterThan(0));
      expect(csv.bankCode, 'HDFC');

      // Same account as the CSV: unlocked with the saved password; rows the
      // CSV already brought in are counted as duplicates, not re-added.
      final pdf = byName['hdfc_account_password.pdf']!;
      expect(pdf.status, BatchFileStatus.imported);
      expect(pdf.duplicates, greaterThan(0));

      expect(byName['icici_account.csv']!.status, BatchFileStatus.imported);
      expect(byName['scanned_image_only.pdf']!.status, BatchFileStatus.failed);

      final total = await db.select(db.transactions).get();
      expect(total.length,
          last.fold<int>(0, (s, r) => s + r.inserted));

      // Re-running the same files: everything already imported.
      final again = await importer.run(files.take(3).toList()).last;
      expect(again.every((r) => r.status == BatchFileStatus.alreadyImported),
          isTrue);
    });

    test('a locked file with no working password is skipped, others continue',
        () async {
      var asked = 0;
      final importer = StatementBatchImporter(
        db: db,
        source: StatementFileSource(),
        vault: vault,
        askPassword: (name, failed, saved) async {
          asked++;
          return null;
        },
      );
      final out = await importer.run([
        golden('hdfc_account_password.pdf'),
        golden('sbi_account.csv'),
      ]).last;
      expect(asked, 1);
      expect(out[0].status, BatchFileStatus.skipped);
      expect(out[1].status, BatchFileStatus.imported);
    });
  });
}

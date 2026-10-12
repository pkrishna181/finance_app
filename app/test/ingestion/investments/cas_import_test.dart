import 'dart:io';
import 'dart:typed_data';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/ingestion/statement/batch_import.dart';
import 'package:arth/ingestion/statement/file_source.dart';
import 'package:arth/ingestion/statement/pdf/password_vault.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

File golden(String sub, String name) {
  for (final d in ['../test/golden/$sub', 'test/golden/$sub']) {
    final f = File('$d/$name');
    if (f.existsSync()) return f;
  }
  fail('missing $sub/$name');
}

StatementFile file(String sub, String name) => (
      name: name,
      bytes: Uint8List.fromList(golden(sub, name).readAsBytesSync()),
    );

void main() {
  late ArthDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = ArthDatabase.memory();
  });
  tearDown(() => db.close());

  test('store: securities, folios, txns, snapshots, prices', () async {
    final st = const CasParser()
        .parse(golden('cas', 'cams_detailed.txt').readAsLinesSync());
    final r = await CasImporter(db)
        .store(st, fileName: 'cas.pdf', contentHash: 'h1');
    expect(r.error, isNull);
    final res = r.result!;
    expect(res.schemes, 3);
    expect(res.newTxns, 11);
    expect(res.valuePaise, 2722649 + 1105662 + 2537276);
    expect(res.asOf, DateTime(2026, 9, 30));

    expect(await db.select(db.securities).get(), hasLength(3));
    final accounts = await db.select(db.investmentAccounts).get();
    expect(accounts.map((a) => a.number).toSet(),
        {'1234567/89', '7788990011', '55443322'});
    expect(accounts.every((a) => a.kind == 'folio'), isTrue);
    final snaps = await db.select(db.holdingSnapshots).get();
    expect(snaps, hasLength(3));
    final hdfc = snaps.firstWhere((s) => s.unitsE4 == 121000);
    expect(hdfc.costPaise, 2399950);
    expect(hdfc.asOf, DateTime(2026, 9, 30));

    // Same statement again under another file hash (overlapping period):
    // no duplicate transactions, snapshot updated in place.
    final again = await CasImporter(db)
        .store(st, fileName: 'cas2.pdf', contentHash: 'h2');
    expect(again.result!.newTxns, 0);
    expect(await db.select(db.investmentTxns).get(), hasLength(11));
    expect(await db.select(db.holdingSnapshots).get(), hasLength(3));

    // Identical file: refused.
    final dup = await CasImporter(db)
        .store(st, fileName: 'cas.pdf', contentHash: 'h1');
    expect(dup.error, 'duplicate_file');
  });

  test('batch: locked CAMS PDF via saved PAN password, NSDL PDF, bank CSV',
      () async {
    final vault = PdfPasswordVault();
    await vault.add('CAS (PAN)', 'ABCDE1234F');
    final prompts = <String>[];
    final importer = StatementBatchImporter(
      db: db,
      source: StatementFileSource(),
      vault: vault,
      askPassword: (name, _, _) async {
        prompts.add(name);
        return null;
      },
    );
    final out = await importer.run([
      file('cas', 'cams_detailed.pdf'),
      file('cas', 'nsdl.pdf'),
      file('statement', 'hdfc_account.csv'),
    ]).last;
    expect(prompts, isEmpty);
    final byName = {for (final r in out) r.name: r};

    final cams = byName['cams_detailed.pdf']!;
    expect(cams.status, BatchFileStatus.imported, reason: cams.message);
    expect(cams.bankCode, 'CAMS');
    expect(cams.inserted, 11);
    expect(cams.message, startsWith('3 holdings · ₹63,655 on 30 Sep 2026'));

    final nsdl = byName['nsdl.pdf']!;
    expect(nsdl.status, BatchFileStatus.imported, reason: nsdl.message);
    expect(nsdl.bankCode, 'NSDL');
    expect(nsdl.message, startsWith('4 holdings'));

    expect(byName['hdfc_account.csv']!.status, BatchFileStatus.imported);
    // CAS rows never land in the bank ledger.
    final ledger = await db.select(db.transactions).get();
    expect(ledger.every((t) => t.bankCode == 'HDFC'), isTrue);

    // The NSDL MF row is the same HDFC fund + folio as the CAMS CAS → same
    // security; the demat equities get their own account.
    final secs = await db.select(db.securities).get();
    expect(secs.where((s) => s.isin == 'INF179K01UT0'), hasLength(1));
    final demat = await (db.select(db.investmentAccounts)
          ..where((a) => a.kind.equals('demat')))
        .get();
    expect(demat.single.number, 'IN303028/12345678');

    // Saved password learnt which provider it opens.
    expect((await vault.list()).single.bankCode, 'CAMS');
  });
}

import 'dart:io';
import 'dart:typed_data';

import 'package:arth/core/models/parsed_transaction.dart';
import 'package:arth/ingestion/statement/header_mapper.dart';
import 'package:arth/ingestion/statement/pdf/pdf_loader.dart';
import 'package:arth/ingestion/statement/row_parser.dart';
import 'package:arth/ingestion/statement/table_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final loader = TableLoader();
  final pdfLoader = PdfStatementLoader();
  final mapper = HeaderMapper();
  final parser = StatementRowParser();

  Directory goldenDir() {
    for (final rel in [
      Directory('../test/golden/statement'),
      Directory('test/golden/statement'),
    ]) {
      if (rel.existsSync()) return rel;
    }
    fail('golden dir missing');
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  List<ParsedTransaction> parseFile(List<List<String>> rows) {
    final map = mapper.map(rows);
    return parser.parse(rows: rows, columnMap: map).transactions;
  }

  for (final name in [
    'hdfc_account',
    'icici_account',
    'sbi_account',
    'axis_account',
    'hdfc_cc',
    'axis_cc',
    'hdfc_continuation',
    'axis_blank_amounts',
  ]) {
    test('CSV and PDF produce equivalent txns for $name', () async {
      final dir = goldenDir();
      final csvFile = File('${dir.path}/$name.csv');
      final pdfFile = File('${dir.path}/$name.pdf');
      expect(csvFile.existsSync(), isTrue, reason: '$name.csv');
      expect(pdfFile.existsSync(), isTrue, reason: '$name.pdf');

      final csvGrid = loader.loadBytes(
        Uint8List.fromList(csvFile.readAsBytesSync()),
        fileName: '$name.csv',
      );
      expect(csvGrid.isOk, isTrue);

      final pdfGrid = await pdfLoader.loadBytes(
        bytes: Uint8List.fromList(pdfFile.readAsBytesSync()),
      );
      expect(pdfGrid.isOk, isTrue, reason: pdfGrid.errorOrNull);

      final csvTxns = parseFile(csvGrid.okOrNull!.rows);
      final pdfTxns = parseFile(pdfGrid.okOrNull!.rows);

      expect(pdfTxns.length, csvTxns.length, reason: name);
      final csvNorm = csvTxns.map(_normalize).toList()..sort(_compare);
      final pdfNorm = pdfTxns.map(_normalize).toList()..sort(_compare);
      expect(pdfNorm, csvNorm, reason: name);
    });
  }

  test('password-protected HDFC PDF opens with password', () async {
    final file = File('${goldenDir().path}/hdfc_account_password.pdf');
    expect(file.existsSync(), isTrue);

    final without = await pdfLoader.loadBytes(
      bytes: file.readAsBytesSync(),
      passwordProvider: (_) async => null,
    );
    expect(without.isErr, isTrue);

    final withPwd = await pdfLoader.loadBytes(
      bytes: file.readAsBytesSync(),
      passwordProvider: (_) async => 'hdfc1234',
    );
    expect(withPwd.isOk, isTrue, reason: withPwd.errorOrNull);
  });

  test('scanned image-only PDF is declined', () async {
    final file = File('${goldenDir().path}/scanned_image_only.pdf');
    expect(file.existsSync(), isTrue);

    final result = await pdfLoader.loadBytes(bytes: file.readAsBytesSync());
    expect(result.isErr, isTrue);
    expect(result.errorOrNull, 'scanned_pdf');
  });
}

/// Financial identity — narration may diverge; ref must match for dedupe.
(
  String date,
  int amount,
  String bank,
  String? ref,
  String direction,
  bool directionInferred,
) _normalize(ParsedTransaction t) {
  return (
    t.bookedAt.toUtc().toIso8601String().substring(0, 10),
    t.amountPaise.paise,
    t.bankCode,
    t.externalRef,
    t.direction.name,
    t.directionInferred,
  );
}

int _compare(
  (
    String date,
    int amount,
    String bank,
    String? ref,
    String direction,
    bool directionInferred,
  ) a,
  (
    String date,
    int amount,
    String bank,
    String? ref,
    String direction,
    bool directionInferred,
  ) b,
) {
  final d = a.$1.compareTo(b.$1);
  if (d != 0) return d;
  return a.$2.compareTo(b.$2);
}

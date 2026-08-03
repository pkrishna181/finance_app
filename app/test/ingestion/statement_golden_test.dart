import 'dart:io';
import 'dart:typed_data';

import 'package:arth/ingestion/statement/header_mapper.dart';
import 'package:arth/ingestion/statement/row_parser.dart';
import 'package:arth/ingestion/statement/table_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final loader = TableLoader();
  final mapper = HeaderMapper();
  final parser = StatementRowParser();

  Directory dir() {
    final candidates = [
      Directory('../test/golden/statement'),
      Directory('test/golden/statement'),
    ];
    for (final d in candidates) {
      if (d.existsSync()) return d;
    }
    fail('statement golden dir missing');
  }

  test('≥16 statement fixtures present', () {
    final files = dir()
        .listSync()
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.csv') ||
            f.path.endsWith('.xlsx') ||
            f.path.endsWith('.xls'))
        .toList();
    expect(files.length, greaterThanOrEqualTo(16));
  });

  for (final name in [
    'hdfc_account.csv',
    'hdfc_account.xlsx',
    'hdfc_cc.csv',
    'hdfc_continuation.csv',
    'icici_account.csv',
    'icici_account.xlsx',
    'icici_cc.csv',
    'sbi_account.csv',
    'sbi_account.xlsx',
    'sbi_excel_serial.csv',
    'axis_account.csv',
    'axis_cc.csv',
    'axis_blank_amounts.csv',
    'kotak_account.csv',
    'kotak_account.xlsx',
    'kotak_drcr_suffix.csv',
    'weird_generic.csv',
  ]) {
    test('parses $name', () {
      final file = File('${dir().path}/$name');
      expect(file.existsSync(), isTrue, reason: name);
      final bytes = Uint8List.fromList(file.readAsBytesSync());
      final grid = loader.loadBytes(bytes, fileName: name);
      expect(grid.isOk, isTrue, reason: grid.errorOrNull);
      final map = mapper.map(grid.okOrNull!.rows);
      expect(map.bindings, isNotEmpty, reason: name);
      expect(map.indexOf(StatementField.date), isNotNull);
      final result = parser.parse(
        rows: grid.okOrNull!.rows,
        columnMap: map,
      );
      expect(
        result.transactions,
        isNotEmpty,
        reason: '$name produced 0 txns; map=${map.toJson()}',
      );
    });
  }

  test('hdfc_account finds header after junk preamble', () {
    final bytes = File('${dir().path}/hdfc_account.csv').readAsBytesSync();
    final grid = loader.loadBytes(Uint8List.fromList(bytes), fileName: 'hdfc_account.csv');
    final map = mapper.map(grid.okOrNull!.rows);
    expect(map.headerRowIndex, greaterThan(0));
    expect(map.bankCode, 'HDFC');
    expect(map.profileId, contains('hdfc'));
  });

  test('continuation row merges into prior narration', () {
    final bytes =
        File('${dir().path}/hdfc_continuation.csv').readAsBytesSync();
    final grid = loader.loadBytes(
      Uint8List.fromList(bytes),
      fileName: 'hdfc_continuation.csv',
    );
    final map = mapper.map(grid.okOrNull!.rows);
    final result = parser.parse(rows: grid.okOrNull!.rows, columnMap: map);
    expect(result.transactions.length, greaterThanOrEqualTo(2));
    final first = result.transactions.first;
    expect(first.rawDescription, contains('ORDER REF ABC123'));
  });

  test('dr/cr suffix resolves direction', () {
    final bytes =
        File('${dir().path}/kotak_drcr_suffix.csv').readAsBytesSync();
    final grid = loader.loadBytes(
      Uint8List.fromList(bytes),
      fileName: 'kotak_drcr_suffix.csv',
    );
    final map = mapper.map(grid.okOrNull!.rows);
    final result = parser.parse(rows: grid.okOrNull!.rows, columnMap: map);
    expect(result.transactions, hasLength(2));
    expect(result.transactions[0].direction.name, 'debit');
    expect(result.transactions[1].direction.name, 'credit');
  });

  test('weird semicolon CSV maps via generic synonyms', () {
    final bytes = File('${dir().path}/weird_generic.csv').readAsBytesSync();
    final grid = loader.loadBytes(
      Uint8List.fromList(bytes),
      fileName: 'weird_generic.csv',
    );
    expect(grid.okOrNull!.detectedDelimiter, ';');
    final map = mapper.map(grid.okOrNull!.rows);
    expect(map.indexOf(StatementField.date), isNotNull);
    expect(map.indexOf(StatementField.debit), isNotNull);
    final result = parser.parse(rows: grid.okOrNull!.rows, columnMap: map);
    expect(result.transactions, hasLength(2));
  });
}

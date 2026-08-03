import 'dart:typed_data';

import 'package:arth/ingestion/statement/table_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy .xls extension returns export XLSX/CSV message', () {
    // OLE magic (BIFF) — not supported.
    final biff = Uint8List.fromList([
      0xd0,
      0xcf,
      0x11,
      0xe0,
      0xa1,
      0xb1,
      0x1a,
      0xe1,
      ...List.filled(100, 0),
    ]);
    final loaded = TableLoader().loadBytes(biff, fileName: 'statement.xls');
    expect(loaded.isErr, isTrue);
    expect(loaded.errorOrNull, 'xls_unsupported_export_xlsx_or_csv');
  });

  test('xlsx with .xlsx extension still parses', () {
    // Minimal zip header (xlsx) — will fail parse but not xls gate.
    final zip = Uint8List.fromList([0x50, 0x4b, 0x03, 0x04, ...List.filled(8, 0)]);
    final loaded = TableLoader().loadBytes(zip, fileName: 'book.xlsx');
    expect(loaded.errorOrNull, isNot('xls_unsupported_export_xlsx_or_csv'));
  });
}

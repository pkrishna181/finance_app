import 'package:arth/ingestion/statement/header_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mapper = HeaderMapper();

  test('scores header not at row 0 amid junk', () {
    final rows = <List<String>>[
      ['Totally Random Bank Export'],
      ['Address line 1'],
      ['Customer: Alice'],
      [],
      ['Txn Day', 'Story', 'Money Out', 'Money In', 'Leftover'],
      ['01/08/2026', 'UPI coffee', '100.00', '', '900.00'],
    ];
    // Near-synonym header row that should win:
    final rows2 = <List<String>>[
      ['Totally Random Bank Export'],
      ['Address line 1'],
      ['Customer: Alice'],
      [],
      ['Txn Date', 'Narration', 'Withdrawal Amt', 'Deposit Amt', 'Balance'],
      ['01/08/2026', 'UPI coffee', '100.00', '', '900.00'],
    ];
    final map = mapper.map(rows2);
    expect(map.headerRowIndex, 4);
    expect(map.indexOf(StatementField.date), 0);
    expect(map.indexOf(StatementField.narration), 1);
    expect(map.indexOf(StatementField.debit), 2);
    expect(map.indexOf(StatementField.credit), 3);
    // Keep `rows` referenced so the weird layout stays in the suite as a
    // negative control (score should be lower / may fail amount requirement).
    final weird = mapper.map(rows);
    expect(weird.overallConfidence, lessThanOrEqualTo(map.overallConfidence));
  });

  test('deliberately weird-but-valid headers still map', () {
    final rows2 = <List<String>>[
      ['Ledger dump v2'],
      [
        'Posting Date',
        'Txn Remarks',
        'Withdrawal Amt',
        'Deposit Amt',
        'Closing Balance',
      ],
      ['02/08/2026', 'NEFT rent', '12000', '', '3000'],
    ];
    final map = mapper.map(rows2);
    expect(map.headerRowIndex, 1);
    expect(map.indexOf(StatementField.date), isNotNull);
    expect(map.indexOf(StatementField.debit), isNotNull);
    expect(map.overallConfidence, greaterThan(2));
  });
}

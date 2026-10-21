import 'dart:typed_data';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/statement/file_source.dart';
import 'package:arth/ingestion/statement/pdf/layout_to_grid.dart';
import 'package:arth/ingestion/statement/pdf/positioned_text.dart';
import 'package:arth/ingestion/statement/printed_totals.dart';
import 'package:arth/ingestion/statement/statement_digest.dart';
import 'package:arth/ingestion/statement/statement_history.dart';
import 'package:arth/ingestion/statement/statement_overview.dart';
import 'package:flutter_test/flutter_test.dart';

/// Words at their real positions; each entry (left x, text).
PdfTextLine _line(int page, double y, List<(double, String)> words) =>
    PdfTextLine(
      pageIndex: page,
      y: y,
      words: [
        for (final (x, t) in words)
          PositionedWord(
            text: t,
            x: x,
            y: y,
            pageIndex: page,
            width: t.length * 4.4,
            height: 8,
          ),
      ],
    );

/// Phrases at column positions, words 3pt apart like real text.
PdfTextLine _cols(int page, double y, List<(double, String)> phrases) {
  final words = <(double, String)>[];
  for (final (x, phrase) in phrases) {
    var at = x;
    for (final w in phrase.split(' ')) {
      words.add((at, w));
      at += w.length * 4.4 + 3;
    }
  }
  return _line(page, y, words);
}

DigestRow _row(String day, int rupees, String merchant, {bool debit = true}) =>
    DigestRow(
      date: DateTime.parse(day),
      paise: rupees * 100,
      isDebit: debit,
      merchant: merchant,
      description: merchant,
    );

void main() {
  group('printed totals', () {
    test('account: summary row with labels above its values', () {
      // SBI savings: closing summary on the last page.
      final p = extractPrintedTotals([
        _cols(0, 40, [(40, 'Clear Balance :'), (130, '1,23,456.78CR')]),
        _cols(20, 559, [(232, 'Statement Summary : 01-04-2026 To 13-08-2026')]),
        _cols(20, 586, [
          (56, 'Brought Forward ( )'),
          (152, 'Dr Count'),
          (196, 'Cr Count'),
          (246, 'Total Debits ( )'),
          (342, 'Total Credits ( )'),
          (452, 'Closing Balance ( )'),
        ]),
        _cols(20, 616, [
          (50, '12,345.67CR'),
          (158, '210'),
          (204, '19'),
          (260, '4,32,100.50'),
          (362, '5,43,211.61'),
          (488, '1,23,456.78CR'),
        ]),
      ]);
      expect(p.periodStart, DateTime(2026, 4, 1));
      expect(p.periodEnd, DateTime(2026, 8, 13));
      expect(p.openingPaise, 1234567);
      expect(p.closingPaise, 12345678);
      expect(p.debitsPaise, 43210050);
      expect(p.creditsPaise, 54321161);
      expect(p.debitCount, 210);
      expect(p.creditCount, 19);
    });

    test('card: boxes with labels stacked over values', () {
      final p = extractPrintedTotals([
        _cols(0, 60, [(400, '*Total Amount Due')]),
        _cols(0, 72, [(410, '54,321.00 incl. EMI')]),
        _cols(0, 90, [(390, '**Minimum Amount Due')]),
        _cols(0, 100, [(60, 'STMT No. : H0000001')]),
        _cols(0, 110, [(410, '12,345.00')]),
        _cols(0, 140, [
          (60, 'Credit Limit'),
          (230, 'Cash Limit'),
          (400, 'Statement Date'),
        ]),
        _cols(0, 152, [
          (70, '1,50,000.00'),
          (240, '21,000.00'),
          (402, '19 Oct 2026'),
        ]),
        _cols(0, 170, [
          (60, 'Available Credit Limit'),
          (230, 'Available Cash Limit'),
          (400, 'Payment Due Date'),
        ]),
        _cols(0, 182, [
          (70, '98,765.43'),
          (240, '21,000.00'),
          (402, '08 Nov 2026'),
        ]),
        _cols(0, 210, [(150, 'Payments,')]),
        _cols(0, 218, [
          (30, 'Previous Balance'),
          (140, 'Reversals & other'),
          (330, 'Fee, Taxes &'),
          (440, 'Total Outstanding'),
        ]),
        _cols(0, 226, [(250, 'Purchases & Other')]),
        _cols(0, 234, [
          (150, 'Credits'),
          (250, 'Debits'),
          (330, 'Interest Charges'),
        ]),
        _cols(0, 246, [
          (40, '49,876.54'),
          (150, '40,000.00'),
          (252, '44,321.09'),
          (340, '543.21'),
          (450, '54,321.00'),
        ]),
        _cols(1, 20, [(80, 'for Statement Period: 20 Sep 26 to 19 Oct 26')]),
        // Further down, policy text that also says "minimum amount due".
        _cols(1, 400, [(40, 'paying the minimum amount due Rs.100')]),
      ]);
      expect(p.totalDuePaise, 5432100);
      expect(p.minDuePaise, 1234500);
      expect(p.creditLimitPaise, 15000000);
      expect(p.availableLimitPaise, 9876543, reason: 'not the cash limit');
      expect(p.statementDate, DateTime(2026, 10, 19));
      expect(p.dueDate, DateTime(2026, 11, 8));
      expect(p.openingPaise, 4987654);
      expect(p.creditsPaise, 4000000);
      expect(p.debitsPaise, 4432109);
      expect(p.feesPaise, 54321);
      expect(p.closingPaise, 5432100);
      expect(p.periodStart, DateTime(2026, 9, 20));
      expect(PrintedTotals.decode(p.encode()).toJson(), p.toJson());
    });
  });

  group('digest', () {
    test('account adds up to the printed totals', () {
      final d = StatementDigest.build(
        rows: [
          _row('2026-04-02', 2400, 'UPI/DR/1/TEA Ve'),
          _row('2026-04-07', 68000, 'ACME LTD', debit: false),
          _row('2026-04-08', 45, 'SMS CHARGES'),
          _row('2026-04-09', 150, 'UPI/DR/2/TEA Ve'),
          _row('2026-04-30', 189, 'CREDIT INTEREST', debit: false),
        ],
        printed: const PrintedTotals(
          openingPaise: 1000000,
          closingPaise: 7559400,
          debitsPaise: 259500,
          creditsPaise: 6818900,
          debitCount: 3,
          creditCount: 2,
        ),
        bankCode: 'SBI',
        isCard: false,
      );
      expect(d.reconciled, isTrue);
      expect(d.outPaise, 259500);
      expect(d.chargesPaise, 4500);
      expect(d.interestEarnedPaise, 18900);
      expect(d.topPayees.first.name, 'Dr Tea', reason: '"UPI" names nobody');
      expect(d.from, DateTime(2026, 4, 2));
    });

    test('a missing row shows where it went wrong', () {
      final d = StatementDigest.build(
        rows: [_row('2026-04-02', 2400, 'TEA')],
        printed: const PrintedTotals(
          debitsPaise: 300000,
          debitCount: 2,
          openingPaise: 1000000,
          closingPaise: 700000,
        ),
        bankCode: 'SBI',
        isCard: false,
      );
      expect(d.reconciled, isFalse);
      final out = d.checks.firstWhere((c) => c.what == 'moneyOut');
      expect(out.differencePaise, -60000);
      expect(d.checks.firstWhere((c) => c.what == 'debitCount').ok, isFalse);
    });

    test('card: purchases apart from fees; outstanding rounds to a rupee', () {
      final d = StatementDigest.build(
        rows: [
          _row('2026-10-08', 5000, 'PAYMENT RECEIVED', debit: false),
          _row('2026-09-19', 640, 'ZEPTO MARKETPLACE PRIV Bangalore IN'),
          _row('2026-09-22', 320, 'Zepto Bengaluru IN'),
          _row('2026-09-25', 401, 'PHP*Zepto Bengaluru IN'),
          _row('2026-09-22', 299, 'GOOGLE PLAY CONTENT PU MUMBAI IN'),
          _row('2026-10-03', 58, 'GOOGLE CLOUD CYBS SI MUMBAI IN'),
          _row('2026-10-19', 103, 'IGST DB @ 18.00%'),
        ],
        printed: const PrintedTotals(
          openingPaise: 1000000,
          creditsPaise: 500000,
          debitsPaise: 171800,
          feesPaise: 10300,
          closingPaise: 682101, // printed rounded
        ),
        bankCode: 'SBI',
        isCard: true,
        instalmentsPaise: 250000,
        instalmentCount: 1,
      );
      expect(d.reconciled, isTrue);
      final zepto = d.topPayees.firstWhere((p) => p.name == 'Zepto');
      expect((zepto.paise, zepto.count), (136100, 3));
      expect(
        d.topPayees.map((p) => p.name),
        containsAll(['Google Play', 'Google Cloud']),
      );
      expect(d.topPayees.map((p) => p.name), isNot(contains('Igst Db')));
      expect(
        statementOverview(d).join(' '),
        contains('₹2,500 in EMI instalments (1)'),
      );
    });
  });

  group('overview', () {
    final d = StatementDigest.build(
      rows: [
        _row('2026-09-19', 640, 'ZEPTO'),
        _row('2026-10-08', 5000, 'PAYMENT RECEIVED', debit: false),
      ],
      printed: PrintedTotals(
        totalDuePaise: 5432100,
        minDuePaise: 1234500,
        dueDate: DateTime(2026, 11, 8),
        periodStart: DateTime(2026, 9, 20),
        periodEnd: DateTime(2026, 10, 19),
      ),
      bankCode: 'SBI',
      isCard: true,
    );

    test('plain sentences from the digest', () {
      expect(statementOverview(d), [
        'From 20 Sep to 19 Oct 2026, ₹640 went on the card in 1 payment and '
            '₹5,000 was paid or refunded to it.',
        'Most went to Zepto: ₹640 over 1 payment.',
        'No fees or charges.',
        '₹54,321 is due by 8 Nov 2026 (minimum ₹12,345).',
      ]);
    });
  });

  test('imported statements keep their summary', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final source = StatementFileSource();
    final preview = (await source.previewBytes(
      db: db,
      bytes: Uint8List.fromList(
        '''
SBI
Account Statement
Date,Narration,Ref,Debit,Credit,Balance
01/07/2026,UPI/DR/412345678901/TEA/Paid,412345678901,1250.00,,45000.00
02/07/2026,NEFT*YESB0000001*YESB000000001*ACME LTD,,,50000.00,95000.00
'''
            .codeUnits,
      ),
      fileName: 'sbi_july.csv',
    )).okOrNull!;
    await source.confirmImport(db: db, preview: preview);

    final history = StatementHistory(db);
    final list = await history.list();
    expect(list, hasLength(1));
    expect(list.single.fileName, 'sbi_july.csv');
    expect(list.single.transactionCount, 2);
    expect(list.single.isCard, isFalse);
    final d = (await history.digest(list.single.importId))!;
    expect((d.outPaise, d.inPaise), (125000, 5000000));
    expect(d.reconciled, isNull, reason: 'a CSV prints no totals');
    expect(d.topSources.single.name, 'Acme');
  });
}

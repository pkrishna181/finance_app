import 'package:arth/core/models/transaction_type.dart';
import 'package:arth/ingestion/statement/header_mapper.dart';
import 'package:arth/ingestion/statement/line_statement_parser.dart';
import 'package:arth/ingestion/statement/pdf/layout_to_grid.dart';
import 'package:arth/ingestion/statement/pdf/positioned_text.dart';
import 'package:flutter_test/flutter_test.dart';

/// Layouts copied from real statements (positions, wrapping, markers) with
/// made-up names, amounts and references.

const _charWidth = 4.4;

/// A line of words; each entry is (left x, text) or (right x, text, true)
/// for right-aligned / (centre x, text, 'c') for centred words.
PdfTextLine _line(int page, double y, List<(double, String, String)> words) =>
    PdfTextLine(
      pageIndex: page,
      y: y,
      words: [
        for (final (x, t, align) in words)
          PositionedWord(
            text: t,
            x: switch (align) {
              'r' => x - t.length * _charWidth,
              'c' => x - t.length * _charWidth / 2,
              _ => x,
            },
            y: y,
            pageIndex: page,
            width: t.length * _charWidth,
            height: 8,
          ),
      ],
    );

(double, String, String) l(double x, String t) => (x, t, 'l');
(double, String, String) r(double x, String t) => (x, t, 'r');
(double, String, String) c(double x, String t) => (x, t, 'c');

/// SBI savings account: no readable header, two dates, a 5-line description
/// block with the date on line 2, amounts centred, "-" for empty cells.
List<PdfTextLine> _accountPage(
  int page,
  List<(String, String, String, String?, String?, String)> rows, {
  double shift = 0,
}) {
  final out = <PdfTextLine>[
    _line(page, 31, [c(520 + shift, 'Balance')]),
  ];
  var y = 62.0;
  for (final (date, kind, path, debit, credit, balance) in rows) {
    out
      ..add(_line(page, y, [l(140, kind)]))
      ..add(
        _line(page, y + 7, [
          l(45, date),
          l(100, date),
          l(140, path),
          c(300 + shift, '-'),
          c(360 + shift, debit ?? '-'),
          c(430 + shift, credit ?? '-'),
          c(515 + shift, balance),
        ]),
      )
      ..add(_line(page, y + 18, [l(140, 'Ve/YESB/q12345/UPI')]))
      ..add(
        _line(page, y + 28, [
          l(140, '0012345678901'),
          l(200, 'AT'),
          l(212, '11111'),
        ]),
      )
      ..add(_line(page, y + 37, [l(140, 'SOMENAGAR,'), l(190, 'TOWN')]));
    y += 50;
  }
  out.add(
    _line(page, y + 20, [c(300, 'Page'), c(325, 'no.'), c(345, '$page')]),
  );
  return out;
}

void main() {
  const parser = LineStatementParser();

  test('account without a readable header: balance gives direction', () {
    final lines = [
      _line(0, 20, [
        l(40, 'State'),
        l(70, 'Bank'),
        l(95, 'of'),
        l(108, 'India'),
      ]),
      _line(0, 40, [
        l(40, 'Account'),
        l(80, 'Number'),
        l(130, ':'),
        l(140, '10000000001'),
      ]),
      ..._accountPage(1, [
        (
          '02/04/2026',
          'WDL TFR',
          'UPI/DR/100000000001/TEA',
          '1,500.00',
          null,
          '10,000.00',
        ),
        (
          '06/04/2026',
          'WDL TFR',
          'UPI/DR/100000000002/SHOP',
          '25.00',
          null,
          '9,975.00',
        ),
        (
          '07/04/2026',
          'DEP TFR',
          'NEFT*YESB0000001*YESIG00000*ACME LTD',
          null,
          '1,50,000.00',
          '1,59,975.00',
        ),
      ]),
      // The last page lays its columns out further right.
      ..._accountPage(2, [
        (
          '09/04/2026',
          'DEP TFR',
          'UPI/CR/100000000004/FRIEND',
          null,
          '40.50',
          '1,60,015.50',
        ),
        (
          '10/04/2026',
          'WDL TFR',
          'UPI/DR/100000000005/INDmoney',
          '2,500.00',
          null,
          '1,57,515.50',
        ),
      ], shift: 24),
    ];

    final res = parser.parse(lines);
    expect(res.bankCode, 'SBI');
    expect(res.isCard, isFalse);
    expect(res.hasBalance, isTrue);
    expect(res.balanceBreaks, 0);
    final t = res.transactions;
    expect(t.map((e) => e.amountPaise.paise), [
      150000,
      2500,
      15000000,
      4050,
      250000,
    ]);
    expect(t.map((e) => e.direction), [
      TransactionDirection.debit,
      TransactionDirection.debit,
      TransactionDirection.credit,
      TransactionDirection.credit,
      TransactionDirection.debit,
    ]);
    expect(t.every((e) => !e.directionInferred), isTrue);
    expect(t.first.bookedAt, DateTime.utc(2026, 4, 2));
    expect(t.first.balanceAfterPaise?.paise, 1000000);
    // Whole block, boilerplate removed, and nothing from the next row.
    expect(
      t.first.rawDescription,
      'UPI/DR/100000000001/TEA Ve/YESB/q12345/UPI',
    );
    expect(t.first.rawMerchant, 'TEA Ve');
    expect(t[2].rawMerchant, startsWith('ACME LTD'));
    expect(
      res.toParseResult().columnMap.profileId,
      LineStatementResult.accountProfileId,
    );
  });

  /// SBI Card: one amount column with a C/D/M marker; fee rows have no date;
  /// one purchase's description is wrapped above and below its amount.
  List<PdfTextLine> cardLines() => [
    _line(0, 20, [
      l(40, 'SBI'),
      l(60, 'Card'),
      l(90, 'Credit'),
      l(120, 'Card'),
      l(150, 'Statement'),
    ]),
    _line(0, 40, [
      l(40, '*Total'),
      l(70, 'Amount'),
      l(110, 'Due'),
      r(400, '6,000.00'),
    ]),
    _line(0, 60, [
      l(40, 'Payment'),
      l(80, 'Due'),
      l(100, 'Date'),
      r(400, '08 Nov 2026'),
    ]),
    _line(0, 80, [
      l(220, 'Date'),
      l(250, 'Transaction'),
      l(300, 'Details'),
      r(392, 'Amount'),
    ]),
    _line(0, 100, [
      l(65, '08'),
      l(74, 'Oct'),
      l(86, '26'),
      l(102, 'PAYMENT'),
      l(132, 'RECEIVED'),
      l(162, '000DP01628'),
      r(380, '4,500.00'),
      l(389, 'C'),
    ]),
    _line(0, 109, [
      l(65, '19'),
      l(74, 'Oct'),
      l(86, '26'),
      l(102, 'FP'),
      l(110, 'EMI'),
      l(123, '06/06(EXCL'),
      l(160, 'TAX'),
      l(178, '7.12)'),
      r(380, '2,500.00'),
      l(389, 'M'),
    ]),
    _line(0, 118, [
      l(65, '19'),
      l(74, 'Oct'),
      l(86, '26'),
      l(102, 'INTEREST'),
      l(131, 'ON'),
      l(142, 'EMI'),
      r(380, '45.10'),
      l(389, 'D'),
    ]),
    _line(0, 127, [
      l(102, 'IGST'),
      l(120, 'DB'),
      l(132, '@'),
      l(140, '18.00%'),
      r(380, '98.20'),
      l(389, 'D'),
    ]),
    _line(0, 136, [
      l(102, 'TRANSACTIONS'),
      l(160, 'FOR'),
      l(180, 'A'),
      l(190, 'CARDHOLDER'),
    ]),
    _line(0, 145, [
      l(65, '19'),
      l(74, 'Sep'),
      l(86, '26'),
      l(102, 'ZEPTO'),
      l(130, 'MARKETPLACE'),
      r(380, '640.00'),
      l(389, 'D'),
    ]),
    _line(0, 154, [
      l(65, '01'),
      l(74, 'Oct'),
      l(86, '26'),
      l(102, 'RENDER.COM'),
      l(150, 'CA'),
      l(165, '5.96'),
      l(185, 'USD'),
      r(380, '480.25'),
      l(389, 'D'),
    ]),
    _line(0, 163, [
      l(65, '11'),
      l(74, 'Oct'),
      l(86, '26'),
      l(102, 'SOMEAI*'),
      l(140, 'SUB'),
      l(165, '100.00'),
      l(195, 'USD'),
      l(215, '(Pay'),
      l(235, 'in'),
    ]),
    _line(0, 168, [r(380, '8,250.40'), l(389, 'D')]),
    _line(0, 173, [l(102, 'EMIs)')]),
    _line(0, 182, [
      l(65, '16'),
      l(74, 'Oct'),
      l(86, '26'),
      l(102, 'IND*LINKEDIN'),
      r(380, '2.00'),
      l(389, 'C'),
    ]),
    _line(0, 210, [
      l(40, 'C=Credit'),
      l(80, ';'),
      l(90, 'D=Debit;'),
      l(130, 'M=Monthly'),
      l(170, 'Installments'),
    ]),
  ];

  test(
    'card statement: markers, undated fees, wrapped rows, EMI instalments',
    () {
      final res = parser.parse(cardLines());
      expect(res.isCard, isTrue);
      expect(res.hasBalance, isFalse);
      final t = res.transactions;
      expect(
        [
          for (final e in t)
            (e.amountPaise.paise, e.direction.name, e.bookedAt.day),
        ],
        [
          (450000, 'credit', 8),
          (4510, 'debit', 19),
          (9820, 'debit', 19), // undated: the date of the row before
          (64000, 'debit', 19),
          (48025, 'debit', 1),
          (825040, 'debit', 11),
          (200, 'credit', 16),
        ],
      );
      expect(res.instalmentsPaise, 250000);
      expect(res.instalmentCount, 1);
      expect(t[4].rawDescription, 'RENDER.COM CA 5.96 USD');
      expect(t[5].rawDescription, 'SOMEAI* SUB 100.00 USD (Pay in EMIs)');
      expect(t[3].rawDescription, 'ZEPTO MARKETPLACE');
      expect(t.every((e) => e.type == TransactionType.card), isTrue);
      expect(
        HeaderMapper.isCreditCardProfileId(
          res.toParseResult().columnMap.profileId,
        ),
        isTrue,
      );
    },
  );

  test('narration boilerplate', () {
    expect(
      cleanStatementNarration(
        'WDL TFR UPI/DR/100000000009/Arun Me/ IDFB/99714/UPI 0012345678901 AT 11111 SOME NAGAR, TOWN',
      ),
      'UPI/DR/100000000009/Arun Me/IDFB/99714/UPI',
    );
  });

  test('too few dated money lines is not a statement', () {
    expect(
      parser.parse([
        _line(0, 10, [l(40, '01/04/2026'), r(300, '10.00')]),
      ]).transactions,
      isEmpty,
    );
  });
}

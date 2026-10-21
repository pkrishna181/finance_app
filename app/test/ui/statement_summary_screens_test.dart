import 'dart:typed_data';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/statement/file_source.dart';
import 'package:arth/ingestion/statement/printed_totals.dart';
import 'package:arth/ingestion/statement/statement_digest.dart';
import 'package:arth/ui/screens/statement_preview_screen.dart';
import 'package:arth/ui/screens/statements_screen.dart';
import 'package:arth/ui/widgets/statement_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester t, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await t.pump(const Duration(milliseconds: 50));
  }
}

DigestRow _row(String day, int rupees, String merchant, {bool debit = true}) =>
    DigestRow(
      date: DateTime.parse(day),
      paise: rupees * 100,
      isDebit: debit,
      merchant: merchant,
      description: merchant,
    );

StatementDigest _card({required int printedPurchases}) => StatementDigest.build(
  rows: [
    _row('2026-10-08', 5000, 'PAYMENT RECEIVED', debit: false),
    _row('2026-09-19', 640, 'ZEPTO MARKETPLACE PRIV Bangalore IN'),
    _row('2026-09-22', 299, 'GOOGLE PLAY CONTENT PU MUMBAI IN'),
    _row('2026-10-19', 103, 'IGST DB @ 18.00%'),
  ],
  printed: PrintedTotals(
    debitsPaise: printedPurchases,
    creditsPaise: 500000,
    feesPaise: 10300,
    totalDuePaise: 5432100,
    minDuePaise: 1234500,
    dueDate: DateTime(2026, 11, 8),
    periodStart: DateTime(2026, 9, 20),
    periodEnd: DateTime(2026, 10, 19),
  ),
  bankCode: 'SBI',
  isCard: true,
  last4: '4455',
);

Future<void> _show(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
  await settle(tester, 2);
}

void main() {
  testWidgets('a statement that adds up', (tester) async {
    await _show(
      tester,
      StatementSummaryView(digest: _card(printedPurchases: 93900)),
    );
    expect(
      find.text('SBI credit card ••4455 · 20 Sep 2026 – 19 Oct 2026'),
      findsOneWidget,
    );
    expect(find.text('Matches the statement'), findsOneWidget);
    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('Total due'), findsOneWidget);
    expect(find.text('Pay by'), findsOneWidget);
    expect(find.text('Fees, interest and taxes · ₹103'), findsOneWidget);
    expect(find.text('Zepto'), findsWidgets);
  });

  testWidgets("one that doesn't shows the difference", (tester) async {
    await _show(
      tester,
      StatementSummaryView(digest: _card(printedPurchases: 200000)),
    );
    expect(find.text("Doesn't add up"), findsOneWidget);
    expect(find.text('₹939.00 read · ₹2,000.00 printed'), findsOneWidget);
  });

  testWidgets('preview: summary first, then import; listed afterwards', (
    tester,
  ) async {
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    final source = StatementFileSource();
    final preview = (await tester.runAsync(
      () => source.previewBytes(
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
      ),
    ))!.okOrNull!;

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StatementPreviewScreen(
                      preview: preview,
                      db: db,
                      source: source,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    expect(find.text('Statement summary'), findsOneWidget);
    expect(find.text('Nothing to check against'), findsOneWidget);
    expect(
      find.text(
        'From 1 Jul to 2 Jul 2026, ₹50,000 came in and ₹1,250 went out '
        '(1 credit, 1 debit).',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Import 2 new'));
    await settle(tester);
    expect(find.text('open'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: StatementsScreen(db: db)));
    await settle(tester);
    expect(find.text('SBI account'), findsOneWidget);
    await tester.tap(find.text('SBI account'));
    await settle(tester);
    expect(find.text('Money in and out'), findsOneWidget);
    expect(find.text('Acme'), findsOneWidget);
  });
}

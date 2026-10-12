import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/ui/screens/allocation_screen.dart';
import 'package:arth/ui/screens/capital_gains_screen.dart';
import 'package:arth/ui/screens/loans_screen.dart';
import 'package:arth/ui/screens/retirement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<ArthDatabase> dbWithCas(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = ArthDatabase.memory();
  addTearDown(() => tester.runAsync(db.close));
  await tester.runAsync(() async {
    final f = ['../test/golden/cas', 'test/golden/cas']
        .map((d) => File('$d/cams_detailed.txt'))
        .firstWhere((f) => f.existsSync());
    await CasImporter(db).store(const CasParser().parse(f.readAsLinesSync()),
        fileName: 'x', contentHash: 'x');
  });
  return db;
}

void main() {
  testWidgets('capital gains: current year planning and last year sales',
      (tester) async {
    final db = await dbWithCas(tester);
    await tester.pumpWidget(MaterialApp(
      home: CapitalGainsScreen(database: db, now: DateTime(2026, 9, 30)),
    ));
    await settle(tester);
    expect(find.text('FY 2026-27'), findsOneWidget);
    expect(find.text('No sales recorded this year.'), findsOneWidget);
    expect(find.textContaining('₹1,25,000 of long-term equity'), findsOneWidget);

    await tester.tap(find.byTooltip('Older year'));
    await tester.pump();
    expect(find.text('FY 2025-26'), findsOneWidget);
    expect(find.text('Short-term (equity)'), findsWidgets);
    expect(find.textContaining('cost estimated'), findsOneWidget);
    expect(find.text('Estimated tax'), findsOneWidget);

    // Fund categories are listed with guesses and can be changed.
    expect(find.text('Debt (guessed)'), findsOneWidget); // liquid fund
    await tester.tap(find.text('Parag Parikh Liquid Fund - Direct Plan - Growth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Equity').last);
    await settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('Debt (guessed)'), findsNothing);
  });

  testWidgets('loans: add, see status, try a prepayment', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(MaterialApp(
      home: LoansScreen(database: db, now: DateTime(2026, 10, 12)),
    ));
    await settle(tester);
    await tester.tap(find.text('Add loan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Home loan');
    await tester.enterText(
        find.widgetWithText(TextField, 'Amount borrowed'), '1000000');
    await tester.enterText(find.widgetWithText(TextField, 'Interest rate'), '9');
    await tester.enterText(find.widgetWithText(TextField, 'Tenure'), '10');
    await tester.pump();
    expect(find.text('Calculated: ₹12,667'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('Home loan'), findsOneWidget);

    await tester.tap(find.text('Home loan'));
    await settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('Outstanding'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Extra payment now'), '100000');
    await tester.pump();
    expect(find.textContaining('Saves ₹'), findsOneWidget);
    await tester.tap(find.text('Lower EMI'));
    await tester.pump();
    expect(find.textContaining('EMI drops to'), findsOneWidget);
  });

  testWidgets('allocation: set targets from a preset and see drift',
      (tester) async {
    final db = await dbWithCas(tester);
    await tester.pumpWidget(MaterialApp(
      home: AllocationScreen(database: db, now: DateTime(2026, 9, 30)),
    ));
    await settle(tester);
    expect(find.text('Set target percentages'), findsOneWidget);
    await tester.tap(find.text('Targets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balanced 60/30/10'));
    await tester.pump();
    expect(find.text('Adds up to 100%'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await settle(tester);
    await tester.pumpAndSettle();
    // Fixture: ~60% equity, ~40% debt, no gold → off target.
    expect(find.textContaining('consider rebalancing'), findsOneWidget);
    expect(find.textContaining('add ₹'), findsWidgets);
  });

  testWidgets('retirement: enter assumptions and see the plan', (tester) async {
    final db = await dbWithCas(tester);
    await tester.pumpWidget(MaterialApp(
      home: RetirementScreen(database: db, now: DateTime(2026, 9, 30)),
    ));
    await settle(tester);
    expect(find.text('Calculate'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Age now'), '35');
    await tester.enterText(
        find.widgetWithText(TextField, 'Monthly expenses today'), '60000');
    await tester.enterText(
        find.widgetWithText(TextField, 'Safe withdrawal rate (optional)'), '3.5');
    await tester.pump();
    await tester.tap(find.text('Calculate'));
    await settle(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('You need ₹'), findsOneWidget);
    expect(find.textContaining("in today's money"), findsOneWidget);
    expect(find.textContaining('a month from now to close the gap'),
        findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });
}

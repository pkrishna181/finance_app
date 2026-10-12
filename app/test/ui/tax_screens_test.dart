import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/ui/screens/capital_gains_screen.dart';
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
}

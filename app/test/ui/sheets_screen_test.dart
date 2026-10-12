import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:arth/ui/screens/sheets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester t, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await t.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('example sheet calculates, edits are saved', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(MaterialApp(
      home: SheetsScreen(database: db, now: DateTime(2026, 10, 12)),
    ));
    await settle(tester);
    await tester.tap(find.text('Open an example'));
    await settle(tester);
    await tester.pumpAndSettle();

    // price = 60L, down = 12L, loan = 48L, EMI at 8.5% for 20 years.
    expect(find.text('60,00,000'), findsOneWidget);
    expect(find.text('12,00,000'), findsOneWidget);
    expect(find.text('48,00,000'), findsOneWidget);
    expect(find.text('41,655.52'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a = 2\nb = a * 21\nb + 1');
    await tester.pump();
    expect(find.text('43'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700)); // save timer
    await settle(tester, 3);
    final saved = await tester.runAsync(() => SheetRepository(db).list());
    expect(saved!.single.body, 'a = 2\nb = a * 21\nb + 1');

    await tester.enterText(find.byType(TextField), 'x + 1');
    await tester.pump();
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}

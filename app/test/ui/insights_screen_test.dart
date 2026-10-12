import 'package:arth/core/db/database.dart';
import 'package:arth/ui/screens/insights_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Tall surface so the lazily built Insights list renders every card.
void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows empty state with no transactions', (tester) async {
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(
      MaterialApp(home: InsightsScreen(database: db)),
    );
    await _settle(tester);

    expect(find.textContaining('No transactions yet'), findsOneWidget);
  });

  testWidgets('renders summary, uncategorized banner and categories',
      (tester) async {
    _tallView(tester);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));

    await tester.runAsync(() async {
      final cat = await (db.select(db.categories)
            ..where((c) => c.slug.equals('groceries')))
          .getSingle();
      final now = DateTime.now();
      final at = DateTime(now.year, now.month, 2, 12);
      Future<void> add(String h, int paise, {int? catId, String d = 'debit'}) =>
          db.into(db.transactions).insert(TransactionsCompanion.insert(
                amountPaise: paise,
                direction: d,
                txnType: 'upi',
                bookedAt: at,
                bankCode: 'HDFC',
                rawMerchant: 'SHOP',
                rawDescription: 'SHOP',
                dedupeHash: h,
                categoryId: Value(catId),
              ));
      await add('g', 150000, catId: cat.id);
      await add('u', 50000);
    });

    await tester.pumpWidget(
      MaterialApp(home: InsightsScreen(database: db)),
    );
    await _settle(tester);

    expect(find.text('Spending by category'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.textContaining('1 uncategorized'), findsOneWidget);
    expect(find.text('Spend trend'), findsOneWidget);
  });

  testWidgets('drill-down recategorizes a row and reloads insights',
      (tester) async {
    _tallView(tester);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));

    await tester.runAsync(() async {
      final now = DateTime.now();
      final at = DateTime(now.year, now.month, 2, 12);
      for (final h in ['u1', 'u2']) {
        await db.into(db.transactions).insert(TransactionsCompanion.insert(
              amountPaise: 50000,
              direction: 'debit',
              txnType: 'upi',
              bookedAt: at,
              bankCode: 'HDFC',
              rawMerchant: 'UPI-SWIGGY-$h',
              rawDescription: 'x',
              dedupeHash: h,
            ));
      }
    });

    await tester.pumpWidget(
      MaterialApp(home: InsightsScreen(database: db)),
    );
    await _settle(tester);
    expect(find.textContaining('2 uncategorized'), findsOneWidget);

    await tester.tap(find.textContaining('2 uncategorized'));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('UPI-SWIGGY-u1'), findsOneWidget);

    await tester.tap(find.text('UPI-SWIGGY-u1'));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('Also apply to 1 other transaction'), findsOneWidget);
    await tester.tap(find.text('Also apply to 1 other transaction'));
    await tester.pump();
    await tester.tap(find.text('Food Delivery'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.text('Moved 2 transactions to Food Delivery'), findsOneWidget);

    await tester.pageBack();
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('uncategorized'), findsNothing);
    expect(find.text('Food Delivery'), findsWidgets);
  });
}

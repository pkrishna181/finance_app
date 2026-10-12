import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
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

  testWidgets('sets a budget from Insights and shows progress',
      (tester) async {
    _tallView(tester);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));

    await tester.runAsync(() async {
      final cat = await (db.select(db.categories)
            ..where((c) => c.slug.equals('groceries')))
          .getSingle();
      final now = DateTime.now();
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 450000,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime(now.year, now.month, 1, 12),
            bankCode: 'HDFC',
            rawMerchant: 'SHOP',
            rawDescription: 'SHOP',
            dedupeHash: 'g',
            categoryId: Value(cat.id),
          ));
    });

    await tester.pumpWidget(MaterialApp(home: InsightsScreen(database: db)));
    await _settle(tester);
    expect(find.text('Budgets'), findsOneWidget);

    await tester.tap(find.text('Set up'));
    await _settle(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5000');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('₹4,500 / ₹5,000'), findsOneWidget);

    await tester.pageBack();
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('₹4,500 of ₹5,000'), findsOneWidget);
    expect(find.textContaining('1 near limit'), findsOneWidget);
  });

  testWidgets('year view shows the statement and jumps back to a month',
      (tester) async {
    _tallView(tester);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));

    await tester.runAsync(() async {
      Future<int> cat(String slug) async => (await (db.select(db.categories)
                ..where((c) => c.slug.equals(slug)))
              .getSingle())
          .id;
      Future<void> add(String h, int paise, DateTime at, String slug,
              {String d = 'debit'}) async =>
          db.into(db.transactions).insert(TransactionsCompanion.insert(
                amountPaise: paise,
                direction: d,
                txnType: 'upi',
                bookedAt: at,
                bankCode: 'HDFC',
                rawMerchant: 'X',
                rawDescription: 'X',
                dedupeHash: h,
                categoryId: Value(await cat(slug)),
              ));
      await add('s', 10000000, DateTime(2025, 5, 1, 10), 'salary', d: 'credit');
      await add('g', 300000, DateTime(2025, 5, 3, 10), 'groceries');
      await add('f', 100000, DateTime(2025, 8, 3, 10), 'fuel');
    });

    await tester.pumpWidget(MaterialApp(home: InsightsScreen(database: db)));
    await _settle(tester);
    await tester.tap(find.text('Aug 2025'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.text('FY 2025-26'), findsOneWidget);
    expect(find.text('Income statement'), findsOneWidget);
    expect(find.text('Where the income went'), findsOneWidget);
    expect(find.text('Daily spending'), findsOneWidget);
    expect(find.text('Total spending'), findsOneWidget);
    expect(find.text('96%'), findsOneWidget); // savings rate

    await tester.tap(find.text('May 2025'));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.text('Income statement'), findsNothing);
    expect(find.text('May 2025'), findsOneWidget);
  });

  testWidgets('search finds rows and bulk-changes their category',
      (tester) async {
    _tallView(tester);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));

    await tester.runAsync(() async {
      final now = DateTime.now();
      for (final (h, raw) in [('a', 'ZOMATO 1'), ('b', 'ZOMATO 2'), ('c', 'UBER')]) {
        await db.into(db.transactions).insert(TransactionsCompanion.insert(
              amountPaise: 30000,
              direction: 'debit',
              txnType: 'upi',
              bookedAt: DateTime(now.year, now.month, 1, 12),
              bankCode: 'HDFC',
              rawMerchant: raw,
              rawDescription: raw,
              dedupeHash: h,
            ));
      }
    });

    await tester.pumpWidget(MaterialApp(home: InsightsScreen(database: db)));
    await _settle(tester);
    await tester.tap(find.byTooltip('Search transactions'));
    await _settle(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zomato');
    await tester.pump(const Duration(milliseconds: 300));
    await _settle(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('2 results'), findsOneWidget);

    await tester.longPress(find.text('ZOMATO 1'));
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.byTooltip('Select all'));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Change category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food Delivery'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.text('Moved 2 transactions to Food Delivery'), findsOneWidget);
    expect(find.textContaining('Food Delivery'), findsWidgets);
    final rows = await tester.runAsync(() => InsightsRepository(db)
        .search(TxnQuery.parse('cat:food_delivery')));
    expect(rows, hasLength(2));
  });
}

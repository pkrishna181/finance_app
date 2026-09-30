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
}

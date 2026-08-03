import 'package:arth/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arth shell shows Home and navigates to Import', (tester) async {
    await tester.pumpWidget(const ArthApp());

    expect(find.text('Arth'), findsWidgets);

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a source'), findsOneWidget);
    expect(find.text('Transaction SMS'), findsOneWidget);
    expect(find.text('CSV / Excel / PDF statement'), findsOneWidget);
  });

  testWidgets('bottom nav has four destinations', (tester) async {
    await tester.pumpWidget(const ArthApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Ask'), findsOneWidget);
  });
}

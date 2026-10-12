import 'dart:typed_data';

import 'package:arth/core/db/database.dart';
import 'package:arth/ui/screens/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester t, [int n = 15]) async {
  for (var i = 0; i < n; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await t.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('create a backup, then restore it into a fresh database',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final src = ArthDatabase.memory();
    final dst = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(() async {
          await src.close();
          await dst.close();
        }));
    await tester.runAsync(() => src.into(src.transactions).insert(
          TransactionsCompanion.insert(
            amountPaise: 100,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime(2026, 9, 1),
            bankCode: 'HDFC',
            rawMerchant: 'CHAI',
            rawDescription: 'CHAI',
            dedupeHash: 'c',
          ),
        ));

    Uint8List? saved;
    String? savedName;
    await tester.pumpWidget(MaterialApp(
      home: BackupScreen(
        key: const ValueKey('src'),
        database: src,
        iterations: 1000,
        saveFile: (name, bytes) async {
          savedName = name;
          saved = bytes;
          return '/tmp/$name';
        },
      ),
    ));
    await settle(tester, 3);
    await tester.tap(find.text('Create backup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Passphrase'), 'short');
    await tester.pump();
    final create = find.widgetWithText(FilledButton, 'Create');
    expect(tester.widget<FilledButton>(create).onPressed, isNull);
    await tester.enterText(
        find.widgetWithText(TextField, 'Passphrase'), 'blue tram kettle');
    await tester.enterText(
        find.widgetWithText(TextField, 'Repeat it'), 'blue tram kettle');
    await tester.pump();
    await tester.tap(create);
    await settle(tester);
    expect(find.text('Backup saved.'), findsOneWidget);
    expect(savedName, endsWith('.arthbak'));

    await tester.pumpWidget(MaterialApp(
      key: const ValueKey('restore-app'),
      home: BackupScreen(
        key: const ValueKey('dst'),
        database: dst,
        iterations: 1000,
        pickFile: () async => saved,
      ),
    ));
    await settle(tester, 3);
    await tester.tap(find.text('Restore from backup'));
    await settle(tester, 3);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Passphrase'), 'wrong pass');
    await tester.pump();
    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(find.textContaining('Wrong passphrase'), findsOneWidget);

    await tester.tap(find.text('Restore from backup'));
    await settle(tester, 3);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Passphrase'), 'blue tram kettle');
    await tester.pump();
    await tester.tap(find.text('Open'));
    for (var i = 0;
        i < 50 && find.textContaining('with 1 transactions').evaluate().isEmpty;
        i++) {
      await settle(tester, 1);
    }
    expect(find.textContaining('with 1 transactions'), findsOneWidget);
    await tester.tap(find.text('Replace'));
    bool done() =>
        find.textContaining('Restored').evaluate().isNotEmpty ||
        find.textContaining('Couldn').evaluate().isNotEmpty;
    for (var i = 0; i < 100 && !done(); i++) {
      await settle(tester, 1);
    }
    expect(find.textContaining('Restored'), findsOneWidget,
        reason: tester
            .widgetList<Text>(find.descendant(
                of: find.byType(SnackBar), matching: find.byType(Text)))
            .map((t) => t.data)
            .join());
    final rows = await tester.runAsync(() => dst.select(dst.transactions).get());
    expect(rows!.single.rawMerchant, 'CHAI');
  });
}

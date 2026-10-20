import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/llm/fake_llm_engine.dart';
import 'package:arth/llm/jobs/llm_batch_coordinator.dart';
import 'package:arth/llm/model_download_manager.dart';
import 'package:arth/ui/screens/ask_screen.dart';
import 'package:arth/ui/screens/search_screen.dart';
import 'package:drift/drift.dart' show Value;
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

class _Downloader extends ModelDownloadManager {
  _Downloader(this.downloaded);
  final bool downloaded;

  @override
  Future<bool> isDownloaded() async => downloaded;

  @override
  Future<File> modelFilePath() async => File('fake.gguf');
}

void main() {
  final now = DateTime(2026, 10, 20, 14);

  Future<ArthDatabase> seeded(WidgetTester tester) async {
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    await tester.runAsync(() async {
      var n = 0;
      Future<void> add(String raw, int rupees, DateTime at, String cat) async {
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                amountPaise: rupees * 100,
                direction: 'debit',
                txnType: 'upi',
                bookedAt: at,
                bankCode: 'HDFC',
                rawMerchant: raw,
                rawDescription: raw,
                dedupeHash: 'h${n++}',
                categoryId: Value((await db.categoryBySlug(cat))!.id),
              ),
            );
      }

      await add('SWIGGY BLR', 450, DateTime(2026, 9, 3), 'food_delivery');
      await add('LANDLORD', 25000, DateTime(2026, 9, 5), 'rent');
    });
    return db;
  }

  Future<void> pump(
    WidgetTester tester,
    ArthDatabase db, {
    LlmBatchCoordinator? coordinator,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: AskScreen(database: db, coordinator: coordinator, now: () => now),
      ),
    );
    await settle(tester, 2);
  }

  testWidgets('a suggestion is answered and opens its transactions', (
    tester,
  ) async {
    final db = await seeded(tester);
    await pump(tester, db);
    expect(find.text('Ask about your money'), findsOneWidget);

    await tester.tap(find.text('How much did I spend last month?'));
    await settle(tester);
    expect(
      find.text('You spent ₹25,450 in Sep 2026 (2 payments).'),
      findsOneWidget,
    );
    expect(find.text('Spending · Sep 2026'), findsOneWidget);

    await tester.tap(find.text('See transactions'));
    await settle(tester);
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('typed question with a merchant', (tester) async {
    final db = await seeded(tester);
    await pump(tester, db);
    await tester.enterText(find.byType(TextField), 'swiggy in september');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await settle(tester);
    expect(
      find.text('You spent ₹450 at "swiggy" in Sep 2026 (1 payment).'),
      findsOneWidget,
    );
  });

  testWidgets('unreadable question without a model offers suggestions', (
    tester,
  ) async {
    final db = await seeded(tester);
    await pump(
      tester,
      db,
      coordinator: LlmBatchCoordinator(
        engine: FakeLlmEngine(),
        downloader: _Downloader(false),
      ),
    );
    await tester.enterText(
      find.byType(TextField),
      'did the zorblax cost a lot',
    );
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await settle(tester);
    expect(find.textContaining('didn\'t recognise "zorblax"'), findsOneWidget);
    expect(find.text('On-device AI model'), findsOneWidget);
  });

  testWidgets('unreadable question goes to the model, answer is computed', (
    tester,
  ) async {
    final db = await seeded(tester);
    final engine = FakeLlmEngine(
      jsonResponse: '{"intent":"spend","category":"rent"}',
    );
    await pump(
      tester,
      db,
      coordinator: LlmBatchCoordinator(
        engine: engine,
        downloader: _Downloader(true),
      ),
    );
    await tester.enterText(
      find.byType(TextField),
      'what did the roof over my head cost in sept',
    );
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await settle(tester);
    expect(engine.lastPrompt, contains('roof over my head'));
    expect(
      find.text('You spent ₹25,000 on Rent in Sep 2026 (1 payment).'),
      findsOneWidget,
    );
    expect(
      find.text('Read by the on-device model as: Spending · Rent · Sep 2026'),
      findsOneWidget,
    );
  });
}

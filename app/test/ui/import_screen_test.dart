import 'dart:async';

import 'package:arth/core/db/database.dart';
import 'package:arth/core/result/result.dart';
import 'package:arth/ingestion/registry.dart';
import 'package:arth/ingestion/sms/consent_screen.dart';
import 'package:arth/ingestion/sms/sms_scan_session.dart';
import 'package:arth/ingestion/sms/sms_source.dart';
import 'package:arth/ingestion/source.dart';
import 'package:arth/ui/screens/import_screen.dart';
import 'package:arth/ui/screens/sms_historical_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSmsIngestionSource extends SmsIngestionSource {
  FakeSmsIngestionSource({
    SmsConsentStore? consentStore,
    this.progressStream,
  }) : super(consentStore: consentStore);

  int scanInvocations = 0;
  final Stream<SmsIngestProgress>? progressStream;

  @override
  Future<bool> hasPermission() async => true;

  @override
  SourceAvailability get availability => SourceAvailability.available;

  @override
  Future<Result<void>> requestPermission() async => const Ok(null);

  @override
  Stream<SmsIngestProgress> scanHistorical({
    required ArthDatabase db,
    int pageSize = 100,
    int chunkSize = 50,
    bool restart = false,
    SmsScanSession? session,
  }) {
    scanInvocations++;
    return progressStream ??
        Stream.value(
          const SmsIngestProgress(
            scanned: 3,
            parsed: 2,
            inserted: 1,
            unparsed: 1,
            skipped: 5,
            mandates: 0,
            done: true,
          ),
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImportScreen SMS historical scan', () {
    late ArthDatabase db;
    late SmsConsentStore consent;
    late FakeSmsIngestionSource fakeSms;

    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      db = ArthDatabase.memory();
      consent = SmsConsentStore();
      fakeSms = FakeSmsIngestionSource(consentStore: consent);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('tap → consent → permission → scan invoked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImportScreen(
            database: db,
            consentStore: consent,
            registry: IngestionRegistry(sources: [fakeSms]),
            showUnparsedBadge: false,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Transaction SMS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Read transaction SMS on this phone'), findsOneWidget);
      await tester.tap(find.text('Allow SMS reading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeSms.scanInvocations, 1);
      expect(find.byType(SmsHistoricalScanScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('skips consent screen when consent already granted', (tester) async {
      await consent.accept();

      await tester.pumpWidget(
        MaterialApp(
          home: ImportScreen(
            database: db,
            consentStore: consent,
            registry: IngestionRegistry(sources: [fakeSms]),
            showUnparsedBadge: false,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Transaction SMS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Read transaction SMS on this phone'), findsNothing);
      expect(fakeSms.scanInvocations, 1);
      expect(find.byType(SmsHistoricalScanScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('SmsHistoricalScanScreen', () {
    late ArthDatabase db;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = ArthDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('progress stream events update UI', (tester) async {
      final controller = StreamController<SmsIngestProgress>();
      final fake = FakeSmsIngestionSource(progressStream: controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: SmsHistoricalScanScreen(source: fake, db: db, restart: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      controller.add(
        const SmsIngestProgress(
          scanned: 12,
          parsed: 4,
          inserted: 3,
          unparsed: 2,
          skipped: 8,
          mandates: 0,
          done: false,
        ),
      );
      await tester.pump();

      expect(find.textContaining('Scanned 12'), findsOneWidget);
      expect(find.text('Unrecognized: 2'), findsOneWidget);
      expect(find.text('Transactions found: 4 (3 new)'), findsOneWidget);

      controller.add(
        const SmsIngestProgress(
          scanned: 20,
          parsed: 5,
          inserted: 4,
          unparsed: 3,
          skipped: 10,
          mandates: 0,
          done: true,
        ),
      );
      await tester.pump();

      expect(find.text('Scan complete'), findsOneWidget);

      await controller.close();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('complete with unparsed shows resolve button', (tester) async {
      final fake = FakeSmsIngestionSource(
        progressStream: Stream.value(
          const SmsIngestProgress(
            scanned: 10,
            parsed: 7,
            inserted: 6,
            unparsed: 3,
            skipped: 2,
            mandates: 0,
            done: true,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SmsHistoricalScanScreen(source: fake, db: db, restart: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('3 unrecognized — resolve'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}

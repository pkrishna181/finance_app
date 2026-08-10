import 'dart:async';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/sms/native_sms_inbox.dart';
import 'package:arth/ingestion/sms/sms_scan_checkpoint.dart';
import 'package:arth/ingestion/sms/sms_scan_session.dart';
import 'package:arth/ingestion/sms/sms_source.dart';
import 'package:flutter_test/flutter_test.dart';

class MemorySmsScanCheckpointStore extends SmsScanCheckpointStore {
  SmsScanCheckpoint? _data;

  @override
  Future<SmsScanCheckpoint?> load() async => _data;

  @override
  Future<void> save(SmsScanCheckpoint checkpoint) async {
    _data = checkpoint;
  }

  @override
  Future<void> clear() async {
    _data = null;
  }

  @override
  Future<bool> hasCheckpoint() async => _data != null;
}

class FakeNativeSmsInbox extends NativeSmsInbox {
  FakeNativeSmsInbox(this._messages);

  final List<NativeSmsMessage> _messages;
  final List<int?> beforeDatesUsed = [];

  @override
  Future<List<NativeSmsMessage>> queryPage({
    required int limit,
    int? beforeDateMillis,
    List<String>? entities,
  }) async {
    beforeDatesUsed.add(beforeDateMillis);
    final filtered = _messages
        .where((m) =>
            beforeDateMillis == null ||
            (m.dateMillis != null && m.dateMillis! < beforeDateMillis))
        .toList();
    return filtered.take(limit).toList(growable: false);
  }

  @override
  Future<int> countMessages({List<String>? entities}) async {
    return _messages.length;
  }
}

class TestSmsIngestionSource extends SmsIngestionSource {
  TestSmsIngestionSource({
    required NativeSmsInbox inbox,
    required SmsScanCheckpointStore checkpointStore,
  }) : super(inbox: inbox, checkpointStore: checkpointStore);

  @override
  Future<bool> hasPermission() async => true;
}

NativeSmsMessage _txnSms({
  required int dateMillis,
  required String body,
  String sender = 'HDFCBK',
}) {
  return NativeSmsMessage(sender: sender, body: body, dateMillis: dateMillis);
}

void main() {
  late ArthDatabase db;
  late MemorySmsScanCheckpointStore checkpoints;
  late FakeNativeSmsInbox inbox;
  late TestSmsIngestionSource source;

  const sms1 =
      'HDFC Bank: Rs.100.00 debited from a/c **1234 on 15-07-26 to VPA shop@ybl '
      '(UPI Ref 412345678901). Not you? Call 18002586161';
  const sms2 =
      'HDFC Bank: Rs.200.00 debited from a/c **1234 on 14-07-26 to VPA food@ybl '
      '(UPI Ref 412345678902). Not you? Call 18002586161';

  setUp(() {
    db = ArthDatabase.memory();
    checkpoints = MemorySmsScanCheckpointStore();
    inbox = FakeNativeSmsInbox([
      _txnSms(dateMillis: 3000, body: sms1),
      _txnSms(dateMillis: 2000, body: sms2),
      _txnSms(
        dateMillis: 1000,
        body: 'Your OTP is 123456. Do not share.',
        sender: 'HDFCBK',
      ),
    ]);
    source = TestSmsIngestionSource(
      inbox: inbox,
      checkpointStore: checkpoints,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<SmsIngestProgress> _runUntilCancelled() async {
    final session = SmsScanSession();
    SmsIngestProgress? last;
    await for (final p in source.scanHistorical(
      db: db,
      pageSize: 1,
      chunkSize: 1,
      session: session,
    )) {
      last = p;
      if (!p.done) session.requestCancel();
    }
    return last!;
  }

  test('cancel between chunks saves checkpoint and reports summary', () async {
    final session = SmsScanSession();
    final progress = <SmsIngestProgress>[];

    final sub = source
        .scanHistorical(
          db: db,
          pageSize: 2,
          chunkSize: 1,
          session: session,
        )
        .listen((p) {
      progress.add(p);
      if (progress.length == 1) session.requestCancel();
    });

    await sub.asFuture();

    expect(progress.last.done, isTrue);
    expect(progress.last.cancelled, isTrue);
    expect(progress.last.scanned, greaterThan(0));

    final cp = await checkpoints.load();
    expect(cp, isNotNull);
    expect(cp!.scanned, progress.last.scanned);

    final txns = await db.select(db.transactions).get();
    expect(txns, isNotEmpty);
  });

  test('resume from checkpoint skips already-scanned newest range', () async {
    final partial = await _runUntilCancelled();
    final cp = await checkpoints.load();
    expect(cp, isNotNull);

    inbox.beforeDatesUsed.clear();
    final resumed = await source
        .scanHistorical(db: db, pageSize: 1, chunkSize: 1)
        .toList();

    expect(resumed.last.scanned, greaterThan(partial.scanned));
    expect(inbox.beforeDatesUsed.first, cp!.lastProcessedDateMillis);
  });

  test('restart clears checkpoint and rescans from newest', () async {
    await _runUntilCancelled();
    expect(await checkpoints.load(), isNotNull);

    inbox.beforeDatesUsed.clear();
    final restarted = await source
        .scanHistorical(
          db: db,
          pageSize: 1,
          chunkSize: 1,
          restart: true,
        )
        .toList();

    expect(await checkpoints.load(), isNull);
    expect(restarted.last.done, isTrue);
    expect(restarted.last.cancelled, isFalse);
    expect(inbox.beforeDatesUsed.first, isNull);
  });

  test('progressive writes — transactions visible before scan completes', () async {
    final session = SmsScanSession();
    var seenDuringScan = 0;

    await for (final p in source.scanHistorical(
      db: db,
      pageSize: 1,
      chunkSize: 1,
      session: session,
    )) {
      if (!p.done) {
        seenDuringScan = (await db.select(db.transactions).get()).length;
        session.requestCancel();
      }
    }

    expect(seenDuringScan, greaterThan(0));
  });
}

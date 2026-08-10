import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/db/database.dart';
import '../../core/models/sms_parse_models.dart';
import '../../core/result/result.dart';
import '../../parsing/sms/regex_sms_parser.dart';
import '../../parsing/sms/sender_matcher.dart';
import '../source.dart';
import 'consent_screen.dart';
import 'native_sms_inbox.dart';
import 'sms_scan_checkpoint.dart';
import 'sms_scan_session.dart';

/// Android SMS ingestion with consent + READ_SMS + paginated historical scan.
class SmsIngestionSource implements IngestionSource {
  SmsIngestionSource({
    SmsConsentStore? consentStore,
    NativeSmsInbox? inbox,
    SmsScanCheckpointStore? checkpointStore,
  })  : _consent = consentStore ?? SmsConsentStore(),
        _inbox = inbox ?? NativeSmsInbox(),
        _checkpointStore = checkpointStore ?? SmsScanCheckpointStore();

  final SmsConsentStore _consent;
  final NativeSmsInbox _inbox;
  final SmsScanCheckpointStore _checkpointStore;

  @override
  String get id => 'sms';

  @override
  String get displayName => 'Transaction SMS';

  @override
  SourceAvailability get availability {
    if (Platform.isAndroid) return SourceAvailability.available;
    return SourceAvailability.unsupportedOnPlatform;
  }

  SmsScanCheckpointStore get checkpointStore => _checkpointStore;

  @override
  Future<bool> hasPermission() async {
    if (availability != SourceAvailability.available) return false;
    if (!await _consent.hasConsent()) return false;
    return Permission.sms.isGranted;
  }

  @override
  Future<Result<void>> requestPermission() async {
    if (availability != SourceAvailability.available) {
      return const Err(
        'SMS ingestion is not available on this platform. '
        'Import a bank statement instead.',
      );
    }
    if (!await _consent.hasConsent()) {
      return const Err('sms_consent_required');
    }
    final status = await Permission.sms.request();
    if (status.isGranted) return const Ok(null);
    if (status.isPermanentlyDenied) {
      return const Err('sms_permission_permanently_denied');
    }
    return const Err('sms_permission_denied');
  }

  /// Paginated historical inbox scan (newest-first). Cooperative cancel via
  /// [session]; checkpoint persisted after each committed parse chunk.
  Stream<SmsIngestProgress> scanHistorical({
    required ArthDatabase db,
    int pageSize = 100,
    int chunkSize = 50,
    bool restart = false,
    SmsScanSession? session,
  }) async* {
    final scanSession = session ?? SmsScanSession();

    if (!await hasPermission()) {
      yield const SmsIngestProgress(
        scanned: 0,
        parsed: 0,
        inserted: 0,
        unparsed: 0,
        skipped: 0,
        mandates: 0,
        done: true,
        error: 'sms_permission_denied',
      );
      return;
    }

    if (restart) {
      await _checkpointStore.clear();
    }

    final existing = restart ? null : await _checkpointStore.load();

    var scanned = existing?.scanned ?? 0;
    var parsed = existing?.parsed ?? 0;
    var inserted = existing?.inserted ?? 0;
    var unparsed = existing?.unparsed ?? 0;
    var skipped = existing?.skipped ?? 0;
    var mandates = existing?.mandates ?? 0;
    int? importId = existing?.importId;
    int? beforeDateMillis = existing?.lastProcessedDateMillis;
    int? scanBoundaryMillis = existing?.lastProcessedDateMillis;

    final estimatedTotal = existing?.estimatedTotal ??
        await _inbox.countMessages(entities: knownSenderEntities);

    if (importId == null) {
      final importHash = sha256
          .convert(
            utf8.encode('sms-scan-${DateTime.now().toUtc().toIso8601String()}'),
          )
          .toString();
      importId = await db.into(db.imports).insert(
            ImportsCompanion.insert(
              sourceType: 'sms',
              sourceLabel: 'Historical SMS scan',
              contentHash: importHash,
              status: const Value('pending'),
            ),
          );
    }

  var cancelled = false;

    while (true) {
      if (scanSession.isCancelled) {
        cancelled = true;
        break;
      }

      final pageStart = DateTime.now();
      final page = await _inbox.queryPage(
        limit: pageSize,
        beforeDateMillis: beforeDateMillis,
        entities: knownSenderEntities,
      );
      if (page.isEmpty) break;

      int? pageMinDateMillis;
      final candidates = <_SmsWire>[];
      for (final m in page) {
        if (m.dateMillis != null) {
          final d = m.dateMillis!;
          pageMinDateMillis =
              pageMinDateMillis == null ? d : (d < pageMinDateMillis! ? d : pageMinDateMillis);
          scanBoundaryMillis = scanBoundaryMillis == null
              ? d
              : (d < scanBoundaryMillis! ? d : scanBoundaryMillis);
        }
        scanned++;
        final match = matchSender(m.sender);
        if (!match.isTransactional) {
          skipped++;
          continue;
        }
        candidates.add(
          _SmsWire(
            body: m.body,
            sender: m.sender,
            receivedAtMs: m.dateMillis,
          ),
        );
      }

      for (var i = 0; i < candidates.length; i += chunkSize) {
        if (scanSession.isCancelled) {
          cancelled = true;
          break;
        }

        final chunkStart = DateTime.now();
        final end = (i + chunkSize < candidates.length)
            ? i + chunkSize
            : candidates.length;
        final chunk = candidates.sublist(i, end);
        final outcomes = await Isolate.run(() => _parseChunk(chunk));

        for (final o in outcomes) {
          switch (o.kind) {
            case _OutcomeKind.skipped:
              skipped++;
            case _OutcomeKind.mandate:
              mandates++;
              await db.insertMandateNotice(
                MandateNoticesCompanion.insert(
                  bankCode: o.bankCode ?? 'UNKNOWN',
                  rawBody: o.rawBody!,
                  amountPaise: Value(o.amountPaise),
                  merchant: Value(o.merchant),
                  accountHint: Value(o.accountHint),
                  sender: Value(o.sender),
                  receivedAt: Value(
                    o.receivedAtMs == null
                        ? null
                        : DateTime.fromMillisecondsSinceEpoch(o.receivedAtMs!),
                  ),
                ),
              );
            case _OutcomeKind.unparsed:
              unparsed++;
              await db.insertUnparsedSms(
                UnparsedSmsRowsCompanion.insert(
                  rawBody: o.rawBody!,
                  reason: o.reason ?? 'no_template_match',
                  sender: Value(o.sender),
                  bankCode: Value(o.bankCode),
                  receivedAt: Value(
                    o.receivedAtMs == null
                        ? null
                        : DateTime.fromMillisecondsSinceEpoch(o.receivedAtMs!),
                  ),
                ),
              );
            case _OutcomeKind.transaction:
              parsed++;
              final hash = buildDedupeHash(
                bankCode: o.bankCode!,
                bookedAt: DateTime.parse(o.bookedAtIso!),
                amountPaise: o.amountPaise!,
                ref: o.externalRef,
                normalizedBody: o.rawBody,
              );
              final write = await db.upsertTransactionWithProvenance(
                TransactionsCompanion.insert(
                  amountPaise: o.amountPaise!,
                  direction: o.direction!,
                  txnType: o.txnType!,
                  bookedAt: DateTime.parse(o.bookedAtIso!),
                  bankCode: o.bankCode!,
                  rawMerchant: o.merchant ?? 'Unknown',
                  rawDescription: o.rawBody!,
                  dedupeHash: hash,
                  accountHint: Value(o.accountHint),
                  upiPayerVpa: Value(o.payerVpa),
                  upiPayeeVpa: Value(o.payeeVpa),
                  upiRef: Value(o.upiRef),
                  remarks: Value(o.remarks),
                  externalRef: Value(o.externalRef),
                  balanceAfterPaise: Value(o.balanceAfterPaise),
                  importId: Value(importId),
                ),
                importId: importId!,
              );
              if (write.inserted) inserted++;
          }
        }

        final chunkMinDate = _minDateMillis(chunk);
        final checkpointDate = scanBoundaryMillis ?? chunkMinDate ?? pageMinDateMillis;
        if (checkpointDate != null) {
          await _checkpointStore.save(
            SmsScanCheckpoint(
              lastProcessedDateMillis: checkpointDate,
              scanned: scanned,
              parsed: parsed,
              inserted: inserted,
              unparsed: unparsed,
              skipped: skipped,
              mandates: mandates,
              importId: importId,
              estimatedTotal: estimatedTotal,
            ),
          );
        }

        final chunkMs = DateTime.now().difference(chunkStart).inMilliseconds;
        developer.log(
          'sms_scan chunk: ${chunk.length} txn candidates, '
          '${chunkMs}ms (page ${page.length} msgs, ${pageSize} cap)',
          name: 'SmsIngestionSource',
        );

        yield SmsIngestProgress(
          scanned: scanned,
          parsed: parsed,
          inserted: inserted,
          unparsed: unparsed,
          skipped: skipped,
          mandates: mandates,
          done: false,
          estimatedTotal: estimatedTotal,
          chunkMessageCount: chunk.length,
          lastChunkMs: chunkMs,
        );

        if (scanSession.isCancelled) {
          cancelled = true;
          break;
        }
      }

      if (cancelled) break;

      final pageMs = DateTime.now().difference(pageStart).inMilliseconds;
      developer.log(
        'sms_scan page: ${page.length} inbox rows, ${pageMs}ms '
        '(~$estimatedTotal matching senders, chunk=$chunkSize)',
        name: 'SmsIngestionSource',
      );

      if (page.length < pageSize) break;
      if (scanBoundaryMillis == null) break;
      beforeDateMillis = scanBoundaryMillis;
    }

    if (!cancelled) {
      await _checkpointStore.clear();
      await (db.update(db.imports)..where((t) => t.id.equals(importId!))).write(
        ImportsCompanion(
          status: const Value('succeeded'),
          rowCount: Value(inserted),
          parsedCount: Value(parsed),
          skippedCount: Value(skipped),
          duplicateCount: Value(parsed - inserted),
        ),
      );
    } else {
      await (db.update(db.imports)..where((t) => t.id.equals(importId!))).write(
        ImportsCompanion(
          status: const Value('partial'),
          rowCount: Value(inserted),
          parsedCount: Value(parsed),
          skippedCount: Value(skipped),
          duplicateCount: Value(parsed - inserted),
        ),
      );
    }

    yield SmsIngestProgress(
      scanned: scanned,
      parsed: parsed,
      inserted: inserted,
      unparsed: unparsed,
      skipped: skipped,
      mandates: mandates,
      done: true,
      cancelled: cancelled,
      estimatedTotal: estimatedTotal,
    );
  }
}

int? _minDateMillis(List<_SmsWire> chunk) {
  int? min;
  for (final m in chunk) {
    final d = m.receivedAtMs;
    if (d == null) continue;
    min = min == null ? d : (d < min ? d : min);
  }
  return min;
}

class SmsIngestProgress {
  const SmsIngestProgress({
    required this.scanned,
    required this.parsed,
    required this.inserted,
    required this.unparsed,
    required this.skipped,
    required this.mandates,
    required this.done,
    this.error,
    this.cancelled = false,
    this.estimatedTotal,
    this.chunkMessageCount,
    this.lastChunkMs,
  });

  final int scanned;
  final int parsed;
  final int inserted;
  final int unparsed;
  final int skipped;
  final int mandates;
  final bool done;
  final String? error;
  final bool cancelled;
  final int? estimatedTotal;
  final int? chunkMessageCount;
  final int? lastChunkMs;
}

class _SmsWire {
  const _SmsWire({
    required this.body,
    this.sender,
    this.receivedAtMs,
  });

  final String body;
  final String? sender;
  final int? receivedAtMs;
}

enum _OutcomeKind { skipped, transaction, mandate, unparsed }

class _ParseOutcome {
  const _ParseOutcome({
    required this.kind,
    this.rawBody,
    this.sender,
    this.receivedAtMs,
    this.bankCode,
    this.amountPaise,
    this.merchant,
    this.accountHint,
    this.direction,
    this.txnType,
    this.bookedAtIso,
    this.externalRef,
    this.upiRef,
    this.payerVpa,
    this.payeeVpa,
    this.remarks,
    this.balanceAfterPaise,
    this.reason,
  });

  final _OutcomeKind kind;
  final String? rawBody;
  final String? sender;
  final int? receivedAtMs;
  final String? bankCode;
  final int? amountPaise;
  final String? merchant;
  final String? accountHint;
  final String? direction;
  final String? txnType;
  final String? bookedAtIso;
  final String? externalRef;
  final String? upiRef;
  final String? payerVpa;
  final String? payeeVpa;
  final String? remarks;
  final int? balanceAfterPaise;
  final String? reason;
}

List<_ParseOutcome> _parseChunk(List<_SmsWire> chunk) {
  final parser = RegexSmsParser();
  final out = <_ParseOutcome>[];
  for (final msg in chunk) {
    final received = msg.receivedAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(msg.receivedAtMs!);
    final result = parser.parseDetailed(
      body: msg.body,
      sender: msg.sender,
      receivedAt: received,
    );
    result.when(
      ok: (success) {
        if (success.isSkipped) {
          out.add(const _ParseOutcome(kind: _OutcomeKind.skipped));
          return;
        }
        if (success.hasMandate) {
          final m = success.mandate!;
          out.add(
            _ParseOutcome(
              kind: _OutcomeKind.mandate,
              rawBody: m.rawBody,
              sender: msg.sender,
              receivedAtMs: msg.receivedAtMs,
              bankCode: m.bankCode,
              amountPaise: m.amountPaise?.paise,
              merchant: m.merchant,
              accountHint: m.accountHint,
            ),
          );
          return;
        }
        for (final t in success.transactions) {
          out.add(
            _ParseOutcome(
              kind: _OutcomeKind.transaction,
              rawBody: t.rawDescription,
              sender: msg.sender,
              receivedAtMs: msg.receivedAtMs,
              bankCode: t.bankCode,
              amountPaise: t.amountPaise.paise,
              merchant: t.rawMerchant,
              accountHint: t.accountHint,
              direction: t.direction.wireName,
              txnType: t.type.wireName,
              bookedAtIso: t.bookedAt.toUtc().toIso8601String(),
              externalRef: t.externalRef,
              upiRef: t.upiRef,
              payerVpa: t.upiPayerVpa,
              payeeVpa: t.upiPayeeVpa,
              remarks: t.remarks,
              balanceAfterPaise: t.balanceAfterPaise?.paise,
            ),
          );
        }
      },
      err: (message, cause) {
        final u = cause is UnparsedSms
            ? cause
            : UnparsedSms(
                rawBody: msg.body,
                sender: msg.sender,
                reason: message,
              );
        out.add(
          _ParseOutcome(
            kind: _OutcomeKind.unparsed,
            rawBody: u.rawBody,
            sender: u.sender ?? msg.sender,
            receivedAtMs: msg.receivedAtMs,
            bankCode: u.bankCode,
            reason: u.reason,
          ),
        );
      },
    );
  }
  return out;
}

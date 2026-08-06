import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;

import '../../core/db/database.dart';
import '../../core/models/transaction_type.dart';
import '../../core/result/result.dart';
import '../anchoring.dart';
import '../category_rule_engine.dart';
import '../llm_engine.dart';
import '../llama_cpp_engine.dart';
import '../merchant_seed_catalog.dart';
import '../llm_disagreement_recorder.dart';
import '../parsed_transaction_validator.dart';
import '../prompts/categorize_prompt.dart';
import '../prompts/gemma3_chat.dart';
import '../prompts/merchant_normalize_prompt.dart';
import '../prompts/sms_parse_prompt.dart';
import 'battery_guard.dart';
import 'llm_job_payload.dart';
import 'llm_job_types.dart';

/// Batch processor for [LlmJobs]. One job at a time; model kept loaded.
class LlmJobRunner {
  LlmJobRunner({
    required this.db,
    required this.engine,
    BatteryGuard? batteryGuard,
    this.maxAttempts = 2,
    ParsedTransactionJsonValidator? validator,
    Future<String> Function(String path)? loadGrammar,
  })  : batteryGuard = batteryGuard ?? PermissiveBatteryGuard(),
        validator = validator ?? const ParsedTransactionJsonValidator(),
        loadGrammar = loadGrammar ?? rootBundle.loadString;

  final ArthDatabase db;
  final LlmEngine engine;
  final BatteryGuard batteryGuard;
  final int maxAttempts;
  final ParsedTransactionJsonValidator validator;
  final Future<String> Function(String path) loadGrammar;

  bool _running = false;
  Uint8List? _smsPrefixState;

  Future<LlmBatchReport> runPendingBatch({bool force = false}) async {
    if (_running) return const LlmBatchReport(skipped: 'already_running');
    _running = true;
    try {
      if (!engine.isReady) {
        return const LlmBatchReport(skipped: 'engine_not_ready');
      }
      if (!force && !await batteryGuard.mayRunLlmBatch()) {
        return const LlmBatchReport(skipped: 'battery_guard');
      }

      final jobs = await db.fetchPendingJobs();
      if (jobs.isEmpty) return const LlmBatchReport(processed: 0);

      var processed = 0;
      var failed = 0;
      final timings = <LlmJobTiming>[];

      for (final job in jobs) {
        if (!force && !await batteryGuard.mayRunLlmBatch()) break;
        final type = LlmJobType.fromWire(job.jobType);
        if (type == null) {
          await _failJob(job.id, 'unknown_job_type');
          failed++;
          continue;
        }
        if (job.attempts >= maxAttempts) {
          await _failJob(job.id, 'max_attempts');
          failed++;
          continue;
        }

        await db.updateLlmJob(
          job.id,
          LlmJobsCompanion(
            status: const Value('running'),
            attempts: Value(job.attempts + 1),
            updatedAt: Value(DateTime.now()),
          ),
        );

        final sw = Stopwatch()..start();
        final result = await _dispatch(type, job.payloadJson, jobId: job.id);
        sw.stop();
        timings.add(LlmJobTiming(jobType: type, wallMs: sw.elapsedMilliseconds));

        if (result.isOk) {
          await db.updateLlmJob(
            job.id,
            LlmJobsCompanion(
              status: const Value('done'),
              resultJson: Value(result.okOrNull),
              updatedAt: Value(DateTime.now()),
            ),
          );
          processed++;
        } else {
          final attempts = job.attempts + 1;
          await db.updateLlmJob(
            job.id,
            LlmJobsCompanion(
              status: Value(attempts >= maxAttempts ? 'failed' : 'pending'),
              lastError: Value(result.errorOrNull),
              updatedAt: Value(DateTime.now()),
            ),
          );
          failed++;
        }
      }

      if (engine is LlamaCppEngine) {
        await (engine as LlamaCppEngine).clearPrefixCache();
      }
      _smsPrefixState = null;

      return LlmBatchReport(processed: processed, failed: failed, timings: timings);
    } finally {
      _running = false;
    }
  }

  Future<Result<String>> _dispatch(LlmJobType type, String payloadJson, {int? jobId}) async {
    return switch (type) {
      LlmJobType.smsExtract => _runSmsExtract(payloadJson, jobId: jobId),
      LlmJobType.stmtRowExtract => const Err('stmt_row_extract_not_implemented_v1'),
      LlmJobType.merchantNormalize => _runMerchantNormalize(payloadJson),
      LlmJobType.categorize => _runCategorize(payloadJson),
    };
  }

  Future<Result<String>> _runSmsExtract(String payloadJson, {int? jobId}) async {
    final payload = SmsExtractPayload.fromJson(
      Map<String, Object?>.from(jsonDecode(payloadJson) as Map),
    );
    final row = await db.getUnparsedSms(payload.unparsedSmsId);
    if (row == null) return const Err('unparsed_sms_missing');

    final grammar = await loadGrammar('lib/llm/gbnf/parsed_transaction.gbnf');
    late final Result<String> gen;

    if (engine is LlamaCppEngine) {
      gen = await (engine as LlamaCppEngine).completeParsedTransactionSmsWithPrefix(
        row.rawBody,
        grammar: grammar,
        cachedPrefixState: _smsPrefixState,
        onPrefixStateCached: (s) => _smsPrefixState = s,
      );
    } else {
      gen = await engine.completeJson(
        prompt: Gemma3Chat.formatUserTurn(
          SmsParsePrompt.buildUserContent(row.rawBody),
        ),
        gbnfGrammar: grammar,
        maxTokens: 96,
      );
    }

    if (gen.isErr) return Err(gen.errorOrNull!, gen);

    final validated = validator.validate(
      gen.okOrNull!,
      sourceSms: row.rawBody,
      sender: row.sender,
    );
    if (validated.isErr) return Err(validated.errorOrNull!, validated);

    final llmTxn = validated.okOrNull!;
    final llmJson = llmTxn.toJson();

    final anchored = validateAgainstSource(
      row.rawBody,
      llmJson,
      sender: row.sender,
    );

    await LlmDisagreementRecorder(db).recordFromAnchor(
      report: anchored.report,
      llmJson: llmJson,
      cleaned: anchored.cleaned,
      jobId: jobId,
    );

    if (!anchored.report.allCriticalPassed) {
      await db.markUnparsedSmsResolved(row.id);
      await db.insertReviewItem(
        LlmReviewItemsCompanion.insert(
          unparsedSmsId: Value(row.id),
          rawText: row.rawBody,
          suggestedJson: gen.okOrNull!,
          anchorReportJson: anchored.report.toJsonString(),
          status: const Value('unresolvable_v1'),
        ),
      );
      return Ok(jsonEncode({'status': 'unresolvable_v1'}));
    }

    await db.insertReviewItem(
      LlmReviewItemsCompanion.insert(
        unparsedSmsId: Value(row.id),
        rawText: row.rawBody,
        suggestedJson: jsonEncode(anchored.cleaned),
        anchorReportJson: anchored.report.toJsonString(),
      ),
    );
    await db.markUnparsedSmsResolved(row.id);
    return Ok(jsonEncode({'status': 'pending_review'}));
  }

  Future<Result<String>> _runMerchantNormalize(String payloadJson) async {
    final payload = MerchantNormalizePayload.fromJson(
      Map<String, Object?>.from(jsonDecode(payloadJson) as Map),
    );
    final raw = payload.rawMerchant.trim();
    if (raw.isEmpty) return const Err('empty_merchant');

    final seeds = await MerchantSeedCatalog.load();
    final deterministic = seeds.matchCanonical(raw);
    if (deterministic != null) {
      final merchantId = await db.findOrCreateMerchant(deterministic);
      await db.upsertMerchantAlias(
        rawName: raw,
        merchantId: merchantId,
        source: 'system',
        confidence: 1.0,
      );
      return Ok(jsonEncode({'canonical_name': deterministic, 'source': 'seed'}));
    }

    if (await db.findMerchantAlias(raw) != null) {
      return Ok(jsonEncode({'status': 'already_mapped'}));
    }

    final grammar = await loadGrammar('lib/llm/gbnf/merchant_normalize.gbnf');
    final gen = await engine.completeJson(
      prompt: Gemma3Chat.formatUserTurn(MerchantNormalizePrompt.build(raw)),
      gbnfGrammar: grammar,
      maxTokens: 64,
    );
    if (gen.isErr) return gen;

    final map = Map<String, Object?>.from(jsonDecode(gen.okOrNull!) as Map);
    final canonical = (map['canonical_name'] as String?)?.trim();
    if (canonical == null || canonical.isEmpty) return const Err('invalid_merchant_json');

    if (!seeds.isKnownBrand(canonical) && !_sharesToken(raw, canonical)) {
      return const Err('merchant_anchor_failed');
    }

    final merchantId = await db.findOrCreateMerchant(canonical);
    final confidence = (map['confidence'] as num?)?.toDouble() ?? 0.5;
    await db.upsertMerchantAlias(
      rawName: raw,
      merchantId: merchantId,
      source: 'llm',
      confidence: confidence,
    );
    return Ok(jsonEncode({'canonical_name': canonical, 'source': 'llm'}));
  }

  Future<Result<String>> _runCategorize(String payloadJson) async {
    final payload = CategorizePayload.fromJson(
      Map<String, Object?>.from(jsonDecode(payloadJson) as Map),
    );
    final txn = await (db.select(db.transactions)
          ..where((t) => t.id.equals(payload.transactionId)))
        .getSingleOrNull();
    if (txn == null) return const Err('transaction_missing');

    final rules = await CategoryRuleEngine.load();
    final dir = TransactionDirection.fromWire(txn.direction);
    final ruleHit = await rules.resolve(
      db: db,
      rawMerchant: txn.rawMerchant,
      narration: txn.rawDescription,
      direction: dir,
      transactionId: txn.id,
    );
    if (ruleHit != null) {
      await _applyCategory(txn.id, ruleHit.slug, ruleHit.source);
      return Ok(jsonEncode({'category': ruleHit.slug, 'source': ruleHit.source}));
    }

    final grammar = await loadGrammar('lib/llm/gbnf/category_suggest.gbnf');
    final gen = await engine.completeJson(
      prompt: Gemma3Chat.formatUserTurn(
        CategorizePrompt.build(
          merchant: txn.rawMerchant,
          narration: txn.rawDescription,
          amountPaise: txn.amountPaise,
          direction: txn.direction,
        ),
      ),
      gbnfGrammar: grammar,
      maxTokens: 64,
    );
    if (gen.isErr) return gen;

    final map = Map<String, Object?>.from(jsonDecode(gen.okOrNull!) as Map);
    final slug = map['category'] as String?;
    if (slug == null || slug.isEmpty) return const Err('invalid_category_json');

    if (await db.categoryBySlug(slug) == null) {
      return Err('invalid_category_slug', slug);
    }

    await _applyCategory(txn.id, slug, 'llm', suggestedOnly: true);
    return Ok(jsonEncode({'category': slug, 'source': 'llm'}));
  }

  Future<void> _applyCategory(
    int txnId,
    String slug,
    String source, {
    bool suggestedOnly = false,
  }) async {
    final cat = await db.categoryBySlug(slug);
    if (cat == null) return;
    if (suggestedOnly) {
      await (db.update(db.transactions)..where((t) => t.id.equals(txnId))).write(
        TransactionsCompanion(
          suggestedCategorySlug: Value(slug),
          categorySource: const Value('llm'),
        ),
      );
    } else {
      await (db.update(db.transactions)..where((t) => t.id.equals(txnId))).write(
        TransactionsCompanion(
          categoryId: Value(cat.id),
          suggestedCategorySlug: Value(slug),
          categorySource: Value(source),
        ),
      );
    }
  }

  Future<void> _failJob(int id, String error) {
    return db.updateLlmJob(
      id,
      LlmJobsCompanion(
        status: const Value('failed'),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  bool _sharesToken(String a, String b) {
    final ta = a.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((t) => t.length >= 3).toSet();
    final tb = b.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((t) => t.length >= 3).toSet();
    return ta.intersection(tb).isNotEmpty;
  }
}

class LlmBatchReport {
  const LlmBatchReport({
    this.processed = 0,
    this.failed = 0,
    this.skipped,
    this.timings = const [],
  });

  final int processed;
  final int failed;
  final String? skipped;
  final List<LlmJobTiming> timings;
}

class LlmJobTiming {
  const LlmJobTiming({required this.jobType, required this.wallMs});
  final LlmJobType jobType;
  final int wallMs;
}

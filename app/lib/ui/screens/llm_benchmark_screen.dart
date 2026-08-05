import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../llm/llama_cpp_engine.dart';
import '../../llm/model_config.dart';
import '../../llm/parsed_transaction_validator.dart';
import '../../llm/prompts/sms_parse_prompt.dart';

/// Held-out SMS samples (not in golden set) for on-device LLM smoke tests.
const kHeldOutWeirdSms = [
  'Acct XX4821 debited INR 87.30 on 29-JUL-26 UPI/412399887766/zomato@paytm FOOD. Avl Bal INR 12,034.55',
  'IMPS/P2A/637890999888/FLIPKART INDIA credited? No — Dr Rs 1,499.00 from HDFC A/c **4821 on 30Jul26',
  'NEFT CR-ACME CORP-SBIN998877665544-BONUS Rs.25,000.00 credited to A/c XXXX9012 on 31-07-2026',
];

/// Debug-only on-device LLM microbenchmark.
class LlmBenchmarkScreen extends StatefulWidget {
  const LlmBenchmarkScreen({super.key, required this.engine});

  final LlamaCppEngine engine;

  @override
  State<LlmBenchmarkScreen> createState() => _LlmBenchmarkScreenState();
}

class _LlmBenchmarkScreenState extends State<LlmBenchmarkScreen> {
  final _validator = const ParsedTransactionJsonValidator();
  final _buffer = StringBuffer();
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM Benchmark'),
        actions: [
          if (_running)
            TextButton(
              onPressed: () async {
                await widget.engine.cancel();
                if (mounted) {
                  setState(() {
                    _buffer.writeln('\n[cancelled by user]');
                    _running = false;
                  });
                }
              },
              child: const Text('Cancel'),
            ),
          IconButton(
            tooltip: 'Copy results',
            onPressed: _buffer.isEmpty
                ? null
                : () => Clipboard.setData(ClipboardData(text: _buffer.toString())),
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Model: ${ModelConfig.defaultGemma3_1b.name} '
            '(${ModelConfig.defaultGemma3_1b.quant})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'First run can take 1–3 min on CPU — progress updates below.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _running ? null : _runBenchmark,
            child: Text(_running ? 'Running…' : 'Run benchmark'),
          ),
          const SizedBox(height: 16),
          SelectableText(
            _buffer.isEmpty ? 'Results will appear here.' : _buffer.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _runBenchmark() async {
    setState(() {
      _running = true;
      _buffer.clear();
    });

    void log(String line) {
      _buffer.writeln(line);
      if (mounted) setState(() {});
    }

    try {
      if (!widget.engine.isReady) {
        log('Engine not loaded — download model first.');
        return;
      }

      log('Starting benchmark…');

      final grammar = await widget.engine.defaultParsedTransactionGrammar();
      final memBefore = await widget.engine.memUsageBytes();

      // Chat-wrapped user content — prefill is synchronous until first decode token.
      final longPrompt =
          SmsParsePrompt.buildBenchmarkUserContent(kHeldOutWeirdSms.first);

      log('Phase 1/4: prefill + 1 decode token…');
      final prefillStart = DateTime.now();
      var prefillTokens = 0;
      await for (final _ in widget.engine.generateStream(
        prompt: longPrompt,
        maxTokens: 1,
      )) {
        prefillTokens++;
      }
      final prefillMs = DateTime.now().difference(prefillStart).inMilliseconds;
      log('  done (${prefillMs}ms, streamed $prefillTokens tok)');

      log('Phase 2/4: decode 32 tokens (unconstrained)…');
      final decodeStart = DateTime.now();
      var decodeTokens = 0;
      await for (final _ in widget.engine.generateStream(
        prompt: longPrompt,
        maxTokens: 32,
      )) {
        decodeTokens++;
      }
      final decodeMs = DateTime.now().difference(decodeStart).inMilliseconds;
      log('  done (${decodeMs}ms, $decodeTokens tok)');

      log('Phase 3/4: decode 32 tokens (grammar)…');
      final grammarRules = await widget.engine.grammarRuleCount(grammar);
      log('  grammar_rules: $grammarRules');
      final grammarStart = DateTime.now();
      var grammarTokens = 0;
      final grammarSample = StringBuffer();
      try {
        await for (final token in widget.engine.generateStream(
          prompt: longPrompt,
          grammar: grammar,
          maxTokens: 32,
        )) {
          grammarTokens++;
          grammarSample.write(token);
        }
      } catch (e) {
        log('  grammar error: $e');
      }
      final grammarMs = DateTime.now().difference(grammarStart).inMilliseconds;
      final grammarText = LlamaCppEngine.stripMarkdownJsonFence(
        grammarSample.toString(),
      );
      log('  done (${grammarMs}ms, $grammarTokens tok)');
      log('  sample: ${_preview(grammarText)}');
      log('  grammar_ok: ${grammarText.trimLeft().startsWith('{')}');

      final memAfter = await widget.engine.memUsageBytes();

      log('\n=== LLM microbench (${widget.engine.backendId}) ===');
      log('threads: ${widget.engine.nThreads}');
      log('prefill+1tok: ~$prefillTokens tok / ${prefillMs}ms '
          '(${prefillMs > 0 ? (prefillTokens * 1000 / prefillMs).toStringAsFixed(1) : "n/a"} tok/s)');
      log('decode (unconstrained): $decodeTokens tok / ${decodeMs}ms '
          '(${decodeMs > 0 ? (decodeTokens * 1000 / decodeMs).toStringAsFixed(1) : "n/a"} tok/s)');
      log('decode (grammar): $grammarTokens tok / ${grammarMs}ms '
          '(${grammarMs > 0 ? (grammarTokens * 1000 / grammarMs).toStringAsFixed(1) : "n/a"} tok/s)');
      log('mem_usage_bytes: before=$memBefore after=$memAfter delta=${memAfter - memBefore}');

      final taskStart = DateTime.now();
      log('\n=== Standard task (3 held-out SMS) ===');
      log('Per-item wall time (full prompt, no prefix cache):');
      for (var i = 0; i < kHeldOutWeirdSms.length; i++) {
        log('SMS ${i + 1}/${kHeldOutWeirdSms.length}…');
        final sms = kHeldOutWeirdSms[i];
        final itemStart = DateTime.now();
        final result = await widget.engine.completeParsedTransactionSms(
          sms,
          maxTokens: 96,
        );
        final itemMs = DateTime.now().difference(itemStart).inMilliseconds;
        log('\n--- SMS ${i + 1} --- wall_ms: $itemMs (no_prefix)');
        if (result.isErr) {
          log('generation: ERR ${result.errorOrNull}');
          continue;
        }
        final raw = result.okOrNull!;
        log('raw: $raw');
        log('output_tokens: ${widget.engine.lastGeneratedTokenCount} (cap 96)');
        final verdict = _validator.validate(raw, sourceSms: sms);
        log('validation: ${verdict.isOk ? "OK" : "FAIL ${verdict.errorOrNull}"}');
      }

      if (widget.engine is LlamaCppEngine) {
        final llama = widget.engine as LlamaCppEngine;
        await llama.clearPrefixCache();
        log('\nPer-item wall time (prefix cache reuse):');
        Uint8List? cached;
        for (var i = 0; i < kHeldOutWeirdSms.length; i++) {
          final sms = kHeldOutWeirdSms[i];
          final itemStart = DateTime.now();
          final result = await llama.completeParsedTransactionSmsWithPrefix(
            sms,
            cachedPrefixState: cached,
            onPrefixStateCached: (s) => cached = s,
          );
          final itemMs = DateTime.now().difference(itemStart).inMilliseconds;
          log('SMS ${i + 1} wall_ms: $itemMs (prefix_reuse)');
          if (result.isErr) log('  ERR ${result.errorOrNull}');
        }
      }

      final taskMs = DateTime.now().difference(taskStart).inMilliseconds;
      log('\nstandard_task_wall_ms: $taskMs');
    } catch (e, st) {
      log('\nERROR: $e');
      if (kDebugMode) log(st.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }
}

String _preview(String text, {int maxLen = 120}) {
  final singleLine = text.replaceAll('\n', r'\n');
  if (singleLine.length <= maxLen) return singleLine;
  return '${singleLine.substring(0, maxLen)}…';
}

/// Debug route guard.
bool get llmDebugRoutesEnabled => kDebugMode;

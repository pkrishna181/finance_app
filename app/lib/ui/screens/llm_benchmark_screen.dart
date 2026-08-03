import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../llm/llama_cpp_engine.dart';
import '../../llm/model_config.dart';
import '../../llm/parsed_transaction_validator.dart';

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

    if (!widget.engine.isReady) {
      log('Engine not loaded — download model first.');
      setState(() => _running = false);
      return;
    }

    final grammar = await widget.engine.defaultParsedTransactionGrammar();
    final memBefore = await widget.engine.memUsageBytes();

    // Prefill + decode microbench (200-token prompt target / 100 gen).
    final longPrompt = '${'token ' * 180}\nParse SMS to JSON:\n${kHeldOutWeirdSms.first}';
    final prefillStart = DateTime.now();
    var prefillTokens = 0;
    await for (final _ in widget.engine.generateStream(
      prompt: longPrompt,
      maxTokens: 1,
    )) {
      prefillTokens++;
    }
    final prefillMs = DateTime.now().difference(prefillStart).inMilliseconds;

    final decodeStart = DateTime.now();
    var decodeTokens = 0;
    await for (final _ in widget.engine.generateStream(
      prompt: longPrompt,
      maxTokens: 100,
    )) {
      decodeTokens++;
    }
    final decodeMs = DateTime.now().difference(decodeStart).inMilliseconds;

    final grammarStart = DateTime.now();
    var grammarTokens = 0;
    await for (final _ in widget.engine.generateStream(
      prompt: longPrompt,
      grammar: grammar,
      maxTokens: 100,
    )) {
      grammarTokens++;
    }
    final grammarMs = DateTime.now().difference(grammarStart).inMilliseconds;

    final memAfter = await widget.engine.memUsageBytes();

    log('=== LLM microbench (${widget.engine.backendId}) ===');
    log('threads: ${widget.engine.nThreads}');
    log('prefill: ~$prefillTokens tok / ${prefillMs}ms '
        '(${prefillMs > 0 ? (prefillTokens * 1000 / prefillMs).toStringAsFixed(1) : "n/a"} tok/s)');
    log('decode (unconstrained): $decodeTokens tok / ${decodeMs}ms '
        '(${decodeMs > 0 ? (decodeTokens * 1000 / decodeMs).toStringAsFixed(1) : "n/a"} tok/s)');
    log('decode (grammar): $grammarTokens tok / ${grammarMs}ms '
        '(${grammarMs > 0 ? (grammarTokens * 1000 / grammarMs).toStringAsFixed(1) : "n/a"} tok/s)');
    log('mem_usage_bytes: before=$memBefore after=$memAfter delta=${memAfter - memBefore}');

    final taskStart = DateTime.now();
    log('\n=== Standard task (3 held-out SMS) ===');
    for (var i = 0; i < kHeldOutWeirdSms.length; i++) {
      final sms = kHeldOutWeirdSms[i];
      final prompt =
          'Extract a ParsedTransaction JSON object from this bank SMS. '
          'Amounts in paise. ISO8601 UTC booked_at.\n$sms';
      final result = await widget.engine.completeJson(prompt: prompt);
      log('\n--- SMS ${i + 1} ---');
      if (result.isErr) {
        log('generation: ERR ${result.errorOrNull}');
        continue;
      }
      final raw = result.okOrNull!;
      log('raw: $raw');
      final verdict = _validator.validate(raw);
      log('validation: ${verdict.isOk ? "OK" : "FAIL ${verdict.errorOrNull}"}');
    }
    final taskMs = DateTime.now().difference(taskStart).inMilliseconds;
    log('\nstandard_task_wall_ms: $taskMs');

    setState(() => _running = false);
  }
}

/// Debug route guard.
bool get llmDebugRoutesEnabled => kDebugMode;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../core/result/result.dart';
import 'llm_engine.dart';
import 'llm_native_worker.dart';
import 'native/arth_llm_bindings.dart';
import 'prompts/gemma3_chat.dart';
import 'prompts/sms_parse_prompt.dart';

/// On-device inference via llama.cpp + [arth_llm] shim.
class LlamaCppEngine implements LlmEngine {
  LlamaCppEngine({
    LlmNativeWorker? worker,
    this.idleUnloadMinutes = 3,
    this.nCtx = 2048,
    int? nThreads,
  })  : _worker = worker ?? LlmNativeWorker(),
        _nThreads = nThreads ?? _defaultThreadCount();

  final LlmNativeWorker _worker;
  final int idleUnloadMinutes;
  final int nCtx;
  final int _nThreads;

  String? _modelPath;
  bool _ready = false;
  Timer? _idleTimer;
  Future<void>? _inFlight;
  final _tokenControllers = <StreamController<String>>{};

  static int _defaultThreadCount() {
    final cores = Platform.numberOfProcessors;
    return cores > 4 ? 4 : cores;
  }

  int get nThreads => _nThreads;

  @override
  String get backendId => 'llama.cpp';

  @override
  bool get isReady => _ready;

  bool get isNativeAvailable => ArthLlmNative.instance != null;

  String? get nativeLoadError => ArthLlmNative.lastLoadError;

  /// Decode tokens from the last shim generation (not chars÷4 estimate).
  int get lastGeneratedTokenCount => _lastShimGeneratedTokens;

  int _lastShimGeneratedTokens = 0;

  Future<int> grammarRuleCount(String grammar) =>
      _worker.grammarRuleCount(grammar);

  Future<void> _refreshLastGeneratedTokenCount() async {
    _lastShimGeneratedTokens = await _worker.lastGeneratedTokenCount();
  }

  @override
  Future<Result<void>> load({required String modelPath}) async {
    if (!isNativeAvailable) {
      final detail = nativeLoadError ?? 'unknown';
      return Err('native_library_unavailable', detail);
    }
    if (!File(modelPath).existsSync()) {
      return Err('model_file_missing', modelPath);
    }
    await _worker.start();
    final result = await _worker.load(
      modelPath: modelPath,
      nCtx: nCtx,
      nThreads: _nThreads,
    );
    if (result.isErr) return result;
    _modelPath = modelPath;
    _ready = true;
    _resetIdleTimer();
    return const Ok(null);
  }

  @override
  Future<void> dispose() async {
    _idleTimer?.cancel();
    for (final c in _tokenControllers) {
      await c.close();
    }
    _tokenControllers.clear();
    await _worker.unload();
    await _worker.shutdown();
    _ready = false;
    _modelPath = null;
  }

  @override
  Future<Result<String>> complete({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.2,
  }) async {
    final buffer = StringBuffer();
    final stream = generateStream(
      prompt: prompt,
      maxTokens: maxTokens,
    );
    await for (final token in stream) {
      buffer.write(token);
    }
    return Ok(buffer.toString());
  }

  @override
  Future<Result<String>> completeJson({
    required String prompt,
    String? gbnfGrammar,
    int maxTokens = 256,
    double temperature = 0.1,
  }) async {
    final grammar = gbnfGrammar ?? await defaultParsedTransactionGrammar();
    final buffer = StringBuffer();
    try {
      await for (final token in generateStream(
        prompt: prompt,
        grammar: grammar,
        maxTokens: maxTokens,
      )) {
        buffer.write(token);
      }
      await _refreshLastGeneratedTokenCount();
      return Ok(stripMarkdownJsonFence(buffer.toString()));
    } catch (e) {
      return Err('generation_failed', e);
    }
  }

  /// SMS → ParsedTransaction JSON with Gemma chat template + few-shot prompt.
  Future<Result<String>> completeParsedTransactionSms(
    String sms, {
    int maxTokens = 96,
  }) {
    return completeJson(
      prompt: SmsParsePrompt.buildUserContent(sms),
      maxTokens: maxTokens,
    );
  }

  Uint8List? _cachedSmsPrefixState;

  /// Prefix-cached SMS extraction (Phase 5 batch path).
  Future<Result<String>> completeParsedTransactionSmsWithPrefix(
    String sms, {
    String? grammar,
    Uint8List? cachedPrefixState,
    void Function(Uint8List state)? onPrefixStateCached,
    int maxTokens = 96,
  }) async {
    if (!_ready) return const Err('LlamaCppEngine not loaded');
    if (_inFlight != null) return const Err('generation_in_progress');

    final g = grammar ?? await defaultParsedTransactionGrammar();
    final prefixPrompt = Gemma3Chat.formatUserTurn(SmsParsePrompt.prefixContent);
    final suffixPrompt = SmsParsePrompt.buildItemSuffix(sms);

    final completer = Completer<void>();
    _inFlight = completer.future;
    _resetIdleTimer();

    try {
      var state = cachedPrefixState ?? _cachedSmsPrefixState;
      if (state == null) {
        final pre = await _worker.prefill(prefixPrompt);
        if (pre.isErr) return Err(pre.errorOrNull!);
        final saved = await _worker.saveState();
        if (saved.isErr) return Err(saved.errorOrNull!);
        state = saved.okOrNull!;
        _cachedSmsPrefixState = state;
        onPrefixStateCached?.call(state);
      } else {
        final restored = await _worker.restoreState(state);
        if (restored.isErr) return Err(restored.errorOrNull!);
      }

      final buffer = StringBuffer();
      await for (final token in _worker.generateEx(
        prompt: suffixPrompt,
        grammar: g,
        maxTokens: maxTokens,
        flags: 0,
      )) {
        buffer.write(token);
      }
      await _refreshLastGeneratedTokenCount();
      return Ok(stripMarkdownJsonFence(buffer.toString()));
    } catch (e) {
      return Err('generation_failed', e);
    } finally {
      if (!completer.isCompleted) completer.complete();
      _inFlight = null;
      _resetIdleTimer();
    }
  }

  Future<void> clearPrefixCache() async {
    _cachedSmsPrefixState = null;
  }

  /// Strip optional ```json fences models sometimes emit despite GBNF.
  static String stripMarkdownJsonFence(String raw) {
    var text = raw.trim();
    if (!text.startsWith('```')) return text;
    text = text.replaceFirst(RegExp(r'^```(?:json)?\s*', multiLine: true), '');
    final close = text.lastIndexOf('```');
    if (close >= 0) text = text.substring(0, close);
    return text.trim();
  }

  /// Token stream with single-flight enforcement.
  Stream<String> generateStream({
    required String prompt,
    String? grammar,
    int maxTokens = 256,
    bool useChatTemplate = true,
  }) {
    if (!_ready) {
      return Stream.error(StateError('LlamaCppEngine not loaded'));
    }
    if (_inFlight != null) {
      return Stream.error(StateError('generation_in_progress'));
    }

    final controller = StreamController<String>();
    _tokenControllers.add(controller);
    _resetIdleTimer();

    final completer = Completer<void>();
    _inFlight = completer.future;

    void finishFlight() {
      if (!completer.isCompleted) completer.complete();
      _inFlight = null;
      _resetIdleTimer();
    }

    final effectivePrompt = useChatTemplate && !Gemma3Chat.isFormatted(prompt)
        ? Gemma3Chat.formatUserTurn(prompt)
        : prompt;

    _worker
        .generate(
          prompt: effectivePrompt,
          grammar: grammar,
          maxTokens: maxTokens,
        )
        .listen(
          controller.add,
          onError: (e, st) {
            if (!controller.isClosed) {
              controller.addError(e, st);
            }
            finishFlight();
            _tokenControllers.remove(controller);
            if (!controller.isClosed) controller.close();
          },
          onDone: () {
            // Must clear _inFlight synchronously before closing [controller].
            // An async onDone let await-for finish Phase 1 and start Phase 2
            // while _inFlight was still set → generation_in_progress.
            finishFlight();
            _tokenControllers.remove(controller);
            if (!controller.isClosed) controller.close();
          },
          cancelOnError: false,
        );

    return controller.stream;
  }

  Future<void> cancel() => _worker.cancel();

  Future<int> memUsageBytes() => _worker.memUsage();

  Future<String> defaultParsedTransactionGrammar() async {
    return rootBundle.loadString('lib/llm/gbnf/parsed_transaction.gbnf');
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (idleUnloadMinutes <= 0) return;
    _idleTimer = Timer(Duration(minutes: idleUnloadMinutes), () async {
      if (_inFlight != null) return;
      await _worker.unload();
      _ready = false;
    });
  }

  String? get loadedModelPath => _modelPath;
}

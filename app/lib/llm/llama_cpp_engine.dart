import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import '../core/result/result.dart';
import 'llm_engine.dart';
import 'llm_native_worker.dart';
import 'native/arth_llm_bindings.dart';

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

  @override
  Future<Result<void>> load({required String modelPath}) async {
    if (!isNativeAvailable) {
      return const Err('native_library_unavailable');
    }
    await _worker.start();
    await _worker.load(
      modelPath: modelPath,
      nCtx: nCtx,
      nThreads: _nThreads,
    );
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
      return Ok(buffer.toString().trim());
    } catch (e) {
      return Err('generation_failed', e);
    }
  }

  /// Token stream with single-flight enforcement.
  Stream<String> generateStream({
    required String prompt,
    String? grammar,
    int maxTokens = 256,
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

    _worker
        .generate(
          prompt: prompt,
          grammar: grammar,
          maxTokens: maxTokens,
        )
        .listen(
          controller.add,
          onError: controller.addError,
          onDone: () async {
            _tokenControllers.remove(controller);
            if (!controller.isClosed) await controller.close();
            completer.complete();
            _inFlight = null;
            _resetIdleTimer();
          },
          cancelOnError: true,
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

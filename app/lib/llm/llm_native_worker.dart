import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../core/result/result.dart';
import 'native/arth_llm_bindings.dart';

/// Messages to the long-lived LLM worker isolate (owns native handle).
sealed class _WorkerCommand {}

class _WorkerLoad extends _WorkerCommand {
  _WorkerLoad(this.modelPath, this.nCtx, this.nThreads, this.replyPort);
  final String modelPath;
  final int nCtx;
  final int nThreads;
  final SendPort replyPort;
}

class _WorkerUnload extends _WorkerCommand {}

class _WorkerGenerate extends _WorkerCommand {
  _WorkerGenerate({
    required this.prompt,
    required this.grammar,
    required this.maxTokens,
    required this.replyPort,
  });
  final String prompt;
  final String? grammar;
  final int maxTokens;
  final SendPort replyPort;
}

class _WorkerCancel extends _WorkerCommand {}

class _WorkerMemUsage extends _WorkerCommand {
  _WorkerMemUsage(this.replyPort);
  final SendPort replyPort;
}

class _WorkerPrefill extends _WorkerCommand {
  _WorkerPrefill({required this.prompt, required this.replyPort});
  final String prompt;
  final SendPort replyPort;
}

class _WorkerSaveState extends _WorkerCommand {
  _WorkerSaveState(this.replyPort);
  final SendPort replyPort;
}

class _WorkerRestoreState extends _WorkerCommand {
  _WorkerRestoreState({required this.state, required this.replyPort});
  final Uint8List state;
  final SendPort replyPort;
}

class _WorkerGenerateEx extends _WorkerCommand {
  _WorkerGenerateEx({
    required this.prompt,
    required this.grammar,
    required this.maxTokens,
    required this.flags,
    required this.replyPort,
  });
  final String? prompt;
  final String? grammar;
  final int maxTokens;
  final int flags;
  final SendPort replyPort;
}

class _WorkerShutdown extends _WorkerCommand {}

class _WorkerGrammarRuleCount extends _WorkerCommand {
  _WorkerGrammarRuleCount(this.grammar, this.replyPort);
  final String grammar;
  final SendPort replyPort;
}

class _WorkerLastGeneratedTokens extends _WorkerCommand {
  _WorkerLastGeneratedTokens(this.replyPort);
  final SendPort replyPort;
}

bool _isValidHandle(Pointer<Void>? handle) =>
    handle != null && handle.address != 0;

/// Human-readable native [arth_llm_generate] status codes.
String llmGenerateErrorMessage(int status) {
  return switch (status) {
    -1 => 'invalid_handle_or_args (model may not be loaded)',
    -2 => 'prompt_tokenize_empty',
    -3 => 'out_of_memory',
    -4 => 'prompt_tokenize_failed',
    -5 => 'prompt_decode_failed',
    -6 => 'token_to_text_failed',
    -7 => 'decode_step_failed',
    -8 => 'grammar_parse_failed',
    -9 => 'grammar_inactive',
    1 => 'cancelled',
    _ => 'generate_error_$status',
  };
}

/// Runs all native calls on a dedicated isolate.
class LlmNativeWorker {
  LlmNativeWorker();

  Isolate? _isolate;
  SendPort? _commandPort;
  final _ready = Completer<void>();

  Future<void> start() async {
    if (_isolate != null) return;
    final initPort = ReceivePort();
    _isolate = await Isolate.spawn(_workerMain, initPort.sendPort);
    _commandPort = await initPort.first as SendPort;
    initPort.close();
    _ready.complete();
  }

  Future<void> ensureStarted() => _ready.future;

  Future<Result<void>> load({
    required String modelPath,
    required int nCtx,
    required int nThreads,
  }) async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerLoad(modelPath, nCtx, nThreads, port.sendPort));
    final reply = await port.first;
    port.close();
    if (reply is String && reply.startsWith('__err__')) {
      return Err(reply.substring(7));
    }
    return const Ok(null);
  }

  Future<void> unload() async {
    await ensureStarted();
    _commandPort!.send(_WorkerUnload());
  }

  Future<void> cancel() async {
    await ensureStarted();
    _commandPort!.send(_WorkerCancel());
  }

  Future<int> memUsage() async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerMemUsage(port.sendPort));
    return await port.first as int;
  }

  Future<int> grammarRuleCount(String grammar) async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerGrammarRuleCount(grammar, port.sendPort));
    return await port.first as int;
  }

  Future<int> lastGeneratedTokenCount() async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerLastGeneratedTokens(port.sendPort));
    return await port.first as int;
  }

  Future<Result<void>> prefill(String prompt) async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerPrefill(prompt: prompt, replyPort: port.sendPort));
    final reply = await port.first;
    port.close();
    if (reply is int && reply == 0) return const Ok(null);
    if (reply is String && reply.startsWith('__err__')) {
      return Err(reply.substring(7));
    }
    return Err('prefill_failed', reply);
  }

  Future<Result<Uint8List>> saveState() async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerSaveState(port.sendPort));
    final reply = await port.first;
    port.close();
    if (reply is Uint8List) return Ok(reply);
    if (reply is String && reply.startsWith('__err__')) {
      return Err(reply.substring(7));
    }
    return const Err('save_state_failed');
  }

  Future<Result<void>> restoreState(Uint8List state) async {
    await ensureStarted();
    final port = ReceivePort();
    _commandPort!.send(_WorkerRestoreState(state: state, replyPort: port.sendPort));
    final reply = await port.first;
    port.close();
    if (reply is int && reply > 0) return const Ok(null);
    if (reply is String && reply.startsWith('__err__')) {
      return Err(reply.substring(7));
    }
    return const Err('restore_state_failed');
  }

  Stream<String> generateEx({
    String? prompt,
    String? grammar,
    required int maxTokens,
    int flags = arthGenClearKv,
  }) {
    final controller = StreamController<String>();
    final port = ReceivePort();
    port.listen((message) {
      if (message is String) {
        if (message == '__done__') {
          port.close();
          controller.close();
        } else if (message.startsWith('__err__')) {
          controller.addError(message.substring(7));
          port.close();
          controller.close();
        } else {
          controller.add(message);
        }
      }
    });

    _commandPort!.send(
      _WorkerGenerateEx(
        prompt: prompt,
        grammar: grammar,
        maxTokens: maxTokens,
        flags: flags,
        replyPort: port.sendPort,
      ),
    );
    return controller.stream;
  }

  Stream<String> generate({
    required String prompt,
    String? grammar,
    required int maxTokens,
  }) {
    final controller = StreamController<String>();
    final port = ReceivePort();
    port.listen((message) {
      if (message is String) {
        if (message == '__done__') {
          port.close();
          controller.close();
        } else if (message.startsWith('__err__')) {
          controller.addError(message.substring(7));
          port.close();
          controller.close();
        } else {
          controller.add(message);
        }
      }
    });

    _commandPort!.send(
      _WorkerGenerate(
        prompt: prompt,
        grammar: grammar,
        maxTokens: maxTokens,
        replyPort: port.sendPort,
      ),
    );
    return controller.stream;
  }

  Future<void> shutdown() async {
    _commandPort?.send(_WorkerShutdown());
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _commandPort = null;
  }

  static Pointer<Void>? _tryLoad(
    ArthLlmBindings bindings, {
    required String modelPath,
    required int nCtx,
    required int nThreads,
    required bool useMmap,
  }) {
    final loaded = bindings.load(
      modelPath: modelPath,
      nCtx: nCtx,
      nThreads: nThreads,
      useMmap: useMmap,
    );
    return _isValidHandle(loaded) ? loaded : null;
  }

  static void _workerMain(SendPort mainSendPort) {
    final commandPort = ReceivePort();
    mainSendPort.send(commandPort.sendPort);

    final native = ArthLlmNative.instance;
    Pointer<Void>? handle;

    commandPort.listen((message) {
      if (message is! _WorkerCommand) return;
      switch (message) {
        case _WorkerLoad():
          if (native == null) {
            message.replyPort.send('__err__native_library_unavailable');
            break;
          }
          if (_isValidHandle(handle)) {
            native!.bindings.unload(handle!);
            handle = null;
          }
          handle = _tryLoad(
            native!.bindings,
            modelPath: message.modelPath,
            nCtx: message.nCtx,
            nThreads: message.nThreads,
            useMmap: true,
          );
          handle ??= _tryLoad(
            native.bindings,
            modelPath: message.modelPath,
            nCtx: message.nCtx,
            nThreads: message.nThreads,
            useMmap: false,
          );
          if (_isValidHandle(handle)) {
            message.replyPort.send('__ok__');
          } else {
            handle = null;
            final detail = native?.bindings.lastError() ?? '';
            if (detail.isNotEmpty) {
              message.replyPort.send('__err__$detail');
            } else {
              message.replyPort.send('__err__model_load_failed');
            }
          }
        case _WorkerUnload():
          if (_isValidHandle(handle) && native != null) {
            native!.bindings.unload(handle!);
            handle = null;
          }
        case _WorkerCancel():
          if (_isValidHandle(handle) && native != null) {
            native!.bindings.cancel(handle!);
          }
        case _WorkerGenerate():
          if (native == null || !_isValidHandle(handle)) {
            message.replyPort.send('__err__model_not_loaded');
            message.replyPort.send('__done__');
            return;
          }
          try {
            final status = native!.bindings.generate(
              handle: handle!,
              prompt: message.prompt,
              grammar: message.grammar,
              maxTokens: message.maxTokens,
              onToken: message.replyPort.send,
            );
            if (status < 0) {
              message.replyPort.send('__err__${llmGenerateErrorMessage(status)}');
            } else if (status > 0) {
              message.replyPort.send('__err__${llmGenerateErrorMessage(status)}');
            }
          } catch (e) {
            message.replyPort.send('__err__$e');
          } finally {
            message.replyPort.send('__done__');
          }
        case _WorkerMemUsage():
          final bytes = _isValidHandle(handle) && native != null
              ? native!.bindings.memUsage(handle!)
              : 0;
          message.replyPort.send(bytes);
        case _WorkerGrammarRuleCount():
          if (native == null) {
            message.replyPort.send(0);
          } else {
            message.replyPort.send(
              native!.bindings.grammarRuleCount(message.grammar),
            );
          }
        case _WorkerLastGeneratedTokens():
          if (native == null) {
            message.replyPort.send(0);
          } else {
            message.replyPort.send(native!.bindings.lastGeneratedTokens());
          }
        case _WorkerPrefill():
          if (native == null || !_isValidHandle(handle)) {
            message.replyPort.send('__err__model_not_loaded');
            return;
          }
          message.replyPort.send(
            native!.bindings.prefill(handle: handle!, prompt: message.prompt),
          );
        case _WorkerSaveState():
          if (native == null || !_isValidHandle(handle)) {
            message.replyPort.send('__err__model_not_loaded');
            return;
          }
          final size = native.bindings.stateSize(handle!);
          if (size <= 0) {
            message.replyPort.send('__err__state_size_zero');
            return;
          }
          final buf = calloc<Uint8>(size);
          final written = native.bindings.saveState(handle!, buf, size);
          if (written <= 0) {
            calloc.free(buf);
            message.replyPort.send('__err__save_state_failed');
            return;
          }
          final copy = Uint8List(written);
          for (var i = 0; i < written; i++) {
            copy[i] = buf[i];
          }
          calloc.free(buf);
          message.replyPort.send(copy);
        case _WorkerRestoreState():
          if (native == null || !_isValidHandle(handle)) {
            message.replyPort.send('__err__model_not_loaded');
            return;
          }
          final src = calloc<Uint8>(message.state.length);
          for (var i = 0; i < message.state.length; i++) {
            src[i] = message.state[i];
          }
          final read = native.bindings.restoreState(handle!, src, message.state.length);
          calloc.free(src);
          message.replyPort.send(read);
        case _WorkerGenerateEx():
          if (native == null || !_isValidHandle(handle)) {
            message.replyPort.send('__err__model_not_loaded');
            message.replyPort.send('__done__');
            return;
          }
          try {
            final status = native!.bindings.generateEx(
              handle: handle!,
              prompt: message.prompt,
              grammar: message.grammar,
              maxTokens: message.maxTokens,
              flags: message.flags,
              onToken: message.replyPort.send,
            );
            if (status < 0) {
              message.replyPort.send('__err__${llmGenerateErrorMessage(status)}');
            } else if (status > 0) {
              message.replyPort.send('__err__${llmGenerateErrorMessage(status)}');
            }
          } catch (e) {
            message.replyPort.send('__err__$e');
          } finally {
            message.replyPort.send('__done__');
          }
        case _WorkerShutdown():
          if (_isValidHandle(handle) && native != null) {
            native!.bindings.unload(handle!);
          }
          commandPort.close();
      }
    });
  }
}

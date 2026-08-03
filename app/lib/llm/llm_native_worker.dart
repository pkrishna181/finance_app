import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import '../core/result/result.dart';
import 'native/arth_llm_bindings.dart';

/// Messages to the long-lived LLM worker isolate (owns native handle).
sealed class _WorkerCommand {}

class _WorkerLoad extends _WorkerCommand {
  _WorkerLoad(this.modelPath, this.nCtx, this.nThreads);
  final String modelPath;
  final int nCtx;
  final int nThreads;
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

class _WorkerShutdown extends _WorkerCommand {}

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
    _commandPort!.send(_WorkerLoad(modelPath, nCtx, nThreads));
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

  static void _workerMain(SendPort mainSendPort) {
    final commandPort = ReceivePort();
    mainSendPort.send(commandPort.sendPort);

    final native = ArthLlmNative.instance;
    Pointer<Void>? handle;

    commandPort.listen((message) {
      if (message is! _WorkerCommand) return;
      switch (message) {
        case _WorkerLoad():
          if (native == null) break;
          if (handle != null) {
            native.bindings.unload(handle!);
          }
          handle = native.bindings.load(
            modelPath: message.modelPath,
            nCtx: message.nCtx,
            nThreads: message.nThreads,
          );
        case _WorkerUnload():
          if (handle != null && native != null) {
            native.bindings.unload(handle!);
            handle = null;
          }
        case _WorkerCancel():
          if (handle != null && native != null) {
            native.bindings.cancel(handle!);
          }
        case _WorkerGenerate():
          if (native == null || handle == null) {
            message.replyPort.send('__err__native_not_loaded');
            return;
          }
          try {
            final status = native.bindings.generate(
              handle: handle!,
              prompt: message.prompt,
              grammar: message.grammar,
              maxTokens: message.maxTokens,
              onToken: message.replyPort.send,
            );
            if (status < 0) {
              message.replyPort.send('__err__generate_$status');
            }
          } catch (e) {
            message.replyPort.send('__err__$e');
          } finally {
            message.replyPort.send('__done__');
          }
        case _WorkerMemUsage():
          final bytes = handle != null && native != null
              ? native.bindings.memUsage(handle!)
              : 0;
          message.replyPort.send(bytes);
        case _WorkerShutdown():
          if (handle != null && native != null) {
            native.bindings.unload(handle!);
          }
          commandPort.close();
      }
    });
  }
}

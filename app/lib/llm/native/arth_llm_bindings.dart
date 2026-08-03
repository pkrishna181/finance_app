import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Loads [libarth_llm] and exposes the stable shim API.
class ArthLlmNative {
  ArthLlmNative._(this._bindings);

  final ArthLlmBindings _bindings;
  static ArthLlmNative? _instance;

  static ArthLlmNative? get instance {
    if (_instance != null) return _instance;
    try {
      final lib = _openLibrary();
      _instance = ArthLlmNative._(ArthLlmBindings(lib));
      return _instance;
    } catch (_) {
      return null;
    }
  }

  static DynamicLibrary _openLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libarth_llm.so');
    }
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    if (Platform.isLinux) {
      return DynamicLibrary.open('libarth_llm.so');
    }
    if (Platform.isMacOS) {
      return DynamicLibrary.open('libarth_llm.dylib');
    }
    throw UnsupportedError('arth_llm unsupported on ${Platform.operatingSystem}');
  }

  ArthLlmBindings get bindings => _bindings;
}

final class ArthLlmParams extends Struct {
  @Int32()
  external int nCtx;
  @Int32()
  external int nThreads;
  @Int32()
  external int nGpuLayers;
  @Int32()
  external int useMmap;
}

typedef _TokenCallbackNative = Int32 Function(
  Pointer<Utf8> token,
  Pointer<Void> userData,
);

void Function(String token)? _activeTokenHandler;

int _tokenCallbackTrampoline(Pointer<Utf8> token, Pointer<Void> _) {
  _activeTokenHandler?.call(token.toDartString());
  return 0;
}

final _tokenCallbackNative = Pointer.fromFunction<_TokenCallbackNative>(
  _tokenCallbackTrampoline,
  0,
);

class ArthLlmBindings {
  ArthLlmBindings(this._lib) {
    _load = _lib.lookupFunction<_LoadNative, _LoadDart>('arth_llm_load');
    _generate =
        _lib.lookupFunction<_GenerateNative, _GenerateDart>('arth_llm_generate');
    _cancel = _lib.lookupFunction<_CancelNative, _CancelDart>('arth_llm_cancel');
    _unload = _lib.lookupFunction<_UnloadNative, _UnloadDart>('arth_llm_unload');
    _memUsage =
        _lib.lookupFunction<_MemUsageNative, _MemUsageDart>('arth_llm_mem_usage');
  }

  final DynamicLibrary _lib;

  late final _LoadDart _load;
  late final _GenerateDart _generate;
  late final _CancelDart _cancel;
  late final _UnloadDart _unload;
  late final _MemUsageDart _memUsage;

  Pointer<Void> load({
    required String modelPath,
    required int nCtx,
    required int nThreads,
    int nGpuLayers = 0,
    bool useMmap = true,
  }) {
    final path = modelPath.toNativeUtf8();
    final params = calloc<ArthLlmParams>();
    params.ref
      ..nCtx = nCtx
      ..nThreads = nThreads
      ..nGpuLayers = nGpuLayers
      ..useMmap = useMmap ? 1 : 0;
    final handle = _load(path, params);
    calloc.free(path);
    calloc.free(params);
    return handle;
  }

  int generate({
    required Pointer<Void> handle,
    required String prompt,
    String? grammar,
    required int maxTokens,
    required void Function(String token) onToken,
  }) {
    final promptPtr = prompt.toNativeUtf8();
    final grammarPtr =
        grammar == null ? nullptr : grammar.toNativeUtf8(allocator: calloc);

    _activeTokenHandler = onToken;
    final status = _generate(
      handle,
      promptPtr,
      grammarPtr,
      maxTokens,
      _tokenCallbackNative,
      nullptr,
    );
    _activeTokenHandler = null;
    calloc.free(promptPtr);
    if (grammarPtr != nullptr) calloc.free(grammarPtr);
    return status;
  }

  void cancel(Pointer<Void> handle) => _cancel(handle);

  void unload(Pointer<Void> handle) => _unload(handle);

  int memUsage(Pointer<Void> handle) => _memUsage(handle);
}

typedef _LoadNative = Pointer<Void> Function(
  Pointer<Utf8> modelPath,
  Pointer<ArthLlmParams> params,
);
typedef _LoadDart = Pointer<Void> Function(
  Pointer<Utf8> modelPath,
  Pointer<ArthLlmParams> params,
);

typedef _GenerateNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Utf8> prompt,
  Pointer<Utf8> grammar,
  Int32 maxTokens,
  Pointer<NativeFunction<_TokenCallbackNative>> callback,
  Pointer<Void> userData,
);
typedef _GenerateDart = int Function(
  Pointer<Void> handle,
  Pointer<Utf8> prompt,
  Pointer<Utf8> grammar,
  int maxTokens,
  Pointer<NativeFunction<_TokenCallbackNative>> callback,
  Pointer<Void> userData,
);

typedef _CancelNative = Void Function(Pointer<Void> handle);
typedef _CancelDart = void Function(Pointer<Void> handle);

typedef _UnloadNative = Void Function(Pointer<Void> handle);
typedef _UnloadDart = void Function(Pointer<Void> handle);

typedef _MemUsageNative = IntPtr Function(Pointer<Void> handle);
typedef _MemUsageDart = int Function(Pointer<Void> handle);

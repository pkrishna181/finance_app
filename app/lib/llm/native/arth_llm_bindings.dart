import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

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
    } catch (e) {
      _lastLoadError = e.toString();
      return null;
    }
  }

  /// Last [DynamicLibrary.open] failure (for debug UI).
  static String? _lastLoadError;
  static String? get lastLoadError => _lastLoadError;

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
    _lastError =
        _lib.lookupFunction<_LastErrorNative, _LastErrorDart>('arth_llm_last_error');
    _prefill = _lib.lookupFunction<_PrefillNative, _PrefillDart>('arth_llm_prefill');
    _stateSize =
        _lib.lookupFunction<_StateSizeNative, _StateSizeDart>('arth_llm_state_size');
    _saveState =
        _lib.lookupFunction<_SaveStateNative, _SaveStateDart>('arth_llm_save_state');
    _restoreState =
        _lib.lookupFunction<_RestoreStateNative, _RestoreStateDart>('arth_llm_restore_state');
    _generateEx =
        _lib.lookupFunction<_GenerateExNative, _GenerateExDart>('arth_llm_generate_ex');
    _grammarRuleCount = _lib
        .lookupFunction<_GrammarRuleCountNative, _GrammarRuleCountDart>(
            'arth_grammar_rule_count');
    try {
      _lastGeneratedTokens = _lib.lookupFunction<
          _LastGeneratedTokensNative, _LastGeneratedTokensDart>(
        'arth_llm_last_generated_tokens',
      );
    } on ArgumentError {
      _lastGeneratedTokens = null;
    }
  }

  final DynamicLibrary _lib;

  late final _LoadDart _load;
  late final _GenerateDart _generate;
  late final _CancelDart _cancel;
  late final _UnloadDart _unload;
  late final _MemUsageDart _memUsage;
  late final _LastErrorDart _lastError;
  late final _PrefillDart _prefill;
  late final _StateSizeDart _stateSize;
  late final _SaveStateDart _saveState;
  late final _RestoreStateDart _restoreState;
  late final _GenerateExDart _generateEx;
  late final _GrammarRuleCountDart _grammarRuleCount;
  _LastGeneratedTokensDart? _lastGeneratedTokens;

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

  String lastError() {
    final ptr = _lastError();
    if (ptr == nullptr) return '';
    return ptr.toDartString();
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

  int prefill({required Pointer<Void> handle, required String prompt}) {
    final promptPtr = prompt.toNativeUtf8();
    final rc = _prefill(handle, promptPtr);
    calloc.free(promptPtr);
    return rc;
  }

  int stateSize(Pointer<Void> handle) => _stateSize(handle);

  int saveState(Pointer<Void> handle, Pointer<Uint8> dst, int cap) =>
      _saveState(handle, dst, cap);

  int restoreState(Pointer<Void> handle, Pointer<Uint8> src, int len) =>
      _restoreState(handle, src, len);

  int generateEx({
    required Pointer<Void> handle,
    required String? prompt,
    String? grammar,
    required int maxTokens,
    required int flags,
    required void Function(String token) onToken,
  }) {
    final promptPtr = prompt == null ? nullptr : prompt.toNativeUtf8(allocator: calloc);
    final grammarPtr =
        grammar == null ? nullptr : grammar.toNativeUtf8(allocator: calloc);

    _activeTokenHandler = onToken;
    final status = _generateEx(
      handle,
      promptPtr,
      grammarPtr,
      maxTokens,
      flags,
      _tokenCallbackNative,
      nullptr,
    );
    _activeTokenHandler = null;
    if (promptPtr != nullptr) calloc.free(promptPtr);
    if (grammarPtr != nullptr) calloc.free(grammarPtr);
    return status;
  }

  int grammarRuleCount(String grammar) {
    final grammarPtr = grammar.toNativeUtf8(allocator: calloc);
    final count = _grammarRuleCount(grammarPtr);
    calloc.free(grammarPtr);
    return count;
  }

  int lastGeneratedTokens() => _lastGeneratedTokens?.call() ?? 0;
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

typedef _LastErrorNative = Pointer<Utf8> Function();
typedef _LastErrorDart = Pointer<Utf8> Function();

typedef _PrefillNative = Int32 Function(Pointer<Void> handle, Pointer<Utf8> prompt);
typedef _PrefillDart = int Function(Pointer<Void> handle, Pointer<Utf8> prompt);

typedef _StateSizeNative = IntPtr Function(Pointer<Void> handle);
typedef _StateSizeDart = int Function(Pointer<Void> handle);

typedef _SaveStateNative = IntPtr Function(
  Pointer<Void> handle,
  Pointer<Uint8> dst,
  IntPtr cap,
);
typedef _SaveStateDart = int Function(
  Pointer<Void> handle,
  Pointer<Uint8> dst,
  int cap,
);

typedef _RestoreStateNative = IntPtr Function(
  Pointer<Void> handle,
  Pointer<Uint8> src,
  IntPtr len,
);
typedef _RestoreStateDart = int Function(
  Pointer<Void> handle,
  Pointer<Uint8> src,
  int len,
);

typedef _GenerateExNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Utf8> prompt,
  Pointer<Utf8> grammar,
  Int32 maxTokens,
  Int32 flags,
  Pointer<NativeFunction<_TokenCallbackNative>> callback,
  Pointer<Void> userData,
);
typedef _GenerateExDart = int Function(
  Pointer<Void> handle,
  Pointer<Utf8> prompt,
  Pointer<Utf8> grammar,
  int maxTokens,
  int flags,
  Pointer<NativeFunction<_TokenCallbackNative>> callback,
  Pointer<Void> userData,
);

typedef _GrammarRuleCountNative = Int32 Function(Pointer<Utf8> grammar);
typedef _GrammarRuleCountDart = int Function(Pointer<Utf8> grammar);

typedef _LastGeneratedTokensNative = Int32 Function();
typedef _LastGeneratedTokensDart = int Function();

/// ARTH_GEN_CLEAR_KV = 1, ARTH_GEN_DECODE_ONLY = 2
const arthGenClearKv = 1;
const arthGenDecodeOnly = 2;

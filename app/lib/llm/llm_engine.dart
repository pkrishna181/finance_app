import '../core/result/result.dart';

/// Abstract on-device LLM runtime.
///
/// Callers depend only on this interface so the backend can swap from
/// llama.cpp (FFI) to LiteRT-LM (or another engine) without touching
/// ingestion / insights / Q&A code.
abstract class LlmEngine {
  /// Human-readable backend id, e.g. `fake`, `llama.cpp`, `litert-lm`.
  String get backendId;

  /// Whether weights are loaded and ready for [complete] / [completeJson].
  bool get isReady;

  /// Load model weights from [modelPath] (GGUF or platform-native format).
  Future<Result<void>> load({required String modelPath});

  /// Unload weights and free native resources.
  Future<void> dispose();

  /// Free-form completion. Prefer [completeJson] for structured tasks.
  Future<Result<String>> complete({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.2,
  });

  /// Structured completion constrained to JSON.
  ///
  /// Implementations SHOULD use grammar-constrained decoding (GBNF) when
  /// available. Callers MUST still validate the returned JSON against a
  /// schema and apply a deterministic fallback on failure.
  Future<Result<String>> completeJson({
    required String prompt,
    String? gbnfGrammar,
    int maxTokens = 256,
    double temperature = 0.1,
  });
}

import '../core/result/result.dart';
import 'llm_engine.dart';

/// Deterministic stub for unit tests and UI development without a model file.
///
/// Returns canned JSON / text. Never touches the network or native libs.
class FakeLlmEngine implements LlmEngine {
  FakeLlmEngine({
    this.jsonResponse = '{"ok":true}',
    this.textResponse = 'ok',
  });

  String jsonResponse;
  String textResponse;
  bool _ready = false;
  String? lastPrompt;
  String? lastGrammar;

  @override
  String get backendId => 'fake';

  @override
  bool get isReady => _ready;

  @override
  Future<Result<void>> load({required String modelPath}) async {
    _ready = true;
    return const Ok(null);
  }

  @override
  Future<void> dispose() async {
    _ready = false;
  }

  @override
  Future<Result<String>> complete({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.2,
  }) async {
    if (!_ready) {
      return const Err('FakeLlmEngine not loaded');
    }
    lastPrompt = prompt;
    return Ok(textResponse);
  }

  @override
  Future<Result<String>> completeJson({
    required String prompt,
    String? gbnfGrammar,
    int maxTokens = 256,
    double temperature = 0.1,
  }) async {
    if (!_ready) {
      return const Err('FakeLlmEngine not loaded');
    }
    lastPrompt = prompt;
    lastGrammar = gbnfGrammar;
    return Ok(jsonResponse);
  }
}

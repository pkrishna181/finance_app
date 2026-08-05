/// Gemma 3 instruction-tuned chat turn formatting.
///
/// See https://ai.google.dev/gemma/docs/core/prompt-structure
class Gemma3Chat {
  Gemma3Chat._();

  static const startOfTurn = '<start_of_turn>';
  static const endOfTurn = '<end_of_turn>';

  /// True when [prompt] already includes Gemma turn markers.
  static bool isFormatted(String prompt) => prompt.contains(startOfTurn);

  /// Wrap [userContent] for model generation (ends at the model turn).
  ///
  /// BOS is added by llama.cpp tokenization (`add_bos=true`), not here.
  static String formatUserTurn(String userContent) {
    final content = userContent.trim();
    return '${startOfTurn}user\n$content\n$endOfTurn\n${startOfTurn}model\n';
  }
}

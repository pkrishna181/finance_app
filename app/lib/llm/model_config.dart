/// Default on-device model metadata (see /model/MODEL_CARD.md).
class ModelConfig {
  const ModelConfig({
    required this.name,
    required this.quant,
    required this.sourceUrl,
    required this.sha256,
    required this.fileName,
    this.sizeBytes,
  });

  final String name;
  final String quant;
  final String sourceUrl;
  final String sha256;
  final String fileName;

  /// Exact file size, when known (cheap check before trusting the file).
  final int? sizeBytes;

  static const defaultGemma3_1b = ModelConfig(
    name: 'gemma-3-1b-it',
    quant: 'Q4_K_M',
    sourceUrl:
        'https://huggingface.co/bartowski/google_gemma-3-1b-it-GGUF/resolve/main/google_gemma-3-1b-it-Q4_K_M.gguf',
    // From the Hugging Face LFS metadata (verified 2026-10-13); update with
    // the weights (see MODEL_CARD.md).
    sha256:
        '12bf0fff8815d5f73a3c9b586bd8fee8e7b248c935de70dec367679873d0f29d',
    fileName: 'google_gemma-3-1b-it-Q4_K_M.gguf',
    sizeBytes: 806058496,
  );
}

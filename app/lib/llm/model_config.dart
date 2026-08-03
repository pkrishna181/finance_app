/// Default on-device model metadata (see /model/MODEL_CARD.md).
class ModelConfig {
  const ModelConfig({
    required this.name,
    required this.quant,
    required this.sourceUrl,
    required this.sha256,
    required this.fileName,
  });

  final String name;
  final String quant;
  final String sourceUrl;
  final String sha256;
  final String fileName;

  static const defaultGemma3_1b = ModelConfig(
    name: 'gemma-3-1b-it',
    quant: 'Q4_K_M',
    sourceUrl:
        'https://huggingface.co/bartowski/google_gemma-3-1b-it-GGUF/resolve/main/google_gemma-3-1b-it-Q4_K_M.gguf',
    // Re-verify when upgrading weights (see MODEL_CARD.md).
    sha256:
        '0000000000000000000000000000000000000000000000000000000000000000',
    fileName: 'google_gemma-3-1b-it-Q4_K_M.gguf',
  );
}

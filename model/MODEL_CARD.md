# Gemma-3 1B On-Device Model Card

| Field | Value |
|---|---|
| **Model** | `google/gemma-3-1b-it` |
| **Quantization** | Q4_K_M (GGUF) |
| **File** | `google_gemma-3-1b-it-Q4_K_M.gguf` |
| **Source URL** | https://huggingface.co/bartowski/google_gemma-3-1b-it-GGUF/resolve/main/google_gemma-3-1b-it-Q4_K_M.gguf |
| **SHA-256** | `12bf0fff8815d5f73a3c9b586bd8fee8e7b248c935de70dec367679873d0f29d` (806,058,496 bytes; from Hugging Face LFS metadata, verified on-device 13 Oct 2026) |
| **Runtime** | llama.cpp `b4875` via `arth_llm` shim |
| **Storage** | `<ApplicationSupport>/models/` (excluded from backups) |

## Attribution

Outputs from on-device inference are tagged in the `model_info` SQLite table
(`model_name`, `quant`, `sha256`, `source_url`, `last_loaded_at`) so parsed
LLM JSON can be traced to a specific weight file.

## License

Use per Google Gemma license and Hugging Face model card terms. Verify before
shipping to production.

## Upgrade policy

1. Download and verify new GGUF sha256.
2. Update `ModelConfig.defaultGemma3_1b` and this card.
3. Bump `model_info` row; old outputs remain attributed to prior hash.

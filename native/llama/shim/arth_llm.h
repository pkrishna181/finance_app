#ifndef ARTH_LLM_H
#define ARTH_LLM_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct arth_llm_handle arth_llm_handle;

typedef struct arth_llm_params {
    int32_t n_ctx;
    int32_t n_threads;
    int32_t n_gpu_layers; /* 0 = CPU only (v1 default) */
    int32_t use_mmap;     /* non-zero to mmap weights */
} arth_llm_params;

/// Per-token callback. Return non-zero to stop generation early.
typedef int (*arth_token_callback)(const char * token, void * user_data);

/// Generate flags for [arth_llm_generate_ex].
enum arth_llm_gen_flags {
    ARTH_GEN_CLEAR_KV = 1 << 0, /* clear KV cache before prompt decode (default) */
    ARTH_GEN_DECODE_ONLY = 1 << 1, /* skip prompt; decode from current KV state */
};

/// Load GGUF model from [model_path]. Returns NULL on failure.
arth_llm_handle * arth_llm_load(const char * model_path, arth_llm_params params);

/// Prefill [prompt] into KV cache (clears cache first). No token generation.
/// Returns 0 on success, negative on error.
int arth_llm_prefill(arth_llm_handle * handle, const char * prompt);

/// Bytes required for [arth_llm_save_state] buffer.
size_t arth_llm_state_size(arth_llm_handle * handle);

/// Copy KV+logits state into [dst] (must be >= arth_llm_state_size). Returns bytes written.
size_t arth_llm_save_state(arth_llm_handle * handle, uint8_t * dst, size_t cap);

/// Restore KV+logits state from [src]. Returns bytes read, or 0 on error.
size_t arth_llm_restore_state(arth_llm_handle * handle, const uint8_t * src, size_t len);

/// Generate tokens. [grammar_bnf_or_null] enables GBNF-constrained decoding.
/// Returns 0 on success, negative on error, positive if cancelled.
int arth_llm_generate(
    arth_llm_handle * handle,
    const char * prompt,
    const char * grammar_bnf_or_null,
    int32_t max_tokens,
    arth_token_callback callback,
    void * user_data
);

/// Extended generate with [flags] (see arth_llm_gen_flags).
/// [prompt] may be NULL when ARTH_GEN_DECODE_ONLY is set.
int arth_llm_generate_ex(
    arth_llm_handle * handle,
    const char * prompt,
    const char * grammar_bnf_or_null,
    int32_t max_tokens,
    int32_t flags,
    arth_token_callback callback,
    void * user_data
);

/// Request cancellation of an in-flight generate call.
void arth_llm_cancel(arth_llm_handle * handle);

/// Free model + context.
void arth_llm_unload(arth_llm_handle * handle);

/// Approximate RSS delta attributable to the loaded model (bytes).
size_t arth_llm_mem_usage(arth_llm_handle * handle);

/// Last error message from load/generate (empty if none).
const char * arth_llm_last_error(void);

/// Parse-check a GBNF grammar. Returns rule count, or 0 if parse failed.
int arth_grammar_rule_count(const char * grammar_str);

/// Decode tokens emitted by the last [arth_llm_generate] / [arth_llm_generate_ex] call.
int32_t arth_llm_last_generated_tokens(void);

#ifdef __cplusplus
}
#endif

#endif /* ARTH_LLM_H */

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

/// Load GGUF model from [model_path]. Returns NULL on failure.
arth_llm_handle * arth_llm_load(const char * model_path, arth_llm_params params);

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

/// Request cancellation of an in-flight [arth_llm_generate].
void arth_llm_cancel(arth_llm_handle * handle);

/// Free model + context.
void arth_llm_unload(arth_llm_handle * handle);

/// Approximate RSS delta attributable to the loaded model (bytes).
size_t arth_llm_mem_usage(arth_llm_handle * handle);

#ifdef __cplusplus
}
#endif

#endif /* ARTH_LLM_H */

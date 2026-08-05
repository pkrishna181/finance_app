#include "arth_llm.h"

#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "llama.h"

#include <math.h>

#ifdef __ANDROID__
#include <android/log.h>
#define ARTH_LOG(level, ...) __android_log_print(level, "arth_llm", __VA_ARGS__)
#else
#define ARTH_LOG(level, ...) fprintf(stderr, __VA_ARGS__)
#endif

struct arth_llm_handle {
    struct llama_model * model;
    struct llama_context * ctx;
    volatile bool cancel;
    size_t model_bytes;
};

static char g_last_error[512];
static int32_t g_last_generated_tokens = 0;

static void set_error(const char * fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vsnprintf(g_last_error, sizeof(g_last_error), fmt, args);
    va_end(args);
    ARTH_LOG(ANDROID_LOG_ERROR, "%s", g_last_error);
}

const char * arth_llm_last_error(void) {
    return g_last_error;
}

int32_t arth_llm_last_generated_tokens(void) {
    return g_last_generated_tokens;
}

static void log_llama(enum ggml_log_level level, const char * text, void * user_data) {
    (void) user_data;
#ifdef __ANDROID__
    int prio = ANDROID_LOG_INFO;
    if (level == GGML_LOG_LEVEL_ERROR) {
        prio = ANDROID_LOG_ERROR;
    } else if (level == GGML_LOG_LEVEL_WARN) {
        prio = ANDROID_LOG_WARN;
    }
    ARTH_LOG(prio, "llama: %s", text);
#else
    (void) level;
    fprintf(stderr, "llama: %s", text);
#endif
}

arth_llm_handle * arth_llm_load(const char * model_path, arth_llm_params params) {
    g_last_error[0] = '\0';

    if (model_path == NULL || model_path[0] == '\0') {
        set_error("empty model path");
        return NULL;
    }

    llama_backend_init();
    llama_log_set(log_llama, NULL);

    struct llama_model_params mparams = llama_model_default_params();
    mparams.use_mmap = params.use_mmap != 0;
    mparams.n_gpu_layers = params.n_gpu_layers;

    ARTH_LOG(ANDROID_LOG_INFO, "loading model: %s (mmap=%d n_ctx=%d n_threads=%d)",
             model_path, params.use_mmap, params.n_ctx, params.n_threads);

    struct llama_model * model = llama_model_load_from_file(model_path, mparams);
    if (model == NULL) {
        set_error("gguf_load_failed: %s", model_path);
        return NULL;
    }

    struct llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = params.n_ctx > 0 ? (uint32_t) params.n_ctx : 2048;
    cparams.n_threads = params.n_threads > 0 ? (int32_t) params.n_threads : 4;
    cparams.n_threads_batch = cparams.n_threads;

    struct llama_context * ctx = llama_init_from_model(model, cparams);
    if (ctx == NULL) {
        set_error("context_create_failed (n_ctx=%u)", cparams.n_ctx);
        llama_model_free(model);
        return NULL;
    }

    arth_llm_handle * handle = calloc(1, sizeof(arth_llm_handle));
    if (handle == NULL) {
        set_error("out_of_memory");
        llama_free(ctx);
        llama_model_free(model);
        return NULL;
    }

    handle->model = model;
    handle->ctx = ctx;
    handle->cancel = false;
    handle->model_bytes = llama_model_size(model);
    ARTH_LOG(ANDROID_LOG_INFO, "model loaded (%zu bytes)", handle->model_bytes);
    return handle;
}

void arth_llm_cancel(arth_llm_handle * handle) {
    if (handle != NULL) {
        handle->cancel = true;
    }
}

void arth_llm_unload(arth_llm_handle * handle) {
    if (handle == NULL) {
        return;
    }
    if (handle->ctx != NULL) {
        llama_free(handle->ctx);
    }
    if (handle->model != NULL) {
        llama_model_free(handle->model);
    }
    free(handle);
}

size_t arth_llm_mem_usage(arth_llm_handle * handle) {
    if (handle == NULL) {
        return 0;
    }
    size_t total = handle->model_bytes;
    if (handle->ctx != NULL) {
        total += llama_state_get_size(handle->ctx);
    }
    return total;
}

size_t arth_llm_state_size(arth_llm_handle * handle) {
    if (handle == NULL || handle->ctx == NULL) {
        return 0;
    }
    return llama_state_get_size(handle->ctx);
}

size_t arth_llm_save_state(arth_llm_handle * handle, uint8_t * dst, size_t cap) {
    if (handle == NULL || handle->ctx == NULL || dst == NULL) {
        set_error("save_state_invalid_args");
        return 0;
    }
    const size_t need = llama_state_get_size(handle->ctx);
    if (cap < need) {
        set_error("save_state_buffer_too_small (need=%zu cap=%zu)", need, cap);
        return 0;
    }
    const size_t written = llama_state_get_data(handle->ctx, dst, cap);
    if (written == 0) {
        set_error("save_state_failed");
    }
    return written;
}

size_t arth_llm_restore_state(arth_llm_handle * handle, const uint8_t * src, size_t len) {
    if (handle == NULL || handle->ctx == NULL || src == NULL || len == 0) {
        set_error("restore_state_invalid_args");
        return 0;
    }
    const size_t read = llama_state_set_data(handle->ctx, src, len);
    if (read == 0) {
        set_error("restore_state_failed");
    }
    return read;
}

int arth_llm_prefill(arth_llm_handle * handle, const char * prompt) {
    return arth_llm_generate_ex(handle, prompt, NULL, 0, ARTH_GEN_CLEAR_KV | ARTH_GEN_DECODE_ONLY, NULL, NULL);
}

static int decode_prompt(
    arth_llm_handle * handle,
    const char * prompt,
    bool clear_kv,
    bool decode_only
) {
    if (handle == NULL) {
        return -1;
    }
    if (decode_only && (prompt == NULL || prompt[0] == '\0')) {
        return 0;
    }
    if (prompt == NULL || prompt[0] == '\0') {
        return -1;
    }

    if (clear_kv) {
        llama_kv_cache_clear(handle->ctx);
    }

    const struct llama_vocab * vocab = llama_model_get_vocab(handle->model);
    const int n_prompt = -llama_tokenize(vocab, prompt, (int32_t) strlen(prompt), NULL, 0, true, true);
    if (n_prompt <= 0) {
        return -2;
    }

    llama_token * prompt_tokens = malloc((size_t) n_prompt * sizeof(llama_token));
    if (prompt_tokens == NULL) {
        return -3;
    }

    if (llama_tokenize(vocab, prompt, (int32_t) strlen(prompt), prompt_tokens, n_prompt, true, true) < 0) {
        free(prompt_tokens);
        return -4;
    }

    struct llama_batch batch = llama_batch_get_one(prompt_tokens, n_prompt);
    const int rc = llama_decode(handle->ctx, batch);
    free(prompt_tokens);
    return rc == 0 ? 0 : -5;
}

static int count_finite_logits(const llama_token_data_array * cur_p) {
    int count = 0;
    for (size_t i = 0; i < cur_p->size; ++i) {
        if (isfinite(cur_p->data[i].logit)) {
            ++count;
        }
    }
    return count;
}

static llama_token sample_with_grammar(
    struct llama_context * ctx,
    const struct llama_vocab * vocab,
    struct llama_sampler * grammar_smpl,
    struct llama_sampler * chain
) {
    const float * logits = llama_get_logits_ith(ctx, -1);
    const int n_vocab = llama_vocab_n_tokens(vocab);

    llama_token_data * cur = malloc((size_t) n_vocab * sizeof(llama_token_data));
    if (cur == NULL) {
        return LLAMA_TOKEN_NULL;
    }

    for (int i = 0; i < n_vocab; ++i) {
        cur[i] = (llama_token_data){ (llama_token) i, logits[i], 0.0f };
    }

    llama_token_data_array cur_p = {
        /* .data     = */ cur,
        /* .size     = */ (size_t) n_vocab,
        /* .selected = */ -1,
        /* .sorted   = */ false,
    };

    if (grammar_smpl != NULL) {
        llama_sampler_apply(grammar_smpl, &cur_p);
    }
    llama_sampler_apply(chain, &cur_p);

    const llama_token tok = cur_p.data[cur_p.selected].id;

    if (grammar_smpl != NULL) {
        llama_sampler_accept(grammar_smpl, tok);
    }
    llama_sampler_accept(chain, tok);

    free(cur);
    return tok;
}

int arth_llm_generate(
    arth_llm_handle * handle,
    const char * prompt,
    const char * grammar_bnf_or_null,
    int32_t max_tokens,
    arth_token_callback callback,
    void * user_data
) {
    return arth_llm_generate_ex(
        handle, prompt, grammar_bnf_or_null, max_tokens, ARTH_GEN_CLEAR_KV, callback, user_data
    );
}

int arth_llm_generate_ex(
    arth_llm_handle * handle,
    const char * prompt,
    const char * grammar_bnf_or_null,
    int32_t max_tokens,
    int32_t flags,
    arth_token_callback callback,
    void * user_data
) {
    if (handle == NULL || max_tokens < 0) {
        return -1;
    }

    const bool clear_kv = (flags & ARTH_GEN_CLEAR_KV) != 0;
    const bool decode_only = (flags & ARTH_GEN_DECODE_ONLY) != 0;

    if (max_tokens == 0 && decode_only) {
        return decode_prompt(handle, prompt, clear_kv, decode_only);
    }
    if (max_tokens <= 0) {
        return -1;
    }

    handle->cancel = false;
    g_last_generated_tokens = 0;

    const int pre = decode_prompt(handle, prompt, clear_kv, decode_only);
    if (pre != 0) {
        return pre;
    }

    const struct llama_vocab * vocab = llama_model_get_vocab(handle->model);
    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    struct llama_sampler * grammar_smpl = NULL;
    struct llama_sampler * chain = llama_sampler_chain_init(sparams);

    if (grammar_bnf_or_null != NULL && grammar_bnf_or_null[0] != '\0') {
        const int rule_count = arth_grammar_rule_count(grammar_bnf_or_null);
        ARTH_LOG(ANDROID_LOG_INFO, "grammar parse: %d rules (%zu bytes)",
                 rule_count, strlen(grammar_bnf_or_null));
        if (rule_count <= 0) {
            set_error("grammar_parse_failed");
            llama_sampler_free(chain);
            return -8;
        }

        grammar_smpl = llama_sampler_init_grammar(vocab, grammar_bnf_or_null, "root");
        if (grammar_smpl == NULL) {
            set_error("grammar_sampler_init_failed");
            llama_sampler_free(chain);
            return -8;
        }
    }

    llama_sampler_chain_add(chain, llama_sampler_init_temp(0.2f));
    llama_sampler_chain_add(chain, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));

    // Accept prefill tokens into temp/dist chain only (not grammar sampler).
    if (!decode_only && prompt != NULL && prompt[0] != '\0') {
        const int n_accept = -llama_tokenize(vocab, prompt, (int32_t) strlen(prompt), NULL, 0, true, true);
        if (n_accept > 0) {
            llama_token * accept_tokens = malloc((size_t) n_accept * sizeof(llama_token));
            if (accept_tokens != NULL) {
                if (llama_tokenize(vocab, prompt, (int32_t) strlen(prompt), accept_tokens, n_accept, true, true) >= 0) {
                    for (int i = 0; i < n_accept; ++i) {
                        llama_sampler_accept(chain, accept_tokens[i]);
                    }
                }
                free(accept_tokens);
            }
        }
    }

    if (grammar_smpl != NULL) {
        const float * logits = llama_get_logits_ith(handle->ctx, -1);
        const int n_vocab = llama_vocab_n_tokens(vocab);
        llama_token_data * probe = malloc((size_t) n_vocab * sizeof(llama_token_data));
        if (probe != NULL) {
            for (int i = 0; i < n_vocab; ++i) {
                probe[i] = (llama_token_data){ (llama_token) i, logits[i], 0.0f };
            }
            llama_token_data_array probe_p = { probe, (size_t) n_vocab, -1, false };
            llama_sampler_apply(grammar_smpl, &probe_p);
            const int finite = count_finite_logits(&probe_p);
            ARTH_LOG(ANDROID_LOG_INFO, "grammar preflight: %d/%d logits finite", finite, n_vocab);
            if (finite >= n_vocab - 10) {
                set_error("grammar_inactive (finite=%d/%d)", finite, n_vocab);
                llama_sampler_free(grammar_smpl);
                llama_sampler_free(chain);
                free(probe);
                return -9;
            }
            free(probe);
        }
    }

    char piece[256];
    int generated = 0;
    int status = 0;

    for (int i = 0; i < max_tokens; ++i) {
        if (handle->cancel) {
            status = 1;
            break;
        }

        const llama_token tok = sample_with_grammar(handle->ctx, vocab, grammar_smpl, chain);
        if (tok == LLAMA_TOKEN_NULL) {
            status = -3;
            break;
        }

        if (llama_vocab_is_eog(vocab, tok)) {
            break;
        }

        const int32_t n = llama_token_to_piece(vocab, tok, piece, (int32_t) sizeof(piece), 0, true);
        if (n < 0) {
            status = -6;
            break;
        }
        if (n > 0 && callback != NULL) {
            piece[n] = '\0';
            if (callback(piece, user_data) != 0) {
                status = 1;
                break;
            }
        }

        llama_token next = tok;
        struct llama_batch batch = llama_batch_get_one(&next, 1);
        if (llama_decode(handle->ctx, batch) != 0) {
            status = -7;
            break;
        }
        ++generated;
    }

    if (grammar_smpl != NULL) {
        llama_sampler_free(grammar_smpl);
    }
    llama_sampler_free(chain);
    g_last_generated_tokens = generated;
    return status;
}

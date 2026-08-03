#include "arth_llm.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "llama.h"

struct arth_llm_handle {
    struct llama_model * model;
    struct llama_context * ctx;
    volatile bool cancel;
    size_t model_bytes;
};

static void log_llama(const char * text, void * /*user_data*/) {
    fprintf(stderr, "llama: %s", text);
}

arth_llm_handle * arth_llm_load(const char * model_path, arth_llm_params params) {
    if (model_path == NULL || model_path[0] == '\0') {
        return NULL;
    }

    llama_backend_init();
    llama_log_set(log_llama, NULL);

    struct llama_model_params mparams = llama_model_default_params();
    mparams.use_mmap = params.use_mmap != 0;

    struct llama_model * model = llama_model_load_from_file(model_path, mparams);
    if (model == NULL) {
        return NULL;
    }

    struct llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx = params.n_ctx > 0 ? (uint32_t) params.n_ctx : 2048;
    cparams.n_threads = params.n_threads > 0 ? (int32_t) params.n_threads : 4;
    cparams.n_threads_batch = cparams.n_threads;
    cparams.n_gpu_layers = params.n_gpu_layers;

    struct llama_context * ctx = llama_init_from_model(model, cparams);
    if (ctx == NULL) {
        llama_model_free(model);
        return NULL;
    }

    arth_llm_handle * handle = calloc(1, sizeof(arth_llm_handle));
    if (handle == NULL) {
        llama_free(ctx);
        llama_model_free(model);
        return NULL;
    }

    handle->model = model;
    handle->ctx = ctx;
    handle->cancel = false;
    handle->model_bytes = llama_model_size(model);
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

int arth_llm_generate(
    arth_llm_handle * handle,
    const char * prompt,
    const char * grammar_bnf_or_null,
    int32_t max_tokens,
    arth_token_callback callback,
    void * user_data
) {
    if (handle == NULL || prompt == NULL || max_tokens <= 0) {
        return -1;
    }

    handle->cancel = false;

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
    if (llama_decode(handle->ctx, batch) != 0) {
        free(prompt_tokens);
        return -5;
    }

    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    struct llama_sampler * smpl = llama_sampler_chain_init(sparams);
    if (grammar_bnf_or_null != NULL && grammar_bnf_or_null[0] != '\0') {
        llama_sampler_chain_add(
            smpl,
            llama_sampler_init_grammar(vocab, grammar_bnf_or_null, "root")
        );
    }
    llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.2f));
    llama_sampler_chain_add(smpl, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));

    char piece[256];
    int generated = 0;
    int status = 0;

    for (int i = 0; i < max_tokens; ++i) {
        if (handle->cancel) {
            status = 1;
            break;
        }

        const llama_token tok = llama_sampler_sample(smpl, handle->ctx, -1);
        llama_sampler_accept(smpl, tok);

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

        batch = llama_batch_get_one(&tok, 1);
        if (llama_decode(handle->ctx, batch) != 0) {
            status = -7;
            break;
        }
        ++generated;
    }

    llama_sampler_free(smpl);
    free(prompt_tokens);
    (void) generated;
    return status;
}

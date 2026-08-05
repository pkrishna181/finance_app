#!/usr/bin/env bash
# Desktop smoke build for shim-level testing (Linux/macOS).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VENDOR="${ROOT}/vendor/llama.cpp"
BUILD="${ROOT}/build/desktop"

LLAMA_TAG="b4875"

if [[ ! -d "${VENDOR}/.git" ]]; then
  git clone --depth 1 --branch "${LLAMA_TAG}" \
    https://github.com/ggerganov/llama.cpp.git "${VENDOR}"
fi

cmake -S "${ROOT}" -B "${BUILD}" -DCMAKE_BUILD_TYPE=Release -DLLAMA_CPP_DIR="${VENDOR}"
cmake --build "${BUILD}" --target grammar_validate
chmod +x "${ROOT}/validate_grammars.sh"
"${ROOT}/validate_grammars.sh"
cmake --build "${BUILD}" --target arth_llm || true
echo "Desktop lib: ${BUILD}/libarth_llm.so (or .dylib)"
echo "Grammar validator: ${BUILD}/grammar_validate"

#!/usr/bin/env bash
# Reproducible Android build for libarth_llm.so (arm64-v8a).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VENDOR="${ROOT}/vendor/llama.cpp"
BUILD="${ROOT}/build/android-arm64"
OUT="${ROOT}/../../app/android/app/src/main/jniLibs/arm64-v8a"

# Pinned release — upgrade deliberately (see ARCHITECTURE.md).
LLAMA_TAG="b4531"
LLAMA_DATE="2026-01-18"

export LLAMA_TAG LLAMA_DATE

if [[ ! -d "${VENDOR}/.git" ]]; then
  git clone --depth 1 --branch "${LLAMA_TAG}" \
    https://github.com/ggerganov/llama.cpp.git "${VENDOR}"
else
  git -C "${VENDOR}" fetch --depth 1 origin "tag/${LLAMA_TAG}" || true
  git -C "${VENDOR}" checkout "${LLAMA_TAG}"
fi

: "${ANDROID_NDK_HOME:?Set ANDROID_NDK_HOME to your NDK root}"

cmake -S "${ROOT}" -B "${BUILD}" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-24 \
  -DANDROID_STL=c++_shared \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_CPP_DIR="${VENDOR}"

cmake --build "${BUILD}" --target arth_llm

mkdir -p "${OUT}"
cp -f "${BUILD}/libarth_llm.so" "${OUT}/"
echo "Built ${OUT}/libarth_llm.so (llama.cpp ${LLAMA_TAG}, ${LLAMA_DATE})"

# Optional emulator debugging (x86_64):
# Re-run with ANDROID_ABI=x86_64 and OUT=.../jniLibs/x86_64

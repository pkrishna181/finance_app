#!/usr/bin/env bash
# Build arth_llm.xcframework for iOS (device + simulator) with Metal enabled.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VENDOR="${ROOT}/vendor/llama.cpp"
OUT="${ROOT}/build/ios"
XCFRAMEWORK="${ROOT}/../../app/ios/Frameworks/arth_llm.xcframework"

LLAMA_TAG="b4531"
LLAMA_DATE="2026-01-18"

if [[ ! -d "${VENDOR}/.git" ]]; then
  git clone --depth 1 --branch "${LLAMA_TAG}" \
    https://github.com/ggerganov/llama.cpp.git "${VENDOR}"
else
  git -C "${VENDOR}" fetch --depth 1 origin "tag/${LLAMA_TAG}" || true
  git -C "${VENDOR}" checkout "${LLAMA_TAG}"
fi

build_one() {
  local sdk="$1"
  local arch="$2"
  local dir="${OUT}/${sdk}-${arch}"
  cmake -S "${ROOT}" -B "${dir}" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES="${arch}" \
    -DCMAKE_OSX_SYSROOT="${sdk}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_CPP_DIR="${VENDOR}" \
    -DGGML_METAL=ON
  cmake --build "${dir}" --config Release --target arth_llm
}

build_one iphoneos arm64
build_one iphonesimulator arm64
build_one iphonesimulator x86_64

rm -rf "${XCFRAMEWORK}"
xcodebuild -create-xcframework \
  -library "${OUT}/iphoneos-arm64/Release-iphoneos/libarth_llm.dylib" \
  -library "${OUT}/iphonesimulator-arm64/Release-iphonesimulator/libarth_llm.dylib" \
  -output "${XCFRAMEWORK}"

echo "Built ${XCFRAMEWORK} (llama.cpp ${LLAMA_TAG}, ${LLAMA_DATE})"

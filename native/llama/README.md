# llama.cpp native builds (Phase 4)

Pinned **llama.cpp `b4531`** (2026-01-18). Upgrades are deliberate — see
`ARCHITECTURE.md`.

## Layout

```
native/llama/
  shim/arth_llm.h   — stable C API (ffigen binds this only)
  shim/arth_llm.c   — thin wrapper over llama.cpp
  CMakeLists.txt
  build_android.sh  — arm64-v8a .so → app/android/.../jniLibs/
  build_ios.sh      — Metal xcframework → app/ios/Frameworks/
  build_desktop.sh  — dev-machine smoke build
  vendor/llama.cpp  — cloned by scripts (not committed)
```

## Shim API

| Function | Purpose |
|---|---|
| `arth_llm_load` | mmap GGUF, create context |
| `arth_llm_generate` | token loop; optional GBNF grammar; per-token callback |
| `arth_llm_cancel` | cooperative cancel flag |
| `arth_llm_unload` | free model + context |
| `arth_llm_mem_usage` | model size + context state bytes |

**Compromises vs full llama.h:** no embedding API, no multi-sequence batching,
no custom sampler chains from Dart — temperature fixed at 0.2 in shim v1.

## Android

```bash
export ANDROID_NDK_HOME=~/Android/Sdk/ndk/<version>
./build_android.sh
```

- **v1 ABI:** `arm64-v8a` only (production devices). Re-run with
  `ANDROID_ABI=x86_64` and alternate `OUT` for emulator debugging.
- CPU path with `-march=armv8.2-a+dotprod+i8mm` compile flags; ggml picks
  kernels at runtime. No GPU/OpenCL in v1.

Gradle can also build via `externalNativeBuild` (see `app/android/app/build.gradle.kts`).

## iOS

```bash
./build_ios.sh
```

Produces `arth_llm.xcframework` with **Metal** (`GGML_METAL=ON`). Link from
Xcode / CocoaPods as needed.

## Desktop smoke test

```bash
./build_desktop.sh
# Download a tiny GGUF (e.g. Gemma-3 1B Q4) then:
export LD_LIBRARY_PATH=build/desktop
./build/desktop/smoke_test path/to/model.gguf   # see tests/smoke_test.c
```

### GBNF parse check (run before every device LLM test)

Every `.gbnf` under `app/lib/llm/gbnf/` must parse through llama.cpp **on
desktop** — broken grammars fail at runtime on device with
`grammar_parse_failed` and zero decode tokens.

```bash
./build_desktop.sh          # builds grammar_validate + runs validate_grammars.sh
./validate_grammars.sh      # re-check after editing any .gbnf
```

If no GGUF is available, run the **manual device checklist**:

1. Install debug APK on arm64 Android device.
2. **`./validate_grammars.sh` must pass on desktop.**
3. Open **Settings → LLM (debug)** → download model on Wi‑Fi.
4. Open **LLM Benchmark** → Run → copy results text.
5. Confirm standard task prints schema-valid JSON for 3 held-out SMS.

## CI

Scripts are non-interactive once `ANDROID_NDK_HOME` / Xcode are present.
CI does **not** bundle the GGUF; app tests use `FakeLlmEngine`.

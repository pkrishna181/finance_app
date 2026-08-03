# Arth

Privacy-first personal finance for India. All parsing, categorization, and
on-device LLM inference stay on your phone — financial data never leaves the device.

See [ARCHITECTURE.md](ARCHITECTURE.md) for schema and pipeline design.

## Quick start

```bash
export PATH="$HOME/development/flutter/bin:$PATH"   # if needed
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

## Phase 0

Runnable Flutter shell, encrypted Drift schema, `LlmEngine` + `FakeLlmEngine`,
and SMS golden-test harness against `StubSmsParser`.

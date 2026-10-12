# Arth

Privacy-first personal finance for India. All parsing, categorization, and
on-device LLM inference stay on your phone — financial data never leaves the device.

See [ARCHITECTURE.md](ARCHITECTURE.md) for schema and pipeline design.

## Privacy

Arth makes no network requests with your data — no cloud parsing, analytics or
crash reporting. Two optional downloads exist, both off until you turn them on:

- the on-device LLM model weights (one-time), and
- mutual-fund prices: AMFI's public all-schemes NAV file
  (`portal.amfiindia.com/spages/NAVAll.txt`, ~1.5 MB), at most once a day or
  when you tap Update. Arth downloads the **whole** list and looks up your
  holdings on the phone, so the request reveals nothing about what you own.
  Turn it on or off under Privacy → Update fund prices.

Statement PDF passwords you choose to remember are kept in the phone's secure
storage (Android Keystore / iOS Keychain), are never shown again, and can be
removed any time under Privacy → Statement passwords.

Backups (Privacy → Backup & restore) are a single file encrypted with a
passphrase you choose (AES-256-GCM, PBKDF2 key). Arth writes it where you pick
and never uploads it; without the passphrase it cannot be opened.

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

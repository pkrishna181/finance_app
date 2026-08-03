# On-device model

Target: ~1GB 4-bit GGUF (Gemma-3 1B class or equivalent).

The model is **not** bundled in the APK. On first use the app will download or
sideload weights into app-private storage. No inference traffic leaves the device.

## Planned contents

- `MODEL_CARD.md` — license, quantization recipe, eval notes
- `fetch_model.sh` — download / verify checksum into device-sideload path

Phase 0: placeholder only.

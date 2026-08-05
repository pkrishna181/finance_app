# Arth — Architecture

Working name for a privacy-first personal finance app for the Indian market.
**Hard constraint:** no financial data ever leaves the device. No cloud APIs for
inference, parsing, analytics, or crash reporting that includes user data.

Last updated: 2026-08-05 (Phase 5 — hybrid LLM integration)

---

## Repo layout

```
/app
  lib/core           drift DB, crypto, models, Result
  lib/ingestion
    sms/             consent, native SMS channel, batch scan
    statement/       file picker, table_loader, header_mapper, row_parser, profiles
      pdf/           pdf_loader, scanned_detector, layout_to_grid, password_hints
  lib/parsing
    common/          shared extractors (amount/date/refs/vpa)
    sms/             regex cascade + templates
  lib/llm            LlmEngine, FakeLlmEngine, LlamaCppEngine, job queue, anchoring
  lib/insights       (later)
  lib/ui
/native/llama        arth_llm shim + llama.cpp b4531 (pinned)
/model               MODEL_CARD.md (Gemma-3 1B Q4)
/test/golden         sms/ + statement/
/app/tool            generate_statement_pdfs.py
ARCHITECTURE.md
```

---

## Dependency checks

| Package | Role | Check |
|---|---|---|
| `drift` 2.34.x + `sqlite3` 3.x | Typed SQLite + sqlite3mc | Active |
| `flutter_secure_storage` 10.x | Keystore/Keychain | Active |
| `permission_handler` 13.x | READ_SMS | Active |
| `excel_community` 2.2.0 | xlsx (ZIP); legacy BIFF `.xls` rejected | **Chosen Phase 2** — community fork; `.xls` routes to export XLSX/CSV |
| `csv` 8.x | CSV decode | dart ecosystem, recent |
| `file_picker` 8.x | File pick | Active |
| `pdfrx_engine` 0.4.x + `pdfium_flutter` | PDF text + positions | **Chosen Phase 3** — PDFium-based (preferred over pure-Dart renderers for extraction fidelity); active GitHub (espresso3389/pdfrx, 2025–2026); MIT; password via `PdfPasswordProvider` |
| `pdf` 3.x | Dev fixture generation only | DavBfr/dart_pdf; BSD; used in Python/reportlab path for goldens, not runtime import |

### Removed: `flutter_sms_inbox`

**Rationale:** limited pagination / sender filtering (plugin caps, coarse
queries). Replaced with an in-house Kotlin `MethodChannel`
(`com.arth.arth/sms_inbox`) that queries `Telephony.Sms.Inbox` directly with
`LIMIT`/`OFFSET`, date DESC, and SQL `LIKE` filters on DLT entity tokens from
`knownSenderEntities`. Returns `{sender, body, date_millis}` only — bodies
never logged.

### Rejected / not used

- `sqflite_sqlcipher` — poorly maintained
- MediaPipe LLM Inference — deprecated; LiteRT-LM later behind `LlmEngine`
- Original `excel` package — quieter maintenance; `excel_community` preferred
- **Syncfusion Flutter PDF** — capable but **commercial license** (Community
  license has revenue/user caps); not adopted without explicit license decision
- **dart_pdf_editor / pdf_graphics** — impressive pure-Dart renderer (2025–2026)
  but text-extraction maturity for arbitrary bank PDFs not verified; PDFium chosen
  for extraction path
- **dart_mupdf_donut** — pure-Dart PDF; maintenance signal weaker than pdfrx on
  pub.dev at Phase 3 check; not selected

---

## Data model (schema v5)

### Imports

`source_type` (`sms|csv|excel|pdf`), `source_label` (file name / scan label),
`content_hash` (sha256 of file bytes or scan id), `status`,
`row_count`, **`parsed_count`**, **`skipped_count`**, **`duplicate_count`**,
`notes`, `imported_at`.

Re-importing the same file hash with `status=succeeded` is a no-op
(`duplicate_file`).

### Transaction provenance

`transaction_imports (transaction_id, import_id)` UNIQUE — a txn may be linked
to both an SMS import and a statement import. Same `dedupe_hash` → one ledger
row, multiple sources.

### Unparsed statement rows

`unparsed_statement_rows` — raw row JSON + reason, attached to `import_id`, for
Phase-5 LLM fallback (same idea as `unparsed_sms_rows`).

### Dedupe (updated Phase 3)

- **Strong ref** (UPI/IMPS 12-digit, NEFT UTR) → `sha256(bank|amount|ref)` — **no date**
- **Weak/other ref** → `sha256(bank|date|amount|ref)`
- **Refless** → `sha256(bank|date|amount|time|normalized_body)` (unchanged)

**Migration note:** SMS carries transaction date; statements (especially credit
cards) carry posting date. Strong refs must collide across sources so one payment
does not duplicate when dates differ. Existing rows keyed with the old
`bank|date|amount|ref` material will not auto-merge with new imports; acceptable
for pre-release data.

---

## Statement import pipeline (Phase 2 + 3)

```
pick file → TableLoader (csv / excel) OR PdfStatementLoader (pdf)
         → List<List<String>> grid
         → HeaderMapper (score header rows; profile then generic synonyms)
         → StatementRowParser (Dr/Cr, continuation merge, extractors)
         → preview → confirm → upsert + provenance + unparsed rows
```

### PDF path (Phase 3)

```
bytes → pdfrx_engine open (password prompt if encrypted)
     → per-page loadStructuredText (word boxes)
     → ScannedPdfDetector (image-only / near-zero text → decline)
     → LayoutToGrid (y-cluster lines, gap-split cells, header/footer strip,
                      credit-card section splits)
     → same HeaderMapper + StatementRowParser as CSV/Excel
```

**Password policy:** Passwords are prompted per import via UI; per-bank hint map
in `password_hints.dart`. Passwords are **never stored** — decrypted bytes flow
through memory into the encrypted DB only.

**Scanned PDFs:** Declined with a clear message; no OCR in Phase 3.

### Header mapping strategy

1. Guess bank from preamble blob; pick best `StatementProfile`.
2. Scan first ~40 rows; skip junk markers unless the row looks headerish.
3. Score each candidate header: synonym exact/contains + token-overlap fuzzy
   against profile + generic synonym lists.
4. Require date + (amount|debit|credit). Highest score wins → `ColumnMap`
   with per-column confidence.

### Profiles

Optional per-bank hints under `statement_profiles/` (HDFC/ICICI/SBI/Axis/Kotak
account + HDFC/ICICI/Axis credit card). Unknown layouts fall back to
`generic_account`.

Long-running tabular parse runs in `Isolate.run`; PDF open + text extract runs
on the main isolate (password UI).

### Import preview (Phase 3)

Rows with single-amount default-debit carry `directionInferred: true`; preview UI
shows a chip and lets the user flip before confirm.

---

## Legacy `.xls` (Phase 3–4)

**BIFF `.xls` is not supported.** Files that are not ZIP-based (true legacy
Excel) are rejected up front with `xls_unsupported_export_xlsx_or_csv`. Users
should export **XLSX or CSV** from their bank portal. ZIP-based `.xlsx` and
CSV paths are unchanged.

---

## On-device LLM (Phase 4)

```
first use → ModelDownloadManager (resumable, sha256, Wi‑Fi default)
         → lazy arth_llm_load (mmap GGUF in ApplicationSupport/models/)
         → LlamaCppEngine (worker isolate, single-flight generation)
         → optional GBNF grammar (parsed_transaction.gbnf)
         → ParsedTransactionJsonValidator (accept/reject; never trust raw JSON)
         → idle unload after 3 min (configurable)
```

### llama.cpp pin

| Field | Value |
|---|---|
| Tag | `b4875` |
| Date | 2026-02-19 (Gemma 3 support; was b4532 — too old for Gemma 3) |
| Android | arm64-v8a CPU, dotprod/i8mm compile flags |
| iOS | xcframework + Metal (`GGML_METAL=ON`) |

Build: `/native/llama/build_android.sh`, `build_ios.sh`. Dart binds **only**
`arth_llm.h` (not llama.h) via `dart:ffi`.

### Shim API

`arth_llm_load`, `arth_llm_prefill`, `arth_llm_save_state`, `arth_llm_restore_state`,
`arth_llm_generate` / `arth_llm_generate_ex` (+ GBNF), `arth_llm_cancel`,
`arth_llm_unload`, `arth_llm_mem_usage`. Temperature fixed at 0.2 in shim v1.

### Grammar

`lib/llm/gbnf/parsed_transaction.gbnf` constrains JSON shape (paise ints,
ISO dates, enum wire names). Grammar narrows; validator decides.

### Model provenance

`model_info` table + `/model/MODEL_CARD.md`. `FakeLlmEngine` remains default
for all CI/unit tests.

### Debug UI

`LlmDebugSettingsScreen` (download, load, n_threads display) and
`LlmBenchmarkScreen` (prefill/decode tok/s, grammar vs unconstrained, RSS,
per-SMS wall time with/without prefix cache, standard-task wall time).
Routes gated by `kDebugMode`.

---

## Hybrid LLM (Phase 5)

The on-device LLM is a **suggester**, never an authority. All LLM output passes
schema validation + anchor-checks before surfacing in a review queue; ledger
inserts require explicit user confirm.

### Job queue (`lib/llm/jobs/`)

```
llm_jobs (Drift)
  type: sms_extract | stmt_row_extract | merchant_normalize | categorize
  payload_json, status, attempts (max 2), result_json, last_error

Runner (LlmJobRunner)
  → opportunistic while app alive (no WorkManager v1 — future step)
  → one job at a time, model kept loaded across batch
  → jobs sorted by type (prefix cache locality)
  → battery guard: skip if <20% and not charging
  → poison messages: failed after 2 attempts, never retry-loop
```

Trigger: Import tab **“N unrecognized — resolve”** (enqueue + run when engine
loaded) or manual debug run.

### Prefix cache (KV state)

Shim: `arth_llm_prefill`, `arth_llm_save_state`, `arth_llm_restore_state`,
`arth_llm_generate_ex` (append suffix without clearing KV).

SMS extract batch: prefill static few-shot prefix once → save state → per SMS
restore + append item suffix → GBNF decode.

**Device measurements (Samsung SM-S928U1, Gemma 3 1B Q4, 2026-08-05):**

| SMS | Full prompt (`no_prefix`) | Prefix reuse (`prefix_reuse`) |
|---|---:|---:|
| 1 | 37,730 ms | 45,854 ms |
| 2 | 40,176 ms | 39,992 ms |
| 3 | 42,735 ms | 36,835 ms |
| **3-SMS total** | **120,641 ms** | **122,681 ms** |

Items 2–3 save ~4–6 s each (~10% vs full prompt) because decode dominates (~40 s/item)
and prefill is only ~2–3 s of wall time. Item 1 pays one-time `prefill + save_state`
overhead (+8 s). **Batch breakeven:** prefix path wins from item 2 onward; a 10-SMS
batch projects ~6 s × 9 ≈ **54 s saved** vs 10 full prefills (first item amortizes setup).

Microbench same session: grammar decode 5.4 tok/s, ~800 MB RSS.

### Anchor-check (`lib/llm/anchoring.dart`)

`validateAgainstSource(rawText, llmJson)` per field:

| Field | Rule |
|---|---|
| amount_paise | Must match `extractSoleTxnAmount` |
| direction | Corroborated by keyword sets; no cue → `directionInferred=true` |
| booked_at | Must parse from raw text (LLM normalizes only) |
| bank_code | **Never from LLM** — sender/body guess overrides |
| raw_merchant | Token overlap or substring; balance-adjacent phrases demoted |
| refs / dedupe refs | Must appear in raw text |

Outputs `(cleanedJson, anchorReport)`. Critical failures →
`unresolvable_v1` (no retry).

### Feature 1 — unparsed queue

Source: `unparsed_sms_rows` (+ statement rows stub). Pipeline: LLM JSON →
validator → anchor-check → `llm_review_items` (pending) → user confirm →
`upsertTransactionWithProvenance`.

UI: `LlmResolveScreen` — raw SMS beside fields, per-field anchor icons.

### Feature 2 — merchant normalization

Precedence: **user alias > seed catalog > LLM**. Deterministic seed lookup
(`lib/llm/data/merchant_seeds.json`, ~200 brands). Unseen raw strings enqueue
one `merchant_normalize` job (deduped). Short prompt + `merchant_normalize.gbnf`.
Anchor: canonical name shares token with raw **or** is a seed brand.

### Feature 3 — categorization

Precedence: **user_correction > merchant map > keyword rules > LLM**.
Seed files: `category_rules.json` (merchant→slug + keyword rules). LLM fallback
uses `category_suggest.gbnf` (fixed enum). Stored as `suggested_category_slug`
until user confirms; corrections feed `user_corrections`.

### Seed data

| File | Entries |
|---|---|
| `merchant_seeds.json` | ~200 canonical Indian merchants + aliases |
| `category_rules.json` | ~30 merchant→category + ~11 keyword rules |

### Tests (CI uses FakeLlmEngine)

- `test/llm/anchoring_test.dart` — Phase 4 bad outputs caught
- `test/llm/llm_job_runner_test.dart` — ordering, battery, dedupe, poison cap
- `test/llm/hybrid_parse_e2e_test.dart` — unparsed → review → confirm → dedupe
- `test/llm/category_enum_test.dart` — invalid type/category rejected

### Phase 5 fragile spots

- **Prefix cache size**: full state serialize per SMS type; monitor RSS on device.
- **stmt_row_extract**: job type defined; processor stubbed v1.
- **WorkManager**: not wired — batch only while app process alive.
- **Battery guard**: injectable `BatteryGuard`; permissive default on desktop/tests.
- **1B model quality**: anchoring catches hallucinations; field accuracy still weak.

---

## SMS (Phase 1, updated Phase 2–3)

Cascade unchanged. Historical scan paginates via native channel until a short
page is returned.

---

## Engineering rules

- Golden fixtures before a parser is “done”.
- No analytics SDKs; never log SMS/statement bodies.
- Document dependency maintenance checks here.

---

## Phase 3–4 fragile spots

- **Layout reconstruction:** Column boundaries anchored from header + sample
  data rows; tight PDF word gaps can still merge narration into ref/date cells
  (mitigated by `resolveStatementRef` in row parser).
- **Font / encoding:** Rare PDFs with custom encodings may yield garbage text.
- **Sectioned credit cards:** Domestic/international sections work when each
  section has its own header row; nested summary boxes may confuse header scan.
- **Password formulas:** Hint map only; user must supply the correct password.
- **LLM shim:** llama.cpp API pinned to b4531; upgrades need shim retest.
  Token callback uses a single trampoline (not re-entrant). Placeholder sha256
  in `ModelConfig` until weights are verified on device.

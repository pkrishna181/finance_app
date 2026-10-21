# Arth — Architecture

Working name for a privacy-first personal finance app for the Indian market.
**Hard constraint:** no financial data ever leaves the device. No cloud APIs for
inference, parsing, analytics, or crash reporting that includes user data.

Last updated: Phase 12.3 — Ask screen (phase 12 complete)

**Network exception (price data, Phase 9+):** the only planned network use is an
**opt-in** download of public price lists (e.g. AMFI's all-schemes NAV file).
Only full lists are fetched — never per-fund/per-symbol lookups — so a request
reveals nothing about what the user holds. Nothing user-derived is ever sent.
Off by default; the opt-in screen and Privacy settings must say exactly what is
downloaded, from where, and that no user data is sent.

---

## Roadmap (feature parity with Paisa, adapted)

Ideas drawn from [Paisa](https://github.com/ananthakumaran/paisa) (AGPL-3.0 —
reimplement from docs/ideas only, never copy code).

| Phase | Scope |
|---|---|
| 7 ✅ | Budgets (per-category, rollover, alerts); yearly views + income statement (cash-flow sankey, spend heatmap); transaction search + bulk edit |
| 8 ✅ | Credit cards (cycle, due date, utilization, bill vs paid); manual transactions; savings goals; data "doctor" |
| 9 ✅ | Holdings layer: CAMS/KFintech + NSDL/CDSL CAS PDF import, manual assets (gold, FD, EPF/PPF, property); net worth; XIRR; opt-in price lists |
| 10 ✅ | Capital gains (FIFO lots, current Indian rules — verify at build time), tax harvesting, Schedule AL, allocation targets, retirement goal, loans |
| 11 ✅ | App lock; encrypted backup / restore; upcoming-payments calendar; reminders; notepad calculator ("sheets") |
| 12 ✅ | Ask tab: questions answered on the device — rule-based parser first, the local model only to read unusual wording; numbers always from app code |
| 13 ✅ | Parsing measured on real data: SMS templates from a real inbox (IDFC FIRST, IndusInd added), PDF statements read line by line, card statements linked to SMS; statement summaries checked against the totals each statement prints |

Not adopted: plain-text journal editor, ledger/hledger/beancount backends,
handlebars import templates (bank profiles cover this).

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
  lib/insights       aggregation (Phase 6.1): pure Dart + read-only repository
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
| `fl_chart` 1.x | Insights donut + trend bars | **Chosen Phase 6.2** — MIT, pure Dart/Flutter (no native/network), actively maintained; checked 2026-09 |
| `pdf` 3.x | Dev fixture generation only | DavBfr/dart_pdf; BSD; used in Python/reportlab path for goldens, not runtime import |

### Removed: `flutter_sms_inbox`

**Rationale:** limited pagination / sender filtering (plugin caps, coarse
queries). Replaced with an in-house Kotlin `MethodChannel`
(`com.arth.arth/sms_inbox`) that queries `Telephony.Sms.Inbox` directly with
`LIMIT`, `before_date_millis` cursor (strictly older than checkpoint), date
DESC, and SQL `LIKE` filters on DLT entity tokens from
`knownSenderEntities`. Returns `{sender, body, date_millis}` only — bodies
never logged. `countMessages` estimates total matching rows for progress UI.

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

## Data model (schema v7)

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
| amount_paise | Must match `extractSoleTxnAmount` — **only hard-reject** |
| direction | See precedence below — **never rejects** |
| booked_at | Must parse from raw text (LLM normalizes only) — **hard-reject** |
| bank_code | **Never from LLM** — sender/body guess overrides |
| raw_merchant | Token overlap or substring; balance-adjacent phrases demoted; bank+A/c phrases demoted |
| refs / VPA | Must appear in raw text **and** pass shape gates; dropped + disagreement row if not |

**Phase 5.4 shape gates** (refs / VPA / merchant):

| Field | Gate |
|---|---|
| VPA (`v`) | Must match `user@psp` shape; bare bank names / bonus tokens dropped |
| Ref (`f`) | Bare last-4 card digits dropped; NEFT UTR / IMPS 12-digit kept |
| Merchant (`m`) | `HDFC A/c`, balance-adjacent phrases demoted; VPA in merchant slot routed to `v` with seed hint on local part |

`MerchantSeedCatalog.merchantHintFromVpa` resolves VPA local parts against the
seed catalog before anchoring.

**Direction precedence** (mirrors statement bank logic):

| Source text | Result |
|---|---|
| Unambiguous debit/credit cue (keyword sets incl. `Dr`/`Cr` abbrev.) | Dart direction wins; silently overrides LLM `r`; `direction_inferred=false` |
| No direction cue | LLM `r` kept; `direction_inferred=true` |
| Conflicting cues (both debit and credit keywords) | LLM `r` kept; `direction_inferred=true` |

`Dr Rs` / `Cr Rs` style abbreviations count as unambiguous even when reversal
wording mentions the opposite keyword (SMS2 case).

Outputs `(cleanedJson, anchorReport)`. Critical failures on amount/date →
`unresolvable_v1` (no retry). Direction mismatch is **not** a failure.

### Disagreement telemetry (`llm_disagreements`, local only)

On-device model-quality ledger — never synced or logged off-device.
Rows: `job_id` (nullable), `field`, `llm_value`, `resolved_value`, `created_at`.

| `field` | When recorded |
|---|---|
| `direction` | Keyword override disagreed with LLM `r` |
| `merchant_demoted` | `raw_merchant` demoted |
| `vpa_dropped` | VPA nulled (not in source) |
| `ref_dropped` | Ref nulled (not in source) |
| `amount_rejected` | Amount anchor failed |
| `date_rejected` | Date anchor failed |

Debug screen shows per-field counts since install (read-only).

### Benchmark anchor verdict (standard task)

After `validation: OK/ERR`, runs the same `validateAgainstSource` path as
[LlmJobRunner]. One line per SMS:

```
anchor: usable
anchor: usable (dropped: v, f) (direction: overridden)
anchor: partial (dropped: m) (directionInferred)
anchor: rejected (amount)
```

Batch footer: `batch verdict: N usable / M rejected (K direction overrides)`.

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

- `test/llm/anchoring_test.dart` — Phase 4 bad outputs + Phase 5.4 shape gates
- `test/llm/llm_job_runner_test.dart` — ordering, battery, dedupe, poison cap
- `test/llm/hybrid_parse_e2e_test.dart` — unparsed → review → confirm → dedupe
- `test/llm/category_enum_test.dart` — invalid type/category rejected
- `test/ingestion/sms_scan_test.dart` — cancel/resume/restart, progressive writes
- `test/llm/llm_batch_coordinator_test.dart` — schedule run, stale job recovery
- `test/ui/import_screen_test.dart` — consent → scan flow, progress UI, resolve CTA

### Phase 5 fragile spots

- **Prefix cache size**: full state serialize per SMS type; monitor RSS on device.
- **stmt_row_extract**: job type defined; processor stubbed v1.
- **WorkManager**: not wired — batch runs opportunistically while app is alive (Phase 5.5); true background deferred.
- **Battery guard**: injectable `BatteryGuard`; permissive default on desktop/tests.
- **1B model quality**: anchoring catches hallucinations; field accuracy still weak.

### Phase 5.5 — opportunistic batch runner

`LlmBatchCoordinator` (`lib/llm/jobs/llm_batch_coordinator.dart`):

- Debounced `scheduleRun(db)` after enqueue (Import resolve badge, scan-complete CTA).
- Auto-loads downloaded GGUF if engine not ready; skips with `model_not_downloaded` otherwise.
- `onAppResumed` recovers stale `running` jobs → `pending`, then schedules a batch.
- `LlmResolveScreen` shows processing UI while jobs are pending/running.

`PrivacySettingsScreen`: revoke SMS consent, link to system READ_SMS settings.

Trigger: Import tab **"N unrecognized — resolve"** (enqueue + schedule batch) or manual debug run.

---

## SMS (Phase 1, updated Phase 2–3, historical scan 2026-08)

Regex cascade unchanged. **Historical scan** (`SmsIngestionSource.scanHistorical`):

```
Import tab → consent → READ_SMS → SmsHistoricalScanScreen
  → paginate inbox (newest-first, known senders)
  → parse in isolate chunks (default 50)
  → upsert transactions + insert unparsed_sms_rows progressively
  → checkpoint after each committed chunk (SharedPreferences)
  → cooperative cancel between pages/chunks; resume or restart on re-entry
```

Checkpoint: `last_processed_date_millis` + counts + `import_id` +
`estimated_total`. Resume queries strictly older than checkpoint; idempotent
writes make overlap harmless. Import row status: `succeeded` on full scan,
`partial` on cancel.

UI: progress stream (X of ~Y, parsed/unparsed/skipped), **Stop scan**, paused /
complete summary. **N unrecognized — resolve** on Import tab and scan complete
(enqueues `sms_extract` jobs, opens `LlmResolveScreen`; LLM batch runs
opportunistically — never inline during scan).

Lifecycle: app backgrounding requests cooperative cancel (same as Stop).

---

## Insights aggregation (Phase 6.1)

`lib/insights/` — no Flutter dependency; deterministic, paise integers only.

- `InsightsRepository` loads slim `InsightTxn` rows (raw SQL join to
  categories/merchants) for a date range, padded ±7 days so transfers across a
  month edge still pair.
- `InsightsAggregator` (pure): `summarize(month)`, `trend`, `topMerchants`,
  `dailySpend`, `weekdaySpend`, `monthOverMonth`, `categoryDeltas`.
- **Spend** = debits; **income** = credits in `salary`/`interest` or
  uncategorized; other categorized credits are **refunds** netting against that
  category (category display floored at 0).
- **Transfers excluded** (`TransferPairing`): category `transfers_self`, plus
  auto-paired debit/credit of equal amount on different accounts within 3 days.
  Both sides must be uncategorized/transfer-category; rows categorized by the
  user elsewhere never pair. Manual override = recategorize the row
  (`transfers_self` to force-exclude, any other category to force-include).
- Schema v7 adds indexes `idx_transactions_booked_at` and
  `idx_transactions_category_booked_at` (no table changes, no codegen impact).
- Tests: `test/insights/`.

### Recurring detection (Phase 6.3)

`RecurringDetector` (pure) over counted, non-transfer debits, grouped by
`merchantId` (else normalized raw label: lowercase, digits/punctuation
stripped, ≥3 chars):

1. Amounts form ≤ 2 consecutive levels (±5%) — one price change allowed
   (`PriceChange`), noisy spend rejected.
2. Min charges: weekly 4, monthly 3, quarterly 3, annual 2.
3. ≥ 75% of intervals fit one cadence (7±2, 30±4, 91±8, 365±15 days); an
   interval near 2× the cadence counts as one missed cycle.
4. `active` = last charge within 2 cycles of `asOf`; lapsed series are kept
   but excluded from the monthly-commitment total.

`kind`: `sip` (category `investments_sip`), `enach` (txn type enach/mandate or
category `emi`), else `subscription`. `InsightsRepository.loadRecurring` scans
13 months, flags rows (`is_recurring_candidate = 1`; `recurring_kind` only when
still null — never overwrites) and attaches the earliest upcoming
`mandate_notices` date whose merchant matches and amount is within 10%.
UI: "Subscriptions & EMIs" card (monthly total, next date, "price up").
Tests: `test/insights/recurring_detector_test.dart`.

### Anomalies (Phase 6.4)

`AnomalyDetector` (pure) flags unusual spending in the selected month against
up to 6 prior months held by the aggregator. Thresholds are constructor
parameters. One flag per transaction (duplicate > new payee > large):

| Kind | Rule |
|---|---|
| Category spike | ≥3 prior months; z ≥ 2 (σ floored at 10% of mean); ≥1.3× mean; ≥₹1,000 above it. Uncategorized ignored. |
| Large transaction | ≥5 prior debits in the category; > mean+3σ; ≥3× median; ≥₹2,000 |
| New payee | ≥20 prior debits overall; never-seen merchant; ≥₹5,000 and ≥ prior 90th percentile |
| Duplicate charge | same merchant + amount within 24h; ≥₹100 |

Top 5 by money impact shown as "Unusual this month". The ✕ button stores a
`user_corrections` row (`field = 'anomaly_dismissed'`, `new_value = key`;
keys: `dup:<txn>`, `new:<txn>`, `large:<txn>`, `cat:<slug>:<yyyy-MM>`). The
category rule engine only reads `field = 'category'`, so dismissals do not
affect categorization. Tests: `test/insights/anomaly_detector_test.dart`.

### Cash-flow and forecast (Phase 6.5)

`lib/insights/cashflow.dart` (pure):

- **`BalanceSeries`** — combined daily balance from `balance_after_paise`.
  Per account the day's last transaction (time, then id) is the closing
  balance, carried forward on quiet days; an account joins from its first known
  balance. Accounts with < 3 balance points are ignored. **Uses all rows
  including transfers** (balances don't care about spend semantics).
  Rows with `account_kind = 'card'` are skipped (card statements report
  outstanding, not money you hold) — Phase 8.1.
- **`CashflowForecaster`** (current calendar month only) — projected spend =
  spent so far + recurring charges still due (from 6.3 series; mandate date
  wins over the estimate; weekly series can fall due repeatedly; overdue ones
  are not projected) + non-recurring daily rate × days left. Rate = this
  month's non-recurring spend / days elapsed once ≥ 7 days have passed, else
  the average of up to 3 prior months. Projected balance = latest combined
  balance − projected remaining spend, when balances are known.
- **Category increases** — top 3 categories with ≥ ₹500 growth vs last month
  (categories with no prior spend excluded).

UI cards: "Month-end outlook", "Biggest increases vs last month", "Balance"
(60-day line). Tests: `test/insights/cashflow_test.dart`.

### Insights UI (Phase 6.2)

`InsightsScreen` (Insights tab) loads the selected month via
`InsightsRepository` → `InsightsSnapshot.build` (pure view-model: summary,
MoM spend delta, 6-month trend, category slices with tail folded into
"Other", top 5 merchants). Reloads when the tab is re-selected
(`reloadToken`) and on pull-to-refresh.

- Summary tiles: income / spend / net / savings rate.
- Category donut (`fl_chart`) + tappable legend → `CategoryTransactionsScreen`
  (read-only list of the transactions behind the number).
- Spend-trend bars with the selected month highlighted; chart is wrapped in a
  text `Semantics` summary.
- Uncategorized banner drills into the uncategorized list (it does **not** open
  the SMS resolve flow, which handles unparsed SMS, not categories).
- Drill-down lists are editable (Phase 6.6, below).
- Tests: `test/insights/insights_snapshot_test.dart`,
  `test/ui/insights_screen_test.dart`.

### Category editing (Phase 6.6)

Tapping a row in `CategoryTransactionsScreen` opens a category picker.
`InsightsRepository.recategorize`:

- Sets `category_id`, `category_source = 'user'`, `suggested_category_slug`
  and records a `user_corrections` row (`field = 'category'`, old → new).
- **"Also apply to N other transactions"** (off by default) recategorizes
  `similarTransactionIds` — same `merchant_id`, else same normalized raw label
  (`normalizeMerchantLabel`, shared with recurring detection) — skipping rows
  whose source is already `user`/`user_correction`. It also stores a
  **merchant-wide rule**: a `category` correction with `transaction_id` NULL,
  and sets `merchants.default_category_id` when the row has a merchant.
- Merchant-wide rules apply to newly inserted rows in
  `upsertTransactionWithProvenance` (only when the row has no category;
  `category_source = 'user_correction'`) and in `CategoryRuleEngine` after the
  per-transaction correction. Latest rule wins. Matching is exact on the
  normalized label, so a merchant whose raw text varies in letters (not just
  digits/punctuation) needs one rule per variant.
- `TransferPairing` treats `user_correction` like `user`.
- Insights reloads via `onChanged` after each edit.
- Tests: `test/insights/recategorize_test.dart`,
  `test/ui/insights_screen_test.dart`.

### Budgets (Phase 7.1)

Schema v8 adds `budgets` (one per category: `limit_paise`, `rollover`,
`start_month` yyyy-MM). `BudgetRepository` upserts by category (an edit keeps
the original start month). `BudgetCalculator` (pure, `lib/insights/budget.dart`):

- Spent = the aggregator's category spend (debits net of refunds, transfers
  excluded). Income, transfer and uncategorized slugs can't be budgeted.
- Status: `over` when spent > available, `warning` at ≥ 80%, else `ok`.
- **Rollover** (envelope): available = limit + Σ(limit − spent) for months from
  `start_month`, at most 6 back (the Insights aggregator holds 7). Overspending
  carries forward as a negative amount.
- Pace hint (current month only): "spending fast" when the fraction used is
  more than 10 points ahead of the fraction of the month elapsed.
- Suggested limit = average of the last 3 months that have data, rounded up to
  ₹100.

UI: "Budgets" card on Insights (summary + top 5, over-budget first) →
`BudgetsScreen` (edit/remove, add with suggested amount). Alerts are in-app
only for now; there is no notification plugin yet.
Tests: `test/insights/budget_test.dart`, `test/ui/insights_screen_test.dart`.

### Yearly view (Phase 7.2)

`lib/insights/yearly.dart` (pure): `FinancialYear` (Indian FY, Apr–Mar,
"FY 2026-27") and `YearSummary.build(agg, fy)`:

- Totals are the sum of the 12 monthly summaries, so they always match the
  monthly Insights numbers (refunds net per month, transfers excluded).
- Income by source: `salary`, `interest`, and uncategorized credits as
  `other_income`.
- `dailySpend` = **gross** debits per day (refunds don't reduce a day).
- Heatmap levels: quantiles of non-zero days (`quantileThresholds`, 4 levels).

`InsightsRepository.yearAggregator` loads the FY ± 7 days. `YearlyScreen`
(opened from the month title on Insights): totals, "Where the income went"
(one stacked bar of the top 5 categories + Other as a share of income; the
unfilled remainder is savings; the legend with amounts doubles as the table),
a daily-spend heatmap (one row per month, tap a day for its amount), the
income statement, and a month-by-month table whose rows jump back to that
month on Insights.

Chart colors live in `lib/ui/theme/chart_colors.dart`: the dataviz reference
categorical slots 1–6, with separate light and dark steps (validated with
`validate_palette.js` in both modes; light slots 3–5 are below 3:1 contrast,
so these charts always show labeled legends with amounts). They replace the
6.2 donut palette, whose dark green failed the chroma check. The sequential
ramp is a single blue hue; in dark mode it runs from dark to light.

Tests: `test/insights/yearly_test.dart`, `test/ui/insights_screen_test.dart`.

### Search and bulk edit (Phase 7.3)

`TxnQuery.parse` (pure, `lib/insights/txn_query.dart`) turns one line into
filters: free words (merchant, description or canonical name contains), quoted
phrases, `cat:<slug or name prefix>` / `cat:none`, `>`, `>=`, `<`, `<=`, `=`
amounts in ₹, `from:` / `to:` (yyyy-mm-dd, inclusive), `in:yyyy-mm`,
`debit` / `credit`, `bank:`, `type:` (txn type, e.g. `type:atm`; 8.4).
Invalid dates and unknown keys fall back to text.

`InsightsRepository.search` builds one parameterized SQL query (all terms
ANDed; `LIKE` wildcards in user text are escaped), newest first, capped at 500
rows. It shares `_select` with `loadRange`. `recategorizeMany` sets
`category_source = 'user'` on each row and logs one correction per row
(no merchant-wide rule: a bulk selection isn't one merchant).

`SearchScreen` (search icon on Insights): example chips, result count with
money out/in, tap a row to recategorize it (same picker and "apply to the same
merchant" option as the drill-down, now shared as
`ui/widgets/category_picker.dart`), long-press to select, "Select all", then
"Change category". Insights reloads after each change.

Tests: `test/insights/search_test.dart`, `test/ui/insights_screen_test.dart`.

### Saved statement passwords and batch import (Phase 8.0)

Indian banks, card issuers and CAS providers lock statement PDFs with a fixed
per-issuer password (PAN, DOB, …). `PdfPasswordVault`
(`ingestion/statement/pdf/password_vault.dart`) stores the ones the user
chooses to remember as one JSON entry in **flutter_secure_storage**
(`arth_pdf_passwords_v1`; Android Keystore / iOS Keychain). Passwords are never
written to the encrypted DB, logs, or shown again in the UI.

- We can't tell which issuer a locked PDF is from until it opens, so
  `PdfUnlockSession.provide` (passed to the loader as the password provider)
  tries **every** saved password, ordered by file-name match (label words or
  learnt bank code; generic words like "statement" ignored) then most recent
  use. pdfrx keeps calling the provider until one works.
- Only when none work is the user asked (up to 3 tries; "Skip" gives up). The
  prompt names the file, shows the issuer hint, and has "Remember for future
  statements" on by default with a suggested label ("AXIS credit card").
- `commit(bankCode)` after a successful open marks the saved entry used and
  records the detected bank, or saves the typed password if asked to.
- Manage: Privacy → Statement passwords (add, rename, forget; names only).

**Batch import:** the statement picker allows many files. One file keeps the
preview screen; several go to `BatchImportScreen`, which runs
`StatementBatchImporter` sequentially (no per-file preview) and lists each
file's outcome: imported (new / already had / to review), already imported
(same file hash), skipped (locked, no password), or failed (e.g. scanned PDF).
Overlapping statements and SMS rows dedupe through the usual `dedupe_hash`.

Tests: `test/ingestion/password_vault_test.dart` (unlocks the real encrypted
golden PDF), `test/ui/import_screen_test.dart`.

### Credit cards (Phase 8.1)

Schema v9: `transactions.account_kind` (`bank` | `card` | null),
`statement_summaries` (one per statement import), `credit_cards`.

**On import** `extractStatementSummary` (pure,
`ingestion/statement/statement_summary.dart`) scans the whole grid for the
card/account last 4 (masked numbers, "ending 1234", "Account No: …"; several
different numbers → none) and card bill facts (statement date, payment due
date, total / minimum due, credit limit; value in the same row after the label,
else the same column of the next row). The preview stamps `last4` onto rows
without an `account_hint`; `confirmImport` sets `account_kind` from the layout
(card profiles → `card`), fills `account_kind` / `account_hint` on rows already
known from SMS, and stores the summary. No false positives across the golden
statements; CSV and PDF of the same statement agree.

**Card status** (`CardCycleCalculator`, pure, `insights/credit_cards.dart`):
cycle from the card's statement day (clamped to short months), else the latest
printed bill's statement date / last transaction. The printed total due and due
date win when that bill closed within 5 days of the cycle; otherwise the bill is
estimated as spends − refunds in the previous cycle, and the due date comes from
the due day. Credits whose text looks like a payment (payment, thank you, BBPS,
NEFT, autopay, …) count as paid; other credits are refunds. Outstanding = unpaid
bill + unbilled; utilization = outstanding / limit (card's, else statement's).
States: due, overdue, paid, no bill.

`CreditCardRepository`: tracked cards (bank + optional last 4, limit,
statement / due day); suggestions = card rows grouped by bank + last 4 that
aren't tracked yet; `statuses(asOf)` sorted overdue → due soonest. A card with
no last 4 matches all of that bank's card rows.

UI: `CreditCardsScreen` (status tiles, "Found in your statements → Track",
add/edit/remove) and a "Credit cards" card on Insights (total outstanding and
up to two bills due), shown once a card is tracked or found. The utilization
note mentions the common 30% guideline.

Tests: `test/ingestion/statement_summary_test.dart`,
`test/insights/credit_cards_test.dart` (includes importing the HDFC card
golden statement end to end).

### Manual transactions (Phase 8.2)

`ManualTransactionRepository` adds / edits / deletes rows the user types in.
They are ordinary `transactions` rows with `dedupe_hash = 'manual:<random>'`
(never collides with imports), `txn_type = 'other'`, and a user category
(`category_source = 'user'`). Cash rows use bank code `CASH` and
`account_kind = 'cash'`. Only `manual:` rows can be edited or deleted (also
removing their `user_corrections`). `InsightTxn.isManual` comes from the hash
prefix.

UI: "+" on Insights → `ManualTransactionScreen` (spent / received, amount,
what for, category, paid with Cash or a known bank, date). Tapping a manual row
in a drill-down or search opens the editor instead of the category picker.
The cash form warns that ATM withdrawals already count as spending (mark them
Transfers (self) to avoid double counting); the data check-up flags this too.

Tests: `test/insights/manual_transactions_test.dart`,
`test/ui/insights_screen_test.dart`.

### Savings goals (Phase 8.3)

Schema v10: `goals` (target, optional target date, start date, already-saved
amount, expected yearly return in basis points, source, source ref) and
`goal_contributions`.

Progress source (no holdings until Phase 9):
- **manual** — already saved + contributions logged in the app;
- **account** — latest `balance_after_paise` of one bank account
  (`BANK|last4`; cards excluded);
- **category** — already saved + net debits in a category since the start date
  (e.g. `investments_sip`; credits such as redemptions subtract).

`GoalCalculator` (pure, `insights/goals.dart`): required monthly saving is the
annuity payment that grows the current amount to the target by the target date
at `return / 12` per month (straight division at 0%; never negative). Recent
pace = last 3 months of contributions / 3 (account: balance growth over 3
months / 3). States: reached, on track (pace ≥ required), behind, no deadline.
Projected date = months until the target at the recent pace (capped at 100
years).

UI: `GoalsScreen` (progress, needed per month, recent pace → projected month,
"Add money" for manual goals), `GoalEditScreen` (source picker; account list
shows current balances; logged contributions can be removed), and a Goals card
on Insights.

Tests: `test/insights/goals_test.dart`, `test/ui/insights_screen_test.dart`.

### Data check-up (Phase 8.4)

`DataDoctor` (pure, `insights/doctor.dart`) over the last 13 months
(`runDataDoctor` loads rows + counts). Findings, warnings first:

| Check | Rule |
|---|---|
| Balance doesn't add up | Per bank account with a last 4 (cards, cash, manual excluded): previous day-closing balance + net movement of the following days ≠ next closing balance (± ₹1). Compared across days because row order within a day is unreliable. |
| No data for N months | Calendar months with no rows between an account's first and last month. |
| Nothing since … | Account's latest row older than 45 days. |
| Uncategorized share | ≥ 20% of the last 3 months' spend (self-transfers excluded) → search `cat:none debit`. |
| Possible duplicates | Same bank, direction, amount (≥ ₹500) and day more than once → search for that day and amount. |
| Cash counted twice | Logged manual cash spending in a month that also has ATM withdrawals not marked Transfers (self) → search `type:atm debit`. |
| Unread messages / skipped rows | Unresolved unparsed SMS / statement rows. |
| Cards not tracked | Card suggestions from 8.1. |

`DoctorScreen` (heart-shield icon on Insights) links each finding to a
pre-filled search, the cards screen, or the Import tab (`InsightsScreen.
onOpenImport`, wired by `HomeShell`).

Tests: `test/insights/doctor_test.dart`, `test/ui/insights_screen_test.dart`.

### Investment statements — CAS (Phase 9.1)

Schema v11: `securities` (ISIN, name, mf / equity), `investment_accounts`
(folio or demat, provider), `investment_txns` (units / NAV × 10⁴, signed paise,
content-hash dedupe), `holding_snapshots` (units, price, value, cost per
account + security + date), `security_prices`.

`CasParser` (pure, `ingestion/investments/cas_parser.dart`) works on text lines
(`LayoutToGrid.textLines`). Formats were checked against the open-source
casparser project (MIT) for reference; the code is our own.

- **Detection:** "Consolidated Account Statement/Summary" heading plus folio /
  demat markers. Provider from the `CAMSCASWS` / `KFINCASWS` watermark, NSDL /
  CDSL header text, or "Registrar : CAMS/KFINTECH".
- **Detailed CAMS / KFintech:** AMC line → `Folio No:` (+ PAN) → scheme header
  (from the scheme-code line or the ISIN line; may wrap) → `Opening Unit
  Balance` → dated rows → `Closing Unit Balance … NAV on … Total Cost Value …
  Market Value on …` (may wrap). Rows: trailing decimal numbers (parentheses =
  negative); 4 → amount, units, NAV, balance; 3 / 2 disambiguated by whether
  units carry the running balance; 1 → amount (stamp duty, STT, IDCW paid).
  Types: purchase, SIP, redemption, switch in/out (incl. STP), IDCW payout /
  reinvest, tax, reversal, misc. Units that don't add up to the closing
  balance produce a warning.
- **Holdings tables** (NSDL / CDSL / summary CAS): an ISIN line whose trailing
  numbers contain quantity … price … value with quantity × price ≈ value
  (±0.5%); the value is taken from the rightmost column and the quantity from
  the leftmost, so face value / balance / average-cost columns in between are
  skipped. ISINs already covered by detailed schemes are ignored. Account from
  `DP ID / Client ID` or `BO ID`; date from the period or "as on".

`CasImporter` stores a statement in one DB transaction; `openStatementFile`
(in `batch_import.dart`) opens a PDF **once** (saved passwords via
`PdfUnlockSession`), routes CAS to `CasImporter` and everything else to the
bank / card preview using the same pages. Batch and single import both use it;
a single CAS shows a summary dialog instead of the preview.

- **Fund rows in demat CAS** that print a folio (NSDL lists non-demat
  folios) are stored under that folio, so the same fund from a CAMS CAS and an
  NSDL CAS is one holding, not two.
- **Opening balance:** units held before the statement period are stored as an
  `opening` transaction at the period start, valued at the first NAV in the
  statement (an estimate). Only the earliest opening per holding is kept, so
  overlapping statements don't double it.

Fixtures: `test/golden/cas/*.txt` (synthetic, modelled on real layouts) and
PDFs from `app/tool/generate_cas_pdfs.py` (CAMS one locked with
`ABCDE1234F`). Tests: `test/ingestion/investments/`.
**Known gap:** the synthetic fixtures can't cover every real template; check
against real statements and add failing ones as fixtures.

### Investment returns (Phase 9.3)

`PortfolioCalculator` (pure, `insights/portfolio.dart`), per account +
security:

- **Units now** = latest snapshot + later transactions (else the sum of
  transactions); **price** = latest known price (CAS NAVs, statement closing
  prices; AMFI in 9.4).
- **Invested** = FIFO cost of the units still held (purchases, SIPs, switch-in,
  IDCW reinvest, opening); the statement's "Total Cost Value" wins when nothing
  happened after that statement. Holdings without history (demat snapshot)
  have unknown cost and are left out of gain totals.
- **Booked gains** = sale proceeds − FIFO cost; reversals undo their purchase.
- **XIRR** (`xirr()`): Newton from 10%, bisection fallback on (−99.99%,
  10000%); needs ≥ 2 flows of both signs over ≥ 7 days. Flows: buys negative,
  sales and IDCW payouts positive, current value at the valuation date.
  Portfolio XIRR pools flows of all holdings with history.

UI: `InvestmentsScreen` (value, gain on invested, XIRR, booked gains, split by
mutual funds / shares; holdings with value, gain %, XIRR; holding detail with
units, price date, transactions) and an Investments card on Insights.

Tests: `test/insights/portfolio_test.dart` (XIRR against closed-form values,
FIFO, the CAS fixture end to end).

### Net worth (Phase 9.2)

Schema v12: `manual_assets` (name, kind: gold, fd, ppf, epf, nps, property,
vehicle, cash, other, loan; FD rate / start / maturity) and
`manual_asset_values` (value from a date on; history kept, one per day).

`NetWorthRepository.netWorth(on)`: bank accounts (latest
`balance_after_paise` per bank + last 4 on or before the date; cards excluded)
+ investments (`PortfolioRepository`) + manual assets − credit-card outstanding
(8.1, today only) − loans. FDs with a rate grow from the last recorded value,
compounded quarterly, capped at maturity (`fdValue`). `history()` = month-end
values for 12 months (card dues left out, leading empty months dropped).

UI: `NetWorthScreen` (total, owned / owed, month-end line chart with tap
tooltips, groups with items and "as of" dates, stale > 45 days flagged; add /
update / remove assets and loans) and a Net worth card at the top of Insights.
When there are no bank transactions yet, Insights still shows net worth and
investments.

Tests: `test/insights/net_worth_test.dart`, `test/ui/insights_screen_test.dart`.

### Fund prices from AMFI (Phase 9.4) — the only data download

`AmfiNavUpdater` (`ingestion/investments/amfi_nav.dart`) implements the
network exception at the top of this document:

- **Off by default.** `PriceFeedSettings` (shared preferences: on/off + last
  update time only). Turning it on — from Privacy or the Investments "Update
  fund prices" button — shows `showPriceFeedOptIn`, which states what is
  downloaded, from where, that nothing about the user is sent, and that shares
  aren't covered.
- **Request:** a plain GET of `https://portal.amfiindia.com/spages/NAVAll.txt`
  (public, every scheme, no parameters / cookies / identifiers).
- **Parsing:** `parseAmfiNav` reads ISINs from columns 2–3 and NAV + date from
  the last two columns, so the 6- and 8-column layouts both work (checked
  against the live file: 14,378 rows, 17,866 ISINs).
- **Matching** happens on the phone: only funds already in `securities` get a
  `security_prices` row (`source = 'amfi'`, upsert per day). Portfolio and net
  worth pick up the newest price automatically.
- **When:** "Update fund prices" on Investments, or `updateIfStale` (≥ 20 h)
  when the Investments screen opens and the feed is on. Failures are reported
  and write nothing. Tests inject a fake fetch; nothing in the test suite hits
  the network.
- Share prices are not downloaded (no bulk feed fits the policy cleanly yet);
  they refresh from the next demat CAS.

### Capital gains (Phase 10.1)

`insights/capital_gains.dart` (pure). Rules checked Oct 2026 (Budget 2026
made no capital-gains changes for FY 2026-27); all dates and rates live in
`CapitalGainsRules` — update there when the law changes.

| Category | Long-term after | Short-term | Long-term |
|---|---|---|---|
| Equity (shares, equity-oriented funds incl. arbitrage / ELSS) | > 12 months | 20% (15% before 23 Jul 2024) | 12.5% above ₹1.25 L a year (10% / ₹1 L earlier) |
| Debt fund bought ≥ 1 Apr 2023 (s. 50AA; > 65% debt from 1 Apr 2026) | never | slab | — |
| Debt bought earlier, other (gold, international, hybrid) | > 24 months (36 for sales before 23 Jul 2024) | slab | 12.5% (20% earlier; indexation not computed) |

- Category: `guessTaxCategory` from the fund name (arbitrage → equity;
  gold / international / FoF → other; liquid / bond / gilt / duration … →
  debt; otherwise equity), overridable per security
  (`securities.tax_category`, schema v13).
- Sales are matched FIFO against lots; a purchase **reversal** cancels the
  newest lots instead (fixed in the portfolio calculator too). Each slice is a
  `SaleLeg` with holding period, kind and gain; legs from `opening` lots are
  marked estimated.
- Grandfathering: equity bought before 1 Feb 2018 sold long-term uses
  max(cost, min(31 Jan 2018 price, sale value)) when that price is in
  `security_prices`; otherwise flagged.
- Set-off within the year: short-term losses against slab, equity STCG, other
  LTCG, equity LTCG (in that order); long-term losses against other LTCG then
  equity LTCG. Then the equity exemption and the estimate (no cess /
  surcharge; slab-rate gains reported separately; leftover losses shown as
  carry-forward).

UI: Investments → "Capital gains & tax": year selector (current year always
shown for planning), gains by kind, exemption used / left, estimated tax,
sales list, editable fund categories, and a clear "estimate, not tax advice"
note.

Tests: `test/insights/capital_gains_test.dart`, `test/ui/tax_screens_test.dart`.

### Tax harvesting (Phase 10.2)

`TaxHarvester` (pure, `insights/tax_harvest.dart`) for the current financial
year, on the open FIFO lots (`CapitalGainsCalculator.openLots`) at today's
price:

- **Exempt gains:** equity holdings only; take lots from the oldest while they
  are long-term and in profit (stop at the first short-term or loss lot,
  because redemptions are FIFO), biggest gains first, until the year's unused
  ₹1.25 L exemption is used; the last one is a proportional slice.
- **Losses:** only when this year has gains that would be taxed. Lots from the
  oldest while below cost; short-term losses offset slab / equity STCG first,
  then long-term gains; long-term losses offset only long-term gains. Tax
  saved is estimated at 20% (short-term) / 12.5% (long-term).
- ELSS (name contains ELSS / tax saver) lots within their 3-year lock-in are
  not sellable (and block later lots, FIFO).

Shown as "Save tax this year" on the capital-gains screen (current year), with
caveats about exit loads and costs; India has no wash-sale rule.

Tests: `test/insights/tax_harvest_test.dart`.

### Loans (Phase 10.3)

Schema v14: `loans` (kind, lender, principal, rate in bp, tenure months, first
EMI date, optional lender EMI) and `loan_prepayments` (date, amount, mode:
`tenure` keeps the EMI and finishes sooner, `emi` keeps the end date and
recomputes the EMI).

`LoanCalculator` (pure, `insights/loans.dart`): reducing-balance monthly
schedule (EMI = P·r·(1+r)ⁿ / ((1+r)ⁿ − 1), r = rate / 12; the lender's EMI wins
when entered; prepayments apply before the next EMI; rounding residue under 1%
of an EMI is folded into the last one). `status(asOf)`: outstanding, EMIs paid
/ left, next and last EMI, interest still to pay. `year(fy)`: interest and
principal paid in a financial year. `prepayEffect`: interest and EMIs saved,
or the new EMI.

`LoanRepository.emisSeen`: bank debits within ±1% of the EMI since the first
EMI. Outstanding loans are liabilities in net worth (and its history).

UI: Net worth → Loans (total outstanding and monthly EMIs, % repaid), loan
detail (status, interest / principal by year with the 24(b) / 80C note for
home loans, EMIs seen, prepayment calculator with "I made this payment"), and
add / edit with the calculated EMI shown.

Tests: `test/insights/loans_test.dart` (textbook EMI and balance values),
`test/ui/tax_screens_test.dart`.

### Asset allocation (Phase 10.4)

Schema v15: `allocation_targets` (asset class → basis points; must add to
100% or be empty).

`insights/allocation.dart` (pure): asset classes equity, debt, gold, cash,
real estate, other. Funds map from their tax category (10.1) with name hints
(gold / silver → gold; international / Nasdaq / S&P … → equity even though
taxed as "other"); shares → equity; bank balances → cash; manual FD / PPF /
EPF → debt, gold → gold, property → real estate, cash → cash, NPS / other →
other; vehicles and liabilities are not counted. Percentages, drift and
add / trim amounts are over the **planned** classes only, so e.g. property can
stay out. Rebalancing is suggested at ≥ 5 points of drift.

UI: Net worth → Asset allocation (bars with a target marker, drift, add /
trim amounts; target editor with presets 70/20/10, 60/30/10, 40/50/10) and a
note to rebalance with new money first because selling can be taxed.

Tests: `test/insights/allocation_test.dart`, `test/ui/tax_screens_test.dart`.

### Retirement plan (Phase 10.5)

Schema v16: `retirement_plans` (single row: ages, life expectancy, optional
monthly expenses, inflation, returns before / after retiring, optional safe
withdrawal rate, asset classes counted).

`RetirementCalculator` (pure, `insights/retirement.dart`):
- Expense at retirement = monthly × 12 × (1 + inflation)^years.
- Corpus = expense / SWR when a SWR is set; otherwise the value of yearly
  withdrawals (start of year) growing with inflation until the planned age at
  the post-retirement return (= years × expense when return = inflation).
- Current corpus = value of the chosen asset classes (10.4), grown at the
  pre-retirement return; the gap is closed by a monthly saving at the
  equivalent monthly rate (month-end).
- Expenses default to the average monthly spend of the last 12 months with
  data; "on track" compares the needed saving with the recent average monthly
  income − spend.

UI: Goals → Retirement (result card with the amount needed in future and
today's rupees, % funded, monthly saving needed, recent saving; assumptions
form with asset-class chips).

Tests: `test/insights/retirement_test.dart`, `test/ui/tax_screens_test.dart`.

### Schedule AL (Phase 10.6)

`insights/schedule_al.dart` + `ScheduleAlRepository`: a draft of ITR Schedule
AL (required when total income exceeds ₹1 crore from AY 2025-26; ₹50 lakh
before) as on 31 March of the chosen year (default: last completed year).

| Section | From |
|---|---|
| A immovable | manual property |
| B(1)(i) jewellery, bullion | manual gold |
| B(1)(iii) vehicles | manual vehicles |
| B(1)(iv)(a) bank incl. deposits | bank balances on / before 31 Mar, FD principal, PPF, EPF |
| B(1)(iv)(b) shares & securities | holdings at FIFO cost (value when cost unknown, flagged), NPS |
| B(1)(iv)(e) cash | manual cash |
| D liabilities | loans outstanding, manual loans, card dues |
| unclassified | manual "other" |

Items valued rather than costed (property, gold, vehicles, unknown-cost
shares) are flagged "value, not cost — check". UI: Net worth → Schedule AL.

Tests: `test/insights/schedule_al_test.dart`, `test/ui/tax_screens_test.dart`.

### App lock (Phase 11.1)

`local_auth` 3.x (`DeviceAuthenticator`, biometrics with the phone's PIN /
pattern as fallback). Android: `MainActivity` is now a
`FlutterFragmentActivity`, `USE_BIOMETRIC` permission, AppCompat launch /
normal themes (+ `androidx.appcompat` dependency) as the plugin requires.

`AppLockGate` wraps `HomeShell`: when enabled the app is locked at launch and
again after the chosen time in the background (immediately / 1 / 5 / 30 min,
default 1 min). The app stays alive underneath (`Offstage`); lifecycle events
caused by the auth prompt itself are ignored. Turning the lock on requires a
successful unlock first (and a device screen lock), so users can't lock
themselves out.

"Hide in recent apps" sets `FLAG_SECURE` through the
`com.arth.arth/window` channel (blank app-switcher preview, no screenshots).
Settings live in shared preferences (on/off and timing only). UI: Privacy →
App lock. Tests: `test/ui/app_lock_test.dart`.

### Encrypted backup and restore (Phase 11.2)

`core/backup/`: `BackupService.export` dumps **every** table (from
`sqlite_master`, so raw tables like `llm_disagreements` are included) as JSON
`{format, app, schemaVersion, createdAt, tables: {name: {columns, rows}}}`,
optionally plus the saved statement passwords (off by default), gzips it and
seals it with `BackupCrypto`:

- `ARTHBAK1` | PBKDF2 iterations | 16-byte salt | 12-byte nonce | AES-256-GCM
  ciphertext + tag; the header is the GCM associated data, so a wrong
  passphrase, tampering or a non-Arth file all fail cleanly.
- Key = PBKDF2-HMAC-SHA256(passphrase, salt, 600,000) (OWASP 2023), run in an
  isolate (~1.7 s on a desktop JIT; a few seconds on a phone). `pointycastle`
  4.x (MIT, pure Dart) provides PBKDF2 and GCM.

`restore` refuses backups from a newer schema, wipes all tables (foreign keys
off), inserts each backed-up table's rows for the columns that still exist
(older backups get defaults for newer columns), checks
`PRAGMA foreign_key_check`, notifies drift streams, and merges saved passwords
into the vault. `inspect` shows date / counts before anything is replaced.

UI: Privacy → Backup & restore (passphrase ≥ 10 characters typed twice, a
"no recovery if forgotten" warning; restore asks for confirmation after
showing what the file contains). Files are written where the user chooses;
nothing is uploaded. Tests: `test/core/backup_test.dart`,
`test/ui/backup_screen_test.dart`.

### Upcoming payments calendar (Phase 11.3)

`UpcomingCalendar` (pure, `insights/upcoming.dart`) merges, for a window
(default 60 days): loan EMIs from the amortisation schedule (authoritative);
active recurring series stepped by cadence from the mandate date (exact) or
the predicted next date (marked expected), skipping ones a loan EMI already
covers (±3 days, ±1% amount); and card bills that are due or overdue. Expected
items up to 7 days late show as overdue today; older ones are dropped.

UI: `UpcomingScreen` (30-day total, month grid with dots, red when overdue;
tap a day to filter; this month and next), from the "Subscriptions & EMIs"
card on Insights and from Loans. Feeds the reminders in 11.4.
Tests: `test/insights/upcoming_test.dart`.

### Reminders (Phase 11.4)

`flutter_local_notifications` 22 + `timezone` / `flutter_timezone`. Android:
`POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, the plugin's scheduled /
boot receivers, core-library desugaring. Inexact scheduling
(`inexactAllowWhileIdle`) at about 9 am, so no exact-alarm permission.

`ReminderPlanner` (pure, `insights/reminders.dart`) from the 11.3 calendar:
card bills 3 days before and on the due day (overdue: today), EMIs / mandates
the day before, SIPs / renewals the day before ("about" when predicted). A
reminder whose time passed earlier today goes out in a minute; older ones are
dropped. IDs are FNV-1a hashes of (what, day), so re-planning never
duplicates. Budget alerts (80% and over) are sent immediately, once per
level per month (state in shared prefs).

`ReminderService.sync` (off until the user enables it and grants permission)
cancels and re-schedules the next 30 days; `HomeShell` calls it on start and
resume. Groups: bills, subscriptions & SIPs, budgets. Notifications use
private visibility (content hidden on a secure lock screen). UI: Home → bell
→ Reminders. Tests: `test/insights/reminders_test.dart` (fake scheduler).

### Sheets — calculator notepad (Phase 11.5)

Schema v17: `sheets` (title, body, updated). `SheetEvaluator` (pure,
`insights/sheets.dart`) evaluates each line with a recursive-descent parser:
`+ - * / ^` (right-assoc power), brackets, unary minus, `%` and `x% of y`,
Indian units (`k`, `L` / `lakh`, `cr` / `crore`) and grouped numbers (Indian
`40,00,000` or western `4,000,000`; a comma not followed by a proper group is
an argument separator), `name = expr` variables, `sum` / `total` of the
current block (reset by blank lines and `#` headings, not `//` comments).
Functions: `emi(P, rate%, years)`, `sip(monthly, rate%, years)` (annuity
due), `fv`, `pv`, `round`, `min`, `max`, `abs`, `sqrt`; user data from a
precomputed `SheetData` (`SheetRepository.data`): `networth`, `investments`,
`cash`, `spend("category" | "all", monthsAgo)`, `income(monthsAgo)`,
`avg_spend(category, months)`. Errors are per line and never stop later lines.

UI: Home → calculator icon → Sheets (example sheet on first use). The editor
aligns results with each logical line by measuring wrapped heights with the
field's own theme-merged style, strut and text scaling; headings bold,
comments muted, tap a result to copy, autosave after 600 ms, help sheet.
Tests: `test/insights/sheets_test.dart`, `test/ui/sheets_screen_test.dart`.

### Release-build fixes (found on the emulator, Oct 2026)

Tests run on the desktop VM, so these only showed up in a release APK:

- **One database connection.** Screens used to call `openEncrypted()`
  themselves; separate connections to the same file failed with "database is
  locked" (e.g. migrations on one, a read on another — broke SMS import on a
  fresh install). Always use `ArthDatabase.shared()`; never close it.
  `busy_timeout = 5000` is set as a safety net.
- **pdfrx cache dir.** `pdfrxInitialize()` defaults to `$HOME/.pdfrx`;
  Android has no `HOME`, so every PDF import crashed. Mobile now passes the
  app temp dir. `openStatementFile` also turns any exception into an error
  result instead of crashing the import screen.
- **INTERNET permission.** Flutter only adds it to debug / profile
  manifests; the release manifest now declares it (model download, opt-in
  AMFI NAVs).
- **AI model screen.** Model download lived on a `kDebugMode`-only screen;
  `AiModelScreen` (Privacy → On-device AI model) is the user-facing one.
  The model's SHA-256 is now pinned (from Hugging Face LFS metadata); the full
  hash runs once off the UI thread and writes a `.verified` marker so later
  checks only compare size + marker. A resume that gets a full 200 response
  restarts instead of appending.
- **App lock covers every route.** `AppLockGate` moved to
  `MaterialApp.builder`, so pushed screens are hidden when the app re-locks.

Verify release-only behaviour on the `arth_test` emulator (Android 35
x86_64 with ARM translation runs the arm64 APK): SMS seeded with
`adb emu sms send`, statements pushed to `/sdcard/Download`.

### Ask — questions and answers (Phase 12.1)

`lib/ask/`. The model never produces a number: a question becomes an
`AskQuery` (intent + period + optional category / merchant), and
`AskAnswerer` computes the answer with the same code as the rest of the app.

- **Intents:** spend, income, savings, top categories, top merchants,
  largest payments, last paid, monthly average, net worth, budgets,
  upcoming payments.
- **`AskParser`** (pure, instant): finds one date phrase (today, this /
  last week, this / last month, month names — a month without a year is the
  most recent one, `since april`, last N days / weeks / months as a rolling
  range, this / last year, `FY 2025-26`, this / last FY), an intent from
  keywords, a category (display names, slugs, `kCategorySynonyms`), and a
  merchant from `AskVocabulary` (merchant names in the ledger). It is strict:
  any leftover word that isn't filler, a category or a known merchant fails
  the parse (`unknownWords`) instead of guessing. Default period: this month.
- **`AskAnswerer`:** totals come from `InsightsAggregator.summarizeWithin`
  per calendar month (new; `summarize` delegates to it), so whole months
  match Insights exactly and partial ranges use the same rules (transfers
  excluded, refunds net per category). Merchant totals and rankings count
  payments only (`topMerchantsWithin`, optional category). Budgets use
  `BudgetCalculator`, net worth `NetWorthRepository`, upcoming
  `UpcomingRepository`, last paid `InsightsRepository.search`. Each answer
  carries `understoodAs` ("Spending · Food Delivery · Sep 2026"), a headline,
  rows, transactions, a note on what is / isn't counted, and a `TxnQuery`
  string to open the matching transactions in Search. A period with no
  transactions says so instead of answering ₹0.

Tests: `test/ask/ask_parser_test.dart`, `test/ask/ask_answerer_test.dart`.

### Ask — the model as a fallback reader (Phase 12.2)

Only when `AskParser` fails. Measured on the real Gemma 3 1B, asking the
model for every field (intent, category, merchant, period, month, n) read
**2 / 24** unusual questions correctly — it can't do date arithmetic or
copy merchants reliably. So the job is split:

- **Parser, always:** even when it can't read the whole question it returns
  an `AskPartial` — the period, a category named in the question, a merchant
  named word-for-word (whole words of a ledger merchant name), a keyword
  intent if any, look-ahead days / month counts, and `ignoredWords`. Number
  words, "fortnight", "a couple of", "since the year began" are rewritten
  first.
- **Model, only classification:** `AskPrompt` (intent descriptions, the
  user's category ids, 12 short examples) → grammar `{"intent":…,
  "category":…}` from fixed lists (the user's own categories). ~10 output
  tokens.
- **Merge (`AskModelReader.validate`, pure):** a specific keyword intent
  beats the model (plain "spend" doesn't); the question's category beats the
  model's; an income category turns spend / savings / rankings into income;
  fields that don't fit the intent are dropped; `last_paid` needs something
  to look for. Dates and merchants never come from the model.

`test/ask/ask_model_eval_test.dart` runs the real model (skipped unless
`ARTH_MODEL_PATH` is set and `LD_LIBRARY_PATH` points at the desktop
`libarth_llm.so`). Desktop, 4 threads, ~2.5 s per question. Results
(Oct 2026):

| Set | Overall | Parser | Model |
|---|---|---|---|
| Tuning (25, prompt and keywords tuned on these) | 24 / 25 | 2 / 2 | 22 / 23 |
| Held out (20, never tuned on) | 12 / 20 | 5 / 5 | 7 / 15 |

The model's usual mistake is defaulting to `spend`; answers it read show
"Read by the on-device model as: …" plus ignored words, so a misreading is
visible. Don't tune on the held-out set; add new held-out questions instead.

`LlmBatchCoordinator.ensureEngineLoaded()` (extracted from `runNow`) loads
the model for Ask; a busy engine (batch job running) returns `model_busy`.

**FFI fix found by this work:** `arth_llm_load` takes `arth_llm_params` by
value, but the Dart binding passed a pointer since Phase 4. C read the
pointer's bits as `n_ctx` / `n_threads` (and garbage for `use_mmap`,
`n_gpu_layers`): when the low 32 bits were negative it fell back to 2048 and
worked; otherwise it tried a context of hundreds of millions of tokens and
crashed (`std::bad_alloc`). The binding now passes the struct by value.
`build_desktop.sh` now builds with `-fPIC` (the shared shim didn't link on
desktop before).

### Ask screen (Phase 12.3)

`AskScreen(database, coordinator)` in the fourth tab. Intro with example
questions; each exchange shows the question, then a card with how it was
read (`understoodAs`, prefixed "Read by the on-device model as:" and followed by
"Ignored: …" when the model was used, so a misreading is visible), the headline, rows, matching
transactions, the note and **See transactions** (opens `SearchScreen` with
the answer's query). Spending answers compare with the previous month in the
headline. The vocabulary is rebuilt per question (imports add merchants).
Not understood → which words weren't recognised plus examples; without the
model, a button to *On-device AI model*; busy model → try again shortly.
Conversations are kept in memory only.

Tests: `test/ui/ask_screen_test.dart` (suggestion → answer → Search; typed
merchant; no model; model path with `FakeLlmEngine`). Rendered light / dark.

---

### Measuring parsers on real data (Phase 13)

Synthetic fixtures had hidden that real parsing was near zero: on one real
inbox (≈12,000 bank messages, 2020–2026) the SMS parser read 0 SBI Card, 0
SBI UPI and 0 Axis messages and never fetched IDFC FIRST or IndusInd; on a
real SBI savings statement and an SBI Card bill the PDF import read 0 rows.
Two harnesses, skipped unless pointed at local data, measure this:

- `test/parsing/real_sms_coverage_test.dart` (`ARTH_SMS_DUMP` = JSON lines of
  `{address, date, body}`, e.g. from `adb shell content query --uri
  content://sms/inbox`; `ARTH_SMS_REPORT`) — per bank: transactions,
  mandates, skips by reason, unparsed, and senders the scan never reads,
  with samples of each.
- `test/ingestion/pdf/real_pdf_coverage_test.dart` (`ARTH_PDF_DIR`,
  `ARTH_PDF_REPORT`) — grid and line parser results, printed totals, the
  digest with its checks, and every positioned line.

Real data stays on the machine. Fixtures made from it use the real layout
with made-up names, amounts, account numbers and references.

### PDF statements line by line (Phase 13.1)

`LineStatementParser` (`ingestion/statement/line_statement_parser.dart`)
reads layouts the header-based grid can't: SBI accounts (table header drawn
without text), SBI Card (centred headers over wide columns), descriptions
wrapped above and below the date line. `file_source.previewBytes` uses it
when it reads more rows than the grid.

```
positioned lines → rows that start with a date and end in amounts
  → amount columns per page: overlapping spans of line-ending amounts
    (right-aligned or centred; amounts inside a description don't end the line)
  → undated rows with a C/D/M marker inside the table (fees, GST) take the
    previous date
  → wrapped lines join the nearest row, lines above counting double
  → direction: running balance, else C/D/M or Cr/Dr marker, else column
```

Card `M` rows (EMI instalments) are counted, not imported: the purchase
they repay was spent earlier. Narration clean-up drops SBI's
`WDL TFR`/`DEP TFR` prefix and `<txn no> AT <branch>` suffix and rejoins
paths and NEFT references split across lines; payees come from
`UPI/DR/<ref>/<name>/` and `NEFT*<ifsc>*<utr>*<name>`. Also fixed in the
grid: a word left of the first column went to the last.

### SMS from a real inbox (Phase 13.2)

About 45 templates written from real formats (SBI UPI in four eras, SBI
Card, SBI account alerts, NEFT/IMPS, INB, ATM/debit card, IDFC FIRST,
IndusInd, Axis card, Paytm, ICICI eazypay). Senders `IDFCFB`, `INDUSB`,
`CBSSBI`, `SBIPSG`, `ATMSBI`, `SBIBNK`, `IPAYTM` map to their banks and are
fetched by the scan.

Skips, each checked against real samples (`detectNoise`): no amount at all
(notices, logins, advisories in other languages), OTP, declined, fraud
checks, bill and statement alerts, collect requests, holds, credit-limit
alerts, EMI-conversion offers, e-mandate set-up, loan-account credits, fund
purchases (the CAS covers them), and spends whose first amount is foreign
(the INR amount is only on the statement). "will be processed", "is
scheduled on" and "will be executed" are mandates (upcoming debits).

Measured afterwards, of messages the scan reads: SBI 5,356 transactions /
20 unparsed, IDFC 1,383 / 1, Axis 306 / 3, Paytm 322 / 14, IndusInd 104 / 1.

**Card statements ↔ SMS.** Card SMS carry no reference the statement prints,
so exact dedupe can't match them. `ArthDatabase.findSmsMatch` links a
statement row without a strong reference to an SMS transaction with the same
bank, amount and direction within a day and a compatible card number (one
ends with the other); each SMS row matches once per statement, so two
identical payments on one day stay two. The preview counts them as already
known. A bank named in a statement now wins over the layout profile's bank.

### Statement summaries (Phase 13.3)

```
PDF lines → extractPrintedTotals → PrintedTotals (what the statement says)
rows + PrintedTotals → StatementDigest.build → totals, charges, payees,
                                               checks
```

`PrintedTotals` (`printed_totals.dart`): a value's label is the text before
it on its line, else the phrase stacked directly above it (up to five lines,
34pt; a phrase is words ≤5pt apart). Reads period, opening/closing balance,
total debits/credits and their counts; for cards previous balance, payments,
purchases, fees, total and minimum due, due and statement dates, credit and
available limit (cash limit recognised but not kept). For PDFs these replace
the grid's bill-fact guesses (the grid reader took a minimum due from policy
text).

`StatementDigest` (`statement_digest.dart`, pure): money in/out and counts,
charges (fee/charge/GST/interest/markup rows), interest earned, top payees
and sources (`payeeKey`: drops places, company suffixes and card-network
prefixes; keeps two words for platforms like Google), largest payments,
instalments, and `DigestCheck`s: parsed vs printed debits (cards: minus
fees), credits, counts, and opening ± movement vs closing (cards: previous −
paid + spent vs outstanding). Money matches to a rupee, counts exactly.

UI: picking one statement opens `StatementPreviewScreen` — the summary
(`StatementSummaryView`: whether it adds up and which figure doesn't, a
plain overview from `statementOverview`, bill, charges, payees, largest),
then the rows (guessed directions to flip) and Import. Import → *Your
statements* lists imported statements (`StatementHistory`); each rebuilds
its digest from the rows the import linked and the totals stored with it
(schema 18: `statement_summaries.printed_json`, `instalments_paise`,
`instalment_count`; every statement import gets a summary row). A card
statement printing only the last two digits takes the card number of the SMS
rows it linked.

A paragraph by the on-device model was tried and dropped: Gemma 3 1B opened
with filler, misstated facts, and looped when its grammar banned digits.
The overview is written by code.

Tests: `test/ingestion/line_statement_parser_test.dart`,
`statement_summary_feature_test.dart`, `cross_source_dedupe_test.dart`,
`test/parsing/real_formats_test.dart`, 33 `real_*` golden SMS,
`test/ui/statement_summary_screens_test.dart`.

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
- **Line parser vs grid:** chosen by row count. A layout where the grid reads
  most rows but not all keeps the grid's result; the summary's checks show it.
- **Printed totals:** label-above-value needs real word spacing; two labels
  closer than 5pt read as one phrase.
- **SMS templates** come from one inbox (SBI, IDFC FIRST, Axis, IndusInd,
  Paytm). Other banks still fall back to the generic templates; measure with
  the harness before trusting a new bank.
- **Font / encoding:** Rare PDFs with custom encodings may yield garbage text.
- **Sectioned credit cards:** Domestic/international sections work when each
  section has its own header row; nested summary boxes may confuse header scan.
- **Password formulas:** Hint map only; user must supply the correct password.
- **LLM shim:** llama.cpp API pinned to b4531; upgrades need shim retest.
  Struct arguments are passed **by value** — match `arth_llm.h` exactly in
  `arth_llm_bindings.dart` (a pointer here silently corrupted load params
  until Phase 12).
  Token callback uses a single trampoline (not re-entrant). Placeholder sha256
  in `ModelConfig` until weights are verified on device.

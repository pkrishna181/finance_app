---
title: "Arth — Build Timeline"
subtitle: "From first commit to a verified release build"
date: "13 October 2026 · as of commit a2f3727 (main)"
---

# Arth — Build Timeline

*Covers every phase from the first commit (3 Aug 2026) to `main` at `a2f3727`
(13 Oct 2026). Dates are commit dates. Phases 0–4 arrived together in the
first commit; their content is reconstructed from the architecture record.*

## At a glance

| | |
|---|---|
| Duration | 3 Aug 2026 → 20 Oct 2026 |
| Phases | 0 → 12, plus a release-hardening pass |
| Commits on `main` | 37 feature/fix commits, 4 merged pull requests |
| App code | ~32,700 lines of Dart in 177 files |
| Tests | 443 automated tests in 68 files (unit, repository, widget, real-model eval) |
| Database | Encrypted SQLite, schema v17, 31 tables |
| Release check | Release APK run on an Android 35 emulator: SMS import, statement + locked CAS import, AI model download verified |

```
Aug 2026   ▕ Phase 0–4  foundations · SMS · statements · PDF · on-device AI
           ▕ Phase 5    hybrid AI: review queue, merchants, categories, batch runner
Sep 2026   ▕ Phase 6    insights: aggregation, charts, recurring, anomalies, forecast
Oct 12     ▕ PR #1 merged (Phases 4–6.5)
           ▕ Phase 6.6  category editing
           ▕ Phase 7    budgets · year view · search
           ▕ Phase 8    passwords + batch import · cards · cash · goals · check-up
           ▕ Phase 9    CAS investments · returns/XIRR · net worth · AMFI prices
           ▕ Phase 10   tax · harvesting · loans · allocation · retirement · Sched. AL
           ▕                                         → PR #2 merged
Oct 12–13  ▕ Phase 11   app lock · encrypted backup · calendar · reminders · sheets
           ▕                                         → PR #3 merged
Oct 13     ▕ Release fixes found on an emulator      → PR #4 merged
Oct 20     ▕ Phase 12   Ask tab · FFI load-params fix
```

---

## Part 1 — Foundations (August 2026)

### Phase 0 — Shell and storage
- Runnable Flutter app with Home / Insights / Import / Ask tabs.
- Encrypted database (drift + SQLite3MultipleCiphers); key generated on the
  device and kept in Android Keystore / iOS Keychain.
- `LlmEngine` interface with a `FakeLlmEngine` for tests; SMS golden-test
  harness.

### Phase 1 — SMS parsing
- Regex template cascade for Indian bank SMS (HDFC, ICICI, SBI, Axis, Kotak,
  Paytm + generic UPI/IMPS/NEFT), shared extractors for amounts, dates,
  references, VPAs and balances.
- Golden fixtures: each sample SMS paired with its expected parse.

### Phase 2 — Statement import (CSV / Excel)
- File picker → table loader → header mapper (bank profiles + generic
  synonyms with per-column confidence) → row parser (Dr/Cr, continuation
  lines) → preview → confirm.
- Import records with provenance: one ledger row can be linked to both an SMS
  and a statement.

### Phase 3 — PDF statements and de-duplication
- PDFium text extraction with layout reconstruction (line clustering, cell
  splitting, header/footer stripping, credit-card sections); scanned PDFs
  declined; password prompt for locked PDFs.
- De-duplication by strength of reference: UPI/IMPS/UTR references match
  across sources regardless of date; weaker keys include the date.
- Credit-card profiles (HDFC, ICICI, Axis).

### Phase 4 — On-device AI (committed 3 Aug)
- llama.cpp (pinned) behind a small C shim (`arth_llm`) bound via `dart:ffi`;
  Gemma 3 1B Q4_K_M; resumable model download; GBNF-constrained JSON output;
  validator that never trusts raw model output.
- Legacy binary `.xls` rejected with guidance to export XLSX/CSV.

### Phase 5 — Hybrid AI (5–10 Aug)
| Date | Step | Delivered |
|---|---|---|
| 5 Aug | 5.2 | Background job queue for AI work (extraction, merchant normalisation, categorisation); prefix cache. |
| 6 Aug | 5.3 | Anchor checks — every AI field is checked against the source text; review queue. |
| 10 Aug | 5.4 | Resumable historical SMS scan (paged, checkpointed, cancellable); shape gates for references/VPAs/merchants. |
| 10 Aug | 5.5 | Opportunistic batch runner while the app is open; Privacy screen (revoke SMS consent). |

Seed data: ~200 Indian merchants with aliases; category rules.

## Part 2 — Insights (September 2026)

| Date | Phase | Delivered |
|---|---|---|
| 29 Sep | 6.1 | Pure aggregation layer: spend/income/refund rules, **transfer pairing** (your own account-to-account moves aren't spending), indexes. |
| 30 Sep | 6.2 | Insights screen: summary tiles, category donut, 6-month trend, drill-down. |
| 30 Sep | 6.3 | Recurring payment detection (subscriptions, SIPs, EMIs) with mandate matching. |
| 30 Sep | 6.4 | Anomalies: category spikes, large payments, new payees, duplicate charges. |
| 30 Sep | 6.5 | Balance history, month-end forecast, biggest category increases. |

Merged to `main` as **PR #1** (12 Oct).

## Part 3 — The Paisa-inspired roadmap (12 October 2026)

### Decisions made at the start
- **Roadmap:** after reviewing the open-source Paisa project, the user approved
  Phases 7–10 (adapted to Arth's automatic, mobile, India-first model; Paisa's
  AGPL code was used for ideas only, never copied).
- **Network policy:** a single exception to "no network" — an *opt-in*
  download of **whole public price lists** (never per-fund lookups, which
  would reveal holdings), disclosed in the README, Privacy settings and the
  opt-in dialog.

### Phase 6.6 — Category editing
Tap any drill-down row to change its category, optionally for every row from
that merchant; merchant rules also apply to future imports. Also fixed two
pre-existing test failures and a missing lockfile entry.

### Phase 7 — Budgets, year view, search
| Commit | Delivered |
|---|---|
| 7.1 `d9cc5be` | Budgets: per-category limits, 80% warning, rollover, pace hint, suggested limits (schema v8). |
| 7.2 `60cc22b` | Financial-year view: income statement, "where the income went", daily-spend heatmap, month table; chart palette validated for light/dark (old palette failed a contrast check). |
| 7.3 `2f61dcf` | Search syntax + bulk re-categorise. |

### Phase 8 — Getting everything in, and keeping it honest
| Commit | Delivered |
|---|---|
| 8.0 `37ace5f` | **Saved statement passwords** (secure storage, tried automatically) and **multi-file import** — at the user's request: "enter the password once". |
| 8.1 `63fd26a` | Credit cards: card number and bill facts read from statements; bill / due / utilisation; card balances removed from the balance chart (schema v9). |
| 8.2 `a20e72f` | Manual (cash) transactions. |
| 8.3 `cb7e21b` | Savings goals with required monthly saving and pace (schema v10). |
| 8.4 `837cad2` | Data check-up (missing statements, gaps, duplicates, cash double-counting…). |

### Phase 9 — Investments and net worth
| Commit | Delivered |
|---|---|
| 9.1 `ff87fb8` | CAS import (CAMS/KFintech detailed; NSDL/CDSL holdings) with synthetic fixtures and a PDF generator (schema v11). |
| 9.3 `383e149` | Returns: FIFO cost, booked gains, dividends, XIRR. Fixed while checking the screen: NSDL fund rows double-counting CAMS folios; opening balances inflating XIRR. |
| 9.2 `4c9e4b7` | Net worth with manual assets, FD growth, loans, 12-month history (schema v12). |
| 9.4 `30af1d9` | Opt-in AMFI NAV download (whole public list; checked against the live file: 14,378 rows). |

### Phase 10 — Tax and planning
Rules were re-verified for FY 2026-27 before building (Budget 2026: no
capital-gains changes; Schedule AL threshold ₹1 crore from AY 2025-26).

| Commit | Delivered |
|---|---|
| 10.1 `33bfc3d` | Capital gains by FY with a dated rules table, set-off, exemption, grandfathering, editable fund categories (schema v13). Fixed: purchase reversals consumed the wrong lot. |
| 10.2 `cb10a21` | Tax harvesting (exempt gains, losses; ELSS lock-in). |
| 10.3 `90c442b` | Loans: amortisation, prepayments, FY interest split, EMIs seen in bank data (schema v14). Fixed: one-paisa extra EMI from rounding. |
| 10.4 `25d16a4` | Asset allocation targets, drift, rebalance amounts (schema v15). |
| 10.5 `abb5166` | Retirement plan (schema v16). |
| 10.6 `9d04ae9` | Schedule AL draft. |

Phases 6.6–10 merged to `main` as **PR #2** (19 commits).

## Part 4 — Security, reminders and tools (12–13 October 2026)

CI was deliberately **not** added — the user's GitHub Actions quota was
nearly used up; all verification ran locally.

| Commit | Delivered |
|---|---|
| 11.1 `7d2cce9` | App lock (biometrics / PIN, re-lock timeout) and hide-in-recents (FLAG_SECURE). |
| fix `8e8083c` | Lock setting read before the first frame (no flash of content). |
| 11.2 `eaa64ed` | Encrypted backup & restore (AES-256-GCM, PBKDF2 600k). |
| 11.3 `0f3d7be` | Upcoming-payments calendar. |
| 11.4 `908db19` | On-device reminders and budget alerts. |
| 11.5 `e7d7555` | Sheets calculator notepad (schema v17). |

Merged as **PR #3**; first release APK exported.

## Part 5 — Release hardening (13 October 2026)

The user installed the release APK: app lock worked, but SMS and statement
import were broken and the model download page was missing. No phone was
connected, so an **Android 35 emulator** was set up to run the exact release
APK (ARM translation), with SMS injected and statement files pushed to the
device. Findings:

| Symptom | Root cause | Fix |
|---|---|---|
| SMS scan: "database is locked" | Several screens opened their own database connections; one ran migrations while another read. | One shared connection (`ArthDatabase.shared()`) + busy timeout. |
| Every PDF import failed silently | The PDF engine looked for `$HOME`, which Android doesn't set; the error was swallowed. | App temp folder passed on mobile; import errors now reported. |
| Model download page missing | It lived on a debug-only screen. | New *On-device AI model* screen. |
| Model download failed (found on emulator) | Release manifest lacked the INTERNET permission (Flutter adds it only to debug builds). | Permission declared. |
| Model never integrity-checked | Placeholder checksum. | SHA-256 pinned; verified once off the UI thread. |
| Resume could corrupt the model | A full response was appended to a partial file. | Restart instead of append. |
| Lock didn't cover open screens | Gate wrapped only the home route. | Gate wraps the whole navigator. |

Verified on the emulator: SMS scan imported a transaction; CSV review screen;
two PDFs (incl. a locked CAS, password prompted once) imported 13
transactions; full 769 MB model download verified. Merged as **PR #4**; fixed
APK exported.

## Part 6 — Ask (20 October 2026)

| Commit | Delivered |
|---|---|
| 12.1 `e4251a7` | Rule-based question parser and deterministic answers (spend, income, savings, rankings, largest, last paid, averages, net worth, budgets, upcoming) using the Insights rules. |
| 12.2 `f0ab5e8` | On-device model fallback with a grammar and validation. |
| 12.3 `5a32fb4` | Ask screen: example questions, answer cards showing how the question was read, link to the transactions. |
| fix `3a8e6c8` | Model load parameters were passed by pointer instead of by value (random context size, sometimes a crash). |
| 12.2 `96d7694` | Model narrowed to classifying the question after measuring it on the real model. |

Measured with the real Gemma 3 1B on desktop (~2.5 s per question): asking
the model for every field read 2 of 24 unusual questions correctly. After
splitting the work (parser: dates, merchants, categories; model: question
type only), 12 of 20 **held-out** questions were read correctly (parser 5 / 5,
model 7 / 15). Misreadings are shown on the answer card.

---

## Bugs found and fixed during the session

| Area | Bug | Found by |
|---|---|---|
| Tests on `main` | Insights card off-screen in test viewport; anomaly fixture names normalised to nothing | Running the suite |
| Charts | Category palette failed the chroma/contrast check | Palette validator |
| Statements | `flipDirection` dropped the account hint | Code review while adding card numbers |
| CAS | NSDL fund rows double-counted CAMS folios | Rendering the Investments screen |
| CAS / XIRR | Opening units ignored → XIRR +177% | Rendering the Investments screen |
| Portfolio / tax | Purchase reversals consumed the oldest lot | Capital-gains tests |
| Loans | Rounding left a one-paisa extra EMI | Loan tests |
| Sheets | Comma-grouped numbers vs argument commas; comments resetting `sum`; result rows misaligned | Evaluator tests, rendered screenshot |
| App lock | Blank first frame; lock not covering pushed screens | Shell test; review |
| Process | A test failure slipped into one commit via a piped `tail` | Noticed immediately; all later commits gated on the test exit code |
| Release build | DB locking, PDF `$HOME`, missing INTERNET, debug-only model screen | Release APK on an emulator |
| LLM shim | Load params passed by pointer to a by-value C struct (random `n_ctx`, occasional out-of-memory crash) | Loading the real model on desktop for the Ask evaluation |

## How the work was verified

- **Pure logic first:** every calculation module is plain Dart with unit
  tests against hand-checkable values (e.g. textbook EMI and balance figures,
  closed-form XIRR, PBKDF2/GCM round trips, real AMFI file parse).
- **Fixtures:** golden SMS and statement files; synthetic CAS text and PDFs
  (one locked with a PAN-style password) generated by a script in the repo.
- **Widget tests** for each screen flow; **rendered screenshots** (light and
  dark) to check layouts and charts.
- **Release APK on an emulator** for platform behaviour tests can't reach.
- **Every commit gated** on `flutter test` passing and no new analyzer issues.

## Schema history

| Version | Added |
|---|---|
| ≤ v7 | Core ledger, imports/provenance, SMS & statement queues, AI jobs/review, insight indexes |
| v8 | Budgets |
| v9 | Account kind, statement summaries, credit cards |
| v10 | Goals, goal contributions |
| v11 | Securities, investment accounts, investment transactions, holding snapshots, prices |
| v12 | Manual assets and value history |
| v13 | Per-fund tax category |
| v14 | Loans, prepayments |
| v15 | Allocation targets |
| v16 | Retirement plan |
| v17 | Sheets |

All upgrades are automatic migrations; backups from older versions restore
into the current schema.

## Pull requests

| PR | Scope | Merged |
|---|---|---|
| #1 | Phases 4–6.5 (foundations → insights) | 12 Oct 2026 |
| #2 | Phases 6.6 → 10.6 (budgets → Schedule AL) | 12 Oct 2026 |
| #3 | Phase 11 (lock, backup, calendar, reminders, sheets) | 13 Oct 2026 |
| #4 | Release-build fixes | 13 Oct 2026 |

## Open items

- Field-test with real SMS / statements / CAS; add failing samples as fixtures.
- Release signing key (current APK uses the development key).
- Ask: check the model fallback on a phone (desktop measured ~2.5 s per question); grow the held-out question set.
- Background processing when the app is closed.
- CI when GitHub Actions quota allows.

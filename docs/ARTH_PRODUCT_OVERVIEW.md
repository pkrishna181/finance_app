---
title: "Arth — Product Overview"
subtitle: "Privacy-first personal finance for India"
date: "13 October 2026 · as of commit a2f3727 (main)"
---

# Arth — Product Overview

*As of 13 October 2026 (`main` at `a2f3727`, app version 0.1.0, database schema v17).*

## 1. What Arth is

Arth is an Android app (Flutter; an iOS build is possible but not yet set up) that builds a complete picture of
a person's money in India — spending, cards, loans, investments, net worth and
taxes — **without any of that data leaving the phone**. It reads bank SMS and
statement files on the device, understands them with built-in rules and, for the
few it can't, a small AI model that also runs on the device.

### Who it is for

People in India who keep money across several banks, cards and mutual funds and
want one honest view of it — including those who are uncomfortable handing
bank SMS, statements or investment details to a cloud service.

### Product principles

| Principle | What it means in practice |
|---|---|
| **Data stays on the phone** | No cloud parsing, no analytics SDKs, no crash reporting with user data. The ledger lives in an encrypted database on the device. |
| **Network only where unavoidable, and disclosed** | Exactly two optional downloads: the AI model (once) and public mutual-fund prices (opt-in). Both send nothing about the user. |
| **Suggest, never decide** | Anything the AI reads is a suggestion the user confirms. Tax figures are labelled estimates. |
| **Indian-first** | ₹ with lakh/crore grouping, Indian banks' SMS and statements, CAS from CAMS/KFintech/NSDL/CDSL, financial years April–March, current Indian tax rules. |
| **Honest numbers** | Transfers between your own accounts don't count as spending; refunds reduce their category; estimates and stale data are flagged. |

## 2. How data gets in

### 2.1 Bank SMS (Android)

- With explicit in-app consent and the READ_SMS permission, Arth scans the SMS
  inbox for messages from known bank senders, newest first, resumably.
- A cascade of bank-specific templates reads amount, direction, account,
  merchant/VPA, references and balance. Templates for **SBI** (UPI, SBI Card,
  account alerts, NEFT, internet banking, ATM), **IDFC FIRST**, **IndusInd**
  cards, **Axis** cards and **Paytm** are written from a real inbox; **HDFC,
  ICICI, Kotak** and generic UPI/IMPS/NEFT patterns cover the rest.
- Messages that aren't transactions are skipped for a stated reason: OTPs,
  declines, bill reminders, collect requests, offers, notices. Card spends in
  a foreign currency are skipped too — the rupee amount only appears on the
  statement.
- Messages the templates can't read are kept (encrypted) for the AI model to
  suggest a reading; nothing is added to the ledger without the user's review.
- Future-dated mandate / e-NACH notices are recorded and used to predict
  upcoming debits.

### 2.2 Bank and credit-card statements (CSV, Excel, PDF)

- Pick **one or many files** at once. A single file opens a review screen;
  several are imported in one batch with a per-file result.
- Layout detection by bank profile with a generic fallback: **HDFC, ICICI,
  SBI, Axis, Kotak** savings accounts and **HDFC, ICICI, Axis** credit cards,
  plus unknown layouts via header matching. PDFs whose table can't be mapped
  that way (headers drawn as graphics, centred headers, wrapped rows — e.g.
  SBI savings and SBI Card) are read line by line from word positions, with
  the running balance or C/D markers deciding debit vs credit.
- Before importing, a statement opens as a **summary** (see §3.8).
- PDFs are read from their text layer (PDFium); scanned image-only PDFs are
  declined with a clear message. Legacy binary `.xls` must be exported as XLSX/CSV.
- **Password-protected PDFs:** enter an issuer's password once and tick
  "Remember". Arth tries saved passwords automatically on future statements
  (matching the file name first), so each bank/card/CAS password is typed once.
- From the statement text Arth also reads the **card/account last 4 digits**
  and, for cards, the **statement date, due date, total and minimum due, and
  credit limit**.
- Overlapping statements and SMS for the same transaction are de-duplicated:
  strong references like UPI/IMPS/UTR match across sources, and card
  statement rows link to the SMS for the same purchase (same amount and card,
  within a day — one to one, so two identical purchases stay two).

### 2.3 Investment statements (CAS)

- **CAMS / KFintech detailed CAS:** every folio and fund with full transaction
  history (SIPs, purchases, redemptions, switches incl. STP, IDCW payout /
  reinvest, stamp duty / STT), opening and closing units, NAV, cost and market value.
- **NSDL / CDSL CAS:** demat equity holdings and mutual-fund folios as a
  holdings snapshot (quantity × price must equal value, to avoid misreads).
- The same fund reported by both a CAMS and an NSDL statement is counted once.
- CAS PDFs are usually locked with your PAN — the saved-password flow handles them.

### 2.4 Manual entries

Cash spending and anything not covered by SMS/statements; other assets (gold,
FD with automatic interest, PPF, EPF, NPS, property, vehicle, cash) and
liabilities; loans with full EMI schedules.

## 3. Features

### 3.1 Insights (monthly)

- Income, spend, net and savings rate; category donut; 6-month trend.
- Top merchants; drill into the transactions behind any number and
  **re-categorise** a row or every row from that merchant (future imports follow).
- **Subscriptions & EMIs** detected from repeating payments, with next dates and price changes.
- **Unusual this month:** category spikes, unusually large payments, new
  payees, possible duplicate charges (dismissable).
- **Month-end outlook:** projected spend and balance; biggest category increases;
  60-day balance chart (card accounts excluded).
- **Search** with a simple syntax (`swiggy >500 in:2026-09 cat:none bank:hdfc
  type:atm debit`) and **bulk re-categorise** of selected results.

### 3.2 Year in review (Indian financial year)

Income by source, spending by category, savings rate, a "where the income
went" bar, a daily-spending heatmap, a full income statement and a
month-by-month table.

### 3.3 Planning and control

| Feature | What it does |
|---|---|
| **Budgets** | Monthly limit per category, 80% warning, optional envelope rollover, "spending fast" pace hint, suggested limits from history. |
| **Credit cards** | Bill (printed or estimated), due date, overdue state, payments, unbilled spend, utilisation vs limit; cards found in statements are offered for tracking. |
| **Savings goals** | Target and date; progress from money you log, a bank balance, or what goes into a category (e.g. SIPs); required monthly saving, recent pace, projected completion. |
| **Upcoming payments** | 60-day calendar of card bills, loan EMIs, SIPs, subscriptions and mandates (exact vs predicted). |
| **Reminders** | On-device notifications: card bills 3 days before and on the due date; EMIs / SIPs / renewals the day before; budget alerts at 80% and when exceeded. Off until enabled; amounts hidden on a locked screen. |
| **Data check-up** | Flags balances that don't add up (missing statements), months without data, stale accounts, high uncategorised share, possible duplicates, cash counted twice, unread messages, untracked cards — each with a way to fix it. |

### 3.4 Investments and net worth

- **Investments:** value, amount invested (FIFO cost or the statement's cost),
  unrealised and booked gains, dividends, and **XIRR** per holding and overall;
  split by mutual funds / shares; per-holding transaction history.
- **Net worth:** bank balances + investments + other assets − card dues −
  loans, with a 12-month month-end chart and "as of" dates.
- **Asset allocation:** equity / debt / gold / cash / real estate / other
  against your targets, with drift and add/trim amounts (presets included).
- **Retirement plan:** corpus needed (safe-withdrawal-rate or money lasting to
  a chosen age, inflation-adjusted), what today's investments grow to, and the
  monthly saving that closes the gap — using your real average spending.
- **Loans:** EMI schedule, outstanding, payoff date, interest/principal by
  financial year (24(b)/80C notes for home loans), prepayment calculator
  ("finish sooner" vs "lower EMI"), EMIs spotted in your bank data.

### 3.5 Tax (estimates, clearly labelled)

| Feature | Detail |
|---|---|
| **Capital gains by financial year** | FIFO matching with holding periods; equity STCG 20% / LTCG 12.5% above ₹1.25 lakh (with the older pre-23-Jul-2024 rates for older years); debt funds bought from 1 Apr 2023 at slab rate; other funds long-term after 24 months at 12.5%; grandfathering for pre-2018 equity; loss set-off and carry-forward. Fund categories guessed from names and editable. |
| **Tax harvesting** | How much long-term equity gain can still be booked tax-free this year (FIFO, ELSS lock-in respected), and losses that would cut this year's tax. |
| **Schedule AL** | Draft of the ITR assets & liabilities schedule as on 31 March (needed above ₹1 crore income), mostly at cost, with values that need checking flagged. |

Rules were checked against Budget 2026 coverage in October 2026; all dates and
rates live in one rules table so future changes are a single edit. Not covered:
cess/surcharge, losses brought forward from earlier years, indexation for
pre-July-2024 sales, exit loads.

### 3.6 Tools

- **Sheets:** a calculator notepad — variables, Indian units (`60L`, `1.5cr`,
  `25k`), `20% of x`, `sum`/`total`, `emi()`, `sip()`, `fv()`, `pv()`, and your
  own numbers (`networth`, `cash`, `spend("groceries")`, `income(1)`,
  `avg_spend("food delivery", 6)`).

### 3.7 Ask

Questions in plain English — "how much did I spend on food last month?",
"top merchants this financial year", "when did I last pay rent?", "what's due
in the next 2 weeks?", net worth, budgets, savings, monthly averages. Every
number is calculated by the app with the same rules as Insights; the
on-device AI is only used to work out what an unusually worded question is
asking, and the answer card shows how it was read. Each answer links to the
matching transactions.

### 3.8 Statement summaries

Pick a bank or card statement and Arth shows what's in it before importing:

- **Whether it adds up:** the rows are checked against every total the
  statement prints — total debits and credits and their counts, opening and
  closing balance; for cards, payments, purchases, fees and the outstanding.
  If something doesn't match, the summary says which figure and by how much.
- A short **overview** in plain sentences, money in and out, **fees,
  interest and taxes** charged, interest earned, where money went and came
  from, the largest payments, EMI instalments billed, and for cards the bill:
  total and minimum due, due date, limit and available credit.
- Every imported statement stays listed under **Import → Your statements**
  with the same summary.

## 4. Privacy and security

| Area | How it is handled |
|---|---|
| **Storage** | SQLite encrypted with SQLite3MultipleCiphers; the key is generated on the phone and kept in Android Keystore (iOS Keychain). |
| **Saved statement passwords** | Platform secure storage only — never in the database, logs or UI after saving; manage or forget them in Privacy. |
| **App lock** | Fingerprint / face / phone PIN at launch and after a chosen time away; covers every screen. Optional "Hide in recent apps" (blank app-switcher preview, screenshots blocked). |
| **Backups** | One file sealed with the user's passphrase (AES-256-GCM, PBKDF2-HMAC-SHA256 600,000 iterations). Written where the user chooses; never uploaded; no recovery without the passphrase. Saved passwords included only if ticked. |
| **Network** | Only (1) the AI model download from huggingface.co, verified against a pinned SHA-256, and (2) the opt-in AMFI all-schemes NAV file — the whole public list is fetched and matched on the phone, so nothing reveals what you own. No analytics, no telemetry. |
| **Notifications** | Scheduled on the phone; content hidden on a secure lock screen. |
| **AI model** | Gemma 3 1B (Q4_K_M, ~769 MB) via llama.cpp, running fully on the device; outputs are validated against the source text and require user confirmation. |
| **SMS** | Read only after in-app consent and Android permission; bodies never logged; consent can be revoked. |

## 5. How it is built

| Layer | Technology |
|---|---|
| App | Flutter (Dart), Material 3; Android `minSdk` per Flutter, arm64 build |
| Database | drift + SQLite3MultipleCiphers (encrypted), schema v17, 31 tables, one shared connection |
| SMS | In-house Kotlin `MethodChannel` over Android's SMS content provider |
| Statements | `csv`, `excel_community`, PDFium via `pdfrx_engine` (text layer + layout reconstruction) |
| On-device AI | llama.cpp (pinned) through a small C shim (`arth_llm`) and `dart:ffi`; GBNF-constrained JSON; anchor checks |
| Charts | `fl_chart`, with a validated colour palette for light and dark themes |
| Security | `flutter_secure_storage`, `local_auth`, `pointycastle` (AES-GCM, PBKDF2) |
| Reminders | `flutter_local_notifications`, `timezone` |
| Code size | ~35,900 lines of app Dart in 186 files; ~10,800 lines of tests in 75 files; 522 automated tests |

Design approach: pure, deterministic calculation modules (aggregation,
budgets, recurring detection, anomalies, cash-flow, portfolio/XIRR, capital
gains, loans, retirement, sheets) with thin database repositories and
Flutter screens on top — so the maths is unit-tested without a phone.

## 6. Known limitations

- **Real-world parser coverage:** SMS parsing was measured on one real
  inbox (SBI, IDFC FIRST, Axis, IndusInd, Paytm: only a few dozen messages
  left unread, nearly all notices; foreign-currency card spends skipped) and
  PDF parsing on one SBI savings statement and one SBI Card bill
  (every printed total matched). Other banks rely on templates and profiles
  not yet checked against real data; CAS parsing is tested on synthetic
  statements modelled on real layouts.
- **Ask** understands common phrasings instantly; unusual wording goes to the
  1B on-device model, which read about half of new test questions correctly
  (the answer card always shows how a question was read). No iOS
  build setup; no background processing when the app is closed (AI work runs
  while the app is open).
- **Share prices** are not downloaded; they update when a newer demat CAS is imported.
- **Release signing** uses the development key — fine for personal installs,
  needs a proper key before distribution.
- **Tax** figures are estimates with the exclusions listed in §3.5.
- **1B AI model** quality is modest; anchor checks catch fabrications, but
  suggestions still need review (by design).

## 7. What's next (suggested)

1. Measure other banks' SMS and statements with the real-data harnesses (and real CAS files); add anonymised fixtures for what fails.
2. Release signing and a Play-ready build; optional iOS setup.
3. Background processing (WorkManager) for AI and reminders when the app is closed.
4. More bank / card / broker statement profiles; share prices from a bulk public source if one fits the privacy policy.

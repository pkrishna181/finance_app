import 'package:drift/drift.dart';

/// System + user categories (Groceries, UPI transfers, etc.).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get slug => text().unique()();
  TextColumn get name => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Canonical merchant identities (user-correctable).
class Merchants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get canonicalName => text()();
  IntColumn get defaultCategoryId =>
      integer().nullable().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Raw merchant string → canonical merchant mapping (local training signal).
class MerchantAliases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawName => text()();
  IntColumn get merchantId => integer().references(Merchants, #id)();

  /// Origin of the mapping: system | llm | user.
  TextColumn get source => text()();

  /// LLM confidence 0–1 when [source] is llm.
  RealColumn get confidence => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {rawName},
      ];
}

/// An ingestion batch (one statement file, one SMS sync window, etc.).
class Imports extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// sms | pdf | csv | excel
  TextColumn get sourceType => text()();
  TextColumn get sourceLabel => text()();

  /// Content hash of the imported payload (for skipping identical re-imports).
  TextColumn get contentHash => text()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();

  /// pending | succeeded | failed | partial | duplicate_file
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get rowCount => integer().withDefault(const Constant(0))();
  IntColumn get parsedCount => integer().withDefault(const Constant(0))();
  IntColumn get skippedCount => integer().withDefault(const Constant(0))();
  IntColumn get duplicateCount => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}

/// Ledger rows. Amounts in paise; INR only for v1.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Always positive; direction separates debit/credit.
  IntColumn get amountPaise => integer()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();

  /// debit | credit
  TextColumn get direction => text()();

  /// See [TransactionType] wire names.
  TextColumn get txnType => text()();

  DateTimeColumn get bookedAt => dateTime()();
  DateTimeColumn get valueDate => dateTime().nullable()();

  TextColumn get bankCode => text()();
  TextColumn get accountHint => text().nullable()();

  IntColumn get merchantId =>
      integer().nullable().references(Merchants, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// LLM/rule suggestion before user confirms (slug from [Categories]).
  TextColumn get suggestedCategorySlug => text().nullable()();

  /// rule | llm | user — how [categoryId] was assigned.
  TextColumn get categorySource => text().nullable()();

  TextColumn get rawMerchant => text()();
  TextColumn get rawDescription => text()();

  TextColumn get upiPayerVpa => text().nullable()();
  TextColumn get upiPayeeVpa => text().nullable()();
  TextColumn get upiRef => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get externalRef => text().nullable()();

  IntColumn get balanceAfterPaise => integer().nullable()();

  /// sha256(bank|date|amount|ref) — unique for idempotent imports.
  TextColumn get dedupeHash => text().unique()();

  IntColumn get importId =>
      integer().nullable().references(Imports, #id)();

  BoolColumn get isRecurringCandidate =>
      boolean().withDefault(const Constant(false))();

  /// subscription | sip | enach | other | null
  TextColumn get recurringKind => text().nullable()();

  /// bank | card | null (unknown) — which kind of account the row is from.
  TextColumn get accountKind => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Many-to-many: a transaction may be supplied by SMS and/or statement imports.
class TransactionImports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get importId => integer().references(Imports, #id)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {transactionId, importId},
      ];
}

/// User corrections (category / merchant) stored as on-device training signal.
class UserCorrections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  TextColumn get rawMerchant => text()();
  TextColumn get field => text()(); // category | merchant
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Unparsed transactional SMS preserved for on-device LLM fallback (Phase 5).
/// Bodies are never written to logs — only this encrypted table.
class UnparsedSmsRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawBody => text()();
  TextColumn get sender => text().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  TextColumn get bankCode => text().nullable()();
  TextColumn get reason => text()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Future-tense mandate / e-NACH notices (recurring detection input).
class MandateNotices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bankCode => text()();
  IntColumn get amountPaise => integer().nullable()();
  TextColumn get merchant => text().nullable()();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  TextColumn get accountHint => text().nullable()();
  TextColumn get rawBody => text()();
  TextColumn get sender => text().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// On-device model provenance (Phase 4).
class ModelInfo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get modelName => text()();
  TextColumn get quant => text()();
  TextColumn get sha256 => text()();
  TextColumn get sourceUrl => text()();
  TextColumn get localPath => text().nullable()();
  DateTimeColumn get downloadedAt => dateTime().nullable()();
  DateTimeColumn get lastLoadedAt => dateTime().nullable()();
}

/// Unparseable statement rows kept for Phase-5 LLM fallback.
class UnparsedStatementRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importId => integer().references(Imports, #id)();
  IntColumn get rowIndex => integer()();
  TextColumn get rawRowJson => text()();
  TextColumn get reason => text()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Background LLM work queue (Phase 5).
class LlmJobs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// sms_extract | stmt_row_extract | merchant_normalize | categorize
  TextColumn get jobType => text()();

  /// JSON payload (row ids, raw strings, txn id, etc.).
  TextColumn get payloadJson => text()();

  /// pending | running | done | failed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get resultJson => text().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// LLM-suggested transactions awaiting user review.
class LlmReviewItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get unparsedSmsId =>
      integer().nullable().references(UnparsedSmsRows, #id)();
  IntColumn get unparsedStatementRowId =>
      integer().nullable().references(UnparsedStatementRows, #id)();
  TextColumn get rawText => text()();
  TextColumn get suggestedJson => text()();
  TextColumn get anchorReportJson => text()();

  /// pending | confirmed | discarded | unresolvable_v1
  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Local model-quality ledger — disagreements between LLM output and anchor resolution.
class LlmDisagreements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jobId => integer().nullable().references(LlmJobs, #id)();

  /// direction | merchant_demoted | vpa_dropped | ref_dropped | amount_rejected | date_rejected
  TextColumn get field => text()();
  TextColumn get llmValue => text()();
  TextColumn get resolvedValue => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Monthly spending limit per category (Phase 7.1).
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().unique().references(Categories, #id)();
  IntColumn get limitPaise => integer()();

  /// Envelope mode: unspent / overspent amounts carry into the next month.
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();

  /// First month (yyyy-MM) the budget applies to.
  TextColumn get startMonth => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Facts printed on an imported statement (Phase 8.1): card/account number
/// and, for cards, the bill.
@DataClassName('StatementSummaryRow')
class StatementSummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importId => integer().unique().references(Imports, #id)();
  TextColumn get bankCode => text()();

  /// bank | card
  TextColumn get accountKind => text()();
  TextColumn get last4 => text().nullable()();
  DateTimeColumn get statementDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get totalDuePaise => integer().nullable()();
  IntColumn get minDuePaise => integer().nullable()();
  IntColumn get creditLimitPaise => integer().nullable()();

  /// Latest transaction date on the statement (fallback statement date).
  DateTimeColumn get periodEnd => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Credit cards the user tracks (Phase 8.1).
class CreditCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bankCode => text()();

  /// Last four digits; null matches the bank's card rows without a number.
  TextColumn get last4 => text().nullable()();
  TextColumn get name => text()();
  IntColumn get creditLimitPaise => integer().nullable()();

  /// Day of month the statement is generated (1–31).
  IntColumn get statementDay => integer().nullable()();

  /// Day of month payment is due (1–31).
  IntColumn get dueDay => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {bankCode, last4},
      ];
}

/// Savings goals (Phase 8.3).
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get targetPaise => integer()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get startPaise => integer().withDefault(const Constant(0))();

  /// Expected yearly return in basis points (700 = 7%).
  IntColumn get annualReturnBp => integer().withDefault(const Constant(0))();

  /// manual | account | category
  TextColumn get source => text().withDefault(const Constant('manual'))();

  /// account: `BANK|last4`; category: slug.
  TextColumn get sourceRef => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Money the user logs toward a manual goal.
class GoalContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id)();
  IntColumn get amountPaise => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A fund, share or other security (Phase 9).
class Securities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get isin => text().unique()();
  TextColumn get name => text()();

  /// mf | equity | other
  TextColumn get kind => text()();
  TextColumn get amc => text().nullable()();

  /// User override of the tax category: equity | debt | other (Phase 10.1).
  TextColumn get taxCategory => text().nullable()();
}

/// A mutual-fund folio or demat account (Phase 9).
class InvestmentAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// folio | demat
  TextColumn get kind => text()();

  /// Folio number or `DP ID/Client ID` / BO ID.
  TextColumn get number => text()();

  /// CAMS | KFINTECH | NSDL | CDSL | UNKNOWN
  TextColumn get provider => text()();
  TextColumn get amc => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {kind, number},
      ];
}

/// Mutual-fund transactions from detailed CAS (Phase 9). Units / NAV are
/// scaled by 10⁴; amounts are signed paise (redemptions negative).
class InvestmentTxns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(InvestmentAccounts, #id)();
  IntColumn get securityId => integer().references(Securities, #id)();
  DateTimeColumn get date => dateTime()();

  /// See `CasTxnType` names.
  TextColumn get type => text()();
  TextColumn get description => text()();
  IntColumn get amountPaise => integer().nullable()();
  IntColumn get unitsE4 => integer().nullable()();
  IntColumn get navE4 => integer().nullable()();
  IntColumn get balanceE4 => integer().nullable()();
  IntColumn get importId => integer().nullable().references(Imports, #id)();
  TextColumn get dedupeHash => text().unique()();
}

/// Units held on a date (closing balance from CAS) (Phase 9).
class HoldingSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(InvestmentAccounts, #id)();
  IntColumn get securityId => integer().references(Securities, #id)();
  DateTimeColumn get asOf => dateTime()();
  IntColumn get unitsE4 => integer()();
  IntColumn get priceE4 => integer()();
  IntColumn get valuePaise => integer()();
  IntColumn get costPaise => integer().nullable()();
  IntColumn get importId => integer().nullable().references(Imports, #id)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {accountId, securityId, asOf},
      ];
}

/// Price / NAV of a security on a date (Phase 9).
class SecurityPrices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get securityId => integer().references(Securities, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get priceE4 => integer()();

  /// cas | amfi
  TextColumn get source => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {securityId, date},
      ];
}

/// Assets and liabilities the user enters by hand (Phase 9.2).
class ManualAssets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// gold | fd | ppf | epf | nps | property | vehicle | cash | other |
  /// loan (liability)
  TextColumn get kind => text()();

  /// FD only: yearly interest in basis points, compounded quarterly from
  /// [startDate] on the latest recorded value.
  IntColumn get interestBp => integer().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get maturityDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Value of a manual asset / liability from a date on (Phase 9.2).
class ManualAssetValues extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId => integer().references(ManualAssets, #id)();
  DateTimeColumn get date => dateTime()();

  /// Always positive; liabilities are subtracted by kind.
  IntColumn get valuePaise => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {assetId, date},
      ];
}

/// Loans with an amortising EMI (Phase 10.3).
class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// home | car | personal | education | gold | other
  TextColumn get kind => text()();
  TextColumn get lender => text().nullable()();
  IntColumn get principalPaise => integer()();

  /// Yearly interest in basis points (850 = 8.5%).
  IntColumn get rateBp => integer()();
  IntColumn get tenureMonths => integer()();

  /// Month of the first EMI.
  DateTimeColumn get firstEmiDate => dateTime()();

  /// As charged by the lender; computed from the terms when null.
  IntColumn get emiPaise => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Extra payments toward a loan (Phase 10.3).
class LoanPrepayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get loanId => integer().references(Loans, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountPaise => integer()();

  /// tenure (keep EMI, finish sooner) | emi (keep end date, lower EMI)
  TextColumn get mode => text().withDefault(const Constant('tenure'))();
}

/// Target share per asset class (Phase 10.4).
class AllocationTargets extends Table {
  /// equity | debt | gold | cash | realEstate | other
  TextColumn get bucket => text()();

  /// Basis points of the planned portfolio (6000 = 60%).
  IntColumn get targetBp => integer()();

  @override
  Set<Column<Object>> get primaryKey => {bucket};
}

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

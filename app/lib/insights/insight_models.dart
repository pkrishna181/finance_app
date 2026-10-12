/// Plain value types for the insights layer (no Flutter / Drift dependency).
library;

/// Calendar month bucket (local time of [Transactions.bookedAt]).
class MonthKey implements Comparable<MonthKey> {
  const MonthKey(this.year, this.month);

  factory MonthKey.of(DateTime d) => MonthKey(d.year, d.month);

  final int year;
  final int month;

  DateTime get start => DateTime(year, month);
  DateTime get endExclusive => DateTime(year, month + 1);

  MonthKey plusMonths(int n) {
    final idx = year * 12 + (month - 1) + n;
    return MonthKey(idx ~/ 12, idx % 12 + 1);
  }

  @override
  int compareTo(MonthKey other) =>
      (year * 12 + month).compareTo(other.year * 12 + other.month);

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}

/// Slim projection of a ledger row — only what aggregation needs.
class InsightTxn {
  const InsightTxn({
    required this.id,
    required this.amountPaise,
    required this.isDebit,
    required this.bookedAt,
    required this.bankCode,
    this.accountHint,
    this.txnType = 'other',
    this.categorySlug,
    this.categorySource,
    this.merchantId,
    this.merchantName,
    this.rawMerchant = '',
    this.balanceAfterPaise,
  });

  final int id;

  /// Always positive.
  final int amountPaise;
  final bool isDebit;
  final DateTime bookedAt;
  final String bankCode;
  final String? accountHint;
  final String txnType;

  /// Null when uncategorized in the DB.
  final String? categorySlug;

  /// rule | llm | user
  final String? categorySource;
  final int? merchantId;
  final String? merchantName;
  final String rawMerchant;

  /// Account balance after this transaction, when the source provides it.
  final int? balanceAfterPaise;

  String get accountKey => '$bankCode|${accountHint ?? ''}';

  bool get isUncategorized =>
      categorySlug == null || categorySlug == kUncategorizedSlug;

  /// Display name: canonical merchant, else raw text.
  String get merchantLabel {
    final m = merchantName?.trim();
    if (m != null && m.isNotEmpty) return m;
    final r = rawMerchant.trim();
    return r.isEmpty ? 'Unknown' : r;
  }
}

const kUncategorizedSlug = 'uncategorized';
const kSelfTransferSlug = 'transfers_self';

/// Credits in these categories count as income; other categorized credits are
/// treated as refunds that net against that category's spend.
const kIncomeSlugs = <String>{'salary', 'interest'};

class MonthSummary {
  const MonthSummary({
    required this.month,
    required this.incomePaise,
    required this.spendPaise,
    required this.byCategory,
    required this.uncategorizedCount,
    required this.uncategorizedPaise,
    required this.txnCount,
    required this.excludedTransferCount,
  });

  final MonthKey month;
  final int incomePaise;

  /// Net of refunds.
  final int spendPaise;

  /// Net spend per category slug (uncategorized under [kUncategorizedSlug]).
  /// Categories whose refunds exceed spend are floored at 0 here; the excess
  /// is already reflected in [spendPaise].
  final Map<String, int> byCategory;
  final int uncategorizedCount;
  final int uncategorizedPaise;

  /// Transactions counted (excludes transfers).
  final int txnCount;
  final int excludedTransferCount;

  int get netPaise => incomePaise - spendPaise;

  /// Null when there is no income to compare against.
  double? get savingsRate =>
      incomePaise <= 0 ? null : netPaise / incomePaise;
}

class MerchantTotal {
  const MerchantTotal({
    required this.label,
    required this.merchantId,
    required this.spendPaise,
    required this.count,
  });

  final String label;
  final int? merchantId;
  final int spendPaise;
  final int count;
}

class MonthDelta {
  const MonthDelta({
    required this.current,
    required this.previous,
  });

  final int current;
  final int previous;

  int get diffPaise => current - previous;

  /// Null when [previous] is zero.
  double? get pct => previous == 0 ? null : (current - previous) / previous;
}

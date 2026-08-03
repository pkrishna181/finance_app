/// Indian payment / ledger transaction kinds supported in v1.
enum TransactionType {
  upi,
  imps,
  neft,
  rtgs,
  atm,
  pos,
  card,
  mandate,
  enach,
  interest,
  charges,
  salary,
  transfer,
  other;

  String get wireName => name;

  static TransactionType fromWire(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.other,
    );
  }
}

/// Debit vs credit from the user's account perspective.
enum TransactionDirection {
  debit,
  credit;

  String get wireName => name;

  static TransactionDirection fromWire(String value) {
    return TransactionDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionDirection.debit,
    );
  }
}

/// How a recurring pattern was classified (Phase 2+).
enum RecurringKind {
  subscription,
  sip,
  enach,
  other;

  String get wireName => name;

  static RecurringKind? tryFromWire(String? value) {
    if (value == null) return null;
    for (final e in RecurringKind.values) {
      if (e.name == value) return e;
    }
    return null;
  }
}

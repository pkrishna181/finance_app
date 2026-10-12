import 'package:drift/drift.dart';

import '../core/db/database.dart';
import 'loans.dart';

class LoanRepository {
  LoanRepository(this._db);

  final ArthDatabase _db;

  Future<List<LoanDef>> list() async {
    final loans = await (_db.select(
      _db.loans,
    )..orderBy([(l) => OrderingTerm.asc(l.createdAt)])).get();
    final pre = await _db.select(_db.loanPrepayments).get();
    return [
      for (final l in loans)
        LoanDef(
          id: l.id,
          name: l.name,
          kind: l.kind,
          lender: l.lender,
          principalPaise: l.principalPaise,
          rateBp: l.rateBp,
          tenureMonths: l.tenureMonths,
          firstEmiDate: l.firstEmiDate,
          emiPaise: l.emiPaise,
          prepayments: [
            for (final p in pre)
              if (p.loanId == l.id)
                Prepayment(
                  p.date,
                  p.amountPaise,
                  mode: PrepayMode.values.byName(p.mode),
                ),
          ],
        ),
    ];
  }

  Future<int> save({
    int? id,
    required String name,
    required String kind,
    String? lender,
    required int principalPaise,
    required int rateBp,
    required int tenureMonths,
    required DateTime firstEmiDate,
    int? emiPaise,
  }) async {
    if (!kLoanKinds.containsKey(kind)) {
      throw ArgumentError.value(kind, 'kind', 'unknown');
    }
    if (principalPaise <= 0 || tenureMonths <= 0 || rateBp < 0) {
      throw ArgumentError('principal, tenure must be positive; rate ≥ 0');
    }
    final row = LoansCompanion(
      name: Value(name.trim()),
      kind: Value(kind),
      lender: Value(lender),
      principalPaise: Value(principalPaise),
      rateBp: Value(rateBp),
      tenureMonths: Value(tenureMonths),
      firstEmiDate: Value(firstEmiDate),
      emiPaise: Value(emiPaise),
    );
    if (id == null) return _db.into(_db.loans).insert(row);
    await (_db.update(_db.loans)..where((l) => l.id.equals(id))).write(row);
    return id;
  }

  Future<void> delete(int id) => _db.transaction(() async {
    await (_db.delete(
      _db.loanPrepayments,
    )..where((p) => p.loanId.equals(id))).go();
    await (_db.delete(_db.loans)..where((l) => l.id.equals(id))).go();
  });

  Future<void> addPrepayment(
    int loanId,
    DateTime date,
    int amountPaise, {
    PrepayMode mode = PrepayMode.tenure,
  }) => _db
      .into(_db.loanPrepayments)
      .insert(
        LoanPrepaymentsCompanion.insert(
          loanId: loanId,
          date: date,
          amountPaise: amountPaise,
          mode: Value(mode.name),
        ),
      );

  Future<List<LoanStatus>> statuses(DateTime asOf) async => [
    for (final l in await list()) const LoanCalculator().status(l, asOf),
  ];

  /// Bank debits within ±1% of the EMI since the first EMI (newest first):
  /// evidence the EMI is being paid.
  Future<List<DateTime>> emisSeen(LoanStatus s, {int limit = 6}) async {
    final emi = s.emiPaise;
    if (emi <= 0) return const [];
    final rows =
        await (_db.select(_db.transactions)
              ..where((t) => t.direction.equals('debit'))
              ..where(
                (t) => t.amountPaise.isBetweenValues(
                  (emi * 0.99).floor(),
                  (emi * 1.01).ceil(),
                ),
              )
              ..where(
                (t) => t.bookedAt.isBiggerOrEqualValue(
                  s.loan.firstEmiDate.subtract(const Duration(days: 7)),
                ),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.bookedAt)])
              ..limit(limit))
            .get();
    return [for (final r in rows) r.bookedAt];
  }
}

import 'package:drift/drift.dart' show OrderingTerm, Value, Variable;

import '../core/db/database.dart';
import 'credit_cards.dart';
import 'insights_repository.dart';

/// A card seen in imported card statements but not yet tracked.
class CardSuggestion {
  const CardSuggestion({
    required this.bankCode,
    required this.last4,
    required this.txnCount,
    this.creditLimitPaise,
  });

  final String bankCode;
  final String? last4;
  final int txnCount;
  final int? creditLimitPaise;
}

class CreditCardRepository {
  CreditCardRepository(this._db);

  final ArthDatabase _db;

  Future<List<CardDef>> list() async {
    final rows = await (_db.select(
      _db.creditCards,
    )..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
    return [
      for (final r in rows)
        CardDef(
          id: r.id,
          bankCode: r.bankCode,
          name: r.name,
          last4: r.last4,
          creditLimitPaise: r.creditLimitPaise,
          statementDay: r.statementDay,
          dueDay: r.dueDay,
        ),
    ];
  }

  /// Inserts when [id] is null, else updates.
  Future<int> save({
    int? id,
    required String bankCode,
    required String name,
    String? last4,
    int? creditLimitPaise,
    int? statementDay,
    int? dueDay,
  }) async {
    for (final d in [statementDay, dueDay]) {
      if (d != null && (d < 1 || d > 31)) {
        throw ArgumentError.value(d, 'day', 'must be 1–31');
      }
    }
    final row = CreditCardsCompanion(
      bankCode: Value(bankCode.toUpperCase()),
      name: Value(name),
      last4: Value(last4),
      creditLimitPaise: Value(creditLimitPaise),
      statementDay: Value(statementDay),
      dueDay: Value(dueDay),
      updatedAt: Value(DateTime.now()),
    );
    if (id == null) return _db.into(_db.creditCards).insert(row);
    await (_db.update(
      _db.creditCards,
    )..where((c) => c.id.equals(id))).write(row);
    return id;
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.creditCards)..where((c) => c.id.equals(id))).go();

  /// Cards found in imported card statements, most transactions first,
  /// excluding ones already tracked.
  Future<List<CardSuggestion>> suggestions() async {
    final tracked = {
      for (final c in await list()) '${c.bankCode}|${c.last4 ?? ''}',
    };
    final rows = await _db
        .customSelect(
          '''
SELECT t.bank_code AS bank, t.account_hint AS last4, COUNT(*) AS n,
       (SELECT s.credit_limit_paise FROM statement_summaries s
         WHERE s.bank_code = t.bank_code AND s.account_kind = 'card'
           AND COALESCE(s.last4, '') = COALESCE(t.account_hint, '')
           AND s.credit_limit_paise IS NOT NULL
         ORDER BY s.id DESC LIMIT 1) AS lim
FROM transactions t
WHERE t.account_kind = 'card'
GROUP BY t.bank_code, t.account_hint
ORDER BY n DESC
''',
          readsFrom: {_db.transactions, _db.statementSummaries},
        )
        .get();
    return [
      for (final r in rows)
        if (!tracked.contains(
          '${r.read<String>('bank')}|${r.readNullable<String>('last4') ?? ''}',
        ))
          CardSuggestion(
            bankCode: r.read<String>('bank'),
            last4: r.readNullable<String>('last4'),
            txnCount: r.read<int>('n'),
            creditLimitPaise: r.readNullable<int>('lim'),
          ),
    ];
  }

  /// Printed bills from this card's imported statements.
  Future<List<CardBill>> bills(CardDef card) async {
    final rows = await _db
        .customSelect(
          'SELECT statement_date, period_end, due_date, total_due_paise, '
          'min_due_paise, credit_limit_paise FROM statement_summaries '
          "WHERE bank_code = ? AND account_kind = 'card' "
          '${card.last4 == null ? '' : 'AND last4 = ?'}',
          variables: [
            Variable<String>(card.bankCode),
            if (card.last4 != null) Variable<String>(card.last4!),
          ],
          readsFrom: {_db.statementSummaries},
        )
        .get();
    return [
      for (final r in rows)
        CardBill(
          statementDate: r.readNullable<DateTime>('statement_date'),
          periodEnd: r.readNullable<DateTime>('period_end'),
          dueDate: r.readNullable<DateTime>('due_date'),
          totalDuePaise: r.readNullable<int>('total_due_paise'),
          minDuePaise: r.readNullable<int>('min_due_paise'),
          creditLimitPaise: r.readNullable<int>('credit_limit_paise'),
        ),
    ];
  }

  /// Status of every tracked card as of [asOf] (due soonest first).
  Future<List<CardStatus>> statuses(DateTime asOf) async {
    final insights = InsightsRepository(_db);
    final out = <CardStatus>[];
    for (final c in await list()) {
      final txns = await insights.cardTransactions(
        c.bankCode,
        c.last4,
        DateTime(asOf.year, asOf.month - 3, asOf.day),
        DateTime(asOf.year, asOf.month, asOf.day + 1),
      );
      out.add(
        const CardCycleCalculator().status(
          c,
          txns,
          asOf: asOf,
          bills: await bills(c),
        ),
      );
    }
    int rank(CardStatus s) => switch (s.state) {
      CardBillState.overdue => 0,
      CardBillState.due => 1,
      CardBillState.noBill => 2,
      CardBillState.paid => 3,
    };
    out.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      return (a.daysToDue ?? 999).compareTo(b.daysToDue ?? 999);
    });
    return out;
  }
}

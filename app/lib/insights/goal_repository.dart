import 'package:drift/drift.dart' show OrderingTerm, Value, Variable;

import '../core/db/database.dart';
import 'goals.dart';

/// A bank account with known balances, for linking a goal.
class BalanceAccount {
  const BalanceAccount(this.bankCode, this.last4, this.balancePaise);
  final String bankCode;
  final String last4;
  final int balancePaise;

  String get ref => '$bankCode|$last4';
}

class GoalRepository {
  GoalRepository(this._db);

  final ArthDatabase _db;

  Future<List<GoalDef>> list() async {
    final rows = await (_db.select(_db.goals)
          ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .get();
    return [for (final r in rows) _def(r)];
  }

  static GoalDef _def(Goal r) => GoalDef(
        id: r.id,
        name: r.name,
        targetPaise: r.targetPaise,
        targetDate: r.targetDate,
        startDate: r.startDate,
        startPaise: r.startPaise,
        annualReturnPct: r.annualReturnBp / 100,
        source: GoalSource.values.byName(r.source),
        sourceRef: r.sourceRef,
      );

  /// Inserts when [id] is null, else updates.
  Future<int> save({
    int? id,
    required String name,
    required int targetPaise,
    DateTime? targetDate,
    DateTime? startDate,
    int startPaise = 0,
    double annualReturnPct = 0,
    GoalSource source = GoalSource.manual,
    String? sourceRef,
  }) async {
    if (targetPaise <= 0) {
      throw ArgumentError.value(targetPaise, 'targetPaise', 'must be positive');
    }
    if (source != GoalSource.manual && (sourceRef ?? '').isEmpty) {
      throw ArgumentError.value(sourceRef, 'sourceRef', 'required');
    }
    final row = GoalsCompanion(
      name: Value(name.trim()),
      targetPaise: Value(targetPaise),
      targetDate: Value(targetDate),
      startPaise: Value(startPaise),
      annualReturnBp: Value((annualReturnPct * 100).round()),
      source: Value(source.name),
      sourceRef: Value(source == GoalSource.manual ? null : sourceRef),
      updatedAt: Value(DateTime.now()),
    );
    if (id == null) {
      final now = DateTime.now();
      return _db.into(_db.goals).insert(row.copyWith(
            startDate: Value(startDate ?? DateTime(now.year, now.month, now.day)),
          ));
    }
    await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      startDate == null ? row : row.copyWith(startDate: Value(startDate)),
    );
    return id;
  }

  Future<void> delete(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.goalContributions)
            ..where((c) => c.goalId.equals(id)))
          .go();
      await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
    });
  }

  Future<void> addContribution(
    int goalId,
    int amountPaise,
    DateTime date, {
    String? note,
  }) async {
    if (amountPaise == 0) return;
    await _db.into(_db.goalContributions).insert(
          GoalContributionsCompanion.insert(
            goalId: goalId,
            amountPaise: amountPaise,
            date: date,
            note: Value(note),
          ),
        );
  }

  Future<List<GoalContribution>> contributions(int goalId) =>
      (_db.select(_db.goalContributions)
            ..where((c) => c.goalId.equals(goalId))
            ..orderBy([(c) => OrderingTerm.desc(c.date)]))
          .get();

  Future<void> deleteContribution(int id) =>
      (_db.delete(_db.goalContributions)..where((c) => c.id.equals(id))).go();

  /// Bank accounts (not cards) with a known balance, latest balance first
  /// by bank.
  Future<List<BalanceAccount>> balanceAccounts() async {
    final rows = await _db.customSelect(
      '''
SELECT bank_code, account_hint, balance_after_paise FROM transactions t
WHERE balance_after_paise IS NOT NULL AND account_hint IS NOT NULL
  AND COALESCE(account_kind, 'bank') = 'bank'
  AND t.id = (SELECT t2.id FROM transactions t2
              WHERE t2.bank_code = t.bank_code
                AND t2.account_hint = t.account_hint
                AND t2.balance_after_paise IS NOT NULL
              ORDER BY t2.booked_at DESC, t2.id DESC LIMIT 1)
ORDER BY bank_code, account_hint
''',
      readsFrom: {_db.transactions},
    ).get();
    return [
      for (final r in rows)
        BalanceAccount(
          r.read<String>('bank_code'),
          r.read<String>('account_hint'),
          r.read<int>('balance_after_paise'),
        ),
    ];
  }

  /// Latest balance of `BANK|last4` on or before [at].
  Future<int?> balanceAt(String ref, DateTime at) async {
    final i = ref.indexOf('|');
    if (i < 0) return null;
    final row = await _db.customSelect(
      'SELECT balance_after_paise AS b FROM transactions '
      'WHERE bank_code = ? AND account_hint = ? AND booked_at <= ? '
      'AND balance_after_paise IS NOT NULL '
      'ORDER BY booked_at DESC, id DESC LIMIT 1',
      variables: [
        Variable<String>(ref.substring(0, i)),
        Variable<String>(ref.substring(i + 1)),
        Variable<DateTime>(at),
      ],
      readsFrom: {_db.transactions},
    ).getSingleOrNull();
    return row?.read<int>('b');
  }

  Future<GoalProgress> progressOf(GoalDef g, DateTime asOf) async {
    switch (g.source) {
      case GoalSource.account:
        final ref = g.sourceRef!;
        return const GoalCalculator().progress(
          g,
          asOf: asOf,
          accountBalancePaise: await balanceAt(ref, asOf),
          accountBalance3MonthsAgoPaise: await balanceAt(
            ref,
            DateTime(asOf.year, asOf.month - 3, asOf.day),
          ),
        );
      case GoalSource.manual:
        return const GoalCalculator().progress(
          g,
          asOf: asOf,
          flows: [
            for (final c in await contributions(g.id))
              GoalFlow(c.date, c.amountPaise),
          ],
        );
      case GoalSource.category:
        final rows = await _db.customSelect(
          'SELECT t.booked_at AS d, '
          "CASE t.direction WHEN 'debit' THEN t.amount_paise "
          'ELSE -t.amount_paise END AS p '
          'FROM transactions t JOIN categories c ON c.id = t.category_id '
          'WHERE c.slug = ? AND t.booked_at >= ? AND t.booked_at <= ?',
          variables: [
            Variable<String>(g.sourceRef!),
            Variable<DateTime>(g.startDate),
            Variable<DateTime>(asOf),
          ],
          readsFrom: {_db.transactions, _db.categories},
        ).get();
        return const GoalCalculator().progress(
          g,
          asOf: asOf,
          flows: [
            for (final r in rows)
              GoalFlow(r.read<DateTime>('d'), r.read<int>('p')),
          ],
        );
    }
  }

  Future<List<GoalProgress>> progressAll(DateTime asOf) async => [
        for (final g in await list()) await progressOf(g, asOf),
      ];
}

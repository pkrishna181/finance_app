import 'package:drift/drift.dart' show DoUpdate, Value, Variable;

import '../core/db/database.dart';
import 'budget.dart';
import 'insight_models.dart';

/// Reads and writes [Budgets] rows as [BudgetDef]s keyed by category slug.
class BudgetRepository {
  BudgetRepository(this._db);

  final ArthDatabase _db;

  Future<List<BudgetDef>> list() async {
    final rows = await _db
        .customSelect(
          'SELECT c.slug AS slug, b.limit_paise AS limit_paise, '
          'b.rollover AS rollover, b.start_month AS start_month '
          'FROM budgets b JOIN categories c ON c.id = b.category_id',
          readsFrom: {_db.budgets, _db.categories},
        )
        .get();
    return [
      for (final r in rows)
        BudgetDef(
          slug: r.read<String>('slug'),
          limitPaise: r.read<int>('limit_paise'),
          rollover: r.read<bool>('rollover'),
          start: _parseMonth(r.read<String>('start_month')),
        ),
    ];
  }

  /// Creates or updates the budget for [slug]. A new budget starts in
  /// [start]; an existing one keeps its start month.
  Future<void> upsert(
    String slug, {
    required int limitPaise,
    required bool rollover,
    required MonthKey start,
  }) async {
    if (limitPaise <= 0) {
      throw ArgumentError.value(limitPaise, 'limitPaise', 'must be positive');
    }
    final cat = await _db.categoryBySlug(slug);
    if (cat == null) {
      throw ArgumentError.value(slug, 'slug', 'unknown category');
    }
    await _db
        .into(_db.budgets)
        .insert(
          BudgetsCompanion.insert(
            categoryId: cat.id,
            limitPaise: limitPaise,
            rollover: Value(rollover),
            startMonth: _formatMonth(start),
          ),
          onConflict: DoUpdate(
            (_) => BudgetsCompanion(
              limitPaise: Value(limitPaise),
              rollover: Value(rollover),
              updatedAt: Value(DateTime.now()),
            ),
            target: [_db.budgets.categoryId],
          ),
        );
  }

  Future<void> delete(String slug) async {
    await _db.customUpdate(
      'DELETE FROM budgets WHERE category_id = '
      '(SELECT id FROM categories WHERE slug = ?)',
      variables: [Variable<String>(slug)],
      updates: {_db.budgets},
    );
  }

  static String _formatMonth(MonthKey m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  static MonthKey _parseMonth(String s) =>
      MonthKey(int.parse(s.substring(0, 4)), int.parse(s.substring(5, 7)));
}

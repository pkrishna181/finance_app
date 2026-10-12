import 'package:drift/drift.dart';

import '../core/db/database.dart';
import 'allocation.dart';
import 'allocation_repository.dart';
import 'insight_models.dart';
import 'insights_repository.dart';
import 'net_worth_repository.dart';
import 'sheets.dart';

/// Example shown when the user has no sheets yet.
const kExampleSheet = '''# Home loan
price = 60L
down = 20% of price
loan = price - down
emi(loan, 8.5, 20)

# Monthly budget
rent = 25k
food = spend("groceries") + spend("food delivery")
others = 15k
total

# My numbers
networth
avg_spend("all", 6)
''';

class SheetRepository {
  SheetRepository(this._db);

  final ArthDatabase _db;

  Future<List<Sheet>> list() => (_db.select(
    _db.sheets,
  )..orderBy([(s) => OrderingTerm.desc(s.updatedAt)])).get();

  Future<Sheet?> get(int id) =>
      (_db.select(_db.sheets)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> create({String title = 'Untitled', String body = ''}) => _db
      .into(_db.sheets)
      .insert(SheetsCompanion.insert(title: title, body: body));

  Future<void> save(int id, {required String title, required String body}) =>
      (_db.update(_db.sheets)..where((s) => s.id.equals(id))).write(
        SheetsCompanion(
          title: Value(title),
          body: Value(body),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> delete(int id) =>
      (_db.delete(_db.sheets)..where((s) => s.id.equals(id))).go();

  /// Snapshot of the user's numbers for sheet functions (rupees).
  Future<SheetData> data(DateTime now) async {
    final repo = InsightsRepository(_db);
    final month = MonthKey.of(now);
    final agg = await repo.aggregatorFor(month, months: 13);
    final spend = <Map<String, double>>[];
    final income = <double>[];
    for (var k = 0; k < 13; k++) {
      final s = agg.summarize(month.plusMonths(-k));
      spend.add({for (final e in s.byCategory.entries) e.key: e.value / 100});
      income.add(s.incomePaise / 100);
    }
    final names = await repo.categoryNames();
    final nw = await NetWorthRepository(_db).netWorth(now);
    final classes = await AllocationRepository(_db).values(now);
    final investments = [
      AssetClass.equity,
      AssetClass.debt,
      AssetClass.gold,
      AssetClass.other,
    ].fold<int>(0, (s, c) => s + (classes[c] ?? 0));
    return SheetData(
      netWorth: nw.totalPaise / 100,
      investments: investments / 100,
      cash: (classes[AssetClass.cash] ?? 0) / 100,
      spendByMonth: spend,
      incomeByMonth: income,
      categoryNames: {
        for (final e in names.entries) e.value.toLowerCase(): e.key,
      },
    );
  }
}

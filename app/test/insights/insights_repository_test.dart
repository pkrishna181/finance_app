import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ArthDatabase db;

  setUp(() => db = ArthDatabase.memory());
  tearDown(() => db.close());

  Future<void> insert(
    String hash,
    int paise,
    DateTime at, {
    String direction = 'debit',
    String? categorySlug,
    String raw = 'SWIGGY',
  }) async {
    int? catId;
    if (categorySlug != null) {
      catId = (await (db.select(db.categories)
                ..where((c) => c.slug.equals(categorySlug)))
              .getSingle())
          .id;
    }
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            amountPaise: paise,
            direction: direction,
            txnType: 'upi',
            bookedAt: at,
            bankCode: 'HDFC',
            rawMerchant: raw,
            rawDescription: raw,
            dedupeHash: hash,
            categoryId: Value(catId),
          ),
        );
  }

  test('loadRange joins category and respects [from, to)', () async {
    await insert('a', 25000, DateTime(2026, 7, 3, 10),
        categorySlug: 'food_delivery');
    await insert('b', 10000, DateTime(2026, 8, 1));
    final rows = await InsightsRepository(db)
        .loadRange(DateTime(2026, 7), DateTime(2026, 8));
    expect(rows, hasLength(1));
    expect(rows.single.categorySlug, 'food_delivery');
    expect(rows.single.isDebit, isTrue);
    expect(rows.single.amountPaise, 25000);
  });

  test('aggregatorFor + availableMonths end to end', () async {
    await insert('a', 25000, DateTime(2026, 7, 3, 10),
        categorySlug: 'food_delivery');
    await insert('b', 500000, DateTime(2026, 6, 28, 10),
        direction: 'credit', categorySlug: 'salary');
    final repo = InsightsRepository(db);

    final months = await repo.availableMonths();
    expect(months, [MonthKey(2026, 7), MonthKey(2026, 6)]);

    final agg = await repo.aggregatorFor(MonthKey(2026, 7));
    final jul = agg.summarize(MonthKey(2026, 7));
    expect(jul.spendPaise, 25000);
    expect(jul.byCategory['food_delivery'], 25000);
    expect(agg.summarize(MonthKey(2026, 6)).incomePaise, 500000);
  });

  test('insight indexes exist', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='index'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll([
      'idx_transactions_booked_at',
      'idx_transactions_category_booked_at',
    ]));
  });

  test('loadRecurring detects, flags rows, and matches mandate notices',
      () async {
    for (final m in [7, 8, 9]) {
      await insert('n$m', 64900, DateTime(2026, m, 5, 10), raw: 'NETFLIX');
    }
    await db.insertMandateNotice(MandateNoticesCompanion.insert(
      bankCode: 'HDFC',
      rawBody: 'upcoming mandate',
      merchant: const Value('Netflix'),
      amountPaise: const Value(64900),
      scheduledDate: Value(DateTime(2026, 9, 25)),
    ));

    final found = await InsightsRepository(db)
        .loadRecurring(asOf: DateTime(2026, 9, 15));
    expect(found, hasLength(1));
    expect(found.single.cadence, Cadence.monthly);
    expect(found.single.mandateDate, DateTime(2026, 9, 25));

    final rows = await db.select(db.transactions).get();
    expect(rows.every((r) => r.isRecurringCandidate), isTrue);
    expect(rows.every((r) => r.recurringKind == 'subscription'), isTrue);
  });

  test('dismissAnomaly persists and is read back', () async {
    await insert('d1', 45000, DateTime(2026, 9, 3, 10), raw: 'ZOMATO');
    final txnId = (await db.select(db.transactions).getSingle()).id;
    final repo = InsightsRepository(db);
    expect(await repo.dismissedAnomalyKeys(), isEmpty);

    await repo.dismissAnomaly(Anomaly(
      kind: AnomalyKind.duplicateCharge,
      key: 'dup:$txnId',
      title: 'Possible duplicate: ZOMATO',
      detail: 'x',
      impactPaise: 45000,
      txnId: txnId,
    ));
    expect(await repo.dismissedAnomalyKeys(), {'dup:$txnId'});
  });
}

import 'package:arth/ask/ask.dart';
import 'package:arth/core/models/category_defaults.dart';
import 'package:arth/insights/insight_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20, 14, 30); // a Tuesday
  final parser = AskParser(
    AskVocabulary(
      categoryNames: {for (final c in kDefaultCategories) c.slug: c.name},
      merchants: const [
        'swiggy blr',
        'swiggy instamart',
        'amazon pay',
        'uber india',
      ],
    ),
  );
  AskQuery q(String s) {
    final r = parser.parse(s, now);
    expect(r.query, isNotNull, reason: 'unknown: ${r.unknownWords}');
    return r.query!;
  }

  final sep = AskPeriod.month(const MonthKey(2026, 9));

  test('spend on a category in a relative month', () {
    final a = q('How much did I spend on food last month?');
    expect(a.intent, AskIntent.spend);
    expect(a.categorySlug, 'food_delivery');
    expect(a.period, sep);
    expect(a.period!.label, 'Sep 2026');
  });

  test('month names, past months only', () {
    expect(q('groceries in september').period, sep);
    expect(q('groceries in september').categorySlug, 'groceries');
    final dec = q('spend in december').period!;
    expect(dec.from, DateTime(2025, 12));
    expect(q('rent sept 2025').period!.from, DateTime(2025, 9));
    expect(q('rent in march last year').period!.from, DateTime(2025, 3));
  });

  test('default period is this month so far', () {
    final a = q('how much did I spend');
    expect(a.intent, AskIntent.spend);
    expect(a.categorySlug, isNull);
    expect(a.period!.from, DateTime(2026, 10));
    expect(a.period!.label, 'Oct 2026 so far');
  });

  test('merchant from the vocabulary', () {
    final a = q('What did I spend at Swiggy this year');
    expect(a.intent, AskIntent.spend);
    expect(a.merchant, 'swiggy');
    expect(a.period!.from, DateTime(2026));
    expect(q('amazon pay last month').merchant, 'amazon pay');
    expect(q('uber rides last week').merchant, 'uber');
  });

  test('unknown words fail instead of guessing', () {
    final r = parser.parse('spent on blorptastic', now);
    expect(r.query, isNull);
    expect(r.unknownWords, ['blorptastic']);
    expect(parser.parse('', now).query, isNull);
  });

  test('intents', () {
    expect(q('top categories last month').intent, AskIntent.topCategories);
    expect(
      q('where did my money go in august').period!.from,
      DateTime(2026, 8),
    );
    final m = q('top 5 merchants this fy');
    expect(m.intent, AskIntent.topMerchants);
    expect(m.period!.from, DateTime(2026, 4));
    expect(m.period!.label, 'FY 2026-27 so far');
    expect(q("what's my net worth?").intent, AskIntent.netWorth);
    expect(q("what's my net worth?").period, isNull);
    expect(q('how are my budgets').intent, AskIntent.budgets);
    expect(q('biggest expenses last month').intent, AskIntent.largest);
  });

  test('savings and income', () {
    final s = q('how much did I save in FY 2025-26');
    expect(s.intent, AskIntent.savings);
    expect(s.period!.from, DateTime(2025, 4));
    expect(s.period!.toExclusive, DateTime(2026, 4));
    final i = q('salary in september');
    expect(i.intent, AskIntent.income);
    expect(i.categorySlug, 'salary');
    expect(q('income last month').intent, AskIntent.income);
  });

  test('upcoming with a look-ahead', () {
    expect(q("what's due next week").days, 7);
    expect(q('upcoming payments').days, 30);
    expect(q('bills due in the next 10 days').days, 10);
  });

  test('last paid needs something to look for', () {
    final a = q('when did I last pay rent');
    expect(a.intent, AskIntent.lastPaid);
    expect(a.categorySlug, 'rent');
    expect(a.period, isNull);
    expect(parser.parse('when did i last order', now).query, isNull);
  });

  test('average uses a month count', () {
    final a = q('average monthly spend on groceries over the last 3 months');
    expect(a.intent, AskIntent.average);
    expect(a.months, 3);
    expect(a.categorySlug, 'groceries');
    expect(q('average spend').months, 6);
  });

  test('rolling ranges and since', () {
    final d = q('biggest expenses last 30 days').period!;
    expect(d.from, DateTime(2026, 9, 21));
    expect(d.toExclusive, DateTime(2026, 10, 21));
    final m = q('food in the last 3 months').period!;
    expect(m.from, DateTime(2026, 7, 21));
    final s = q('spent on fuel since april').period!;
    expect(s.from, DateTime(2026, 4));
    expect(s.toExclusive, DateTime(2026, 10, 21));
    final w = q('spend last week').period!;
    expect(w.from, DateTime(2026, 10, 12));
    expect(w.toExclusive, DateTime(2026, 10, 19));
  });

  test('number words and fortnights', () {
    expect(
      q('swiggy in the past three months').period!.from,
      DateTime(2026, 7, 21),
    );
    expect(
      q('spend over the past fortnight').period!.from,
      DateTime(2026, 10, 7),
    );
    expect(q('bills due in the next fortnight').days, 14);
    expect(q('rent since the year began').period!.from, DateTime(2026));
  });

  test('a failed parse still reports what it found', () {
    final r = parser.parse('how much did swiggy sneakily take in august', now);
    expect(r.query, isNull);
    final p = r.partial!;
    expect(p.merchant, 'swiggy');
    expect(p.period!.from, DateTime(2026, 8));
    expect(p.intent, isNull);
    expect(p.ignoredWords, ['sneakily', 'take']);

    final w = parser.parse('when did i last fill petrol', now).partial!;
    expect(w.intent, AskIntent.lastPaid);
    expect(w.categorySlug, 'fuel');
    // Merchants match whole words only.
    expect(parser.parse('ate out in august', now).partial!.merchant, isNull);
  });
}

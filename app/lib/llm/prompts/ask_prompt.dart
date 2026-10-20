/// Question → structured query JSON for the Ask tab (Phase 12.2).
///
/// The model only classifies the question; it never sees or produces
/// amounts. Output shape is fixed by `AskModelReader.grammar`.
class AskPrompt {
  AskPrompt._();

  static String _ym(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static String build({
    required String question,
    required DateTime today,
    required Map<String, String> categories,
  }) {
    final twoMonthsAgo = DateTime(today.year, today.month - 2);
    final cats = [
      for (final e in categories.entries)
        if (e.key != 'uncategorized') '${e.key} (${e.value})',
    ].join(', ');
    final q = question.replaceAll('\n', ' ').trim();
    return '''Turn a question about the user's own money into JSON.
Today is ${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}.
Keys, in this order:
intent: spend, income, savings, top_categories, top_merchants, largest, last_paid, average, net_worth, budgets or upcoming
category: one category id below, or "" if none is meant
merchant: a shop, app or person copied exactly from the question, or ""
period: this_month, last_month, month, this_year, last_year, this_fy, last_fy, last_days, last_months or all
month: "YYYY-MM" when period is month, else ""
n: days or months for last_days / last_months, months to average over, or days ahead for upcoming; else 0

Category ids: $cats

Q: what did dinner orders cost me in ${_monthName(twoMonthsAgo.month)}
{"intent":"spend","category":"food_delivery","merchant":"","period":"month","month":"${_ym(twoMonthsAgo)}","n":0}
Q: which apps took most of my cash this financial year
{"intent":"top_merchants","category":"","merchant":"","period":"this_fy","month":"","n":0}
Q: what's left to pay over the coming fortnight
{"intent":"upcoming","category":"","merchant":"","period":"all","month":"","n":14}
Q: how much did i blow at Starbucks in the past couple of months
{"intent":"spend","category":"","merchant":"Starbucks","period":"last_months","month":"","n":2}
Q: am i putting money aside
{"intent":"savings","category":"","merchant":"","period":"this_month","month":"","n":0}

Q: $q
''';
  }

  static const _names = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];

  static String _monthName(int m) => _names[m - 1];
}

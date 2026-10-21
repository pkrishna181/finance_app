/// Question → intent (+ category) for the Ask tab (Phase 12.2).
///
/// A 1B model is only asked to classify: dates and merchants are read by the
/// rule-based parser, and the model never sees or produces amounts. Output
/// shape is fixed by `AskModelReader.grammar`.
class AskPrompt {
  AskPrompt._();

  static String build({
    required String question,
    required Map<String, String> categories,
  }) {
    final cats = [
      for (final e in categories.entries)
        if (e.key != 'uncategorized') '${e.key} (${e.value})',
    ].join(', ');
    final q = question.replaceAll('\n', ' ').trim();
    return '''Classify a question about the user's own money.
Reply with JSON: {"intent":"...","category":"..."}

intent is one of:
spend: how much money went out, what something cost
income: money that came in, salary, interest received
savings: money saved, spending compared with income
top_categories: which kinds of spending took the most
top_merchants: which shops, apps or people got the most money
largest: the biggest single payments
last_paid: when something was last paid
average: the usual or typical amount per month
net_worth: total wealth, everything owned minus loans
budgets: spending limits, going over a limit
upcoming: bills and payments due soon

category is "" unless the question is about one kind of spending or income.
Category ids: $cats

Q: what did dinner from outside cost me
{"intent":"spend","category":"food_delivery"}
Q: which apps took most of my cash
{"intent":"top_merchants","category":""}
Q: am i living within my means
{"intent":"savings","category":""}
Q: what are my biggest kinds of spending
{"intent":"top_categories","category":""}
Q: what's left to pay soon
{"intent":"upcoming","category":""}
Q: when did i last top up my phone
{"intent":"last_paid","category":"recharge"}
Q: what do i normally put into mutual funds each month
{"intent":"average","category":"investments_sip"}
Q: how rich am i
{"intent":"net_worth","category":""}
Q: did i blow past any limits
{"intent":"budgets","category":""}
Q: how much did the employer pay me
{"intent":"income","category":"salary"}
Q: how much have i sent my brother
{"intent":"spend","category":""}
Q: priciest thing i bought
{"intent":"largest","category":""}

Q: $q
''';
  }
}

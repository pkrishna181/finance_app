/// Transaction categorization prompt (fixed enum via GBNF).
class CategorizePrompt {
  CategorizePrompt._();

  static String build({
    required String merchant,
    required String narration,
    required int amountPaise,
    required String direction,
  }) {
    return '''Suggest a spending category for this transaction.
Output JSON only: {"category":"<slug>","confidence":0.0}
Use one of: groceries, food_delivery, transport, fuel, utilities, rent, emi,
investments_sip, recharge, healthcare, shopping, entertainment, transfers_self,
transfers_others, salary, interest, charges, uncategorized

Merchant: $merchant
Narration: $narration
Amount paise: $amountPaise
Direction: $direction
JSON:''';
  }
}

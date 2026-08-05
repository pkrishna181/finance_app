/// Few-shot user prompts for SMS → span-extraction JSON (Phase 5.2).
class SmsParsePrompt {
  SmsParsePrompt._();

  static const _instructions = '''Extract one minified JSON object from a bank SMS.
Keys (exact order, no spaces): a,d,t,y,r,m,f,v
- a: VERBATIM txn amount substring — copy exactly (e.g. "Rs.275.00", "INR 87.30"). Never compute paise.
- d: VERBATIM date substring from SMS — copy exactly (e.g. "01-08-26", "29-JUL-26")
- t: VERBATIM time substring or null
- y: upi, imps, neft, rtgs, atm, card, salary, other
- r: debit or credit (Dr/debited→debit; Cr/credited/received→credit)
- m: merchant/payee verbatim or null (null if only Avl Bal / balance text)
- f: UPI/IMPS/NEFT ref verbatim or null
- v: UPI VPA verbatim or null
Pick the txn amount, not Avl Bal / available balance. Output ONLY minified JSON.''';

  static const _example1Sms =
      'Rs.275.00 debited for UPI Ref 812233445566 to shop@ybl on 01-08-26. Thank you.';
  static const _example1Json =
      '{"a":"Rs.275.00","d":"01-08-26","t":null,"y":"upi","r":"debit",'
      '"m":"shop@ybl","f":"812233445566","v":"shop@ybl"}';

  static const _example2Sms =
      'Dr INR 87.30 debited on 29-JUL-26 UPI/412399887766/zomato@paytm FOOD. Avl Bal INR 12,034.55';
  static const _example2Json =
      '{"a":"INR 87.30","d":"29-JUL-26","t":null,"y":"upi","r":"debit",'
      '"m":"zomato@paytm","f":"412399887766","v":"zomato@paytm"}';

  static const _example3Sms =
      'NEFT CR-ACME CORP Rs.25,000.00 credited to A/c XXXX9012 on 31-07-2026';
  static const _example3Json =
      '{"a":"Rs.25,000.00","d":"31-07-2026","t":null,"y":"neft","r":"credit",'
      '"m":"ACME CORP","f":null,"v":null}';

  static String get _fewShotBlock => '''Example SMS:
$_example1Sms
JSON:
$_example1Json

Example SMS:
$_example2Sms
JSON:
$_example2Json

Example SMS:
$_example3Sms
JSON:
$_example3Json''';

  /// Cached prefix token estimate (chars÷4 heuristic).
  static int get prefixTokenEstimate =>
      (prefixContent.length / 4).ceil();

  /// User-turn content for [Gemma3Chat.formatUserTurn].
  static String buildUserContent(String sms) {
    return '''$_instructions

$_fewShotBlock

SMS:
${sms.trim()}
JSON:''';
  }

  /// Static prefix (instructions + few-shot) for KV-cache reuse.
  static String get prefixContent {
    return '''$_instructions

$_fewShotBlock

SMS:
''';
  }

  /// Per-item suffix appended after cached prefix.
  static String buildItemSuffix(String sms) => '${sms.trim()}\nJSON:';

  /// Short instruction for microbenchmark prefill/decode (no few-shot).
  static String buildBenchmarkUserContent(String sms) {
    return 'Extract span SMS txn JSON (a,d verbatim from text). Minified JSON only.\n${sms.trim()}';
  }
}

import 'dart:convert';

import '../core/result/result.dart';
import '../insights/insight_models.dart';
import '../llm/llm_engine.dart';
import '../llm/prompts/ask_prompt.dart';
import 'ask_parser.dart';
import 'ask_query.dart';

/// Reads a question the rule-based [AskParser] couldn't, using the on-device
/// model for the one thing rules do badly: what kind of question it is.
///
/// The model picks only the intent and, when the parser found none, a
/// category — both from fixed lists enforced by a grammar. Dates and
/// merchants always come from the parser's [AskPartial]; amounts from
/// `AskAnswerer`.
class AskModelReader {
  AskModelReader(this.engine);

  final LlmEngine engine;

  Future<Result<AskQuery>> read(
    String question,
    AskPartial partial,
    AskVocabulary vocab,
    DateTime now,
  ) async {
    final out = await engine.completeJson(
      prompt: AskPrompt.build(
        question: question,
        categories: vocab.categoryNames,
      ),
      gbnfGrammar: grammar(vocab),
      maxTokens: 24,
    );
    return switch (out) {
      Ok(:final value) => validate(value, partial, vocab, now),
      Err(:final message, :final cause) => Err(
        '$cause'.contains('generation_in_progress') ? 'model_busy' : message,
        cause,
      ),
    };
  }

  static String _lit(String s) =>
      '"\\"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}\\""';

  /// Compact JSON with two fixed keys; categories limited to the user's own.
  static String grammar(AskVocabulary vocab) {
    final cats = [
      '"\\"\\""',
      for (final slug in vocab.categoryNames.keys)
        if (slug != kUncategorizedSlug) _lit(slug),
    ].join(' | ');
    return '''
root ::= "{\\"intent\\":" intent ",\\"category\\":" category "}"
intent ::= ${[for (final i in AskIntent.values) _lit(i.wire)].join(' | ')}
category ::= $cats
''';
  }

  /// Model JSON + the parser's partial reading → a query. Pure, so it is
  /// tested without a model.
  static Result<AskQuery> validate(
    String json,
    AskPartial partial,
    AskVocabulary vocab,
    DateTime now,
  ) {
    final Map<String, dynamic> m;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return const Err('bad_json');
      m = decoded;
    } on FormatException catch (e) {
      return Err('bad_json', e);
    }

    final read = AskIntentWire.fromWire('${m['intent']}');
    if (read == null) return Err('bad_intent', m['intent']);
    // A specific keyword in the question beats the model's guess; plain
    // "spend" is too generic to overrule it.
    var intent = partial.intent != null && partial.intent != AskIntent.spend
        ? partial.intent!
        : read;
    // "interest the bank gave me": an income category means income.
    if (kIncomeSlugs.contains(partial.categorySlug) &&
        const {
          AskIntent.spend,
          AskIntent.savings,
          AskIntent.topCategories,
          AskIntent.topMerchants,
        }.contains(intent)) {
      intent = AskIntent.income;
    }

    final cat = '${m['category'] ?? ''}'.trim();
    if (cat.isNotEmpty && !vocab.categoryNames.containsKey(cat)) {
      return Err('bad_category', cat);
    }
    // The parser's category (named in the question) wins over the model's.
    var category = partial.categorySlug ?? (cat.isEmpty ? null : cat);
    if (!_takesCategory(intent)) category = null;
    if (intent == AskIntent.income &&
        category != null &&
        !kIncomeSlugs.contains(category)) {
      category = null;
    }

    if (intent == AskIntent.lastPaid &&
        category == null &&
        partial.merchant == null) {
      return const Err('nothing_to_look_for');
    }

    return Ok(
      AskQuery(
        intent: intent,
        period: intent.usesPeriod
            ? partial.period ?? AskPeriod.month(MonthKey.of(now), now: now)
            : null,
        categorySlug: category,
        merchant: _takesMerchant(intent) ? partial.merchant : null,
        months: partial.months,
        days: partial.days,
      ),
    );
  }

  static bool _takesCategory(AskIntent i) => switch (i) {
    AskIntent.netWorth ||
    AskIntent.budgets ||
    AskIntent.upcoming ||
    AskIntent.savings ||
    AskIntent.topCategories => false,
    _ => true,
  };

  static bool _takesMerchant(AskIntent i) => switch (i) {
    AskIntent.spend ||
    AskIntent.largest ||
    AskIntent.lastPaid ||
    AskIntent.average => true,
    _ => false,
  };
}

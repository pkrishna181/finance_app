import 'dart:convert';

import '../core/result/result.dart';
import '../insights/insight_models.dart';
import '../insights/yearly.dart';
import '../llm/llm_engine.dart';
import '../llm/prompts/ask_prompt.dart';
import 'ask_parser.dart';
import 'ask_query.dart';

/// Reads a question the rule-based [AskParser] couldn't, using the on-device
/// model. The model only fills in an [AskQuery]; its output is constrained by
/// a grammar, then validated here before anything is computed.
class AskModelReader {
  AskModelReader(this.engine);

  final LlmEngine engine;

  static const _periods = [
    'this_month',
    'last_month',
    'month',
    'this_year',
    'last_year',
    'this_fy',
    'last_fy',
    'last_days',
    'last_months',
    'all',
  ];

  Future<Result<AskQuery>> read(
    String question,
    AskVocabulary vocab,
    DateTime now,
  ) async {
    final out = await engine.completeJson(
      prompt: AskPrompt.build(
        question: question,
        today: now,
        categories: vocab.categoryNames,
      ),
      gbnfGrammar: grammar(vocab),
      maxTokens: 80,
    );
    return switch (out) {
      Ok(:final value) => validate(value, question, vocab, now),
      Err(:final message, :final cause) => Err(
        '$cause'.contains('generation_in_progress') ? 'model_busy' : message,
        cause,
      ),
    };
  }

  static String _lit(String s) =>
      '"\\"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}\\""';

  /// Compact JSON with fixed keys; categories limited to the user's own.
  static String grammar(AskVocabulary vocab) {
    final cats = [
      '"\\"\\""',
      for (final slug in vocab.categoryNames.keys)
        if (slug != kUncategorizedSlug) _lit(slug),
    ].join(' | ');
    return '''
root ::= "{\\"intent\\":" intent ",\\"category\\":" category ",\\"merchant\\":" merchant ",\\"period\\":" period ",\\"month\\":" month ",\\"n\\":" n "}"
intent ::= ${[for (final i in AskIntent.values) _lit(i.wire)].join(' | ')}
category ::= $cats
merchant ::= "\\"" [a-zA-Z0-9 &.'-]{0,40} "\\""
period ::= ${[for (final p in _periods) _lit(p)].join(' | ')}
month ::= "\\"\\"" | "\\"" [0-9]{4} "-" [0-9]{2} "\\""
n ::= [0-9]{1,3}
''';
  }

  /// Turns model JSON into a query, or explains why it can't be used.
  /// Pure, so it is tested without a model.
  static Result<AskQuery> validate(
    String json,
    String question,
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

    final intent = AskIntentWire.fromWire('${m['intent']}');
    if (intent == null) return Err('bad_intent', m['intent']);

    final cat = '${m['category'] ?? ''}'.trim();
    String? category;
    if (cat.isNotEmpty) {
      if (!vocab.categoryNames.containsKey(cat)) {
        return Err('bad_category', cat);
      }
      category = cat;
    }

    // A merchant must be in the question (no invented names) and in the
    // ledger (otherwise the answer would be a silent ₹0).
    final rawMerchant = '${m['merchant'] ?? ''}'.trim().toLowerCase();
    String? merchant;
    if (rawMerchant.isNotEmpty) {
      if (!question.toLowerCase().contains(rawMerchant)) {
        return Err('merchant_not_in_question', rawMerchant);
      }
      if (!vocab.merchants.any((x) => x.contains(rawMerchant))) {
        return Err('unknown_merchant', rawMerchant);
      }
      merchant = rawMerchant;
    }

    if (intent == AskIntent.lastPaid && category == null && merchant == null) {
      return const Err('nothing_to_look_for');
    }

    final n = m['n'] is int ? m['n'] as int : 0;
    final period = intent.usesPeriod
        ? _period('${m['period']}', '${m['month'] ?? ''}', n, now)
        : null;
    if (intent.usesPeriod && period == null) {
      return Err('bad_period', '${m['period']} ${m['month']} $n');
    }

    return Ok(
      AskQuery(
        intent: intent,
        period: period,
        categorySlug: category,
        merchant: merchant,
        months: intent == AskIntent.average && n > 0 ? n.clamp(1, 24) : 6,
        days: intent == AskIntent.upcoming && n > 0 ? n.clamp(1, 90) : 30,
      ),
    );
  }

  static AskPeriod? _period(String kind, String month, int n, DateTime now) {
    final thisMonth = MonthKey.of(now);
    switch (kind) {
      case 'this_month':
        return AskPeriod.month(thisMonth, now: now);
      case 'last_month':
        return AskPeriod.month(thisMonth.plusMonths(-1));
      case 'month':
        final mm = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(month);
        if (mm == null) return null;
        final key = MonthKey(int.parse(mm[1]!), int.parse(mm[2]!));
        if (key.month < 1 || key.month > 12) return null;
        if (key.compareTo(thisMonth) > 0) return null;
        return AskPeriod.month(key, now: now);
      case 'this_year':
        return AskPeriod.calendarYear(now.year, now: now);
      case 'last_year':
        return AskPeriod.calendarYear(now.year - 1);
      case 'this_fy':
        return AskPeriod.financialYear(FinancialYear.of(now), now: now);
      case 'last_fy':
        return AskPeriod.financialYear(FinancialYear.of(now).previous);
      case 'last_days':
        return n < 1 || n > 730 ? null : AskPeriod.lastDays(n, now);
      case 'last_months':
        return n < 1 || n > 24 ? null : AskPeriod.lastMonths(n, now);
      case 'all':
        return AskPeriod.allTime(now);
    }
    return null;
  }
}

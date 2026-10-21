import 'dart:io';

import 'package:arth/ask/ask.dart';
import 'package:arth/core/models/category_defaults.dart';
import 'package:arth/core/result/result.dart';
import 'package:arth/llm/llama_cpp_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Accuracy of the model fallback on questions the parser can't read.
///
/// Skipped unless a real model and the desktop shim are available:
///   ARTH_MODEL_PATH=/path/gemma.gguf LD_LIBRARY_PATH=(dir of libarth_llm.so) \
///     flutter test test/ask/ask_model_eval_test.dart
class _Case {
  const _Case(
    this.q,
    this.intent, {
    this.category,
    this.merchant,
    this.from,
    this.to,
    this.n,
  });

  final String q;
  final Set<AskIntent> intent;
  final Set<String?>? category;
  final String? merchant;

  /// Expected period bounds (null = not checked).
  final DateTime? from;
  final DateTime? to;

  /// Expected days (upcoming) or months (average).
  final int? n;
}

void main() {
  final modelPath = Platform.environment['ARTH_MODEL_PATH'];
  final now = DateTime(2026, 10, 20, 14);
  final vocab = AskVocabulary(
    categoryNames: {for (final c in kDefaultCategories) c.slug: c.name},
    merchants: const [
      'starbucks coffee',
      'swiggy blr',
      'zomato',
      'uber india',
      'amazon pay',
      'netflix',
      'landlord',
      'indian oil',
    ],
  );
  final today1 = DateTime(2026, 10, 21);

  final cases = <_Case>[
    _Case(
      'what did dinner from outside cost me in july',
      {AskIntent.spend},
      category: {'food_delivery'},
      from: DateTime(2026, 7),
    ),
    _Case(
      'how much went on cabs and autos over the past fortnight',
      {AskIntent.spend},
      category: {'transport'},
      from: DateTime(2026, 10, 7),
      to: today1,
    ),
    _Case('am I burning more cash than I make lately', {AskIntent.savings}),
    _Case(
      'which shops ate most of my money this financial year',
      {AskIntent.topMerchants},
      from: DateTime(2026, 4),
    ),
    _Case(
      'how much did netflix charge me this year',
      {AskIntent.spend},
      merchant: 'netflix',
      from: DateTime(2026),
    ),
    _Case("what's my overall wealth right now", {AskIntent.netWorth}),
    _Case('am i overshooting my limits', {AskIntent.budgets}),
    _Case('any bills hitting my account in the next fortnight', {
      AskIntent.upcoming,
    }, n: 14),
    _Case(
      'when did I last fill petrol',
      {AskIntent.lastPaid},
      category: {'fuel'},
    ),
    _Case(
      'typical monthly outlay on groceries',
      {AskIntent.average},
      category: {'groceries'},
    ),
    _Case('biggest single purchase in august', {
      AskIntent.largest,
    }, from: DateTime(2026, 8)),
    _Case(
      'how much salary hit my account in september',
      {AskIntent.income},
      category: {'salary', null},
      from: DateTime(2026, 9),
    ),
    _Case(
      'how much did zomato take from me last month',
      {AskIntent.spend},
      merchant: 'zomato',
      from: DateTime(2026, 9),
    ),
    _Case(
      'how much have i given my landlord since the year began',
      {AskIntent.spend},
      merchant: 'landlord',
      from: DateTime(2026),
    ),
    _Case(
      'uber bill for the last ninety days',
      {AskIntent.spend},
      merchant: 'uber',
      from: DateTime(2026, 7, 23),
      to: today1,
    ),
    _Case(
      'how much interest did the bank give me this fy',
      {AskIntent.income},
      category: {'interest'},
      from: DateTime(2026, 4),
    ),
    _Case('did i put anything aside in august', {
      AskIntent.savings,
    }, from: DateTime(2026, 8)),
    _Case('where is all my money disappearing this month', {
      AskIntent.topCategories,
      AskIntent.topMerchants,
    }, from: DateTime(2026, 10)),
    _Case(
      'petrol costs across the whole of last year',
      {AskIntent.spend},
      category: {'fuel'},
      from: DateTime(2025),
      to: DateTime(2026),
    ),
    _Case(
      'how much did I fork out at starbucks in the past three months',
      {AskIntent.spend},
      merchant: 'starbucks',
      from: DateTime(2026, 7, 21),
      to: today1,
    ),
    _Case("what's coming up for payment this week", {AskIntent.upcoming}),
    _Case(
      'doctor and pharmacy bills in march',
      {AskIntent.spend},
      category: {'healthcare'},
      from: DateTime(2026, 3),
    ),
    _Case(
      'what do movies and ott cost me on a normal month',
      {AskIntent.average},
      category: {'entertainment'},
    ),
    _Case('how much came in overall last month', {
      AskIntent.income,
    }, from: DateTime(2026, 9)),
    _Case('which category ate the most cash in august', {
      AskIntent.topCategories,
    }, from: DateTime(2026, 8)),
  ];

  // Written after tuning and never tuned on: the honest score.
  final heldOut = <_Case>[
    _Case(
      'how much did eating out set me back in august',
      {AskIntent.spend},
      category: {'food_delivery'},
      from: DateTime(2026, 8),
    ),
    _Case('what am i worth on paper', {AskIntent.netWorth}),
    _Case('which payee got the most from me in september', {
      AskIntent.topMerchants,
    }, from: DateTime(2026, 9)),
    _Case('did my expenses exceed my earnings last month', {
      AskIntent.savings,
    }, from: DateTime(2026, 9)),
    _Case('what was the largest chunk i paid out this year', {
      AskIntent.largest,
    }, from: DateTime(2026)),
    _Case(
      'how much do i shell out on electricity monthly',
      {AskIntent.average},
      category: {'utilities'},
    ),
    _Case('any emis or subscriptions coming in the next ten days', {
      AskIntent.upcoming,
    }, n: 10),
    _Case(
      'last time i recharged my phone',
      {AskIntent.lastPaid},
      category: {'recharge'},
    ),
    _Case(
      'how much went to amazon pay in july',
      {AskIntent.spend},
      merchant: 'amazon pay',
      from: DateTime(2026, 7),
    ),
    _Case(
      'what did my medicines run me this year',
      {AskIntent.spend},
      category: {'healthcare'},
      from: DateTime(2026),
    ),
    _Case('am i within my spending limits', {AskIntent.budgets}),
    _Case('how much cash came in this fy', {
      AskIntent.income,
    }, from: DateTime(2026, 4)),
    _Case('break down my outgoings for september', {
      AskIntent.topCategories,
    }, from: DateTime(2026, 9)),
    _Case('what does swiggy cost me in a typical month', {
      AskIntent.average,
    }, merchant: 'swiggy'),
    _Case(
      'total fuel bill over the past 2 months',
      {AskIntent.spend},
      category: {'fuel'},
      from: DateTime(2026, 8, 21),
      to: today1,
    ),
    _Case(
      'how much went into my sips last year',
      {AskIntent.spend},
      category: {'investments_sip'},
      from: DateTime(2025),
      to: DateTime(2026),
    ),
    _Case('what did i splurge on most in july', {
      AskIntent.topCategories,
    }, from: DateTime(2026, 7)),
    _Case('was i in the green in september', {
      AskIntent.savings,
    }, from: DateTime(2026, 9)),
    _Case('when did i last order from zomato', {
      AskIntent.lastPaid,
    }, merchant: 'zomato'),
    _Case('my costliest uber ride', {AskIntent.largest}, merchant: 'uber'),
  ];

  test('model reads unusual questions', () async {
    if (modelPath == null) {
      markTestSkipped('set ARTH_MODEL_PATH to run');
      return;
    }
    final engine = LlamaCppEngine();
    final load = await engine.load(modelPath: modelPath);
    expect(load.errorOrNull, isNull);
    addTearDown(engine.dispose);
    final reader = AskModelReader(engine);
    final parser = AskParser(vocab);

    final out = StringBuffer();
    for (final (name, set) in [('tuning', cases), ('held out', heldOut)]) {
      var parserOk = 0, parserN = 0, modelOk = 0, modelN = 0;
      out.writeln('--- $name');
      for (final c in set) {
        final parsed = parser.parse(c.q, now);
        final sw = Stopwatch()..start();
        final r = parsed.query != null
            ? Ok<AskQuery>(parsed.query!)
            : await reader.read(c.q, parsed.partial!, vocab, now);
        sw.stop();
        final byParser = parsed.query != null;
        final problems = switch (r) {
          Err(:final message, :final cause) => ['rejected: $message $cause'],
          Ok(:final value) => _check(c, value),
        };
        if (byParser) {
          parserN++;
          if (problems.isEmpty) parserOk++;
        } else {
          modelN++;
          if (problems.isEmpty) modelOk++;
        }
        out.writeln(
          '${problems.isEmpty ? 'OK  ' : 'MISS'} ${byParser ? 'parser' : 'model '} '
          '${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)}s  ${c.q}'
          '${problems.isEmpty ? '' : '  → ${problems.join(', ')}'}',
        );
      }
      out.writeln(
        '$name — all: ${parserOk + modelOk}/${set.length}, '
        'parser: $parserOk/$parserN, model: $modelOk/$modelN',
      );
    }
    // ignore: avoid_print
    print(out);
  }, timeout: const Timeout(Duration(minutes: 30)));
}

List<String> _check(_Case c, AskQuery q) => [
  if (!c.intent.contains(q.intent)) 'intent ${q.intent}',
  if (c.category != null && !c.category!.contains(q.categorySlug))
    'category ${q.categorySlug}',
  if (c.merchant != q.merchant) 'merchant ${q.merchant}',
  if (c.from != null && q.period?.from != c.from) 'from ${q.period?.from}',
  if (c.to != null && q.period?.toExclusive != c.to)
    'to ${q.period?.toExclusive}',
  if (c.n != null &&
      (q.intent == AskIntent.upcoming ? q.days : q.months) != c.n)
    'n ${q.days}/${q.months}',
];

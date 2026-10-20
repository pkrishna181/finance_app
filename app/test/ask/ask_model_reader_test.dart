import 'dart:io';

import 'package:arth/ask/ask.dart';
import 'package:arth/core/models/category_defaults.dart';
import 'package:arth/core/result/result.dart';
import 'package:arth/insights/insight_models.dart';
import 'package:arth/llm/fake_llm_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20);
  final vocab = AskVocabulary(
    categoryNames: {for (final c in kDefaultCategories) c.slug: c.name},
    merchants: const ['starbucks coffee', 'swiggy blr'],
  );

  String json({
    String intent = 'spend',
    String category = '',
    String merchant = '',
    String period = 'this_month',
    String month = '',
    int n = 0,
  }) =>
      '{"intent":"$intent","category":"$category","merchant":"$merchant",'
      '"period":"$period","month":"$month","n":$n}';

  AskQuery ok(String j, [String question = 'q']) {
    final r = AskModelReader.validate(j, question, vocab, now);
    expect(r.errorOrNull, isNull);
    return r.okOrNull!;
  }

  String err(String j, [String question = 'q']) =>
      AskModelReader.validate(j, question, vocab, now).errorOrNull!;

  test('valid output becomes a query', () {
    final a = ok(
      json(category: 'food_delivery', period: 'month', month: '2026-08'),
    );
    expect(a.intent, AskIntent.spend);
    expect(a.categorySlug, 'food_delivery');
    expect(a.period, AskPeriod.month(const MonthKey(2026, 8)));

    final b = ok(
      json(merchant: 'Starbucks', period: 'last_months', n: 2),
      'how much did i blow at Starbucks lately',
    );
    expect(b.merchant, 'starbucks');
    expect(b.period!.from, DateTime(2026, 8, 21));

    expect(ok(json(intent: 'upcoming', period: 'all', n: 14)).days, 14);
    expect(ok(json(intent: 'average', n: 3)).months, 3);
    expect(ok(json(intent: 'net_worth')).period, isNull);
    expect(ok(json(period: 'this_fy')).period!.from, DateTime(2026, 4));
  });

  test('rejects what the model made up', () {
    expect(err('not json'), 'bad_json');
    expect(err(json(intent: 'gossip')), 'bad_intent');
    expect(err(json(category: 'crypto')), 'bad_category');
    expect(
      err(json(merchant: 'starbucks'), 'coffee spend'),
      'merchant_not_in_question',
    );
    expect(
      err(json(merchant: 'blue tokai'), 'spent at blue tokai'),
      'unknown_merchant',
    );
    expect(err(json(intent: 'last_paid')), 'nothing_to_look_for');
    expect(err(json(period: 'month', month: '2026-12')), 'bad_period');
    expect(err(json(period: 'month', month: '2026-13')), 'bad_period');
    expect(err(json(period: 'last_days', n: 0)), 'bad_period');
    expect(err(json(period: 'someday')), 'bad_period');
  });

  test('read sends the prompt and grammar to the engine', () async {
    final engine = FakeLlmEngine(jsonResponse: json(intent: 'savings'));
    await engine.load(modelPath: 'x');
    final r = await AskModelReader(engine).read('am i saving', vocab, now);
    expect(r.okOrNull!.intent, AskIntent.savings);
    expect(engine.lastPrompt, contains('Q: am i saving'));
    expect(engine.lastPrompt, contains('food_delivery (Food Delivery)'));
    expect(engine.lastGrammar, contains('"\\"food_delivery\\""'));
    expect(engine.lastGrammar, isNot(contains('uncategorized')));
  });

  test('engine errors pass through', () async {
    final engine = FakeLlmEngine(); // not loaded
    final r = await AskModelReader(engine).read('x', vocab, now);
    expect(r, isA<Err<AskQuery>>());
  });

  test('grammar parses with llama.cpp (when the desktop tool is built)', () {
    final root = Directory.current.path.endsWith('${Platform.pathSeparator}app')
        ? Directory.current.parent
        : Directory.current;
    final validator = File(
      '${root.path}/native/llama/build/desktop/grammar_validate',
    );
    if (!validator.existsSync()) {
      markTestSkipped('run native/llama/build_desktop.sh');
      return;
    }
    final dir = Directory.systemTemp.createTempSync('ask_gbnf');
    addTearDown(() => dir.deleteSync(recursive: true));
    final f = File('${dir.path}/ask.gbnf')
      ..writeAsStringSync(AskModelReader.grammar(vocab));
    final r = Process.runSync(validator.path, [f.path]);
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  });
}

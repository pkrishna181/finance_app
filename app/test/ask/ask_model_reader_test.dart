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
  final sep = AskPeriod.month(const MonthKey(2026, 9));

  String json(String intent, [String category = '']) =>
      '{"intent":"$intent","category":"$category"}';

  AskQuery ok(String j, [AskPartial partial = const AskPartial()]) {
    final r = AskModelReader.validate(j, partial, vocab, now);
    expect(r.errorOrNull, isNull);
    return r.okOrNull!;
  }

  String err(String j, [AskPartial partial = const AskPartial()]) =>
      AskModelReader.validate(j, partial, vocab, now).errorOrNull!;

  test('model picks the intent and category; dates come from the parser', () {
    final a = ok(json('spend', 'food_delivery'), AskPartial(period: sep));
    expect(a.intent, AskIntent.spend);
    expect(a.categorySlug, 'food_delivery');
    expect(a.period, sep);

    final b = ok(json('top_merchants'));
    expect(b.period, AskPeriod.month(const MonthKey(2026, 10), now: now));
    expect(ok(json('net_worth')).period, isNull);
    expect(ok(json('upcoming'), const AskPartial(days: 14)).days, 14);
  });

  test('the parser outranks the model where it found something', () {
    // Category named in the question beats the model's.
    final a = ok(
      json('spend', 'groceries'),
      const AskPartial(categorySlug: 'fuel'),
    );
    expect(a.categorySlug, 'fuel');
    // A specific keyword beats the model's intent; generic "spend" doesn't.
    expect(
      ok(
        json('upcoming'),
        const AskPartial(intent: AskIntent.lastPaid, categorySlug: 'fuel'),
      ).intent,
      AskIntent.lastPaid,
    );
    expect(
      ok(
        json('average', 'groceries'),
        const AskPartial(intent: AskIntent.spend),
      ).intent,
      AskIntent.average,
    );
    // An income category turns spend / savings into income.
    final i = ok(json('savings'), const AskPartial(categorySlug: 'interest'));
    expect(i.intent, AskIntent.income);
    expect(i.categorySlug, 'interest');
  });

  test('fields that do not fit the intent are dropped', () {
    expect(ok(json('net_worth', 'rent')).categorySlug, isNull);
    expect(ok(json('income', 'groceries')).categorySlug, isNull);
    const swiggy = AskPartial(merchant: 'swiggy');
    expect(ok(json('spend'), swiggy).merchant, 'swiggy');
    expect(ok(json('top_categories'), swiggy).merchant, isNull);
  });

  test('rejects malformed output', () {
    expect(err('not json'), 'bad_json');
    expect(err('[1]'), 'bad_json');
    expect(err(json('gossip')), 'bad_intent');
    expect(err(json('spend', 'crypto')), 'bad_category');
    expect(err(json('last_paid')), 'nothing_to_look_for');
  });

  test('read sends the prompt and grammar to the engine', () async {
    final engine = FakeLlmEngine(jsonResponse: json('savings'));
    await engine.load(modelPath: 'x');
    final r = await AskModelReader(
      engine,
    ).read('am i saving', const AskPartial(), vocab, now);
    expect(r.okOrNull!.intent, AskIntent.savings);
    expect(engine.lastPrompt, contains('Q: am i saving'));
    expect(engine.lastPrompt, contains('food_delivery (Food Delivery)'));
    expect(engine.lastGrammar, contains('"\\"food_delivery\\""'));
    expect(engine.lastGrammar, isNot(contains('uncategorized')));
  });

  test('engine errors pass through', () async {
    final r =
        await AskModelReader(FakeLlmEngine()) // not loaded
            .read('x', const AskPartial(), vocab, now);
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

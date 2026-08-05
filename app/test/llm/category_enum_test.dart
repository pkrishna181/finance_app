import 'package:flutter_test/flutter_test.dart';

import 'package:arth/llm/fake_llm_engine.dart';
import 'package:arth/llm/parsed_transaction_validator.dart';

void main() {
  test('invalid category slug rejected by validator path', () {
    const validator = ParsedTransactionJsonValidator();
    const badTypeJson =
        '{"a":"Rs.1.00","d":"01-08-26","t":null,"y":"imps/p2a","r":"debit",'
        '"m":null,"f":null,"v":null}';
    final v = validator.validate(badTypeJson, sourceSms: 'Rs.1.00 on 01-08-26');
    expect(v.isErr, isTrue);
    expect(v.errorOrNull, 'invalid_type');
  });

  test('FakeLlmEngine bad category JSON fails enum validation', () async {
    final engine = FakeLlmEngine(
      jsonResponse: '{"category":"not_a_real_slug","confidence":0.9}',
    );
    await engine.load(modelPath: 'fake');
    final r = await engine.completeJson(prompt: 'x', gbnfGrammar: 'root ::= object');
    expect(r.isOk, isTrue);
    expect(r.okOrNull!.contains('not_a_real_slug'), isTrue);
  });
}

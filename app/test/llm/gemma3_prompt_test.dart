import 'package:arth/llm/prompts/gemma3_chat.dart';
import 'package:arth/llm/prompts/sms_parse_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gemma3Chat', () {
    test('formatUserTurn wraps user content', () {
      final prompt = Gemma3Chat.formatUserTurn('Hello');
      expect(
        prompt,
        '<start_of_turn>user\nHello\n<end_of_turn>\n<start_of_turn>model\n',
      );
    });

    test('isFormatted detects existing turns', () {
      expect(Gemma3Chat.isFormatted(Gemma3Chat.formatUserTurn('x')), isTrue);
      expect(Gemma3Chat.isFormatted('plain prompt'), isFalse);
    });
  });

  group('SmsParsePrompt', () {
    test('prefix stays under 600 token budget', () {
      expect(SmsParsePrompt.prefixTokenEstimate, lessThan(600));
    });

    test('buildUserContent includes span-schema few-shot examples', () {
      const sms = 'Rs.10 debited';
      final content = SmsParsePrompt.buildUserContent(sms);
      expect(content, contains('VERBATIM txn amount'));
      expect(content, contains('"a":"Rs.275.00"'));
      expect(content, contains('"a":"INR 87.30"'));
      expect(content, contains('"r":"credit"'));
      expect(content, contains('Dr INR 87.30'));
      expect(content, isNot(contains('dedupe_key')));
      expect(content, isNot(contains('bank_code')));
      expect(content, contains(sms));
    });

    test('buildBenchmarkUserContent is shorter', () {
      const sms = 'test sms';
      final content = SmsParsePrompt.buildBenchmarkUserContent(sms);
      expect(content, contains('span SMS txn JSON'));
      expect(content, contains(sms));
      expect(content, isNot(contains('Example SMS:')));
    });
  });
}

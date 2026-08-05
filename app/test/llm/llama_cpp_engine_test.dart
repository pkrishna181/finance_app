import 'package:arth/llm/llama_cpp_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stripMarkdownJsonFence removes fences', () {
    const raw = '```json\n{"a":1}\n```';
    expect(LlamaCppEngine.stripMarkdownJsonFence(raw), '{"a":1}');
  });

  test('stripMarkdownJsonFence leaves plain JSON', () {
    const raw = '{"a":1}';
    expect(LlamaCppEngine.stripMarkdownJsonFence(raw), raw);
  });
}

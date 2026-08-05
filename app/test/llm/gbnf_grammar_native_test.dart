import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Parses every repo GBNF through llama.cpp on desktop (native/llama/validate_grammars.sh).
///
/// Skipped when [grammar_validate] is not built — run `native/llama/build_desktop.sh`.
void main() {
  test('all GBNF files parse via llama.cpp grammar parser', () {
    final repoRoot = Directory.current.path.endsWith('${Platform.pathSeparator}app')
        ? Directory.current.parent
        : Directory.current;
    final script = File('${repoRoot.path}/native/llama/validate_grammars.sh');
    final validator = File('${repoRoot.path}/native/llama/build/desktop/grammar_validate');

    if (!script.existsSync() || !validator.existsSync()) {
      // ignore: avoid_print
      print('SKIP gbnf native test — run native/llama/build_desktop.sh first');
      return;
    }

    final result = Process.runSync(
      'bash',
      [script.path],
      workingDirectory: '${repoRoot.path}/native/llama',
    );

    expect(
      result.exitCode,
      0,
      reason: '${result.stdout}\n${result.stderr}',
    );
    expect(result.stdout.toString(), contains('OK'));
  });
}

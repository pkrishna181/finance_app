import 'dart:convert';
import 'dart:io';

import 'package:arth/parsing/sms/regex_sms_parser.dart';

void main() {
  final dir = Directory('../test/golden/sms');
  if (!dir.existsSync()) {
    throw StateError('golden sms dir missing');
  }
  final parser = RegexSmsParser();
  for (final sms in dir.listSync().whereType<File>().where((f) => f.path.endsWith('.sms.txt'))) {
    final body = sms.readAsStringSync().trim();
    final metaFile = File(sms.path.replaceAll('.sms.txt', '.meta.json'));
    String? sender;
    if (metaFile.existsSync()) {
      final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
      sender = meta['sender'] as String?;
    }
    final parsed = parser.parse(body: body, sender: sender).okOrNull!.single;
    final out = File(sms.path.replaceAll('.sms.txt', '.expected.json'));
    out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(parsed.toJson()));
    print('Updated ${out.path}');
  }
}

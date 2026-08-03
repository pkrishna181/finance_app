import 'dart:convert';
import 'dart:io';

import 'package:arth/core/models/parsed_transaction.dart';
import 'package:arth/parsing/sms/regex_sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden-file harness for SMS parsing against [RegexSmsParser].
void main() {
  final parser = RegexSmsParser();

  final dir = _goldenDir();
  final smsFiles = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sms.txt'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('golden suite has at least 29 fixtures', () {
    expect(smsFiles.length, greaterThanOrEqualTo(29));
  });

  for (final smsFile in smsFiles) {
    final name = smsFile.uri.pathSegments.last.replaceAll('.sms.txt', '');
    test('golden SMS: $name', () {
      final expectedFile = File(
        smsFile.path.replaceAll('.sms.txt', '.expected.json'),
      );
      expect(expectedFile.existsSync(), isTrue,
          reason: 'missing ${expectedFile.path}');

      final body = smsFile.readAsStringSync().trim();
      final expectedJson =
          jsonDecode(expectedFile.readAsStringSync()) as Map<String, dynamic>;
      final expected = ParsedTransaction.fromJson(
        Map<String, Object?>.from(expectedJson),
      );

      final metaFile = File(
        smsFile.path.replaceAll('.sms.txt', '.meta.json'),
      );
      String? sender;
      if (metaFile.existsSync()) {
        final meta =
            jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
        sender = meta['sender'] as String?;
      }

      final result = parser.parse(body: body, sender: sender);
      expect(result.isOk, isTrue, reason: result.errorOrNull);
      result.when(
        ok: (parsed) {
          expect(parsed, hasLength(1), reason: name);
          expect(parsed.single.toJson(), equals(expected.toJson()));
        },
        err: (msg, cause) => fail('$name failed: $msg $cause'),
      );
    });
  }

  test('OTP SMS is skipped (empty ok)', () {
    final result = parser.parse(body: 'Your OTP is 123456. Do not share.');
    expect(result.isOk, isTrue);
    expect(result.okOrNull, isEmpty);
  });

  test('promotional DLT sender (P suffix) is skipped', () {
    final result = parser.parse(
      body: 'HDFC Bank: Get 10% cashback on weekends. Apply now!',
      sender: 'JD-HDFCBK-P',
    );
    expect(result.isOk, isTrue);
    expect(result.okOrNull, isEmpty);
  });
}

Directory _goldenDir() {
  final candidates = [
    Directory('../test/golden/sms'),
    Directory('test/golden/sms'),
  ];
  for (final d in candidates) {
    if (d.existsSync()) return d;
  }
  fail('Golden dir not found (cwd=${Directory.current.path})');
}

import 'dart:convert';
import 'dart:io';

import 'package:arth/core/result/result.dart';
import 'package:arth/parsing/sms/regex_sms_parser.dart';
import 'package:arth/parsing/sms/sender_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parser coverage on a real inbox dump. Skipped unless ARTH_SMS_DUMP points
/// at a JSON-lines file of {address, date, body}; the report (which quotes
/// message bodies) goes to ARTH_SMS_REPORT. Neither belongs in the repo.
///
///   ARTH_SMS_DUMP=inbox.jsonl ARTH_SMS_REPORT=report.txt \
///     flutter test test/parsing/real_sms_coverage_test.dart
final _money = RegExp(r'(?:rs\.?|inr|₹)\s*[\d,]+', caseSensitive: false);
final _moved = RegExp(
  r'\b(debited|credited|spent|withdrawn|sent|received|paid|transferred|'
  r'debit|credit|purchase|txn|transaction)\b',
  caseSensitive: false,
);

bool looksLikeTxn(String body) =>
    _money.hasMatch(body) && _moved.hasMatch(body);

void main() {
  final dump = Platform.environment['ARTH_SMS_DUMP'];
  final reportPath = Platform.environment['ARTH_SMS_REPORT'];

  test('real inbox coverage', () {
    if (dump == null || reportPath == null) {
      markTestSkipped('set ARTH_SMS_DUMP and ARTH_SMS_REPORT to run');
      return;
    }
    final parser = RegexSmsParser();
    final rows = File(dump)
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty)
        .map((l) => jsonDecode(l) as Map<String, dynamic>);

    // entity → [scanned, parsed, nonTxn, err, missedTxnLooking]
    final stats = <String, List<int>>{};
    final samples = <String, List<String>>{};
    void sample(String key, String line) {
      final list = samples.putIfAbsent(key, () => []);
      if (list.length < 40) list.add(line);
    }

    final known = knownSenderEntities;
    for (final r in rows) {
      final address = '${r['address']}';
      final body = '${r['body']}';
      final match = matchSender(address);
      final upper = address.toUpperCase();
      final scanned = known.any(upper.contains);
      final s = stats.putIfAbsent(match.entity, () => List.filled(6, 0));
      if (!scanned) {
        if (looksLikeTxn(body)) {
          s[5]++;
          sample('NOT SCANNED ${match.entity}', body);
        }
        continue;
      }
      s[0]++;
      final res = parser.parse(
        body: body,
        sender: address,
        receivedAt: DateTime.fromMillisecondsSinceEpoch(r['date'] as int),
      );
      switch (res) {
        case Ok(:final value) when value.isNotEmpty:
          s[1]++;
          final t = value.first;
          sample(
            'PARSED ${match.entity}',
            '${t.direction.name} ${t.amountPaise} ${t.type.name} '
                'm=${t.rawMerchant} acct=${t.accountHint} | $body',
          );
        case Ok():
          s[2]++;
          if (looksLikeTxn(body)) {
            s[4]++;
            sample('SILENT MISS ${match.entity}', body);
          }
        case Err(:final message):
          s[3]++;
          sample('ERR ${match.entity}', '$message | $body');
      }
    }

    final out = StringBuffer()
      ..writeln('entity  scanned parsed nonTxn err silentMiss notScannedTxn');
    final keys = stats.keys.toList()
      ..sort(
        (a, b) => (stats[b]![0] + stats[b]![5]).compareTo(
          stats[a]![0] + stats[a]![5],
        ),
      );
    for (final k in keys) {
      final s = stats[k]!;
      if (s[0] == 0 && s[5] == 0) continue;
      out.writeln('$k  ${s.join(' ')}');
    }
    for (final e in samples.entries) {
      out
        ..writeln('\n=== ${e.key}')
        ..writeAll(e.value.map((b) => '- ${b.replaceAll('\n', ' ')}'), '\n')
        ..writeln();
    }
    File(reportPath).writeAsStringSync(out.toString());
  }, timeout: const Timeout(Duration(minutes: 10)));
}

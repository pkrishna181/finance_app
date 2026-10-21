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
final _money = RegExp(
  r'(?:rs\.?|inr|₹)\s*[\d,]+|\b(?:debited|credited) (?:by|with) [\d,]+',
  caseSensitive: false,
);
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

    // bank → counters
    final stats = <String, Map<String, int>>{};
    final skips = <String, int>{};
    final samples = <String, List<String>>{};
    void sample(String key, String line) {
      final list = samples.putIfAbsent(key, () => []);
      if (list.length < 60) list.add(line);
    }

    final known = knownSenderEntities;
    for (final r in rows) {
      final address = '${r['address']}';
      final body = '${r['body']}';
      final match = matchSender(address);
      final upper = address.toUpperCase();
      final bank = match.bankCode == 'UNKNOWN' ? match.entity : match.bankCode;
      final s = stats.putIfAbsent(bank, () => {});
      void count(String k) => s[k] = (s[k] ?? 0) + 1;
      if (!known.any(upper.contains)) {
        if (looksLikeTxn(body)) {
          count('notScanned');
          sample('NOT SCANNED $bank', body);
        }
        continue;
      }
      if (!match.isTransactional) {
        count('promoSender');
        continue;
      }
      count('scanned');
      final res = parser.parseDetailed(
        body: body,
        sender: address,
        receivedAt: DateTime.fromMillisecondsSinceEpoch(r['date'] as int),
      );
      switch (res) {
        case Ok(:final value) when value.transactions.isNotEmpty:
          count('txn');
          final t = value.transactions.first;
          sample(
            'TXN $bank',
            '${t.direction.name} ${t.amountPaise / 100} ${t.type.name} '
                '${t.bookedAt.toIso8601String().substring(0, 16)} '
                'm=${t.rawMerchant} acct=${t.accountHint} ref=${t.externalRef} '
                'bal=${t.balanceAfterPaise} | $body',
          );
        case Ok(:final value) when value.hasMandate:
          count('mandate');
          sample('MANDATE $bank', body);
        case Ok(:final value):
          count('skipped');
          final why = value.skippedReason ?? '?';
          skips[why] = (skips[why] ?? 0) + 1;
          if (looksLikeTxn(body)) sample('SKIPPED $why', body);
        case Err():
          count('unparsed');
          sample('UNPARSED $bank', body);
      }
    }

    const cols = [
      'scanned',
      'txn',
      'mandate',
      'skipped',
      'unparsed',
      'promoSender',
      'notScanned',
    ];
    int total(String k) =>
        (stats[k]!['scanned'] ?? 0) + (stats[k]!['notScanned'] ?? 0);
    final out = StringBuffer()..writeln('bank  ${cols.join(' ')}');
    final keys = stats.keys.toList()
      ..sort((a, b) => total(b).compareTo(total(a)));
    for (final k in keys) {
      if (total(k) == 0) continue;
      out.writeln('$k  ${cols.map((c) => stats[k]![c] ?? 0).join(' ')}');
    }
    out.writeln('skip reasons: $skips');
    for (final e in samples.entries) {
      out
        ..writeln('\n=== ${e.key}')
        ..writeAll(e.value.map((b) => '- ${b.replaceAll('\n', ' ')}'), '\n')
        ..writeln();
    }
    File(reportPath).writeAsStringSync(out.toString());
  }, timeout: const Timeout(Duration(minutes: 10)));
}

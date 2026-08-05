import 'package:arth/llm/parsed_transaction_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const v = ParsedTransactionJsonValidator();

  const sourceSms =
      'Rs.275.00 debited for UPI Ref 812233445566 to shop@ybl on 01-08-26.';

  const compactJson =
      '{"a":"Rs.275.00","d":"01-08-26","t":null,"y":"upi","r":"debit",'
      '"m":"shop@ybl","f":"812233445566","v":"shop@ybl"}';

  test('accepts span-schema minified extraction JSON', () {
    final r = v.validate(compactJson, sourceSms: sourceSms);
    expect(r.isOk, isTrue);
    final txn = r.okOrNull!;
    expect(txn.amountPaise.paise, 27500);
    expect(txn.rawDescription, sourceSms);
    expect(txn.dedupeKey, contains('812233445566'));
    expect(txn.bankCode, 'UNKNOWN');
  });

  test('compact path computes dedupe_key — never reads from JSON', () {
    final withFakeDedupe =
        '{"a":"Rs.275.00","d":"01-08-26","t":null,"y":"upi","r":"debit",'
        '"m":"shop@ybl","f":"812233445566","v":"shop@ybl","dedupe_key":"evil"}';
    final r = v.validate(withFakeDedupe, sourceSms: sourceSms);
    expect(r.errorOrNull, 'unexpected_compact_key');
  });

  test('rejects integer amount (paise arithmetic structurally impossible)', () {
    final json =
        '{"a":27500,"d":"01-08-26","t":null,"y":"upi","r":"debit",'
        '"m":null,"f":null,"v":null}';
    expect(
      v.validate(json, sourceSms: sourceSms).errorOrNull,
      'invalid_amount_span',
    );
  });

  test('accepts Rs. variant when source has Rs space', () {
    const sms =
        'Dr Rs 1,499.00 from HDFC on 30Jul26 IMPS ref 637890999888';
    const json =
        '{"a":"Rs.1,499.00","d":"30Jul26","t":null,"y":"imps","r":"debit",'
        '"m":null,"f":null,"v":null}';
    expect(v.validate(json, sourceSms: sms).isOk, isTrue);
  });

  test('rejects amount span not in source', () {
    final json =
        '{"a":"Rs.999.00","d":"01-08-26","t":null,"y":"upi","r":"debit",'
        '"m":null,"f":null,"v":null}';
    expect(
      v.validate(json, sourceSms: sourceSms).errorOrNull,
      'amount_span_not_in_source',
    );
  });

  test('rejects unparseable amount span', () {
    const sms = 'paid foo bar on 01-08-26';
    final json =
        '{"a":"foo bar","d":"01-08-26","t":null,"y":"upi","r":"debit",'
        '"m":null,"f":null,"v":null}';
    expect(v.validate(json, sourceSms: sms).errorOrNull, 'invalid_amount_span');
  });

  test('rejects bad type enum', () {
    final json =
        '{"a":"Rs.1.00","d":"01-08-26","t":null,"y":"wire","r":"debit",'
        '"m":null,"f":null,"v":null}';
    expect(
      v.validate(json, sourceSms: 'Rs.1.00 on 01-08-26').errorOrNull,
      'invalid_type',
    );
  });

  test('rejects truncated JSON', () {
    expect(v.validate('{"a":"1').errorOrNull, 'json_parse_failed');
  });

  test('domain JSON path for review confirm still works', () {
    final json =
        '{"amount_paise":125000,"direction":"debit","type":"upi",'
        '"booked_at":"2026-07-01T00:00:00.000Z","bank_code":"HDFC",'
        '"raw_merchant":"m","raw_description":"d","dedupe_key":"k"}';
    expect(v.validate(json).isOk, isTrue);
  });

  group('held-out SMS span fixtures', () {
    const sms1 =
        'Acct XX4821 debited INR 87.30 on 29-JUL-26 UPI/412399887766/zomato@paytm FOOD. Avl Bal INR 12,034.55';
    const sms2 =
        'IMPS/P2A/637890999888/FLIPKART INDIA credited? No — Dr Rs 1,499.00 from HDFC A/c **4821 on 30Jul26';
    const sms3 =
        'NEFT CR-ACME CORP-SBIN998877665544-BONUS Rs.25,000.00 credited to A/c XXXX9012 on 31-07-2026';

    const fixtures = {
      sms1:
          '{"a":"INR 87.30","d":"29-JUL-26","t":null,"y":"upi","r":"debit","m":"zomato@paytm","f":"412399887766","v":"zomato@paytm"}',
      sms2:
          '{"a":"Rs 1,499.00","d":"30Jul26","t":null,"y":"imps","r":"debit","m":"FLIPKART INDIA","f":"637890999888","v":null}',
      sms3:
          '{"a":"Rs.25,000.00","d":"31-07-2026","t":null,"y":"neft","r":"credit","m":"ACME CORP","f":"998877665544","v":null}',
    };

    for (final entry in fixtures.entries) {
      test('validator OK for fixture (${entry.key.substring(0, 12)}…)', () {
        final json = entry.value;
        final est = ParsedTransactionJsonValidator.estimateOutputTokens(json);
        expect(est, lessThan(96), reason: 'fixture should finish under cap');
        final r = v.validate(json, sourceSms: entry.key, sender: 'SBINB');
        expect(r.isOk, isTrue, reason: r.errorOrNull);
      });
    }

    test('SMS3 wrong amount span not in source (no paise arithmetic)', () {
      const bad =
          '{"a":"25000","d":"31-07-2026","t":null,"y":"neft","r":"credit",'
          '"m":"ACME CORP","f":null,"v":null}';
      expect(
        v.validate(bad, sourceSms: sms3).errorOrNull,
        'amount_span_not_in_source',
      );
    });

    test('SMS3 correct span yields 2500000 paise', () {
      const good =
          '{"a":"Rs.25,000.00","d":"31-07-2026","t":null,"y":"neft","r":"credit",'
          '"m":"ACME CORP","f":null,"v":null}';
      final r = v.validate(good, sourceSms: sms3);
      expect(r.okOrNull!.amountPaise.paise, 2500000);
    });
  });
}

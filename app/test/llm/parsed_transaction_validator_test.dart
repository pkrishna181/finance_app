import 'package:arth/llm/parsed_transaction_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const v = ParsedTransactionJsonValidator();

  Map<String, Object?> valid() => {
        'amount_paise': 125000,
        'direction': 'debit',
        'type': 'upi',
        'booked_at': '2026-07-01T00:00:00.000Z',
        'bank_code': 'HDFC',
        'raw_merchant': 'merchant@okhdfcbank',
        'raw_description': 'UPI/412345678901/merchant@okhdfcbank/FOOD',
        'dedupe_key': 'abc123',
        'direction_inferred': false,
      };

  test('accepts valid ParsedTransaction JSON', () {
    final json =
        '{"amount_paise":125000,"direction":"debit","type":"upi",'
        '"booked_at":"2026-07-01T00:00:00.000Z","bank_code":"HDFC",'
        '"raw_merchant":"m","raw_description":"d","dedupe_key":"k"}';
    expect(v.validate(json).isOk, isTrue);
  });

  test('rejects string amount', () {
    final m = valid();
    m['amount_paise'] = '125000';
    final json = _encode(m);
    expect(v.validate(json).errorOrNull, 'invalid_amount_paise');
  });

  test('rejects bad enum', () {
    final m = valid();
    m['type'] = 'wire_transfer';
    expect(v.validate(_encode(m)).errorOrNull, 'invalid_type');
  });

  test('rejects truncated JSON', () {
    expect(v.validate('{"amount_paise":1').errorOrNull, 'json_parse_failed');
  });
}

String _encode(Map<String, Object?> m) {
  final parts = m.entries.map((e) => '"${e.key}":${_val(e.value)}');
  return '{${parts.join(',')}}';
}

String _val(Object? v) {
  if (v is String) return '"$v"';
  if (v is bool) return v ? 'true' : 'false';
  return '$v';
}

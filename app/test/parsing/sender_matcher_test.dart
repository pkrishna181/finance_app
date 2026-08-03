import 'package:arth/parsing/sms/sender_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DLT XX-ENTITY-C transactional', () {
    final m = matchSender('VM-HDFCBK-T');
    expect(m.entity, 'HDFCBK');
    expect(m.category, 'T');
    expect(m.bankCode, 'HDFC');
    expect(m.isTransactional, isTrue);
  });

  test('P suffix is non-transactional', () {
    final m = matchSender('JD-SBIUPI-P');
    expect(m.bankCode, 'SBI');
    expect(m.isTransactional, isFalse);
  });

  test('service suffix still allowed through sender filter', () {
    final m = matchSender('AD-ICICIB-S');
    expect(m.bankCode, 'ICICI');
    expect(m.isTransactional, isTrue);
  });

  test('unknown entity maps UNKNOWN', () {
    final m = matchSender('XX-FOOBAR-T');
    expect(m.bankCode, 'UNKNOWN');
    expect(m.entity, 'FOOBAR');
  });
}

import 'package:arth/parsing/sms/regex_sms_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = RegexSmsParser();

  test('mandate notice is captured, not dropped', () {
    final result = parser.parseDetailed(
      body:
          'Your A/c XX1234 will be debited with Rs.1,999.00 on 10-08-26 towards NETFLIX mandate. HDFC Bank',
      sender: 'VM-HDFCBK-T',
    );
    expect(result.isOk, isTrue);
    final success = result.okOrNull!;
    expect(success.hasMandate, isTrue);
    expect(success.mandate!.bankCode, 'HDFC');
    expect(success.mandate!.amountPaise?.paise, 199900);
    expect(success.transactions, isEmpty);
  });

  test('EMI reminder skipped as noise', () {
    final result = parser.parse(
      body: 'EMI due reminder: Rs.5,000.00 for your loan A/c XX1234 is due on 05-08-26.',
    );
    expect(result.isOk, isTrue);
    expect(result.okOrNull, isEmpty);
  });
}

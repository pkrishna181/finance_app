import 'package:flutter_test/flutter_test.dart';

import 'package:arth/llm/anchoring.dart';
import 'package:arth/llm/parsed_transaction_validator.dart';

void main() {
  const sms1 =
      'Acct XX4821 debited INR 87.30 on 29-JUL-26 UPI/412399887766/zomato@paytm FOOD. Avl Bal INR 12,034.55';
  const sms2 =
      'IMPS/P2A/637890999888/FLIPKART INDIA credited? No — Dr Rs 1,499.00 from HDFC A/c **4821 on 30Jul26';
  const sms3 =
      'NEFT CR-ACME CORP-SBIN998877665544-BONUS Rs.25,000.00 credited to A/c XXXX9012 on 31-07-2026';

  test('SMS1 demotes balance-text merchant', () {
    final llm = {
      'amount_paise': 8730,
      'direction': 'debit',
      'type': 'upi',
      'booked_at': '2026-07-29T00:00:00.000Z',
      'bank_code': 'UNKNOWN',
      'raw_merchant': 'Avl Bal INR 12,034.55',
      'raw_description': sms1,
      'dedupe_key': 'unknown|8730|412399887766',
    };
    final r = validateAgainstSource(sms1, llm);
    final merchant = r.report.fields.firstWhere((f) => f.field == 'raw_merchant');
    expect(merchant.status, AnchorFieldStatus.demote);
    expect(r.cleaned['raw_merchant'], '');
  });

  test('SMS3 overrides BONUS bank_code from LLM', () {
    final llm = {
      'amount_paise': 2500000,
      'direction': 'credit',
      'type': 'neft',
      'booked_at': '2026-07-31T00:00:00.000Z',
      'bank_code': 'BONUS',
      'raw_merchant': 'ACME CORP',
      'raw_description': sms3,
      'dedupe_key': 'unknown|2500000|8877665544',
    };
    final r = validateAgainstSource(sms3, llm, sender: 'SBINB');
    final bank = r.report.fields.firstWhere((f) => f.field == 'bank_code');
    expect(bank.status, AnchorFieldStatus.override);
    expect(r.cleaned['bank_code'], isNot('BONUS'));
  });

  test('SMS2 rejects contradicted credit direction', () {
    final llm = {
      'amount_paise': 149900,
      'direction': 'credit',
      'type': 'imps',
      'booked_at': '2026-07-30T00:00:00.000Z',
      'bank_code': 'HDFC',
      'raw_merchant': 'FLIPKART INDIA',
      'raw_description': sms2,
      'dedupe_key': '637890999888|149900|HDFC',
    };
    final r = validateAgainstSource(sms2, llm);
    final dir = r.report.fields.firstWhere((f) => f.field == 'direction');
    expect(dir.status, AnchorFieldStatus.reject);
    expect(r.cleaned.containsKey('direction'), isFalse);
    expect(r.report.allCriticalPassed, isFalse);
  });

  group('span extraction → anchor (Phase 4 bad outputs)', () {
    const v = ParsedTransactionJsonValidator();

    test('SMS1 balance merchant demoted after span validate', () {
      const badJson =
          '{"a":"INR 87.30","d":"29-JUL-26","t":null,"y":"upi","r":"debit",'
          '"m":"Avl Bal INR 12,034.55","f":"412399887766","v":"zomato@paytm"}';
      final txn = v.validate(badJson, sourceSms: sms1).okOrNull!;
      final r = validateAgainstSource(sms1, txn.toJson());
      final merchant =
          r.report.fields.firstWhere((f) => f.field == 'raw_merchant');
      expect(merchant.status, AnchorFieldStatus.demote);
    });

    test('SMS2 wrong credit rejected after span validate', () {
      const badJson =
          '{"a":"Rs 1,499.00","d":"30Jul26","t":null,"y":"imps","r":"credit",'
          '"m":"FLIPKART INDIA","f":"637890999888","v":null}';
      final txn = v.validate(badJson, sourceSms: sms2).okOrNull!;
      final r = validateAgainstSource(sms2, txn.toJson());
      expect(r.report.allCriticalPassed, isFalse);
    });

    test('SMS3 amount span parses to 2500000 not wrong integer', () {
      const goodJson =
          '{"a":"Rs.25,000.00","d":"31-07-2026","t":null,"y":"neft","r":"credit",'
          '"m":"ACME CORP","f":"998877665544","v":null}';
      final txn =
          v.validate(goodJson, sourceSms: sms3, sender: 'SBINB').okOrNull!;
      expect(txn.amountPaise.paise, 2500000);
      expect(txn.bankCode, isNot('BONUS'));
      final r = validateAgainstSource(sms3, txn.toJson(), sender: 'SBINB');
      final bank = r.report.fields.firstWhere((f) => f.field == 'bank_code');
      expect(bank.status, AnchorFieldStatus.override);
    });
  });
}

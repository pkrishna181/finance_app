import 'package:flutter_test/flutter_test.dart';

import 'package:arth/core/db/database.dart';
import 'package:arth/llm/anchoring.dart';
import 'package:arth/llm/llm_disagreement_recorder.dart';
import 'package:arth/llm/merchant_seed_catalog.dart';
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

  test('routes VPA in merchant slot to v and seed hint', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final seeds = await MerchantSeedCatalog.load();
    final llm = {
      'amount_paise': 8730,
      'direction': 'debit',
      'type': 'upi',
      'booked_at': '2026-07-29T00:00:00.000Z',
      'bank_code': 'UNKNOWN',
      'raw_merchant': 'zomato@paytm',
      'raw_description': sms1,
      'upi_ref': '412399887766',
      'dedupe_key': 'unknown|8730|412399887766',
    };
    final r = validateAgainstSource(sms1, llm, merchantSeeds: seeds);
    expect(r.cleaned['upi_payee_vpa'], 'zomato@paytm');
    expect(r.cleaned['raw_merchant'], 'Zomato');
    expect(
      r.report.fields.firstWhere((f) => f.field == 'raw_merchant').status,
      AnchorFieldStatus.override,
    );
    expect(
      formatAnchorVerdictLine(r.report, r.cleaned),
      'anchor: usable',
    );
  });

  test('routes VPA without seeds uses local part as merchant hint', () {
    final llm = {
      'amount_paise': 8730,
      'direction': 'debit',
      'type': 'upi',
      'booked_at': '2026-07-29T00:00:00.000Z',
      'bank_code': 'UNKNOWN',
      'raw_merchant': 'zomato@paytm',
      'raw_description': sms1,
      'upi_ref': '412399887766',
      'dedupe_key': 'unknown|8730|412399887766',
    };
    final r = validateAgainstSource(sms1, llm);
    expect(r.cleaned['upi_payee_vpa'], 'zomato@paytm');
    expect(r.cleaned['raw_merchant'], 'zomato');
    expect(
      formatAnchorVerdictLine(r.report, r.cleaned),
      'anchor: usable',
    );
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

  test('SMS2 overrides contradicted credit direction via Dr cue', () {
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
    expect(dir.status, AnchorFieldStatus.override);
    expect(r.cleaned['direction'], 'debit');
    expect(r.cleaned['direction_inferred'], isFalse);
    expect(r.report.allCriticalPassed, isTrue);
    expect(
      formatAnchorVerdictLine(r.report, r.cleaned),
      'anchor: usable (direction: overridden)',
    );
  });

  group('Phase 5.4 shape gates (device verbatim)', () {
    test('v:BONUS dropped — not a VPA shape', () {
      final llm = {
        'amount_paise': 2500000,
        'direction': 'credit',
        'type': 'neft',
        'booked_at': '2026-07-31T00:00:00.000Z',
        'bank_code': 'SBI',
        'raw_merchant': 'ACME CORP',
        'raw_description': sms3,
        'upi_payee_vpa': 'BONUS',
        'external_ref': 'SBIN998877665544',
        'dedupe_key': 'unknown|2500000|SBIN998877665544',
      };
      final r = validateAgainstSource(sms3, llm, sender: 'SBINB');
      final vpa = r.report.fields.firstWhere((f) => f.field == 'upi_payee_vpa');
      expect(vpa.status, AnchorFieldStatus.reject);
      expect(vpa.detail, 'bad_shape');
      expect(r.cleaned['upi_payee_vpa'], isNull);
      expect(
        r.report.fields.firstWhere((f) => f.field == 'external_ref').status,
        AnchorFieldStatus.pass,
      );
      expect(
        formatAnchorVerdictLine(r.report, r.cleaned),
        'anchor: usable (dropped: v)',
      );
    });

    test('f:4821 dropped — bare last-4 is not a ref', () {
      final llm = {
        'amount_paise': 149900,
        'direction': 'debit',
        'type': 'imps',
        'booked_at': '2026-07-30T00:00:00.000Z',
        'bank_code': 'HDFC',
        'raw_merchant': 'FLIPKART INDIA',
        'raw_description': sms2,
        'external_ref': '4821',
        'dedupe_key': 'unknown|149900|4821',
      };
      final r = validateAgainstSource(sms2, llm);
      final ref = r.report.fields.firstWhere((f) => f.field == 'external_ref');
      expect(ref.status, AnchorFieldStatus.reject);
      expect(ref.detail, 'bad_shape');
      expect(r.cleaned['external_ref'], isNull);
    });

    test('f:SBIN998877665544 kept — NEFT UTR shape', () {
      final llm = {
        'amount_paise': 2500000,
        'direction': 'credit',
        'type': 'neft',
        'booked_at': '2026-07-31T00:00:00.000Z',
        'bank_code': 'SBI',
        'raw_merchant': 'ACME CORP',
        'raw_description': sms3,
        'external_ref': 'SBIN998877665544',
        'dedupe_key': 'unknown|2500000|SBIN998877665544',
      };
      final r = validateAgainstSource(sms3, llm, sender: 'SBINB');
      final ref = r.report.fields.firstWhere((f) => f.field == 'external_ref');
      expect(ref.status, AnchorFieldStatus.pass);
      expect(r.cleaned['external_ref'], 'SBIN998877665544');
    });

    test('m:HDFC A/c demoted — bank + account phrase', () {
      final llm = {
        'amount_paise': 149900,
        'direction': 'debit',
        'type': 'imps',
        'booked_at': '2026-07-30T00:00:00.000Z',
        'bank_code': 'HDFC',
        'raw_merchant': 'HDFC A/c',
        'raw_description': sms2,
        'dedupe_key': 'unknown|149900|637890999888',
      };
      final r = validateAgainstSource(sms2, llm);
      final merchant =
          r.report.fields.firstWhere((f) => f.field == 'raw_merchant');
      expect(merchant.status, AnchorFieldStatus.demote);
      expect(merchant.detail, 'bad_shape');
      expect(r.cleaned['raw_merchant'], '');
    });

    test('v:HDFC A/c dropped — not a VPA shape (device SMS2)', () {
      final llm = {
        'amount_paise': 149900,
        'direction': 'debit',
        'type': 'upi',
        'booked_at': '2026-07-30T00:00:00.000Z',
        'bank_code': 'HDFC',
        'raw_merchant': 'FLIPKART INDIA',
        'raw_description': sms2,
        'upi_payee_vpa': 'HDFC A/c',
        'dedupe_key': 'unknown|149900|637890999888',
      };
      final r = validateAgainstSource(sms2, llm);
      final vpa = r.report.fields.firstWhere((f) => f.field == 'upi_payee_vpa');
      expect(vpa.status, AnchorFieldStatus.reject);
      expect(vpa.detail, 'bad_shape');
      expect(r.cleaned['upi_payee_vpa'], isNull);
      expect(
        formatAnchorVerdictLine(r.report, r.cleaned),
        contains('dropped: v'),
      );
    });
  });

  group('device-mirroring anchor verdicts (standard 3)', () {
    const v = ParsedTransactionJsonValidator();

    const deviceFixtures = {
      sms1:
          '{"a":"INR 87.30","d":"29-JUL-26","t":null,"y":"upi","r":"debit","m":"Avl Bal INR 12,034.55","f":"412399887766","v":"zomato@paytm"}',
      sms2:
          '{"a":"Rs 1,499.00","d":"30Jul26","t":null,"y":"upi","r":"credit","m":"HDFC A/c","f":"4821","v":"HDFC A/c"}',
      sms3:
          '{"a":"Rs.25,000.00","d":"31-07-2026","t":null,"y":"upi","r":"credit","m":"ACME CORP","f":"SBIN998877665544","v":"BONUS"}',
    };

    const expectedVerdicts = {
      sms1: 'anchor: usable (dropped: m)',
      sms2: 'anchor: usable (dropped: m, f, v) (direction: overridden)',
      sms3: 'anchor: usable (dropped: v)',
    };

    for (final entry in deviceFixtures.entries) {
      test('verdict for ${entry.key.substring(0, 20)}…', () {
        final txn = v
            .validate(entry.value, sourceSms: entry.key, sender: 'SBINB')
            .okOrNull!;
        final r = validateAgainstSource(entry.key, txn.toJson(), sender: 'SBINB');
        expect(
          formatAnchorVerdictLine(r.report, r.cleaned),
          expectedVerdicts[entry.key],
        );
      });
    }
  });

  test('disagreement rows written for each shape-gate drop', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final recorder = LlmDisagreementRecorder(db);

    final sms2Llm = {
      'amount_paise': 149900,
      'direction': 'credit',
      'type': 'imps',
      'booked_at': '2026-07-30T00:00:00.000Z',
      'bank_code': 'HDFC',
      'raw_merchant': 'HDFC A/c',
      'raw_description': sms2,
      'external_ref': '4821',
      'upi_payee_vpa': 'FLIPKART INDIA',
      'dedupe_key': 'unknown|149900|4821',
    };
    final sms2R = validateAgainstSource(sms2, sms2Llm);
    await recorder.recordFromAnchor(
      report: sms2R.report,
      llmJson: sms2Llm,
      cleaned: sms2R.cleaned,
    );

    final sms3Llm = {
      'amount_paise': 2500000,
      'direction': 'credit',
      'type': 'neft',
      'booked_at': '2026-07-31T00:00:00.000Z',
      'bank_code': 'SBI',
      'raw_merchant': 'ACME CORP',
      'raw_description': sms3,
      'upi_payee_vpa': 'BONUS',
      'external_ref': 'SBIN998877665544',
      'dedupe_key': 'unknown|2500000|SBIN998877665544',
    };
    final sms3R = validateAgainstSource(sms3, sms3Llm, sender: 'SBINB');
    await recorder.recordFromAnchor(
      report: sms3R.report,
      llmJson: sms3Llm,
      cleaned: sms3R.cleaned,
    );

    final counts = await db.countLlmDisagreementsByField();
    expect(counts[LlmDisagreementField.merchantDemoted.wireName], 1);
    expect(counts[LlmDisagreementField.refDropped.wireName], 1);
    expect(counts[LlmDisagreementField.vpaDropped.wireName], 2);
  });

  test('no direction cue accepts LLM direction with inferred flag', () {
    const body = 'Txn INR 500.00 on 01-AUG-26 ref 998877665544';
    final llm = {
      'amount_paise': 50000,
      'direction': 'debit',
      'type': 'other',
      'booked_at': '2026-08-01T00:00:00.000Z',
      'bank_code': 'UNKNOWN',
      'raw_merchant': 'ref 998877665544',
      'raw_description': body,
      'dedupe_key': 'unknown|50000|998877665544',
    };
    final r = validateAgainstSource(body, llm);
    final dir = r.report.fields.firstWhere((f) => f.field == 'direction');
    expect(dir.status, AnchorFieldStatus.infer);
    expect(r.cleaned['direction'], 'debit');
    expect(r.cleaned['direction_inferred'], isTrue);
    expect(r.report.allCriticalPassed, isTrue);
  });

  test('conflicting direction cues keep LLM with inferred flag', () {
    const body =
        'Amount debited from A/c. Refund credited back Rs 200.00 on 02-AUG-26';
    final llm = {
      'amount_paise': 20000,
      'direction': 'credit',
      'type': 'other',
      'booked_at': '2026-08-02T00:00:00.000Z',
      'bank_code': 'UNKNOWN',
      'raw_merchant': 'Refund',
      'raw_description': body,
      'dedupe_key': 'unknown|20000|',
    };
    final r = validateAgainstSource(body, llm);
    final dir = r.report.fields.firstWhere((f) => f.field == 'direction');
    expect(dir.status, AnchorFieldStatus.infer);
    expect(dir.detail, 'conflicting_cues');
    expect(r.cleaned['direction'], 'credit');
    expect(r.cleaned['direction_inferred'], isTrue);
  });

  test('disagreement rows for merchant demote and vpa drop', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);

    const body =
        'Rs 99.00 debited on 03-AUG-26 UPI/111122223333/shop@ybl';
    final llm = {
      'amount_paise': 9900,
      'direction': 'debit',
      'type': 'upi',
      'booked_at': '2026-08-03T00:00:00.000Z',
      'bank_code': 'UNKNOWN',
      'raw_merchant': 'Avl Bal INR 9,999.00',
      'raw_description': body,
      'upi_payee_vpa': 'fake@vpa',
      'upi_ref': '111122223333',
      'dedupe_key': 'unknown|9900|111122223333',
    };
    final r = validateAgainstSource(body, llm);
    expect(
      r.report.fields.firstWhere((f) => f.field == 'raw_merchant').status,
      AnchorFieldStatus.demote,
    );
    expect(
      r.report.fields.firstWhere((f) => f.field == 'upi_payee_vpa').status,
      AnchorFieldStatus.reject,
    );
    await LlmDisagreementRecorder(db).recordFromAnchor(
      report: r.report,
      llmJson: llm,
      cleaned: r.cleaned,
    );

    final counts = await db.countLlmDisagreementsByField();
    expect(counts[LlmDisagreementField.merchantDemoted.wireName], 1);
    expect(counts[LlmDisagreementField.vpaDropped.wireName], 1);
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

    test('SMS2 wrong credit overridden after span validate', () {
      const badJson =
          '{"a":"Rs 1,499.00","d":"30Jul26","t":null,"y":"imps","r":"credit",'
          '"m":"FLIPKART INDIA","f":"637890999888","v":null}';
      final txn = v.validate(badJson, sourceSms: sms2).okOrNull!;
      final r = validateAgainstSource(sms2, txn.toJson());
      expect(r.report.allCriticalPassed, isTrue);
      expect(r.cleaned['direction'], 'debit');
      final dir = r.report.fields.firstWhere((f) => f.field == 'direction');
      expect(dir.status, AnchorFieldStatus.override);
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

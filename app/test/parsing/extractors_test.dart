import 'package:arth/core/models/transaction_type.dart';
import 'package:arth/parsing/sms/extractors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAmountToken', () {
    test('Indian grouping with paise', () {
      expect(parseAmountToken('Rs.1,23,456.78')?.paise, 12345678);
      expect(parseAmountToken('Rs.1,250.00')?.paise, 125000);
    });

    test('INR and bare forms', () {
      expect(parseAmountToken('INR 500')?.paise, 50000);
      expect(parseAmountToken('Rs 1500.00')?.paise, 150000);
      expect(parseAmountToken('₹99.50')?.paise, 9950);
    });

    test('rejects non-amount', () {
      expect(parseAmountToken('hello'), isNull);
    });
  });

  group('extractSoleTxnAmount', () {
    test('single txn amount', () {
      final r = extractSoleTxnAmount('Rs.100.00 debited from a/c');
      expect(r.isOk, isTrue);
      expect(r.okOrNull!.paise, 10000);
    });

    test('excludes balance amount', () {
      final r = extractSoleTxnAmount(
        'Rs.100.00 debited. Avl Bal Rs.5,000.00',
      );
      expect(r.isOk, isTrue);
      expect(r.okOrNull!.paise, 10000);
    });

    test('ambiguous multiple txn amounts', () {
      final r = extractSoleTxnAmount(
        'Rs.100.00 debited and Rs.50.00 credited',
      );
      expect(r.isErr, isTrue);
      expect(r.errorOrNull, 'ambiguous_multiple_amounts');
    });

    test('no amount', () {
      expect(extractSoleTxnAmount('hello world').isErr, isTrue);
    });
  });

  group('extractDateTime', () {
    test('dd-MM-yy and dd/MM/yy', () {
      expect(
        extractDateTime('on 15-07-26'),
        DateTime.utc(2026, 7, 15),
      );
      expect(
        extractDateTime('on 03/08/26'),
        DateTime.utc(2026, 8, 3),
      );
    });

    test('dd-MM-yyyy', () {
      expect(
        extractDateTime('02-08-2026'),
        DateTime.utc(2026, 8, 2),
      );
    });

    test('01-Aug-26 and 01Aug26', () {
      expect(extractDateTime('01-Aug-26'), DateTime.utc(2026, 8, 1));
      expect(extractDateTime('01Aug26'), DateTime.utc(2026, 8, 1));
    });

    test('captures time when present', () {
      expect(
        extractDateTime('28-07-26 19:42 IST'),
        DateTime.utc(2026, 7, 28, 19, 42),
      );
    });
  });

  group('extractDirection', () {
    test('debit and credit keywords', () {
      expect(extractDirection('debited from'), TransactionDirection.debit);
      expect(extractDirection('credited to'), TransactionDirection.credit);
      expect(extractDirection('spent on card'), TransactionDirection.debit);
      expect(extractDirection('Paid Rs.10'), TransactionDirection.debit);
    });
  });

  group('refs and masks', () {
    test('upi / imps / neft / account / vpa', () {
      expect(
        extractUpiRef('UPI Ref 412345678901'),
        '412345678901',
      );
      expect(
        extractImpsRef('IMPS/P2A/637890123456/AMAZON'),
        '637890123456',
      );
      expect(
        extractNeftUtr('NEFT UTR SBIN987654321098'),
        'SBIN987654321098',
      );
      expect(
        resolveStatementRef(
          refCol: 'UPI/412345678901/merchant@okhdfcbank/FOOD',
          narration: '',
        ),
        '412345678901',
      );
      expect(
        resolveStatementRef(
          refCol: '',
          narration: '',
          dateCell: '02-Aug-2026 IMPS/P2A/637890123456/AMAZON',
        ),
        '637890123456',
      );
      expect(extractAccountMask('a/c **1234'), '1234');
      expect(extractAccountMask('A/c ending 5678'), '5678');
      expect(extractVpa('to merchant@okhdfcbank today'), 'merchant@okhdfcbank');
    });
  });

  group('extractBalance', () {
    test('avl bal separate from txn', () {
      expect(
        extractBalance('debited Rs.10.00. Avl Bal Rs.1,234.56')?.paise,
        123456,
      );
    });
  });

  group('normalizeSmsBody', () {
    test('collapses whitespace and strips oddities', () {
      expect(
        normalizeSmsBody('A\u00a0B\n\tC\u200b'),
        'A B C',
      );
    });
  });
}

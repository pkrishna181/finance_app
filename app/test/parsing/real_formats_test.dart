import 'package:arth/core/models/transaction_type.dart';
import 'package:arth/core/result/result.dart';
import 'package:arth/parsing/common/extractors.dart';
import 'package:arth/parsing/sms/regex_sms_parser.dart';
import 'package:arth/parsing/sms/sender_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// Formats from real inboxes (made-up names and numbers) that the golden
/// files can't hold: no date in the message, or not a transaction at all.
void main() {
  final parser = RegexSmsParser();
  final received = DateTime.utc(2026, 10, 5, 9, 30);

  ({String? skipped, bool mandate, List<Object> txns, bool unparsed}) run(
    String body,
    String sender,
  ) {
    final r = parser.parseDetailed(
      body: body,
      sender: sender,
      receivedAt: received,
    );
    return switch (r) {
      Ok(:final value) => (
        skipped: value.skippedReason,
        mandate: value.hasMandate,
        txns: value.transactions,
        unparsed: false,
      ),
      Err() => (skipped: null, mandate: false, txns: const [], unparsed: true),
    };
  }

  group('undated transactions take the day received', () {
    for (final (sender, body, paise, dir, merchant) in [
      (
        'VM-SBICRD-S',
        'We have received payment of Rs.18,350.00 via BBPS & the same has been '
            'credited to your SBI Credit Card. Your available limit is '
            'Rs.1,20,000.00.',
        1835000,
        TransactionDirection.credit,
        'BBPS',
      ),
      (
        'VM-SBICRD',
        'Dear SBI Cardholder, payment of Rs. 52140.00 for your SBI Credit Card '
            'has been successfully processed. ref no : CHD5EB81AAAAAA.',
        5214000,
        TransactionDirection.credit,
        'Unknown',
      ),
      (
        'VM-SBICRD',
        'Annual fee waiver of Rs 399 has been credited to your SBI Card ending 1234.',
        39900,
        TransactionDirection.credit,
        'Annual fee waiver',
      ),
      (
        'VM-CBSSBI',
        'Dear Customer, Loan of Rs.76500.00 disbursed from Loan A/c No '
            'XXXXX111222 and credit to A/c No XXXXX654321 as requested.Please '
            'contact Branch for further information-SBI',
        7650000,
        TransactionDirection.credit,
        'Loan',
      ),
      (
        'BP-iPaytm',
        'Paid Rs.185 to Jubliant from Paytm Balance. Updated Balance: Paytm '
            'Wallet- Rs 0. More Details: https://paytm.me/AAAA-1a',
        18500,
        TransactionDirection.debit,
        'Jubliant',
      ),
      (
        'BP-iPaytm',
        'Rs.350.00 received from ARUN MEHTA (8686000000@paytm) in your Paytm '
            'Payments Bank a/c 91XX5555. UPI Ref: 029077000015',
        35000,
        TransactionDirection.credit,
        'ARUN MEHTA',
      ),
      (
        'AX-IDFCFB-S',
        'Your refund of INR 15for your UPI Transaction Dispute is successfully '
            'processed  in your IDFC First bank account 10000000000. Service '
            'request no.1158230000 is closed.',
        1500,
        TransactionDirection.credit,
        'refund',
      ),
    ]) {
      test(body.substring(0, 40), () {
        final r = parser.parse(
          body: body,
          sender: sender,
          receivedAt: received,
        );
        final t = r.okOrNull!.single;
        expect(t.amountPaise.paise, paise);
        expect(t.direction, dir);
        expect(t.rawMerchant, merchant);
        expect(t.bookedAt, DateTime.utc(2026, 10, 5));
      });
    }

    test("a received UPI ID is the payer's, not the payee's", () {
      final t = parser
          .parse(
            body:
                'Rs.350.00 received from ARUN MEHTA (8686000000@paytm) in '
                'your Paytm Payments Bank a/c 91XX5555. UPI Ref: 029077000015',
            sender: 'BP-iPaytm',
            receivedAt: received,
          )
          .okOrNull!
          .single;
      expect(t.upiPayerVpa, '8686000000@paytm');
      expect(t.upiPayeeVpa, isNull);
    });
  });

  group('not transactions', () {
    for (final (reason, sender, body) in [
      (
        'otp',
        'VM-SBICRD',
        '639644 is the OTP for Trxn. of INR 199.00 at SWIGGY PVT with your '
            'credit card ending 1234. OTP is valid for 10 mins.',
      ),
      (
        'declined',
        'VM-SBICRD',
        'Dear SBI Cardholder, Txn of Rs.650.00 on Card ending with XX1234 at '
            'SOMEAI on 03-04-26 has been declined. Pls call at 18601801290.',
      ),
      (
        'bill_alert',
        'AD-AXISBK-S',
        'Payment of INR 18000.50 for Axis Bank Credit Card no. XX2468 is due on '
            '30-09-26 with minimum amount due of INR 9000. Ignore if paid.',
      ),
      (
        'bill_alert',
        'AX-INDUSB-S',
        '22/09/26 Stmt Alert: Total Amount Due on your IndusInd Bank Credit '
            'Card XXXX1357 is INR 25000.00 and Minimum Amount Due is INR '
            '4000.00, payable by 12/10/26.',
      ),
      (
        'collect_request',
        'VM-SBIUPI',
        'IRCTC CF has requested Rs512.30 frm u on Google Pay app. Once '
            'approved, money will be debited frm ur a/c -SBI',
      ),
      (
        'hold',
        'VM-CBSSBI',
        'Dear Customer, hold for INR 11,111.00 created in deposit Ac '
            'XXXXX654321 on 17/09/26. If not consented, pl contact branch-SBI',
      ),
      (
        'foreign_currency',
        'AX-AXISBK-S',
        'Spent USD 3.54 Axis Bank Card no. XX2468 12-10-26 06:18:14 IST '
            'PATREON ME Avl Limit: INR 30000.00 Not you? SMS BLOCK 2468',
      ),
      (
        'foreign_currency',
        'VM-SBICRD',
        'USD21.40 spent on your SBI Credit Card ending 1234 at SOMEAI on '
            '20/02/26. Trxn. not done by you? Report at https://sbicard.com/D',
      ),
      (
        'no_amount',
        'VM-SBICRD',
        'Dear Cardholder, You have successfully logged in to your SBI Credit '
            'Card online account on 01 Jun 2026.',
      ),
      (
        'emi_offer',
        'VM-SBICRD',
        'Dear Cardholder, you can convert Trxns. of combined value Rs.5000 done '
            'with your credit card on 29JUL into Flexipay EMI.',
      ),
      (
        'loan_account',
        'VM-CBSSBI',
        'Dear Customer, Your loan A/C XXXXX111222 Credited INR 50,000.00 on '
            '03/08/24,deposit transfer from Mr. RAMESH BABU.-SBI.',
      ),
      (
        'investment',
        'VM-SBIMFD',
        'Dear Investor, Purchase transaction in Folio No. 12345678 in Scheme : '
            'SBI Nifty Index Fund-Dir Growth for amount of INR 1500.00',
      ),
    ]) {
      test('$reason: ${body.substring(0, 30)}', () {
        expect(run(body, sender).skipped, reason);
      });
    }
  });

  group('upcoming payments are mandates', () {
    for (final body in [
      'Dear Cardholder, your payment of INR 299.00 at Google Play is due on '
          '22/10/2026 and will be processed through your credit card ending 1234 '
          'as per e-Mandate (SiHub ID: AbCdEf1234) registered by you.',
      'Dear UPI User, UPI AutoPay for INDmoney debit of Rs.1500.00 is scheduled '
          'on .10/06/26, abc123@inhdfc. Please ensure sufficient balance.',
      'Your account will be debited with Rs 499.00 towards NETFLIX for the '
          'Create Mandate on 05/10/2026. Pause mandate to stop execution.',
      'Your scheduled transaction in SBI Internet Banking for Rs.2500 towards '
          'Third Party Transfer from A/c XX4321 will be executed on 28/02/2021.',
    ]) {
      test(body.substring(0, 40), () {
        expect(run(body, 'VM-SBIUPI').mandate, isTrue);
      });
    }
  });

  test('senders of real alerts map to their bank', () {
    expect(matchSender('AX-IDFCFB-S').bankCode, 'IDFC');
    expect(matchSender('JKIDFCFB').bankCode, 'IDFC');
    expect(matchSender('AX-INDUSB-S').bankCode, 'INDUSIND');
    expect(matchSender('VM-CBSSBI').bankCode, 'SBI');
    expect(matchSender('VM-SBIPSG-S').bankCode, 'SBI');
    expect(knownSenderEntities, containsAll(['IDFCFB', 'INDUSB']));
  });

  test('dates: ISO and 12-hour times', () {
    expect(
      extractDateTime('credited on 2026-08-08.'),
      DateTime.utc(2026, 8, 8),
    );
    expect(
      extractDateTime('on 18-10-2026 03:05:54 pm at'),
      DateTime.utc(2026, 10, 18, 15, 5, 54),
    );
    expect(
      extractDateTime('on 18-10-2026 12:10:00 am at'),
      DateTime.utc(2026, 10, 18, 0, 10),
    );
  });

  test('INR.33.00', () {
    expect(parseAmountToken('INR.33.00')?.paise, 3300);
  });
}

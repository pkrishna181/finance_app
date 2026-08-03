import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

List<SmsTemplate> paytmTemplates() => [
      SmsTemplate(
        id: 'paytm_upi_paid',
        bankCode: 'PAYTM',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'Paid\s+(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+from\s+Paytm\s+Payments\s+Bank\s+'
          r'A/c\s+\w*(?<account>\d{4})\s+to\s+(?<payee_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+)\s+on\s+'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\.\s*UPI\s*Ref:\s*(?<ref>\d{12})',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'paytm_upi_received',
        bankCode: 'PAYTM',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.credit,
        pattern: RegExp(
          r'Received\s+(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+in\s+Paytm\s+Payments\s+Bank\s+'
          r'A/c\s+\w*(?<account>\d{4})\s+from\s+(?<payer_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+)\s+on\s+'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\.\s*UPI\s*Ref:\s*(?<ref>\d{12})',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'paytm_card',
        bankCode: 'PAYTM',
        type: TransactionType.card,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+spent\s+on\s+Paytm\s+(?:Postpaid|Card)\s+'
          r'(?:XX|ending\s+)?(?<account>\d{4})\s+at\s+(?<merchant>.+?)\s+on\s+'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})',
          caseSensitive: false,
        ),
        externalRefBuilder: (f) =>
            'PAYTM-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
      ),
      SmsTemplate(
        id: 'paytm_atm',
        bankCode: 'PAYTM',
        type: TransactionType.atm,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+withdrawn\s+from\s+Paytm\s+Payments\s+Bank\s+'
          r'A/c\s+\w*(?<account>\d{4})\s+at\s+(?<merchant>.+?)\s+on\s+'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})',
          caseSensitive: false,
        ),
      ),
    ];

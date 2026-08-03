import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

List<SmsTemplate> kotakTemplates() => [
      SmsTemplate(
        id: 'kotak_upi_debit',
        bankCode: 'KOTAK',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'Kotak\s+Bank\s+A/c\s+\w*(?<account>\d{4})\s+debited\s+with\s+'
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\s+'
          r'towards\s+(?<payee_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+)\s+UPI\s+Ref\s*(?<ref>\d{12})',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'kotak_upi_credit',
        bankCode: 'KOTAK',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.credit,
        pattern: RegExp(
          r'Kotak\s+Bank\s+A/c\s+\w*(?<account>\d{4})\s+credited\s+with\s+'
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\s+'
          r'from\s+(?<payer_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+)\s+UPI\s+Ref\s*(?<ref>\d{12})',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'kotak_card',
        bankCode: 'KOTAK',
        type: TransactionType.card,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>INR\s*[0-9,]+\.\d{2})\s+spent\s+on\s+Kotak\s+Card\s+\w*(?<account>\d{4})\s+'
          r'at\s+(?<merchant>.+?)\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})(?:\s+(?<time>\d{1,2}:\d{2}))?',
          caseSensitive: false,
        ),
        externalRefBuilder: (f) =>
            'KOTAK-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
      ),
      SmsTemplate(
        id: 'kotak_atm',
        bankCode: 'KOTAK',
        type: TransactionType.atm,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+withdrawn\s+from\s+Kotak\s+A/c\s+\w*(?<account>\d{4})\s+'
          r'at\s+ATM\s+(?<merchant>.+?)\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})',
          caseSensitive: false,
        ),
      ),
    ];

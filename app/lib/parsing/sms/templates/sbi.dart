import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

List<SmsTemplate> sbiTemplates() => [
      SmsTemplate(
        id: 'sbi_upi_debit',
        bankCode: 'SBI',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'Dear\s+SBI\s+User,\s+your\s+A/c\s+X?(?<account>\d{4})\s+debited\s+by\s+'
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\s+'
          r'by\s+UPI\s+Ref\s+No\s+(?<ref>\d{12})\s*-?\s*(?<merchant>[A-Za-z0-9_]+).*?'
          r'(?:Avl\s+Bal\s+(?<balance>Rs\.?\s*[0-9,]+\.\d{2}))?',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'sbi_upi_credit',
        bankCode: 'SBI',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.credit,
        pattern: RegExp(
          r'Dear\s+SBI\s+User,\s+your\s+A/c\s+X?(?<account>\d{4})\s+credited\s+by\s+'
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\s+'
          r'by\s+UPI\s+Ref\s+No\s+(?<ref>\d{12})\s*-?\s*(?<merchant>[A-Za-z0-9_]+)',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'sbi_atm',
        bankCode: 'SBI',
        type: TransactionType.atm,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+withdrawn\s+from\s+A/c\s+\w*(?<account>\d{4})\s+'
          r'on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4}).*?ATM\s+(?<merchant>.+?)(?:\.|Avl)',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'sbi_card',
        bankCode: 'SBI',
        type: TransactionType.card,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+spent\s+on\s+SBI\s+Card\s+\w*(?<account>\d{4})\s+'
          r'at\s+(?<merchant>.+?)\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})',
          caseSensitive: false,
        ),
        externalRefBuilder: (f) =>
            'SBI-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
      ),
    ];

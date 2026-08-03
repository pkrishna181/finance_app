import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

List<SmsTemplate> iciciTemplates() => [
      SmsTemplate(
        id: 'icici_imps_debit',
        bankCode: 'ICICI',
        type: TransactionType.imps,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'ICICI\s+Bank\s+Acct\s+\w*(?<account>\d{4})\s+is\s+debited\s+with\s+'
          r'(?<amount>INR\s*[0-9,]+\.\d{2})\s+on\s+(?<date>\d{2}-[A-Za-z]{3}-\d{2,4})\.\s+'
          r'Info:\s*IMPS/[^/]+/(?<ref>\d{12})/(?<merchant>.+?)\.\s+'
          r'Available\s+Bal:\s*(?<balance>INR\s*[0-9,]+\.\d{2})',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'icici_upi',
        bankCode: 'ICICI',
        type: TransactionType.upi,
        pattern: RegExp(
          r'ICICI\s+Bank\s+Acct\s+\w*(?<account>\d{4})\s+is\s+'
          r'(?:debited|credited)\s+with\s+(?<amount>INR\s*[0-9,]+\.\d{2})\s+on\s+'
          r'(?<date>\d{2}-[A-Za-z]{3}-\d{2,4})\.\s*'
          r'Info:\s*UPI/(?<ref>\d{12})/(?:VPA\s+)?(?<payee_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+)?',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'icici_credit_salary',
        bankCode: 'ICICI',
        type: TransactionType.salary,
        fixedDirection: TransactionDirection.credit,
        pattern: RegExp(
          r'ICICI\s+Bank\s+Acct\s+\w*(?<account>\d{4})\s+is\s+credited\s+with\s+'
          r'(?<amount>INR\s*[0-9,]+\.\d{2})\s+on\s+(?<date>\d{2}-[A-Za-z]{3}-\d{2,4})\.\s+'
          r'Info:\s*(?:NEFT|IMPS)/.*/(?<ref>[A-Z0-9]+)/(?<merchant>.+?)(?:\.|$)',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'icici_card',
        bankCode: 'ICICI',
        type: TransactionType.card,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>INR\s*[0-9,]+\.\d{2})\s+spent\s+on\s+ICICI\s+Bank\s+Card\s+\w*(?<account>\d{4})\s+'
          r'at\s+(?<merchant>.+?)\s+on\s+(?<date>\d{2}-[A-Za-z]{3}-\d{2,4})',
          caseSensitive: false,
        ),
        externalRefBuilder: (f) =>
            'ICICI-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
      ),
    ];

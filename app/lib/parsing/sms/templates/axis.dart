import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

List<SmsTemplate> axisTemplates() => [
      SmsTemplate(
        id: 'axis_card_pos',
        bankCode: 'AXIS',
        type: TransactionType.pos,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'AXIS\s+BANK:\s*(?<amount>INR\s*[0-9,]+\.\d{2})\s+spent\s+on\s+AXIS\s+Card\s+\w*(?<account>\d{4})\s+'
          r'at\s+(?<merchant>.+?)\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})(?:\s+(?<time>\d{1,2}:\d{2}))?',
          caseSensitive: false,
        ),
        externalRefBuilder: (f) =>
            'AXIS-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
      ),
      SmsTemplate(
        id: 'axis_upi',
        bankCode: 'AXIS',
        type: TransactionType.upi,
        pattern: RegExp(
          r'(?:AXIS(?:\s+BANK)?)?:?\s*(?<amount>(?:INR|Rs\.?)\s*[0-9,]+\.\d{2})\s+'
          r'(?:debited|credited).*?(?:A/c|a/c)\s*\w*(?<account>\d{4}).*?'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4}).*?'
          r'UPI\s*Ref\s*(?:No\.?)?\s*(?<ref>\d{12}).*?'
          r'(?:to|from)?\s*(?<payee_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+)?',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'axis_credit',
        bankCode: 'AXIS',
        type: TransactionType.transfer,
        fixedDirection: TransactionDirection.credit,
        pattern: RegExp(
          r'AXIS\s+BANK:\s*(?<amount>INR\s*[0-9,]+\.\d{2})\s+credited\s+to\s+A/c\s+\w*(?<account>\d{4})\s+'
          r'on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4}).*?(?:from\s+(?<merchant>.+?))?(?:\.|Ref)',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'axis_atm',
        bankCode: 'AXIS',
        type: TransactionType.atm,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'AXIS\s+BANK:\s*(?<amount>INR\s*[0-9,]+\.\d{2})\s+withdrawn\s+from\s+A/c\s+\w*(?<account>\d{4})\s+'
          r'at\s+ATM\s+(?<merchant>.+?)\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})',
          caseSensitive: false,
        ),
      ),
    ];

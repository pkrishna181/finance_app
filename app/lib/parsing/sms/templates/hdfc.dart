import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

/// HDFC Bank SMS templates (ordered; first match wins).
List<SmsTemplate> hdfcTemplates() => [
      SmsTemplate(
        id: 'hdfc_upi_debit_vpa',
        bankCode: 'HDFC',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'HDFC\s+Bank:?\s*(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+debited\s+from\s+'
          r'a/c\s*\**(?<account>\d{4})\s+on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})\s+'
          r'to\s+VPA\s+(?<payee_vpa>[^\s(]+)\s*\(UPI\s*Ref\s*(?<ref>\d{12})\)',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'hdfc_upi_credit',
        bankCode: 'HDFC',
        type: TransactionType.upi,
        fixedDirection: TransactionDirection.credit,
        pattern: RegExp(
          r'(?:HDFC\s+Bank:?\s*)?(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+credited\s+to\s+'
          r'(?:a/c\s*\**(?<account>\d{4})\s+)?.*?'
          r'(?:from\s+VPA\s+(?<payer_vpa>\S+)|UPI).*?'
          r'(?:on\s+(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})).*?'
          r'(?:UPI\s*Ref\s*(?:No\.?)?\s*(?<ref>\d{12}))',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'hdfc_card_pos',
        bankCode: 'HDFC',
        type: TransactionType.pos,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'Thank\s+you\s+for\s+using\s+your\s+HDFC\s+Bank\s+Card\s+\w*(?<account>\d{4})\s+'
          r'for\s+(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+at\s+(?<merchant>.+?)\s+on\s+'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})(?:\s+(?<time>\d{1,2}:\d{2}))?',
          caseSensitive: false,
        ),
        externalRefBuilder: (f) =>
            'HDFC-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
      ),
      SmsTemplate(
        id: 'hdfc_atm',
        bankCode: 'HDFC',
        type: TransactionType.atm,
        fixedDirection: TransactionDirection.debit,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+withdrawn\s+(?:using\s+)?(?:HDFC\s+Bank\s+)?'
          r'(?:Debit\s+)?Card\s+\w*(?<account>\d{4})\s+at\s+(?:ATM\s+)?(?<merchant>.+?)\s+on\s+'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4})',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'hdfc_imps',
        bankCode: 'HDFC',
        type: TransactionType.imps,
        pattern: RegExp(
          r'(?<amount>Rs\.?\s*[0-9,]+\.\d{2})\s+(?<dir>debited|credited).*?'
          r'a/c\s*\**(?<account>\d{4}).*?'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4}).*?'
          r'IMPS.*?(?<ref>\d{12}).*?(?<merchant>[A-Z][A-Z0-9 &\-]{2,})?',
          caseSensitive: false,
        ),
      ),
    ];

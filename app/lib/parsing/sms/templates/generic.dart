import '../../../core/models/transaction_type.dart';
import '../template.dart';

/// Generic UPI / IMPS / NEFT templates used when bank is unknown or bank
/// templates miss. First match wins within this list.
List<SmsTemplate> genericTemplates() => [
      SmsTemplate(
        id: 'generic_upi',
        bankCode: 'UNKNOWN',
        type: TransactionType.upi,
        pattern: RegExp(
          r'(?<amount>(?:Rs\.?|INR|₹)\s*[0-9,]+\.\d{2}).*?'
          r'\b(?<dir>debited|credited|paid|received)\b.*?'
          r'(?:UPI\s*Ref(?:\s*No)?\.?\s*:?\s*(?<ref>\d{12})).*?'
          r'(?:(?:to|from)\s+(?:VPA\s+)?(?<payee_vpa>[a-zA-Z0-9._-]+@[a-zA-Z0-9]+))?',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'generic_imps',
        bankCode: 'UNKNOWN',
        type: TransactionType.imps,
        pattern: RegExp(
          r'(?<amount>(?:Rs\.?|INR|₹)\s*[0-9,]+\.\d{2}).*?'
          r'\b(?<dir>debited|credited)\b.*?'
          r'IMPS.*? (?<ref>\d{12}).*?'
          r'(?<date>\d{2}[-/]\d{2}[-/]\d{2,4}|\d{2}-[A-Za-z]{3}-\d{2,4})?',
          caseSensitive: false,
        ),
      ),
      SmsTemplate(
        id: 'generic_neft',
        bankCode: 'UNKNOWN',
        type: TransactionType.neft,
        pattern: RegExp(
          r'(?<amount>(?:Rs\.?|INR|₹)\s*[0-9,]+\.\d{2}).*?'
          r'\b(?<dir>debited|credited)\b.*?'
          r'NEFT.*?(?:UTR\s*:?\s*)?(?<ref>[A-Z0-9]{12,22})',
          caseSensitive: false,
        ),
      ),
    ];

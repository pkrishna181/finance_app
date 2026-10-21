import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

List<SmsTemplate> paytmTemplates() => [
  // Real Paytm wallet / Payments Bank formats (2020–2024).
  SmsTemplate(
    id: 'paytm_wallet_paid',
    bankCode: 'PAYTM',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'Paid (?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) to (?<merchant>.+?) from Paytm '
      r'Balance',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_bank_paid_via',
    bankCode: 'PAYTM',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'(?:You have paid|Paid) (?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) via (?:your )?'
      r'a/c \w*(?<account>\d{4}) to (?<merchant>.+?) on (?<date>\d{2}-\d{2}-\d{4})\. '
      r'Ref(?: No)?:? ?(?<ref>\d+)',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_bank_sent',
    bankCode: 'PAYTM',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'(?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) sent to (?<payee_vpa>\S+@\S+?) from '
      r'(?:your Paytm Payments Bank|PPBL) a/c \w*(?<account>\d{4}) ?\.? ?UPI Ref: ?'
      r'(?<ref>\d{12})',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_bank_received',
    bankCode: 'PAYTM',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      r'(?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) received from (?<merchant>.+?) '
      r'\((?<payer_vpa>\S+@\S+)\) in your Paytm Payments Bank a/c \w*(?<account>\d{4})\. '
      r'UPI Ref: ?(?<ref>\d{12})',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_bank_sent_account',
    bankCode: 'PAYTM',
    type: TransactionType.imps,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'Sent (?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) from your a/c \w*(?<account>\d{4}) '
      r'to (?<merchant>a/c \w+) on (?<date>\d{2}-\d{2}-\d{4})\. ?Ref no: (?<ref>\w+)',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_failed_upi_refund',
    bankCode: 'PAYTM',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      r'(?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) is added back to your Paytm Payments '
      r'bank a/c \w*(?<account>\d{4}) as your UPI transaction with reference '
      r'(?<ref>\d{12}) has failed',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_wallet_to_bank',
    bankCode: 'PAYTM',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'(?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) transferred from your (?<merchant>Paytm '
      r'wallet to A/c No\. \w+)',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_paid_to_by',
    bankCode: 'PAYTM',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'(?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) paid to (?<merchant>.+?) by \w+ +on '
      r'.*?Paytm Transaction id: ?(?<ref>\d+)',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'paytm_paid_with_ref',
    bankCode: 'PAYTM',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'Paid (?<amount>Rs\.?\s*[0-9][0-9,]*(?:\.\d+)?) to (?<merchant>.+?) on '
      r'[A-Za-z]{3} \d{1,2}, \d{4} [0-9:]+ with Ref: ?(?<ref>\d+)',
      caseSensitive: false,
    ),
  ),
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

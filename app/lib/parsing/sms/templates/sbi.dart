import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

// Amount with or without a currency: "Rs78.0", "Rs.1,000.00", "INR 500",
// SBI UPI's bare "debited by 124.00".
const _amt = r'(?<amount>(?:Rs\.?|INR|₹)?\s*[0-9][0-9,]*(?:\.\d+)?)';
const _upiDate = r'(?<date>\d{1,2}[A-Za-z]{3}\d{2,4})';

List<SmsTemplate> sbiTemplates() => [
  // Formats below are from real SBI / SBI Card messages (2020–2026).
  SmsTemplate(
    id: 'sbi_upi_debit_trf',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Dear UPI user A/C X?(?<account>\d{4}) debited by ',
        _amt,
        r' on date ',
        _upiDate,
        r' trf to (?<merchant>.+?) Refno (?<ref>\d{12})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_upi_debit_transfer',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'your A/c X?(?<account>\d{4})-debited by ',
        _amt,
        r' on ',
        _upiDate,
        r' transfer to (?<merchant>.+?) Ref No (?<ref>\d{12})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_upi_credit_transfer',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'your A/c X?(?<account>\d{4})-credited by ',
        _amt,
        r' on ',
        _upiDate,
        r' transfer from (?<merchant>.+?) Ref No (?<ref>\d{12})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_upi_credit_by',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'ur A/c ?X?(?<account>\d{4}) credited (?:by|with) ',
        _amt,
        r' on ',
        _upiDate,
        r' (?:by (?<merchant>[^()]*?) ?|against (?<remarks>reversal of txn) ?)?'
            r'\(Ref no (?<ref>\d{12})\)',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_upi_debited_at',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        _amt,
        r' debited\W?SBI UPI frm A/c ?X?(?<account>\d{4}) on ',
        _upiDate,
        r' RefNo (?<ref>\d{12})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_card_spent',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'(?<amount>(?:Rs\.?|INR)\s*[0-9][0-9,]*(?:\.\d+)?) spent on your (?:SBI )?'
      r'(?:Credit )?Card ending (?:with )?X*(?<account>\d{4}) at (?<merchant>.+?) '
      r'on (?<date>\d{2}/\d{2}/\d{2,4})',
      caseSensitive: false,
    ),
    externalRefBuilder: (f) =>
        'SBI-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
  ),
  SmsTemplate(
    id: 'sbi_card_emandate',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'Transaction of (?<amount>(?:Rs\.?|INR)\s*[0-9][0-9,]*(?:\.\d+)?) at '
      r'(?<merchant>.+?) against E-mandate .*? has been debited to your SBI Credit '
      r'Card ending (?<account>\d{4}) on (?<date>\d{2}-\d{2}-\d{2,4})',
      caseSensitive: false,
    ),
    externalRefBuilder: (f) =>
        'SBI-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
  ),
  SmsTemplate(
    id: 'sbi_card_payment_received',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      r'received payment of (?<amount>(?:Rs\.?|INR)\s*[0-9][0-9,]*(?:\.\d+)?) '
      r'via (?<merchant>.+?) & the same has been credited to your SBI Credit Card',
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_card_reversal',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        _amt,
        r' has been credited to your SBI Credit Card x*(?<account>\d{4}), '
            r'towards (?<remarks>reversal/cashback) from (?<merchant>.+?) for trxn',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_card_payment_processed',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'payment of ',
        _amt,
        r' for your SBI Credit Card has been successfully '
            r'processed\. ref no : (?<ref>\w+)',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_card_fee_waiver',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'(?<merchant>Annual fee waiver) of ',
        _amt,
        r' has been credited to your SBI Card ending (?<account>\d{4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_loan_disbursal',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'(?<merchant>Loan) of ',
        _amt,
        r' disbursed from Loan A/c No X*\d+ and '
            r'credit to A/c No X*\d*?(?<account>\d{4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_account_debited',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Your A/?C X*\d*?(?<account>\d{4}) Debited ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4}) ?-(?:Transferred to )?'
            r'(?<merchant>.+?)\.? Avl Bal(?:ance)? (?<balance>INR [0-9,]+\.\d{2})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_account_credited',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Your A/?C X*\d*?(?<account>\d{4}) Credited ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4}) ?-(?:Deposit by transfer from )?'
            r'(?<merchant>.+?)\.? Avl Bal(?:ance)? (?<balance>INR [0-9,]+\.\d{2})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_account_nach',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Your A/?C X*\d*?(?<account>\d{4}) has a debit by (?<merchant>NACH) of ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_account_upi_credit',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Your A/?C X*\d*?(?<account>\d{4}) has credit for UPI/(?<ref>\d{12})/\S* of ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_account_credit_for',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Your A/?C X*\d*?(?<account>\d{4}) has credit for (?<merchant>.+?) of ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_neft_credit',
    bankCode: 'SBI',
    type: TransactionType.neft,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        _amt,
        r' credited to your A/c No X*(?<account>\d{4}) on '
            r'(?<date>\d{2}/\d{2}/\d{2,4}) through NEFT with UTR (?<ref>[A-Z0-9]+) '
            r'by (?<merchant>.+?),? INFO:',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_imps_credit',
    bankCode: 'SBI',
    type: TransactionType.imps,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'a/c no\. X*(?<account>\d{4}) is credited by ',
        _amt,
        r' on (?<date>\d{2}-\d{2}-\d{2,4}) by (?<merchant>.+?) \(IMPS Ref no (?<ref>\d{12})\)',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_standing_instruction',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'(?<remarks>SI\d+) executed successfully through State Bank Internet banking\. '
            r'Your Transaction Ref No is (?<ref>\w+) for ',
        _amt,
        r' on (?<date>\d{2}-[A-Za-z]{3}-\d{2,4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_debit_card',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'transaction number (?<ref>\d+) for ',
        _amt,
        r' by SBI Debit Card X?(?<account>\d{4}) (?:done )?at (?<merchant>\S+) on ',
        _upiDate,
        r' at (?<time>\d{2}:\d{2}:\d{2})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_upi_debit_ref_old',
    bankCode: 'SBI',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'ur A/c ?X?(?<account>\d{4}) - debited by ',
        _amt,
        r' on ',
        _upiDate,
        r' Ref No (?<ref>\d{12})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_inb_transfer',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Thx for INB txn of ',
        _amt,
        r' frm A/c X?(?<account>\d{4}) to '
            r'(?<merchant>.+?)\.* ref#? ?(?<ref>\w+) on ',
        _upiDate,
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_atm_withdrawn_at',
    bankCode: 'SBI',
    type: TransactionType.atm,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        _amt,
        r' withdrawn at (?<merchant>.+? ATM \S*) from A/c ?X?(?<account>\d{4}) on ',
        _upiDate,
        r' Transaction Number (?<ref>\d+)',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_yono_cash',
    bankCode: 'SBI',
    type: TransactionType.atm,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'(?<merchant>Yono Cash) ',
        _amt,
        r' w/d@.+? fm A/c ?X?(?<account>\d{4}) on ',
        _upiDate,
        r' Ref#(?<ref>\d+)',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_debit_card_used',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'SBIDrCard X?(?<account>\d{4}) used for ',
        _amt,
        r' on ?',
        _upiDate,
        r' at ?(?<merchant>\S+) Txn#(?<ref>\w+)',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_debit_card_emandate',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Payment of ',
        _amt,
        r' for (?<merchant>.+?) e-mandate .*? processed '
            r'successfully on your SBI Debit card ending (?<account>\d{4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_card_merchant_refund',
    bankCode: 'SBI',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Trxn\. of ',
        _amt,
        r' on your SBI Credit Card ending (?<account>\d{4}) at '
            r'(?<merchant>.+?) dated (?<date>\d{2}-\d{2}-\d{2,4}) has been cancelled and '
            r'refunded',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'sbi_it_refund',
    bankCode: 'SBI',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'An (?<merchant>IT Refund) amount of ',
        _amt,
        r' for AY-\S+ has been credited to your account X*(?<account>\d{4}) on '
            r'(?<date>\d{4}-\d{2}-\d{2})',
      ].join(),
      caseSensitive: false,
    ),
  ),
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

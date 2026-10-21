import '../../../core/models/transaction_type.dart';
import '../template.dart';

const _amt = r'(?<amount>(?:Rs\.?|INR\.?)\s*[0-9][0-9,]*(?:\.\d+)?)';

/// IDFC FIRST Bank, from real messages (2024–2026).
List<SmsTemplate> idfcTemplates() => [
  SmsTemplate(
    id: 'idfc_upi_debit',
    bankCode: 'IDFC',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Your A/c X*(?<account>\d{4}) debited by ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4}); (?<merchant>.+?) credited\. '
            r'RRN (?<ref>\d{12})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'idfc_debit',
    bankCode: 'IDFC',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Your A/C X*\d*?(?<account>\d{4}) is debited by ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4}) (?<time>\d{2}:\d{2})\. '
            r'New Bal ?:(?<balance>INR [0-9,]+\.\d{2})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'idfc_credit',
    bankCode: 'IDFC',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Your A/C X*\d*?(?<account>\d{4}) is credited with ',
        _amt,
        r' on (?<date>\d{2}/\d{2}/\d{2,4}) (?<time>\d{2}:\d{2})\. '
            r'Your new balance is (?<balance>INR [0-9,]+\.\d{2})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'idfc_credit_info',
    bankCode: 'IDFC',
    type: TransactionType.neft,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Your A/c X*(?<account>\d{4}) has been credited with ',
        _amt,
        r' on (?<date>\d{2}-\d{2}-\d{4})\. Info: (?<remarks>(?:NEFT|IMPS|RTGS)/'
            r'(?<ref>[A-Z0-9]+)/(?<merchant>[^.]+))\.',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'idfc_interest',
    bankCode: 'IDFC',
    type: TransactionType.other,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Monthly (?<merchant>interest) of ',
        _amt,
        r' earned on your Savings A/c X*(?<account>\d{4}) has been credited '
            r'to your A/C on (?<date>\d{2}/\d{2}/\d{2,4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'idfc_card_spent',
    bankCode: 'IDFC',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      [
        r'Spent ',
        _amt,
        r' from A/C X*(?<account>\d{4}) at (?<merchant>.+?) '
            r'on (?<date>\d{2}/\d{2}/\d{2,4})',
      ].join(),
      caseSensitive: false,
    ),
  ),
  SmsTemplate(
    id: 'idfc_dispute_refund',
    bankCode: 'IDFC',
    type: TransactionType.upi,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      [
        r'Your (?<merchant>refund) of ',
        _amt,
        r' ?for your UPI Transaction Dispute is successfully processed',
      ].join(),
      caseSensitive: false,
    ),
  ),
];

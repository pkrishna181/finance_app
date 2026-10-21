import '../../../core/models/transaction_type.dart';
import '../extractors.dart';
import '../template.dart';

/// IndusInd Bank credit card, from real messages (2026).
List<SmsTemplate> indusindTemplates() => [
  SmsTemplate(
    id: 'indusind_card_spent',
    bankCode: 'INDUSIND',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.debit,
    pattern: RegExp(
      r'(?<amount>INR [0-9][0-9,]*(?:\.\d+)?) spent on IndusInd Card X*(?<account>\d{4}) '
      r'on (?<date>\d{2}-\d{2}-\d{4}) (?<time>\d{2}:\d{2}:\d{2} [ap]m) at '
      r'(?:UPI )?(?<merchant>.+?)\. Avl Lmt',
      caseSensitive: false,
    ),
    externalRefBuilder: (f) =>
        'INDUSIND-${f.accountHint ?? 'XXXX'}-${formatDayKey(f.bookedAt)}-${f.amountPaise}',
  ),
  SmsTemplate(
    id: 'indusind_card_payment',
    bankCode: 'INDUSIND',
    type: TransactionType.card,
    fixedDirection: TransactionDirection.credit,
    pattern: RegExp(
      r'thank you for your Payment of (?<amount>INR [0-9][0-9,]*(?:\.\d+)?) towards '
      r'your IndusInd Bank Credit Card on (?<date>\d{2}/\d{2}/\d{4})',
      caseSensitive: false,
    ),
  ),
];

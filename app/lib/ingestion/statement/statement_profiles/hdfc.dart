import 'profile.dart';

StatementProfile hdfcAccountProfile() => StatementProfile(
      id: 'hdfc_account',
      bankCode: 'HDFC',
      junkMarkers: const [
        'hdfc bank',
        'account branch',
        'statement of account',
        'opening balance',
        'closing balance',
        'unless the constituent',
      ],
      headerSynonyms: {
        StatementField.date: ['date', 'transaction date'],
        StatementField.narration: ['narration'],
        StatementField.ref: ['chq/ref no', 'ref no'],
        StatementField.debit: ['withdrawal amt.', 'withdrawal amt'],
        StatementField.credit: ['deposit amt.', 'deposit amt'],
        StatementField.balance: ['closing balance'],
      },
    );

StatementProfile hdfcCreditCardProfile() => StatementProfile(
      id: 'hdfc_cc',
      bankCode: 'HDFC',
      isCreditCard: true,
      junkMarkers: const [
        'credit card',
        'card statement',
        'payment due',
        'total amount due',
      ],
      headerSynonyms: {
        StatementField.date: ['date', 'transaction date'],
        StatementField.narration: ['description', 'transaction description'],
        StatementField.amount: ['amount'],
        StatementField.drcrFlag: ['cr/dr', 'dr/cr'],
      },
    );

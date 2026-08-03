import 'profile.dart';

StatementProfile iciciAccountProfile() => StatementProfile(
      id: 'icici_account',
      bankCode: 'ICICI',
      junkMarkers: const [
        'icici bank',
        'account statement',
        'customer id',
        'transaction list',
      ],
      headerSynonyms: {
        StatementField.date: ['transaction date', 'value date'],
        StatementField.narration: ['transaction remarks', 'particulars'],
        StatementField.ref: ['cheque number', 'txn id'],
        StatementField.amount: ['amount'],
        StatementField.drcrFlag: ['type', 'cr/dr'],
        StatementField.balance: ['balance'],
      },
    );

StatementProfile iciciCreditCardProfile() => StatementProfile(
      id: 'icici_cc',
      bankCode: 'ICICI',
      isCreditCard: true,
      junkMarkers: const ['icici bank credit card', 'statement period'],
      headerSynonyms: {
        StatementField.date: ['date'],
        StatementField.narration: ['details', 'description'],
        StatementField.amount: ['amount (in rs)'],
      },
    );

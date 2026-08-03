import 'profile.dart';

StatementProfile kotakAccountProfile() => StatementProfile(
      id: 'kotak_account',
      bankCode: 'KOTAK',
      junkMarkers: const [
        'kotak mahindra bank',
        'account statement',
      ],
      headerSynonyms: {
        StatementField.date: ['date'],
        StatementField.narration: ['narration'],
        StatementField.ref: ['chq/ref number'],
        StatementField.debit: ['withdrawal'],
        StatementField.credit: ['deposit'],
        StatementField.balance: ['balance'],
      },
    );

import 'profile.dart';

StatementProfile sbiAccountProfile() => StatementProfile(
      id: 'sbi_account',
      bankCode: 'SBI',
      junkMarkers: const [
        'state bank of india',
        'account name',
        'branch',
        'statement from',
      ],
      headerSynonyms: {
        StatementField.date: ['txn date', 'value date'],
        StatementField.narration: ['description'],
        StatementField.ref: ['ref no./cheque no.', 'ref no'],
        StatementField.debit: ['debit'],
        StatementField.credit: ['credit'],
        StatementField.balance: ['balance'],
      },
    );

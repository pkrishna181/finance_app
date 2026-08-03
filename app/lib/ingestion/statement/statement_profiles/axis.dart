import 'profile.dart';

StatementProfile axisAccountProfile() => StatementProfile(
      id: 'axis_account',
      bankCode: 'AXIS',
      junkMarkers: const [
        'axis bank',
        'account statement',
        'customer name',
      ],
      headerSynonyms: {
        StatementField.date: ['tran date', 'value date'],
        StatementField.narration: ['particulars'],
        StatementField.debit: ['debit amount'],
        StatementField.credit: ['credit amount'],
        StatementField.balance: ['balance amount'],
      },
    );

StatementProfile axisCreditCardProfile() => StatementProfile(
      id: 'axis_cc',
      bankCode: 'AXIS',
      isCreditCard: true,
      junkMarkers: const ['axis bank credit card', 'statement summary'],
      headerSynonyms: {
        StatementField.date: ['date'],
        StatementField.narration: ['transaction details'],
        StatementField.amount: ['amount'],
      },
    );

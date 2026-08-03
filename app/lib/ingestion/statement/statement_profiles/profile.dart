/// Canonical statement columns.
enum StatementField {
  date,
  narration,
  ref,
  debit,
  credit,
  amount,
  drcrFlag,
  balance,
}

final genericSynonyms = <StatementField, List<String>>{
  StatementField.date: [
    'date',
    'txn date',
    'transaction date',
    'value date',
    'tran date',
    'posting date',
  ],
  StatementField.narration: [
    'narration',
    'description',
    'particulars',
    'remarks',
    'transaction remarks',
    'details',
  ],
  StatementField.ref: [
    'ref',
    'ref no',
    'reference',
    'chq',
    'cheque',
    'transaction id',
    'utr',
  ],
  StatementField.debit: [
    'withdrawal',
    'withdrawal amt',
    'withdrawal amount',
    'debit',
    'debit amount',
    'dr amount',
  ],
  StatementField.credit: [
    'deposit',
    'deposit amt',
    'deposit amount',
    'credit',
    'credit amount',
    'cr amount',
  ],
  StatementField.amount: [
    'amount',
    'txn amount',
    'transaction amount',
  ],
  StatementField.drcrFlag: [
    'dr/cr',
    'cr/dr',
    'type',
    'debit/credit',
    'transaction type',
  ],
  StatementField.balance: [
    'balance',
    'closing balance',
    'running balance',
    'available balance',
  ],
};

class StatementProfile {
  const StatementProfile({
    required this.id,
    required this.bankCode,
    required this.headerSynonyms,
    this.junkMarkers = const [],
    this.isCreditCard = false,
  });

  final String id;
  final String bankCode;
  final Map<StatementField, List<String>> headerSynonyms;
  final List<String> junkMarkers;
  final bool isCreditCard;
}

import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import 'printed_totals.dart';
import 'statement_digest.dart';

/// An imported bank or card statement.
class StoredStatement {
  const StoredStatement({
    required this.importId,
    required this.fileName,
    required this.importedAt,
    required this.bankCode,
    required this.isCard,
    required this.last4,
    required this.periodStart,
    required this.periodEnd,
    required this.transactionCount,
  });

  final int importId;
  final String fileName;
  final DateTime importedAt;
  final String? bankCode;
  final bool isCard;
  final String? last4;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int transactionCount;
}

/// Imported statements and their summaries, rebuilt from the rows each
/// import brought in (including rows an SMS had already recorded) and the
/// totals stored when it was imported.
class StatementHistory {
  StatementHistory(this._db);

  final ArthDatabase _db;

  Future<List<StoredStatement>> list() async {
    final rows = await _db
        .customSelect(
          '''
SELECT i.id, i.source_label, i.imported_at, s.bank_code, s.account_kind,
       s.last4, s.printed_json, s.period_end,
       (SELECT COUNT(*) FROM transaction_imports ti WHERE ti.import_id = i.id)
         AS n,
       (SELECT MIN(t.booked_at) FROM transactions t
          JOIN transaction_imports ti ON ti.transaction_id = t.id
         WHERE ti.import_id = i.id) AS first_day
FROM imports i
LEFT JOIN statement_summaries s ON s.import_id = i.id
WHERE i.source_type IN ('pdf', 'csv', 'excel') AND i.status = 'succeeded'
ORDER BY i.imported_at DESC, i.id DESC
''',
          readsFrom: {
            _db.imports,
            _db.statementSummaries,
            _db.transactionImports,
            _db.transactions,
          },
        )
        .get();
    return [
      for (final r in rows)
        () {
          final printed = PrintedTotals.decode(
            r.readNullable<String>('printed_json'),
          );
          return StoredStatement(
            importId: r.read<int>('id'),
            fileName: r.read<String>('source_label'),
            importedAt: r.read<DateTime>('imported_at'),
            bankCode: r.readNullable<String>('bank_code'),
            isCard: r.readNullable<String>('account_kind') == 'card',
            last4: r.readNullable<String>('last4'),
            periodStart:
                printed.periodStart ?? r.readNullable<DateTime>('first_day'),
            periodEnd:
                printed.periodEnd ?? r.readNullable<DateTime>('period_end'),
            transactionCount: r.read<int>('n'),
          );
        }(),
    ];
  }

  Future<StatementDigest?> digest(int importId) async {
    final s = await (_db.select(
      _db.statementSummaries,
    )..where((t) => t.importId.equals(importId))).getSingleOrNull();
    final rows = await _db
        .customSelect(
          'SELECT t.booked_at, t.amount_paise, t.direction, t.raw_merchant, '
          't.raw_description FROM transactions t '
          'JOIN transaction_imports ti ON ti.transaction_id = t.id '
          'WHERE ti.import_id = ? ORDER BY t.booked_at, t.id',
          variables: [Variable<int>(importId)],
          readsFrom: {_db.transactions, _db.transactionImports},
        )
        .get();
    if (s == null && rows.isEmpty) return null;
    return StatementDigest.build(
      rows: [
        for (final r in rows)
          DigestRow(
            date: r.read<DateTime>('booked_at'),
            paise: r.read<int>('amount_paise'),
            isDebit: r.read<String>('direction') == 'debit',
            merchant: r.read<String>('raw_merchant'),
            description: r.read<String>('raw_description'),
          ),
      ],
      printed: PrintedTotals.decode(s?.printedJson),
      bankCode: s?.bankCode ?? 'UNKNOWN',
      isCard: s?.accountKind == 'card',
      last4: s?.last4,
      instalmentsPaise: s?.instalmentsPaise ?? 0,
      instalmentCount: s?.instalmentCount ?? 0,
    );
  }
}

import '../core/db/database.dart';
import 'credit_card_repository.dart';
import 'doctor.dart';
import 'insights_repository.dart';

/// Loads the last 13 months plus the counts [DataDoctor] needs.
Future<List<DoctorFinding>> runDataDoctor(
  ArthDatabase db, {
  DateTime? asOf,
  DataDoctor doctor = const DataDoctor(),
}) async {
  final now = asOf ?? DateTime.now();
  final txns = await InsightsRepository(db).loadRange(
    DateTime(now.year, now.month - 13, 1),
    DateTime(now.year, now.month, now.day + 1),
  );
  final rows = await db.customSelect(
    'SELECT COUNT(*) AS n FROM unparsed_statement_rows WHERE resolved = 0',
    readsFrom: {db.unparsedStatementRows},
  ).getSingle();
  return doctor.run(
    txns,
    DoctorContext(
      asOf: now,
      unresolvedSms: await db.countUnresolvedUnparsedSms(),
      unresolvedStatementRows: rows.read<int>('n'),
      untrackedCards: (await CreditCardRepository(db).suggestions()).length,
    ),
  );
}

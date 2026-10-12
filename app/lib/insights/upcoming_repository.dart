import '../core/db/database.dart';
import 'credit_card_repository.dart';
import 'insights_repository.dart';
import 'loan_repository.dart';
import 'upcoming.dart';

class UpcomingRepository {
  UpcomingRepository(this._db);

  final ArthDatabase _db;

  /// Everything due from [from] for [days] days.
  Future<List<UpcomingEvent>> events(DateTime from, {int days = 60}) async {
    final recurring = await InsightsRepository(_db)
        .loadRecurring(asOf: from, persist: false);
    return const UpcomingCalendar().build(
      from: from,
      to: from.add(Duration(days: days)),
      recurring: recurring,
      loans: await LoanRepository(_db).list(),
      cards: await CreditCardRepository(_db).statuses(from),
    );
  }
}

import '../core/db/database.dart';
import 'credit_card_repository.dart';
import 'goal_repository.dart';
import 'loan_repository.dart';
import 'net_worth_repository.dart';
import 'portfolio_repository.dart';
import 'schedule_al.dart';
import 'yearly.dart';

/// Builds Schedule AL for a financial year from everything Arth knows.
class ScheduleAlRepository {
  ScheduleAlRepository(this._db);

  final ArthDatabase _db;

  Future<ScheduleAl> build(FinancialYear fy) async {
    final asOf = DateTime(fy.startYear + 1, 3, 31, 23, 59);
    final items = <AlItem>[];

    final goals = GoalRepository(_db);
    for (final a in await goals.balanceAccounts()) {
      final b = await goals.balanceAt(a.ref, asOf);
      if (b == null || b <= 0) continue;
      items.add(
        AlItem(
          section: AlSection.bank,
          label: '${a.bankCode} ••${a.last4}',
          amountPaise: b,
        ),
      );
    }

    final portfolio = await PortfolioRepository(_db).summary(asOf);
    for (final p in portfolio.positions) {
      final cost = p.investedPaise;
      items.add(
        AlItem(
          section: AlSection.securities,
          label: p.input.name,
          amountPaise: cost ?? p.valuePaise,
          atCost: cost != null,
        ),
      );
    }

    for (final a in await NetWorthRepository(_db).assets(asOf)) {
      items.add(
        AlItem(
          section: alSectionOfManual(a.kind),
          label: a.name,
          // FDs: the principal entered is the cost; others are the value the
          // user recorded (may not be the purchase cost).
          amountPaise: a.kind == 'fd' ? a.recordedPaise : a.currentPaise,
          atCost:
              a.kind == 'fd' ||
              a.kind == 'ppf' ||
              a.kind == 'epf' ||
              a.kind == 'cash' ||
              a.kind == 'loan',
        ),
      );
    }

    for (final l in await LoanRepository(_db).statuses(asOf)) {
      if (l.outstandingPaise <= 0 || l.loan.firstEmiDate.isAfter(asOf)) {
        continue;
      }
      items.add(
        AlItem(
          section: AlSection.liabilities,
          label: l.loan.name,
          amountPaise: l.outstandingPaise,
        ),
      );
    }
    for (final c in await CreditCardRepository(_db).statuses(asOf)) {
      if (c.outstandingPaise <= 0) continue;
      items.add(
        AlItem(
          section: AlSection.liabilities,
          label: c.card.name,
          amountPaise: c.outstandingPaise,
        ),
      );
    }
    return ScheduleAl(asOf: DateTime(fy.startYear + 1, 3, 31), items: items);
  }
}

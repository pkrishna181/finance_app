import 'package:arth/core/db/database.dart';
import 'package:arth/core/notifications/reminder_service.dart';
import 'package:arth/insights/insights.dart';
import 'package:arth/ui/screens/reminders_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeScheduler implements NotificationScheduler {
  bool permission = true;
  final scheduled = <PlannedReminder>[];
  final shown = <PlannedReminder>[];
  int cancels = 0;

  @override
  Future<bool> requestPermission() async => permission;
  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled.clear();
  }

  @override
  Future<void> schedule(PlannedReminder r) async => scheduled.add(r);
  @override
  Future<void> showNow(PlannedReminder r) async => shown.add(r);
}

const planner = ReminderPlanner();
final now = DateTime(2026, 10, 12, 8, 30);

UpcomingEvent ev(UpcomingKind k, DateTime d, String label,
        {int paise = 100000, bool overdue = false, bool est = false}) =>
    UpcomingEvent(
        date: d,
        kind: k,
        label: label,
        amountPaise: paise,
        overdue: overdue,
        estimated: est);

void main() {
  test('timing per kind, at 9 am', () {
    final p = planner.plan(now: now, events: [
      ev(UpcomingKind.cardDue, DateTime(2026, 10, 20), 'Regalia'),
      ev(UpcomingKind.loanEmi, DateTime(2026, 10, 15), 'Home loan'),
      ev(UpcomingKind.subscription, DateTime(2026, 10, 18), 'Netflix', est: true),
    ], enabled: ReminderGroup.values.toSet());
    final byTitle = {for (final r in p) '${r.title}|${r.when}': r};
    expect(byTitle.keys, containsAll([
      'Card bill due in 3 days|${DateTime(2026, 10, 17, 9)}',
      'Card bill due today|${DateTime(2026, 10, 20, 9)}',
      'EMI tomorrow|${DateTime(2026, 10, 14, 9)}',
      'Renewal tomorrow|${DateTime(2026, 10, 17, 9)}',
    ]));
    expect(p.firstWhere((r) => r.title == 'Renewal tomorrow').body,
        'Netflix: about ₹1,000.');
    expect(p.map((r) => r.when), orderedEquals([...p.map((r) => r.when)]..sort()));
  });

  test('past reminders are skipped; one passed earlier today goes out now', () {
    final late = DateTime(2026, 10, 12, 11);
    final p = planner.plan(now: late, events: [
      ev(UpcomingKind.cardDue, DateTime(2026, 10, 12), 'Due today'),
      ev(UpcomingKind.loanEmi, DateTime(2026, 10, 12), 'EMI today'), // eve passed
    ], enabled: ReminderGroup.values.toSet());
    expect(p.map((r) => r.title), ['Card bill due today']);
    expect(p.single.when, late.add(const Duration(minutes: 1)));
  });

  test('overdue card bills remind today; groups can be turned off', () {
    final events = [
      ev(UpcomingKind.cardDue, DateTime(2026, 10, 12), 'Axis', overdue: true),
      ev(UpcomingKind.sip, DateTime(2026, 10, 20), 'Flexi Cap SIP'),
    ];
    final bills = planner.plan(
        now: now, events: events, enabled: {ReminderGroup.bills});
    expect(bills.single.title, 'Card bill overdue');
    expect(bills.single.when, DateTime(2026, 10, 12, 9));
    final subs = planner.plan(
        now: now, events: events, enabled: {ReminderGroup.subscriptions});
    expect(subs.single.title, 'SIP tomorrow');
  });

  test('ids are stable across re-planning', () {
    final e = [ev(UpcomingKind.loanEmi, DateTime(2026, 10, 15), 'Home loan')];
    final a = planner.plan(now: now, events: e);
    final b = planner.plan(now: now.add(const Duration(hours: 1)), events: e);
    expect(a.single.id, b.single.id);
    expect(a.single.id, isNonNegative);
  });

  test('budget alerts fire once per level per month', () {
    BudgetProgress b(int spent) => BudgetProgress(
          slug: 'groceries',
          name: 'Groceries',
          limitPaise: 1000000,
          carryPaise: 0,
          spentPaise: spent,
          status: spent > 1000000
              ? BudgetStatus.over
              : spent >= 800000
                  ? BudgetStatus.warning
                  : BudgetStatus.ok,
        );
    final warn = planner.budgetAlerts(
        now: now, budgets: [b(850000)], announced: {});
    expect(warn.single.$1.title, 'Groceries budget at 85%');
    expect(planner.budgetAlerts(
        now: now, budgets: [b(900000)], announced: {'groceries': warn.single.$3}),
        isEmpty);
    final over = planner.budgetAlerts(
        now: now, budgets: [b(1100000)], announced: {'groceries': warn.single.$3});
    expect(over.single.$1.title, 'Groceries budget exceeded');
  });

  group('ReminderService', () {
    late ArthDatabase db;
    late FakeScheduler fake;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = ArthDatabase.memory();
      fake = FakeScheduler();
      await LoanRepository(db).save(
        name: 'Car loan',
        kind: 'car',
        principalPaise: 50000000,
        rateBp: 900,
        tenureMonths: 60,
        firstEmiDate: DateTime(2026, 1, 20),
      );
    });
    tearDown(() => db.close());

    test('off by default; enabling needs permission; sync schedules', () async {
      final svc = ReminderService(db, scheduler: fake);
      expect(await svc.sync(now: now), 0);
      fake.permission = false;
      expect(await svc.enable(), isFalse);
      expect(await svc.isEnabled(), isFalse);
      fake.permission = true;
      expect(await svc.enable(), isTrue);
      final n = await svc.sync(now: now);
      expect(n, greaterThan(0));
      expect(fake.scheduled.first.title, 'EMI tomorrow');
      expect(fake.scheduled.first.when, DateTime(2026, 10, 19, 9));
      // Re-sync replaces rather than piles up.
      await svc.sync(now: now);
      expect(fake.scheduled, hasLength(n));
      await svc.disable();
      expect(fake.scheduled, isEmpty);
    });

    test('budget alert sent once, not on every sync', () async {
      final cat = (await db.categoryBySlug('groceries'))!.id;
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amountPaise: 900000,
            direction: 'debit',
            txnType: 'upi',
            bookedAt: DateTime(2026, 10, 5),
            bankCode: 'HDFC',
            rawMerchant: 'DMART',
            rawDescription: 'DMART',
            dedupeHash: 'g',
            categoryId: Value(cat),
          ));
      await BudgetRepository(db).upsert('groceries',
          limitPaise: 1000000, rollover: false, start: MonthKey(2026, 10));
      final svc = ReminderService(db, scheduler: fake);
      await svc.enable();
      await svc.sync(now: now);
      await svc.sync(now: now);
      expect(fake.shown.map((r) => r.title), ['Groceries budget at 90%']);
    });
  });

  testWidgets('reminders screen toggles and lists groups', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    final fake = FakeScheduler();
    await tester.pumpWidget(MaterialApp(
      home: RemindersScreen(database: db, scheduler: fake),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    expect(find.text('Card bills and EMIs'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    expect(find.textContaining('reminders scheduled for the next 30 days'),
        findsOneWidget);
  });
}

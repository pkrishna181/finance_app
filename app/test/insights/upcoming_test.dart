import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:arth/ui/screens/upcoming_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RecurringSeries series(
  String label,
  Cadence c,
  DateTime next, {
  String kind = 'subscription',
  int paise = 64900,
  DateTime? mandate,
  bool active = true,
}) =>
    RecurringSeries(
      key: label,
      label: label,
      merchantId: null,
      cadence: c,
      kind: kind,
      lastAmountPaise: paise,
      lastSeen: next.subtract(const Duration(days: 30)),
      nextExpected: next,
      occurrences: 5,
      txnIds: const [],
      confidence: 1,
      active: active,
      mandateDate: mandate,
    );

const cal = UpcomingCalendar();
final today = DateTime(2026, 10, 12);

void main() {
  test('steps recurring series through the window', () {
    final e = cal.build(
      from: today,
      to: DateTime(2026, 12, 31),
      recurring: [
        series('Netflix', Cadence.monthly, DateTime(2026, 10, 20)),
        series('Gym', Cadence.weekly, DateTime(2026, 10, 14)),
        series('Domain', Cadence.annual, DateTime(2027, 2, 1)),
        series('Old', Cadence.monthly, DateTime(2026, 10, 20), active: false),
      ],
    );
    final netflix = e.where((x) => x.label == 'Netflix').map((x) => x.date);
    expect(netflix, [
      DateTime(2026, 10, 20),
      DateTime(2026, 11, 20),
      DateTime(2026, 12, 20),
    ]);
    expect(e.where((x) => x.label == 'Gym'), hasLength(12));
    expect(e.any((x) => x.label == 'Domain' || x.label == 'Old'), isFalse);
    expect(e.first.estimated, isTrue);
  });

  test('mandate date is exact; recently missed ones show as overdue', () {
    final e = cal.build(from: today, to: DateTime(2026, 10, 31), recurring: [
      series('SIP', Cadence.monthly, DateTime(2026, 10, 25),
          kind: 'sip', mandate: DateTime(2026, 10, 24)),
      series('Spotify', Cadence.monthly, DateTime(2026, 10, 8)),
      series('Ancient', Cadence.monthly, DateTime(2026, 9, 1)),
    ]);
    final sip = e.singleWhere((x) => x.label == 'SIP');
    expect(sip.date, DateTime(2026, 10, 24));
    expect(sip.estimated, isFalse);
    expect(sip.kind, UpcomingKind.sip);
    final spotify = e.singleWhere((x) => x.label == 'Spotify');
    expect(spotify.overdue, isTrue);
    expect(spotify.date, today);
    expect(e.any((x) => x.label == 'Ancient'), isFalse); // > 7 days ago
  });

  test('loan EMI replaces the matching eNACH series; card dues included', () {
    final loan = LoanDef(
      id: 1,
      name: 'Home loan',
      kind: 'home',
      principalPaise: 100000000,
      rateBp: 900,
      tenureMonths: 120,
      firstEmiDate: DateTime(2025, 5, 5),
    );
    final emi = const LoanCalculator().status(loan, today).emiPaise;
    const card = CardDef(id: 1, bankCode: 'HDFC', name: 'Regalia', last4: '4455');
    final e = cal.build(
      from: today,
      to: DateTime(2026, 11, 30),
      loans: [loan],
      recurring: [
        series('SBI HOME LOAN', Cadence.monthly, DateTime(2026, 11, 6),
            kind: 'enach', paise: emi),
      ],
      cards: [
        CardStatus(
          card: card,
          state: CardBillState.due,
          unbilledPaise: 0,
          dueDate: DateTime(2026, 10, 15),
          billPaise: 1200000,
        ),
      ],
    );
    expect(e.where((x) => x.kind == UpcomingKind.loanEmi).map((x) => x.date),
        [DateTime(2026, 11, 5)]);
    expect(e.any((x) => x.kind == UpcomingKind.emi), isFalse);
    final bill = e.singleWhere((x) => x.kind == UpcomingKind.cardDue);
    expect(bill.date, DateTime(2026, 10, 15));
    expect(bill.amountPaise, 1200000);
    expect(bill.label, 'Regalia ••4455');
    expect(e.first, bill); // sorted by date
  });

  testWidgets('screen shows the 30-day total and filters by day',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = ArthDatabase.memory();
    addTearDown(() => tester.runAsync(db.close));
    await tester.runAsync(() => LoanRepository(db).save(
          name: 'Car loan',
          kind: 'car',
          principalPaise: 50000000,
          rateBp: 900,
          tenureMonths: 60,
          firstEmiDate: DateTime(2026, 1, 20),
        ));
    await tester.pumpWidget(MaterialApp(
      home: UpcomingScreen(database: db, now: today),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.textContaining('due in the next 30 days · 1 payment'),
        findsOneWidget);
    expect(find.text('Car loan'), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pump();
    expect(find.text('20 Oct'), findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pump();
    expect(find.text('Nov 2026'), findsOneWidget);
    expect(find.text('Car loan'), findsOneWidget);
  });
}

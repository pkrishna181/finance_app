import 'budget.dart';
import 'insight_format.dart';
import 'upcoming.dart';

enum ReminderGroup {
  /// Card bills, loan EMIs, bank mandates.
  bills,

  /// Subscriptions and SIPs.
  subscriptions,

  /// Budgets near / over the limit.
  budgets,
}

class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.group,
  });

  /// Stable per (what, when): re-planning never duplicates.
  final int id;
  final DateTime when;
  final String title;
  final String body;
  final ReminderGroup group;
}

/// Pure: decides which reminders to schedule.
class ReminderPlanner {
  const ReminderPlanner({this.hour = 9, this.maxReminders = 60});

  /// Local hour reminders go off.
  final int hour;
  final int maxReminders;

  static int stableId(String key) {
    // FNV-1a 32-bit, kept positive for Android notification ids.
    var h = 0x811c9dc5;
    for (final c in key.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h & 0x7fffffff;
  }

  DateTime _at(DateTime day) => DateTime(day.year, day.month, day.day, hour);

  List<PlannedReminder> plan({
    required DateTime now,
    required List<UpcomingEvent> events,
    Set<ReminderGroup> enabled = const {
      ReminderGroup.bills,
      ReminderGroup.subscriptions,
    },
  }) {
    final out = <PlannedReminder>[];
    void add(
      String key,
      DateTime when,
      String title,
      String body,
      ReminderGroup g,
    ) {
      if (!enabled.contains(g)) return;
      var w = when;
      if (!w.isAfter(now)) {
        // Today's reminder already passed its hour: send soon, once.
        if (w.year == now.year && w.month == now.month && w.day == now.day) {
          w = now.add(const Duration(minutes: 1));
        } else {
          return;
        }
      }
      out.add(
        PlannedReminder(
          id: stableId('$key|${w.year}-${w.month}-${w.day}'),
          when: w,
          title: title,
          body: body,
          group: g,
        ),
      );
    }

    String amount(UpcomingEvent e) => inrWhole(e.amountPaise);

    for (final e in events) {
      final day = _at(e.date);
      switch (e.kind) {
        case UpcomingKind.cardDue:
          if (e.overdue) {
            add(
              'card-overdue|${e.label}',
              _at(now),
              'Card bill overdue',
              '${e.label}: ${amount(e)} is past its due date.',
              ReminderGroup.bills,
            );
          } else {
            add(
              'card-3d|${e.label}',
              day.subtract(const Duration(days: 3)),
              'Card bill due in 3 days',
              '${e.label}: ${amount(e)} due ${e.date.day} '
                  '${monthShort(e.date.month)}.',
              ReminderGroup.bills,
            );
            add(
              'card-0d|${e.label}',
              day,
              'Card bill due today',
              '${e.label}: ${amount(e)}.',
              ReminderGroup.bills,
            );
          }
        case UpcomingKind.loanEmi:
        case UpcomingKind.emi:
          add(
            'emi|${e.label}',
            day.subtract(const Duration(days: 1)),
            'EMI tomorrow',
            '${e.label}: ${amount(e)}. Keep the balance in your account.',
            ReminderGroup.bills,
          );
        case UpcomingKind.sip:
        case UpcomingKind.subscription:
          if (e.overdue) continue;
          add(
            'sub|${e.label}',
            day.subtract(const Duration(days: 1)),
            e.kind == UpcomingKind.sip ? 'SIP tomorrow' : 'Renewal tomorrow',
            '${e.label}: ${e.estimated ? 'about ' : ''}${amount(e)}.',
            ReminderGroup.subscriptions,
          );
      }
    }
    out.sort((a, b) => a.when.compareTo(b.when));
    // Same id twice (e.g. two events folding to one key): keep the first.
    final seen = <int>{};
    final unique = [
      for (final r in out)
        if (seen.add(r.id)) r,
    ];
    return unique.take(maxReminders).toList();
  }

  /// Budget alerts to send now: budgets whose status got worse than what
  /// was last announced this month ([announced]: slug → status index).
  List<(PlannedReminder, String, int)> budgetAlerts({
    required DateTime now,
    required List<BudgetProgress> budgets,
    required Map<String, int> announced,
  }) {
    final out = <(PlannedReminder, String, int)>[];
    for (final b in budgets) {
      if (b.status == BudgetStatus.ok) continue;
      if ((announced[b.slug] ?? -1) >= b.status.index) continue;
      final over = b.status == BudgetStatus.over;
      out.add((
        PlannedReminder(
          id: stableId(
            'budget|${b.slug}|${now.year}-${now.month}|${b.status.name}',
          ),
          when: now,
          title: over
              ? '${b.name} budget exceeded'
              : '${b.name} budget at '
                    '${(b.fraction * 100).round()}%',
          body: over
              ? '${inrWhole(b.spentPaise)} spent of ${inrWhole(b.availablePaise)}.'
              : '${inrWhole(b.remainingPaise)} left for this month.',
          group: ReminderGroup.budgets,
        ),
        b.slug,
        b.status.index,
      ));
    }
    return out;
  }
}

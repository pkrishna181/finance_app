import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/notifications/reminder_service.dart';
import '../../insights/insights.dart';

/// Turn reminders on / off and choose which kinds to get.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key, this.database, this.scheduler});

  final ArthDatabase? database;

  /// Override for tests.
  final NotificationScheduler? scheduler;

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  ReminderService? _svc;
  bool? _enabled;
  Set<ReminderGroup> _groups = const {};
  int? _scheduled;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = widget.database ?? await ArthDatabase.shared();
    _svc = ReminderService(db, scheduler: widget.scheduler);
    await _load();
  }

  Future<void> _load() async {
    final e = await _svc!.isEnabled();
    final g = await _svc!.groups();
    if (mounted) {
      setState(() {
        _enabled = e;
        _groups = g;
      });
    }
  }

  Future<void> _resync() async {
    final n = await _svc!.sync();
    if (mounted) setState(() => _scheduled = n);
  }

  Future<void> _toggle(bool on) async {
    if (on) {
      final ok = await _svc!.enable();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Notifications are blocked for Arth. Allow them in '
              'your phone\'s settings.'),
        ));
      }
      if (ok) await _resync();
    } else {
      await _svc!.disable();
      _scheduled = null;
    }
    await _load();
  }

  Future<void> _setGroup(ReminderGroup g, bool on) async {
    final next = {..._groups};
    on ? next.add(g) : next.remove(g);
    await _svc!.setGroups(next);
    await _load();
    if (_enabled == true) await _resync();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final enabled = _enabled ?? false;
    String label(ReminderGroup g) => switch (g) {
          ReminderGroup.bills => 'Card bills and EMIs',
          ReminderGroup.subscriptions => 'Subscriptions and SIPs',
          ReminderGroup.budgets => 'Budget limits',
        };
    String detail(ReminderGroup g) => switch (g) {
          ReminderGroup.bills =>
            '3 days before and on a card\'s due date; the day before an EMI',
          ReminderGroup.subscriptions => 'The day before a renewal or SIP',
          ReminderGroup.budgets => 'When a budget reaches 80% and when it\'s '
              'exceeded (checked when you open Arth)',
        };
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _enabled == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  value: enabled,
                  onChanged: _toggle,
                  title: const Text('Reminders'),
                  subtitle: const Text('Sent by this phone at about 9 am'),
                ),
                const Divider(),
                for (final g in ReminderGroup.values)
                  CheckboxListTile(
                    value: _groups.contains(g),
                    onChanged: enabled ? (v) => _setGroup(g, v ?? false) : null,
                    title: Text(label(g)),
                    subtitle: Text(detail(g)),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${_scheduled == null ? '' : '$_scheduled reminders scheduled for the next 30 days. '}'
                    'Reminders are worked out and scheduled on your phone — '
                    'nothing is sent anywhere. Amounts are hidden on a locked '
                    'screen. They refresh each time you open Arth.',
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
    );
  }
}

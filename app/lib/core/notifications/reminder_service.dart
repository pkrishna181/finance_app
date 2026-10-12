import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../insights/insights.dart';
import '../db/database.dart';

/// Where reminders go. [LocalNotificationScheduler] in the app; fakes in
/// tests.
abstract class NotificationScheduler {
  Future<bool> requestPermission();
  Future<void> cancelAll();
  Future<void> schedule(PlannedReminder r);
  Future<void> showNow(PlannedReminder r);
}

/// flutter_local_notifications on the device. Notifications are marked
/// private: on a secure lock screen Android hides their content.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'arth_reminders',
    'Reminders',
    channelDescription: 'Bills, EMIs, renewals and budget alerts',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    visibility: NotificationVisibility.private,
  );

  static const _details = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }

  @override
  Future<void> schedule(PlannedReminder r) async {
    await _init();
    await _plugin.zonedSchedule(
      id: r.id,
      scheduledDate: tz.TZDateTime.from(r.when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: r.title,
      body: r.body,
    );
  }

  @override
  Future<void> showNow(PlannedReminder r) async {
    await _init();
    await _plugin.show(
      id: r.id,
      title: r.title,
      body: r.body,
      notificationDetails: _details,
    );
  }
}

/// Reminder preferences and (re)scheduling. Everything is computed and
/// scheduled on the phone; nothing is sent anywhere.
class ReminderService {
  ReminderService(this._db, {NotificationScheduler? scheduler})
    : _scheduler = scheduler ?? LocalNotificationScheduler();

  final ArthDatabase _db;
  final NotificationScheduler _scheduler;

  static const _enabledKey = 'reminders_enabled_v1';
  static const _groupsKey = 'reminders_groups_v1';
  static const _budgetKey = 'reminders_budget_announced_v1';

  Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;

  Future<Set<ReminderGroup>> groups() async {
    final raw = (await SharedPreferences.getInstance()).getStringList(
      _groupsKey,
    );
    if (raw == null) return ReminderGroup.values.toSet();
    return {
      for (final g in raw)
        if (ReminderGroup.values.any((x) => x.name == g))
          ReminderGroup.values.byName(g),
    };
  }

  Future<void> setGroups(Set<ReminderGroup> g) async =>
      (await SharedPreferences.getInstance()).setStringList(_groupsKey, [
        for (final x in g) x.name,
      ]);

  /// Asks for permission; returns whether reminders are now on.
  Future<bool> enable() async {
    final ok = await _scheduler.requestPermission();
    await (await SharedPreferences.getInstance()).setBool(_enabledKey, ok);
    return ok;
  }

  Future<void> disable() async {
    await (await SharedPreferences.getInstance()).setBool(_enabledKey, false);
    await _scheduler.cancelAll();
  }

  /// Replaces all scheduled reminders with a fresh plan for the next 30
  /// days and sends any new budget alerts. Safe to call often.
  Future<int> sync({DateTime? now}) async {
    if (!await isEnabled()) return 0;
    final t = now ?? DateTime.now();
    final enabled = await groups();
    final events = await UpcomingRepository(_db).events(t, days: 30);
    final plan = const ReminderPlanner().plan(
      now: t,
      events: events,
      enabled: enabled,
    );
    await _scheduler.cancelAll();
    for (final r in plan) {
      await _scheduler.schedule(r);
    }
    if (enabled.contains(ReminderGroup.budgets)) await _budgetAlerts(t);
    return plan.length;
  }

  Future<void> _budgetAlerts(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final month = '${now.year}-${now.month}';
    final stored = jsonDecode(prefs.getString(_budgetKey) ?? '{}') as Map;
    final announced = stored['month'] == month
        ? Map<String, int>.from(stored['status'] as Map)
        : <String, int>{};
    final repo = InsightsRepository(_db);
    final m = MonthKey.of(now);
    final budgets = const BudgetCalculator().compute(
      await repo.aggregatorFor(m),
      m,
      await BudgetRepository(_db).list(),
      await repo.categoryNames(),
      asOf: now,
    );
    for (final (r, slug, status) in const ReminderPlanner().budgetAlerts(
      now: now,
      budgets: budgets,
      announced: announced,
    )) {
      await _scheduler.showNow(r);
      announced[slug] = status;
    }
    await prefs.setString(
      _budgetKey,
      jsonEncode({'month': month, 'status': announced}),
    );
  }
}

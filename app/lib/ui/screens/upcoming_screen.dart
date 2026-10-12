import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Calendar of what's due: card bills, loan EMIs, SIPs, subscriptions.
class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  List<UpcomingEvent>? _events;
  late DateTime _month;
  DateTime? _selected;

  DateTime get _today {
    final n = widget.now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _month = DateTime(_today.year, _today.month);
    _load();
  }

  Future<void> _load() async {
    final e = await UpcomingRepository(widget.database).events(_today);
    if (mounted) setState(() => _events = e);
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    final t = Theme.of(context).textTheme;
    final in30 =
        events?.where((e) => e.date.difference(_today).inDays < 30).toList() ??
        const <UpcomingEvent>[];
    final shown = events == null
        ? const <UpcomingEvent>[]
        : _selected == null
        ? events
              .where(
                (e) =>
                    e.date.year == _month.year && e.date.month == _month.month,
              )
              .toList()
        : events.where((e) => e.date == _selected).toList();
    final lastMonth = DateTime(_today.year, _today.month + 1);
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming payments')),
      body: events == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  in30.isEmpty
                      ? 'Nothing due in the next 30 days.'
                      : '${inrWhole(in30.fold(0, (s, e) => s + e.amountPaise))} '
                            'due in the next 30 days · ${in30.length} payment'
                            '${in30.length == 1 ? '' : 's'}',
                  style: t.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Previous month',
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          _month.isAfter(DateTime(_today.year, _today.month))
                          ? () => setState(() {
                              _month = DateTime(_month.year, _month.month - 1);
                              _selected = null;
                            })
                          : null,
                    ),
                    Text(
                      monthLabel(_month.year, _month.month),
                      style: t.titleSmall,
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _month.isBefore(lastMonth)
                          ? () => setState(() {
                              _month = DateTime(_month.year, _month.month + 1);
                              _selected = null;
                            })
                          : null,
                    ),
                  ],
                ),
                _MonthGrid(
                  month: _month,
                  today: _today,
                  selected: _selected,
                  events: events,
                  onTap: (d) =>
                      setState(() => _selected = _selected == d ? null : d),
                ),
                const SizedBox(height: 12),
                if (_selected != null)
                  Text(
                    '${_selected!.day} ${monthShort(_selected!.month)}',
                    style: t.titleSmall,
                  ),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nothing due.', style: t.bodySmall),
                  ),
                for (final e in shown) _EventTile(event: e),
                const SizedBox(height: 8),
                Text(
                  'Subscription and SIP dates are predicted from past '
                  'payments; bank mandate notices and loan schedules are '
                  'exact.',
                  style: t.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.events,
    required this.onTap,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selected;
  final List<UpcomingEvent> events;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final lead = DateTime(month.year, month.month, 1).weekday - 1; // Mon = 0
    final byDay = <int, List<UpcomingEvent>>{};
    for (final e in events) {
      if (e.date.year == month.year && e.date.month == month.month) {
        byDay.putIfAbsent(e.date.day, () => []).add(e);
      }
    }
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final cells = <Widget>[
      for (final n in names) Center(child: Text(n, style: t.labelSmall)),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++)
        _DayCell(
          date: DateTime(month.year, month.month, d),
          isToday: DateTime(month.year, month.month, d) == today,
          isSelected: DateTime(month.year, month.month, d) == selected,
          events: byDay[d] ?? const [],
          onTap: onTap,
          scheme: scheme,
          style: t.bodySmall!,
        ),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
    required this.scheme,
    required this.style,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<UpcomingEvent> events;
  final ValueChanged<DateTime> onTap;
  final ColorScheme scheme;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final overdue = events.any((e) => e.overdue);
    return Semantics(
      label:
          '${date.day} ${monthShort(date.month)}'
          '${events.isEmpty ? '' : ', ${events.length} due'}',
      button: events.isNotEmpty,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: events.isEmpty ? null : () => onTap(date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? scheme.primaryContainer : null,
            border: isToday ? Border.all(color: scheme.primary) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${date.day}', style: style),
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: events.isEmpty
                      ? Colors.transparent
                      : overdue
                      ? scheme.error
                      : scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final UpcomingEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = event;
    final icon = switch (e.kind) {
      UpcomingKind.cardDue => Icons.credit_card,
      UpcomingKind.loanEmi => Icons.account_balance_outlined,
      UpcomingKind.emi => Icons.receipt_long_outlined,
      UpcomingKind.sip => Icons.trending_up,
      UpcomingKind.subscription => Icons.autorenew,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: e.overdue ? scheme.error : null),
      title: Text(e.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          e.kind.label,
          if (e.overdue)
            'overdue'
          else
            '${e.date.day} ${monthShort(e.date.month)}',
          if (e.estimated && !e.overdue) 'expected',
        ].join(' · '),
      ),
      trailing: Text(inrWhole(e.amountPaise)),
    );
  }
}

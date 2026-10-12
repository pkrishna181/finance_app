import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// Schedule AL draft for the income-tax return: assets and liabilities on
/// 31 March, grouped by the form's sections.
class ScheduleAlScreen extends StatefulWidget {
  const ScheduleAlScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<ScheduleAlScreen> createState() => _ScheduleAlScreenState();
}

class _ScheduleAlScreenState extends State<ScheduleAlScreen> {
  // The return is filed for the last completed financial year.
  late FinancialYear _fy =
      FinancialYear.of(widget.now ?? DateTime.now()).previous;
  ScheduleAl? _al;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _al = null);
    final al = await ScheduleAlRepository(widget.database).build(_fy);
    if (mounted) setState(() => _al = al);
  }

  @override
  Widget build(BuildContext context) {
    final al = _al;
    final t = Theme.of(context).textTheme;
    final current = FinancialYear.of(widget.now ?? DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule AL')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Older year',
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  _fy = _fy.previous;
                  _load();
                },
              ),
              Text(_fy.label, style: t.titleMedium),
              IconButton(
                tooltip: 'Newer year',
                icon: const Icon(Icons.chevron_right),
                onPressed: _fy.next.compareTo(current) > 0
                    ? null
                    : () {
                        _fy = _fy.next;
                        _load();
                      },
              ),
            ],
          ),
          Text(
            'Only needed if your total income for the year is above ₹1 crore '
            '(₹50 lakh before AY 2025-26). Values are on 31 March, at cost.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 12),
          if (al == null)
            const Center(child: CircularProgressIndicator())
          else if (al.items.isEmpty)
            const Text('Nothing recorded for this year.')
          else ...[
            for (final s in AlSection.values)
              if (al.totals.containsKey(s)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('${s.code}  ${s.label}', style: t.titleSmall),
                    ),
                    Text(inrWhole(al.totals[s]!), style: t.titleSmall),
                  ],
                ),
                for (final i in al.items.where((i) => i.section == s))
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 12),
                    title: Text(i.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle:
                        i.atCost ? null : const Text('value, not cost — check'),
                    trailing: Text(inrWhole(i.amountPaise)),
                  ),
              ],
            const Divider(height: 24),
            Row(children: [
              const Expanded(child: Text('Total assets')),
              Text(inrWhole(al.assetsPaise)),
            ]),
            Row(children: [
              const Expanded(child: Text('Total liabilities')),
              Text(inrWhole(al.liabilitiesPaise)),
            ]),
            const SizedBox(height: 12),
            Text(
              'A draft to help fill the form, not tax advice. Schedule AL asks '
              'for the cost of each asset: shares and funds use what you paid '
              '(FIFO) where known; property, gold and vehicles use the value '
              'you entered — replace it with the purchase cost. '
              'Bank balances come from your latest statement on or before '
              '31 March; add any accounts Arth hasn\'t seen.',
              style: t.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

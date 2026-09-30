import 'package:flutter/material.dart';

import '../../insights/insight_format.dart';
import '../../insights/insight_models.dart';

/// Read-only list of the transactions behind an Insights number.
class CategoryTransactionsScreen extends StatelessWidget {
  const CategoryTransactionsScreen({
    super.key,
    required this.title,
    required this.txns,
  });

  final String title;
  final List<InsightTxn> txns;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: txns.isEmpty
          ? const Center(child: Text('No transactions.'))
          : ListView.separated(
              itemCount: txns.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = txns[i];
                final d = t.bookedAt;
                return ListTile(
                  title: Text(
                    t.merchantLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${d.day} ${monthShort(d.month)} ${d.year}'
                      ' · ${t.bankCode}'),
                  trailing: Text(
                    '${t.isDebit ? '-' : '+'}${inrWhole(t.amountPaise)}',
                    style: TextStyle(
                      color: t.isDebit ? scheme.error : scheme.primary,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

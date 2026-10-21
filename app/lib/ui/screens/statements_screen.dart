import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../ingestion/statement/statement_digest.dart';
import '../../ingestion/statement/statement_history.dart';
import '../../insights/insight_format.dart';
import '../widgets/statement_summary_view.dart';

String _date(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';

/// Bank and card statements imported so far; each opens its summary.
class StatementsScreen extends StatefulWidget {
  const StatementsScreen({super.key, required this.db});

  final ArthDatabase db;

  @override
  State<StatementsScreen> createState() => _StatementsScreenState();
}

class _StatementsScreenState extends State<StatementsScreen> {
  late final Future<List<StoredStatement>> _list = StatementHistory(
    widget.db,
  ).list();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your statements')),
      body: FutureBuilder<List<StoredStatement>>(
        future: _list,
        builder: (context, snap) {
          final list = snap.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No statements imported yet. Import a bank or card statement '
                'from the Import tab to see its summary here.',
              ),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = list[i];
              final who = [
                if (s.bankCode != null && s.bankCode != 'UNKNOWN') s.bankCode!,
                s.isCard ? 'card' : 'account',
                if (s.last4 != null) '••${s.last4}',
              ].join(' ');
              final period = s.periodStart == null || s.periodEnd == null
                  ? 'Imported ${_date(s.importedAt)}'
                  : '${_date(s.periodStart!)} – ${_date(s.periodEnd!)}';
              return ListTile(
                leading: Icon(
                  s.isCard ? Icons.credit_card : Icons.account_balance_outlined,
                ),
                title: Text(who),
                subtitle: Text(
                  '$period · ${s.transactionCount} transactions\n${s.fileName}',
                ),
                isThreeLine: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        StatementSummaryScreen(db: widget.db, statement: s),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// One imported statement's summary.
class StatementSummaryScreen extends StatelessWidget {
  const StatementSummaryScreen({
    super.key,
    required this.db,
    required this.statement,
  });

  final ArthDatabase db;
  final StoredStatement statement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statement summary')),
      body: FutureBuilder<StatementDigest?>(
        future: StatementHistory(db).digest(statement.importId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data;
          if (d == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('This statement has no transactions left in Arth.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatementSummaryView(digest: d, title: statement.fileName),
            ],
          );
        },
      ),
    );
  }
}

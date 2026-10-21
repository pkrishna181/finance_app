import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/models/money.dart';
import '../../core/models/transaction_type.dart';
import '../../ingestion/statement/file_source.dart';
import '../widgets/statement_summary_view.dart';

/// A picked statement before import: its summary (checked against the
/// totals it prints), then its rows. Import writes; Cancel discards.
class StatementPreviewScreen extends StatefulWidget {
  const StatementPreviewScreen({
    super.key,
    required this.preview,
    required this.db,
    required this.source,
  });

  final StatementImportPreview preview;
  final ArthDatabase db;
  final StatementFileSource source;

  @override
  State<StatementPreviewScreen> createState() => _StatementPreviewScreenState();
}

class _StatementPreviewScreenState extends State<StatementPreviewScreen> {
  bool _importing = false;

  Future<void> _import() async {
    setState(() => _importing = true);
    final result = await widget.source.confirmImport(
      db: widget.db,
      preview: widget.preview,
    );
    if (!mounted) return;
    setState(() => _importing = false);
    result.when(
      ok: (n) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Imported $n new transactions')));
        Navigator.of(context).pop();
      },
      err: (msg, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    final t = Theme.of(context).textTheme;
    final inferred = preview.transactions
        .where((e) => e.directionInferred)
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Statement summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatementSummaryView(digest: preview.digest, title: preview.fileName),
          Text(
            '${preview.newCount} new · ${preview.duplicateCount} already in '
            'Arth${preview.unparseableCount == 0 ? '' : ' · ${preview.unparseableCount} lines not read'}',
            style: t.bodySmall,
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Transactions (${preview.transactions.length})'),
            subtitle: inferred == 0
                ? null
                : Text('$inferred with a guessed direction — check them'),
            initiallyExpanded: inferred > 0,
            children: [
              for (var i = 0; i < preview.transactions.length; i++)
                _TxnTile(
                  preview: preview,
                  index: i,
                  onFlip: () => setState(() => preview.flipDirection(i)),
                ),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('How it was read'),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${preview.columnMap.bankCode} · ${preview.columnMap.profileId}'
                  ' · ${preview.grid.sourceFormat}\n'
                  '${preview.columnMap.bindings.map((b) => '${b.field.name} ← "${b.matchedHeader}"').join('\n')}',
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _importing ? null : _import,
                  child: Text(
                    preview.newCount == 0
                        ? 'Save statement'
                        : 'Import ${preview.newCount} new',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({
    required this.preview,
    required this.index,
    required this.onFlip,
  });

  final StatementImportPreview preview;
  final int index;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final t = preview.transactions[index];
    final sign = t.direction == TransactionDirection.debit ? '-' : '+';
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(t.rawMerchant, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${t.bookedAt.toIso8601String().substring(0, 10)}'
        '${t.directionInferred ? ' · direction guessed' : ''}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (t.directionInferred)
            IconButton(
              tooltip: 'Flip debit/credit',
              icon: const Icon(Icons.swap_horiz),
              onPressed: onFlip,
            ),
          Text('$sign${MoneyPaise(t.amountPaise.paise).formatInr()}'),
        ],
      ),
    );
  }
}

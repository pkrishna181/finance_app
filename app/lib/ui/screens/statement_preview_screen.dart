import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/models/money.dart';
import '../../core/models/transaction_type.dart';
import '../../ingestion/statement/file_source.dart';

/// Preview detected mapping + first rows; Confirm writes / Cancel discards.
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
  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    final map = preview.columnMap;
    return Scaffold(
      appBar: AppBar(title: const Text('Review statement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(preview.fileName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Detected: ${map.bankCode} · ${map.profileId} · '
            '${preview.grid.sourceFormat}',
          ),
          Text(
            'New ${preview.newCount} · Duplicates ${preview.duplicateCount} · '
            'Unparseable ${preview.unparseableCount}',
          ),
          const SizedBox(height: 12),
          Text('Column mapping', style: Theme.of(context).textTheme.titleSmall),
          ...map.bindings.map(
            (b) => Text(
              '${b.field.name} ← "${b.matchedHeader}" '
              '(col ${b.index}, ${(b.confidence * 100).round()}%)',
            ),
          ),
          const SizedBox(height: 16),
          Text('First rows', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...List.generate(preview.previewRows.length, (i) {
            final t = preview.previewRows[i];
            final sign = t.direction == TransactionDirection.debit ? '-' : '+';
            final desc = t.rawDescription.length > 60
                ? '${t.rawDescription.substring(0, 60)}…'
                : t.rawDescription;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Expanded(child: Text(t.rawMerchant)),
                  if (t.directionInferred)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: const Text('Direction guessed'),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                '${t.bookedAt.toIso8601String().substring(0, 10)} · '
                '${t.type.name} · $desc',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (t.directionInferred)
                    IconButton(
                      tooltip: 'Flip debit/credit',
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () {
                        setState(() => preview.flipDirection(i));
                      },
                    ),
                  Text(
                    '$sign${MoneyPaise(t.amountPaise.paise).formatInr()}',
                  ),
                ],
              ),
            );
          }),
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
                  onPressed: () async {
                    final result = await widget.source.confirmImport(
                      db: widget.db,
                      preview: preview,
                    );
                    if (!context.mounted) return;
                    result.when(
                      ok: (n) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Imported $n new transactions'),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      err: (msg, _) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      },
                    );
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/models/money.dart';
import '../../ingestion/statement/statement_digest.dart';
import '../../ingestion/statement/statement_overview.dart';
import '../../insights/insight_format.dart';

String _date(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';

/// A statement's summary: overview, the check against its printed totals,
/// money in and out, charges, payees and the largest payments.
class StatementSummaryView extends StatelessWidget {
  const StatementSummaryView({super.key, required this.digest, this.title});

  final StatementDigest digest;

  /// File name or account label shown at the top.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final d = digest;
    final t = Theme.of(context).textTheme;
    final who = [
      d.bankCode == 'UNKNOWN' ? null : d.bankCode,
      d.isCard ? 'credit card' : 'account',
      if (d.last4 != null) '••${d.last4}',
    ].whereType<String>().join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) Text(title!, style: t.titleMedium),
        Text(
          '${who[0].toUpperCase()}${who.substring(1)}'
          '${d.from == null || d.to == null ? '' : ' · ${_date(d.from!)} – ${_date(d.to!)}'}',
          style: t.bodyMedium,
        ),
        const SizedBox(height: 12),
        _CheckCard(digest: d),
        const SizedBox(height: 12),
        _Section(
          title: 'Overview',
          children: [
            for (final s in statementOverview(d))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(s),
              ),
          ],
        ),
        _Section(
          title: d.isCard ? 'Spent and paid' : 'Money in and out',
          children: [
            _row(
              context,
              d.isCard ? 'Spent' : 'Money out',
              d.outPaise,
              '${d.outCount}',
            ),
            _row(
              context,
              d.isCard ? 'Paid or refunded' : 'Money in',
              d.inPaise,
              '${d.inCount}',
            ),
            if (!d.isCard) _row(context, 'Net', d.inPaise - d.outPaise, null),
            if (d.instalmentCount > 0)
              _row(
                context,
                'EMI instalments billed',
                d.instalmentsPaise,
                '${d.instalmentCount}',
              ),
            if (d.interestEarnedPaise > 0)
              _row(context, 'Interest earned', d.interestEarnedPaise, null),
          ],
        ),
        if (d.isCard && d.printed.totalDuePaise != null) _Bill(digest: d),
        if (d.charges.isNotEmpty)
          _Section(
            title: 'Fees, interest and taxes · ${inrWhole(d.chargesPaise)}',
            children: [
              for (final r in d.charges)
                _row(context, _short(r.description), r.paise, null),
            ],
          ),
        if (d.topPayees.isNotEmpty)
          _Section(
            title: d.isCard ? 'Where it was spent' : 'Where money went',
            children: [
              for (final p in d.topPayees)
                _row(context, p.name, p.paise, '${p.count}×'),
            ],
          ),
        if (d.topSources.isNotEmpty)
          _Section(
            title: d.isCard ? 'Payments and refunds' : 'Where money came from',
            children: [
              for (final p in d.topSources)
                _row(context, p.name, p.paise, '${p.count}×'),
            ],
          ),
        if (d.largest.isNotEmpty)
          _Section(
            title: 'Largest payments',
            children: [
              for (final r in d.largest)
                _row(
                  context,
                  '${r.date.day} ${monthShort(r.date.month)} · ${_short(r.merchant)}',
                  r.paise,
                  null,
                ),
            ],
          ),
      ],
    );
  }

  static String _short(String s) =>
      s.length > 40 ? '${s.substring(0, 40)}…' : s;

  static Widget _row(
    BuildContext context,
    String label,
    int paise,
    String? note,
  ) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(note, style: t.bodySmall),
            ),
          Text(
            inrWhole(paise),
            style: t.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        ...children,
      ],
    ),
  );
}

/// Whether the rows add up to what the statement prints.
class _CheckCard extends StatelessWidget {
  const _CheckCard({required this.digest});

  final StatementDigest digest;

  static String _label(DigestCheck c, bool isCard) => switch (c.what) {
    'moneyOut' => isCard ? 'Purchases' : 'Total debits',
    'moneyIn' => isCard ? 'Payments and credits' : 'Total credits',
    'debitCount' => 'Number of debits',
    'creditCount' => 'Number of credits',
    _ => isCard ? 'Total outstanding' : 'Closing balance',
  };

  static String _value(DigestCheck c, int v) =>
      c.isCount ? '${v ~/ 100}' : MoneyPaise(v).formatInr();

  @override
  Widget build(BuildContext context) {
    final d = digest;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final ok = d.reconciled;
    final (icon, color, headline, detail) = switch (ok) {
      true => (
        Icons.verified_outlined,
        scheme.primary,
        'Matches the statement',
        'Every total printed on the statement adds up from these '
            '${d.inCount + d.outCount} transactions.',
      ),
      false => (
        Icons.error_outline,
        scheme.error,
        "Doesn't add up",
        'Some rows may be missing or misread. The figures below show '
            'where.',
      ),
      null => (
        Icons.info_outline,
        scheme.onSurfaceVariant,
        'Nothing to check against',
        "This statement doesn't print totals that could be checked.",
      ),
    };
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    headline,
                    style: t.titleSmall?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(detail, style: t.bodySmall),
            if (d.checks.isNotEmpty) const SizedBox(height: 8),
            for (final c in d.checks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      c.ok ? Icons.check : Icons.close,
                      size: 16,
                      color: c.ok ? scheme.primary : scheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: c.ok
                          ? Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _label(c, d.isCard),
                                    style: t.bodySmall,
                                  ),
                                ),
                                Text(
                                  _value(c, c.printedPaise),
                                  style: t.bodySmall,
                                ),
                              ],
                            )
                          // Two figures don't fit beside the label on a phone.
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_label(c, d.isCard), style: t.bodySmall),
                                Text(
                                  '${_value(c, c.parsedPaise)} read · '
                                  '${_value(c, c.printedPaise)} printed',
                                  style: t.bodySmall?.copyWith(
                                    color: scheme.error,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bill extends StatelessWidget {
  const _Bill({required this.digest});

  final StatementDigest digest;

  @override
  Widget build(BuildContext context) {
    final p = digest.printed;
    return _Section(
      title: 'Bill',
      children: [
        StatementSummaryView._row(context, 'Total due', p.totalDuePaise!, null),
        if (p.minDuePaise != null)
          StatementSummaryView._row(
            context,
            'Minimum due',
            p.minDuePaise!,
            null,
          ),
        if (p.dueDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                const Expanded(child: Text('Pay by')),
                Text(_date(p.dueDate!)),
              ],
            ),
          ),
        if (p.creditLimitPaise != null)
          StatementSummaryView._row(
            context,
            'Credit limit',
            p.creditLimitPaise!,
            null,
          ),
        if (p.availableLimitPaise != null)
          StatementSummaryView._row(
            context,
            'Available',
            p.availableLimitPaise!,
            null,
          ),
      ],
    );
  }
}

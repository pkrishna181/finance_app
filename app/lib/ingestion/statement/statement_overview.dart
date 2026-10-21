import '../../insights/insight_format.dart';
import 'statement_digest.dart';

String _day(DateTime d) => '${d.day} ${monthShort(d.month)}';
String _date(DateTime d) => '${_day(d)} ${d.year}';

String _period(StatementDigest d) {
  final from = d.from, to = d.to;
  if (from == null || to == null) return 'On this statement';
  return from.year == to.year
      ? 'From ${_day(from)} to ${_date(to)}'
      : 'From ${_date(from)} to ${_date(to)}';
}

String _count(int n, String one) => n == 1 ? '1 $one' : '$n ${one}s';
String _times(int n) => _count(n, 'payment');

/// The summary in a few plain sentences, every figure from [d].
List<String> statementOverview(StatementDigest d) {
  final top = d.topPayees.isEmpty ? null : d.topPayees.first;
  final printed = d.printed;
  return [
    if (d.isCard)
      '${_period(d)}, ${inrWhole(d.outPaise)} went on the card in '
          '${_times(d.outCount)} and ${inrWhole(d.inPaise)} was paid or '
          'refunded to it.'
    else
      '${_period(d)}, ${inrWhole(d.inPaise)} came in and '
          '${inrWhole(d.outPaise)} went out '
          '(${_count(d.inCount, 'credit')}, ${_count(d.outCount, 'debit')}).',
    if (top != null)
      'Most went to ${top.name}: ${inrWhole(top.paise)} over '
          '${_times(top.count)}.',
    if (d.chargesPaise > 0)
      '${d.isCard ? 'The card' : 'The bank'} charged '
          '${inrWhole(d.chargesPaise)} in fees, interest and taxes.'
    else
      'No fees or charges.',
    if (d.interestEarnedPaise > 0)
      'Interest earned: ${inrWhole(d.interestEarnedPaise)}.',
    if (d.instalmentCount > 0)
      '${inrWhole(d.instalmentsPaise)} in EMI instalments '
          '(${d.instalmentCount}) was billed too.',
    if (d.isCard && printed.totalDuePaise != null)
      '${inrWhole(printed.totalDuePaise!)} is due'
          '${printed.dueDate == null ? '' : ' by ${_date(printed.dueDate!)}'}'
          '${printed.minDuePaise == null ? '' : ' (minimum ${inrWhole(printed.minDuePaise!)})'}.',
  ];
}

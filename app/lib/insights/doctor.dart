import 'insight_format.dart';
import 'insight_models.dart';

enum DoctorSeverity { warning, info }

/// Where tapping a finding should take the user.
enum DoctorAction { search, importData, resolveUnparsed, cards, none }

class DoctorFinding {
  const DoctorFinding({
    required this.key,
    required this.severity,
    required this.title,
    required this.detail,
    this.action = DoctorAction.none,
    this.query,
  });

  /// Stable id (for tests / de-duplication).
  final String key;
  final DoctorSeverity severity;
  final String title;
  final String detail;
  final DoctorAction action;

  /// Search query for [DoctorAction.search].
  final String? query;
}

/// Counts the checks need from outside the transaction list.
class DoctorContext {
  const DoctorContext({
    required this.asOf,
    this.unresolvedSms = 0,
    this.unresolvedStatementRows = 0,
    this.untrackedCards = 0,
  });

  final DateTime asOf;
  final int unresolvedSms;
  final int unresolvedStatementRows;
  final int untrackedCards;
}

/// Pure data-quality checks over the ledger.
class DataDoctor {
  const DataDoctor({
    this.balanceTolerancePaise = 100,
    this.staleDays = 45,
    this.uncategorizedShare = 0.2,
    this.duplicateMinPaise = 50000,
  });

  /// Balance differences up to this are rounding, not missing rows.
  final int balanceTolerancePaise;

  /// An account with nothing newer than this is "not updated recently".
  final int staleDays;

  /// Uncategorized spend share (last 3 months) worth flagging.
  final double uncategorizedShare;

  /// Smallest amount checked for same-day duplicates.
  final int duplicateMinPaise;

  List<DoctorFinding> run(List<InsightTxn> txns, DoctorContext ctx) {
    final out = <DoctorFinding>[
      ..._balanceGaps(txns),
      ..._monthGaps(txns, ctx),
      ..._stale(txns, ctx),
      ..._uncategorized(txns, ctx),
      ..._duplicates(txns),
      ..._cashDoubleCount(txns),
      if (ctx.unresolvedSms > 0)
        DoctorFinding(
          key: 'unparsed_sms',
          severity: DoctorSeverity.warning,
          title: '${ctx.unresolvedSms} bank message'
              '${ctx.unresolvedSms == 1 ? '' : 's'} not understood',
          detail: 'They may be transactions missing from your totals. '
              'Review them on the Import tab.',
          action: DoctorAction.resolveUnparsed,
        ),
      if (ctx.unresolvedStatementRows > 0)
        DoctorFinding(
          key: 'unparsed_rows',
          severity: DoctorSeverity.info,
          title: '${ctx.unresolvedStatementRows} statement row'
              '${ctx.unresolvedStatementRows == 1 ? '' : 's'} skipped',
          detail: 'Rows Arth couldn\'t read from imported statements are kept '
              'for review.',
          action: DoctorAction.resolveUnparsed,
        ),
      if (ctx.untrackedCards > 0)
        DoctorFinding(
          key: 'untracked_cards',
          severity: DoctorSeverity.info,
          title: '${ctx.untrackedCards} credit card'
              '${ctx.untrackedCards == 1 ? '' : 's'} not tracked',
          detail: 'Track them to see bills, due dates and limit use.',
          action: DoctorAction.cards,
        ),
    ];
    out.sort((a, b) => a.severity.index.compareTo(b.severity.index));
    return out;
  }

  static String _acct(InsightTxn t) => t.accountHint == null
      ? t.bankCode
      : '${t.bankCode} ••${t.accountHint}';

  static String _day(DateTime d) => '${d.day} ${monthShort(d.month)} ${d.year}';

  static DateTime _dateOf(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<String, List<InsightTxn>> _byAccount(
    Iterable<InsightTxn> txns, {
    bool bankOnly = false,
  }) {
    final m = <String, List<InsightTxn>>{};
    for (final t in txns) {
      if (t.isManual || t.bankCode == 'CASH') continue;
      if (bankOnly && (t.isCardAccount || t.accountHint == null)) continue;
      m.putIfAbsent(t.accountKey, () => []).add(t);
    }
    for (final l in m.values) {
      l.sort((a, b) {
        final c = a.bookedAt.compareTo(b.bookedAt);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    }
    return m;
  }

  /// Day-closing balances that don't follow from the day's transactions mean
  /// rows are missing in between. Compares across days because the order of
  /// rows within a day isn't reliable.
  List<DoctorFinding> _balanceGaps(List<InsightTxn> txns) {
    final out = <DoctorFinding>[];
    for (final e in _byAccount(txns, bankOnly: true).entries) {
      final rows = e.value;
      // Per day: net movement and the closing balance (last row with one).
      final days = <DateTime>[];
      final net = <DateTime, int>{};
      final close = <DateTime, int>{};
      for (final t in rows) {
        final d = _dateOf(t.bookedAt);
        if (!net.containsKey(d)) days.add(d);
        net[d] = (net[d] ?? 0) + (t.isDebit ? -t.amountPaise : t.amountPaise);
        if (t.balanceAfterPaise != null) close[d] = t.balanceAfterPaise!;
      }
      DateTime? prevDay;
      var gaps = 0;
      var missing = 0;
      DateTime? firstFrom;
      DateTime? firstTo;
      var running = 0;
      for (final d in days) {
        if (prevDay != null) {
          running += net[d]!;
          final c = close[d];
          if (c != null) {
            final expected = close[prevDay]! + running;
            final diff = c - expected;
            if (diff.abs() > balanceTolerancePaise) {
              gaps++;
              missing += diff.abs();
              firstFrom ??= prevDay;
              firstTo ??= d;
            }
          }
        }
        if (close.containsKey(d)) {
          prevDay = d;
          running = 0;
        }
      }
      if (gaps > 0) {
        final acct = _acct(rows.first);
        out.add(DoctorFinding(
          key: 'balance_gap:${e.key}',
          severity: DoctorSeverity.warning,
          title: '$acct: balance doesn\'t add up',
          detail: '${inrWhole(missing)} unaccounted for across $gaps '
              'place${gaps == 1 ? '' : 's'}, first between '
              '${_day(firstFrom!)} and ${_day(firstTo!)}. A statement or some '
              'messages are probably missing — import that period.',
          action: DoctorAction.importData,
        ));
      }
    }
    return out;
  }

  /// Calendar months with no rows between an account's first and last month.
  List<DoctorFinding> _monthGaps(List<InsightTxn> txns, DoctorContext ctx) {
    final out = <DoctorFinding>[];
    for (final e in _byAccount(txns).entries) {
      final months = {for (final t in e.value) MonthKey.of(t.bookedAt)};
      final first = MonthKey.of(e.value.first.bookedAt);
      final last = MonthKey.of(e.value.last.bookedAt);
      final missing = <MonthKey>[
        for (var m = first; m.compareTo(last) < 0; m = m.plusMonths(1))
          if (!months.contains(m)) m,
      ];
      if (missing.isEmpty) continue;
      final names = missing.take(3).map((m) => monthLabel(m.year, m.month));
      out.add(DoctorFinding(
        key: 'month_gap:${e.key}',
        severity: DoctorSeverity.warning,
        title: '${_acct(e.value.first)}: no data for '
            '${missing.length} month${missing.length == 1 ? '' : 's'}',
        detail: '${names.join(', ')}${missing.length > 3 ? ', …' : ''}. '
            'Import statements for these months so totals are complete.',
        action: DoctorAction.importData,
      ));
    }
    return out;
  }

  List<DoctorFinding> _stale(List<InsightTxn> txns, DoctorContext ctx) {
    final out = <DoctorFinding>[];
    for (final e in _byAccount(txns).entries) {
      final last = e.value.last.bookedAt;
      final age = _dateOf(ctx.asOf).difference(_dateOf(last)).inDays;
      if (age <= staleDays) continue;
      out.add(DoctorFinding(
        key: 'stale:${e.key}',
        severity: DoctorSeverity.info,
        title: '${_acct(e.value.first)}: nothing since ${_day(last)}',
        detail: 'If you still use this account, import a recent statement.',
        action: DoctorAction.importData,
      ));
    }
    return out;
  }

  List<DoctorFinding> _uncategorized(List<InsightTxn> txns, DoctorContext ctx) {
    final since = DateTime(ctx.asOf.year, ctx.asOf.month - 3, ctx.asOf.day);
    var spend = 0;
    var uncat = 0;
    var n = 0;
    for (final t in txns) {
      if (!t.isDebit || t.bookedAt.isBefore(since)) continue;
      if (t.categorySlug == kSelfTransferSlug) continue;
      spend += t.amountPaise;
      if (t.isUncategorized) {
        uncat += t.amountPaise;
        n++;
      }
    }
    if (spend == 0 || uncat / spend < uncategorizedShare) return const [];
    return [
      DoctorFinding(
        key: 'uncategorized',
        severity: DoctorSeverity.info,
        title: '${(uncat * 100 / spend).round()}% of recent spending is '
            'uncategorized',
        detail: '$n transactions (${inrWhole(uncat)}) in the last 3 months. '
            'Categorizing them makes budgets and insights accurate.',
        action: DoctorAction.search,
        query: 'cat:none debit',
      ),
    ];
  }

  /// Same account, day, amount and direction from different sources that
  /// dedupe didn't merge.
  List<DoctorFinding> _duplicates(List<InsightTxn> txns) {
    final groups = <String, List<InsightTxn>>{};
    for (final t in txns) {
      if (t.isManual || t.amountPaise < duplicateMinPaise) continue;
      final d = _dateOf(t.bookedAt);
      groups
          .putIfAbsent(
              '${t.bankCode}|${t.isDebit}|${t.amountPaise}|$d', () => [])
          .add(t);
    }
    final dupGroups = groups.values.where((g) => g.length > 1).toList();
    if (dupGroups.isEmpty) return const [];
    final extra = dupGroups.fold<int>(0, (s, g) => s + g.length - 1);
    final first = dupGroups.first.first;
    final d = first.bookedAt;
    return [
      DoctorFinding(
        key: 'duplicates',
        severity: DoctorSeverity.info,
        title: '$extra possible duplicate${extra == 1 ? '' : 's'}',
        detail: 'Same bank, day and amount more than once (e.g. '
            '${inrWhole(first.amountPaise)} on ${_day(d)}). Often genuine; '
            'check if one was recorded twice.',
        action: DoctorAction.search,
        query: '=${first.amountPaise ~/ 100}'
            '${first.amountPaise % 100 == 0 ? '' : '.${(first.amountPaise % 100).toString().padLeft(2, '0')}'} '
            'bank:${first.bankCode.toLowerCase()} '
            'from:${_iso(d)} to:${_iso(d)}',
      ),
    ];
  }

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Logged cash spending while ATM withdrawals still count as spend.
  List<DoctorFinding> _cashDoubleCount(List<InsightTxn> txns) {
    final cashMonths = {
      for (final t in txns)
        if (t.isManual && t.isDebit && t.bankCode == 'CASH')
          MonthKey.of(t.bookedAt),
    };
    if (cashMonths.isEmpty) return const [];
    final atm = [
      for (final t in txns)
        if (t.isDebit &&
            t.txnType == 'atm' &&
            t.categorySlug != kSelfTransferSlug &&
            cashMonths.contains(MonthKey.of(t.bookedAt)))
          t,
    ];
    if (atm.isEmpty) return const [];
    final total = atm.fold<int>(0, (s, t) => s + t.amountPaise);
    return [
      DoctorFinding(
        key: 'cash_double_count',
        severity: DoctorSeverity.warning,
        title: 'Cash may be counted twice',
        detail: '${atm.length} ATM withdrawal${atm.length == 1 ? '' : 's'} '
            '(${inrWhole(total)}) count as spending, and you also logged '
            'cash purchases in the same months. Mark the withdrawals as '
            'Transfers (self).',
        action: DoctorAction.search,
        query: 'type:atm debit',
      ),
    ];
  }
}

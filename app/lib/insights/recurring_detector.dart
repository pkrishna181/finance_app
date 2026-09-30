import 'insight_models.dart';

enum Cadence {
  weekly(7, 2, 4),
  monthly(30, 4, 3),
  quarterly(91, 8, 3),
  annual(365, 15, 2);

  const Cadence(this.days, this.tolerance, this.minOccurrences);

  final int days;

  /// Allowed deviation (days) from [days] for one interval.
  final int tolerance;
  final int minOccurrences;

  /// Approximate paise-per-month multiplier for a per-charge amount.
  double get perMonth => switch (this) {
        Cadence.weekly => 52 / 12,
        Cadence.monthly => 1,
        Cadence.quarterly => 1 / 3,
        Cadence.annual => 1 / 12,
      };
}

class PriceChange {
  const PriceChange({required this.fromPaise, required this.toPaise});
  final int fromPaise;
  final int toPaise;
  bool get isIncrease => toPaise > fromPaise;
}

class RecurringSeries {
  const RecurringSeries({
    required this.key,
    required this.label,
    required this.merchantId,
    required this.cadence,
    required this.kind,
    required this.lastAmountPaise,
    required this.lastSeen,
    required this.nextExpected,
    required this.occurrences,
    required this.txnIds,
    required this.confidence,
    required this.active,
    this.priceChange,
    this.mandateDate,
  });

  final String key;
  final String label;
  final int? merchantId;
  final Cadence cadence;

  /// subscription | sip | enach (values stored in `transactions.recurring_kind`).
  final String kind;
  final int lastAmountPaise;
  final DateTime lastSeen;
  final DateTime nextExpected;
  final int occurrences;
  final List<int> txnIds;

  /// Share of intervals that fit the cadence, 0..1.
  final double confidence;

  /// False when the series has lapsed (no charge for over two cycles).
  final bool active;
  final PriceChange? priceChange;

  /// Upcoming scheduled date from a matching bank mandate notice, if any.
  final DateTime? mandateDate;

  int get monthlyEquivalentPaise =>
      (lastAmountPaise * cadence.perMonth).round();

  RecurringSeries withMandate(DateTime? date) => RecurringSeries(
        key: key,
        label: label,
        merchantId: merchantId,
        cadence: cadence,
        kind: kind,
        lastAmountPaise: lastAmountPaise,
        lastSeen: lastSeen,
        nextExpected: nextExpected,
        occurrences: occurrences,
        txnIds: txnIds,
        confidence: confidence,
        active: active,
        priceChange: priceChange,
        mandateDate: date,
      );
}

/// Bank mandate notice reduced to what matching needs.
class MandateHint {
  const MandateHint({
    required this.merchant,
    required this.amountPaise,
    required this.scheduledDate,
  });
  final String? merchant;
  final int? amountPaise;
  final DateTime? scheduledDate;
}

/// Finds fixed-cadence debits (subscriptions, SIPs, EMIs) in a transaction list.
///
/// Callers should pass only counted debits (no transfers). Per merchant:
/// 1. amounts must form at most two consecutive "levels" (±[amountTolerance]),
///    so one price change is allowed but noisy spend (groceries) is not;
/// 2. ≥ [Cadence.minOccurrences] charges;
/// 3. ≥ [minConfidence] of intervals fit one cadence, where an interval of
///    about twice the cadence counts as a single missed cycle.
class RecurringDetector {
  const RecurringDetector({
    this.amountTolerance = 0.05,
    this.minConfidence = 0.75,
  });

  final double amountTolerance;
  final double minConfidence;

  List<RecurringSeries> detect(
    List<InsightTxn> txns, {
    required DateTime asOf,
  }) {
    final groups = <String, List<InsightTxn>>{};
    for (final t in txns) {
      if (!t.isDebit) continue;
      final k = groupKey(t);
      if (k == null) continue;
      groups.putIfAbsent(k, () => []).add(t);
    }

    final out = <RecurringSeries>[];
    for (final e in groups.entries) {
      final s = _analyse(e.key, e.value, asOf);
      if (s != null) out.add(s);
    }
    out.sort((a, b) {
      if (a.active != b.active) return a.active ? -1 : 1;
      final c = b.monthlyEquivalentPaise.compareTo(a.monthlyEquivalentPaise);
      return c != 0 ? c : a.label.compareTo(b.label);
    });
    return out;
  }

  /// Stable merchant key: canonical merchant id, else normalized raw text.
  static String? groupKey(InsightTxn t) {
    if (t.merchantId != null) return 'm${t.merchantId}';
    final n = normalizeLabel(t.merchantLabel);
    return n.length < 3 ? null : 'r$n';
  }

  static String normalizeLabel(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[0-9]+'), ' ')
      .replaceAll(RegExp(r'[^a-z ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  RecurringSeries? _analyse(String key, List<InsightTxn> raw, DateTime asOf) {
    if (raw.length < 2) return null;
    final txns = [...raw]..sort((a, b) => a.bookedAt.compareTo(b.bookedAt));

    // Amount levels (sequential).
    final levels = <List<InsightTxn>>[];
    for (final t in txns) {
      if (levels.isNotEmpty) {
        final base = levels.last.first.amountPaise;
        if ((t.amountPaise - base).abs() <= base * amountTolerance) {
          levels.last.add(t);
          continue;
        }
      }
      levels.add([t]);
    }
    if (levels.length > 2) return null;

    final days = txns.map((t) => _day(t.bookedAt)).toList();
    final intervals = [
      for (var i = 1; i < days.length; i++) days[i] - days[i - 1],
    ];

    Cadence? best;
    var bestConf = 0.0;
    for (final c in Cadence.values) {
      if (txns.length < c.minOccurrences) continue;
      final ok = intervals.where((d) => _fits(d, c)).length;
      final conf = ok / intervals.length;
      if (conf > bestConf) {
        best = c;
        bestConf = conf;
      }
    }
    if (best == null || bestConf < minConfidence) return null;

    final last = txns.last;
    final lastDay = _day(last.bookedAt);
    final asOfDay = _day(asOf);
    final active = asOfDay - lastDay <= best.days * 2 + best.tolerance;

    PriceChange? change;
    if (levels.length == 2) {
      change = PriceChange(
        fromPaise: levels.first.last.amountPaise,
        toPaise: levels.last.last.amountPaise,
      );
    }

    return RecurringSeries(
      key: key,
      label: last.merchantLabel,
      merchantId: last.merchantId,
      cadence: best,
      kind: _kindOf(txns),
      lastAmountPaise: last.amountPaise,
      lastSeen: last.bookedAt,
      nextExpected: DateTime(
        last.bookedAt.year,
        last.bookedAt.month,
        last.bookedAt.day + best.days,
      ),
      occurrences: txns.length,
      txnIds: [for (final t in txns) t.id],
      confidence: bestConf,
      active: active,
      priceChange: change,
    );
  }

  static bool _fits(int interval, Cadence c) {
    bool near(int target) => (interval - target).abs() <= c.tolerance;
    return near(c.days) || near(c.days * 2);
  }

  static int _day(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  static String _kindOf(List<InsightTxn> txns) {
    int count(bool Function(InsightTxn) f) => txns.where(f).length;
    final half = txns.length / 2;
    if (count((t) => t.categorySlug == 'investments_sip') > half) {
      return 'sip';
    }
    if (count((t) =>
            t.txnType == 'enach' ||
            t.txnType == 'mandate' ||
            t.categorySlug == 'emi') >
        half) {
      return 'enach';
    }
    return 'subscription';
  }

  /// Attaches the earliest upcoming mandate date (on/after [asOf]) to each
  /// series whose label matches a notice merchant and whose amount is close.
  static List<RecurringSeries> matchMandates(
    List<RecurringSeries> series,
    List<MandateHint> notices, {
    required DateTime asOf,
  }) {
    final today = DateTime(asOf.year, asOf.month, asOf.day);
    return [
      for (final s in series)
        s.withMandate(_mandateFor(s, notices, today)),
    ];
  }

  static DateTime? _mandateFor(
    RecurringSeries s,
    List<MandateHint> notices,
    DateTime today,
  ) {
    final label = normalizeLabel(s.label);
    if (label.length < 3) return null;
    DateTime? best;
    for (final n in notices) {
      final m = normalizeLabel(n.merchant ?? '');
      final date = n.scheduledDate;
      if (m.length < 3 || date == null || date.isBefore(today)) continue;
      if (!(label.contains(m) || m.contains(label))) continue;
      final amt = n.amountPaise;
      if (amt != null &&
          (amt - s.lastAmountPaise).abs() > s.lastAmountPaise * 0.1) {
        continue;
      }
      if (best == null || date.isBefore(best)) best = date;
    }
    return best;
  }
}

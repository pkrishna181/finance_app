import 'dart:math' as math;

/// A dated cash flow for XIRR: negative = money in (investment), positive =
/// money out (redemption, dividend, final value).
class CashFlow {
  const CashFlow(this.date, this.paise);
  final DateTime date;
  final int paise;
}

/// Annualised internal rate of return (e.g. 0.12 = 12% a year) for irregular
/// [flows], or null when it can't be computed (no sign change, < 2 flows,
/// shorter than a week, or no convergence).
double? xirr(List<CashFlow> flows) {
  final f = [
    for (final x in flows)
      if (x.paise != 0) x,
  ];
  if (f.length < 2) return null;
  if (!f.any((x) => x.paise < 0) || !f.any((x) => x.paise > 0)) return null;
  f.sort((a, b) => a.date.compareTo(b.date));
  final t0 = f.first.date;
  final span = f.last.date.difference(t0).inDays;
  if (span < 7) return null;
  final years = [for (final x in f) x.date.difference(t0).inDays / 365.0];
  final amts = [for (final x in f) x.paise.toDouble()];

  double npv(double r) {
    var s = 0.0;
    for (var i = 0; i < amts.length; i++) {
      s += amts[i] / math.pow(1 + r, years[i]);
    }
    return s;
  }

  double dnpv(double r) {
    var s = 0.0;
    for (var i = 0; i < amts.length; i++) {
      s -= years[i] * amts[i] / math.pow(1 + r, years[i] + 1);
    }
    return s;
  }

  // Newton from 10%, then bisection if it wanders off.
  var r = 0.1;
  for (var i = 0; i < 50; i++) {
    final v = npv(r);
    final d = dnpv(r);
    if (d == 0 || !v.isFinite || !d.isFinite) break;
    final next = r - v / d;
    if (next <= -0.9999 || next > 100 || !next.isFinite) break;
    if ((next - r).abs() < 1e-9) return next;
    r = next;
  }
  var lo = -0.9999;
  var hi = 100.0;
  var flo = npv(lo);
  final fhi = npv(hi);
  if (flo.sign == fhi.sign) return null;
  for (var i = 0; i < 300; i++) {
    final mid = (lo + hi) / 2;
    final fm = npv(mid);
    if (fm.abs() < 1e-6 || (hi - lo) < 1e-10) return mid;
    if (fm.sign == flo.sign) {
      lo = mid;
      flo = fm;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// One investment transaction (from CAS).
class PositionTxn {
  const PositionTxn({
    required this.date,
    required this.type,
    this.amountPaise,
    this.unitsE4,
  });

  final DateTime date;

  /// `CasTxnType` name.
  final String type;
  final int? amountPaise;
  final int? unitsE4;
}

/// Everything known about one security in one account.
class PositionInput {
  const PositionInput({
    required this.securityId,
    required this.accountId,
    required this.name,
    required this.kind,
    required this.accountLabel,
    this.isin,
    this.amc,
    this.txns = const [],
    this.snapshotDate,
    this.snapshotUnitsE4,
    this.snapshotCostPaise,
    this.priceDate,
    this.priceE4,
  });

  final int securityId;
  final int accountId;
  final String name;

  /// mf | equity | other
  final String kind;
  final String accountLabel;
  final String? isin;
  final String? amc;
  final List<PositionTxn> txns;
  final DateTime? snapshotDate;
  final int? snapshotUnitsE4;
  final int? snapshotCostPaise;

  /// Latest known price (any source) on or before the valuation date.
  final DateTime? priceDate;
  final int? priceE4;
}

class Position {
  const Position({
    required this.input,
    required this.unitsE4,
    required this.valuePaise,
    this.investedPaise,
    this.realisedPaise = 0,
    this.dividendsPaise = 0,
    this.xirr,
  });

  final PositionInput input;
  final int unitsE4;
  final int valuePaise;

  /// Cost of the units still held (FIFO), or the statement's cost value.
  final int? investedPaise;

  /// Gains booked on units sold (FIFO).
  final int realisedPaise;
  final int dividendsPaise;
  final double? xirr;

  int? get gainPaise =>
      investedPaise == null ? null : valuePaise - investedPaise!;

  double? get gainFraction {
    final i = investedPaise;
    if (i == null || i <= 0) return null;
    return (valuePaise - i) / i;
  }

  bool get isClosed => unitsE4 <= 0;
}

class PortfolioSummary {
  const PortfolioSummary({
    required this.positions,
    required this.valuePaise,
    required this.investedPaise,
    required this.realisedPaise,
    required this.valueWithCostPaise,
    this.xirr,
    this.asOf,
  });

  /// Open positions, largest value first.
  final List<Position> positions;
  final int valuePaise;

  /// Sum of known invested amounts.
  final int investedPaise;

  /// Value of the positions whose invested amount is known.
  final int valueWithCostPaise;
  final int realisedPaise;

  /// Over positions with transaction history.
  final double? xirr;
  final DateTime? asOf;

  /// Unrealised gain over positions with a known cost.
  int get gainPaise => valueWithCostPaise - investedPaise;

  bool get isEmpty => positions.isEmpty;

  /// Value by kind (mf / equity / other).
  Map<String, int> get byKind {
    final m = <String, int>{};
    for (final p in positions) {
      m[p.input.kind] = (m[p.input.kind] ?? 0) + p.valuePaise;
    }
    return m;
  }
}

/// Pure valuation over [PositionInput]s.
class PortfolioCalculator {
  const PortfolioCalculator();

  /// `opening` = units held before the first statement, at an estimated
  /// value on the statement's start date.
  static const _buyTypes = {
    'purchase',
    'sip',
    'switchIn',
    'dividendReinvest',
    'opening',
  };

  Position position(PositionInput p, DateTime asOf) {
    final txns = [...p.txns]..sort((a, b) => a.date.compareTo(b.date));

    // Units now: snapshot + later transactions, else the sum of transactions.
    int units;
    final snapDate = p.snapshotDate;
    if (p.snapshotUnitsE4 != null && snapDate != null) {
      units =
          p.snapshotUnitsE4! +
          txns
              .where((t) => t.date.isAfter(snapDate) && !t.date.isAfter(asOf))
              .fold<int>(0, (s, t) => s + (t.unitsE4 ?? 0));
    } else {
      units = txns
          .where((t) => !t.date.isAfter(asOf))
          .fold<int>(0, (s, t) => s + (t.unitsE4 ?? 0));
    }
    if (units < 0) units = 0;
    final price = p.priceE4 ?? 0;
    final value = (units * price / 1e6).round();

    // FIFO lots: [unitsE4, costPaise].
    final lots = <List<int>>[];
    var realised = 0;
    var dividends = 0;
    final flows = <CashFlow>[];
    var sawBuy = false;
    for (final t in txns) {
      if (t.date.isAfter(asOf)) break;
      final u = t.unitsE4 ?? 0;
      final amt = t.amountPaise ?? 0;
      if (u > 0 && _buyTypes.contains(t.type)) {
        sawBuy = true;
        lots.add([u, amt.abs()]);
        if (t.type != 'dividendReinvest') {
          flows.add(CashFlow(t.date, -amt.abs()));
        }
      } else if (u > 0) {
        // Bonus / merger units: no cost.
        lots.add([u, 0]);
      } else if (u < 0 && t.type == 'reversal') {
        // Cancels the purchase it reverses: newest lots first, no gain.
        var left = -u;
        while (left > 0 && lots.isNotEmpty) {
          final lot = lots.last;
          final take = math.min(left, lot[0]);
          lot[1] -= (lot[1] * take / lot[0]).round();
          lot[0] -= take;
          left -= take;
          if (lot[0] == 0) lots.removeLast();
        }
        flows.add(CashFlow(t.date, amt.abs()));
      } else if (u < 0) {
        var left = -u;
        var cost = 0;
        while (left > 0 && lots.isNotEmpty) {
          final lot = lots.first;
          final take = math.min(left, lot[0]);
          final c = (lot[1] * take / lot[0]).round();
          cost += c;
          lot[0] -= take;
          lot[1] -= c;
          left -= take;
          if (lot[0] == 0) lots.removeAt(0);
        }
        realised += amt.abs() - cost;
        flows.add(CashFlow(t.date, amt.abs()));
      } else if (t.type == 'dividendPayout' && amt > 0) {
        dividends += amt;
        flows.add(CashFlow(t.date, amt));
      }
    }

    int? invested;
    if (sawBuy) {
      invested = lots.fold<int>(0, (s, l) => s + l[1]);
      // Statement cost is authoritative when no later buys/sells happened.
      if (p.snapshotCostPaise != null &&
          snapDate != null &&
          !txns.any((t) => t.date.isAfter(snapDate))) {
        invested = p.snapshotCostPaise;
      }
    } else {
      invested = p.snapshotCostPaise;
    }

    double? rate;
    if (flows.isNotEmpty && value > 0) {
      rate = xirr([...flows, CashFlow(asOf, value)]);
    } else if (flows.isNotEmpty && units == 0) {
      rate = xirr(flows);
    }

    return Position(
      input: p,
      unitsE4: units,
      valuePaise: value,
      investedPaise: invested,
      realisedPaise: realised,
      dividendsPaise: dividends,
      xirr: rate,
    );
  }

  PortfolioSummary summarize(List<PositionInput> inputs, DateTime asOf) {
    final all = [for (final p in inputs) position(p, asOf)];
    final open = [
      for (final p in all)
        if (!p.isClosed) p,
    ]..sort((a, b) => b.valuePaise.compareTo(a.valuePaise));

    // Portfolio XIRR over every position with transaction flows.
    final flows = <CashFlow>[];
    for (final p in all) {
      final inner = <CashFlow>[];
      for (final t in p.input.txns) {
        if (t.date.isAfter(asOf)) continue;
        final u = t.unitsE4 ?? 0;
        final a = (t.amountPaise ?? 0).abs();
        if (u > 0 &&
            _buyTypes.contains(t.type) &&
            t.type != 'dividendReinvest') {
          inner.add(CashFlow(t.date, -a));
        } else if (u < 0) {
          inner.add(CashFlow(t.date, a));
        } else if (t.type == 'dividendPayout') {
          inner.add(CashFlow(t.date, a));
        }
      }
      if (inner.isEmpty) continue;
      flows.addAll(inner);
      if (p.valuePaise > 0) flows.add(CashFlow(asOf, p.valuePaise));
    }

    return PortfolioSummary(
      positions: open,
      valuePaise: open.fold(0, (s, p) => s + p.valuePaise),
      investedPaise: open.fold(0, (s, p) => s + (p.investedPaise ?? 0)),
      valueWithCostPaise: open.fold(
        0,
        (s, p) => s + (p.investedPaise == null ? 0 : p.valuePaise),
      ),
      realisedPaise: all.fold(0, (s, p) => s + p.realisedPaise),
      xirr: xirr(flows),
      asOf: asOf,
    );
  }
}

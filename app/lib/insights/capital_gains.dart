import 'dart:math' as math;

import 'portfolio.dart' show PositionTxn;
import 'yearly.dart' show FinancialYear;

/// How a security is taxed in India.
///
/// - [equity]: listed shares and equity-oriented funds (≥ 65% Indian equity,
///   incl. arbitrage / ELSS / index funds).
/// - [debt]: funds with > 65% in debt / money-market instruments ("specified
///   mutual funds"); units bought on or after 1 Apr 2023 are taxed at slab
///   rate whatever the holding period.
/// - [other]: everything else (gold / silver, international, most hybrids,
///   fund-of-funds).
enum TaxCategory { equity, debt, other }

extension TaxCategoryLabel on TaxCategory {
  String get label => switch (this) {
    TaxCategory.equity => 'Equity',
    TaxCategory.debt => 'Debt',
    TaxCategory.other => 'Other (gold, international, hybrid)',
  };
}

/// Category guessed from a fund's name (users can override per fund).
/// Shares are always [TaxCategory.equity].
TaxCategory guessTaxCategory(String name, String kind) {
  if (kind == 'equity') return TaxCategory.equity;
  final n = name.toLowerCase();
  bool has(String p) => RegExp(p).hasMatch(n);
  // Arbitrage funds are equity-oriented for tax.
  if (has(r'arbitrage')) return TaxCategory.equity;
  if (has(
    r'\bgold\b|\bsilver\b|international|global|overseas|\bus\b|'
    r'nasdaq|s&p|world|emerging market|greater china|japan|europe|'
    r'fund of funds?\b|\bfof\b',
  )) {
    return TaxCategory.other;
  }
  if (has(
    r'liquid|overnight|money market|\bdebt\b|\bbond|gilt|treasury|'
    r'banking (?:&|and) psu|corporate|credit risk|duration|floater|'
    r'floating rate|target maturity|\bpsu\b|\bincome\b|\bsdl\b|'
    r'constant maturity|\bt-?bill',
  )) {
    return TaxCategory.debt;
  }
  if (has(r'conservative hybrid|multi[- ]asset')) return TaxCategory.other;
  return TaxCategory.equity;
}

enum GainKind {
  /// Equity, held ≤ 12 months.
  stcgEquity,

  /// Equity, held > 12 months (exemption applies).
  ltcgEquity,

  /// Short-term non-equity, and all post-Apr-2023 debt fund gains: slab rate.
  slab,

  /// Long-term non-equity (other, pre-Apr-2023 debt).
  ltcgOther,
}

extension GainKindLabel on GainKind {
  String get label => switch (this) {
    GainKind.stcgEquity => 'Short-term (equity)',
    GainKind.ltcgEquity => 'Long-term (equity)',
    GainKind.slab => 'Taxed at your slab rate',
    GainKind.ltcgOther => 'Long-term (other)',
  };

  bool get isShortTerm => this == GainKind.stcgEquity || this == GainKind.slab;
}

/// Indian capital-gains rules by date. Checked Oct 2026 against Budget 2026
/// coverage (no changes for FY 2026-27); update here when rules change.
class CapitalGainsRules {
  const CapitalGainsRules();

  /// Budget 2024 changes applied to transfers from this date.
  static final budget2024 = DateTime(2024, 7, 23);

  /// Debt funds bought from this date are taxed at slab rate (s. 50AA).
  static final specifiedFundCutoff = DateTime(2023, 4, 1);

  /// Equity bought before this date is grandfathered at its 31 Jan 2018 price.
  static final grandfatherCutoff = DateTime(2018, 2, 1);

  /// Months an asset must be held (strictly more) to be long-term.
  int longTermMonths(TaxCategory c, DateTime sold) {
    if (c == TaxCategory.equity) return 12;
    return sold.isBefore(budget2024) ? 36 : 24;
  }

  GainKind kindOf(TaxCategory c, DateTime bought, DateTime sold) {
    if (c == TaxCategory.debt && !bought.isBefore(specifiedFundCutoff)) {
      return GainKind.slab;
    }
    final lt = sold.isAfter(_addMonths(bought, longTermMonths(c, sold)));
    if (c == TaxCategory.equity) {
      return lt ? GainKind.ltcgEquity : GainKind.stcgEquity;
    }
    return lt ? GainKind.ltcgOther : GainKind.slab;
  }

  /// Rate for [kind] (null = slab) under the rules at the end of [fy].
  double? rate(GainKind kind, FinancialYear fy) {
    final newRules = !fy.endExclusive.isBefore(budget2024);
    return switch (kind) {
      GainKind.stcgEquity => newRules ? 0.20 : 0.15,
      GainKind.ltcgEquity => newRules ? 0.125 : 0.10,
      GainKind.ltcgOther => newRules ? 0.125 : 0.20,
      GainKind.slab => null,
    };
  }

  /// Yearly exemption on equity LTCG (₹1.25 lakh from FY 2024-25).
  int equityExemptionPaise(FinancialYear fy) =>
      fy.startYear >= 2024 ? 12500000 : 10000000;

  static DateTime _addMonths(DateTime d, int m) {
    final t = DateTime(d.year, d.month + m, 1);
    final last = DateTime(t.year, t.month + 1, 0).day;
    return DateTime(t.year, t.month, math.min(d.day, last));
  }
}

/// One FIFO-matched slice of a sale.
class SaleLeg {
  const SaleLeg({
    required this.securityName,
    required this.category,
    required this.bought,
    required this.sold,
    required this.unitsE4,
    required this.costPaise,
    required this.proceedsPaise,
    required this.kind,
    this.costEstimated = false,
    this.grandfathered = false,
    this.grandfatheringMissing = false,
  });

  final String securityName;
  final TaxCategory category;
  final DateTime bought;
  final DateTime sold;
  final int unitsE4;
  final int costPaise;
  final int proceedsPaise;
  final GainKind kind;

  /// Units held before the first statement: cost and date are estimates.
  final bool costEstimated;

  /// Cost raised to the 31 Jan 2018 price.
  final bool grandfathered;

  /// Grandfathering applies but the 31 Jan 2018 price isn't known.
  final bool grandfatheringMissing;

  int get gainPaise => proceedsPaise - costPaise;
  FinancialYear get fy => FinancialYear.of(sold);
}

/// A fund / share with its transactions, for gains calculation.
class GainsInput {
  const GainsInput({
    required this.name,
    required this.category,
    required this.txns,
    this.fmv2018E4,
  });

  final String name;
  final TaxCategory category;
  final List<PositionTxn> txns;

  /// Price on 31 Jan 2018, for grandfathering.
  final int? fmv2018E4;
}

class FyGains {
  FyGains(this.fy);

  final FinancialYear fy;
  final List<SaleLeg> legs = [];

  /// Gross gain (+) / loss (−) by kind before set-off.
  Map<GainKind, int> get gross {
    final m = {for (final k in GainKind.values) k: 0};
    for (final l in legs) {
      m[l.kind] = m[l.kind]! + l.gainPaise;
    }
    return m;
  }

  bool get hasEstimates =>
      legs.any((l) => l.costEstimated || l.grandfatheringMissing);
}

/// Gains after setting off losses within the year, and the tax estimate.
class GainsTax {
  const GainsTax({
    required this.fy,
    required this.net,
    required this.exemptionUsedPaise,
    required this.exemptionLeftPaise,
    required this.taxPaise,
    required this.slabGainPaise,
    required this.lossCarriedPaise,
  });

  final FinancialYear fy;

  /// After set-off, by kind (never negative).
  final Map<GainKind, int> net;
  final int exemptionUsedPaise;
  final int exemptionLeftPaise;

  /// Tax on equity STCG, equity LTCG above the exemption and other LTCG
  /// (excluding slab-rate gains and cess / surcharge).
  final int taxPaise;

  /// Added to income and taxed at the user's slab rate.
  final int slabGainPaise;

  /// Losses left after set-off (can be carried forward 8 years if the
  /// return is filed on time).
  final int lossCarriedPaise;
}

class CapitalGainsCalculator {
  const CapitalGainsCalculator({this.rules = const CapitalGainsRules()});

  final CapitalGainsRules rules;

  static const _buys = {
    'purchase',
    'sip',
    'switchIn',
    'dividendReinvest',
    'opening',
  };

  /// Every sale leg (FIFO) for one holding.
  List<SaleLeg> legs(GainsInput g) => _run(g).legs;

  /// Lots still held after all transactions (oldest first).
  List<OpenLot> openLots(GainsInput g) => [
    for (final l in _run(g).lots)
      OpenLot(l.date, l.units, l.cost, estimated: l.estimated),
  ];

  ({List<SaleLeg> legs, List<_Lot> lots}) _run(GainsInput g) {
    final txns = [...g.txns]
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        // Buys before sells on the same day.
        return ((a.unitsE4 ?? 0) < 0 ? 1 : 0).compareTo(
          (b.unitsE4 ?? 0) < 0 ? 1 : 0,
        );
      });
    final lots = <_Lot>[];
    final out = <SaleLeg>[];
    for (final t in txns) {
      final u = t.unitsE4 ?? 0;
      if (u > 0) {
        lots.add(
          _Lot(
            t.date,
            u,
            _buys.contains(t.type) ? (t.amountPaise ?? 0).abs() : 0,
            estimated: t.type == 'opening',
          ),
        );
        continue;
      }
      if (u >= 0) continue;
      var left = -u;
      final proceeds = (t.amountPaise ?? 0).abs();
      if (t.type == 'reversal') {
        // Cancels the purchase it reverses: take units back from the
        // newest lots, no gain.
        while (left > 0 && lots.isNotEmpty) {
          final lot = lots.last;
          final take = math.min(left, lot.units);
          lot.cost -= (lot.cost * take / lot.units).round();
          lot.units -= take;
          left -= take;
          if (lot.units == 0) lots.removeLast();
        }
        continue;
      }
      while (left > 0 && lots.isNotEmpty) {
        final lot = lots.first;
        final take = math.min(left, lot.units);
        final cost = (lot.cost * take / lot.units).round();
        final share = (proceeds * take / -u).round();
        lot.units -= take;
        lot.cost -= cost;
        left -= take;
        if (lot.units == 0) lots.removeAt(0);

        var effCost = cost;
        var gf = false;
        var gfMissing = false;
        final kind = rules.kindOf(g.category, lot.date, t.date);
        if (g.category == TaxCategory.equity &&
            kind == GainKind.ltcgEquity &&
            lot.date.isBefore(CapitalGainsRules.grandfatherCutoff)) {
          final fmv = g.fmv2018E4;
          if (fmv == null) {
            gfMissing = true;
          } else {
            final fmvValue = (take * fmv / 1e6).round();
            final stepped = math.max(cost, math.min(fmvValue, share));
            gf = stepped != cost;
            effCost = stepped;
          }
        }
        out.add(
          SaleLeg(
            securityName: g.name,
            category: g.category,
            bought: lot.date,
            sold: t.date,
            unitsE4: take,
            costPaise: effCost,
            proceedsPaise: share,
            kind: kind,
            costEstimated: lot.estimated,
            grandfathered: gf,
            grandfatheringMissing: gfMissing,
          ),
        );
      }
    }
    return (legs: out, lots: lots);
  }

  /// Sale legs of all holdings grouped by financial year, newest first.
  List<FyGains> byYear(List<GainsInput> inputs) {
    final m = <int, FyGains>{};
    for (final g in inputs) {
      for (final l in legs(g)) {
        m.putIfAbsent(l.fy.startYear, () => FyGains(l.fy)).legs.add(l);
      }
    }
    final out = m.values.toList()
      ..sort((a, b) => b.fy.startYear.compareTo(a.fy.startYear));
    for (final y in out) {
      y.legs.sort((a, b) => a.sold.compareTo(b.sold));
    }
    return out;
  }

  /// Set-off within the year: short-term losses against any gains (slab
  /// first, then equity STCG, other LTCG, equity LTCG); long-term losses
  /// against long-term gains only (other first, so the equity exemption
  /// stays useful). Then the equity LTCG exemption and the tax estimate.
  GainsTax tax(FyGains y) {
    var stLoss = 0;
    var ltLoss = 0;
    final pos = {for (final k in GainKind.values) k: 0};
    for (final e in y.gross.entries) {
      if (e.value >= 0) {
        pos[e.key] = e.value;
      } else if (e.key.isShortTerm) {
        stLoss += -e.value;
      } else {
        ltLoss += -e.value;
      }
    }
    int absorb(GainKind k, int loss) {
      final used = math.min(pos[k]!, loss);
      pos[k] = pos[k]! - used;
      return loss - used;
    }

    for (final k in [
      GainKind.slab,
      GainKind.stcgEquity,
      GainKind.ltcgOther,
      GainKind.ltcgEquity,
    ]) {
      stLoss = absorb(k, stLoss);
    }
    for (final k in [GainKind.ltcgOther, GainKind.ltcgEquity]) {
      ltLoss = absorb(k, ltLoss);
    }

    final exemption = rules.equityExemptionPaise(y.fy);
    final used = math.min(exemption, pos[GainKind.ltcgEquity]!);
    final taxableLtEq = pos[GainKind.ltcgEquity]! - used;
    double tax = 0;
    tax += pos[GainKind.stcgEquity]! * rules.rate(GainKind.stcgEquity, y.fy)!;
    tax += taxableLtEq * rules.rate(GainKind.ltcgEquity, y.fy)!;
    tax += pos[GainKind.ltcgOther]! * rules.rate(GainKind.ltcgOther, y.fy)!;

    return GainsTax(
      fy: y.fy,
      net: pos,
      exemptionUsedPaise: used,
      exemptionLeftPaise: exemption - used,
      taxPaise: tax.round(),
      slabGainPaise: pos[GainKind.slab]!,
      lossCarriedPaise: stLoss + ltLoss,
    );
  }
}

/// A purchase lot still held.
class OpenLot {
  const OpenLot(
    this.date,
    this.unitsE4,
    this.costPaise, {
    this.estimated = false,
  });
  final DateTime date;
  final int unitsE4;
  final int costPaise;
  final bool estimated;
}

class _Lot {
  _Lot(this.date, this.units, this.cost, {this.estimated = false});
  final DateTime date;
  int units;
  int cost;
  final bool estimated;
}

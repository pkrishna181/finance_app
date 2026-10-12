import 'dart:math' as math;

import 'capital_gains.dart';
import 'yearly.dart';

/// A holding to consider for harvesting.
class HarvestInput {
  const HarvestInput({
    required this.gains,
    required this.accountLabel,
    required this.priceE4,
  });

  final GainsInput gains;
  final String accountLabel;

  /// Current price.
  final int priceE4;

  bool get isElss {
    final n = gains.name.toLowerCase();
    return n.contains('elss') ||
        n.contains('tax saver') ||
        n.contains('taxsaver');
  }
}

enum HarvestKind {
  /// Book long-term equity gains within the yearly exemption (then re-buy).
  exemptGain,

  /// Book a loss to offset taxable gains.
  loss,
}

class HarvestIdea {
  const HarvestIdea({
    required this.kind,
    required this.name,
    required this.accountLabel,
    required this.unitsE4,
    required this.saleValuePaise,
    required this.gainPaise,
    required this.longTerm,
    this.taxSavedPaise = 0,
    this.costEstimated = false,
  });

  final HarvestKind kind;
  final String name;
  final String accountLabel;

  /// Units to sell (oldest first — FIFO is how units are redeemed).
  final int unitsE4;
  final int saleValuePaise;

  /// Gain (+) or loss (−) booked by the sale.
  final int gainPaise;
  final bool longTerm;

  /// Tax this saves this year (estimate).
  final int taxSavedPaise;
  final bool costEstimated;
}

/// Pure harvesting suggestions for [fy] given gains already booked.
class TaxHarvester {
  const TaxHarvester({this.rules = const CapitalGainsRules()});

  final CapitalGainsRules rules;

  List<HarvestIdea> ideas(
    List<HarvestInput> holdings,
    FyGains booked, {
    required DateTime asOf,
  }) {
    final calc = CapitalGainsCalculator(rules: rules);
    final tax = calc.tax(booked);
    final fy = FinancialYear.of(asOf);
    var exemptionLeft = tax.exemptionLeftPaise;
    final out = <HarvestIdea>[];

    // 1) Exempt equity gains, biggest gains first.
    final gainIdeas = <HarvestIdea>[];
    for (final h in holdings) {
      if (h.gains.category != TaxCategory.equity || h.priceE4 <= 0) continue;
      var units = 0;
      var value = 0;
      var gain = 0;
      var est = false;
      for (final lot in _sellable(calc, h, asOf)) {
        if (rules.kindOf(TaxCategory.equity, lot.date, asOf) !=
            GainKind.ltcgEquity) {
          break; // FIFO: anything after this would be short-term
        }
        final lotValue = (lot.unitsE4 * h.priceE4 / 1e6).round();
        final lotGain = lotValue - lot.costPaise;
        if (lotGain <= 0) break; // a loss lot: leave it for loss harvesting
        units += lot.unitsE4;
        value += lotValue;
        gain += lotGain;
        est = est || lot.estimated;
      }
      if (gain > 0) {
        gainIdeas.add(
          HarvestIdea(
            kind: HarvestKind.exemptGain,
            name: h.gains.name,
            accountLabel: h.accountLabel,
            unitsE4: units,
            saleValuePaise: value,
            gainPaise: gain,
            longTerm: true,
            costEstimated: est,
          ),
        );
      }
    }
    gainIdeas.sort((a, b) => b.gainPaise.compareTo(a.gainPaise));
    for (final g in gainIdeas) {
      if (exemptionLeft <= 0) break;
      if (g.gainPaise <= exemptionLeft) {
        out.add(g);
        exemptionLeft -= g.gainPaise;
      } else {
        // Sell a proportional slice of the long-term units.
        final f = exemptionLeft / g.gainPaise;
        out.add(
          HarvestIdea(
            kind: HarvestKind.exemptGain,
            name: g.name,
            accountLabel: g.accountLabel,
            unitsE4: (g.unitsE4 * f).floor(),
            saleValuePaise: (g.saleValuePaise * f).floor(),
            gainPaise: exemptionLeft,
            longTerm: true,
            costEstimated: g.costEstimated,
          ),
        );
        exemptionLeft = 0;
      }
    }

    // 2) Losses, only when there are gains that would be taxed.
    final taxableSt = tax.net[GainKind.slab]! + tax.net[GainKind.stcgEquity]!;
    final taxableLt =
        tax.net[GainKind.ltcgOther]! +
        math.max(0, tax.net[GainKind.ltcgEquity]! - tax.exemptionUsedPaise);
    var stLeft = taxableSt;
    var ltLeft = taxableLt;
    if (stLeft + ltLeft > 0) {
      final lossIdeas = <HarvestIdea>[];
      for (final h in holdings) {
        if (h.priceE4 <= 0) continue;
        var units = 0;
        var value = 0;
        var loss = 0;
        var anyShort = false;
        var est = false;
        for (final lot in _sellable(calc, h, asOf)) {
          final lotValue = (lot.unitsE4 * h.priceE4 / 1e6).round();
          if (lotValue >= lot.costPaise) break;
          units += lot.unitsE4;
          value += lotValue;
          loss += lot.costPaise - lotValue;
          anyShort =
              anyShort ||
              rules.kindOf(h.gains.category, lot.date, asOf).isShortTerm;
          est = est || lot.estimated;
        }
        if (loss > 0) {
          lossIdeas.add(
            HarvestIdea(
              kind: HarvestKind.loss,
              name: h.gains.name,
              accountLabel: h.accountLabel,
              unitsE4: units,
              saleValuePaise: value,
              gainPaise: -loss,
              longTerm: !anyShort,
              costEstimated: est,
            ),
          );
        }
      }
      lossIdeas.sort((a, b) => a.gainPaise.compareTo(b.gainPaise));
      for (final l in lossIdeas) {
        var loss = -l.gainPaise;
        var saved = 0.0;
        // Short-term losses offset anything; long-term only long-term.
        if (!l.longTerm) {
          final useSt = math.min(loss, stLeft);
          saved += useSt * (rules.rate(GainKind.stcgEquity, fy) ?? 0.2);
          stLeft -= useSt;
          loss -= useSt;
        }
        final useLt = math.min(loss, ltLeft);
        saved += useLt * (rules.rate(GainKind.ltcgEquity, fy) ?? 0.125);
        ltLeft -= useLt;
        if (saved <= 0) continue;
        out.add(
          HarvestIdea(
            kind: HarvestKind.loss,
            name: l.name,
            accountLabel: l.accountLabel,
            unitsE4: l.unitsE4,
            saleValuePaise: l.saleValuePaise,
            gainPaise: l.gainPaise,
            longTerm: l.longTerm,
            taxSavedPaise: saved.round(),
            costEstimated: l.costEstimated,
          ),
        );
      }
    }
    return out;
  }

  /// Open lots that may be sold today (ELSS lots stay locked for 3 years).
  Iterable<OpenLot> _sellable(
    CapitalGainsCalculator calc,
    HarvestInput h,
    DateTime asOf,
  ) sync* {
    for (final lot in calc.openLots(h.gains)) {
      if (h.isElss &&
          asOf.isBefore(
            DateTime(lot.date.year + 3, lot.date.month, lot.date.day),
          )) {
        return; // FIFO: later lots are locked too
      }
      yield lot;
    }
  }
}

import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

PositionTxn buy(DateTime d, int units, int rupees) => PositionTxn(
    date: d, type: 'purchase', amountPaise: rupees * 100, unitsE4: units * 10000);
PositionTxn sell(DateTime d, int units, int rupees) => PositionTxn(
    date: d, type: 'redemption', amountPaise: -rupees * 100, unitsE4: -units * 10000);

HarvestInput h(String name, List<PositionTxn> t, int priceRupees,
        {TaxCategory c = TaxCategory.equity}) =>
    HarvestInput(
      gains: GainsInput(name: name, category: c, txns: t),
      accountLabel: 'Folio 1',
      priceE4: priceRupees * 10000,
    );

final asOf = DateTime(2026, 10, 12);
const fy = FinancialYear(2026);
const harvester = TaxHarvester();

void main() {
  test('books long-term gains up to the exemption, oldest lots first', () {
    final ideas = harvester.ideas([
      h('Flexi Cap', [
        buy(DateTime(2024, 1, 1), 1000, 100000), // ₹100 → LT
        buy(DateTime(2026, 6, 1), 100, 15000), // ₹150 → ST, stops here
      ], 200),
    ], FyGains(fy), asOf: asOf);
    final i = ideas.single;
    expect(i.kind, HarvestKind.exemptGain);
    // LT gain on all 1000 units = ₹1,00,000 (< ₹1.25 L): sell them all.
    expect(i.unitsE4, 10000000);
    expect(i.gainPaise, 10000000);
    expect(i.saleValuePaise, 20000000);
  });

  test('caps at the exemption left after gains already booked', () {
    final booked = FyGains(fy)
      ..legs.add(SaleLeg(
        securityName: 'x',
        category: TaxCategory.equity,
        bought: DateTime(2024),
        sold: DateTime(2026, 5),
        unitsE4: 1,
        costPaise: 0,
        proceedsPaise: 10000000, // ₹1 L used
        kind: GainKind.ltcgEquity,
      ));
    final ideas = harvester.ideas([
      h('Flexi Cap', [buy(DateTime(2024, 1, 1), 1000, 100000)], 200),
    ], booked, asOf: asOf);
    expect(ideas.single.gainPaise, 2500000); // ₹25,000 left
    expect(ideas.single.unitsE4, 2500000); // 250 units
  });

  test('skips debt funds and locked ELSS units', () {
    final ideas = harvester.ideas([
      h('Liquid', [buy(DateTime(2022, 1, 1), 100, 1000)], 20,
          c: TaxCategory.debt),
      h('Axis ELSS Tax Saver', [buy(DateTime(2024, 1, 1), 100, 1000)], 20),
      h('Old ELSS Tax Saver', [buy(DateTime(2023, 1, 1), 100, 1000)], 20),
    ], FyGains(fy), asOf: asOf);
    expect(ideas.map((i) => i.name), ['Old ELSS Tax Saver']);
  });

  test('suggests losses only when there are taxable gains', () {
    final losers = [
      h('Small Cap', [buy(DateTime(2026, 2, 1), 100, 20000)], 150), // ST loss ₹5k
    ];
    expect(harvester.ideas(losers, FyGains(fy), asOf: asOf), isEmpty);

    final booked = FyGains(fy)
      ..legs.add(SaleLeg(
        securityName: 'y',
        category: TaxCategory.equity,
        bought: DateTime(2026, 1),
        sold: DateTime(2026, 6),
        unitsE4: 1,
        costPaise: 0,
        proceedsPaise: 300000, // ₹3,000 STCG
        kind: GainKind.stcgEquity,
      ));
    final i = harvester.ideas(losers, booked, asOf: asOf).single;
    expect(i.kind, HarvestKind.loss);
    expect(i.gainPaise, -500000);
    expect(i.longTerm, isFalse);
    expect(i.taxSavedPaise, 60000); // 20% of the ₹3,000 it offsets
  });

  test('a long-term loss cannot offset short-term gains', () {
    final booked = FyGains(fy)
      ..legs.add(SaleLeg(
        securityName: 'y',
        category: TaxCategory.equity,
        bought: DateTime(2026, 1),
        sold: DateTime(2026, 6),
        unitsE4: 1,
        costPaise: 0,
        proceedsPaise: 300000,
        kind: GainKind.stcgEquity,
      ));
    final ideas = harvester.ideas([
      h('Old loser', [buy(DateTime(2023, 1, 1), 100, 20000)], 150),
    ], booked, asOf: asOf);
    expect(ideas, isEmpty);
  });
}

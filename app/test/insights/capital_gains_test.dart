import 'package:arth/core/db/database.dart';
import 'package:arth/insights/insights.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

PositionTxn buy(DateTime d, int units, int rupees, {String type = 'purchase'}) =>
    PositionTxn(date: d, type: type, amountPaise: rupees * 100, unitsE4: units * 10000);
PositionTxn sell(DateTime d, int units, int rupees, {String type = 'redemption'}) =>
    PositionTxn(date: d, type: type, amountPaise: -rupees * 100, unitsE4: -units * 10000);

const calc = CapitalGainsCalculator();
const rules = CapitalGainsRules();

List<SaleLeg> legsOf(TaxCategory c, List<PositionTxn> t, {int? fmv}) =>
    calc.legs(GainsInput(name: 'F', category: c, txns: t, fmv2018E4: fmv));

void main() {
  test('equity FIFO splits a sale into long- and short-term legs', () {
    final l = legsOf(TaxCategory.equity, [
      buy(DateTime(2025, 1, 10), 100, 10000),
      buy(DateTime(2025, 6, 10), 100, 12000),
      sell(DateTime(2026, 3, 15), 150, 22500),
    ]);
    expect(l, hasLength(2));
    expect(l[0].kind, GainKind.ltcgEquity);
    expect((l[0].costPaise, l[0].proceedsPaise), (1000000, 1500000));
    expect(l[1].kind, GainKind.stcgEquity);
    expect((l[1].costPaise, l[1].proceedsPaise), (600000, 750000));
    final y = calc.byYear([
      GainsInput(name: 'F', category: TaxCategory.equity, txns: [
        buy(DateTime(2025, 1, 10), 100, 10000),
        buy(DateTime(2025, 6, 10), 100, 12000),
        sell(DateTime(2026, 3, 15), 150, 22500),
      ]),
    ]).single;
    expect(y.fy.label, 'FY 2025-26');
    final t = calc.tax(y);
    expect(t.taxPaise, 30000); // 20% of ₹1,500 STCG; LTCG under exemption
    expect(t.exemptionUsedPaise, 500000);
    expect(t.exemptionLeftPaise, 12500000 - 500000);
  });

  test('long-term means strictly more than 12 months', () {
    final bought = DateTime(2025, 3, 15);
    expect(rules.kindOf(TaxCategory.equity, bought, DateTime(2026, 3, 15)),
        GainKind.stcgEquity);
    expect(rules.kindOf(TaxCategory.equity, bought, DateTime(2026, 3, 16)),
        GainKind.ltcgEquity);
    // Month-end: bought 31 Jan → 12 months later clamps to 31 Jan.
    expect(rules.kindOf(TaxCategory.equity, DateTime(2025, 1, 31),
        DateTime(2026, 2, 1)), GainKind.ltcgEquity);
  });

  test('debt funds: slab after Apr 2023, 24-month LTCG before', () {
    expect(rules.kindOf(TaxCategory.debt, DateTime(2023, 5, 1),
        DateTime(2026, 6, 1)), GainKind.slab);
    expect(rules.kindOf(TaxCategory.debt, DateTime(2022, 1, 1),
        DateTime(2025, 6, 1)), GainKind.ltcgOther);
    expect(rules.kindOf(TaxCategory.debt, DateTime(2022, 1, 1),
        DateTime(2023, 12, 1)), GainKind.slab); // 23 months
    // Sold before 23 Jul 2024: 36 months needed.
    expect(rules.kindOf(TaxCategory.debt, DateTime(2022, 1, 1),
        DateTime(2024, 5, 1)), GainKind.slab);
  });

  test('other (gold / international): 24 months', () {
    final b = DateTime(2024, 1, 1);
    expect(rules.kindOf(TaxCategory.other, b, DateTime(2025, 12, 1)),
        GainKind.slab);
    expect(rules.kindOf(TaxCategory.other, b, DateTime(2026, 2, 1)),
        GainKind.ltcgOther);
  });

  test('rates and exemption by year', () {
    const old = FinancialYear(2023);
    const now = FinancialYear(2026);
    expect(rules.rate(GainKind.stcgEquity, old), 0.15);
    expect(rules.rate(GainKind.ltcgEquity, old), 0.10);
    expect(rules.rate(GainKind.stcgEquity, now), 0.20);
    expect(rules.rate(GainKind.ltcgEquity, now), 0.125);
    expect(rules.rate(GainKind.slab, now), isNull);
    expect(rules.equityExemptionPaise(old), 10000000);
    expect(rules.equityExemptionPaise(const FinancialYear(2024)), 12500000);
  });

  test('grandfathering for equity bought before 1 Feb 2018', () {
    final t = [buy(DateTime(2017, 6, 1), 10, 1000)]; // ₹100 a unit
    // 31 Jan 2018 price ₹150; sold at ₹200 → cost ₹150 a unit.
    final up = legsOf(TaxCategory.equity,
        [...t, sell(DateTime(2025, 6, 1), 10, 2000)], fmv: 1500000).single;
    expect(up.costPaise, 150000);
    expect(up.grandfathered, isTrue);
    // Sold at ₹130 (below the 2018 price) → cost = sale value, no gain.
    final mid = legsOf(TaxCategory.equity,
        [...t, sell(DateTime(2025, 6, 1), 10, 1300)], fmv: 1500000).single;
    expect(mid.gainPaise, 0);
    // Unknown 2018 price: flagged, actual cost kept.
    final missing = legsOf(TaxCategory.equity,
        [...t, sell(DateTime(2025, 6, 1), 10, 2000)]).single;
    expect(missing.grandfatheringMissing, isTrue);
    expect(missing.costPaise, 100000);
  });

  test('set-off order, exemption and carried losses', () {
    final y = FyGains(const FinancialYear(2025));
    SaleLeg leg(GainKind k, int gainRupees) => SaleLeg(
          securityName: 'x',
          category: TaxCategory.equity,
          bought: DateTime(2024),
          sold: DateTime(2025, 6),
          unitsE4: 1,
          costPaise: gainRupees < 0 ? -gainRupees * 100 : 0,
          proceedsPaise: gainRupees < 0 ? 0 : gainRupees * 100,
          kind: k,
        );
    y.legs.addAll([
      leg(GainKind.stcgEquity, 50000),
      leg(GainKind.ltcgEquity, -20000), // LT loss: LT gains only
      leg(GainKind.slab, -10000), // ST loss: any gains
    ]);
    final t = calc.tax(y);
    expect(t.net[GainKind.stcgEquity], 4000000);
    expect(t.lossCarriedPaise, 2000000);
    expect(t.taxPaise, 800000); // 20% of ₹40,000

    final big = FyGains(const FinancialYear(2025))
      ..legs.add(leg(GainKind.ltcgEquity, 200000));
    final bt = calc.tax(big);
    expect(bt.exemptionUsedPaise, 12500000);
    expect(bt.taxPaise, 937500); // 12.5% of ₹75,000
    expect(bt.exemptionLeftPaise, 0);
  });

  test('reversals make no gain; opening lots are marked estimated', () {
    final l = legsOf(TaxCategory.equity, [
      buy(DateTime(2025, 4, 1), 10, 1000, type: 'opening'),
      buy(DateTime(2025, 5, 1), 5, 600),
      sell(DateTime(2025, 5, 3), 5, 600, type: 'reversal'),
      sell(DateTime(2026, 6, 1), 10, 1500),
    ]);
    expect(l, hasLength(1));
    expect(l.single.costEstimated, isTrue);
    expect(l.single.costPaise, 100000);
  });

  test('guessTaxCategory', () {
    TaxCategory g(String n) => guessTaxCategory(n, 'mf');
    expect(g('HDFC Flexi Cap Fund - Direct Plan - Growth'), TaxCategory.equity);
    expect(g('Mirae Asset ELSS Tax Saver Fund'), TaxCategory.equity);
    expect(g('Kotak Equity Arbitrage Fund'), TaxCategory.equity);
    expect(g('Parag Parikh Liquid Fund'), TaxCategory.debt);
    expect(g('ICICI Prudential Corporate Bond Fund'), TaxCategory.debt);
    expect(g('SBI Magnum Gilt Fund'), TaxCategory.debt);
    expect(g('Nippon India Gold Savings Fund'), TaxCategory.other);
    expect(g('Motilal Oswal Nasdaq 100 FOF'), TaxCategory.other);
    expect(g('Franklin India Feeder - Franklin U.S. Opportunities'),
        TaxCategory.equity); // ambiguous names default to equity
    expect(guessTaxCategory('INFOSYS LIMITED', 'equity'), TaxCategory.equity);
  });

  test('repository: override persists and feeds the calculation', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final sec = await db.into(db.securities).insert(SecuritiesCompanion.insert(
        isin: 'INF000A01011', name: 'Some Hybrid Fund', kind: 'mf'));
    final acct = await db.into(db.investmentAccounts).insert(
        InvestmentAccountsCompanion.insert(
            kind: 'folio', number: '1', provider: 'CAMS'));
    for (final (i, t) in [
      buy(DateTime(2023, 1, 1), 10, 1000),
      sell(DateTime(2025, 6, 1), 10, 1500),
    ].indexed) {
      await db.into(db.investmentTxns).insert(InvestmentTxnsCompanion.insert(
            accountId: acct,
            securityId: sec,
            date: t.date,
            type: t.type,
            description: t.type,
            amountPaise: Value(t.amountPaise),
            unitsE4: Value(t.unitsE4),
            dedupeHash: 'h$i',
          ));
    }
    final repo = CapitalGainsRepository(db);
    expect((await repo.categories())[sec]!.category, TaxCategory.equity);
    expect((await repo.byYear(DateTime(2026))).single.legs.single.kind,
        GainKind.ltcgEquity);
    await repo.setCategory(sec, TaxCategory.debt);
    expect((await repo.categories())[sec]!.isOverride, isTrue);
    // Bought before Apr 2023, held 29 months → long-term other.
    expect((await repo.byYear(DateTime(2026))).single.legs.single.kind,
        GainKind.ltcgOther);
    await repo.setCategory(sec, null);
    expect((await repo.categories())[sec]!.isOverride, isFalse);
  });
}

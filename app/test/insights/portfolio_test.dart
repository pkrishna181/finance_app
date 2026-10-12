import 'dart:io';
import 'dart:math' as math;

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('xirr', () {
    test('single investment, one year', () {
      final r = xirr([
        CashFlow(DateTime(2021, 1, 1), -1000000),
        CashFlow(DateTime(2022, 1, 1), 1100000),
      ])!;
      expect(r, closeTo(0.10, 1e-6)); // 365 days → exactly 10%
    });

    test('irregular flows satisfy NPV = 0', () {
      final flows = [
        CashFlow(DateTime(2024, 1, 10), -500000),
        CashFlow(DateTime(2024, 4, 3), -500000),
        CashFlow(DateTime(2024, 9, 20), -300000),
        CashFlow(DateTime(2025, 2, 1), 200000),
        CashFlow(DateTime(2026, 6, 30), 1400000),
      ];
      final r = xirr(flows)!;
      final t0 = flows.first.date;
      final npv = flows.fold<double>(
          0,
          (s, f) =>
              s + f.paise / math.pow(1 + r, f.date.difference(t0).inDays / 365));
      expect(npv.abs(), lessThan(1));
    });

    test('losses give a negative rate', () {
      final r = xirr([
        CashFlow(DateTime(2025, 1, 1), -1000000),
        CashFlow(DateTime(2026, 1, 1), 800000),
      ])!;
      expect(r, closeTo(-0.2, 1e-6));
    });

    test('not computable', () {
      expect(xirr([CashFlow(DateTime(2025), -1)]), isNull);
      expect(
          xirr([CashFlow(DateTime(2025), -1), CashFlow(DateTime(2026), -1)]),
          isNull);
      expect(
          xirr([
            CashFlow(DateTime(2025, 1, 1), -1),
            CashFlow(DateTime(2025, 1, 3), 2),
          ]),
          isNull); // under a week
    });
  });

  group('PortfolioCalculator', () {
    const calc = PortfolioCalculator();
    final asOf = DateTime(2026, 9, 30);

    PositionInput input(List<PositionTxn> txns,
            {int? priceE4, int? snapUnits, DateTime? snapDate, int? cost}) =>
        PositionInput(
          securityId: 1,
          accountId: 1,
          name: 'Fund',
          kind: 'mf',
          accountLabel: 'Folio 1',
          txns: txns,
          priceE4: priceE4,
          snapshotUnitsE4: snapUnits,
          snapshotDate: snapDate,
          snapshotCostPaise: cost,
        );

    test('FIFO cost, realised gain, dividends and XIRR', () {
      final p = calc.position(
        input([
          PositionTxn(date: DateTime(2025, 1, 1), type: 'purchase',
              amountPaise: 1000000, unitsE4: 1000000), // 100 u @ ₹100
          PositionTxn(date: DateTime(2025, 6, 1), type: 'sip',
              amountPaise: 1200000, unitsE4: 1000000), // 100 u @ ₹120
          PositionTxn(date: DateTime(2026, 1, 1), type: 'redemption',
              amountPaise: -1500000, unitsE4: -1000000), // sell 100 u @ ₹150
          PositionTxn(date: DateTime(2026, 3, 1), type: 'dividendPayout',
              amountPaise: 20000),
          PositionTxn(date: DateTime(2026, 3, 1), type: 'tax',
              amountPaise: 25),
        ], priceE4: 1600000), // ₹160 now
        asOf,
      );
      expect(p.unitsE4, 1000000);
      expect(p.valuePaise, 1600000);
      expect(p.investedPaise, 1200000); // the ₹120 lot remains
      expect(p.gainPaise, 400000);
      expect(p.realisedPaise, 500000); // 1500 − 1000 (first lot)
      expect(p.dividendsPaise, 20000);
      expect(p.xirr, isNotNull);
      expect(p.xirr!, greaterThan(0.2));
    });

    test('snapshot units plus later transactions; snapshot cost when quiet',
        () {
      final quiet = calc.position(
        input(
          [
            PositionTxn(date: DateTime(2025, 1, 1), type: 'purchase',
                amountPaise: 1000000, unitsE4: 1000000),
          ],
          priceE4: 1200000,
          snapUnits: 1000000,
          snapDate: DateTime(2026, 6, 30),
          cost: 1000050, // includes stamp duty
        ),
        asOf,
      );
      expect(quiet.investedPaise, 1000050);

      final later = calc.position(
        input(
          [
            PositionTxn(date: DateTime(2026, 8, 1), type: 'sip',
                amountPaise: 120000, unitsE4: 100000),
          ],
          priceE4: 1200000,
          snapUnits: 1000000,
          snapDate: DateTime(2026, 6, 30),
        ),
        asOf,
      );
      expect(later.unitsE4, 1100000);
      expect(later.valuePaise, 1320000);
    });

    test('holding without history: value only, cost from statement', () {
      final p = calc.position(
        input(const [], priceE4: 29505000, snapUnits: 100000,
            snapDate: DateTime(2026, 9, 30)),
        asOf,
      );
      expect(p.valuePaise, 2950500);
      expect(p.investedPaise, isNull);
      expect(p.xirr, isNull);
    });

    test('summary excludes unknown-cost positions from gain', () {
      final s = calc.summarize([
        input([
          PositionTxn(date: DateTime(2025, 9, 30), type: 'purchase',
              amountPaise: 1000000, unitsE4: 1000000),
        ], priceE4: 1100000),
        PositionInput(
          securityId: 2,
          accountId: 2,
          name: 'Shares',
          kind: 'equity',
          accountLabel: 'NSDL',
          priceE4: 1000000,
          snapshotUnitsE4: 100000,
          snapshotDate: DateTime(2026, 9, 30),
        ),
      ], asOf);
      expect(s.positions, hasLength(2));
      expect(s.valuePaise, 1100000 + 100000); // 10 units × ₹100
      expect(s.investedPaise, 1000000);
      expect(s.gainPaise, 100000);
      expect(s.xirr!, closeTo(0.1, 1e-3));
      expect(s.byKind, {'mf': 1100000, 'equity': 100000});
    });
  });

  test('repository values the imported CAS fixture', () async {
    final db = ArthDatabase.memory();
    addTearDown(db.close);
    final lines = [
      for (final d in ['../test/golden/cas', 'test/golden/cas'])
        if (File('$d/cams_detailed.txt').existsSync())
          ...File('$d/cams_detailed.txt').readAsLinesSync(),
    ];
    await CasImporter(db).store(const CasParser().parse(lines),
        fileName: 'x', contentHash: 'h');
    final s = await PortfolioRepository(db).summary(DateTime(2026, 9, 30));
    expect(s.positions, hasLength(3));
    // Values reproduce the statement's market values within rounding.
    expect(s.valuePaise, closeTo(2722649 + 1105662 + 2537276, 300));
    final hdfc = s.positions.firstWhere((p) => p.input.isin == 'INF179K01UT0');
    expect(hdfc.investedPaise, 2399950); // statement cost (no later txns)
    expect(hdfc.realisedPaise, greaterThan(0));
    expect(hdfc.input.accountLabel, 'Folio 1234567/89');
    // Opening units are costed at the period start, so XIRR stays sane
    // (NAV went 1,999.90 → 2,250.12 over ~18 months).
    expect(hdfc.xirr!, inInclusiveRange(0.05, 0.15));
    expect(s.xirr!, inInclusiveRange(0.0, 0.2));
  });
}

import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;

InsightTxn tx(int rupees, DateTime at, String? cat, {bool debit = true}) =>
    InsightTxn(
      id: ++_id,
      amountPaise: rupees * 100,
      isDebit: debit,
      bookedAt: at,
      bankCode: 'HDFC',
      categorySlug: cat,
      rawMerchant: 'Shop',
    );

void main() {
  test('FinancialYear boundaries and labels', () {
    expect(FinancialYear.of(DateTime(2026, 3, 31)).startYear, 2025);
    expect(FinancialYear.of(DateTime(2026, 4, 1)).startYear, 2026);
    const fy = FinancialYear(2026);
    expect(fy.label, 'FY 2026-27');
    expect(fy.months.first, MonthKey(2026, 4));
    expect(fy.months.last, MonthKey(2027, 3));
    expect(fy.endExclusive, DateTime(2027, 4));
    expect(const FinancialYear(1999).label, 'FY 1999-00');
  });

  test('YearSummary totals, income sources, refunds, daily spend', () {
    final agg = InsightsAggregator([
      tx(9999, DateTime(2026, 3, 31), 'groceries'), // previous FY
      tx(100000, DateTime(2026, 4, 1), 'salary', debit: false),
      tx(500, DateTime(2026, 6, 30), 'interest', debit: false),
      tx(2000, DateTime(2026, 7, 2), null, debit: false), // other credit
      tx(3000, DateTime(2026, 5, 10, 9), 'groceries'),
      tx(1000, DateTime(2026, 5, 10, 18), 'fuel'),
      tx(500, DateTime(2026, 5, 12), 'groceries', debit: false), // refund
      tx(4000, DateTime(2027, 3, 31), 'shopping'),
      tx(7777, DateTime(2027, 4, 1), 'shopping'), // next FY
    ]);
    final y = YearSummary.build(agg, const FinancialYear(2026));
    expect(y.months, hasLength(12));
    expect(y.incomeBySource, {
      'salary': 10000000,
      'interest': 50000,
      kOtherIncomeSlug: 200000,
    });
    expect(y.incomePaise, 10250000);
    expect(y.spendByCategory,
        {'groceries': 250000, 'fuel': 100000, 'shopping': 400000});
    expect(y.spendPaise, 750000);
    expect(y.netPaise, 9500000);
    expect(y.savingsRate, closeTo(0.927, 0.001));
    // Gross debits by day; refunds don't reduce the heatmap.
    expect(y.dailySpend[DateTime(2026, 5, 10)], 400000);
    expect(y.dailySpend.containsKey(DateTime(2026, 5, 12)), isFalse);
    expect(y.dailySpend[DateTime(2027, 3, 31)], 400000);
    expect(y.dailySpend.containsKey(DateTime(2026, 3, 31)), isFalse);
  });

  test('savingsRate is null without income', () {
    final agg = InsightsAggregator([tx(100, DateTime(2026, 5, 1), 'fuel')]);
    expect(YearSummary.build(agg, const FinancialYear(2026)).savingsRate,
        isNull);
  });

  test('quantile thresholds and intensity levels', () {
    final th = quantileThresholds([0, 10, 20, 30, 40, 50, 60, 70, 80]);
    expect(th, [30, 50, 70]);
    expect(intensityLevel(0, th), 0);
    expect(intensityLevel(10, th), 1);
    expect(intensityLevel(30, th), 1);
    expect(intensityLevel(31, th), 2);
    expect(intensityLevel(80, th), 4);
    expect(quantileThresholds(const []), isEmpty);
    expect(intensityLevel(5, const []), 1);
  });
}

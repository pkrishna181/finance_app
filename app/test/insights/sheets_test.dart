import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';

const ev = SheetEvaluator();

double? v(String text, {SheetData data = const SheetData()}) =>
    ev.evaluate(text, data: data).last.value;

String? err(String text) => ev.evaluate(text).last.error;

void main() {
  test('arithmetic, precedence, power, unary minus', () {
    expect(v('2 + 3 * 4'), 14);
    expect(v('(2 + 3) * 4'), 20);
    expect(v('2 ^ 3 ^ 2'), 512); // right-associative
    expect(v('-3 + 10 / 4'), -0.5);
    expect(v('10 × 2 ÷ 4 − 1'), 4);
  });

  test('Indian numbers and units', () {
    expect(v('40,00,000'), 4000000);
    expect(v('1,234,567.5'), 1234567.5);
    expect(v('40L'), 4000000);
    expect(v('1.5 cr'), 15000000);
    expect(v('12k + 500'), 12500);
    expect(v('₹2.5 lakh'), 250000);
  });

  test('percent and "of"', () {
    expect(v('20% of 40L'), 800000);
    expect(v('8.6%'), closeTo(0.086, 1e-12));
    expect(v('1000 * 18%'), 180);
  });

  test('variables, sum of the block, headings reset it', () {
    final lines = ev.evaluate('''
# Home loan
price = 40L
down = 20% of price
loan = price - down
// a comment
rent = 25k
food = 15k
total

# New block
a = 1
sum''');
    expect(lines[0].kind, SheetLineKind.heading);
    expect(lines[2].value, 800000);
    expect(lines[3].value, 3200000);
    expect(lines[3].name, 'loan');
    expect(lines[4].kind, SheetLineKind.comment);
    // total = price + down + loan + rent + food (same block)
    expect(lines[7].value, 4000000 + 800000 + 3200000 + 25000 + 15000);
    expect(lines.last.value, 1);
  });

  test('finance functions', () {
    expect(v('emi(10L, 9, 10)'), closeTo(12667.58, 0.01));
    expect(v('emi(4000000,9,20)'), closeTo(35989.04, 0.01)); // no spaces
    expect(v('emi(40,00,000, 9, 20)'), closeTo(35989.04, 0.01));
    expect(v('emi(4,000,000, 9, 20)'), closeTo(35989.04, 0.01));
    expect(v('sip(10k, 12, 10)'), closeTo(2323390.76, 1));
    expect(v('fv(1L, 10, 2)'), closeTo(121000, 1e-6));
    expect(v('pv(121000, 10, 2)'), closeTo(100000, 1e-6));
    expect(v('round(2/3, 2)'), 0.67);
    expect(v('max(3, 9, 4) - min(3, 9, 4)'), 6);
  });

  test('your data', () {
    const data = SheetData(
      netWorth: 5000000,
      investments: 3000000,
      cash: 200000,
      spendByMonth: [
        {'groceries': 9000, 'food_delivery': 4000},
        {'groceries': 8000},
        {'groceries': 10000},
        {'groceries': 12000},
      ],
      incomeByMonth: [150000, 150000],
      categoryNames: {'food delivery': 'food_delivery'},
    );
    expect(v('networth - cash', data: data), 4800000);
    expect(v('spend("groceries")', data: data), 9000);
    expect(v('spend("Food Delivery")', data: data), 4000);
    expect(v('spend("all")', data: data), 13000);
    expect(v('spend("groceries", 1)', data: data), 8000);
    expect(v('avg_spend("groceries", 3)', data: data), 10000);
    expect(v('income(1) - spend("all", 1)', data: data), 142000);
    expect(v('spend("nothing")', data: data), 0);
  });

  test('errors are per line and do not stop later lines', () {
    final lines = ev.evaluate('x = 5\ny + 1\nx * 2\n10 / 0\nemi(1)\nsum = 3\n(1 + 2');
    expect(lines[1].error, 'unknown name "y"');
    expect(lines[2].value, 10);
    expect(lines[3].error, 'division by zero');
    expect(lines[4].error, contains('emi: needs 2 arguments'));
    expect(lines[5].error, contains('built-in'));
    expect(lines[6].error, 'missing )');
    expect(err('5 \$'), 'unexpected "\$"');
  });

  test('formatSheetNumber uses Indian grouping', () {
    expect(formatSheetNumber(1234567.891), '12,34,567.89');
    expect(formatSheetNumber(999), '999');
    expect(formatSheetNumber(-4000000), '−40,00,000');
    expect(formatSheetNumber(0.5), '0.5');
  });
}

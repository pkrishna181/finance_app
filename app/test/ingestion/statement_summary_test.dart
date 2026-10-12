import 'package:arth/ingestion/statement/statement_summary.dart';
import 'package:flutter_test/flutter_test.dart';

List<List<String>> csv(String s) =>
    [for (final l in s.trim().split('\n')) l.split(',')];

void main() {
  test('HDFC card header: ending, due date', () {
    final s = extractStatementSummary(csv('''
HDFC Bank Credit Card Statement
Card ending 4455
Payment Due Date,15-08-2026

Date,Description,Amount
10/07/2026,ZOMATO MEDIA PVT LTD,899.00 Dr'''));
    expect(s.last4, '4455');
    expect(s.dueDate, DateTime(2026, 8, 15));
    expect(s.totalDuePaise, isNull);
  });

  test('bank account number masked', () {
    final s = extractStatementSummary(csv('''
HDFC Bank Ltd
Account No,XXXXXXXX1234
Date,Narration,Withdrawal Amt.'''));
    expect(s.last4, '1234');
    expect(s.hasBill, isFalse);
  });

  test('plain account number after a label', () {
    final s = extractStatementSummary(
        [['Account Number : 50100012345678'], ['Txn Date', 'Description']]);
    expect(s.last4, '5678');
  });

  test('summary box: labels row over values row', () {
    final s = extractStatementSummary([
      ['Credit Card No.', '5241 XXXX XXXX 9876'],
      ['Statement Date', 'Payment Due Date', 'Total Amount Due', 'Minimum Amount Due', 'Credit Limit', 'Available Credit Limit'],
      ['12/09/2026', '02/10/2026', '₹23,456.78', '₹1,180.00', '2,00,000.00', '1,76,543.22'],
      ['Date', 'Transaction Details', 'Amount'],
    ]);
    expect(s.last4, '9876');
    expect(s.statementDate, DateTime(2026, 9, 12));
    expect(s.dueDate, DateTime(2026, 10, 2));
    expect(s.totalDuePaise, 2345678);
    expect(s.minDuePaise, 118000);
    expect(s.creditLimitPaise, 20000000);
  });

  test('same-row label: value pairs', () {
    final s = extractStatementSummary([
      ['Total Amount Due: Rs. 4,500.00'],
      ['Minimum Due: Rs 225'],
      ['Due Date: 05 Nov 2026'],
      ['Card Number: 4375XXXXXXXX1122'],
    ]);
    expect(s.totalDuePaise, 450000);
    expect(s.minDuePaise, 22500);
    expect(s.dueDate, DateTime(2026, 11, 5));
    expect(s.last4, '1122');
  });

  test('several card numbers (add-on cards): no last4 guess', () {
    final s = extractStatementSummary([
      ['Card ending 1111'],
      ['Card ending 2222'],
    ]);
    expect(s.last4, isNull);
  });

  test('ordinary rows yield nothing', () {
    final s = extractStatementSummary(csv('''
Date,Description,Amount
05 Jul 2026,SWIGGY BANGALORE,450.00
08 Jul 2026,AMAZON PAY,1299.00'''));
    expect(s.isEmpty, isTrue);
  });
}

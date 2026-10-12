import 'dart:io';

import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> fixture(String name) {
  for (final d in ['../test/golden/cas', 'test/golden/cas']) {
    final f = File('$d/$name');
    if (f.existsSync()) return f.readAsLinesSync();
  }
  fail('missing fixture $name');
}

void main() {
  group('helpers', () {
    test('parseScaled', () {
      expect(parseScaled('1,23,456.789', 4), 1234567890);
      expect(parseScaled('(6,000.00)', 2), -600000);
      expect(parseScaled('-2.8', 4), -28000);
      expect(parseScaled('.196', 4), 1960);
      expect(parseScaled('2.00005', 4), 20001); // rounds half up
      expect(parseScaled('abc', 2), isNull);
    });

    test('parseCasDate', () {
      expect(parseCasDate('10-May-2025'), DateTime(2025, 5, 10));
      expect(parseCasDate('30-09-2026'), DateTime(2026, 9, 30));
      expect(parseCasDate('31-Feb-2026'), isNull);
    });

    test('cleanSchemeName', () {
      expect(
        cleanSchemeName('B92Z-HDFC Flexi Cap Fund - Direct Plan - Growth Option '
            '(Non-Demat) - ISIN: INF179K01UT0(Advisor: DIRECT) Registrar : CAMS'),
        'HDFC Flexi Cap Fund - Direct Plan - Growth Option',
      );
      expect(
        cleanSchemeName('MAEF-Mirae Asset ELSS Tax Saver Fund - Direct Plan - '
            'IDCW (formerly Mirae Asset Tax Saver Fund) - ISIN: INF769K01DH9'),
        'Mirae Asset ELSS Tax Saver Fund - Direct Plan - IDCW',
      );
    });

    test('classifyCasTxn', () {
      expect(classifyCasTxn('Purchase-SIP Instalment 1/60', 25000), CasTxnType.sip);
      expect(classifyCasTxn('Purchase', 1), CasTxnType.purchase);
      expect(classifyCasTxn('Redemption', -1), CasTxnType.redemption);
      expect(classifyCasTxn('Switch Out - To Liquid', -1), CasTxnType.switchOut);
      expect(classifyCasTxn('S T P In', 1), CasTxnType.switchIn);
      expect(classifyCasTxn('*** Stamp Duty ***', null), CasTxnType.tax);
      expect(classifyCasTxn('IDCW Paid @ Rs.1.50 per unit', null),
          CasTxnType.dividendPayout);
      expect(classifyCasTxn('IDCW Reinvestment @ Rs.0.50', 1),
          CasTxnType.dividendReinvest);
      expect(classifyCasTxn('Purchase Reversal - insufficient balance', -1),
          CasTxnType.reversal);
    });
  });

  test('detailed CAMS / KFintech CAS', () {
    final lines = fixture('cams_detailed.txt');
    expect(looksLikeCas(lines), isTrue);
    final st = const CasParser().parse(lines);
    expect(st.provider, CasProvider.cams);
    expect(st.periodFrom, DateTime(2025, 4, 1));
    expect(st.periodTo, DateTime(2026, 9, 30));
    expect(st.warnings, isEmpty);
    expect(st.folios.map((f) => f.folio),
        ['1234567/89', '7788990011', '55443322']);
    expect(st.folios.first.amc, 'HDFC Mutual Fund');
    expect(st.folios.first.pan, 'ABCDE1234F');

    final hdfc = st.folios[0].schemes.single;
    expect(hdfc.name, 'HDFC Flexi Cap Fund - Direct Plan - Growth Option');
    expect(hdfc.isin, 'INF179K01UT0');
    expect(hdfc.registrar, 'CAMS');
    expect(hdfc.openingE4, 100000);
    expect(hdfc.closingE4, 121000);
    expect(hdfc.computedClosingE4, 121000);
    expect(hdfc.navE4, 22501234);
    expect(hdfc.navDate, DateTime(2026, 9, 30));
    expect(hdfc.costPaise, 2399950);
    expect(hdfc.valuePaise, 2722649); // wrapped onto the next line
    expect(hdfc.txns, hasLength(6));
    final sip = hdfc.txns[0];
    expect(sip.type, CasTxnType.sip);
    expect(sip.date, DateTime(2025, 5, 10));
    expect(sip.amountPaise, 499975);
    expect(sip.unitsE4, 25000);
    expect(sip.navE4, 19999000);
    expect(sip.balanceE4, 125000);
    expect(hdfc.txns[1].type, CasTxnType.tax);
    expect(hdfc.txns[1].amountPaise, 25);
    final red = hdfc.txns[4];
    expect(red.type, CasTxnType.redemption);
    expect(red.amountPaise, -600000);
    expect(red.unitsE4, -28000);

    final elss = st.folios[1].schemes.single;
    expect(elss.isin, 'INF769K01DH9'); // header wrapped over two lines
    expect(elss.registrar, 'KFINTECH');
    expect(elss.name, 'Mirae Asset ELSS Tax Saver Fund - Direct Plan - IDCW');
    final types = elss.txns.map((t) => t.type).toList();
    expect(types, [
      CasTxnType.purchase,
      CasTxnType.tax,
      CasTxnType.dividendPayout,
      CasTxnType.dividendReinvest,
    ]);
    expect(elss.txns[2].amountPaise, 60000);
    expect(elss.txns[2].unitsE4, isNull);
    expect(elss.closingE4, 4078430);

    final liquid = st.folios[2].schemes.single;
    expect(liquid.txns.single.type, CasTxnType.switchIn);
    expect(liquid.txns.single.unitsE4, 181234);
    // 4-decimal units, 3-decimal closing: within rounding.
    expect(liquid.closingE4, 181230);

    // Detailed schemes aren't duplicated as holdings.
    expect(st.holdings, isEmpty);
  });

  test('NSDL CAS: equities and MF folios from holdings tables', () {
    final lines = fixture('nsdl.txt');
    expect(looksLikeCas(lines), isTrue);
    final st = const CasParser().parse(lines);
    expect(st.provider, CasProvider.nsdl);
    expect(st.periodTo, DateTime(2026, 9, 30));
    expect(st.holdings.map((h) => h.isin), [
      'INE002A01018',
      'INE009A01021',
      'INE062A01020',
      'INF179K01UT0',
    ]);
    final infy = st.holdings[1];
    expect(infy.name, 'INFOSYS LIMITED');
    expect(infy.unitsE4, 250000);
    expect(infy.priceE4, 18204000);
    expect(infy.valuePaise, 4551000);
    expect(infy.account, 'IN303028/12345678');
    expect(infy.isMutualFund, isFalse);
    final mf = st.holdings[3];
    expect(mf.name, 'HDFC Flexi Cap Fund - Direct Growth');
    expect(mf.unitsE4, 121000);
    expect(mf.priceE4, 22501234);
    expect(mf.valuePaise, 2722649);
    expect(mf.isMutualFund, isTrue);
  });

  test('CDSL CAS: balance columns between quantity and price', () {
    final st = const CasParser().parse(fixture('cdsl.txt'));
    expect(st.provider, CasProvider.cdsl);
    expect(st.periodTo, DateTime(2026, 9, 30));
    expect(st.holdings, hasLength(2));
    expect(st.holdings[0].name, 'HDFC BANK LIMITED');
    expect(st.holdings[0].unitsE4, 150000);
    expect(st.holdings[0].account, '1208160012345678');
    expect(st.holdings[1].unitsE4, 30000);
    expect(st.holdings[1].valuePaise, 1233000);
  });

  test('bank statements are not CAS', () {
    expect(
      looksLikeCas([
        'HDFC Bank Ltd',
        'Statement of account',
        'Date Narration Withdrawal Deposit Balance',
      ]),
      isFalse,
    );
  });

  test('units that do not add up produce a warning', () {
    final st = const CasParser().parse([
      'Consolidated Account Statement',
      'X Mutual Fund',
      'Folio No: 1',
      'ABC-X Fund - Growth - ISIN: INF000X01011 Registrar : CAMS',
      'Opening Unit Balance: 0.000',
      '01-Jan-2026 Purchase 1,000.00 10.000 100.0000 10.000',
      'Closing Unit Balance: 15.000 NAV on 31-Jan-2026: INR 100.0000',
    ]);
    expect(st.warnings.single, contains('X Fund - Growth'));
  });
}

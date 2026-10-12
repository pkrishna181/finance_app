import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:arth/ingestion/investments/amfi_nav.dart';
import 'package:arth/ingestion/investments/cas_import.dart';
import 'package:arth/ingestion/investments/cas_parser.dart';
import 'package:arth/insights/insights.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _newFormat = '''
Scheme Code;ISIN Div Payout/ ISIN Growth;ISIN Div Reinvestment;Scheme Name;Plan;Option;Net Asset Value;Date

Open Ended Schemes(Equity Scheme - Flexi Cap Fund)

HDFC Mutual Fund

118955;INF179K01UT0;-;HDFC Flexi Cap Fund;Direct Plan;Growth Option;2310.5000;12-Oct-2026
135763;INF846K01WS2;INF846K01WQ6;Axis Children's Fund;Direct Plan;IDCW Option;26.7589;12-Oct-2026
999999;INF000X01011;-;Bad NAV Fund;Direct Plan;Growth;N.A.;12-Oct-2026
''';

const _oldFormat = '''
Scheme Code;ISIN Div Payout/ ISIN Growth;ISIN Div Reinvestment;Scheme Name;Net Asset Value;Date
120503;INF769K01DH9;-;Mirae Asset ELSS Tax Saver Fund - Direct Plan - IDCW;28.1234;11-Oct-2026
''';

void main() {
  test('parseAmfiNav: new and old layouts, both ISIN columns, bad rows', () {
    final n = parseAmfiNav(_newFormat);
    expect(n['INF179K01UT0']!.navE4, 23105000);
    expect(n['INF179K01UT0']!.date, DateTime(2026, 10, 12));
    expect(n['INF846K01WS2']!.navE4, 267589);
    expect(n['INF846K01WQ6']!.navE4, 267589);
    expect(n.containsKey('INF000X01011'), isFalse);
    expect(parseAmfiNav(_oldFormat)['INF769K01DH9']!.navE4, 281234);
  });

  group('AmfiNavUpdater', () {
    late ArthDatabase db;
    var fetches = 0;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = ArthDatabase.memory();
      fetches = 0;
      final f = ['../test/golden/cas', 'test/golden/cas']
          .map((d) => File('$d/cams_detailed.txt'))
          .firstWhere((f) => f.existsSync());
      await CasImporter(db).store(
          const CasParser().parse(f.readAsLinesSync()),
          fileName: 'x',
          contentHash: 'x');
    });
    tearDown(() => db.close());

    AmfiNavUpdater updater({bool fail = false}) => AmfiNavUpdater(db,
        fetch: () async {
          fetches++;
          if (fail) throw const SocketException('offline');
          return '$_newFormat$_oldFormat';
        });

    test('does nothing until the user opts in', () async {
      final r = await updater().update();
      expect(r.errorOrNull, 'price_feed_disabled');
      expect(fetches, 0);
      expect(await updater().updateIfStale(), isNull);
      expect(fetches, 0);
    });

    test('stores NAVs for held funds; portfolio uses them', () async {
      await PriceFeedSettings().setEnabled(true);
      final r = await updater().update(now: DateTime(2026, 10, 12, 20));
      expect(r.okOrNull, 2); // HDFC Flexi Cap + Mirae ELSS (held); Axis not
      final s = await PortfolioRepository(db).summary(DateTime(2026, 10, 12, 23));
      final hdfc = s.positions.firstWhere((p) => p.input.isin == 'INF179K01UT0');
      expect(hdfc.input.priceE4, 23105000);
      expect(hdfc.input.priceDate, DateTime(2026, 10, 12));
      expect(hdfc.valuePaise, (121000 * 23105000 / 1e6).round());
      expect(await PriceFeedSettings().lastUpdate(), DateTime(2026, 10, 12, 20));
    });

    test('updateIfStale: at most once per maxAge', () async {
      await PriceFeedSettings().setEnabled(true);
      final t = DateTime(2026, 10, 12, 8);
      expect((await updater().updateIfStale(now: t))!.isOk, isTrue);
      expect(await updater().updateIfStale(now: t.add(const Duration(hours: 5))),
          isNull);
      expect(fetches, 1);
      await updater().updateIfStale(now: t.add(const Duration(hours: 21)));
      expect(fetches, 2);
    });

    test('network failure is reported, nothing written', () async {
      await PriceFeedSettings().setEnabled(true);
      final r = await updater(fail: true).update();
      expect(r.errorOrNull, 'price_feed_failed');
      final amfi = await (db.select(db.securityPrices)
            ..where((p) => p.source.equals('amfi')))
          .get();
      expect(amfi, isEmpty);
      expect(await PriceFeedSettings().lastUpdate(), isNull);
    });
  });
}

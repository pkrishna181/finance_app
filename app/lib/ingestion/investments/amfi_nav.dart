import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/database.dart';
import '../../core/result/result.dart';
import 'cas_parser.dart' show parseCasDate, parseScaled;

/// AMFI's public file with the latest NAV of every mutual-fund scheme.
///
/// Privacy: this is a plain GET of one public file — no query parameters,
/// cookies or identifiers — and the whole list is downloaded, so the request
/// reveals nothing about what the user holds. Matching to holdings happens
/// on the phone. Only used after the user opts in.
const kAmfiNavUrl = 'https://portal.amfiindia.com/spages/NAVAll.txt';

class AmfiNav {
  const AmfiNav(this.date, this.navE4);
  final DateTime date;
  final int navE4;
}

/// ISIN → latest NAV from the `NAVAll.txt` body. Reads NAV and date from
/// the last two columns and ISINs from columns 2–3, so both the older
/// 6-column and newer 8-column (with Plan / Option) layouts work.
Map<String, AmfiNav> parseAmfiNav(String body) {
  final out = <String, AmfiNav>{};
  final isinRe = RegExp(r'^IN[F][0-9A-Z]{8}\d$');
  for (final raw in const LineSplitter().convert(body)) {
    final parts = raw.split(';');
    if (parts.length < 6) continue;
    final date = parseCasDate(parts.last.trim());
    final nav = parseScaled(parts[parts.length - 2].trim(), 4);
    if (date == null || nav == null || nav <= 0) continue;
    for (final c in [parts[1], parts[2]]) {
      final isin = c.trim();
      if (isinRe.hasMatch(isin)) out[isin] = AmfiNav(date, nav);
    }
  }
  return out;
}

/// Opt-in state and last update time (shared preferences; no financial
/// data).
class PriceFeedSettings {
  static const _enabledKey = 'amfi_nav_enabled_v1';
  static const _lastKey = 'amfi_nav_last_update_v1';

  Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;

  Future<void> setEnabled(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_enabledKey, v);

  Future<DateTime?> lastUpdate() async {
    final ms = (await SharedPreferences.getInstance()).getInt(_lastKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastUpdate(DateTime t) async =>
      (await SharedPreferences.getInstance())
          .setInt(_lastKey, t.millisecondsSinceEpoch);
}

/// Downloads the AMFI list (only when the user opted in) and stores NAVs for
/// the funds already in the database.
class AmfiNavUpdater {
  AmfiNavUpdater(
    this._db, {
    PriceFeedSettings? settings,
    Future<String> Function()? fetch,
  })  : _settings = settings ?? PriceFeedSettings(),
        _fetch = fetch ?? _download;

  final ArthDatabase _db;
  final PriceFeedSettings _settings;
  final Future<String> Function() _fetch;

  static Future<String> _download() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final req = await client.getUrl(Uri.parse(kAmfiNavUrl));
      final res = await req.close().timeout(const Duration(seconds: 60));
      if (res.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${res.statusCode}');
      }
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }

  /// Updates prices if enabled. Returns how many funds got a new NAV, or
  /// `Err('price_feed_disabled')` / `Err('price_feed_failed')`.
  Future<Result<int>> update({DateTime? now}) async {
    if (!await _settings.isEnabled()) return const Err('price_feed_disabled');
    final String body;
    try {
      body = await _fetch();
    } catch (e) {
      return Err('price_feed_failed', e);
    }
    final navs = parseAmfiNav(body);
    if (navs.isEmpty) return const Err('price_feed_failed');

    var updated = 0;
    final funds = await (_db.select(_db.securities)
          ..where((s) => s.kind.equals('mf')))
        .get();
    await _db.transaction(() async {
      for (final f in funds) {
        final n = navs[f.isin];
        if (n == null) continue;
        await _db.into(_db.securityPrices).insert(
              SecurityPricesCompanion.insert(
                securityId: f.id,
                date: n.date,
                priceE4: n.navE4,
                source: 'amfi',
              ),
              onConflict: DoUpdate(
                (_) => SecurityPricesCompanion(
                  priceE4: Value(n.navE4),
                  source: const Value('amfi'),
                ),
                target: [_db.securityPrices.securityId, _db.securityPrices.date],
              ),
            );
        updated++;
      }
    });
    await _settings.setLastUpdate(now ?? DateTime.now());
    return Ok(updated);
  }

  /// [update] when enabled and the last update is older than [maxAge].
  Future<Result<int>?> updateIfStale({
    Duration maxAge = const Duration(hours: 20),
    DateTime? now,
  }) async {
    if (!await _settings.isEnabled()) return null;
    final t = now ?? DateTime.now();
    final last = await _settings.lastUpdate();
    if (last != null && t.difference(last) < maxAge) return null;
    return update(now: t);
  }
}

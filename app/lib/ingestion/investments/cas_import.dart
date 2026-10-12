import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import 'cas_parser.dart';

/// What one CAS import added.
class CasImportResult {
  const CasImportResult({
    required this.provider,
    required this.schemes,
    required this.holdings,
    required this.newTxns,
    required this.valuePaise,
    this.asOf,
    this.warnings = const [],
  });

  final CasProvider provider;

  /// Funds with transaction history (detailed CAS).
  final int schemes;

  /// Holdings from holdings tables (demat / summary CAS).
  final int holdings;

  /// Investment transactions not seen before.
  final int newTxns;

  /// Total value on the statement date.
  final int valuePaise;
  final DateTime? asOf;
  final List<String> warnings;

  String get providerLabel => switch (provider) {
    CasProvider.cams => 'CAMS',
    CasProvider.kfintech => 'KFintech',
    CasProvider.nsdl => 'NSDL',
    CasProvider.cdsl => 'CDSL',
    CasProvider.unknown => 'CAS',
  };
}

/// Stores a parsed [CasStatement]: securities, folios / demat accounts,
/// transactions (deduped by content, so overlapping statements are safe),
/// closing holdings and prices.
class CasImporter {
  CasImporter(this._db);

  final ArthDatabase _db;

  static String providerCode(CasProvider p) => switch (p) {
    CasProvider.cams => 'CAMS',
    CasProvider.kfintech => 'KFINTECH',
    CasProvider.nsdl => 'NSDL',
    CasProvider.cdsl => 'CDSL',
    CasProvider.unknown => 'UNKNOWN',
  };

  /// Fails with `duplicate_file` when this exact file was imported before,
  /// or `cas_empty` when nothing could be read.
  Future<({CasImportResult? result, String? error})> store(
    CasStatement st, {
    required String fileName,
    required String contentHash,
  }) async {
    final existing = await _db.findImportByHash(contentHash);
    if (existing != null && existing.status == 'succeeded') {
      return (result: null, error: 'duplicate_file');
    }
    if (st.isEmpty) return (result: null, error: 'cas_empty');

    final provider = providerCode(st.provider);
    late CasImportResult result;
    await _db.transaction(() async {
      final importId = await _db
          .into(_db.imports)
          .insert(
            ImportsCompanion.insert(
              sourceType: 'cas',
              sourceLabel: fileName,
              contentHash: contentHash,
              status: const Value('pending'),
            ),
          );
      var newTxns = 0;
      var value = 0;
      var schemes = 0;
      final asOf = st.asOf;

      for (final folio in st.folios) {
        if (folio.schemes.isEmpty) continue;
        final accountId = await _account(
          'folio',
          folio.folio,
          provider,
          amc: folio.amc,
        );
        for (final s in folio.schemes) {
          schemes++;
          final secId = await _security(
            s.isin ?? 'NOISIN:${s.name}',
            s.name,
            'mf',
            amc: folio.amc,
          );
          for (final t in s.txns) {
            final hash = sha256
                .convert(
                  utf8.encode(
                    [
                      folio.folio,
                      s.isin ?? s.name,
                      t.date.toIso8601String().substring(0, 10),
                      t.type.name,
                      t.amountPaise,
                      t.unitsE4,
                      t.description,
                    ].join('|'),
                  ),
                )
                .toString();
            final known = await (_db.select(
              _db.investmentTxns,
            )..where((x) => x.dedupeHash.equals(hash))).getSingleOrNull();
            if (known == null) {
              newTxns++;
              await _db
                  .into(_db.investmentTxns)
                  .insert(
                    InvestmentTxnsCompanion.insert(
                      accountId: accountId,
                      securityId: secId,
                      date: t.date,
                      type: t.type.name,
                      description: t.description,
                      amountPaise: Value(t.amountPaise),
                      unitsE4: Value(t.unitsE4),
                      navE4: Value(t.navE4),
                      balanceE4: Value(t.balanceE4),
                      importId: Value(importId),
                      dedupeHash: hash,
                    ),
                  );
            }
            if (t.navE4 != null && t.navE4! > 0) {
              await _price(secId, t.date, t.navE4!);
            }
          }
          final units = s.closingE4;
          final date = s.navDate ?? asOf;
          if (units != null && date != null) {
            final nav =
                s.navE4 ??
                (s.valuePaise != null && units > 0
                    ? (s.valuePaise! * 1e6 / units).round()
                    : null);
            final v =
                s.valuePaise ?? (nav == null ? 0 : (units * nav / 1e6).round());
            value += v;
            if (nav != null) {
              await _snapshot(
                accountId,
                secId,
                date,
                units,
                nav,
                v,
                cost: s.costPaise,
                importId: importId,
              );
              await _price(secId, date, nav);
            }
          }
        }
      }

      for (final h in st.holdings) {
        final date = asOf;
        if (date == null) continue;
        final accountId = await _account(
          h.isMutualFund && h.account == null ? 'folio' : 'demat',
          h.account ?? '$provider holdings',
          provider,
        );
        final secId = await _security(
          h.isin,
          h.name,
          h.isMutualFund ? 'mf' : 'equity',
        );
        await _snapshot(
          accountId,
          secId,
          date,
          h.unitsE4,
          h.priceE4,
          h.valuePaise,
          importId: importId,
        );
        await _price(secId, date, h.priceE4);
        value += h.valuePaise;
      }

      await (_db.update(
        _db.imports,
      )..where((i) => i.id.equals(importId))).write(
        ImportsCompanion(
          status: const Value('succeeded'),
          rowCount: Value(newTxns),
          parsedCount: Value(schemes + st.holdings.length),
          notes: Value(
            'cas=$provider'
            '${st.warnings.isEmpty ? '' : '; warnings=${st.warnings.length}'}',
          ),
        ),
      );

      result = CasImportResult(
        provider: st.provider,
        schemes: schemes,
        holdings: st.holdings.length,
        newTxns: newTxns,
        valuePaise: value,
        asOf: asOf,
        warnings: st.warnings,
      );
    });
    return (result: result, error: null);
  }

  Future<int> _account(
    String kind,
    String number,
    String provider, {
    String? amc,
  }) async {
    final found =
        await (_db.select(_db.investmentAccounts)
              ..where((a) => a.kind.equals(kind) & a.number.equals(number)))
            .getSingleOrNull();
    if (found != null) return found.id;
    return _db
        .into(_db.investmentAccounts)
        .insert(
          InvestmentAccountsCompanion.insert(
            kind: kind,
            number: number,
            provider: provider,
            amc: Value(amc),
          ),
        );
  }

  Future<int> _security(
    String isin,
    String name,
    String kind, {
    String? amc,
  }) async {
    final found = await (_db.select(
      _db.securities,
    )..where((s) => s.isin.equals(isin))).getSingleOrNull();
    if (found != null) {
      // Prefer the longer (more descriptive) name.
      if (name.length > found.name.length) {
        await (_db.update(_db.securities)..where((s) => s.id.equals(found.id)))
            .write(SecuritiesCompanion(name: Value(name)));
      }
      return found.id;
    }
    return _db
        .into(_db.securities)
        .insert(
          SecuritiesCompanion.insert(
            isin: isin,
            name: name,
            kind: kind,
            amc: Value(amc),
          ),
        );
  }

  Future<void> _snapshot(
    int accountId,
    int securityId,
    DateTime asOf,
    int unitsE4,
    int priceE4,
    int valuePaise, {
    int? cost,
    int? importId,
  }) {
    final day = DateTime(asOf.year, asOf.month, asOf.day);
    return _db
        .into(_db.holdingSnapshots)
        .insert(
          HoldingSnapshotsCompanion.insert(
            accountId: accountId,
            securityId: securityId,
            asOf: day,
            unitsE4: unitsE4,
            priceE4: priceE4,
            valuePaise: valuePaise,
            costPaise: Value(cost),
            importId: Value(importId),
          ),
          onConflict: DoUpdate(
            (_) => HoldingSnapshotsCompanion(
              unitsE4: Value(unitsE4),
              priceE4: Value(priceE4),
              valuePaise: Value(valuePaise),
              costPaise: Value(cost),
            ),
            target: [
              _db.holdingSnapshots.accountId,
              _db.holdingSnapshots.securityId,
              _db.holdingSnapshots.asOf,
            ],
          ),
        );
  }

  Future<void> _price(int securityId, DateTime date, int priceE4) {
    final day = DateTime(date.year, date.month, date.day);
    return _db
        .into(_db.securityPrices)
        .insert(
          SecurityPricesCompanion.insert(
            securityId: securityId,
            date: day,
            priceE4: priceE4,
            source: 'cas',
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}

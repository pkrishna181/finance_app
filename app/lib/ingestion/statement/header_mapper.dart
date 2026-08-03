import 'statement_profiles/axis.dart';
import 'statement_profiles/generic.dart';
import 'statement_profiles/hdfc.dart';
import 'statement_profiles/icici.dart';
import 'statement_profiles/kotak.dart';
import 'statement_profiles/profile.dart';
import 'statement_profiles/sbi.dart';

export 'statement_profiles/profile.dart'
    show StatementField, StatementProfile, genericSynonyms;

class ColumnBinding {
  const ColumnBinding({
    required this.field,
    required this.index,
    required this.confidence,
    required this.matchedHeader,
  });

  final StatementField field;
  final int index;
  final double confidence;
  final String matchedHeader;
}

class ColumnMap {
  const ColumnMap({
    required this.headerRowIndex,
    required this.bindings,
    required this.bankCode,
    required this.profileId,
    required this.overallConfidence,
  });

  final int headerRowIndex;
  final List<ColumnBinding> bindings;
  final String bankCode;
  final String profileId;
  final double overallConfidence;

  int? indexOf(StatementField field) {
    for (final b in bindings) {
      if (b.field == field) return b.index;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
        'header_row_index': headerRowIndex,
        'bank_code': bankCode,
        'profile_id': profileId,
        'overall_confidence': overallConfidence,
        'bindings': [
          for (final b in bindings)
            {
              'field': b.field.name,
              'index': b.index,
              'confidence': b.confidence,
              'matched_header': b.matchedHeader,
            },
        ],
      };
}

/// Score candidate header rows and map columns via synonyms + fuzzy match.
class HeaderMapper {
  HeaderMapper({List<StatementProfile>? profiles})
      : _profiles = profiles ??
            [
              hdfcAccountProfile(),
              hdfcCreditCardProfile(),
              iciciAccountProfile(),
              iciciCreditCardProfile(),
              sbiAccountProfile(),
              axisAccountProfile(),
              axisCreditCardProfile(),
              kotakAccountProfile(),
              genericAccountProfile(),
            ];

  final List<StatementProfile> _profiles;

  ColumnMap map(List<List<String>> rows) {
    if (rows.isEmpty) {
      return const ColumnMap(
        headerRowIndex: 0,
        bindings: [],
        bankCode: 'UNKNOWN',
        profileId: 'empty',
        overallConfidence: 0,
      );
    }

    final bankHint = _guessBank(rows);
    final profile = _selectProfile(rows, bankHint);

    var bestScore = -1.0;
    var bestIndex = 0;
    List<ColumnBinding> bestBindings = const [];

    final scanLimit = rows.length < 40 ? rows.length : 40;
    for (var i = 0; i < scanLimit; i++) {
      final row = rows[i];
      if (_looksLikeJunk(row, profile)) continue;
      final scored = _scoreHeaderRow(row, profile);
      if (scored.score > bestScore) {
        bestScore = scored.score;
        bestIndex = i;
        bestBindings = scored.bindings;
      }
    }

    return ColumnMap(
      headerRowIndex: bestIndex,
      bindings: bestBindings,
      bankCode: profile.bankCode,
      profileId: profile.id,
      overallConfidence: bestScore,
    );
  }

  StatementProfile _selectProfile(List<List<String>> rows, String bankHint) {
    final blob = rows.take(15).expand((r) => r).join(' ').toLowerCase();
    StatementProfile? best;
    var bestScore = -1.0;
    for (final p in _profiles) {
      var s = 0.0;
      if (p.bankCode == bankHint) s += 2;
      for (final marker in p.junkMarkers) {
        if (blob.contains(marker.toLowerCase())) s += 0.5;
      }
      for (final syn in p.headerSynonyms.values.expand((e) => e)) {
        if (blob.contains(syn.toLowerCase())) s += 0.2;
      }
      if (p.isCreditCard &&
          (blob.contains('credit card') || blob.contains('card statement'))) {
        s += 1.5;
      }
      if (!p.isCreditCard && blob.contains('account statement')) s += 0.5;
      if (s > bestScore) {
        bestScore = s;
        best = p;
      }
    }
    return best ?? genericAccountProfile();
  }

  String _guessBank(List<List<String>> rows) {
    final blob = rows.take(12).expand((r) => r).join(' ').toUpperCase();
    if (RegExp(r'\bHDFC\b').hasMatch(blob)) return 'HDFC';
    if (RegExp(r'\bICICI\b').hasMatch(blob)) return 'ICICI';
    if (RegExp(r'\bAXIS\b').hasMatch(blob)) return 'AXIS';
    if (RegExp(r'\bKOTAK\b').hasMatch(blob)) return 'KOTAK';
    if (RegExp(r'\bSBI\b|\bSTATE BANK\b').hasMatch(blob)) return 'SBI';
    return 'UNKNOWN';
  }

  bool _looksLikeJunk(List<String> row, StatementProfile profile) {
    final joined = row.join(' ').toLowerCase();
    if (joined.trim().isEmpty) return true;
    for (final m in profile.junkMarkers) {
      if (joined.contains(m.toLowerCase()) && !_hasHeaderishTokens(row)) {
        return true;
      }
    }
    return false;
  }

  bool _hasHeaderishTokens(List<String> row) {
    const tokens = [
      'date',
      'narration',
      'description',
      'withdrawal',
      'deposit',
      'amount',
      'balance',
      'debit',
      'credit',
    ];
    final joined = row.join(' ').toLowerCase();
    var hits = 0;
    for (final t in tokens) {
      if (joined.contains(t)) hits++;
    }
    return hits >= 2;
  }

  ({double score, List<ColumnBinding> bindings}) _scoreHeaderRow(
    List<String> row,
    StatementProfile profile,
  ) {
    final bindings = <ColumnBinding>[];
    var score = 0.0;
    final used = <int>{};

    // Prefer `amount` before debit/credit so a bare "Amount" header does not
    // match the "debit amount" synonym via substring contains.
    const fieldOrder = [
      StatementField.date,
      StatementField.narration,
      StatementField.ref,
      StatementField.amount,
      StatementField.debit,
      StatementField.credit,
      StatementField.drcrFlag,
      StatementField.balance,
    ];

    for (final field in fieldOrder) {
      final synonyms = [
        ...?profile.headerSynonyms[field],
        ...?genericSynonyms[field],
      ];
      var bestConf = 0.0;
      var bestIdx = -1;
      var bestHeader = '';
      for (var i = 0; i < row.length; i++) {
        if (used.contains(i)) continue;
        final cell = row[i].trim();
        if (cell.isEmpty) continue;
        final conf = _matchConfidence(cell, synonyms);
        if (conf > bestConf) {
          bestConf = conf;
          bestIdx = i;
          bestHeader = cell;
        }
      }
      if (bestIdx >= 0 && bestConf >= 0.55) {
        used.add(bestIdx);
        bindings.add(
          ColumnBinding(
            field: field,
            index: bestIdx,
            confidence: bestConf,
            matchedHeader: bestHeader,
          ),
        );
        score += bestConf;
      }
    }

    final hasDate = bindings.any((b) => b.field == StatementField.date);
    final hasAmt = bindings.any(
      (b) =>
          b.field == StatementField.amount ||
          b.field == StatementField.debit ||
          b.field == StatementField.credit,
    );
    if (!hasDate || !hasAmt) {
      return (score: 0, bindings: const []);
    }
    return (score: score, bindings: bindings);
  }

  double _matchConfidence(String cell, List<String> synonyms) {
    final n = _norm(cell);
    var best = 0.0;
    for (final s in synonyms) {
      final sn = _norm(s);
      if (n == sn) return 1.0;
      if (n.contains(sn)) {
        best = best < 0.85 ? 0.85 : best;
      } else if (sn.contains(n) && n.length >= 8) {
        // Avoid "amount" ⊆ "debit amount".
        best = best < 0.7 ? 0.7 : best;
      } else {
        final sim = _tokenOverlap(n, sn);
        if (sim > best) best = sim;
      }
    }
    return best;
  }

  String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  double _tokenOverlap(String a, String b) {
    final at = a.split(' ').where((t) => t.isNotEmpty).toSet();
    final bt = b.split(' ').where((t) => t.isNotEmpty).toSet();
    if (at.isEmpty || bt.isEmpty) return 0;
    final inter = at.intersection(bt).length;
    final uni = at.union(bt).length;
    return inter / uni;
  }
}

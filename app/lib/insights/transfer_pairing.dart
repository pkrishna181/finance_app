import 'insight_models.dart';

/// Detects own-account movements (bank → card bill, savings → savings) so they
/// are not counted as spend or income.
///
/// A debit and a credit are paired when they have the same amount, sit on
/// different accounts, and are booked within [window] of each other. Each row
/// pairs at most once (nearest date wins).
///
/// Guards against coincidences (a friend repaying the exact amount you paid):
/// both sides must be uncategorized or in a transfer category, and rows the
/// user explicitly categorized elsewhere are never paired.
class TransferPairing {
  const TransferPairing({this.window = const Duration(days: 3)});

  final Duration window;

  /// IDs to exclude from spend/income: paired rows plus anything the user
  /// (or a rule) categorized as a self-transfer.
  Set<int> excludedIds(List<InsightTxn> txns) {
    final out = <int>{
      for (final t in txns)
        if (t.categorySlug == kSelfTransferSlug) t.id,
    };
    out.addAll(pairedIds(txns));
    return out;
  }

  Set<int> pairedIds(List<InsightTxn> txns) {
    final debits = <InsightTxn>[];
    final credits = <InsightTxn>[];
    for (final t in txns) {
      if (!_eligible(t)) continue;
      (t.isDebit ? debits : credits).add(t);
    }

    final creditsByAmount = <int, List<InsightTxn>>{};
    for (final c in credits) {
      creditsByAmount.putIfAbsent(c.amountPaise, () => []).add(c);
    }

    debits.sort((a, b) => a.bookedAt.compareTo(b.bookedAt));
    final used = <int>{};
    final paired = <int>{};

    for (final d in debits) {
      final candidates = creditsByAmount[d.amountPaise];
      if (candidates == null) continue;
      InsightTxn? best;
      Duration? bestGap;
      for (final c in candidates) {
        if (used.contains(c.id)) continue;
        if (c.accountKey == d.accountKey) continue;
        final gap = c.bookedAt.difference(d.bookedAt).abs();
        if (gap > window) continue;
        if (bestGap == null || gap < bestGap) {
          best = c;
          bestGap = gap;
        }
      }
      if (best != null) {
        used.add(best.id);
        paired
          ..add(d.id)
          ..add(best.id);
      }
    }
    return paired;
  }

  static bool _eligible(InsightTxn t) {
    final slug = t.categorySlug;
    if (t.categorySource == 'user' &&
        slug != null &&
        slug != kSelfTransferSlug) {
      return false;
    }
    return slug == null ||
        slug == kUncategorizedSlug ||
        slug == kSelfTransferSlug ||
        slug == 'transfers_others';
  }
}

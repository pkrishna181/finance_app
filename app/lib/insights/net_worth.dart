import 'dart:math' as math;

/// Manual asset kinds, with display names. `loan` is a liability.
const kAssetKinds = <String, String>{
  'gold': 'Gold',
  'fd': 'Fixed deposit',
  'ppf': 'PPF',
  'epf': 'EPF',
  'nps': 'NPS',
  'property': 'Property',
  'vehicle': 'Vehicle',
  'cash': 'Cash at home',
  'other': 'Other asset',
  'loan': 'Loan (owed)',
};

bool isLiabilityKind(String kind) => kind == 'loan';

enum NetWorthGroup { bank, investments, assets, cards, loans }

extension NetWorthGroupLabel on NetWorthGroup {
  String get label => switch (this) {
    NetWorthGroup.bank => 'Bank accounts',
    NetWorthGroup.investments => 'Investments',
    NetWorthGroup.assets => 'Other assets',
    NetWorthGroup.cards => 'Credit cards',
    NetWorthGroup.loans => 'Loans',
  };

  bool get isLiability =>
      this == NetWorthGroup.cards || this == NetWorthGroup.loans;
}

class NetWorthItem {
  const NetWorthItem({
    required this.group,
    required this.label,
    required this.valuePaise,
    this.asOf,
    this.assetId,
  });

  final NetWorthGroup group;
  final String label;

  /// Positive; liabilities are subtracted by [group].
  final int valuePaise;

  /// Date the value is from (e.g. last statement balance).
  final DateTime? asOf;

  /// Set for manual assets / loans (editable).
  final int? assetId;

  int get signedPaise => group.isLiability ? -valuePaise : valuePaise;
}

class NetWorth {
  const NetWorth(this.items);

  final List<NetWorthItem> items;

  int get totalPaise => items.fold(0, (s, i) => s + i.signedPaise);
  int get assetsPaise => items
      .where((i) => !i.group.isLiability)
      .fold(0, (s, i) => s + i.valuePaise);
  int get liabilitiesPaise => items
      .where((i) => i.group.isLiability)
      .fold(0, (s, i) => s + i.valuePaise);

  /// Group → total (positive), in [NetWorthGroup] order, empty groups omitted.
  Map<NetWorthGroup, int> get byGroup {
    final m = <NetWorthGroup, int>{};
    for (final g in NetWorthGroup.values) {
      final v = items
          .where((i) => i.group == g)
          .fold<int>(0, (s, i) => s + i.valuePaise);
      if (v != 0) m[g] = v;
    }
    return m;
  }

  bool get isEmpty => items.isEmpty;
}

class NetWorthPoint {
  const NetWorthPoint(this.date, this.paise);
  final DateTime date;
  final int paise;
}

/// Value of an FD recorded as [principalPaise] on [from], at [rateBp] a
/// year compounded quarterly, on [on] (capped at [maturity]).
int fdValue(
  int principalPaise,
  int rateBp,
  DateTime from,
  DateTime on, {
  DateTime? maturity,
}) {
  final end = maturity != null && on.isAfter(maturity) ? maturity : on;
  final days = end.difference(from).inDays;
  if (days <= 0 || rateBp <= 0) return principalPaise;
  final years = days / 365.0;
  final r = rateBp / 10000;
  return (principalPaise * math.pow(1 + r / 4, 4 * years)).round();
}

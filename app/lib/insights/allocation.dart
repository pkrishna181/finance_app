import 'capital_gains.dart' show TaxCategory;

enum AssetClass { equity, debt, gold, cash, realEstate, other }

extension AssetClassLabel on AssetClass {
  String get label => switch (this) {
    AssetClass.equity => 'Equity',
    AssetClass.debt => 'Debt',
    AssetClass.gold => 'Gold',
    AssetClass.cash => 'Cash',
    AssetClass.realEstate => 'Real estate',
    AssetClass.other => 'Other',
  };
}

/// Asset class of a fund / share from its name and tax category.
AssetClass assetClassOfSecurity(String name, String kind, TaxCategory tax) {
  if (kind == 'equity') return AssetClass.equity;
  final n = name.toLowerCase();
  if (RegExp(r'\bgold\b|\bsilver\b').hasMatch(n)) return AssetClass.gold;
  return switch (tax) {
    TaxCategory.equity => AssetClass.equity,
    TaxCategory.debt => AssetClass.debt,
    // International / overseas equity is taxed as "other" but is equity.
    TaxCategory.other =>
      RegExp(
            r'international|global|overseas|nasdaq|'
            r's&p|\bus\b|world|emerging|china|japan|europe',
          ).hasMatch(n)
          ? AssetClass.equity
          : AssetClass.other,
  };
}

/// Asset class of a manual asset kind; null = not counted (vehicles, loans).
AssetClass? assetClassOfManual(String kind) => switch (kind) {
  'gold' => AssetClass.gold,
  'fd' || 'ppf' || 'epf' => AssetClass.debt,
  'property' => AssetClass.realEstate,
  'cash' => AssetClass.cash,
  'nps' || 'other' => AssetClass.other,
  _ => null,
};

class AllocationRow {
  const AllocationRow({
    required this.assetClass,
    required this.valuePaise,
    this.targetBp,
    this.plannedTotalPaise = 0,
  });

  final AssetClass assetClass;
  final int valuePaise;

  /// Null when the class isn't part of the plan.
  final int? targetBp;

  /// Total value of all planned classes.
  final int plannedTotalPaise;

  bool get inPlan => targetBp != null;

  double get currentFraction =>
      plannedTotalPaise <= 0 ? 0 : valuePaise / plannedTotalPaise;

  double? get targetFraction => targetBp == null ? null : targetBp! / 10000;

  /// Current − target, in percentage points (planned classes only).
  double? get driftPoints =>
      targetFraction == null ? null : (currentFraction - targetFraction!) * 100;

  /// + = buy this much, − = trim this much, to hit the target.
  int? get rebalancePaise => targetBp == null
      ? null
      : (plannedTotalPaise * targetBp! / 10000).round() - valuePaise;
}

class Allocation {
  const Allocation(this.rows);

  /// Every class with value or a target, in [AssetClass] order.
  final List<AllocationRow> rows;

  bool get hasPlan => rows.any((r) => r.inPlan);

  int get plannedTotalPaise => rows.isEmpty ? 0 : rows.first.plannedTotalPaise;

  /// Biggest absolute drift among planned classes.
  double get maxDriftPoints => rows
      .where((r) => r.inPlan)
      .fold(0.0, (m, r) => r.driftPoints!.abs() > m ? r.driftPoints!.abs() : m);

  /// Rebalancing is suggested past this drift.
  static const driftThresholdPoints = 5.0;

  bool get needsRebalance => hasPlan && maxDriftPoints >= driftThresholdPoints;

  static Allocation build(
    Map<AssetClass, int> values,
    Map<AssetClass, int> targetsBp,
  ) {
    final planned = targetsBp.keys.fold<int>(0, (s, c) => s + (values[c] ?? 0));
    return Allocation([
      for (final c in AssetClass.values)
        if ((values[c] ?? 0) > 0 || targetsBp.containsKey(c))
          AllocationRow(
            assetClass: c,
            valuePaise: values[c] ?? 0,
            targetBp: targetsBp[c],
            plannedTotalPaise: planned,
          ),
    ]);
  }
}

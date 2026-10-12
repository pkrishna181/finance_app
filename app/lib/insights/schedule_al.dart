/// Sections of ITR Schedule AL (assets and liabilities at the end of the
/// year). Required when total income exceeds ₹1 crore (from AY 2025-26;
/// ₹50 lakh earlier). Reported at cost.
enum AlSection {
  immovable,
  jewellery,
  vehicles,
  bank,
  securities,
  insurance,
  loansGiven,
  cash,
  liabilities,
  unmapped,
}

extension AlSectionLabel on AlSection {
  String get code => switch (this) {
        AlSection.immovable => 'A',
        AlSection.jewellery => 'B(1)(i)',
        AlSection.vehicles => 'B(1)(iii)',
        AlSection.bank => 'B(1)(iv)(a)',
        AlSection.securities => 'B(1)(iv)(b)',
        AlSection.insurance => 'B(1)(iv)(c)',
        AlSection.loansGiven => 'B(1)(iv)(d)',
        AlSection.cash => 'B(1)(iv)(e)',
        AlSection.liabilities => 'D',
        AlSection.unmapped => '—',
      };

  String get label => switch (this) {
        AlSection.immovable => 'Immovable assets (land, buildings)',
        AlSection.jewellery => 'Jewellery, bullion',
        AlSection.vehicles => 'Vehicles',
        AlSection.bank => 'Bank balances and deposits',
        AlSection.securities => 'Shares and securities',
        AlSection.insurance => 'Insurance policies',
        AlSection.loansGiven => 'Loans and advances given',
        AlSection.cash => 'Cash in hand',
        AlSection.liabilities => 'Liabilities',
        AlSection.unmapped => 'Not classified — decide where these go',
      };
}

class AlItem {
  const AlItem({
    required this.section,
    required this.label,
    required this.amountPaise,
    this.atCost = true,
  });

  final AlSection section;
  final String label;
  final int amountPaise;

  /// False when only a market value / entered value was available.
  final bool atCost;
}

class ScheduleAl {
  const ScheduleAl({required this.asOf, required this.items});

  /// 31 March of the financial year.
  final DateTime asOf;
  final List<AlItem> items;

  static const thresholdPaise = 1000000000; // ₹1 crore

  Map<AlSection, int> get totals {
    final m = <AlSection, int>{};
    for (final i in items) {
      m[i.section] = (m[i.section] ?? 0) + i.amountPaise;
    }
    return m;
  }

  int get assetsPaise => items
      .where((i) =>
          i.section != AlSection.liabilities &&
          i.section != AlSection.unmapped)
      .fold(0, (s, i) => s + i.amountPaise);

  int get liabilitiesPaise => totals[AlSection.liabilities] ?? 0;

  bool get hasValuesNotAtCost => items.any((i) => !i.atCost);
}

/// Manual asset kind → section (null = vehicles etc. handled separately).
AlSection alSectionOfManual(String kind) => switch (kind) {
      'property' => AlSection.immovable,
      'gold' => AlSection.jewellery,
      'vehicle' => AlSection.vehicles,
      'fd' || 'ppf' || 'epf' => AlSection.bank,
      'nps' => AlSection.securities,
      'cash' => AlSection.cash,
      'loan' => AlSection.liabilities,
      _ => AlSection.unmapped,
    };

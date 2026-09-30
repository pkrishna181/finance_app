import '../core/models/money.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String monthShort(int month) => _monthNames[month - 1];

/// "Jul 2026"
String monthLabel(int year, int month) => '${monthShort(month)} $year';

/// Full amount, Indian grouping, no paise: ₹1,25,000
String inrWhole(int paise) {
  final s = MoneyPaise(paise.abs() ~/ 100 * 100).formatInr();
  final trimmed = s.substring(0, s.length - 3); // drop ".00"
  return paise < 0 ? '-$trimmed' : trimmed;
}

/// Chart-axis style: 950 → ₹950, 12,500 → ₹12.5k, 1,50,000 → ₹1.5L.
String inrCompact(int paise) {
  final rupees = paise.abs() / 100;
  final sign = paise < 0 ? '-' : '';
  String fmt(double v) {
    final t = v.toStringAsFixed(1);
    return t.endsWith('.0') ? t.substring(0, t.length - 2) : t;
  }

  if (rupees >= 10000000) return '$sign₹${fmt(rupees / 10000000)}Cr';
  if (rupees >= 100000) return '$sign₹${fmt(rupees / 100000)}L';
  if (rupees >= 1000) return '$sign₹${fmt(rupees / 1000)}k';
  return '$sign₹${rupees.round()}';
}

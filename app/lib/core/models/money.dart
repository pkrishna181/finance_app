/// Amount in paise (1 INR = 100 paise). INR only for v1.
extension type const MoneyPaise(int paise) implements int {
  factory MoneyPaise.fromRupees(num rupees) =>
      MoneyPaise((rupees * 100).round());

  double get asRupees => paise / 100.0;

  /// Indian grouping: 1,00,000.50
  String formatInr({bool includeSymbol = true}) {
    final negative = paise < 0;
    final abs = paise.abs();
    final whole = abs ~/ 100;
    final frac = abs % 100;
    final grouped = _indianGroup(whole);
    final body = '$grouped.${frac.toString().padLeft(2, '0')}';
    final signed = negative ? '-$body' : body;
    return includeSymbol ? '₹$signed' : signed;
  }

  static String _indianGroup(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}

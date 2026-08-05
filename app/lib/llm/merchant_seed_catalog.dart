import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class MerchantSeedEntry {
  const MerchantSeedEntry({required this.canonical, required this.aliases});
  final String canonical;
  final List<String> aliases;
}

/// ~200 common Indian merchant brands (editable asset).
class MerchantSeedCatalog {
  MerchantSeedCatalog(this.entries);

  final List<MerchantSeedEntry> entries;

  static MerchantSeedCatalog? _cached;

  static Future<MerchantSeedCatalog> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('lib/llm/data/merchant_seeds.json');
    final list = jsonDecode(raw) as List<Object?>;
    final entries = list.map((e) {
      final map = Map<String, Object?>.from(e as Map);
      return MerchantSeedEntry(
        canonical: map['canonical'] as String,
        aliases: (map['aliases'] as List<Object?>).cast<String>(),
      );
    }).toList();
    _cached = MerchantSeedCatalog(entries);
    return _cached!;
  }

  String? matchCanonical(String raw) {
    final norm = raw.trim().toLowerCase();
    if (norm.isEmpty) return null;
    for (final entry in entries) {
      if (entry.canonical.toLowerCase() == norm) return entry.canonical;
      for (final alias in entry.aliases) {
        if (norm.contains(alias.toLowerCase()) || alias.toLowerCase().contains(norm)) {
          return entry.canonical;
        }
      }
    }
    return null;
  }

  bool isKnownBrand(String name) {
    final norm = name.trim().toLowerCase();
    for (final entry in entries) {
      if (entry.canonical.toLowerCase() == norm) return true;
      for (final alias in entry.aliases) {
        if (alias.toLowerCase() == norm) return true;
      }
    }
    return false;
  }
}

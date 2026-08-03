/// Indian DLT sender ID normalization and bank entity mapping.
///
/// Formats: `XX-ENTITY`, `XX-ENTITY-C` where trailing letter is category:
/// T=transactional, S=service, P=promotional (non-transactional).
class SenderMatch {
  const SenderMatch({
    required this.raw,
    required this.entity,
    required this.category,
    required this.bankCode,
    required this.isTransactional,
  });

  final String raw;

  /// Uppercase entity token, e.g. HDFCBK, SBIUPI.
  final String entity;

  /// T / S / P / null when absent.
  final String? category;

  /// Mapped bank code (HDFC, SBI, …) or `UNKNOWN`.
  final String bankCode;

  final bool isTransactional;
}

const _entityToBank = <String, String>{
  'HDFCBK': 'HDFC',
  'HDFC': 'HDFC',
  'HDFCBN': 'HDFC',
  'SBIINB': 'SBI',
  'SBIUPI': 'SBI',
  'SBICRD': 'SBI',
  'SBI': 'SBI',
  'ICICIB': 'ICICI',
  'ICICI': 'ICICI',
  'AXISBK': 'AXIS',
  'AXISB': 'AXIS',
  'AXISBN': 'AXIS',
  'KOTAKB': 'KOTAK',
  'KOTAK': 'KOTAK',
  'PAYTMB': 'PAYTM',
  'PAYTM': 'PAYTM',
  'PYTMPB': 'PAYTM',
  'IPBKL': 'PAYTM', // Paytm Payments Bank legacy
};

/// Entity tokens used for native SMS ContentProvider LIKE filters.
List<String> get knownSenderEntities =>
    _entityToBank.keys.toList(growable: false);

/// Normalize a DLT / bank SMS sender address into a [SenderMatch].
SenderMatch matchSender(String? sender) {
  if (sender == null || sender.trim().isEmpty) {
    return const SenderMatch(
      raw: '',
      entity: '',
      category: null,
      bankCode: 'UNKNOWN',
      isTransactional: true,
    );
  }

  final raw = sender.trim().toUpperCase();
  // Strip leading VM-/JD-/AD-/BX- style prefixes if present as XX-ENTITY-C
  final dlt = RegExp(r'^([A-Z]{2})-([A-Z0-9]+)(?:-([A-Z]))?$').firstMatch(raw);
  if (dlt != null) {
    final entity = dlt.group(2)!;
    final category = dlt.group(3);
    final bank = _mapEntity(entity);
    final transactional = category != 'P';
    return SenderMatch(
      raw: raw,
      entity: entity,
      category: category,
      bankCode: bank,
      isTransactional: transactional,
    );
  }

  // Bare entity or phone-like: try contains / equals known tokens
  for (final entry in _entityToBank.entries) {
    if (raw == entry.key || raw.contains(entry.key)) {
      return SenderMatch(
        raw: raw,
        entity: entry.key,
        category: null,
        bankCode: entry.value,
        isTransactional: true,
      );
    }
  }

  return SenderMatch(
    raw: raw,
    entity: raw,
    category: null,
    bankCode: 'UNKNOWN',
    isTransactional: true,
  );
}

String _mapEntity(String entity) {
  final direct = _entityToBank[entity];
  if (direct != null) return direct;
  // Prefix match: HDFCBKxxx
  for (final entry in _entityToBank.entries) {
    if (entity.startsWith(entry.key) || entry.key.startsWith(entity)) {
      return entry.value;
    }
  }
  return 'UNKNOWN';
}

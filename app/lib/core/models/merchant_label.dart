/// Normalized merchant text for grouping and merchant-wide category rules:
/// lowercase, digits and punctuation stripped, whitespace collapsed.
String normalizeMerchantLabel(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[0-9]+'), ' ')
    .replaceAll(RegExp(r'[^a-z ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

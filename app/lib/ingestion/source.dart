import '../core/result/result.dart';

/// First-class ingestion asymmetry: not every source exists on every OS.
enum SourceAvailability {
  /// Fully supported on this platform (e.g. SMS on Android).
  available,

  /// Conceptually supported by the product, but not on this OS (SMS on iOS).
  unsupportedOnPlatform,

  /// Not yet implemented.
  notImplemented,
}

/// Capability descriptor for a pluggable data source.
abstract class IngestionSource {
  String get id;
  String get displayName;
  SourceAvailability get availability;

  /// Whether the user has granted any required OS permission.
  Future<bool> hasPermission();

  /// Request permission / show consent UI prerequisites.
  Future<Result<void>> requestPermission();
}

/// Envelope for raw payloads pulled from a source before parsing.
class RawIngestBatch {
  const RawIngestBatch({
    required this.sourceId,
    required this.items,
    required this.contentHash,
    this.label,
  });

  final String sourceId;
  final String? label;
  final List<RawIngestItem> items;

  /// Hash of the batch payload for import-level idempotency.
  final String contentHash;
}

class RawIngestItem {
  const RawIngestItem({
    required this.payload,
    this.sender,
    this.receivedAt,
    this.metadata = const {},
  });

  /// SMS body, CSV row blob, PDF text layer, etc.
  final String payload;
  final String? sender;
  final DateTime? receivedAt;
  final Map<String, String> metadata;
}

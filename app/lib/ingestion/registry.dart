import 'sms/sms_source.dart';
import 'source.dart';
import 'statement/file_source.dart';

/// Registry used by the UI to list what the user can import on this device.
class IngestionRegistry {
  IngestionRegistry({List<IngestionSource>? sources})
      : sources = sources ??
            [
              SmsIngestionSource(),
              StatementFileSource(),
            ];

  final List<IngestionSource> sources;

  List<IngestionSource> get actionable => sources
      .where((s) => s.availability == SourceAvailability.available)
      .toList(growable: false);
}

import '../core/models/parsed_transaction.dart';
import '../core/result/result.dart';

/// Parses a single SMS body into zero or more transactions.
abstract class SmsParser {
  String get id;

  /// Returns Ok(empty) when the message is non-transactional.
  /// Returns Err when the message looks transactional but could not be parsed.
  Result<List<ParsedTransaction>> parse({
    required String body,
    String? sender,
    DateTime? receivedAt,
  });
}

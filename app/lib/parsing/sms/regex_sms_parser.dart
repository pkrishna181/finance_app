import '../../core/models/parsed_transaction.dart';
import '../../core/models/sms_parse_models.dart';
import '../../core/result/result.dart';
import '../sms_parser.dart';
import 'cascade.dart';

/// Production regex-based SMS parser (Phase 1).
class RegexSmsParser implements SmsParser {
  RegexSmsParser({SmsParseCascade? cascade})
      : _cascade = cascade ?? SmsParseCascade();

  final SmsParseCascade _cascade;

  @override
  String get id => 'regex';

  /// Full cascade result including mandates / skips / unparsed.
  Result<SmsParseSuccess> parseDetailed({
    required String body,
    String? sender,
    DateTime? receivedAt,
  }) {
    return _cascade.run(body: body, sender: sender, receivedAt: receivedAt);
  }

  @override
  Result<List<ParsedTransaction>> parse({
    required String body,
    String? sender,
    DateTime? receivedAt,
  }) {
    final result = parseDetailed(
      body: body,
      sender: sender,
      receivedAt: receivedAt,
    );
    return result.when(
      ok: (success) => Ok(success.transactions),
      err: (message, cause) => Err(message, cause),
    );
  }
}

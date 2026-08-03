import 'package:flutter/services.dart';

import '../../parsing/sms/sender_matcher.dart';

/// One SMS row from the native ContentProvider query.
class NativeSmsMessage {
  const NativeSmsMessage({
    required this.sender,
    required this.body,
    required this.dateMillis,
  });

  final String? sender;
  final String body;
  final int? dateMillis;

  factory NativeSmsMessage.fromMap(Map<dynamic, dynamic> map) {
    return NativeSmsMessage(
      sender: map['sender'] as String?,
      body: (map['body'] as String?) ?? '',
      dateMillis: (map['date_millis'] as num?)?.toInt(),
    );
  }
}

/// Dart side of `com.arth.arth/sms_inbox` (Kotlin ContentProvider reader).
class NativeSmsInbox {
  NativeSmsInbox({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.arth.arth/sms_inbox');

  final MethodChannel _channel;

  /// Paginated inbox query. [entities] are DLT entity tokens (HDFCBK, …)
  /// applied as SQL LIKE filters at the provider level.
  Future<List<NativeSmsMessage>> queryPage({
    required int limit,
    required int offset,
    List<String>? entities,
  }) async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'querySmsPage',
      <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'entities': entities ?? knownSenderEntities,
      },
    );
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((m) => NativeSmsMessage.fromMap(Map<dynamic, dynamic>.from(m)))
        .where((m) => m.body.isNotEmpty)
        .toList(growable: false);
  }
}

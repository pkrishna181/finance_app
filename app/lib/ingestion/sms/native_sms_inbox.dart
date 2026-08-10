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

  /// Paginated inbox query (date DESC). Pass [beforeDateMillis] to continue
  /// older than a checkpoint (exclusive upper bound on DATE).
  Future<List<NativeSmsMessage>> queryPage({
    required int limit,
    int? beforeDateMillis,
    List<String>? entities,
  }) async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'querySmsPage',
      <String, dynamic>{
        'limit': limit,
        if (beforeDateMillis != null) 'before_date_millis': beforeDateMillis,
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

  /// Approximate inbox rows matching sender entity filters (for progress UI).
  Future<int> countMessages({List<String>? entities}) async {
    final count = await _channel.invokeMethod<int>(
      'countSms',
      <String, dynamic>{
        'entities': entities ?? knownSenderEntities,
      },
    );
    return count ?? 0;
  }
}

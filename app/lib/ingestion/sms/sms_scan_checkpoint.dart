import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persisted SMS historical scan checkpoint (resume after cancel / background).
class SmsScanCheckpoint {
  const SmsScanCheckpoint({
    required this.lastProcessedDateMillis,
    required this.scanned,
    required this.parsed,
    required this.inserted,
    required this.unparsed,
    required this.skipped,
    required this.mandates,
    this.importId,
    this.estimatedTotal,
  });

  /// Oldest [date_millis] fully committed; resume queries strictly older rows.
  final int lastProcessedDateMillis;
  final int scanned;
  final int parsed;
  final int inserted;
  final int unparsed;
  final int skipped;
  final int mandates;
  final int? importId;
  final int? estimatedTotal;

  Map<String, Object?> toJson() => {
        'last_processed_date_millis': lastProcessedDateMillis,
        'scanned': scanned,
        'parsed': parsed,
        'inserted': inserted,
        'unparsed': unparsed,
        'skipped': skipped,
        'mandates': mandates,
        if (importId != null) 'import_id': importId,
        if (estimatedTotal != null) 'estimated_total': estimatedTotal,
      };

  factory SmsScanCheckpoint.fromJson(Map<String, Object?> json) {
    return SmsScanCheckpoint(
      lastProcessedDateMillis: json['last_processed_date_millis'] as int,
      scanned: json['scanned'] as int? ?? 0,
      parsed: json['parsed'] as int? ?? 0,
      inserted: json['inserted'] as int? ?? 0,
      unparsed: json['unparsed'] as int? ?? 0,
      skipped: json['skipped'] as int? ?? 0,
      mandates: json['mandates'] as int? ?? 0,
      importId: json['import_id'] as int?,
      estimatedTotal: json['estimated_total'] as int?,
    );
  }
}

/// Local checkpoint store for cooperative resume.
class SmsScanCheckpointStore {
  SmsScanCheckpointStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const _key = 'arth_sms_scan_checkpoint_v1';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<SmsScanCheckpoint?> load() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SmsScanCheckpoint.fromJson(Map<String, Object?>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(SmsScanCheckpoint checkpoint) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(_key, jsonEncode(checkpoint.toJson()));
  }

  Future<void> clear() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_key);
  }

  Future<bool> hasCheckpoint() async => await load() != null;
}

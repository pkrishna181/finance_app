import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Generates and persists the SQLite encryption passphrase.
///
/// Key material lives only in platform secure storage (Android Keystore /
/// iOS Keychain via flutter_secure_storage). Never logged or synced.
class DbKeyStore {
  DbKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'arth_db_encryption_key_v1';

  final FlutterSecureStorage _storage;

  /// Returns the existing key or creates a new 256-bit random passphrase.
  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final key = _generateKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  /// Test / reset helper — not used in production flows.
  Future<void> clear() => _storage.delete(key: _keyName);

  static String _generateKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }
}

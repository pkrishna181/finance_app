import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-lock preferences (no secrets: only on/off and timing).
class AppLockSettings {
  static const _enabledKey = 'app_lock_enabled_v1';
  static const _timeoutKey = 'app_lock_timeout_s_v1';
  static const _secureKey = 'app_lock_secure_window_v1';

  /// Lock again after this long in the background.
  static const timeouts = <int, String>{
    0: 'Immediately',
    60: 'After 1 minute',
    300: 'After 5 minutes',
    1800: 'After 30 minutes',
  };

  Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;
  Future<void> setEnabled(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_enabledKey, v);

  Future<int> timeoutSeconds() async =>
      (await SharedPreferences.getInstance()).getInt(_timeoutKey) ?? 60;
  Future<void> setTimeoutSeconds(int s) async =>
      (await SharedPreferences.getInstance()).setInt(_timeoutKey, s);

  /// Hide contents in recent apps and block screenshots.
  Future<bool> secureWindow() async =>
      (await SharedPreferences.getInstance()).getBool(_secureKey) ?? false;
  Future<void> setSecureWindow(bool v) async {
    await (await SharedPreferences.getInstance()).setBool(_secureKey, v);
    await applySecureWindow(v);
  }

  static const _window = MethodChannel('com.arth.arth/window');

  /// Applies FLAG_SECURE on Android; no-op elsewhere / in tests.
  static Future<void> applySecureWindow(bool secure) async {
    try {
      await _window.invokeMethod<void>('setSecure', {'secure': secure});
    } on MissingPluginException {
      // Not Android, or a test binding.
    } on PlatformException {
      // Ignore: the setting is best effort.
    }
  }
}

/// Verifies the user with the phone's biometrics or screen lock.
abstract class Authenticator {
  /// Whether the device has a screen lock / biometrics to use.
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class DeviceAuthenticator implements Authenticator {
  DeviceAuthenticator([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      // biometricOnly: false → falls back to the phone's PIN / pattern.
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

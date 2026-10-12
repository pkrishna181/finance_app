import 'package:flutter/material.dart';

import '../../core/security/app_lock.dart';

/// Covers [child] with a lock screen at launch and when the app returns from
/// the background after the chosen timeout, until the user unlocks with
/// biometrics or the phone's screen lock.
class AppLockGate extends StatefulWidget {
  const AppLockGate({
    super.key,
    required this.child,
    this.settings,
    this.authenticator,
    this.clock,
    this.initiallyEnabled,
  });

  final Widget child;

  /// Lock setting read before the app started (see `main`), so the first
  /// frame is already correct: no flash of content, no blank frame.
  final bool? initiallyEnabled;
  final AppLockSettings? settings;
  final Authenticator? authenticator;

  /// Injectable clock (tests).
  final DateTime Function()? clock;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  late final _settings = widget.settings ?? AppLockSettings();
  late final _auth = widget.authenticator ?? DeviceAuthenticator();
  late bool? _locked = widget.initiallyEnabled; // null = deciding
  bool _authenticating = false;
  DateTime? _backgroundedAt;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    bool enabled;
    try {
      enabled = widget.initiallyEnabled ?? await _settings.isEnabled();
      await AppLockSettings.applySecureWindow(await _settings.secureWindow());
    } catch (_) {
      enabled = widget.initiallyEnabled ?? false;
    }
    if (!mounted) return;
    if (_locked != enabled) setState(() => _locked = enabled);
    if (enabled) await _unlock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system auth prompt itself pauses the app; ignore that.
    if (_authenticating) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= _now();
    } else if (state == AppLifecycleState.resumed) {
      _maybeRelock();
    }
  }

  Future<void> _maybeRelock() async {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || _locked == true) return;
    if (!await _settings.isEnabled()) return;
    final timeout = await _settings.timeoutSeconds();
    if (_now().difference(since).inSeconds >= timeout) {
      if (!mounted) return;
      setState(() => _locked = true);
      await _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final ok = await _auth.authenticate('Unlock Arth');
    _authenticating = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    final locked = _locked;
    return Stack(
      children: [
        // Keep the app alive underneath, but hidden while locked / deciding.
        Offstage(offstage: locked != false, child: widget.child),
        if (locked != false)
          Positioned.fill(
            child: _LockScreen(
              deciding: locked == null,
              onUnlock: _unlock,
            ),
          ),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.deciding, required this.onUnlock});
  final bool deciding;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: deciding
              ? const SizedBox.shrink()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    Text('Arth is locked', style: t.titleLarge),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onUnlock,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Unlock'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

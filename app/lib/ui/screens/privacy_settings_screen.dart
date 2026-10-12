import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ingestion/sms/consent_screen.dart';
import 'saved_passwords_screen.dart';
import '../../ingestion/investments/amfi_nav.dart';
import '../widgets/price_feed_opt_in.dart';
import '../../core/security/app_lock.dart';
import 'backup_screen.dart';
import 'ai_model_screen.dart';

/// Privacy controls: SMS consent revoke and permission shortcuts.
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({
    super.key,
    this.consentStore,
  });

  final SmsConsentStore? consentStore;

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late final SmsConsentStore _consent;
  bool _hasConsent = false;
  bool _smsGranted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _consent = widget.consentStore ?? SmsConsentStore();
    _refresh();
  }

  Future<void> _refresh() async {
    final consent = await _consent.hasConsent();
    final sms = Platform.isAndroid ? await Permission.sms.isGranted : false;
    if (!mounted) return;
    setState(() {
      _hasConsent = consent;
      _smsGranted = sms;
      _loading = false;
    });
  }

  Future<void> _revokeConsent() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke SMS consent?'),
        content: const Text(
          'Arth will stop reading transaction SMS. Existing imported '
          'transactions stay on your phone. You can still import statements.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _consent.revoke();
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SMS consent revoked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const ListTile(
                  title: Text('SMS access'),
                  subtitle: Text(
                    'Arth reads bank/UPI SMS only on this device. '
                    'Nothing is uploaded.',
                  ),
                ),
                ListTile(
                  title: const Text('In-app consent'),
                  subtitle: Text(_hasConsent ? 'Granted' : 'Not granted'),
                  trailing: _hasConsent
                      ? TextButton(
                          onPressed: _revokeConsent,
                          child: const Text('Revoke'),
                        )
                      : null,
                ),
                if (Platform.isAndroid)
                  ListTile(
                    title: const Text('READ_SMS permission'),
                    subtitle: Text(_smsGranted ? 'Granted' : 'Not granted'),
                    trailing: TextButton(
                      onPressed: openAppSettings,
                      child: const Text('System settings'),
                    ),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.memory_outlined),
                  title: const Text('On-device AI model'),
                  subtitle: const Text('Download, check or remove'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AiModelScreen(),
                    ),
                  ),
                ),
                const Divider(),
                const AppLockTiles(),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup & restore'),
                  subtitle: const Text('Encrypted with your passphrase'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BackupScreen(),
                    ),
                  ),
                ),
                const Divider(),
                const _PriceFeedTile(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('Statement passwords'),
                  subtitle: const Text(
                    'Saved in secure storage to unlock statement PDFs',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SavedPasswordsScreen(),
                    ),
                  ),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Data stays on-device'),
                  subtitle: Text(
                    'Ledger, SMS bodies, and LLM work never leave your phone. '
                    'Revoking consent does not delete existing data.',
                  ),
                ),
              ],
            ),
    );
  }
}

/// Opt-in for downloading AMFI's public NAV list.
class _PriceFeedTile extends StatefulWidget {
  const _PriceFeedTile();

  @override
  State<_PriceFeedTile> createState() => _PriceFeedTileState();
}

class _PriceFeedTileState extends State<_PriceFeedTile> {
  final _settings = PriceFeedSettings();
  bool? _enabled;
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _settings.isEnabled();
    final l = await _settings.lastUpdate();
    if (mounted) {
      setState(() {
        _enabled = e;
        _last = l;
      });
    }
  }

  Future<void> _toggle(bool on) async {
    if (on) {
      if (!await showPriceFeedOptIn(context, settings: _settings)) return;
    } else {
      await _settings.setEnabled(false);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = _last;
    return SwitchListTile(
      secondary: const Icon(Icons.cloud_download_outlined),
      value: _enabled ?? false,
      onChanged: _enabled == null ? null : _toggle,
      title: const Text('Update fund prices from AMFI'),
      subtitle: Text(
        'Downloads AMFI\'s public list of all fund NAVs; nothing about you is '
        'sent.${l == null ? '' : ' Last updated ${l.day}/${l.month}/${l.year}.'}',
      ),
    );
  }
}

/// App lock on/off, re-lock timeout, and hiding the app in recents.
class AppLockTiles extends StatefulWidget {
  const AppLockTiles({super.key, this.settings, this.authenticator});

  final AppLockSettings? settings;
  final Authenticator? authenticator;

  @override
  State<AppLockTiles> createState() => _AppLockTilesState();
}

class _AppLockTilesState extends State<AppLockTiles> {
  late final _settings = widget.settings ?? AppLockSettings();
  late final _auth = widget.authenticator ?? DeviceAuthenticator();
  bool? _enabled;
  int _timeout = 60;
  bool _secure = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _settings.isEnabled();
    final t = await _settings.timeoutSeconds();
    final s = await _settings.secureWindow();
    if (!mounted) return;
    setState(() {
      _enabled = e;
      _timeout = t;
      _secure = s;
    });
  }

  Future<void> _toggle(bool on) async {
    if (on) {
      if (!await _auth.isAvailable()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Set up a screen lock or fingerprint on your phone '
              'first.'),
        ));
        return;
      }
      // Prove it works before relying on it.
      if (!await _auth.authenticate('Confirm to turn on app lock')) return;
    }
    await _settings.setEnabled(on);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled ?? false;
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          value: enabled,
          onChanged: _enabled == null ? null : _toggle,
          title: const Text('App lock'),
          subtitle: const Text(
            'Unlock with fingerprint, face or your phone\'s PIN',
          ),
        ),
        if (enabled)
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Lock again'),
            trailing: DropdownButton<int>(
              value: _timeout,
              items: [
                for (final e in AppLockSettings.timeouts.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) async {
                if (v == null) return;
                await _settings.setTimeoutSeconds(v);
                await _load();
              },
            ),
          ),
        SwitchListTile(
          secondary: const Icon(Icons.visibility_off_outlined),
          value: _secure,
          onChanged: (v) async {
            await _settings.setSecureWindow(v);
            await _load();
          },
          title: const Text('Hide in recent apps'),
          subtitle: const Text(
            'Blanks Arth in the app switcher and blocks screenshots',
          ),
        ),
      ],
    );
  }
}


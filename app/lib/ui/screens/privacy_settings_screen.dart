import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ingestion/sms/consent_screen.dart';
import 'saved_passwords_screen.dart';
import '../../ingestion/investments/amfi_nav.dart';
import '../widgets/price_feed_opt_in.dart';

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


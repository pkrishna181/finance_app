import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ingestion/sms/consent_screen.dart';

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

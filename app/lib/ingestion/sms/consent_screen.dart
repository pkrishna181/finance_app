import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Plain-language SMS consent. Accept is explicit; revoke clears the flag
/// (settings can call [SmsConsentStore.revoke]).
class SmsConsentScreen extends StatelessWidget {
  const SmsConsentScreen({
    super.key,
    required this.onAccepted,
    this.onDeclined,
  });

  final VoidCallback onAccepted;
  final VoidCallback? onDeclined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS access')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Read transaction SMS on this phone',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Arth can read bank and UPI SMS already on your device to '
              'build your ledger. Messages are parsed entirely on this phone.\n\n'
              '• SMS content never leaves your device\n'
              '• We do not upload SMS to any server\n'
              '• You can revoke access anytime in Settings\n'
              '• Declining still lets you import PDF/CSV statements',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                await SmsConsentStore().accept();
                if (context.mounted) onAccepted();
              },
              child: const Text('Allow SMS reading'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onDeclined ?? () => Navigator.of(context).maybePop(),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}

class SmsConsentStore {
  SmsConsentStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'arth_sms_consent_v1';
  final FlutterSecureStorage _storage;

  Future<bool> hasConsent() async {
    final v = await _storage.read(key: _key);
    return v == 'true';
  }

  Future<void> accept() => _storage.write(key: _key, value: 'true');

  Future<void> revoke() => _storage.delete(key: _key);
}

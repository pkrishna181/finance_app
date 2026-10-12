import 'package:flutter/material.dart';

import '../../ingestion/statement/pdf/password_hints.dart';
import '../../ingestion/statement/pdf/password_vault.dart';

/// Asks for a statement PDF password, offering to remember it under a label
/// such as "Axis credit card". Returns null when the user skips.
Future<PasswordEntry?> showPdfPasswordDialog(
  BuildContext context, {
  required String fileName,
  int failedAsks = 0,
  int savedTried = 0,
}) {
  return showDialog<PasswordEntry>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PdfPasswordDialog(
      fileName: fileName,
      failedAsks: failedAsks,
      savedTried: savedTried,
    ),
  );
}

class _PdfPasswordDialog extends StatefulWidget {
  const _PdfPasswordDialog({
    required this.fileName,
    required this.failedAsks,
    required this.savedTried,
  });

  final String fileName;
  final int failedAsks;
  final int savedTried;

  @override
  State<_PdfPasswordDialog> createState() => _PdfPasswordDialogState();
}

class _PdfPasswordDialogState extends State<_PdfPasswordDialog> {
  final _password = TextEditingController();
  late final _label = TextEditingController(text: _defaultLabel());
  bool _remember = true;
  bool _obscure = true;

  String _defaultLabel() {
    final issuer = guessIssuer(widget.fileName);
    final words = widget.fileName
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .toSet();
    final kind =
        words.contains('card') ||
            words.contains('cc') ||
            words.contains('creditcard')
        ? 'credit card'
        : words.contains('cas') ||
              issuer == 'CAMS' ||
              issuer == 'KFINTECH' ||
              issuer == 'NSDL' ||
              issuer == 'CDSL'
        ? 'investments'
        : 'statements';
    return issuer == null ? '' : '$issuer $kind';
  }

  @override
  void dispose() {
    _password.dispose();
    _label.dispose();
    super.dispose();
  }

  void _submit() {
    final pw = _password.text;
    if (pw.isEmpty) return;
    final label = _label.text.trim();
    Navigator.of(context).pop(
      PasswordEntry(
        password: pw,
        remember: _remember,
        label: label.isEmpty ? widget.fileName : label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final hint = passwordHintForBank(guessIssuer(widget.fileName));
    return AlertDialog(
      title: const Text('Statement password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.fileName, style: t.titleSmall),
            const SizedBox(height: 8),
            if (widget.failedAsks > 0)
              Text(
                'That password didn\'t work. Try again.',
                style: t.bodyMedium?.copyWith(color: scheme.error),
              )
            else if (widget.savedTried > 0)
              Text(
                'None of your ${widget.savedTried} saved '
                'password${widget.savedTried == 1 ? '' : 's'} opened this file.',
                style: t.bodySmall,
              ),
            const SizedBox(height: 4),
            Text(hint, style: t.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _remember,
              onChanged: (v) => setState(() => _remember = v ?? false),
              title: const Text('Remember for future statements'),
              subtitle: const Text(
                'Kept in this phone\'s secure storage. Manage in Privacy.',
              ),
            ),
            if (_remember)
              TextField(
                controller: _label,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Axis credit card',
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Skip'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Unlock')),
      ],
    );
  }
}

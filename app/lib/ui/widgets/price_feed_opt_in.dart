import 'package:flutter/material.dart';

import '../../ingestion/investments/amfi_nav.dart';

/// Explains exactly what turning on fund-price updates downloads and asks
/// for consent. Returns true when the user turns it on.
Future<bool> showPriceFeedOptIn(
  BuildContext context, {
  PriceFeedSettings? settings,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Update fund prices?'),
      content: const SingleChildScrollView(
        child: Text(
          'Arth can download the latest NAV of every mutual fund from AMFI '
          '(portal.amfiindia.com) to value your holdings between statements.\n\n'
          '• It downloads one public file (about 1.5 MB) listing all '
          '~15,000 schemes — not just yours.\n'
          '• Nothing about you or your investments is sent: no account, '
          'no list of funds, no identifiers. Your holdings are matched on '
          'this phone.\n'
          '• It runs at most once a day, or when you tap Update.\n'
          '• Share prices are not downloaded; they update when you import '
          'a newer demat CAS.\n\n'
          'You can turn this off any time in Privacy.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Turn on'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await (settings ?? PriceFeedSettings()).setEnabled(true);
    return true;
  }
  return false;
}

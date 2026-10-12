import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme/arth_theme.dart';
import 'widgets/app_lock_gate.dart';

class ArthApp extends StatelessWidget {
  const ArthApp({super.key, this.lockEnabled = false});

  /// App-lock setting read in `main` before the first frame.
  final bool lockEnabled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arth',
      debugShowCheckedModeBanner: false,
      theme: ArthTheme.light(),
      home: AppLockGate(
        initiallyEnabled: lockEnabled,
        child: const HomeShell(),
      ),
    );
  }
}

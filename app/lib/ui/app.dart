import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme/arth_theme.dart';

class ArthApp extends StatelessWidget {
  const ArthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arth',
      debugShowCheckedModeBanner: false,
      theme: ArthTheme.light(),
      home: const HomeShell(),
    );
  }
}

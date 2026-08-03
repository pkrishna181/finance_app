import 'package:flutter/material.dart';

/// Minimal light theme — branding polish is a later phase.
class ArthTheme {
  static ThemeData light() {
    const seed = Color(0xFF0B6E4F);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}

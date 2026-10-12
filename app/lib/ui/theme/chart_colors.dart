import 'package:flutter/material.dart';

/// Categorical series colors (dataviz reference palette, slots 1–6), stepped
/// separately for light and dark surfaces. Validated as a set in both modes;
/// light slots 3–5 sit below 3:1 contrast, so charts using them must show
/// direct labels or a table. Assign in fixed order — never cycle: anything
/// past slot 6 folds into "Other" (neutral).
const _categoricalLight = <Color>[
  Color(0xFF2A78D6), // blue
  Color(0xFFEB6834), // orange
  Color(0xFF1BAF7A), // aqua
  Color(0xFFEDA100), // yellow
  Color(0xFFE87BA4), // magenta
  Color(0xFF008300), // green
];
const _categoricalDark = <Color>[
  Color(0xFF3987E5),
  Color(0xFFD95926),
  Color(0xFF199E70),
  Color(0xFFC98500),
  Color(0xFFD55181),
  Color(0xFF008300),
];

/// Number of categorical slots before folding into "Other".
const kCategoricalSlots = 6;

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Slot [index] (0-based), or the neutral "Other" color past the last slot.
Color categoricalColor(BuildContext context, int index) {
  if (index < 0 || index >= kCategoricalSlots) {
    return neutralSeriesColor(context);
  }
  return (_isDark(context) ? _categoricalDark : _categoricalLight)[index];
}

/// Gray used for "Other" / "Uncategorized".
Color neutralSeriesColor(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Single-hue (blue) sequential ramp for magnitude, low → high. In dark mode
/// low values recede toward the dark surface, so the ramp runs dark → light.
const _sequentialLight = <Color>[
  Color(0xFF9EC5F4), // 200
  Color(0xFF5598E7), // 350
  Color(0xFF256ABF), // 500
  Color(0xFF104281), // 650
];
const _sequentialDark = <Color>[
  Color(0xFF184F95), // 600
  Color(0xFF256ABF), // 500
  Color(0xFF5598E7), // 350
  Color(0xFF9EC5F4), // 200
];

/// Intensity [level] 0 (nothing) to [kSequentialLevels].
const kSequentialLevels = 4;

Color sequentialColor(BuildContext context, int level) {
  if (level <= 0) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }
  final ramp = _isDark(context) ? _sequentialDark : _sequentialLight;
  return ramp[(level - 1).clamp(0, ramp.length - 1)];
}

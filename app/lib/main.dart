import 'package:flutter/widgets.dart';

import 'core/security/app_lock.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read before the first frame so a locked app never shows its contents.
  var locked = false;
  try {
    locked = await AppLockSettings().isEnabled();
  } catch (_) {}
  runApp(ArthApp(lockEnabled: locked));
}

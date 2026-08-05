/// Injectable battery/charging guard for LLM batch runs.
abstract class BatteryGuard {
  Future<bool> mayRunLlmBatch();
}

/// Default: always allow (desktop/tests). Replace on Android/iOS in app bootstrap.
class PermissiveBatteryGuard implements BatteryGuard {
  @override
  Future<bool> mayRunLlmBatch() async => true;
}

/// Stops batch when battery < 20% and not charging.
class ThresholdBatteryGuard implements BatteryGuard {
  ThresholdBatteryGuard({
    required this.levelProvider,
    required this.chargingProvider,
    this.minPercent = 20,
  });

  final Future<int> Function() levelProvider;
  final Future<bool> Function() chargingProvider;
  final int minPercent;

  @override
  Future<bool> mayRunLlmBatch() async {
    final level = await levelProvider();
    if (level >= minPercent) return true;
    return chargingProvider();
  }
}

/// Cooperative cancellation token for an in-flight SMS scan.
class SmsScanSession {
  bool _cancelRequested = false;

  void requestCancel() => _cancelRequested = true;

  bool get isCancelled => _cancelRequested;
}

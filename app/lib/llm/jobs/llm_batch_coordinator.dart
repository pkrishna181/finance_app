import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/db/database.dart';
import '../llama_cpp_engine.dart';
import '../llm_engine.dart';
import '../model_download_manager.dart';
import 'battery_guard.dart';
import 'llm_job_runner.dart';

/// Opportunistic LLM batch runner while the app process is alive (Phase 5.5).
///
/// Debounces enqueue bursts, auto-loads a downloaded model, and resumes on
/// [onAppResumed]. WorkManager is a future step — not used here.
class LlmBatchCoordinator {
  LlmBatchCoordinator({
    LlmEngine? engine,
    ModelDownloadManager? downloader,
    BatteryGuard? batteryGuard,
    Future<String> Function(String path)? loadGrammar,
  })  : engine = engine ?? LlamaCppEngine(),
        _downloader = downloader ?? ModelDownloadManager(),
        _batteryGuard = batteryGuard ?? PermissiveBatteryGuard(),
        _loadGrammar = loadGrammar;

  final LlmEngine engine;
  final ModelDownloadManager _downloader;
  final BatteryGuard _batteryGuard;
  final Future<String> Function(String path)? _loadGrammar;

  final _stateCtrl = StreamController<LlmBatchState>.broadcast();
  Stream<LlmBatchState> get states => _stateCtrl.stream;

  LlmBatchState _state = const LlmBatchState.idle();
  LlmBatchState get state => _state;

  Timer? _debounce;
  ArthDatabase? _scheduledDb;
  bool _inFlight = false;

  void scheduleRun(ArthDatabase db) {
    _scheduledDb = db;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final target = _scheduledDb;
      if (target != null) unawaited(runNow(target));
    });
  }

  Future<void> onAppResumed(ArthDatabase db) async {
    await db.recoverStaleRunningLlmJobs();
    scheduleRun(db);
  }

  Future<void> runNow(ArthDatabase db) async {
    if (_inFlight) return;
    _inFlight = true;
    _emit(const LlmBatchState.running());

    try {
      await db.recoverStaleRunningLlmJobs();
      final pending = await db.countPendingLlmJobs();
      if (pending == 0) {
        _emit(const LlmBatchState.idle());
        return;
      }

      if (!engine.isReady) {
        if (!await _downloader.isDownloaded()) {
          _emit(const LlmBatchState.idle(skipped: 'model_not_downloaded'));
          return;
        }
        final file = await _downloader.modelFilePath();
        final load = await engine.load(modelPath: file.path);
        if (load.isErr) {
          _emit(const LlmBatchState.idle(skipped: 'engine_load_failed'));
          return;
        }
      }

      final runner = LlmJobRunner(
        db: db,
        engine: engine,
        batteryGuard: _batteryGuard,
        loadGrammar: _loadGrammar ?? rootBundle.loadString,
      );
      final report = await runner.runPendingBatch();
      _emit(LlmBatchState.idle(report: report));

      final remaining = await db.countPendingLlmJobs();
      if (remaining > 0 && report.skipped != 'battery_guard') {
        scheduleRun(db);
      }
    } finally {
      _inFlight = false;
    }
  }

  void _emit(LlmBatchState next) {
    _state = next;
    if (!_stateCtrl.isClosed) _stateCtrl.add(next);
  }

  void dispose() {
    _debounce?.cancel();
    _stateCtrl.close();
  }
}

class LlmBatchState {
  const LlmBatchState.idle({this.report, this.skipped}) : running = false;

  const LlmBatchState.running()
      : running = true,
        report = null,
        skipped = null;

  final bool running;
  final LlmBatchReport? report;
  final String? skipped;
}

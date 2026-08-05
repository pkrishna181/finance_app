import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../llm/llama_cpp_engine.dart';
import '../../llm/model_config.dart';
import '../../llm/model_download_manager.dart';
import 'llm_benchmark_screen.dart';

/// Model download + thread settings (debug).
class LlmDebugSettingsScreen extends StatefulWidget {
  const LlmDebugSettingsScreen({super.key, required this.engine});

  final LlamaCppEngine engine;

  @override
  State<LlmDebugSettingsScreen> createState() => _LlmDebugSettingsScreenState();
}

class _LlmDebugSettingsScreenState extends State<LlmDebugSettingsScreen> {
  static const _wifiOnlyKey = 'llm_wifi_only';
  final _downloader = ModelDownloadManager();
  ModelDownloadProgress? _progress;
  String? _status;
  bool _wifiOnly = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _downloader.progress.listen((p) {
      if (mounted) setState(() => _progress = p);
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _wifiOnly = prefs.getBool(_wifiOnlyKey) ?? true);
  }

  Future<void> _saveWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wifiOnlyKey, value);
    setState(() => _wifiOnly = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LLM (debug)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${ModelConfig.defaultGemma3_1b.name} ${ModelConfig.defaultGemma3_1b.quant}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Download over Wi‑Fi only'),
            value: _wifiOnly,
            onChanged: _saveWifiOnly,
          ),
          if (_progress != null)
            LinearProgressIndicator(
              value: _progress!.fraction,
            ),
          if (_status != null) Text(_status!),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _download,
            child: const Text('Download / verify model'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loadModel,
            child: const Text('Load model'),
          ),
          if (llmDebugRoutesEnabled) ...[
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Open benchmark'),
              trailing: const Icon(Icons.speed),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LlmBenchmarkScreen(engine: widget.engine),
                ),
              ),
            ),
          ],
          const Divider(),
          ListTile(
            title: const Text('n_threads'),
            subtitle: Text('${widget.engine.nThreads} (performance cores, cap 4)'),
          ),
          ListTile(
            title: const Text('Native library'),
            subtitle: Text(
              widget.engine.isNativeAvailable
                  ? 'available'
                  : 'not loaded${widget.engine.nativeLoadError != null ? ': ${widget.engine.nativeLoadError}' : ''}',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download() async {
    setState(() => _status = 'Downloading…');
    final mgr = ModelDownloadManager(wifiOnly: _wifiOnly);
    final result = await mgr.download();
    setState(() {
      _status = result.isOk
          ? 'Downloaded: ${result.okOrNull!.path}'
          : 'Error: ${result.errorOrNull}';
    });
  }

  Future<void> _loadModel() async {
    final file = await _downloader.modelFilePath();
    if (!file.existsSync()) {
      setState(() => _status = 'Model file missing — download first.');
      return;
    }
    final sizeMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
    setState(() => _status = 'Loading ${sizeMb}MB model…');
    final r = await widget.engine.load(modelPath: file.path);
    setState(() {
      if (r.isOk) {
        _status = 'Model loaded ($sizeMb MB).';
      } else if (r.errorOrNull == 'native_library_unavailable') {
        final detail = (widget.engine.nativeLoadError ??
                r.when(ok: (_) => '', err: (_, cause) => cause?.toString() ?? '') ??
                '')
            .trim();
        _status = 'Load failed: native library unavailable.\n'
            '${detail.isNotEmpty ? 'Detail: $detail\n' : ''}'
            'Reinstall the latest APK (includes libarth_llm.so).\n'
            'If you built from source, run native/llama/build_android.sh first.';
      } else {
        _status = 'Load failed: ${r.errorOrNull}\n'
            'File: ${file.path}\n'
            'Size: ${sizeMb}MB\n'
            'Tip: Gemma 3 needs llama.cpp b4875+ (reinstall latest APK).';
      }
    });
  }
}

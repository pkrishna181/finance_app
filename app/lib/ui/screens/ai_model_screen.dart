import 'dart:async';

import 'package:flutter/material.dart';

import '../../llm/model_config.dart';
import '../../llm/model_download_manager.dart';

/// Download, check and remove the on-device AI model that reads messages
/// and statement rows the regular parsers can't.
class AiModelScreen extends StatefulWidget {
  const AiModelScreen({super.key, this.manager});

  /// Override for tests.
  final ModelDownloadManager? manager;

  @override
  State<AiModelScreen> createState() => _AiModelScreenState();
}

class _AiModelScreenState extends State<AiModelScreen> {
  late final _mgr = widget.manager ?? ModelDownloadManager();
  StreamSubscription<ModelDownloadProgress>? _sub;
  ModelDownloadProgress? _progress;
  bool? _installed;
  int _onDisk = 0;
  bool _downloading = false;
  String? _message;

  static String _mb(int bytes) => '${(bytes / (1024 * 1024)).round()} MB';

  @override
  void initState() {
    super.initState();
    _sub = _mgr.progress.listen((p) {
      if (mounted) setState(() => _progress = p);
    });
    _refresh();
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_downloading) _mgr.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final ok = await _mgr.isDownloaded();
    final bytes = await _mgr.bytesOnDisk();
    if (mounted) {
      setState(() {
        _installed = ok;
        _onDisk = bytes;
      });
    }
  }

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _message = null;
    });
    final r = await _mgr.download();
    if (!mounted) return;
    setState(() {
      _downloading = false;
      _message = r.isOk
          ? 'Downloaded and verified.'
          : switch (r.errorOrNull) {
              'download_cancelled' => 'Paused. Tap download to continue.',
              'checksum_mismatch' =>
                'The file didn\'t match the expected checksum and was '
                    'removed. Try again.',
              _ => 'Download failed — check your connection and try again. '
                  'It will continue where it stopped.\n'
                  '(${r.errorOrNull}${r.when(ok: (_) => '', err: (_, c) => c == null ? '' : ': ${c.toString().split('\n').first}')})',
            };
    });
    await _refresh();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove the AI model?'),
        content: const Text(
          'Frees the space. Messages and rows the regular parsers can\'t read '
          'will wait until you download it again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _mgr.delete();
    setState(() => _message = 'Removed.');
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const cfg = ModelConfig.defaultGemma3_1b;
    final size = _mgr.expectedBytes;
    final p = _progress;
    final installed = _installed;
    return Scaffold(
      appBar: AppBar(title: const Text('On-device AI model')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Arth reads most bank messages and statements with built-in rules. '
            'For the few it can\'t, a small AI model runs on this phone to '
            'suggest the details — you review every suggestion.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            '${cfg.name} (${cfg.quant})'
            '${size == null ? '' : ' · ${_mb(size)}'}',
            style: t.titleSmall,
          ),
          Text(
            'Downloaded once from huggingface.co and checked against a known '
            'fingerprint (SHA-256). Your data is never sent anywhere — the '
            'model only runs on the phone. Wi-Fi recommended.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 16),
          if (installed == null)
            const LinearProgressIndicator()
          else if (installed && !_downloading)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Installed and verified'),
              subtitle: Text(_mb(_onDisk)),
            )
          else ...[
            if (_downloading || _onDisk > 0) ...[
              LinearProgressIndicator(
                value: p?.fraction ??
                    (size == null || size == 0 ? null : _onDisk / size),
              ),
              const SizedBox(height: 4),
              Text(
                '${_mb(p?.bytesReceived ?? _onDisk)}'
                '${size == null ? '' : ' of ${_mb(size)}'}'
                '${_downloading && p != null && p.bytesReceived >= (size ?? 1 << 62) ? ' · verifying…' : ''}',
                style: t.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            if (_downloading)
              OutlinedButton.icon(
                onPressed: _mgr.cancel,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              )
            else
              FilledButton.icon(
                onPressed: _download,
                icon: const Icon(Icons.download),
                label: Text(_onDisk > 0 ? 'Continue download' : 'Download'),
              ),
          ],
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: t.bodyMedium),
          ],
          if (installed == true || (_onDisk > 0 && !_downloading)) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _downloading ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove model'),
            ),
          ],
        ],
      ),
    );
  }
}

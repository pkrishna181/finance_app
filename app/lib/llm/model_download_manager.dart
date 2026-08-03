import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/result/result.dart';
import 'model_config.dart';

typedef HttpClientFactory = HttpClient Function();

/// Resumable, sha256-verified GGUF download into app support dir.
class ModelDownloadManager {
  ModelDownloadManager({
    ModelConfig config = ModelConfig.defaultGemma3_1b,
    HttpClientFactory? httpClientFactory,
    Future<Directory> Function()? supportDir,
    this.wifiOnly = true,
    Future<bool> Function()? isOnWifi,
  })  : _config = config,
        _httpClientFactory = httpClientFactory ?? HttpClient.new,
        _supportDir = supportDir ?? getApplicationSupportDirectory,
        _isOnWifi = isOnWifi;

  final ModelConfig _config;
  final HttpClientFactory _httpClientFactory;
  final Future<Directory> Function() _supportDir;
  final bool wifiOnly;
  final Future<bool> Function()? _isOnWifi;

  final _progress = StreamController<ModelDownloadProgress>.broadcast();
  Stream<ModelDownloadProgress> get progress => _progress.stream;

  HttpClient? _client;
  bool _cancelled = false;

  Future<File> modelFilePath() async {
    final dir = await _modelsDir();
    return File(p.join(dir.path, _config.fileName));
  }

  Future<bool> isDownloaded() async {
    final file = await modelFilePath();
    if (!file.existsSync()) return false;
    return _verifyFile(file);
  }

  Future<Result<File>> download({bool force = false}) async {
    if (wifiOnly) {
      final onWifi = await (_isOnWifi?.call() ?? Future.value(true));
      if (!onWifi) {
        return const Err('wifi_required');
      }
    }

    final dest = await modelFilePath();
    if (!force && dest.existsSync() && await _verifyFile(dest)) {
      return Ok(dest);
    }

    final part = File('${dest.path}.part');
    _cancelled = false;
    _client = _httpClientFactory();
    try {
      var offset = 0;
      if (part.existsSync()) {
        offset = await part.length();
      }
      final sink = part.openWrite(mode: FileMode.append);

      while (!_cancelled) {
        final request = await _client!.getUrl(Uri.parse(_config.sourceUrl));
        if (offset > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
        }
        final response = await request.close();
        if (offset > 0 &&
            response.statusCode != HttpStatus.partialContent &&
            response.statusCode != HttpStatus.ok) {
          await sink.close();
          return Err('resume_failed', response.statusCode);
        }
        if (offset == 0 && response.statusCode != HttpStatus.ok) {
          await sink.close();
          return Err('download_failed', response.statusCode);
        }

        final total = _contentLength(response, offset);
        var received = offset;
        await for (final chunk in response) {
          if (_cancelled) break;
          sink.add(chunk);
          received += chunk.length;
          _progress.add(
            ModelDownloadProgress(
              bytesReceived: received,
              totalBytes: total,
            ),
          );
        }
        await sink.close();
        break;
      }

      if (_cancelled) {
        return const Err('download_cancelled');
      }

      if (part.existsSync()) {
        if (dest.existsSync()) await dest.delete();
        await part.rename(dest.path);
      }

      if (!await _verifyFile(dest)) {
        await dest.delete();
        return const Err('checksum_mismatch');
      }
      return Ok(dest);
    } catch (e) {
      return Err('download_error', e);
    } finally {
      _client?.close(force: true);
      _client = null;
    }
  }

  void cancel() {
    _cancelled = true;
    _client?.close(force: true);
  }

  Future<bool> _verifyFile(File file) async {
    if (_config.sha256.startsWith('00000000')) {
      return file.lengthSync() > 1024 * 1024;
    }
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString() == _config.sha256.toLowerCase();
  }

  int? _contentLength(HttpClientResponse response, int offset) {
    final raw = response.headers.value(HttpHeaders.contentLengthHeader);
    if (raw == null) return null;
    final len = int.tryParse(raw);
    if (len == null) return null;
    return offset > 0 ? offset + len : len;
  }

  Future<Directory> _modelsDir() async {
    final base = await _supportDir();
    final dir = Directory(p.join(base.path, 'models'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

class ModelDownloadProgress {
  const ModelDownloadProgress({
    required this.bytesReceived,
    this.totalBytes,
  });

  final int bytesReceived;
  final int? totalBytes;

  double? get fraction =>
      totalBytes == null || totalBytes == 0 ? null : bytesReceived / totalBytes!;
}

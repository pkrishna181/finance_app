import 'dart:async';
import 'dart:io';
import 'dart:isolate';

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

  /// True when the model file is present and was verified. The full
  /// SHA-256 runs once after download (marker file); later checks only
  /// compare size and marker, so this is cheap to call often.
  Future<bool> isDownloaded() async {
    final file = await modelFilePath();
    if (!file.existsSync()) return false;
    final size = _config.sizeBytes;
    if (size != null && file.lengthSync() != size) return false;
    final marker = File('${file.path}.verified');
    if (marker.existsSync() &&
        marker.readAsStringSync().trim() == _config.sha256.toLowerCase()) {
      return true;
    }
    return _verifyFile(file);
  }

  /// Bytes already downloaded (finished file or partial download).
  Future<int> bytesOnDisk() async {
    final file = await modelFilePath();
    if (file.existsSync()) return file.lengthSync();
    final part = File('${file.path}.part');
    return part.existsSync() ? part.lengthSync() : 0;
  }

  int? get expectedBytes => _config.sizeBytes;

  /// Removes the model, its marker and any partial download.
  Future<void> delete() async {
    final file = await modelFilePath();
    for (final f in [
      file,
      File('${file.path}.verified'),
      File('${file.path}.part'),
    ]) {
      if (f.existsSync()) await f.delete();
    }
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

      while (!_cancelled) {
        final request = await _client!.getUrl(Uri.parse(_config.sourceUrl));
        if (offset > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
        }
        final response = await request.close();
        if (offset > 0 && response.statusCode == HttpStatus.ok) {
          // Server ignored the range and sent the whole file: start over
          // instead of appending it to the partial download.
          offset = 0;
        } else if (offset > 0 &&
            response.statusCode != HttpStatus.partialContent) {
          return Err('resume_failed', response.statusCode);
        } else if (offset == 0 && response.statusCode != HttpStatus.ok) {
          return Err('download_failed', response.statusCode);
        }
        final sink = part.openWrite(
          mode: offset == 0 ? FileMode.write : FileMode.append,
        );

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

  /// Full SHA-256 check (off the UI thread); records a marker on success.
  Future<bool> _verifyFile(File file) async {
    if (_config.sha256.startsWith('00000000')) {
      return file.lengthSync() > 1024 * 1024;
    }
    final size = _config.sizeBytes;
    if (size != null && file.lengthSync() != size) return false;
    final path = file.path;
    final digest = await Isolate.run(
      () async => (await sha256.bind(File(path).openRead()).first).toString(),
    );
    final ok = digest == _config.sha256.toLowerCase();
    if (ok) await File('$path.verified').writeAsString(digest);
    return ok;
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

import 'dart:io';

import 'package:arth/llm/model_config.dart';
import 'package:arth/llm/model_download_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;
  late HttpServer server;
  late Uri url;
  final payload = List<int>.generate(2048, (i) => i % 256);

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('arth_model_dl');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    url = Uri.parse('http://${server.address.host}:${server.port}/model.gguf');
    server.listen((request) async {
      if (request.method == 'GET') {
        final range = request.headers.value(HttpHeaders.rangeHeader);
        if (range != null && range.startsWith('bytes=')) {
          final start = int.parse(range.substring(6).split('-').first);
          final slice = payload.sublist(start);
          request.response.statusCode = HttpStatus.partialContent;
          request.response.headers.contentLength = slice.length;
          request.response.add(slice);
        } else {
          request.response.contentLength = payload.length;
          request.response.add(payload);
        }
      } else {
        request.response.statusCode = HttpStatus.methodNotAllowed;
      }
      await request.response.close();
    });
  });

  tearDownAll(() async {
    await server.close(force: true);
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  ModelDownloadManager manager({
    required String sha256,
    bool wifiOnly = false,
  }) {
    return ModelDownloadManager(
      config: ModelConfig(
        name: 'test-model',
        quant: 'Q4',
        sourceUrl: url.toString(),
        sha256: sha256,
        fileName: 'test.gguf',
      ),
      httpClientFactory: HttpClient.new,
      supportDir: () async => tmp,
      wifiOnly: wifiOnly,
      isOnWifi: () async => true,
    );
  }

  test('resume completes and verifies checksum', () async {
    final hash = sha256.convert(payload).toString();
    final mgr = manager(sha256: hash);
    final dest = await mgr.modelFilePath();
    final part = File('${dest.path}.part');
    await part.writeAsBytes(payload.sublist(0, 1000));

    final result = await mgr.download();
    expect(result.isOk, isTrue);
    expect(await dest.readAsBytes(), payload);
  });

  test('checksum mismatch deletes file and errors', () async {
    final mgr = manager(sha256: 'a' * 64);
    final result = await mgr.download();
    expect(result.isErr, isTrue);
    expect(result.errorOrNull, 'checksum_mismatch');
    final dest = await mgr.modelFilePath();
    expect(dest.existsSync(), isFalse);
  });
}

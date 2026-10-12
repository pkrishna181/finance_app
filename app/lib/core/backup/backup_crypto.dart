import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Passphrase encryption for backup files.
///
/// Layout: `ARTHBAK1` | iterations (u32 BE) | salt (16) | nonce (12) |
/// AES-256-GCM ciphertext + 16-byte tag. The header is authenticated as
/// associated data, so tampering or a wrong passphrase fails decryption.
/// Key = PBKDF2-HMAC-SHA256(passphrase, salt, iterations).
class BackupCrypto {
  static const magic = 'ARTHBAK1';
  static const defaultIterations = 600000;
  static const _saltLen = 16;
  static const _nonceLen = 12;
  static const _headerLen = 8 + 4 + _saltLen + _nonceLen;

  static Future<Uint8List> encrypt(
    Uint8List plain,
    String passphrase, {
    int iterations = defaultIterations,
  }) {
    final rnd = Random.secure();
    final salt = Uint8List.fromList(
      List.generate(_saltLen, (_) => rnd.nextInt(256)),
    );
    final nonce = Uint8List.fromList(
      List.generate(_nonceLen, (_) => rnd.nextInt(256)),
    );
    return Isolate.run(
      () => _encrypt(plain, passphrase, iterations, salt, nonce),
    );
  }

  /// Throws [BackupException] (`not_a_backup`, `wrong_passphrase`).
  static Future<Uint8List> decrypt(Uint8List data, String passphrase) =>
      Isolate.run(() => _decrypt(data, passphrase));

  static Uint8List _encrypt(
    Uint8List plain,
    String passphrase,
    int iterations,
    Uint8List salt,
    Uint8List nonce,
  ) {
    final header = BytesBuilder()
      ..add(ascii.encode(magic))
      ..add((ByteData(4)..setUint32(0, iterations)).buffer.asUint8List())
      ..add(salt)
      ..add(nonce);
    final h = header.toBytes();
    final key = _key(passphrase, salt, iterations);
    final gcm = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, nonce, h));
    return Uint8List.fromList([...h, ...gcm.process(plain)]);
  }

  static Uint8List _decrypt(Uint8List data, String passphrase) {
    if (data.length < _headerLen + 16 ||
        ascii.decode(data.sublist(0, 8), allowInvalid: true) != magic) {
      throw const BackupException('not_a_backup');
    }
    final h = data.sublist(0, _headerLen);
    final iterations = ByteData.sublistView(data, 8, 12).getUint32(0);
    if (iterations < 1000 || iterations > 10000000) {
      throw const BackupException('not_a_backup');
    }
    final salt = data.sublist(12, 12 + _saltLen);
    final nonce = data.sublist(12 + _saltLen, _headerLen);
    final key = _key(passphrase, salt, iterations);
    final gcm = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, nonce, h));
    try {
      return gcm.process(data.sublist(_headerLen));
    } on InvalidCipherTextException {
      throw const BackupException('wrong_passphrase');
    } on ArgumentError {
      throw const BackupException('wrong_passphrase');
    }
  }

  static Uint8List _key(String passphrase, Uint8List salt, int iterations) {
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, 32));
    return kdf.process(Uint8List.fromList(utf8.encode(passphrase)));
  }
}

class BackupException implements Exception {
  const BackupException(this.code, [this.detail]);

  /// not_a_backup | wrong_passphrase | newer_version | bad_contents
  final String code;
  final Object? detail;

  @override
  String toString() =>
      'BackupException($code${detail == null ? '' : ': $detail'})';
}

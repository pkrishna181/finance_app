import 'dart:io';

import 'package:arth/core/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('arth_orph_'));
  tearDown(() async => tmp.delete(recursive: true));

  Future<void> create(File file, String key) async {
    final db = ArthDatabase.openEncryptedFile(file: file, key: key);
    await db.customSelect('SELECT count(*) FROM categories').get();
    await db.close();
  }

  test('a database restored without its key cannot be opened', () async {
    final file = File(p.join(tmp.path, 'arth_encrypted.db'));
    await create(file, 'key-from-the-old-install');

    final db = ArthDatabase.openEncryptedFile(file: file, key: 'new-key');
    await expectLater(
      db.customSelect('SELECT 1').get(),
      throwsA(predicate((e) => '$e'.contains('file is not a database'))),
    );
    await db.close();
  });

  test(
    'setting it aside lets a fresh database open with the new key',
    () async {
      final file = File(p.join(tmp.path, 'arth_encrypted.db'));
      await create(file, 'key-from-the-old-install');
      File('${file.path}-wal').writeAsStringSync('x');

      final now = DateTime(2026, 10, 21);
      expect(await setAsideUnreadableDatabase(file, now: now), isTrue);
      final stamp = now.millisecondsSinceEpoch;
      expect(File('${file.path}.unreadable-$stamp').existsSync(), isTrue);
      expect(File('${file.path}-wal.unreadable-$stamp').existsSync(), isTrue);
      expect(file.existsSync(), isFalse);

      await create(file, 'new-key');
      expect(file.existsSync(), isTrue);
    },
  );

  test('nothing to set aside on a clean install', () async {
    final file = File(p.join(tmp.path, 'arth_encrypted.db'));
    expect(await setAsideUnreadableDatabase(file), isFalse);
  });
}

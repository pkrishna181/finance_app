import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../ingestion/statement/pdf/password_vault.dart';
import '../db/database.dart';
import 'backup_crypto.dart';

/// What a backup contains (shown before restoring).
class BackupSummary {
  const BackupSummary({
    required this.createdAt,
    required this.schemaVersion,
    required this.transactions,
    required this.tables,
    required this.savedPasswords,
  });

  final DateTime createdAt;
  final int schemaVersion;
  final int transactions;
  final int tables;
  final int savedPasswords;
}

/// Exports every table to an encrypted file and restores it, replacing all
/// data. The file never leaves the phone unless the user moves it.
class BackupService {
  BackupService(this._db, {this.vault, this.iterations});

  final ArthDatabase _db;
  /// Saved statement passwords to include / restore (optional).
  final PdfPasswordVault? vault;

  /// PBKDF2 iterations (tests use fewer).
  final int? iterations;

  static const format = 1;

  Future<List<String>> _tables() async {
    final rows = await _db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();
    return [for (final r in rows) r.read<String>('name')];
  }

  Future<List<String>> _columns(String table) async {
    final rows = await _db.customSelect('PRAGMA table_info("$table")').get();
    return [for (final r in rows) r.read<String>('name')];
  }

  Future<Uint8List> export(
    String passphrase, {
    bool includePasswords = false,
  }) async {
    final tables = <String, Object>{};
    for (final t in await _tables()) {
      final cols = await _columns(t);
      final rows = await _db.customSelect('SELECT * FROM "$t"').get();
      tables[t] = {
        'columns': cols,
        'rows': [
          for (final r in rows) [for (final c in cols) _encodeValue(r.data[c])],
        ],
      };
    }
    final v = vault;
    final passwords = includePasswords && v != null ? await v.list() : null;
    final payload = {
      'format': format,
      'app': 'arth',
      'schemaVersion': _db.schemaVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
      if (passwords != null)
        'pdfPasswords': [for (final p in passwords) p.toJson()],
    };
    final gz = GZipCodec().encode(utf8.encode(jsonEncode(payload)));
    return BackupCrypto.encrypt(
      Uint8List.fromList(gz),
      passphrase,
      iterations: iterations ?? BackupCrypto.defaultIterations,
    );
  }

  static Object? _encodeValue(Object? v) =>
      v is Uint8List ? {'b64': base64Encode(v)} : v;

  static Object? _decodeValue(Object? v) =>
      v is Map && v['b64'] is String ? base64Decode(v['b64'] as String) : v;

  Future<Map<String, Object?>> _open(Uint8List file, String passphrase) async {
    final plain = await BackupCrypto.decrypt(file, passphrase);
    try {
      final json = jsonDecode(utf8.decode(GZipCodec().decode(plain)));
      final m = Map<String, Object?>.from(json as Map);
      if (m['app'] != 'arth' || m['format'] != format) {
        throw const BackupException('not_a_backup');
      }
      return m;
    } on BackupException {
      rethrow;
    } catch (e) {
      throw BackupException('bad_contents', e);
    }
  }

  /// Decrypts and describes a backup without changing anything.
  Future<BackupSummary> inspect(Uint8List file, String passphrase) async =>
      _summary(await _open(file, passphrase));

  static BackupSummary _summary(Map<String, Object?> m) {
    final tables = Map<String, Object?>.from(m['tables'] as Map);
    final txns = tables['transactions'] as Map?;
    return BackupSummary(
      createdAt: DateTime.parse(m['createdAt'] as String).toLocal(),
      schemaVersion: m['schemaVersion'] as int,
      transactions: (txns?['rows'] as List?)?.length ?? 0,
      tables: tables.length,
      savedPasswords: (m['pdfPasswords'] as List?)?.length ?? 0,
    );
  }

  /// Replaces **all** data with the backup's. Older backups restore into the
  /// current schema (new columns get their defaults); newer ones are refused.
  Future<BackupSummary> restore(Uint8List file, String passphrase) async {
    final m = await _open(file, passphrase);
    final version = m['schemaVersion'] as int;
    if (version > _db.schemaVersion) {
      throw BackupException('newer_version', version);
    }
    final tables = Map<String, Object?>.from(m['tables'] as Map);
    final current = await _tables();

    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        for (final t in current) {
          await _db.customStatement('DELETE FROM "$t"');
        }
        for (final e in tables.entries) {
          if (!current.contains(e.key)) continue;
          final have = (await _columns(e.key)).toSet();
          final t = Map<String, Object?>.from(e.value as Map);
          final cols = [for (final c in t['columns'] as List) c as String];
          final keep = [
            for (var i = 0; i < cols.length; i++)
              if (have.contains(cols[i])) i,
          ];
          if (keep.isEmpty) continue;
          final sql =
              'INSERT INTO "${e.key}" '
              '(${keep.map((i) => '"${cols[i]}"').join(', ')}) VALUES '
              '(${List.filled(keep.length, '?').join(', ')})';
          for (final row in t['rows'] as List) {
            final r = row as List;
            await _db.customStatement(sql, [
              for (final i in keep) _decodeValue(r[i]),
            ]);
          }
        }
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
    final violations = await _db.customSelect('PRAGMA foreign_key_check').get();
    if (violations.isNotEmpty) {
      throw BackupException('bad_contents', 'foreign keys');
    }
    _db.notifyUpdates({for (final t in _db.allTables) TableUpdate.onTable(t)});

    final pw = m['pdfPasswords'] as List?;
    final v = vault;
    if (pw != null && v != null) {
      for (final j in pw) {
        final p = SavedPdfPassword.fromJson(
          Map<String, Object?>.from(j as Map),
        );
        await v.add(p.label, p.password, bankCode: p.bankCode);
      }
    }
    return _summary(m);
  }
}

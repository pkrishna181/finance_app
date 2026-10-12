import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A statement password the user chose to remember, e.g. "Axis credit card".
class SavedPdfPassword {
  const SavedPdfPassword({
    required this.id,
    required this.label,
    required this.password,
    this.bankCode,
    this.lastUsed,
  });

  final String id;
  final String label;
  final String password;

  /// Bank detected the last time this password opened a statement.
  final String? bankCode;
  final DateTime? lastUsed;

  SavedPdfPassword copyWith({
    String? label,
    String? bankCode,
    DateTime? lastUsed,
  }) => SavedPdfPassword(
    id: id,
    label: label ?? this.label,
    password: password,
    bankCode: bankCode ?? this.bankCode,
    lastUsed: lastUsed ?? this.lastUsed,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'password': password,
    'bank': bankCode,
    'used': lastUsed?.millisecondsSinceEpoch,
  };

  factory SavedPdfPassword.fromJson(Map<String, Object?> j) => SavedPdfPassword(
    id: j['id'] as String,
    label: j['label'] as String,
    password: j['password'] as String,
    bankCode: j['bank'] as String?,
    lastUsed: j['used'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(j['used'] as int),
  );
}

/// Statement passwords kept in platform secure storage (Android Keystore /
/// iOS Keychain), never in the database, logs or backups we control.
class PdfPasswordVault {
  PdfPasswordVault({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'arth_pdf_passwords_v1';

  final FlutterSecureStorage _storage;

  Future<List<SavedPdfPassword>> list() async {
    final raw = await _storage.read(key: _keyName);
    if (raw == null || raw.isEmpty) return [];
    return [
      for (final e in jsonDecode(raw) as List)
        SavedPdfPassword.fromJson(Map<String, Object?>.from(e as Map)),
    ];
  }

  Future<void> _save(List<SavedPdfPassword> all) => _storage.write(
    key: _keyName,
    value: jsonEncode([for (final p in all) p.toJson()]),
  );

  /// Adds [password] under [label]. If the same password is already saved,
  /// that entry is relabelled instead of duplicated.
  Future<SavedPdfPassword> add(
    String label,
    String password, {
    String? bankCode,
  }) async {
    final all = await list();
    final i = all.indexWhere((p) => p.password == password);
    final now = DateTime.now();
    if (i >= 0) {
      all[i] = all[i].copyWith(label: label, bankCode: bankCode, lastUsed: now);
      await _save(all);
      return all[i];
    }
    final entry = SavedPdfPassword(
      id: _newId(),
      label: label,
      password: password,
      bankCode: bankCode,
      lastUsed: now,
    );
    await _save([...all, entry]);
    return entry;
  }

  Future<void> rename(String id, String label) async {
    final all = await list();
    await _save([
      for (final p in all) p.id == id ? p.copyWith(label: label) : p,
    ]);
  }

  Future<void> remove(String id) async {
    final all = await list();
    await _save([
      for (final p in all)
        if (p.id != id) p,
    ]);
  }

  Future<void> clear() => _storage.delete(key: _keyName);

  /// Records a successful unlock (and the bank it turned out to be).
  Future<void> markUsed(String id, {String? bankCode}) async {
    final all = await list();
    await _save([
      for (final p in all)
        p.id == id
            ? p.copyWith(
                lastUsed: DateTime.now(),
                bankCode: bankCode == null || bankCode == 'UNKNOWN'
                    ? null
                    : bankCode,
              )
            : p,
    ]);
  }

  /// Saved passwords ordered for [fileName]: entries whose label or bank
  /// matches a word in the file name first, then most recently used.
  Future<List<SavedPdfPassword>> candidatesFor(String fileName) async {
    final words = fileNameWords(fileName);
    int score(SavedPdfPassword p) {
      final label = fileNameWords(p.label);
      final bank = p.bankCode?.toLowerCase();
      return words.any((w) => label.contains(w) || w == bank) ? 1 : 0;
    }

    final all = await list();
    all.sort((a, b) {
      final s = score(b).compareTo(score(a));
      if (s != 0) return s;
      final at = a.lastUsed?.millisecondsSinceEpoch ?? 0;
      final bt = b.lastUsed?.millisecondsSinceEpoch ?? 0;
      return bt.compareTo(at);
    });
    return all;
  }

  static String _newId() {
    final r = Random.secure();
    return List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
  }
}

/// Lowercase alphabetic words (≥ 3 letters) from a file name or label,
/// ignoring generic words like "statement".
Set<String> fileNameWords(String s) {
  const generic = {
    'statement',
    'stmt',
    'pdf',
    'account',
    'acct',
    'bank',
    'card',
    'credit',
    'the',
    'and',
    'for',
    'xls',
    'xlsx',
    'csv',
    'estatement',
    'monthly',
  };
  return {
    for (final w in s.toLowerCase().split(RegExp(r'[^a-z]+')))
      if (w.length >= 3 && !generic.contains(w)) w,
  };
}

/// Issuer guessed from a file name, for labels and hints. Null if unknown.
String? guessIssuer(String fileName) {
  const issuers = {
    'hdfc': 'HDFC',
    'icici': 'ICICI',
    'sbi': 'SBI',
    'axis': 'AXIS',
    'kotak': 'KOTAK',
    'amex': 'AMEX',
    'idfc': 'IDFC',
    'indusind': 'INDUSIND',
    'yes': 'YES',
    'rbl': 'RBL',
    'federal': 'FEDERAL',
    'onecard': 'ONECARD',
    'cams': 'CAMS',
    'kfintech': 'KFINTECH',
    'nsdl': 'NSDL',
    'cdsl': 'CDSL',
  };
  final words = fileName.toLowerCase().split(RegExp(r'[^a-z]+')).toSet();
  for (final e in issuers.entries) {
    if (words.contains(e.key)) return e.value;
  }
  return null;
}

/// What the user typed when no saved password worked.
class PasswordEntry {
  const PasswordEntry({
    required this.password,
    required this.remember,
    required this.label,
  });

  final String password;
  final bool remember;
  final String label;
}

/// Supplies passwords to the PDF loader: every saved candidate first, then
/// [ask]s the user. After the PDF opens, call [commit] to update the vault.
class PdfUnlockSession {
  PdfUnlockSession({
    required this.vault,
    required this.fileName,
    required this.ask,
    this.maxAsks = 3,
  });

  final PdfPasswordVault vault;
  final String fileName;

  /// Prompt for a password; [failedAsks] is how many typed passwords were
  /// wrong so far. Return null to give up.
  final Future<PasswordEntry?> Function(int failedAsks) ask;
  final int maxAsks;

  List<SavedPdfPassword>? _candidates;
  var _next = 0;
  var _asks = 0;
  SavedPdfPassword? _lastSaved;
  PasswordEntry? _lastEntry;

  /// Number of saved passwords tried so far.
  int get savedTried => _next;

  /// For `PdfStatementLoader(passwordProvider: session.provide)`.
  Future<String?> provide(int _) async {
    final c = _candidates ??= await vault.candidatesFor(fileName);
    if (_next < c.length) {
      _lastSaved = c[_next++];
      _lastEntry = null;
      return _lastSaved!.password;
    }
    if (_asks >= maxAsks) return null;
    final entry = await ask(_asks);
    _asks++;
    if (entry == null || entry.password.isEmpty) return null;
    _lastSaved = null;
    _lastEntry = entry;
    return entry.password;
  }

  /// Call once the document opened. Saves a typed password when the user
  /// asked to remember it, or marks the saved one as used.
  Future<void> commit({String? bankCode}) async {
    final bank = bankCode == null || bankCode == 'UNKNOWN' ? null : bankCode;
    if (_lastSaved != null) {
      await vault.markUsed(_lastSaved!.id, bankCode: bank);
    } else if (_lastEntry case final e? when e.remember) {
      await vault.add(e.label, e.password, bankCode: bank);
    }
  }
}

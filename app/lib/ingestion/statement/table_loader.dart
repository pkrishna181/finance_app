import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel_community/excel_community.dart';

import '../../core/result/result.dart';

/// Uniform grid produced by CSV / Excel loaders.
class TableGrid {
  const TableGrid({
    required this.rows,
    required this.sourceFormat,
    this.detectedDelimiter,
    this.detectedEncoding,
  });

  final List<List<String>> rows;
  final String sourceFormat; // csv | xlsx | xls
  final String? detectedDelimiter;
  final String? detectedEncoding;
}

/// Load CSV (delimiter + encoding sniff) or xlsx/xls into a string grid.
class TableLoader {
  Result<TableGrid> loadBytes(Uint8List bytes, {String? fileName}) {
    final lower = (fileName ?? '').toLowerCase();
    // Legacy BIFF .xls is not supported — ask user to export XLSX/CSV.
    if (lower.endsWith('.xls') && !_looksLikeZip(bytes)) {
      return const Err('xls_unsupported_export_xlsx_or_csv');
    }
    if (lower.endsWith('.xlsx') ||
        _looksLikeZip(bytes) ||
        _looksLikeOle(bytes)) {
      return _loadExcel(bytes, fileName: fileName);
    }
    return _loadCsv(bytes);
  }

  Result<TableGrid> _loadCsv(Uint8List bytes) {
    final decoded = _decodeBytes(bytes);
    final text = decoded.text;
    final delimiter = _sniffDelimiter(text);
    try {
      final codec = Csv(
        fieldDelimiter: delimiter,
        autoDetect: false,
        dynamicTyping: false,
      );
      final rows = codec.decode(text);
      final asStrings = rows
          .map(
            (r) => r.map((c) => c?.toString() ?? '').toList(growable: false),
          )
          .toList(growable: false);
      return Ok(
        TableGrid(
          rows: asStrings,
          sourceFormat: 'csv',
          detectedDelimiter: delimiter,
          detectedEncoding: decoded.encoding,
        ),
      );
    } catch (e) {
      return Err('csv_parse_failed', e);
    }
  }

  Result<TableGrid> _loadExcel(Uint8List bytes, {String? fileName}) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet =
          excel.tables.values.isEmpty ? null : excel.tables.values.first;
      if (sheet == null) {
        return const Err('excel_empty');
      }
      final rows = <List<String>>[];
      for (final row in sheet.rows) {
        rows.add(
          row.map((cell) => _cellToString(cell)).toList(growable: false),
        );
      }
      final fmt = (fileName ?? '').toLowerCase().endsWith('.xls') &&
              !_looksLikeZip(bytes)
          ? 'xls'
          : 'xlsx';
      return Ok(TableGrid(rows: rows, sourceFormat: fmt));
    } catch (e) {
      return Err('excel_parse_failed', e);
    }
  }

  String _cellToString(Data? cell) {
    if (cell == null) return '';
    final v = cell.value;
    if (v == null) return '';
    if (v is DateCellValue) {
      return '${v.day.toString().padLeft(2, '0')}-'
          '${v.month.toString().padLeft(2, '0')}-'
          '${v.year}';
    }
    if (v is DateTimeCellValue) {
      return v.toString();
    }
    if (v is DoubleCellValue) {
      // Preserve serials as numbers for parseStatementDate.
      return v.value.toString();
    }
    if (v is IntCellValue) {
      return v.value.toString();
    }
    return v.toString();
  }

  bool _looksLikeZip(Uint8List b) =>
      b.length >= 4 && b[0] == 0x50 && b[1] == 0x4b;

  bool _looksLikeOle(Uint8List b) =>
      b.length >= 8 &&
      b[0] == 0xd0 &&
      b[1] == 0xcf &&
      b[2] == 0x11 &&
      b[3] == 0xe0;

  ({String text, String encoding}) _decodeBytes(Uint8List bytes) {
    try {
      return (text: utf8.decode(bytes), encoding: 'utf-8');
    } catch (_) {
      return (text: latin1.decode(bytes), encoding: 'windows-1252');
    }
  }

  String _sniffDelimiter(String text) {
    final sample = text.split('\n').take(20).join('\n');
    final counts = <String, int>{
      ',': ','.allMatches(sample).length,
      ';': ';'.allMatches(sample).length,
      '\t': '\t'.allMatches(sample).length,
    };
    var best = ',';
    var bestN = -1;
    counts.forEach((d, n) {
      if (n > bestN) {
        best = d;
        bestN = n;
      }
    });
    return best;
  }
}

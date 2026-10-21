import 'dart:io';
import 'dart:typed_data';

import 'package:arth/core/models/transaction_type.dart';
import 'package:arth/ingestion/statement/header_mapper.dart';
import 'package:arth/ingestion/statement/line_statement_parser.dart';
import 'package:arth/ingestion/statement/pdf/pdf_loader.dart';
import 'package:arth/ingestion/statement/row_parser.dart';
import 'package:arth/ingestion/statement/statement_summary.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the PDF pipeline gets out of real statements. Skipped unless
/// ARTH_PDF_DIR is set; the report (which quotes statement rows) goes to
/// ARTH_PDF_REPORT. Neither belongs in the repo.
///
///   ARTH_PDF_DIR=~/Statements ARTH_PDF_REPORT=report.txt \
///     flutter test test/ingestion/pdf/real_pdf_coverage_test.dart
void main() {
  final dir = Platform.environment['ARTH_PDF_DIR'];
  final reportPath = Platform.environment['ARTH_PDF_REPORT'];

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  test('real statement coverage', () async {
    if (dir == null || reportPath == null) {
      markTestSkipped('set ARTH_PDF_DIR and ARTH_PDF_REPORT to run');
      return;
    }
    final out = StringBuffer();
    final files = Directory(dir).listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      out.writeln('######## ${f.uri.pathSegments.last}');
      final loaded = await PdfStatementLoader().loadBytes(
        bytes: Uint8List.fromList(f.readAsBytesSync()),
        passwordProvider: (_) async =>
            Platform.environment['ARTH_PDF_PASSWORD'],
      );
      if (loaded.isErr) {
        out.writeln('LOAD FAILED: ${loaded.errorOrNull}');
        continue;
      }
      final rows = loaded.okOrNull!.rows;
      final map = HeaderMapper().map(rows);
      final parsed = StatementRowParser().parse(rows: rows, columnMap: map);
      final summary = extractStatementSummary(rows);
      final txns = parsed.transactions;
      int sum(TransactionDirection d) => txns
          .where((t) => t.direction == d)
          .fold(0, (a, t) => a + t.amountPaise.paise);

      out
        ..writeln(
          'grid rows ${rows.length}; profile ${map.profileId} bank '
          '${map.bankCode} header row ${map.headerRowIndex} '
          'confidence ${map.overallConfidence.toStringAsFixed(2)}',
        )
        ..writeln(
          'bindings: ${[for (final b in map.bindings) '${b.field.name}@${b.index}="${b.matchedHeader}"'].join(', ')}',
        )
        ..writeln(
          'txns ${txns.length} (debits ${sum(TransactionDirection.debit) / 100}, '
          'credits ${sum(TransactionDirection.credit) / 100}); '
          'unparsed ${parsed.unparsed.length}',
        )
        ..writeln(
          'summary: last4 ${summary.last4} stmt ${summary.statementDate} '
          'due ${summary.dueDate} total ${summary.totalDuePaise} '
          'min ${summary.minDuePaise} limit ${summary.creditLimitPaise}',
        )
        ..writeln('--- header row and around:');
      final h = map.headerRowIndex;
      for (
        var i = (h - 2).clamp(0, rows.length);
        i < (h + 4).clamp(0, rows.length);
        i++
      ) {
        out.writeln('  [$i] ${rows[i]}');
      }
      out.writeln('--- transactions:');
      for (final t in txns) {
        out.writeln(
          '  ${t.bookedAt.toIso8601String().substring(0, 10)} '
          '${t.direction.name[0]}${t.directionInferred ? '?' : ''} '
          '${t.amountPaise.paise / 100} ${t.type.name} '
          'bal=${t.balanceAfterPaise == null ? '-' : t.balanceAfterPaise!.paise / 100} '
          '| ${t.rawMerchant} | ${t.rawDescription}',
        );
      }
      final line = const LineStatementParser().parse(
        loaded.okOrNull!.pdfLines ?? const [],
      );
      int lsum(TransactionDirection d) => line.transactions
          .where((t) => t.direction == d)
          .fold(0, (a, t) => a + t.amountPaise.paise);
      out.writeln(
        '--- line parser: ${line.transactions.length} txns, card ${line.isCard}, '
        'bank ${line.bankCode}, columns ${line.amountColumns}, balance '
        '${line.hasBalance}, breaks ${line.balanceBreaks}, debits '
        '${lsum(TransactionDirection.debit) / 100}, credits '
        '${lsum(TransactionDirection.credit) / 100}, unparsed ${line.unparsed.length}',
      );
      for (final t in line.transactions) {
        out.writeln(
          '  ${t.bookedAt.toIso8601String().substring(0, 10)} '
          '${t.direction.name[0]}${t.directionInferred ? '?' : ''} '
          '${t.amountPaise.paise / 100} ${t.type.name} '
          'bal=${t.balanceAfterPaise == null ? '-' : t.balanceAfterPaise!.paise / 100} '
          '| ${t.rawMerchant} | ${t.rawDescription}',
        );
      }
      for (final u in line.unparsed) {
        out.writeln('  UNPARSED $u');
      }
      out.writeln('--- unparsed:');
      for (final u in parsed.unparsed) {
        out.writeln('  $u');
      }
      out.writeln('--- positioned lines:');
      for (final l in loaded.okOrNull!.pdfLines ?? const []) {
        out.writeln(
          '  p${l.pageIndex} y${l.y.toStringAsFixed(1)} '
          '${[for (final w in l.words) '${w.text}@${(w.x + w.width).toStringAsFixed(1)}'].join(' ')}',
        );
      }
      out.writeln('--- full grid:');
      for (var i = 0; i < rows.length; i++) {
        out.writeln('  [$i] ${rows[i]}');
      }
    }
    File(reportPath).writeAsStringSync(out.toString());
  }, timeout: const Timeout(Duration(minutes: 5)));
}

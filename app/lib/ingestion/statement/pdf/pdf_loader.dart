import 'dart:typed_data';

import 'package:pdfrx_engine/pdfrx_engine.dart';

import '../../../core/result/result.dart';
import 'layout_to_grid.dart';
import 'positioned_text.dart';
import 'scanned_detector.dart';
import '../table_loader.dart';

/// Callback to obtain a PDF password. Return null to abort.
typedef PdfPasswordProvider = Future<String?> Function(int attempt);

/// Opens PDFs, handles encryption, extracts positioned text, builds grids.
class PdfStatementLoader {
  PdfStatementLoader({
    ScannedPdfDetector? scannedDetector,
    LayoutToGrid? layoutToGrid,
    Future<void> Function()? ensureInitialized,
  })  : _scanned = scannedDetector ?? const ScannedPdfDetector(),
        _layout = layoutToGrid ?? const LayoutToGrid(),
        _ensureInitialized = ensureInitialized ?? _defaultInit;

  final ScannedPdfDetector _scanned;
  final LayoutToGrid _layout;
  final Future<void> Function() _ensureInitialized;

  static bool _initialized = false;

  static Future<void> _defaultInit() async {
    if (_initialized) return;
    await pdfrxInitialize();
    _initialized = true;
  }

  /// Extract positioned text from all pages.
  Future<Result<List<PdfPageTextContent>>> extractPages({
    required Uint8List bytes,
    PdfPasswordProvider? passwordProvider,
  }) async {
    await _ensureInitialized();

  PdfDocument? doc;
    try {
      doc = await _openWithPassword(bytes, passwordProvider);
      final pages = <PdfPageTextContent>[];
      for (final page in doc.pages) {
        pages.add(await _extractPage(page));
      }
      return Ok(pages);
    } on PdfPasswordException {
      return const Err('pdf_password_required');
    } on PdfException catch (e) {
      if (_isPasswordError(e)) {
        return const Err('pdf_password_required');
      }
      return Err('pdf_open_failed', e);
    } catch (e) {
      return Err('pdf_open_failed', e);
    } finally {
      await doc?.dispose();
    }
  }

  /// Full pipeline: bytes → [TableGrid] for header_mapper / row_parser.
  Future<Result<TableGrid>> loadBytes({
    required Uint8List bytes,
    PdfPasswordProvider? passwordProvider,
  }) async {
    final pagesResult = await extractPages(
      bytes: bytes,
      passwordProvider: passwordProvider,
    );
    if (pagesResult.isErr) return Err(pagesResult.errorOrNull!);

    final pages = pagesResult.okOrNull!;
    final scanned = _scanned.declineReason(pages);
    if (scanned != null) {
      return Err(scanned);
    }

    final grid = _layout.buildFlatGrid(pages);
    if (grid.isEmpty) return const Err('pdf_no_table');

    return Ok(TableGrid(rows: grid, sourceFormat: 'pdf'));
  }

  Future<PdfDocument> _openWithPassword(
    Uint8List bytes,
    PdfPasswordProvider? passwordProvider,
  ) async {
    var attempt = 0;
    String? lastPassword;

    Future<String?> pdfrxProvider() async {
      if (attempt == 0) {
        attempt++;
        return '';
      }
      if (passwordProvider == null) return null;
      final pwd = await passwordProvider(attempt);
      attempt++;
      lastPassword = pwd;
      return pwd;
    }

    try {
      return await PdfDocument.openData(
        bytes,
        passwordProvider: pdfrxProvider,
        firstAttemptByEmptyPassword: true,
        sourceName: 'statement.pdf',
      );
    } on PdfException {
      if (passwordProvider != null && lastPassword != null) {
        throw const PdfException('Invalid password');
      }
      rethrow;
    }
  }

  bool _isPasswordError(PdfException e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('password') || msg.contains('encrypt');
  }

  Future<PdfPageTextContent> _extractPage(PdfPage page) async {
    await page.ensureLoaded();
    final structured = await page.loadStructuredText();
    final pageHeight = page.height;

    final words = <PositionedWord>[];
    for (final frag in structured.fragments) {
      final text = frag.text.trim();
      if (text.isEmpty) continue;
      final b = frag.bounds;
      words.add(
        PositionedWord(
          text: text,
          x: b.left,
          y: pageHeight - b.top,
          pageIndex: page.pageNumber - 1,
          width: b.width,
          height: b.height,
        ),
      );
    }

    final plainLen = structured.fullText.replaceAll(RegExp(r'\s+'), '').length;

    return PdfPageTextContent(
      pageIndex: page.pageNumber - 1,
      words: words,
      pageHeight: pageHeight,
      plainTextLength: plainLen,
    );
  }
}

String pdfPasswordRequiredMessage(String bankHint) =>
    'This PDF is password-protected. $bankHint';

String pdfLoadErrorMessage(String code) {
  return switch (code) {
    'scanned_pdf' => scannedPdfUserMessage(),
    'pdf_password_required' => 'PDF password required.',
    'pdf_no_table' => 'Could not find a transaction table in this PDF.',
    'pdf_empty' => 'PDF appears to be empty.',
    'xls_unsupported_export_xlsx_or_csv' =>
      'Legacy .xls could not be read — please export as XLSX or CSV.',
    _ => 'Could not parse this file ($code).',
  };
}

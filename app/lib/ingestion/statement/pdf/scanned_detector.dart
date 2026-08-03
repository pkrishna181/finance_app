import 'positioned_text.dart';

/// Heuristic: pages with near-zero extractable text are treated as scanned.
class ScannedPdfDetector {
  const ScannedPdfDetector({
    this.minMeaningfulCharsPerPage = 30,
    this.minWordsPerPage = 5,
  });

  final int minMeaningfulCharsPerPage;
  final int minWordsPerPage;

  /// Returns a user-facing reason when the document looks scanned, else null.
  String? declineReason(List<PdfPageTextContent> pages) {
    if (pages.isEmpty) return 'pdf_empty';

    var textPages = 0;
    var scannedPages = 0;

    for (final page in pages) {
      final meaningful = _meaningfulCharCount(page);
      final wordCount = page.words.where((w) => w.text.trim().isNotEmpty).length;

      if (meaningful >= minMeaningfulCharsPerPage &&
          wordCount >= minWordsPerPage) {
        textPages++;
        continue;
      }

      // A page with a handful of header/footer chars but no table is scanned.
      if (meaningful < minMeaningfulCharsPerPage || wordCount < minWordsPerPage) {
        scannedPages++;
      }
    }

    if (textPages == 0 && scannedPages > 0) {
      return 'scanned_pdf';
    }
    return null;
  }

  int _meaningfulCharCount(PdfPageTextContent page) {
    final buf = StringBuffer();
    for (final w in page.words) {
      final t = w.text.trim();
      if (t.isNotEmpty) buf.write(t);
    }
    return buf.length;
  }
}

String scannedPdfUserMessage() =>
    'This looks like a scanned copy — please download the digital statement '
    'or use CSV/Excel.';

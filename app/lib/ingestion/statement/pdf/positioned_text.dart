/// A word extracted from a PDF page with layout coordinates.
///
/// [y] is distance from the top of the page (top-down, points).
class PositionedWord {
  const PositionedWord({
    required this.text,
    required this.x,
    required this.y,
    required this.pageIndex,
    required this.width,
    required this.height,
  });

  final String text;
  final double x;
  final double y;
  final int pageIndex;
  final double width;
  final double height;

  double get centerX => x + width / 2;
  double get centerY => y + height / 2;
}

/// Text content extracted from one PDF page.
class PdfPageTextContent {
  const PdfPageTextContent({
    required this.pageIndex,
    required this.words,
    required this.pageHeight,
    required this.plainTextLength,
  });

  final int pageIndex;
  final List<PositionedWord> words;
  final double pageHeight;

  /// Length of whitespace-stripped plain text on the page.
  final int plainTextLength;
}

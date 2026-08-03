import 'package:arth/ingestion/statement/pdf/positioned_text.dart';
import 'package:arth/ingestion/statement/pdf/scanned_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const detector = ScannedPdfDetector();

  test('text-layer pages are accepted', () {
    final page = PdfPageTextContent(
      pageIndex: 0,
      pageHeight: 800,
      plainTextLength: 200,
      words: [
        for (var i = 0; i < 20; i++)
          PositionedWord(
            text: 'word$i',
            x: 40 + i * 10,
            y: 100 + i * 12,
            pageIndex: 0,
            width: 20,
            height: 10,
          ),
      ],
    );
    expect(detector.declineReason([page]), isNull);
  });

  test('image-only page is declined', () {
    final page = PdfPageTextContent(
      pageIndex: 0,
      pageHeight: 800,
      plainTextLength: 0,
      words: const [],
    );
    expect(detector.declineReason([page]), 'scanned_pdf');
  });
}

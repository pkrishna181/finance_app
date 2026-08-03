import 'package:arth/ingestion/statement/pdf/layout_to_grid.dart';
import 'package:arth/ingestion/statement/pdf/positioned_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LayoutToGrid', () {
    const layout = LayoutToGrid(lineYTolerance: 4);

    test('clusters words by y-coordinate tolerance', () {
      final page = PdfPageTextContent(
        pageIndex: 0,
        pageHeight: 800,
        plainTextLength: 20,
        words: const [
          PositionedWord(text: 'Date', x: 40, y: 100, pageIndex: 0, width: 30, height: 10),
          PositionedWord(text: 'Amount', x: 200, y: 101, pageIndex: 0, width: 40, height: 10),
          PositionedWord(text: '01/07/2026', x: 40, y: 120, pageIndex: 0, width: 50, height: 10),
          PositionedWord(text: '1250.00', x: 200, y: 119, pageIndex: 0, width: 40, height: 10),
        ],
      );

      final grid = layout.buildFlatGrid([page]);
      expect(grid.length, greaterThanOrEqualTo(2));
      expect(grid[0].join(' ').toLowerCase(), contains('date'));
      expect(grid[1].any((c) => c.contains('01/07/2026')), isTrue);
      expect(grid[1].any((c) => c.contains('1250')), isTrue);
    });

    test('detects column boundaries from header row', () {
      final page = PdfPageTextContent(
        pageIndex: 0,
        pageHeight: 800,
        plainTextLength: 40,
        words: const [
          PositionedWord(text: 'Date', x: 50, y: 80, pageIndex: 0, width: 30, height: 10),
          PositionedWord(text: 'Narration', x: 150, y: 80, pageIndex: 0, width: 50, height: 10),
          PositionedWord(text: 'Debit', x: 350, y: 80, pageIndex: 0, width: 30, height: 10),
          PositionedWord(text: '01/07/2026', x: 50, y: 100, pageIndex: 0, width: 50, height: 10),
          PositionedWord(text: 'UPI/FOOD', x: 150, y: 100, pageIndex: 0, width: 60, height: 10),
          PositionedWord(text: '1250.00', x: 350, y: 100, pageIndex: 0, width: 40, height: 10),
        ],
      );

      final grid = layout.buildFlatGrid([page]);
      final header = grid.firstWhere((r) => r.join(' ').toLowerCase().contains('date'));
      expect(header.length, greaterThanOrEqualTo(3));
    });

    test('strips repeating page headers at same y across pages', () {
      final headerWords = [
        const PositionedWord(
          text: 'HDFC Bank Ltd',
          x: 40,
          y: 30,
          pageIndex: 0,
          width: 80,
          height: 10,
        ),
      ];
      final tableHeader = [
        const PositionedWord(text: 'Date', x: 40, y: 80, pageIndex: 0, width: 30, height: 10),
        const PositionedWord(text: 'Amount', x: 200, y: 80, pageIndex: 0, width: 40, height: 10),
      ];
      final row1 = [
        const PositionedWord(text: '01/07/2026', x: 40, y: 100, pageIndex: 0, width: 50, height: 10),
        const PositionedWord(text: '100.00', x: 200, y: 100, pageIndex: 0, width: 40, height: 10),
      ];

      final page0 = PdfPageTextContent(
        pageIndex: 0,
        pageHeight: 800,
        plainTextLength: 50,
        words: [...headerWords, ...tableHeader, ...row1],
      );
      final page1 = PdfPageTextContent(
        pageIndex: 1,
        pageHeight: 800,
        plainTextLength: 50,
        words: [
          ...headerWords.map(
            (w) => PositionedWord(
              text: w.text,
              x: w.x,
              y: w.y,
              pageIndex: 1,
              width: w.width,
              height: w.height,
            ),
          ),
          ...tableHeader.map(
            (w) => PositionedWord(
              text: w.text,
              x: w.x,
              y: w.y,
              pageIndex: 1,
              width: w.width,
              height: w.height,
            ),
          ),
          ...row1.map(
            (w) => PositionedWord(
              text: w.text,
              x: w.x,
              y: w.y,
              pageIndex: 1,
              width: w.width,
              height: w.height,
            ),
          ),
        ],
      );

      final grid = layout.buildFlatGrid([page0, page1]);
      final hdfcLines =
          grid.where((r) => r.join(' ').contains('HDFC Bank Ltd')).length;
      expect(hdfcLines, lessThanOrEqualTo(1));
    });
  });
}

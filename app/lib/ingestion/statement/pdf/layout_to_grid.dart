import 'positioned_text.dart';

/// Reconstructs a string grid from positioned PDF text for [HeaderMapper].
class LayoutToGrid {
  const LayoutToGrid({
    this.lineYTolerance = 4.0,
    this.cellGapThreshold = 22.0,
    this.headerFooterMinPages = 2,
  });

  final double lineYTolerance;
  final double cellGapThreshold;
  final int headerFooterMinPages;

  /// Build one or more grids (credit-card sections get separate sub-grids).
  List<List<List<String>>> buildSectionGrids(List<PdfPageTextContent> pages) {
    if (pages.isEmpty) return [[]];

    final lines = _allLines(pages);
    final stripped = _stripRepeatingHeadersFooters(lines);
    final sections = _splitSections(stripped);
    return sections.map(_linesToGrid).where((g) => g.isNotEmpty).toList();
  }

  /// Flatten section grids into a single grid (preamble + tables).
  List<List<String>> buildFlatGrid(List<PdfPageTextContent> pages) {
    final sections = buildSectionGrids(pages);
    if (sections.isEmpty) return [];
    if (sections.length == 1) return sections.first;

    final out = <List<String>>[];
    for (final section in sections) {
      if (out.isNotEmpty && out.last.every((c) => c.trim().isEmpty)) {
        out.removeLast();
      }
      out.addAll(section);
      out.add(const []);
    }
    while (out.isNotEmpty && out.last.every((c) => c.trim().isEmpty)) {
      out.removeLast();
    }
    return out;
  }

  List<_TextLine> _allLines(List<PdfPageTextContent> pages) {
    final lines = <_TextLine>[];
    for (final page in pages) {
      lines.addAll(_clusterLines(page));
    }
    lines.sort((a, b) {
      final pageCmp = a.pageIndex.compareTo(b.pageIndex);
      if (pageCmp != 0) return pageCmp;
      return a.y.compareTo(b.y);
    });
    return lines;
  }

  List<_TextLine> _clusterLines(PdfPageTextContent page) {
    if (page.words.isEmpty) return const [];

    final sorted = [...page.words]
      ..sort((a, b) {
        final yCmp = a.y.compareTo(b.y);
        if (yCmp != 0) return yCmp;
        return a.x.compareTo(b.x);
      });

    final lines = <_TextLine>[];
    var current = <PositionedWord>[sorted.first];
    var lineY = sorted.first.y;

    for (var i = 1; i < sorted.length; i++) {
      final w = sorted[i];
      if ((w.y - lineY).abs() <= lineYTolerance) {
        current.add(w);
      } else {
        lines.add(_TextLine(pageIndex: page.pageIndex, y: lineY, words: current));
        current = [w];
        lineY = w.y;
      }
    }
    lines.add(_TextLine(pageIndex: page.pageIndex, y: lineY, words: current));
    return lines;
  }

  List<_TextLine> _stripRepeatingHeadersFooters(List<_TextLine> lines) {
    if (lines.length < 4) return lines;

    final byPage = <int, List<_TextLine>>{};
    for (final line in lines) {
      byPage.putIfAbsent(line.pageIndex, () => []).add(line);
    }
    if (byPage.length < headerFooterMinPages) return lines;

    final pageKeys = byPage.keys.toList()..sort();
    final headerCandidates = <String, int>{};
    final footerCandidates = <String, int>{};

    for (final pageIdx in pageKeys) {
      final pageLines = byPage[pageIdx]!;
      if (pageLines.isEmpty) continue;
      final headerKey = _lineKey(pageLines.first);
      final footerKey = _lineKey(pageLines.last);
      if (headerKey.isNotEmpty) {
        headerCandidates[headerKey] = (headerCandidates[headerKey] ?? 0) + 1;
      }
      if (footerKey.isNotEmpty && footerKey != headerKey) {
        footerCandidates[footerKey] = (footerCandidates[footerKey] ?? 0) + 1;
      }
    }

    final repeatThreshold = (byPage.length / 2).ceil();
    final stripHeaders = headerCandidates.entries
        .where((e) => e.value >= repeatThreshold)
        .map((e) => e.key)
        .toSet();
    final stripFooters = footerCandidates.entries
        .where((e) => e.value >= repeatThreshold)
        .map((e) => e.key)
        .toSet();

    return lines.where((line) {
      final key = _lineKey(line);
      if (stripHeaders.contains(key)) return false;
      if (stripFooters.contains(key)) return false;
      return true;
    }).toList(growable: false);
  }

  String _lineKey(_TextLine line) {
    final text = line.words.map((w) => w.text.trim()).join(' ').trim();
    return text.toLowerCase();
  }

  List<List<_TextLine>> _splitSections(List<_TextLine> lines) {
    if (lines.isEmpty) return [[]];

    final headerIndices = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_looksLikeTableHeader(lines[i])) {
        headerIndices.add(i);
      }
    }

    if (headerIndices.length <= 1) return [lines];

    final sections = <List<_TextLine>>[];
    for (var s = 0; s < headerIndices.length; s++) {
      final start = headerIndices[s];
      final end = s + 1 < headerIndices.length
          ? headerIndices[s + 1]
          : lines.length;
      final chunk = lines.sublist(start, end);
      if (chunk.length > 1) sections.add(chunk);
    }

    if (headerIndices.first > 0) {
      final preamble = lines.sublist(0, headerIndices.first);
      if (sections.isNotEmpty) {
        sections[0] = [...preamble, ...sections.first];
      }
    }

    return sections.isEmpty ? [lines] : sections;
  }

  bool _looksLikeTableHeader(_TextLine line) {
    final cells = _rowToCells(line.words, const _ColumnLayout.empty());
    final joined = cells.join(' ').toLowerCase();
    final hasDate = joined.contains('date') || joined.contains('txn');
    final hasAmount = joined.contains('amount') ||
        joined.contains('debit') ||
        joined.contains('credit') ||
        joined.contains('withdrawal') ||
        joined.contains('deposit') ||
        joined.contains('particular');
    return hasDate && hasAmount;
  }

  List<List<String>> _linesToGrid(List<_TextLine> lines) {
    if (lines.isEmpty) return [];

    final headerIdx = lines.indexWhere(_looksLikeTableHeader);
    if (headerIdx < 0) {
      return lines
          .map((l) => _rowToCells(l.words, const _ColumnLayout.empty()))
          .where((r) => r.any((c) => c.trim().isNotEmpty))
          .toList();
    }

    final preamble = <List<String>>[];
    for (var i = 0; i < headerIdx; i++) {
      final cells = _rowToCells(lines[i].words, const _ColumnLayout.empty());
      if (cells.any((c) => c.trim().isNotEmpty)) preamble.add(cells);
    }

    final headerLine = lines[headerIdx];
    final sampleData = <List<PositionedWord>>[];
    for (var i = headerIdx + 1; i < lines.length && sampleData.length < 3; i++) {
      if (lines[i].words.isEmpty) continue;
      final first = lines[i].words.first.text;
      if (_looksLikeDate(first) || _looksLikeDate(lines[i].words.map((w) => w.text).join(' '))) {
        sampleData.add(lines[i].words);
      }
    }
    final layout = _ColumnLayout.fromLines(
      [headerLine.words, ...sampleData],
      gapThreshold: 10,
    );
    final headerRow = _rowToCells(headerLine.words, layout);

    final dataRows = <List<String>>[];
    for (var i = headerIdx + 1; i < lines.length; i++) {
      final row = _rowToCells(lines[i].words, layout);
      if (row.every((c) => c.trim().isEmpty)) continue;
      dataRows.add(row);
    }

    return [...preamble, headerRow, ...dataRows];
  }

  bool _looksLikeDate(String cell) =>
      RegExp(r'\d{2}[-/]\d{2}[-/]\d{2,4}').hasMatch(cell);

  /// Gap-split when no table header anchors exist (preamble lines).
  List<String> _rowToCells(List<PositionedWord> words, _ColumnLayout layout) {
    if (words.isEmpty) return const [];
    if (!layout.isAnchored) {
      return _lineToCellsByGap(words);
    }
    return layout.assign(words);
  }

  List<String> _lineToCellsByGap(List<PositionedWord> words) {
    if (words.isEmpty) return const [];
    final sorted = [...words]..sort((a, b) => a.x.compareTo(b.x));
    final cells = <String>[];
    var buffer = StringBuffer();

    for (var i = 0; i < sorted.length; i++) {
      if (i > 0) {
        final prev = sorted[i - 1];
        final gap = sorted[i].x - (prev.x + prev.width);
        if (gap > cellGapThreshold) {
          cells.add(buffer.toString().trim());
          buffer = StringBuffer();
        } else {
          buffer.write(' ');
        }
      }
      buffer.write(sorted[i].text);
    }
    cells.add(buffer.toString().trim());
    return cells;
  }
}

/// Column boundaries derived from the table header row x-positions.
class _ColumnLayout {
  const _ColumnLayout._({
    required this.boundaries,
    required this.columnCount,
  });

  const _ColumnLayout.empty()
      : boundaries = const [],
        columnCount = 0;

  final List<double> boundaries;
  final int columnCount;

  bool get isAnchored => columnCount > 0;

  /// Pick the line with the most column clusters (header or sample data rows).
  factory _ColumnLayout.fromLines(
    List<List<PositionedWord>> lineWordLists, {
    required double gapThreshold,
  }) {
    var bestClusters = <List<PositionedWord>>[];
    for (final words in lineWordLists) {
      if (words.isEmpty) continue;
      final clusters = _clusterWords(words, gapThreshold: gapThreshold);
      if (clusters.length > bestClusters.length) {
        bestClusters = clusters;
      }
    }
    return _ColumnLayout._fromClusters(bestClusters);
  }

  static _ColumnLayout _fromClusters(List<List<PositionedWord>> clusters) {
    if (clusters.isEmpty) return const _ColumnLayout.empty();

    final bounds = <double>[clusters.first.first.x - 2];
    for (var i = 0; i < clusters.length - 1; i++) {
      final right = clusters[i]
          .map((w) => w.x + w.width)
          .reduce((a, b) => a > b ? a : b);
      final leftNext = clusters[i + 1].first.x;
      bounds.add((right + leftNext) / 2);
    }
    final lastRight = clusters.last
        .map((w) => w.x + w.width)
        .reduce((a, b) => a > b ? a : b);
    bounds.add(lastRight + 2);

    return _ColumnLayout._(
      boundaries: bounds,
      columnCount: clusters.length,
    );
  }

  static List<List<PositionedWord>> _clusterWords(
    List<PositionedWord> words, {
    required double gapThreshold,
  }) {
    if (words.isEmpty) return const [];
    final sorted = [...words]..sort((a, b) => a.x.compareTo(b.x));
    final clusters = <List<PositionedWord>>[];
    var cluster = <PositionedWord>[sorted.first];
    for (var i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final cur = sorted[i];
      final gap = cur.x - (prev.x + prev.width);
      if (gap > gapThreshold) {
        clusters.add(cluster);
        cluster = [cur];
      } else {
        cluster.add(cur);
      }
    }
    clusters.add(cluster);
    return clusters;
  }

  List<String> assign(List<PositionedWord> words) {
    final cells = List<String>.filled(columnCount, '');
    final sorted = [...words]..sort((a, b) => a.x.compareTo(b.x));
    for (final w in sorted) {
      final col = _columnForX(w.centerX);
      if (col < 0 || col >= columnCount) continue;
      final t = w.text.trim();
      if (t.isEmpty) continue;
      cells[col] = cells[col].isEmpty ? t : '${cells[col]} $t';
    }
    return cells;
  }

  int _columnForX(double x) {
    for (var i = 0; i < boundaries.length - 1; i++) {
      if (x >= boundaries[i] && x < boundaries[i + 1]) return i;
    }
    return boundaries.length - 2;
  }
}

class _TextLine {
  const _TextLine({
    required this.pageIndex,
    required this.y,
    required this.words,
  });

  final int pageIndex;
  final double y;
  final List<PositionedWord> words;
}

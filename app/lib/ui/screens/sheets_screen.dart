import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/database.dart';
import '../../insights/insights.dart';

/// List of calculator sheets.
class SheetsScreen extends StatefulWidget {
  const SheetsScreen({super.key, required this.database, this.now});

  final ArthDatabase database;
  final DateTime? now;

  @override
  State<SheetsScreen> createState() => _SheetsScreenState();
}

class _SheetsScreenState extends State<SheetsScreen> {
  late final _repo = SheetRepository(widget.database);
  List<Sheet>? _sheets;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.list();
    if (mounted) setState(() => _sheets = s);
  }

  Future<void> _open(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SheetEditorScreen(
          database: widget.database,
          sheetId: id,
          now: widget.now,
        ),
      ),
    );
    await _load();
  }

  Future<void> _new({bool example = false}) async {
    final id = await _repo.create(
      title: example ? 'Example' : 'Untitled',
      body: example ? kExampleSheet : '',
    );
    await _open(id);
  }

  @override
  Widget build(BuildContext context) {
    final sheets = _sheets;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sheets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _new(),
        icon: const Icon(Icons.add),
        label: const Text('New sheet'),
      ),
      body: sheets == null
          ? const Center(child: CircularProgressIndicator())
          : sheets.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A notepad that calculates as you type: '
                    '"rent = 25k", "20% of 60L", "emi(48L, 8.5, 20)", '
                    'or your own numbers like networth and '
                    'spend("groceries").',
                    style: t.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _new(example: true),
                    child: const Text('Open an example'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final s in sheets)
                  ListTile(
                    title: Text(s.title),
                    subtitle: Text(
                      s.body
                          .split('\n')
                          .firstWhere(
                            (l) => l.trim().isNotEmpty,
                            orElse: () => 'Empty',
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _open(s.id),
                  ),
              ],
            ),
    );
  }
}

/// Styles heading (#) lines bold and comment (//) lines muted.
class _SheetController extends TextEditingController {
  _SheetController(String text, this.muted) : super(text: text);
  final Color muted;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final lines = text.split('\n');
    return TextSpan(
      style: style,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          TextSpan(
            text: lines[i],
            style: lines[i].trimLeft().startsWith('#')
                ? const TextStyle(fontWeight: FontWeight.w700)
                : lines[i].trimLeft().startsWith('//')
                ? TextStyle(color: muted)
                : null,
          ),
          if (i < lines.length - 1) const TextSpan(text: '\n'),
        ],
      ],
    );
  }
}

class SheetEditorScreen extends StatefulWidget {
  const SheetEditorScreen({
    super.key,
    required this.database,
    required this.sheetId,
    this.now,
  });

  final ArthDatabase database;
  final int sheetId;
  final DateTime? now;

  @override
  State<SheetEditorScreen> createState() => _SheetEditorScreenState();
}

class _SheetEditorScreenState extends State<SheetEditorScreen> {
  late final _repo = SheetRepository(widget.database);
  _SheetController? _c;
  String _title = '';
  SheetData _data = const SheetData();
  List<SheetLine> _results = const [];
  Timer? _saveTimer;

  static const _fontSize = 16.0;
  static const _lineHeight = 1.5;
  static const _style = TextStyle(
    fontSize: _fontSize,
    height: _lineHeight,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const _strut = StrutStyle(
    fontSize: _fontSize,
    height: _lineHeight,
    forceStrutHeight: true,
  );
  static const _resultsWidth = 132.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.get(widget.sheetId);
    final data = await _repo.data(widget.now ?? DateTime.now());
    if (!mounted || s == null) return;
    final c = _SheetController(s.body, Theme.of(context).colorScheme.outline)
      ..addListener(_changed);
    setState(() {
      _title = s.title;
      _data = data;
      _c = c;
      _results = const SheetEvaluator().evaluate(s.body, data: data);
    });
  }

  void _changed() {
    setState(() {
      _results = const SheetEvaluator().evaluate(_c!.text, data: _data);
    });
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<void> _save() =>
      _repo.save(widget.sheetId, title: _title, body: _c?.text ?? '');

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_c != null) {
      _save();
      _c!.dispose();
    }
    super.dispose();
  }

  Future<void> _rename() async {
    final ctl = TextEditingController(text: _title);
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename sheet'),
        content: TextField(controller: ctl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctl.dispose();
    if (r == null || r.isEmpty) return;
    setState(() => _title = r);
    await _save();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$_title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _saveTimer?.cancel();
    await _repo.delete(widget.sheetId);
    _c?.removeListener(_changed);
    _c?.dispose();
    _c = null;
    if (mounted) Navigator.of(context).pop();
  }

  /// The editor's text style: theme font + fixed size / line height, so the
  /// measured line heights match what the text field draws.
  TextStyle _effectiveStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.merge(_style);

  /// Height of each logical line once wrapped at [width].
  List<double> _lineHeights(BuildContext context, double width) {
    final style = _effectiveStyle(context);
    final scaler = MediaQuery.textScalerOf(context);
    return [
      for (final l in _c!.text.split('\n'))
        (TextPainter(
          text: TextSpan(text: l.isEmpty ? ' ' : l, style: style),
          strutStyle: _strut,
          textScaler: scaler,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: width))
            .height,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(onTap: _rename, child: Text(_title)),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const _HelpSheet(),
            ),
          ),
          IconButton(
            tooltip: 'Rename',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _rename,
          ),
          IconButton(
            tooltip: 'Delete sheet',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: c == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, box) {
                const pad = 16.0;
                final textWidth = box.maxWidth - pad * 2 - _resultsWidth - 8;
                final heights = _lineHeights(context, textWidth);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(pad),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: textWidth,
                        child: TextField(
                          controller: c,
                          maxLines: null,
                          style: _effectiveStyle(context),
                          strutStyle: _strut,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'rent = 25k',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: _resultsWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var i = 0; i < heights.length; i++)
                              SizedBox(
                                height: heights[i],
                                child: i < _results.length
                                    ? _Result(line: _results[i], scheme: scheme)
                                    : null,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.line, required this.scheme});
  final SheetLine line;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final l = line;
    if (l.kind == SheetLineKind.error) {
      return Align(
        alignment: Alignment.topRight,
        child: Tooltip(
          message: l.error ?? 'error',
          triggerMode: TooltipTriggerMode.tap,
          child: Icon(Icons.error_outline, size: 18, color: scheme.error),
        ),
      );
    }
    if (l.kind != SheetLineKind.value) return const SizedBox.shrink();
    final text = formatSheetNumber(l.value!);
    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: text.replaceAll(',', '')));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Copied $text')));
        },
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: _SheetEditorScreenState._style.copyWith(
            color: l.name != null ? scheme.primary : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          strutStyle: _SheetEditorScreenState._strut,
        ),
      ),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const rows = <(String, String)>[
      ('rent = 25k', 'name a value; use it on later lines'),
      ('20% of price', 'percentages'),
      ('60L, 1.5cr, 40,00,000', 'Indian units and grouping'),
      ('sum  /  total', 'adds the lines above (until a blank line or #)'),
      ('# Heading   // note', 'headings and comments'),
      ('emi(48L, 8.5, 20)', 'monthly EMI: amount, rate %, years'),
      ('sip(10k, 12, 15)', 'monthly SIP value after years at rate %'),
      ('fv(5L, 7, 10)  pv(…)', 'lump sum growth / today\'s value'),
      ('round(x, 2)  min  max  abs  sqrt', 'helpers'),
      ('networth  investments  cash', 'your current numbers'),
      ('spend("groceries")', 'this month; spend("all", 1) = last month'),
      ('income(1)', 'last month\'s income'),
      ('avg_spend("food delivery", 6)', 'average of the last 6 months'),
    ];
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text('Sheet basics', style: t.titleMedium),
        const SizedBox(height: 8),
        for (final (code, what) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: t.bodyMedium?.copyWith(fontFamily: 'monospace'),
                ),
                Text(what, style: t.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

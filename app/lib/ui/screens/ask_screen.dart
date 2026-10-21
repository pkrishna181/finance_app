import 'package:flutter/material.dart';

import '../../ask/ask.dart';
import '../../core/db/database.dart';
import '../../core/result/result.dart';
import '../../insights/insight_format.dart';
import '../../llm/jobs/llm_batch_coordinator.dart';
import 'ai_model_screen.dart';
import 'search_screen.dart';

const kAskSuggestions = [
  'How much did I spend last month?',
  'Top categories this month',
  'Food in the last 3 months',
  'Top merchants this financial year',
  "What's my net worth?",
  'How are my budgets?',
  "What's due in the next 2 weeks?",
  'How much did I save this financial year?',
];

/// Questions about your money, answered on the device (Phase 12).
///
/// The rule-based [AskParser] reads most questions instantly; anything it
/// can't read goes to the on-device model, which only picks an [AskQuery].
/// Every number comes from [AskAnswerer].
class AskScreen extends StatefulWidget {
  const AskScreen({super.key, this.database, this.coordinator, this.now});

  final ArthDatabase? database;

  /// Owns the on-device model; null disables the model fallback.
  final LlmBatchCoordinator? coordinator;

  /// Clock override for tests.
  final DateTime Function()? now;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

enum _Problem { notUnderstood, noModel, modelFailed, busy, failed }

class _Exchange {
  _Exchange(this.question);

  final String question;
  AskAnswer? answer;
  bool reading = false;
  bool fromModel = false;
  _Problem? problem;
  List<String> unknownWords = const [];

  /// Words the model's reading didn't use (shown with its answer).
  List<String> ignoredWords = const [];
}

class _AskScreenState extends State<AskScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _exchanges = <_Exchange>[];
  bool _busy = false;

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _ask(String text) async {
    final db = widget.database;
    final question = text.trim();
    if (db == null || question.isEmpty || _busy) return;
    final ex = _Exchange(question);
    setState(() {
      _busy = true;
      _exchanges.add(ex);
      _input.clear();
    });
    _scrollToEnd();
    try {
      await _resolve(db, ex);
    } catch (e) {
      // Without this the card would spin forever.
      debugPrint('Ask failed: $e');
      ex.problem = _Problem.failed;
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollToEnd();
    }
  }

  Future<void> _resolve(ArthDatabase db, _Exchange ex) async {
    final answerer = AskAnswerer(db);
    final now = _now;
    // Fresh each time: imports add merchants.
    final vocab = await answerer.vocabulary();
    final parsed = AskParser(vocab).parse(ex.question, now);
    if (parsed.query != null) {
      ex.answer = await answerer.answer(parsed.query!, now);
      return;
    }
    ex.unknownWords = parsed.unknownWords;

    final coordinator = widget.coordinator;
    if (coordinator == null) {
      ex.problem = _Problem.notUnderstood;
      return;
    }
    if (mounted) setState(() => ex.reading = true);
    try {
      final notReady = await coordinator.ensureEngineLoaded();
      if (notReady != null) {
        ex.problem = notReady == 'model_not_downloaded'
            ? _Problem.noModel
            : _Problem.modelFailed;
        return;
      }
      final read = await AskModelReader(
        coordinator.engine,
      ).read(ex.question, parsed.partial!, vocab, now);
      switch (read) {
        case Ok(:final value):
          ex.fromModel = true;
          ex.ignoredWords = parsed.partial!.ignoredWords;
          ex.answer = await answerer.answer(value, now);
        case Err(:final message):
          ex.problem = message == 'model_busy'
              ? _Problem.busy
              : _Problem.notUnderstood;
      }
    } finally {
      ex.reading = false;
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _openSearch(String query) {
    final db = widget.database;
    if (db == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(database: db, initialQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask'),
        actions: [
          if (_exchanges.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _busy ? null : () => setState(_exchanges.clear),
            ),
        ],
      ),
      body: widget.database == null
          ? const Center(child: Text('Opening your data…'))
          : Column(
              children: [
                Expanded(
                  child: _exchanges.isEmpty
                      ? _Intro(onPick: _ask)
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _exchanges.length,
                          itemBuilder: (context, i) => _ExchangeView(
                            ex: _exchanges[i],
                            onSearch: _openSearch,
                            onPick: _ask,
                          ),
                        ),
                ),
                _InputBar(controller: _input, enabled: !_busy, onSend: _ask),
              ],
            ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ask about your money', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Answers are worked out on this phone from your own transactions, '
          'with the same numbers as Insights. Nothing leaves the device.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text('Try', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _Suggestions(onPick: onPick),
      ],
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onPick, this.limit});

  final ValueChanged<String> onPick;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in kAskSuggestions.take(limit ?? kAskSuggestions.length))
          ActionChip(label: Text(s), onPressed: () => onPick(s)),
      ],
    );
  }
}

class _ExchangeView extends StatelessWidget {
  const _ExchangeView({
    required this.ex,
    required this.onSearch,
    required this.onPick,
  });

  final _Exchange ex;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.only(left: 48, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ex.question,
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: _body(context),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    if (ex.reading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 10),
          Text(
            'Reading your question with the on-device model… '
            'this can take 10–20 seconds.',
            style: muted,
          ),
        ],
      );
    }
    final a = ex.answer;
    if (a != null) {
      return _AnswerView(
        answer: a,
        fromModel: ex.fromModel,
        ignoredWords: ex.ignoredWords,
        onSearch: onSearch,
      );
    }
    if (ex.problem == null) {
      return const Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final unknown = ex.unknownWords.isEmpty
        ? ''
        : ' (I didn\'t recognise "${ex.unknownWords.join(' ')}")';
    final message = switch (ex.problem!) {
      _Problem.notUnderstood =>
        'Sorry, I couldn\'t work that question out$unknown. '
            'Try naming a category, a shop or a time, like these:',
      _Problem.noModel =>
        'I couldn\'t work that question out$unknown. Download the on-device '
            'AI model to ask in your own words, or try one of these:',
      _Problem.modelFailed =>
        'The on-device model couldn\'t start on this phone. '
            'Try one of these instead:',
      _Problem.busy =>
        'The on-device model is busy sorting new transactions. '
            'Try again in a minute, or use one of these:',
      _Problem.failed =>
        'Something went wrong reading your data. Try again, or one of these:',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        if (ex.problem == _Problem.noModel)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download_outlined),
              label: const Text('On-device AI model'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AiModelScreen()),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _Suggestions(onPick: onPick, limit: 4),
      ],
    );
  }
}

class _AnswerView extends StatelessWidget {
  const _AnswerView({
    required this.answer,
    required this.fromModel,
    required this.onSearch,
    this.ignoredWords = const [],
  });

  final AskAnswer answer;
  final bool fromModel;
  final List<String> ignoredWords;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final a = answer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              fromModel ? Icons.memory_outlined : Icons.manage_search,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                fromModel
                    ? 'Read by the on-device model as: ${a.understoodAs}'
                    : a.understoodAs,
                style: muted,
              ),
            ),
          ],
        ),
        if (ignoredWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text('Ignored: ${ignoredWords.join(' ')}', style: muted),
          ),
        const SizedBox(height: 8),
        Text(a.headline, style: theme.textTheme.titleMedium),
        if (a.rows.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final r in a.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.label),
                        if (r.detail != null) Text(r.detail!, style: muted),
                      ],
                    ),
                  ),
                  if (r.paise != null)
                    Text(
                      inrWhole(r.paise!),
                      style: TextStyle(
                        color: r.flagged ? scheme.error : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
            ),
        ],
        if (a.transactions.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final t in a.transactions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.merchantLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(longDate(t.bookedAt), style: muted),
                      ],
                    ),
                  ),
                  Text(
                    '${t.isDebit ? '-' : '+'}${inrWhole(t.amountPaise)}',
                    style: TextStyle(
                      color: t.isDebit ? scheme.error : scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (a.note != null && a.note!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(a.note!, style: muted),
        ],
        if (a.searchQuery != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('See transactions'),
              onPressed: () => onSearch(a.searchQuery!),
            ),
          ),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Ask about your spending…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: onSend,
              ),
            ),
            IconButton(
              tooltip: 'Ask',
              icon: const Icon(Icons.send),
              onPressed: enabled ? () => onSend(controller.text) : null,
            ),
          ],
        ),
      ),
    );
  }
}

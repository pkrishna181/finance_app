import '../insights/insight_models.dart';
import '../insights/yearly.dart';
import 'ask_query.dart';

/// Words the parser can map to categories and merchants. Built from the
/// database so renamed categories and the user's own merchants are known.
class AskVocabulary {
  const AskVocabulary({required this.categoryNames, this.merchants = const []});

  /// slug → display name.
  final Map<String, String> categoryNames;

  /// Lowercased merchant labels seen in the ledger.
  final List<String> merchants;
}

/// Everyday words for the default categories (the display names and slugs
/// are always recognised too).
const kCategorySynonyms = <String, List<String>>{
  'groceries': ['grocery', 'kirana', 'vegetables', 'veggies'],
  'food_delivery': [
    'food',
    'eating out',
    'restaurants',
    'restaurant',
    'dining',
    'takeout',
    'takeaway',
    'food orders',
  ],
  'transport': ['travel', 'cab', 'cabs', 'taxi', 'commute', 'metro', 'auto'],
  'fuel': ['petrol', 'diesel'],
  'utilities': ['electricity', 'water bill', 'broadband', 'internet', 'gas'],
  'emi': ['emis', 'loan emi', 'loan emis'],
  'investments_sip': [
    'investments',
    'investment',
    'sip',
    'sips',
    'mutual funds',
  ],
  'recharge': ['recharges', 'mobile recharge', 'phone recharge'],
  'healthcare': [
    'health',
    'medical',
    'medicine',
    'medicines',
    'doctor',
    'pharmacy',
    'hospital',
  ],
  'entertainment': ['movies', 'ott', 'streaming'],
  'charges': ['bank charges', 'fees', 'bank fees'],
};

class AskParseResult {
  const AskParseResult(this.query, {this.unknownWords = const []});

  /// Null when the question wasn't understood.
  final AskQuery? query;

  /// Words that matched nothing (why [query] is null).
  final List<String> unknownWords;
}

/// Rule-based question → [AskQuery]. Pure and instant; handles the common
/// phrasings so the on-device model is only needed for unusual wording.
///
/// Strict on purpose: a leftover word that isn't filler, a category or a
/// known merchant makes the parse fail rather than guess.
class AskParser {
  AskParser(this.vocab) : _categoryPhrases = _buildCategoryPhrases(vocab);

  final AskVocabulary vocab;

  /// phrase → slug, longest phrase first.
  final List<(String, String)> _categoryPhrases;

  static List<(String, String)> _buildCategoryPhrases(AskVocabulary v) {
    final out = <String, String>{};
    for (final e in v.categoryNames.entries) {
      if (e.key == kUncategorizedSlug) continue;
      out[_normalize(e.value)] = e.key;
      out[e.key.replaceAll('_', ' ')] = e.key;
      for (final s in kCategorySynonyms[e.key] ?? const <String>[]) {
        out.putIfAbsent(s, () => e.key);
      }
    }
    out['uncategorized'] = kUncategorizedSlug;
    out['uncategorised'] = kUncategorizedSlug;
    final list = [for (final e in out.entries) (e.key, e.value)]
      ..sort((a, b) => b.$1.length.compareTo(a.$1.length));
    return list;
  }

  /// Lowercase, keep letters/digits/hyphens, single spaces.
  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"[’'`]"), '')
      .replaceAll(RegExp(r'[^a-z0-9\- ]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  AskParseResult parse(String question, DateTime now) {
    var text = ' ${_normalize(question)} '.replaceAll(
      RegExp(r' top \d{1,2} '),
      ' top ',
    );
    if (text.trim().isEmpty) return const AskParseResult(null);

    final intent = _intent(text);

    // "last 3 months" for an average is a month count, not a date range.
    var months = 6;
    if (intent == AskIntent.average) {
      final m = RegExp(
        r' (?:last|past|previous) (\d{1,2}) months? ',
      ).firstMatch(text);
      if (m != null) {
        months = int.parse(m[1]!).clamp(1, 24);
        text = text.replaceRange(m.start, m.end, ' ');
      }
    }
    var days = 30;
    if (intent == AskIntent.upcoming) {
      final m = RegExp(
        r' (?:next|coming) (\d{1,3}) (days?|weeks?) ',
      ).firstMatch(text);
      if (m != null) {
        final n = int.parse(m[1]!);
        days = (m[2]!.startsWith('week') ? n * 7 : n).clamp(1, 90);
        text = text.replaceRange(m.start, m.end, ' ');
      } else if (text.contains(' next week ') || text.contains(' this week ')) {
        days = 7;
        text = text.replaceAll(RegExp(r' (?:next|this) week '), ' ');
      }
    }

    final (period, rest) = _period(text, now);
    text = rest;

    String? category;
    for (final (phrase, slug) in _categoryPhrases) {
      final at = text.indexOf(' $phrase ');
      if (at >= 0) {
        category = slug;
        text = text.replaceRange(at, at + phrase.length + 2, ' ');
        break;
      }
    }

    final words = [
      for (final w in text.trim().split(' '))
        if (w.isNotEmpty) w,
    ];
    final leftover = [
      for (final w in words)
        if (!_filler.contains(w)) w,
    ];
    String? merchant;
    if (leftover.isNotEmpty) {
      merchant = _matchMerchant(words);
      if (merchant == null) {
        return AskParseResult(null, unknownWords: leftover);
      }
    }

    var finalIntent = intent;
    // "salary in September" is income, not spend.
    if (finalIntent == AskIntent.spend &&
        category != null &&
        kIncomeSlugs.contains(category) &&
        !_mentionsSpend(question)) {
      finalIntent = AskIntent.income;
    }
    if (finalIntent == AskIntent.lastPaid &&
        category == null &&
        merchant == null) {
      return AskParseResult(null, unknownWords: leftover);
    }

    return AskParseResult(
      AskQuery(
        intent: finalIntent,
        period: finalIntent.usesPeriod
            ? period ?? AskPeriod.month(MonthKey.of(now), now: now)
            : null,
        categorySlug: category,
        merchant: merchant,
        months: months,
        days: days,
      ),
    );
  }

  static bool _mentionsSpend(String q) => RegExp(
    r'\b(spen[dt]|spending|paid|pay|expenses?)\b',
  ).hasMatch(q.toLowerCase());

  static bool _has(String text, List<String> phrases) =>
      phrases.any((p) => text.contains(' $p '));

  static AskIntent _intent(String t) {
    if (_has(t, ['net worth', 'networth', 'worth'])) return AskIntent.netWorth;
    if (_has(t, ['budget', 'budgets'])) return AskIntent.budgets;
    if (_has(t, [
      'upcoming',
      'due',
      'coming up',
      'next payments',
      'next payment',
      'bills next',
      'have to pay',
    ])) {
      return AskIntent.upcoming;
    }
    if (_has(t, ['when'])) return AskIntent.lastPaid;
    if (_has(t, ['average', 'avg', 'typically', 'usually', 'per month'])) {
      return AskIntent.average;
    }
    if (_has(t, [
      'biggest',
      'largest',
      'most expensive',
      'highest',
      'big expenses',
      'big purchases',
    ])) {
      return AskIntent.largest;
    }
    if (_has(t, [
      'merchants',
      'merchant',
      'shops',
      'stores',
      'payees',
      'who did i pay',
      'where did i spend',
      'where do i spend',
    ])) {
      return AskIntent.topMerchants;
    }
    if (_has(t, [
      'categories',
      'category',
      'breakdown',
      'where did my money go',
      'where does my money go',
      'where did the money go',
      'what did i spend on',
      'what do i spend on',
    ])) {
      return AskIntent.topCategories;
    }
    if (_has(t, [
      'save',
      'saved',
      'saving',
      'savings',
      'cash flow',
      'cashflow',
    ])) {
      return AskIntent.savings;
    }
    if (_has(t, [
      'income',
      'earn',
      'earned',
      'earning',
      'earnings',
      'received',
      'credited',
      'got paid',
    ])) {
      return AskIntent.income;
    }
    return AskIntent.spend;
  }

  static const _months = <String, int>{
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  static final _monthRe = RegExp(
    ' (?:(since|from) )?(${_months.keys.join('|')}) '
    r'(?:(\d{4}|last year|this year) )?',
  );

  static int _fullYear(String y) {
    final n = int.parse(y);
    return y.length == 2 ? 2000 + n : n;
  }

  /// Finds one date phrase, returns it and the text with it removed.
  static (AskPeriod?, String) _period(String t, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = MonthKey.of(now);
    (AskPeriod?, String) cut(Match m, AskPeriod p) =>
        (p, t.replaceRange(m.start, m.end, ' '));

    final rel = RegExp(
      r' (?:last|past|previous) (\d{1,3}) (days?|weeks?|months?) ',
    ).firstMatch(t);
    if (rel != null) {
      final n = int.parse(rel[1]!).clamp(1, 730);
      final unit = rel[2]!;
      if (unit.startsWith('day')) return cut(rel, AskPeriod.lastDays(n, now));
      if (unit.startsWith('week')) {
        return cut(rel, AskPeriod.lastDays(n * 7, now));
      }
      return cut(rel, AskPeriod.lastMonths(n, now));
    }

    final simple = <String, AskPeriod Function()>{
      'all time': () => AskPeriod.allTime(now),
      'ever': () => AskPeriod.allTime(now),
      'today': () =>
          AskPeriod(today, today.add(const Duration(days: 1)), 'today'),
      'yesterday': () => AskPeriod(
        today.subtract(const Duration(days: 1)),
        today,
        'yesterday',
      ),
      'this week': () {
        final monday = today.subtract(Duration(days: today.weekday - 1));
        return AskPeriod(
          monday,
          monday.add(const Duration(days: 7)),
          'this week',
        );
      },
      'last week': () {
        final monday = today.subtract(Duration(days: today.weekday + 6));
        return AskPeriod(
          monday,
          monday.add(const Duration(days: 7)),
          'last week (${shortDate(monday)} – '
          '${shortDate(monday.add(const Duration(days: 6)))})',
        );
      },
      'this month': () => AskPeriod.month(thisMonth, now: now),
      'current month': () => AskPeriod.month(thisMonth, now: now),
      'last month': () => AskPeriod.month(thisMonth.plusMonths(-1)),
      'previous month': () => AskPeriod.month(thisMonth.plusMonths(-1)),
      'this financial year': () =>
          AskPeriod.financialYear(FinancialYear.of(now), now: now),
      'this fy': () => AskPeriod.financialYear(FinancialYear.of(now), now: now),
      'last financial year': () =>
          AskPeriod.financialYear(FinancialYear.of(now).previous),
      'last fy': () => AskPeriod.financialYear(FinancialYear.of(now).previous),
      'previous financial year': () =>
          AskPeriod.financialYear(FinancialYear.of(now).previous),
    };
    for (final e in simple.entries) {
      final at = t.indexOf(' ${e.key} ');
      if (at >= 0) {
        return (e.value(), t.replaceRange(at, at + e.key.length + 2, ' '));
      }
    }

    final fy = RegExp(r' fy ?(\d{2}|\d{4})(?:-(\d{2}|\d{4}))? ').firstMatch(t);
    if (fy != null) {
      var start = _fullYear(fy[1]!);
      // "FY 2027" usually means the year ending March 2027.
      if (fy[2] == null) start -= 1;
      return cut(fy, AskPeriod.financialYear(FinancialYear(start), now: now));
    }

    final mo = _monthRe.firstMatch(t);
    if (mo != null) {
      final month = _months[mo[2]!]!;
      final y = mo[3];
      int year;
      if (y == null) {
        // A month without a year is the most recent one (not the future).
        year = month > now.month ? now.year - 1 : now.year;
      } else if (y == 'last year') {
        year = now.year - 1;
      } else if (y == 'this year') {
        year = now.year;
      } else {
        year = int.parse(y);
      }
      final key = MonthKey(year, month);
      if (mo[1] != null) {
        return cut(
          mo,
          AskPeriod(
            key.start,
            today.add(const Duration(days: 1)),
            'since ${shortDate(key.start)} ${key.year}',
          ),
        );
      }
      return cut(mo, AskPeriod.month(key, now: now));
    }

    for (final e in {
      'this year': () => AskPeriod.calendarYear(now.year, now: now),
      'last year': () => AskPeriod.calendarYear(now.year - 1),
    }.entries) {
      final at = t.indexOf(' ${e.key} ');
      if (at >= 0) {
        return (e.value(), t.replaceRange(at, at + e.key.length + 2, ' '));
      }
    }

    final year = RegExp(r' (20\d{2}) ').firstMatch(t);
    if (year != null) {
      return cut(year, AskPeriod.calendarYear(int.parse(year[1]!), now: now));
    }
    return (null, t);
  }

  /// A merchant name containing every non-filler word of [words], widened
  /// by up to two neighbouring words ("amazon pay"), longest first. Null if
  /// no merchant contains them all.
  String? _matchMerchant(List<String> words) {
    final content = [
      for (var i = 0; i < words.length; i++)
        if (!_filler.contains(words[i])) i,
    ];
    final first = content.first;
    final last = content.last;
    final spans = <(int, int)>[
      for (var a = first; a >= 0 && a >= first - 2; a--)
        for (var b = last; b < words.length && b <= last + 2; b++) (a, b),
    ]..sort((x, y) => (y.$2 - y.$1).compareTo(x.$2 - x.$1));
    for (final (a, b) in spans) {
      final phrase = words.sublist(a, b + 1).join(' ');
      if (phrase.length < 3) continue;
      if (vocab.merchants.any((m) => m.contains(phrase))) return phrase;
    }
    return null;
  }

  static const _filler = <String>{
    'lot',
    'lots',
    'ride',
    'rides',
    'trip',
    'trips',
    'bookings',
    'booking',
    'a',
    'about',
    'all',
    'am',
    'amount',
    'an',
    'and',
    'any',
    'are',
    'at',
    'average',
    'avg',
    'be',
    'been',
    'big',
    'biggest',
    'bill',
    'bills',
    'bought',
    'breakdown',
    'budget',
    'budgets',
    'buy',
    'by',
    'can',
    'cash',
    'categories',
    'category',
    'coming',
    'compare',
    'compared',
    'cost',
    'costs',
    'could',
    'cr',
    'credited',
    'current',
    'currently',
    'date',
    'day',
    'days',
    'did',
    'do',
    'does',
    'doing',
    'due',
    'earn',
    'earned',
    'earning',
    'earnings',
    'entire',
    'expense',
    'expenses',
    'expensive',
    'far',
    'find',
    'flow',
    'for',
    'from',
    'get',
    'give',
    'go',
    'goes',
    'gone',
    'got',
    'had',
    'has',
    'have',
    'highest',
    'how',
    'i',
    'im',
    'in',
    'income',
    'inr',
    'into',
    'is',
    'it',
    'its',
    'ive',
    'just',
    'k',
    'lakh',
    'largest',
    'last',
    'lately',
    'left',
    'less',
    'list',
    'made',
    'make',
    'many',
    'me',
    'merchant',
    'merchants',
    'money',
    'month',
    'monthly',
    'months',
    'more',
    'most',
    'much',
    'my',
    'net',
    'networth',
    'next',
    'now',
    'of',
    'on',
    'only',
    'or',
    'order',
    'ordered',
    'orders',
    'out',
    'over',
    'overall',
    'paid',
    'past',
    'pay',
    'payees',
    'paying',
    'payment',
    'payments',
    'per',
    'please',
    'previous',
    'purchase',
    'purchases',
    'received',
    'recent',
    'recently',
    'remaining',
    'right',
    'rs',
    'rupees',
    'save',
    'saved',
    'saving',
    'savings',
    'see',
    'shops',
    'show',
    'so',
    'spend',
    'spending',
    'spends',
    'spent',
    'status',
    'stores',
    'sum',
    'tell',
    'than',
    'that',
    'the',
    'there',
    'this',
    'till',
    'time',
    'times',
    'to',
    'top',
    'total',
    'totals',
    'track',
    'transaction',
    'transactions',
    'typical',
    'typically',
    'until',
    'up',
    'upcoming',
    'use',
    'used',
    'usually',
    'value',
    'was',
    'we',
    'week',
    'went',
    'were',
    'what',
    'whats',
    'when',
    'where',
    'which',
    'who',
    'whole',
    'with',
    'worth',
    'year',
    'you',
  };
}

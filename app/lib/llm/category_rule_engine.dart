import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/db/database.dart';
import '../core/models/transaction_type.dart';

class CategoryRuleMatch {
  const CategoryRuleMatch({
    required this.slug,
    required this.source,
    this.confidence = 1.0,
  });

  final String slug;
  final String source;
  final double confidence;
}

/// Deterministic categorization: user corrections > merchant map > keywords.
class CategoryRuleEngine {
  CategoryRuleEngine({
    required this.merchantMap,
    required this.keywordRules,
  });

  final Map<String, String> merchantMap;
  final List<KeywordCategoryRule> keywordRules;

  static CategoryRuleEngine? _cached;

  static Future<CategoryRuleEngine> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('lib/llm/data/category_rules.json');
    final json = Map<String, Object?>.from(jsonDecode(raw) as Map);
    final merchantRaw = Map<String, Object?>.from(json['merchant_categories'] as Map);
    final keywordRaw = (json['keyword_rules'] as List<Object?>)
        .map((e) => KeywordCategoryRule.fromJson(Map<String, Object?>.from(e as Map)))
        .toList();
    _cached = CategoryRuleEngine(
      merchantMap: merchantRaw.map((k, v) => MapEntry(k, v as String)),
      keywordRules: keywordRaw,
    );
    return _cached!;
  }

  Future<CategoryRuleMatch?> resolve({
    required ArthDatabase db,
    required String rawMerchant,
    required String narration,
    required TransactionDirection direction,
    int? transactionId,
  }) async {
    if (transactionId != null) {
      final corrections = await (db.select(db.userCorrections)
            ..where((t) => t.transactionId.equals(transactionId))
            ..where((t) => t.field.equals('category')))
          .get();
      if (corrections.isNotEmpty) {
        return CategoryRuleMatch(
          slug: corrections.last.newValue,
          source: 'user_correction',
        );
      }
    }

    for (final entry in merchantMap.entries) {
      if (rawMerchant.toLowerCase().contains(entry.key.toLowerCase())) {
        return CategoryRuleMatch(slug: entry.value, source: 'merchant_map');
      }
    }

    final blob = '$rawMerchant $narration'.toLowerCase();
    for (final rule in keywordRules) {
      if (rule.direction != null && rule.direction != direction.name) continue;
      if (blob.contains(rule.pattern)) {
        return CategoryRuleMatch(slug: rule.category, source: 'keyword_rule');
      }
    }
    return null;
  }
}

class KeywordCategoryRule {
  const KeywordCategoryRule({
    required this.pattern,
    required this.category,
    this.direction,
  });

  final String pattern;
  final String category;
  final String? direction;

  factory KeywordCategoryRule.fromJson(Map<String, Object?> json) {
    return KeywordCategoryRule(
      pattern: json['pattern'] as String,
      category: json['category'] as String,
      direction: json['direction'] as String?,
    );
  }
}

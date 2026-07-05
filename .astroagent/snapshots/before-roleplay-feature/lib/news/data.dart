// lib/news/data.dart

import 'package:flutter/foundation.dart';

/// Represents a single, immutable news article.
///
/// This class is a pure data model, meaning it contains no business logic
/// or dependencies on the Flutter framework. Its sole responsibility is to
/// represent the structure of a news article.
@immutable
class NewsArticle {
  final String id;
  final Map<String, String> title;
  final Map<String, String> summary;
  final Map<String, String> content;
  final String? link;
  final Map<String, String>? coverImagePaths;
  final DateTime publishedAt;

  /// Creates a new instance of a [NewsArticle].
  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.link,
    this.coverImagePaths,
    required this.publishedAt,
  });

  /// Checks if the article has the minimum required data to be displayed.
  /// An article is considered valid if it has a title and summary in at least English.
  bool get isValid {
    final hasEnglishTitle = title['en'] != null &&
        title['en']!.trim().isNotEmpty;
    final hasEnglishSummary = summary['en'] != null &&
        summary['en']!.trim().isNotEmpty;

    return hasEnglishTitle && hasEnglishSummary;
  }

  /// A factory constructor to create a [NewsArticle] instance from a JSON map.
  ///
  /// This method safely parses the JSON, providing default values for missing
  /// or malformed fields to prevent runtime errors.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // Gracefully handle the case where 'translations' might be null.
    final translations = json['translations'] as Map<String, dynamic>? ?? {};
    final Map<String, String> titleMap = {};
    final Map<String, String> summaryMap = {};
    final Map<String, String> contentMap = {};

    for (final entry in translations.entries) {
      final langCode = entry.key;
      final translationData = entry.value;
      if (translationData is Map<String, dynamic>) {
        titleMap[langCode] = translationData['title'] as String? ?? '';
        summaryMap[langCode] = translationData['summary'] as String? ?? '';
        contentMap[langCode] = translationData['content'] as String? ?? '';
      }
    }

    // Safely extract the first link from the references list.
    final references = json['references'] as List<dynamic>?;
    String? link;
    if (references != null && references.isNotEmpty) {
      link = references.first as String?;
    }

    return NewsArticle(
      id: json['id'] as String? ?? 'unknown_id_${DateTime
          .now()
          .millisecondsSinceEpoch}',
      title: titleMap,
      summary: summaryMap,
      content: contentMap,
      link: link,
      coverImagePaths: json['cover'] != null ? Map<String, String>.from(
          json['cover'] as Map) : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
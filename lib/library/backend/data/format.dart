// lib/library/backend/data/format.dart

import 'package:flutter/foundation.dart';

/// Represents the token configuration for a chat model.
@immutable
class ChatTokens {
  final String? systemStart;
  final String? systemEnd;
  final String? userStart;
  final String? userEnd;
  final String? assistantStart;
  final String? assistantEnd;
  final List<String> stopGeneration;
  final String? ignoreRegex;

  const ChatTokens({
    this.systemStart,
    this.systemEnd,
    this.userStart,
    this.userEnd,
    this.assistantStart,
    this.assistantEnd,
    required this.stopGeneration,
    this.ignoreRegex,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory ChatTokens.fromMap(Map<String, dynamic> map) {
    return ChatTokens(
      systemStart: map['system_start'] as String?,
      systemEnd: map['system_end'] as String?,
      userStart: map['user_start'] as String?,
      userEnd: map['user_end'] as String?,
      assistantStart: map['assistant_start'] as String?,
      assistantEnd: map['assistant_end'] as String?,
      stopGeneration: List<String>.from(map['stop_generation'] as List? ?? []),
      ignoreRegex: map['ignore_regex'] as String?,
    );
  }

  /// Converts the instance back to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'system_start': systemStart,
      'system_end': systemEnd,
      'user_start': userStart,
      'user_end': userEnd,
      'assistant_start': assistantStart,
      'assistant_end': assistantEnd,
      'stop_generation': stopGeneration,
      'ignore_regex': ignoreRegex,
    };
  }
}

/// Represents the complete chat format configuration for a model.
@immutable
class ChatFormat {
  final String? template;
  final ChatTokens? tokens;

  const ChatFormat({
    this.template,
    this.tokens,
  });

  /// Factory constructor to create an instance from a JSON map.
  factory ChatFormat.fromMap(Map<String, dynamic> map) {
    return ChatFormat(
      template: map['template'] as String?,
      tokens: map['tokens'] != null
          ? ChatTokens.fromMap(map['tokens'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the instance back to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'template': template,
      'tokens': tokens?.toMap(),
    };
  }
}

/// Formats a name (Producer, Series, or Variant) by replacing dashes with spaces,
/// applying Title Case to words, and capitalizing "ai" or "AI".
String formatName(String? name, {bool isOfflineVariant = false}) {
  if (name == null || name.isEmpty) return "";

  if (isOfflineVariant) {
    String source = name.trim();
    if (source.contains('/')) {
      source = source.split('/').last.trim();
    }

    final words = source
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll('.', ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);

    final formattedWords = <String>[];
    for (final rawWord in words) {
      final lower = rawWord.toLowerCase();
      if (lower == 'gguf') continue;
      if (lower == 'it') {
        formattedWords.add('IT');
        continue;
      }
      if (lower == 'ai') {
        formattedWords.add('AI');
        continue;
      }
      if (lower == 'moe') {
        formattedWords.add('MOE');
        continue;
      }
      if (RegExp(r'[A-Z]').hasMatch(rawWord) &&
          rawWord == rawWord.toUpperCase()) {
        formattedWords.add(rawWord);
        continue;
      }

      final leadingNumberMatch = RegExp(r'^(\d+)([a-z]+)$').firstMatch(lower);
      if (leadingNumberMatch != null) {
        formattedWords.add(
            '${leadingNumberMatch.group(1)}${leadingNumberMatch.group(2)!.toUpperCase()}');
        continue;
      }

      final surroundedNumberMatch =
          RegExp(r'^([a-z]+)(\d+)([a-z]+)$').firstMatch(lower);
      if (surroundedNumberMatch != null) {
        formattedWords.add(
            '${surroundedNumberMatch.group(1)![0].toUpperCase()}${surroundedNumberMatch.group(1)!.substring(1)}${surroundedNumberMatch.group(2)}${surroundedNumberMatch.group(3)!.toUpperCase()}');
        continue;
      }

      final alphaNumericMatch = RegExp(r'^([a-z]+)(\d+)$').firstMatch(lower);
      if (alphaNumericMatch != null) {
        formattedWords.add(
            '${alphaNumericMatch.group(1)![0].toUpperCase()}${alphaNumericMatch.group(1)!.substring(1)}${alphaNumericMatch.group(2)}');
        continue;
      }

      formattedWords.add(lower[0].toUpperCase() + lower.substring(1));
    }

    final mergedNumericWords = <String>[];
    int i = 0;
    while (i < formattedWords.length) {
      final current = formattedWords[i];
      final next =
          (i + 1 < formattedWords.length) ? formattedWords[i + 1] : null;
      final bothPureNumbers = RegExp(r'^\d+$').hasMatch(current) &&
          next != null &&
          RegExp(r'^\d+$').hasMatch(next);

      if (bothPureNumbers) {
        mergedNumericWords.add('$current.$next');
        i += 2;
      } else {
        mergedNumericWords.add(current);
        i++;
      }
    }

    var limitedWords = mergedNumericWords;
    if (limitedWords.length > 4) {
      limitedWords = limitedWords.sublist(0, 4);
    }
    while (limitedWords.isNotEmpty && limitedWords.join(" ").length > 30) {
      limitedWords.removeLast();
    }
    return limitedWords.join(" ").trim();
  }

  final words = name
      .replaceAll('-', ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty);
  final formattedWords = words.map((word) {
    if (word.isEmpty) return word;

    // First apply basic title case (first letter uppercase, rest untouched)
    String w = word[0].toUpperCase() + word.substring(1);

    if (w.toLowerCase() == "ai") return "AI";
    return w;
  });

  String joined = formattedWords.join(" ");
  joined =
      joined.replaceAll(RegExp(r'chatgpt', caseSensitive: false), 'ChatGPT');
  joined =
      joined.replaceAll(RegExp(r'wizardlm', caseSensitive: false), 'WizardLM');
  joined = joined.replaceAll(RegExp(r'llama', caseSensitive: false), 'Llama');
  joined =
      joined.replaceAll(RegExp(r'seedance', caseSensitive: false), 'SeeDance');
  joined =
      joined.replaceAll(RegExp(r'seedream', caseSensitive: false), 'SeeDream');
  joined = joined.replaceAll(
      RegExp(r'bytedance', caseSensitive: false), 'ByteDance');

  return joined.trim();
}

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
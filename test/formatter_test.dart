// test/formatter_test.dart
import 'package:cortex/library/backend/data/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatFormat & ChatTokens Tests', () {
    final Map<String, dynamic> tokenMap = {
      'system_start': '<|system|>',
      'system_end': '<|end|>',
      'user_start': '<|user|>',
      'user_end': '<|end|>',
      'assistant_start': '<|assistant|>',
      'assistant_end': '<|end|>',
      'stop_generation': ['<|end|>', 'User:'],
      'ignore_regex': null,
    };

    final Map<String, dynamic> formatMap = {
      'template': '{{system}}\n{{user}}\n{{assistant}}',
      'tokens': tokenMap
    };

    test('ChatTokens parsing', () {
      final tokens = ChatTokens.fromMap(tokenMap);

      expect(tokens.systemStart, '<|system|>');
      expect(tokens.stopGeneration.length, 2);
      expect(tokens.stopGeneration.contains('User:'), true);
      expect(tokens.ignoreRegex, null);
    });

    test('ChatTokens serialization', () {
      final tokens = ChatTokens.fromMap(tokenMap);
      final map = tokens.toMap();

      expect(map['system_start'], '<|system|>');
      expect(map['stop_generation'], tokens.stopGeneration);
    });

    test('ChatTokens null safety', () {
      final map = <String, dynamic>{}; // Empty map
      final tokens = ChatTokens.fromMap(map);

      expect(tokens.systemStart, null);
      expect(tokens.stopGeneration, isEmpty);
    });

    test('ChatFormat parsing (deep)', () {
      final format = ChatFormat.fromMap(formatMap);

      expect(format.template, '{{system}}\n{{user}}\n{{assistant}}');
      expect(format.tokens, isNotNull);
      expect(format.tokens!.userStart, '<|user|>');
    });

    test('ChatFormat serialization', () {
      final format = ChatFormat.fromMap(formatMap);
      final map = format.toMap();

      expect(map['template'], formatMap['template']);
      expect(map['tokens'], isNotNull);
      expect((map['tokens'] as Map)['user_start'], '<|user|>');
    });

    test('ChatFormat null tokens', () {
      final map = {'template': 'simple'};
      final format = ChatFormat.fromMap(map);

      expect(format.template, 'simple');
      expect(format.tokens, null);
    });
  });
}

// lib/roleplay/service.dart
//
// Handles the actual AI API call for roleplay sessions.
// Builds the correct system prompt + message history and calls the backend.

import 'package:dio/dio.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:flutter/foundation.dart';

import 'models/character.dart';

class RoleplayService {
  static const _maxHistoryMessages = 40;

  /// Generates an AI response for a roleplay session.
  ///
  /// [history] is the existing message list (non-loading messages only).
  /// [character] defines the system prompt and persona.
  Future<String> generateResponse({
    required List<RoleplayMessage> history,
    required RoleplayCharacter character,
    required ModelEntity model,
    required Dio dio,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(character);
      final messages = _buildMessages(history, systemPrompt);

      final response = await dio.post(
        '/chat',
        data: {
          'model': model.id,
          'messages': messages,
          'max_tokens': 800,
          'temperature': 0.9,
          'stream': false,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final msg = choices[0]['message'] as Map<String, dynamic>?;
          if (msg != null) {
            return (msg['content'] as String? ?? '').trim();
          }
        }
      }

      return '${character.avatarEmoji} ...';
    } catch (e) {
      debugPrint('[RoleplayService] generateResponse error: $e');
      rethrow;
    }
  }

  String _buildSystemPrompt(RoleplayCharacter character) {
    final sb = StringBuffer();
    sb.writeln(character.systemPrompt);

    if (character.worldContext != null) {
      sb.writeln('\n--- DÜNYA BAĞLAMI ---');
      sb.writeln(character.worldContext);
    }

    if (character.traits.isNotEmpty) {
      sb.writeln('\n--- KİŞİLİK ÖZELLİKLERİN ---');
      for (final t in character.traits) {
        sb.writeln('${t.emoji} ${t.name}');
      }
    }

    sb.writeln('\n--- TEMEL KURALLAR ---');
    sb.writeln('• Her zaman ${character.name} karakteri olarak kal.');
    sb.writeln('• Kullanıcının dilinde (Türkçe veya ne yazıyorsa) yanıt ver.');
    sb.writeln('• "Ben bir AI\'yım" veya benzeri meta-açıklamalar yapma.');
    sb.writeln('• Yanıtların doğal, akıcı ve karakter tutarlı olsun.');
    sb.writeln('• Kısa ama etkili yanıtlar ver; monolog yazmaktan kaçın.');

    return sb.toString();
  }

  List<Map<String, String>> _buildMessages(
    List<RoleplayMessage> history,
    String systemPrompt,
  ) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Take only last N messages to stay within context limit
    final recent = history.length > _maxHistoryMessages
        ? history.sublist(history.length - _maxHistoryMessages)
        : history;

    for (final msg in recent) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    return messages;
  }
}

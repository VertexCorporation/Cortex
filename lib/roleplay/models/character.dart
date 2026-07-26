// lib/roleplay/models/character.dart
//
// Data model for a Character AI / Roleplay character persona.
// Immutable, serializable, and provider-agnostic.

import 'package:flutter/material.dart';

/// The category / genre a character belongs to, used for Discover filters.
enum CharacterCategory {
  featured,
  anime,
  fantasy,
  scifi,
  historical,
  celebrity,
  original,
  romance,
  adventure,
  horror,
  comedy,
  educational,
}

extension CharacterCategoryLabel on CharacterCategory {
  String get label {
    switch (this) {
      case CharacterCategory.featured:
        return '✨ Öne Çıkan';
      case CharacterCategory.anime:
        return '🎌 Anime';
      case CharacterCategory.fantasy:
        return '🧙 Fantezi';
      case CharacterCategory.scifi:
        return '🚀 Bilim Kurgu';
      case CharacterCategory.historical:
        return '🏛️ Tarihi';
      case CharacterCategory.celebrity:
        return '⭐ Ünlü';
      case CharacterCategory.original:
        return '💡 Özgün';
      case CharacterCategory.romance:
        return '💕 Romantik';
      case CharacterCategory.adventure:
        return '⚔️ Macera';
      case CharacterCategory.horror:
        return '👻 Korku';
      case CharacterCategory.comedy:
        return '😄 Komedi';
      case CharacterCategory.educational:
        return '📚 Eğitici';
    }
  }

  Color get accentColor {
    switch (this) {
      case CharacterCategory.featured:
        return const Color(0xFFFFD700);
      case CharacterCategory.anime:
        return const Color(0xFFFF6B9D);
      case CharacterCategory.fantasy:
        return const Color(0xFF9B59B6);
      case CharacterCategory.scifi:
        return const Color(0xFF00BCD4);
      case CharacterCategory.historical:
        return const Color(0xFFD4A017);
      case CharacterCategory.celebrity:
        return const Color(0xFFFF9800);
      case CharacterCategory.original:
        return const Color(0xFF4CAF50);
      case CharacterCategory.romance:
        return const Color(0xFFE91E63);
      case CharacterCategory.adventure:
        return const Color(0xFFFF5722);
      case CharacterCategory.horror:
        return const Color(0xFF607D8B);
      case CharacterCategory.comedy:
        return const Color(0xFFFFEB3B);
      case CharacterCategory.educational:
        return const Color(0xFF2196F3);
    }
  }
}

/// Personality trait tags used for display and system prompt generation.
class PersonalityTrait {
  final String name;
  final String emoji;

  const PersonalityTrait({required this.name, required this.emoji});
}

/// Core character model — represents one AI persona / character.
class RoleplayCharacter {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String systemPrompt;
  final String avatarEmoji;
  final String? avatarImageUrl;
  final CharacterCategory category;
  final List<PersonalityTrait> traits;
  final List<String> exampleOpeners;
  final String backgroundStory;
  final String? voiceStyle; // e.g. 'formal', 'casual', 'poetic'
  final bool isOfficial; // Official Cortex characters vs user-created
  final bool isNSFW;
  final int chatCount; // Popularity metric
  final String creatorName;
  final DateTime createdAt;
  final List<Color> gradientColors;
  final String? worldContext; // Setting/universe description

  const RoleplayCharacter({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.systemPrompt,
    required this.avatarEmoji,
    this.avatarImageUrl,
    required this.category,
    this.traits = const [],
    this.exampleOpeners = const [],
    this.backgroundStory = '',
    this.voiceStyle,
    this.isOfficial = false,
    this.isNSFW = false,
    this.chatCount = 0,
    this.creatorName = 'Cortex',
    required this.createdAt,
    required this.gradientColors,
    this.worldContext,
  });

  RoleplayCharacter copyWith({
    String? id,
    String? name,
    String? tagline,
    String? description,
    String? systemPrompt,
    String? avatarEmoji,
    String? avatarImageUrl,
    CharacterCategory? category,
    List<PersonalityTrait>? traits,
    List<String>? exampleOpeners,
    String? backgroundStory,
    String? voiceStyle,
    bool? isOfficial,
    bool? isNSFW,
    int? chatCount,
    String? creatorName,
    DateTime? createdAt,
    List<Color>? gradientColors,
    String? worldContext,
  }) {
    return RoleplayCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarImageUrl: avatarImageUrl ?? this.avatarImageUrl,
      category: category ?? this.category,
      traits: traits ?? this.traits,
      exampleOpeners: exampleOpeners ?? this.exampleOpeners,
      backgroundStory: backgroundStory ?? this.backgroundStory,
      voiceStyle: voiceStyle ?? this.voiceStyle,
      isOfficial: isOfficial ?? this.isOfficial,
      isNSFW: isNSFW ?? this.isNSFW,
      chatCount: chatCount ?? this.chatCount,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      gradientColors: gradientColors ?? this.gradientColors,
      worldContext: worldContext ?? this.worldContext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'systemPrompt': systemPrompt,
      'avatarEmoji': avatarEmoji,
      'avatarImageUrl': avatarImageUrl,
      'category': category.name,
      'traits': traits.map((t) => {'name': t.name, 'emoji': t.emoji}).toList(),
      'exampleOpeners': exampleOpeners,
      'backgroundStory': backgroundStory,
      'voiceStyle': voiceStyle,
      'isOfficial': isOfficial,
      'isNSFW': isNSFW,
      'chatCount': chatCount,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'gradientColors': gradientColors.map((c) => c.toARGB32()).toList(),
      'worldContext': worldContext,
    };
  }

  factory RoleplayCharacter.fromJson(Map<String, dynamic> json) {
    return RoleplayCharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      systemPrompt: json['systemPrompt'] as String? ?? '',
      avatarEmoji: json['avatarEmoji'] as String? ?? '🤖',
      avatarImageUrl: json['avatarImageUrl'] as String?,
      category: CharacterCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => CharacterCategory.original,
      ),
      traits: (json['traits'] as List<dynamic>?)
              ?.map((t) => PersonalityTrait(
                    name: t['name'] as String,
                    emoji: t['emoji'] as String,
                  ))
              .toList() ??
          [],
      exampleOpeners: List<String>.from(json['exampleOpeners'] ?? []),
      backgroundStory: json['backgroundStory'] as String? ?? '',
      voiceStyle: json['voiceStyle'] as String?,
      isOfficial: json['isOfficial'] as bool? ?? false,
      isNSFW: json['isNSFW'] as bool? ?? false,
      chatCount: json['chatCount'] as int? ?? 0,
      creatorName: json['creatorName'] as String? ?? 'Cortex',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          [const Color(0xFF6C63FF), const Color(0xFF3A3A8C)],
      worldContext: json['worldContext'] as String?,
    );
  }
}

/// A single message within a roleplay session.
class RoleplayMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const RoleplayMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  RoleplayMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return RoleplayMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// A roleplay session — one ongoing conversation with a character.
class RoleplaySession {
  final String id;
  final RoleplayCharacter character;
  final List<RoleplayMessage> messages;
  final DateTime startedAt;
  final DateTime lastMessageAt;
  final String? userPersonaName; // How the user wants to be called in-session

  const RoleplaySession({
    required this.id,
    required this.character,
    this.messages = const [],
    required this.startedAt,
    required this.lastMessageAt,
    this.userPersonaName,
  });

  RoleplaySession copyWith({
    String? id,
    RoleplayCharacter? character,
    List<RoleplayMessage>? messages,
    DateTime? startedAt,
    DateTime? lastMessageAt,
    String? userPersonaName,
  }) {
    return RoleplaySession(
      id: id ?? this.id,
      character: character ?? this.character,
      messages: messages ?? this.messages,
      startedAt: startedAt ?? this.startedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      userPersonaName: userPersonaName ?? this.userPersonaName,
    );
  }
}

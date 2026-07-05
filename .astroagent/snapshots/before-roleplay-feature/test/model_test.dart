// test/model_test.dart
import 'package:cortex/library/backend/data/entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelEntity Tests', () {
    // --- MASSIVE PARAMETRIC TESTING ---
    final languages = ['en', 'tr', 'fr', 'es', 'de', 'it', 'ja', 'ru'];
    final tiers = ['free', 'premium', 'plus', 'pro', 'ultra', 'standard'];
    final categories = [
      'chat',
      'roleplay',
      'code',
      'vision',
      'audio',
      'analysis'
    ];

    for (var lang in languages) {
      test('Language fallback logic for $lang', () {
        final Map<String, dynamic> data = {
          'id': 'test-model',
          'title': {'en': 'English Name', 'tr': 'Turkish Name'},
          'description': {'fr': 'French Desc'}
        };
        final model = ModelEntity.fromMap(data, lang);

        if (lang == 'tr') {
          expect(model.displayTitle, 'Turkish Name');
        } else if (lang == 'en') {
          expect(model.displayTitle, 'English Name');
        } else {
          // Fallback to English
          expect(model.displayTitle, 'English Name');
        }

        // Fallback to first available if EN missing
        if (lang == 'fr') {
          expect(model.displayDescription, 'French Desc');
        } else {
          expect(model.displayDescription,
              'French Desc'); // Fallback to first available
        }
      });
    }

    for (var tier in tiers) {
    test('Tier detection for $tier', () {
      final model = ModelEntity.fromMap({'id': tier == 'premium' ? 'claude' : 'm', 'title': tier == 'premium' ? 'Claude' : 'M', 'tier': tier}, 'en');
      final isPremiumTier = tier == 'premium';
      expect(model.isPremium, isPremiumTier);
    });
  }

    for (var cat in categories) {
      test('Category parsing for $cat', () {
        final model = ModelEntity.fromMap({'id': 'm', 'category': cat}, 'en');
        expect(model.category, cat);
      });
    }

    test('Handling String inputs for localized fields', () {
      final model = ModelEntity.fromMap({
        'id': 'test2',
        'title': 'Just A String',
        'description': 'Description String'
      }, 'en');

      expect(model.displayTitle, 'Just A String');
      expect(model.displayDescription, 'Description String');
    });

    test('Convenience Getters', () {
      final serverModel = ModelEntity.fromMap(
          {'id': 'cortex/gpt', 'title': 'S', 'type': 'online'}, 'en');
      final localModel = ModelEntity.fromMap(
          {'id': 'llama-3', 'title': 'L', 'type': 'offline'}, 'en');

      expect(serverModel.isServerSide, true);
      expect(localModel.isServerSide, false);
    });

    test('Equality and HashCode', () {
      final m1 = ModelEntity.fromMap({'id': 'a', 'title': 'Name'}, 'en');
      final m2 = ModelEntity.fromMap({'id': 'a', 'title': 'Name'}, 'en');
      final m3 = ModelEntity.fromMap({'id': 'b', 'title': 'Name'}, 'en');

      expect(m1 == m2, true);
      expect(m1 == m3, false);
      expect(m1.hashCode, m2.hashCode);
    });

    test('copyWith Functionality', () {
      final m1 = ModelEntity.fromMap({'id': 'a', 'title': 'Original'}, 'en');
      final m2 = m1.copyWith(displayTitle: 'Updated');

      expect(m2.id, 'a');
      expect(m2.displayTitle, 'Updated');
      expect(m1.displayTitle, 'Original'); // Immutable
    });

    test('toMap Serialization', () {
      final map = {
        'id': 'test',
        'title': 'Test', // Note: mapped from 'title'
        'is_active': true,
        'context': '2048'
      };

      // We pass the map in. The toMap output keys match property names, or are they standard?
      // Entity.dart: toMap uses 'title' for displayTitle.

      final model = ModelEntity.fromMap(map, 'en');
      final json = model.toMap();

      expect(json['id'], 'test');
      expect(json['title'], 'Test');
    });

    test('ChatFormat Parsing', () {
      final data = {
        'id': 'f',
        'chatFormat': {
          'template': 'abc',
          'tokens': {
            'stop_generation': ['STOP']
          }
        }
      };
      // Note key was 'chatFormat' in entity code

      final model = ModelEntity.fromMap(data, 'en');
      expect(model.chatFormat, isNotNull);
      expect(model.chatFormat!.template, 'abc');
      expect(model.chatFormat!.tokens!.stopGeneration.first, 'STOP');
    });
  });
}

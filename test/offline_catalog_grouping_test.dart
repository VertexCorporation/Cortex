import 'package:cortex/library/backend/data/defaults.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/repository.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> offline(String id, int size, int ram) => {
      'id': id,
      'source': 'huggingface',
      'type': 'offline',
      'size': size,
      'ram': ram,
      'url': 'https://huggingface.co/p/$id/resolve/main/$id.gguf',
      'details': {
        'en': {'title': id.replaceAll('-', ' ')},
        'tr': {'description': 'Korunacak'}
      },
    };
void main() {
  test('offline variant titles retain identity, version and size', () {
    for (final entry in {
      'next-1b': 'Next 1B',
      'next-4b': 'Next 4B',
      'glm-4.7-flash': 'GLM 4.7 Flash',
    }.entries) {
      final family = entry.key.startsWith('next') ? 'Next' : 'GLM';
      final raw = offline(entry.key, 1000, 3000);
      raw['details']['en']['title'] = entry.value;
      final grouped = ModelDefaults.normalizeModelFamilies([
        {...raw, 'series': entry.value},
      ]).single;
      expect(grouped['series'], family);
      final variant = (grouped['variants'] as Map).values.single;
      for (final lang in ['en', 'tr']) {
        expect(
            ModelEntity.fromMap(Map<String, dynamic>.from(variant), lang)
                .displayTitle,
            entry.value);
      }
    }
  });

  test('Arcee AI survives client family filtering', () {
    final groups = ModelDefaults.normalizeModelFamilies([
      {
        'id': 'arcee-ai/trinity-large-thinking',
        'series': 'Arcee AI',
        'title': 'Trinity Large Thinking',
        'type': 'online',
        'source': 'openrouter'
      },
    ]);
    expect(groups.single['series'], 'Arcee AI');
  });
  test('legacy curated offline names use base families', () {
    for (final id in ['jan-nano', 'jannano128k']) {
      expect(ModelDefaults.offlineModelFamily({'id': id}, id), 'Jan');
    }
    expect(
        ModelDefaults.offlineModelFamily(
            {'id': 'supernova-medius'}, 'supernova medius'),
        'SuperNova');
    expect(ModelDefaults.offlineModelFamily({'id': 'zeta'}, 'zeta'), 'Zeta');
  });
  test(
      'wire catalog groups Next sizes and keeps online and offline Llama separate',
      () {
    final models = ModelRepository.parseServerModels({
      'producers': {
        'Publisher': {
          'Next 1B': {'Default': offline('next-1b', 900, 2200)},
          'Next 4B': {'Default': offline('next-4b', 3000, 5000)},
        },
        'Meta': {
          'Llama 2': {
            '7B Chat': offline('llama-2-7b-chat', 4000, 6000),
          },
          'Llama': {
            'Online': {
              'id': 'meta-llama/llama-4',
              'type': 'online',
              'source': 'openrouter'
            },
            '8B': offline('llama-3-8b', 5000, 7000),
          }
        },
      }
    }, 'tr');
    final next = ModelEntity.fromMap(
        models.firstWhere((m) => m['series'] == 'Next'), 'tr');
    expect(next.type, 'offline');
    expect(next.variants!.keys, unorderedEquals(['next-1b', 'next-4b']));
    expect(next.variants!['next-4b']['size'], 3000);
    expect(
        next.variants!['next-4b']['details']['tr']['description'], 'Korunacak');
    final llama = models.where((m) => m['series'] == 'Llama').toList();
    expect(llama, hasLength(2));
    expect(llama.map((m) => m['type']), unorderedEquals(['online', 'offline']));
    expect(llama.map((m) => m['id']).toSet(), hasLength(2));
    final offlineLlama = llama.singleWhere((m) => m['type'] == 'offline');
    expect((offlineLlama['variants'] as Map).keys,
        unorderedEquals(['llama-2-7b-chat', 'llama-3-8b']));
    expect(models.where((m) => m['series'] == 'Llama 2'), isEmpty);
  });

  test(
      'legacy provider and unknown-series cards cannot survive cache hydration',
      () {
    final models = ModelDefaults.normalizeModelFamilies([
      for (final family in [
        'Hunyuan',
        'Hy Mt2 1.8b',
        'Hy3',
        'Orpheus',
        'STT',
        'SDAIA'
      ])
        {
          'id': family.toLowerCase(),
          'series': family,
          'type': 'online',
          'source': 'openrouter'
        },
    ]);
    expect(models, isEmpty);
  });

  test('oversized first variant does not hide smaller downloadable variants',
      () {
    final model = ModelEntity.fromMap({
      'id': 'next-offline',
      'series': 'Next',
      'title': 'Next',
      'type': 'offline',
      'imagePath': 'assets/icons/self.svg',
      'size': 50000,
      'ram': 52000,
      'variants': {
        'large': offline('next-70b', 50000, 52000),
        'small': offline('next-1b', 900, 2200)
      },
    }, 'en');
    final result = ModelService.normalizeOfflineModelForCatalog(model,
        minOfflineSizeMb: 300,
        maxOfflineRamMb: 32000,
        maxOfflineSizeMb: 1048576);
    expect(result, isNotNull);
    expect(result!.variants!.keys, ['small']);
    expect(result.size, 900);
    expect(result.ram, 2200);
  });
}

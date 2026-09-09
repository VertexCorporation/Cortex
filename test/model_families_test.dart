import 'dart:io';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/defaults.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> model(String family, String id,
        {String output = 'text'}) =>
    {
      'id': id,
      'series': family,
      'title': family,
      'producer': 'Original provider',
      'type': 'online',
      'source': 'original-route',
      'outputs': {output: true},
    };

void main() {
  final cases = [
    ['Cloudflare AI', '@cf/deepgram/nova-3', 'Nova'],
    ['Grok Imagine', 'xai/grok-imagine', 'Grok'],
    ['Hailuo Video', 'fal-ai/minimax/hailuo-02', 'MiniMax'],
    ['MiniMax Speech', 'minimax/speech-02', 'MiniMax'],
    ['Meta', 'meta/muse-image/edit', 'Muse'],
    ['Meta', 'meta-llama/llama-4', 'Llama'],
    ['Microsoft', 'microsoft/mai-image-2.5', 'MAI'],
    ['Microsoft', 'microsoft/phi-4', 'Phi'],
    ['NVIDIA', 'nvidia/nemotron-3-nano', 'Nemotron'],
    ['Groq', 'openai/gpt-oss-120b', 'ChatGPT'],
    ['Groq', 'qwen/qwen3-32b', 'Qwen'],
    ['Stable Diffusion', 'stability/sd3', 'Stable'],
    ['Stable Audio', 'stable-audio-2', 'Stable'],
    ['CTT', 'ctt/whisper-large', 'Whisper'],
    ['Gpt Image', 'openai/gpt-image-2', 'GPT Image'],
  ];
  for (final row in cases) {
    test('${row[0]} / ${row[1]} becomes ${row[2]} without changing routing',
        () {
      final result =
          ModelDefaults.normalizeModelFamilies([model(row[0], row[1])]).single;
      expect(result['series'], row[2]);
      expect(ModelEntity.fromMap(result, 'en').displayTitle, row[2]);
      final variant = (result['variants'] as Map)[row[1]] as Map;
      expect(variant['id'], row[1]);
      expect(variant['producer'], 'Original provider');
      expect(variant['source'], 'original-route');
    });
  }

  test('merges aliases, preserves each modality and is idempotent', () {
    final result = ModelDefaults.normalizeModelFamilies([
      model('MiniMax', 'minimax/m2'),
      model('Hailuo Video', 'fal/minimax/hailuo', output: 'video'),
      model('minimax-speech', 'minimax/speech', output: 'audio'),
      model(' MINIMAX ', 'minimax/image', output: 'image'),
    ]);
    expect(result, hasLength(1));
    final entity = ModelEntity.fromMap(result.single, 'en');
    expect(entity.variants, hasLength(4));
    for (final modality in ['text', 'video', 'audio', 'image']) {
      expect(entity.supportsOutput(modality), isTrue);
    }
    expect(ModelDefaults.normalizeModelFamilies(result), result);
  });

  test('splits legacy mixed provider buckets and merges existing destinations',
      () {
    final result = ModelDefaults.normalizeModelFamilies([
      {
        'id': 'nvidia',
        'series': 'NVIDIA',
        'variants': {
          'nvidia/nemotron-3': model('NVIDIA', 'nvidia/nemotron-3'),
          'nvidia/cosmos-3': model('NVIDIA', 'nvidia/cosmos-3'),
        }
      },
      model('nemotron', 'nvidia/nemotron-4'),
    ]);
    expect(result.map((m) => m['series']), unorderedEquals(['Nemotron']));
    expect(result.firstWhere((m) => m['series'] == 'Nemotron')['variants'],
        hasLength(2));
  });

  test('localized variant title cannot overwrite family display title', () {
    final result = ModelDefaults.normalizeModelFamilies([
      {
        ...model('Meta', 'meta/muse-image'),
        'details': {
          'tr': {'title': 'Meta Muse Image', 'description': 'Açıklama'}
        },
      }
    ]).single;
    expect(ModelEntity.fromMap(result, 'tr').displayTitle, 'Muse');
    expect(
        (result['variants'] as Map)['meta/muse-image']['details'], isNotNull);
  });

  test('unknown provider models and custom models are retained', () {
    final custom = {...model('Meta', 'self_123'), 'category': 'self'};
    final result = ModelDefaults.normalizeModelFamilies(
        [model('CTT', 'ctt/unknown-model'), custom]);
    expect(result, contains(custom));
    expect(result.where((m) => m['series'] == 'unknown-model'), isEmpty);
    expect(ModelDefaults.resolveModelFamily('Groq', ''), 'Other');
  });

  test('all family assets are registered by the model asset directory', () {
    expect(
        File('pubspec.yaml').readAsStringSync(), contains('- assets/models/'));
    for (final path in ModelDefaults.familyAssets.values) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}

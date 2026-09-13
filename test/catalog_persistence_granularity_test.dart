// Regression tests for the per-variant catalog persistence design.
//
// The models table stores one small row per wire variant entry. Family
// containers — the presentation shape the UI consumes — are rebuilt at read
// time by `ModelDefaults.normalizeModelFamilies`. These tests pin both the
// row granularity (rows must stay far below Android's 2 MB CursorWindow) and
// the round-trip contract (grouping rows must produce the same family
// containers as the pre-redesign pipeline).
import 'dart:convert';

import 'package:cortex/library/backend/data/defaults.dart';
import 'package:cortex/library/backend/data/repository.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> onlineVariant(int i) => {
      'id': 'qwen/qwen3-next-${i}b',
      'source': 'openrouter',
      'tier': 'free',
      'type': 'online',
      'description': {
        'en': 'English description for variant $i.',
        'tr': 'Varyant $i Turkce aciklamasi.',
        'processing_status': {'ok': true},
      },
      'context': '128k',
    };

Map<String, dynamic> offlineVariant(int i) => {
      'id': 'qwen3-next-${i}b-gguf',
      'source': 'huggingface',
      'type': 'offline',
      'size': 4000 + i,
      'ram': 6000 + i,
      'url': 'https://huggingface.co/p/qwen/resolve/main/$i.gguf',
      'details': {
        'en': {'title': 'Qwen3 Next ${i}B'},
        'tr': {'description': 'Korunacak $i'},
      },
    };

Map<String, dynamic> multiVariantCatalog({
  int onlineCount = 6,
  int offlineCount = 4,
  int heavyCount = 0,
}) {
  final online = <String, dynamic>{
    for (var i = 0; i < onlineCount; i++) 'Next ${i}B': onlineVariant(i),
  };
  final heavy = <String, dynamic>{
    for (var i = 0; i < heavyCount; i++)
      'Heavy ${i}B': onlineVariant(1000 + i)..['details'] = {
            'en': {'description': 'H' * 4000},
            'tr': {'description': 'T' * 4000},
            'fr': {'description': 'F' * 4000},
            'zh': {'description': 'Z' * 4000},
          },
  };
  final offline = <String, dynamic>{
    for (var i = 0; i < offlineCount; i++) 'Offline ${i}B': offlineVariant(i),
  };
  return {
    'producers': {
      'Qwen Corp': {
        'Qwen Next': {
          'series_description': {
            'en': 'Series text.',
            'tr': 'Seri metni.',
          },
          ...online,
          ...heavy,
        },
        'Qwen Next Offline': {
          'series_description': {'en': 'Offline series text.'},
          ...offline,
        },
      },
    },
  };
}

void main() {
  test('parseServerModelRows emits one record per wire variant', () {
    final rows =
        ModelRepository.parseServerModelRows(multiVariantCatalog(), 'en');

    expect(rows, hasLength(10));
    for (final row in rows) {
      expect(row['series'], anyOf('Qwen Next', 'Qwen Next Offline'));
      expect(row['producer'], 'Qwen Corp');
      expect('${row['id']}', isNotEmpty);
      // Sibling variant maps must never be duplicated into a record — that
      // duplication is what made legacy family rows grow quadratically.
      expect(row.keys.where((k) => k.startsWith('Next ')), isEmpty);
      expect(row.keys.where((k) => k.startsWith('Offline ')), isEmpty);
      expect(row['variants'], isNull);
    }
  });

  test('records regroup into the same family containers the UI expects', () {
    final rows =
        ModelRepository.parseServerModelRows(multiVariantCatalog(), 'en');
    final groups = ModelDefaults.normalizeModelFamilies(rows);

    expect(groups, hasLength(2));
    final online = groups.firstWhere((g) => g['id'] == 'qwen');
    final offline = groups.firstWhere((g) => g['id'] == 'qwen-offline');

    expect(online['series'], 'Qwen');
    final onlineVariants = online['variants'] as Map<String, dynamic>;
    expect(onlineVariants.keys,
        unorderedEquals([for (var i = 0; i < 6; i++) 'qwen/qwen3-next-${i}b']));
    expect(onlineVariants['qwen/qwen3-next-3b']['description'],
        'English description for variant 3.');
    expect(onlineVariants['qwen/qwen3-next-3b']['summary'], 'Series text.');

    final offlineVariants = offline['variants'] as Map<String, dynamic>;
    expect(offlineVariants.keys,
        unorderedEquals([for (var i = 0; i < 4; i++) 'qwen3-next-${i}b-gguf']));
    expect(offlineVariants['qwen3-next-2b-gguf']['size'], 4002);
    expect(
        offlineVariants['qwen3-next-2b-gguf']['details']['tr']['description'],
        'Korunacak 2');
  });

  test('parseServerModels still returns grouped containers (wire contract)',
      () {
    final models =
        ModelRepository.parseServerModels(multiVariantCatalog(), 'en');
    final ids = models.map((m) => '${m['id']}').toSet();
    expect(ids, containsAll(['qwen', 'qwen-offline']));
    final online = models.firstWhere((m) => m['id'] == 'qwen');
    expect((online['variants'] as Map).keys, hasLength(6));
  });

  test('duplicate variant ids across producers keep last-write-wins parity',
      () {
    final rows = ModelRepository.parseServerModelRows({
      'producers': {
        'Alpha': {
          'Qwen Next': {
            'series_description': {'en': 'Alpha series.'},
            'One': {
              'id': 'qwen/shared-variant',
              'type': 'online',
              'source': 'openrouter',
            },
          },
        },
        'Beta': {
          'Qwen Next': {
            'series_description': {'en': 'Beta series.'},
            'One': {
              'id': 'qwen/shared-variant',
              'type': 'online',
              'source': 'fal',
            },
          },
        },
      },
    }, 'en');

    expect(rows, hasLength(2));
    expect(rows.map((r) => r['id']).toSet(), {'qwen/shared-variant'});

    final groups = ModelDefaults.normalizeModelFamilies(rows);
    expect(groups, hasLength(1));
    // The later record wins, exactly like a primary-key upsert of the rows
    // and exactly like the legacy in-group variant merge behaved.
    final mergedVariants = groups.single['variants'] as Map;
    expect(mergedVariants.values.single['source'], 'fal');
  });

  test('records stay far below the CursorWindow limit under stress', () {
    // 150 heavy variants: with the legacy design this catalog produced one
    // family row of roughly variantCount * seriesSize bytes — quadratic in
    // the variant count. Records must stay linear and tiny.
    final rows = ModelRepository.parseServerModelRows(
        multiVariantCatalog(heavyCount: 150), 'en');
    expect(rows, hasLength(160));

    var maxRow = 0;
    for (final row in rows) {
      final s = json.encode(row).length;
      if (s > maxRow) maxRow = s;
    }
    // Android's CursorWindow is 2 MB; keep a 8x safety margin.
    expect(maxRow, lessThan(256 * 1024));

    final groups = ModelDefaults.normalizeModelFamilies(rows);
    final online = groups.firstWhere((g) => g['id'] == 'qwen');
    expect((online['variants'] as Map).keys, hasLength(156));
  });
}

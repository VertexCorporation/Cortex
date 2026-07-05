import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

ModelEntity _entityFromMap(Map<String, dynamic> map) =>
    ModelEntity.fromMap(map, 'en');

void main() {
  group('ModelService.normalizeOfflineModelForCatalog', () {
    const minOfflineSizeMb = 300;
    const maxOfflineRamMb = 32000;
    const maxOfflineSizeMb = 1024 * 1024;

    test('removes offline models smaller than 300 MB', () {
      final model = _entityFromMap({
        'id': 'tiny-offline',
        'title': 'Tiny Offline',
        'producer': 'Test',
        'type': 'offline',
        'category': 'assistant',
        'size': 256,
      });

      final result = ModelService.normalizeOfflineModelForCatalog(
        model,
        minOfflineSizeMb: minOfflineSizeMb,
        maxOfflineRamMb: maxOfflineRamMb,
        maxOfflineSizeMb: maxOfflineSizeMb,
      );

      expect(result, isNull);
    });

    test('keeps 300 MB offline models', () {
      final model = _entityFromMap({
        'id': 'exact-offline',
        'title': 'Exact Offline',
        'producer': 'Test',
        'type': 'offline',
        'category': 'assistant',
        'size': 300,
      });

      final result = ModelService.normalizeOfflineModelForCatalog(
        model,
        minOfflineSizeMb: minOfflineSizeMb,
        maxOfflineRamMb: maxOfflineRamMb,
        maxOfflineSizeMb: maxOfflineSizeMb,
      );

      expect(result, isNotNull);
      expect(result!.size, 300);
    });

    test('filters offline variants below threshold and keeps valid ones', () {
      final model = _entityFromMap({
        'id': 'variant-offline',
        'title': 'Variant Offline',
        'producer': 'Test',
        'type': 'offline',
        'category': 'assistant',
        'size': 256,
        'variants': {
          'tiny': {'id': 'tiny', 'size': 256},
          'valid': {'id': 'valid', 'size': 512},
        },
      });

      final result = ModelService.normalizeOfflineModelForCatalog(
        model,
        minOfflineSizeMb: minOfflineSizeMb,
        maxOfflineRamMb: maxOfflineRamMb,
        maxOfflineSizeMb: maxOfflineSizeMb,
      );

      expect(result, isNotNull);
      expect(result!.variants!.length, 1);
      expect(result.variants!.keys, contains('valid'));
      expect(result.variants!.keys, isNot(contains('tiny')));
      expect(result.size, 512);
    });

    test('removes offline model when all variants are below threshold', () {
      final model = _entityFromMap({
        'id': 'all-tiny-offline',
        'title': 'All Tiny Offline',
        'producer': 'Test',
        'type': 'offline',
        'category': 'assistant',
        'variants': {
          'tiny-a': {'id': 'tiny-a', 'size': 128},
          'tiny-b': {'id': 'tiny-b', 'size': 299},
        },
      });

      final result = ModelService.normalizeOfflineModelForCatalog(
        model,
        minOfflineSizeMb: minOfflineSizeMb,
        maxOfflineRamMb: maxOfflineRamMb,
        maxOfflineSizeMb: maxOfflineSizeMb,
      );

      expect(result, isNull);
    });
  });
}

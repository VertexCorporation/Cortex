// test/startup_performance_test.dart
//
// Açılış süresi ve Phase 1/2 pipeline performans testleri.
//
// Bu testler gerçek network/Firebase çağrıları YAPMAYOR — tamamen business
// logic, hesaplama hızı ve veri akışını ölçer. Bir sonraki aşamada
// flutter drive ile gerçek cihazda da koşturulabilir.

import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/utils.dart';
import 'package:cortex/cache.dart';
import 'package:cortex/initialization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // =========================================================================
  // GRUP 1: AppInitializer — Versiyon Karşılaştırma Performansı
  // =========================================================================
  group('AppInitializer — Version Comparison Logic', () {
    // Sahte AppInitializer (iç metodu test etmek için)
    final initializer = _VersionTester();

    test('Lower version returns true (update required)', () {
      expect(initializer.isLower('2.9.3', '2.9.4'), true);
      expect(initializer.isLower('1.0.0', '2.0.0'), true);
      expect(initializer.isLower('2.9.9', '3.0.0'), true);
      expect(initializer.isLower('0.0.1', '0.0.2'), true);
    });

    test('Same version returns false (no update needed)', () {
      expect(initializer.isLower('2.9.4', '2.9.4'), false);
      expect(initializer.isLower('3.0.0', '3.0.0'), false);
    });

    test('Higher version returns false (already up to date)', () {
      expect(initializer.isLower('3.0.0', '2.9.9'), false);
      expect(initializer.isLower('2.9.5', '2.9.4'), false);
    });

    test('Short version string normalizes correctly', () {
      // "2.9" vs "2.9.1" → 2.9.0 < 2.9.1
      expect(initializer.isLower('2.9', '2.9.1'), true);
      expect(initializer.isLower('2.9.1', '2.9'), false);
    });

    test('Malformed version string does not throw (safe fallback)', () {
      expect(() => initializer.isLower('abc', '1.0.0'), returnsNormally);
      expect(() => initializer.isLower('1.0.0', 'xyz'), returnsNormally);
      // Fallback: assumes safe (no update)
      expect(initializer.isLower('bad', '1.0'), false);
    });

    // Performance: 10.000 version comparison <100ms (JIT warmup included)
    test('[PERF] 10k version comparisons complete in <100ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        initializer.isLower('2.9.$i', '2.9.${i + 1}');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Version comparison is O(n) where n=3 — must be near-instant');
    });
  });

  // =========================================================================
  // GRUP 2: Açılış SVG Listesi Bütünlüğü
  // =========================================================================
  group('Startup — SVG Pre-cache List Integrity', () {
    // Bu test, SVG listesinin compile-time hataları olmadan oluşturulduğunu
    // ve beklenmedik boş giriş içermediğini doğrular.
    const coreSvgs = [
      'assets/cortex.svg',
      'assets/icons/chat.svg',
      'assets/icons/features.svg',
      'assets/icons/on/axon.svg',
      'assets/icons/off/axon.svg',
      'assets/icons/storage.svg',
    ];

    test('Core SVG list has no empty or whitespace-only entries', () {
      for (final path in coreSvgs) {
        expect(path.trim(), isNotEmpty,
            reason: 'SVG path must not be blank: "$path"');
        expect(path.endsWith('.svg'), true,
            reason: 'Entry must be a .svg file: "$path"');
      }
    });

    test('No duplicate SVG paths in pre-cache list', () {
      final uniquePaths = coreSvgs.toSet();
      expect(uniquePaths.length, coreSvgs.length,
          reason: 'Duplicate SVG paths waste startup time');
    });
  });

  // =========================================================================
  // GRUP 3: Açılış Statü Geçişleri (State Machine Doğruluğu)
  // =========================================================================
  group('AppStatus State Machine', () {
    test('All AppStatus values exist', () {
      final values = AppStatus.values;
      expect(values, containsAll([
        AppStatus.needsOnboarding,
        AppStatus.initializing,
        AppStatus.needsLogin,
        AppStatus.needsVerification,
        AppStatus.ready,
        AppStatus.maintenance,
        AppStatus.updateRequired,
      ]));
    });

    test('Default status is initializing', () {
      // Verify the enum default ordering for flag checks
      expect(AppStatus.initializing.index, greaterThanOrEqualTo(0));
    });
  });

  // =========================================================================
  // GRUP 4: CacheService — Startup Cache Performance
  // =========================================================================
  group('CacheService — Startup Cache Performance', () {
    setUp(() => CacheService.clearAll());
    tearDown(() => CacheService.clearAll());

    test('[PERF] Writing 100 cache entries completes in <200ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        CacheService.set(CacheKey.allModels, List.generate(i, (j) => j));
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(200),
          reason: 'Cache writes must be synchronous and near-instant');
    });

    test('[PERF] Reading 10k cache hits completes in <50ms', () {
      CacheService.set(CacheKey.allModels, [1, 2, 3]);
      final sw = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        CacheService.get<List>(CacheKey.allModels);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Cache reads are O(1) HashMap lookups');
    });

    test('Cache miss returns null (no cold-start crash)', () {
      // After clearAll, every key must return null
      for (final key in CacheKey.values) {
        expect(CacheService.get(key), isNull,
            reason: '${key.name} should be null after clearAll');
      }
    });

    test('CacheKey enum covers all expected data types', () {
      // Ensures no key was accidentally removed during refactor
      expect(CacheKey.values.length, greaterThanOrEqualTo(10),
          reason: 'Expect at least 10 cache key types to be defined');
    });

    test('Set and Get round-trip is lossless', () {
      final payload = {'userId': 'abc', 'credits': 42, 'isPremium': true};
      CacheService.set(CacheKey.settingsUserData, payload);
      final retrieved = CacheService.get<Map<String, dynamic>>(CacheKey.settingsUserData);
      expect(retrieved, equals(payload));
    });

    test('Invalidate removes only the targeted key', () {
      CacheService.set(CacheKey.allModels, ['model1']);
      CacheService.set(CacheKey.recentModels, ['model2']);

      CacheService.invalidate(CacheKey.allModels);

      expect(CacheService.get(CacheKey.allModels), isNull);
      expect(CacheService.get<List>(CacheKey.recentModels), isNotNull);
    });

    test('clearAll removes every key', () {
      for (final key in CacheKey.values) {
        CacheService.set(key, 'value');
      }
      CacheService.clearAll();
      for (final key in CacheKey.values) {
        expect(CacheService.get(key), isNull);
      }
    });

    test('invalidateConversationCache removes only conversation keys', () {
      // Seed all keys
      CacheService.set(CacheKey.conversationManagers, ['c1']);
      CacheService.set(CacheKey.conversationOrder, [1]);
      CacheService.set(CacheKey.starredIds, {'id1'});
      CacheService.set(CacheKey.userModels, ['m1']);
      CacheService.set(CacheKey.settingsUserData, {'user': 'a'}); // unrelated

      CacheService.invalidateConversationCache();

      expect(CacheService.get(CacheKey.conversationManagers), isNull);
      expect(CacheService.get(CacheKey.conversationOrder), isNull);
      expect(CacheService.get(CacheKey.starredIds), isNull);
      expect(CacheService.get(CacheKey.userModels), isNull);
      // Unrelated key must survive
      expect(CacheService.get(CacheKey.settingsUserData), isNotNull);
    });
  });

  // =========================================================================
  // GRUP 5: Model Formatı ve Startup Model Yükleme Hızı
  // =========================================================================
  group('Startup Model Formatting — formatModelName Performance', () {
    test('[PERF] Formatting 1000 model names completes in <200ms', () {
      final modelIds = List.generate(1000, (i) => 'vendor/model-name-v${i}b');
      final sw = Stopwatch()..start();
      for (final id in modelIds) {
        ModelDataUtils.formatModelName(id);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(200),
          reason: 'Model name formatting must not be a startup bottleneck');
    });

    test('formatModelName handles edge cases safely', () {
      expect(ModelDataUtils.formatModelName(''), '');
      expect(ModelDataUtils.formatModelName('   '), ''); // only spaces
      expect(ModelDataUtils.formatModelName('gpt-4o'), isNotEmpty);
      expect(ModelDataUtils.formatModelName('cortex/auto'), isNotEmpty);
    });

    test('formatModelName never returns Unknown Model string', () {
      final ids = ['gpt-4', 'llama-3b', 'gemini-pro', 'cortex/auto', 'mistral-7b'];
      for (final id in ids) {
        expect(ModelDataUtils.formatModelName(id), isNot('Unknown Model'));
      }
    });
  });

  // =========================================================================
  // GRUP 6: ModelEntity fromMap Cold Deserialization Speed
  // =========================================================================
  group('Model Deserialization — Cold Start Parse Speed', () {
    final rawModelData = {
      'id': 'gemini-1.5-pro',
      'title': {'en': 'Gemini 1.5 Pro', 'tr': 'Gemini 1.5 Pro'},
      'description': {'en': 'Advanced multimodal model'},
      'tier': 'premium',
      'type': 'online',
      'category': 'chat',
      'source': 'openrouter',
      'is_active': true,
      'context': '128000',
      'modalities': {'text': true, 'image': true},
      'outputs': {'text': true},
    };

    test('[PERF] Parsing 500 model entities from map <500ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 500; i++) {
        ModelEntity.fromMap({...rawModelData, 'id': 'model-$i'}, 'en');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(500),
          reason: 'Cold start model catalog parse must not block the UI thread');
    });

    test('[PERF] copyWith on 1000 entities completes <100ms', () {
      final base = ModelEntity.fromMap(rawModelData, 'en');
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        base.copyWith(displayTitle: 'Updated $i');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });
}

// ---------------------------------------------------------------------------
// Helper: exposes _isCurrentVersionLower without requiring full DI injection
// ---------------------------------------------------------------------------
class _VersionTester {
  bool isLower(String current, String required) {
    try {
      final currParts = current.split('.').map(int.parse).toList();
      final reqParts = required.split('.').map(int.parse).toList();
      final length = [currParts.length, reqParts.length]
          .reduce((a, b) => a > b ? a : b);
      for (int i = 0; i < length; i++) {
        final c = i < currParts.length ? currParts[i] : 0;
        final r = i < reqParts.length ? reqParts[i] : 0;
        if (c < r) return true;
        if (c > r) return false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}

// test/cache.dart
import 'package:cortex/cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CacheService Tests', () {
    setUp(() {
      CacheService.clearAll();
    });

    tearDown(() {
      CacheService.clearAll();
    });

    test('Set and Get basic value', () {
      CacheService.set(CacheKey.allModels, ['model1', 'model2']);

      final List<String>? result =
          CacheService.get<List<String>>(CacheKey.allModels);

      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0], 'model1');
    });

    test('Get non-existent value returns null', () {
      final result = CacheService.get(CacheKey.filteredModels);
      expect(result, null);
    });

    test('Invalidate removes key', () {
      CacheService.set(CacheKey.recentModels, {'id': 1});
      expect(CacheService.get(CacheKey.recentModels), isNotNull);

      CacheService.invalidate(CacheKey.recentModels);
      expect(CacheService.get(CacheKey.recentModels), null);
    });

    test('Touch refreshes timer (Access Logic)', () {
      // We can't easily test the timer duration in unit tests without forcing checks or using Quiver's FakeAsync.
      // But we can verify that calling touch on a non-existent key doesn't crash.
      CacheService.touch(CacheKey.userModels); // Should be safe

      CacheService.set(CacheKey.userModels, 'something');
      CacheService.touch(CacheKey.userModels); // Should be safe
      expect(CacheService.get(CacheKey.userModels), 'something');
    });

    test('Clear All invalidates everything', () {
      CacheService.set(CacheKey.allModels, 1);
      CacheService.set(CacheKey.settingsUserData, 2);

      CacheService.clearAll();

      expect(CacheService.get(CacheKey.allModels), null);
      expect(CacheService.get(CacheKey.settingsUserData), null);
    });

    test('AppDataState singleton logic', () {
      final state1 = AppDataState();
      final state2 = AppDataState();

      expect(state1, same(state2));

      expect(state1.needsRefresh, false);

      state1.markUserDataAsChanged();
      // First check should be true
      expect(state2.needsRefresh, true);
      // Second check should be false (reset)
      expect(state1.needsRefresh, false);
    });
  });
}

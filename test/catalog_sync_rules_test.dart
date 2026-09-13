// Regression tests for the catalog sync decision rules in ModelRepository.
//
// Architecture under test (the real GET is the source of truth):
// - No HEAD probe and no generic third-party host check gates catalog
//   behavior. When a sync is warranted (empty DB, stale cache, language
//   change) the real catalog fetch is attempted directly and its actual
//   failure is classified (DNS, timeout, TLS, HTTP status, parsing).
// - Known-good local data is never replaced by failed/empty sync data.
// - An empty result is never memoized as the session cache, so a temporary
//   failure never permanently prevents future synchronization.
// - Automatic fetch attempts back off exponentially while the catalog host
//   is unavailable (bounded retry rate, session-scoped, reset by success);
//   the explicit user Retry action bypasses the backoff entirely.

import 'package:cortex/library/backend/data/repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelRepository.isSyncRequired', () {
    test('attempts the real fetch when the database is empty', () {
      expect(
        ModelRepository.isSyncRequired(
            isDbEmpty: true, isCacheStale: true, isLangChanged: false),
        isTrue,
      );
    });

    test('attempts the fetch when the cached catalog is stale', () {
      expect(
        ModelRepository.isSyncRequired(
            isDbEmpty: false, isCacheStale: true, isLangChanged: false),
        isTrue,
      );
    });

    test('attempts the fetch when the display language changed', () {
      expect(
        ModelRepository.isSyncRequired(
            isDbEmpty: false, isCacheStale: false, isLangChanged: true),
        isTrue,
      );
    });

    test(
        'a fresh, populated catalog needs no network fetch '
        '(reachability is proven by the fetch itself, never by probes)',
        () {
      expect(
        ModelRepository.isSyncRequired(
            isDbEmpty: false, isCacheStale: false, isLangChanged: false),
        isFalse,
      );
    });
  });

  group('ModelRepository.syncRetryBackoff', () {
    test('no failures means no backoff (first attempt is immediate)', () {
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 0),
        Duration.zero,
      );
    });

    test('grows exponentially: 30s, 1m, 2m, 4m, 8m', () {
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 1),
        const Duration(seconds: 30),
      );
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 2),
        const Duration(minutes: 1),
      );
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 3),
        const Duration(minutes: 2),
      );
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 4),
        const Duration(minutes: 4),
      );
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 5),
        const Duration(minutes: 8),
      );
    });

    test('caps at 10 minutes regardless of the failure count', () {
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 6),
        const Duration(minutes: 10),
      );
      expect(
        ModelRepository.syncRetryBackoff(consecutiveFailures: 1000),
        const Duration(minutes: 10),
      );
    });
  });

  group('ModelRepository.isBackoffElapsed', () {
    final now = DateTime(2026, 1, 1, 12, 0, 0);

    test('no recorded failure means the automatic attempt is allowed', () {
      expect(
        ModelRepository.isBackoffElapsed(
            lastFailureAt: null, consecutiveFailures: 0, now: now),
        isTrue,
      );
    });

    test('a failure recorded but a zeroed counter allows the attempt', () {
      // Defensive: a success resets the counter, so even if the timestamp
      // were left behind, the next attempt must not be suppressed.
      expect(
        ModelRepository.isBackoffElapsed(
          lastFailureAt: now.subtract(const Duration(seconds: 1)),
          consecutiveFailures: 0,
          now: now,
        ),
        isTrue,
      );
    });

    test('a recent failure still blocks the automatic attempt', () {
      expect(
        ModelRepository.isBackoffElapsed(
          lastFailureAt: now.subtract(const Duration(seconds: 5)),
          consecutiveFailures: 1,
          now: now,
        ),
        isFalse,
      );
    });

    test('the first (30s) backoff window elapses and the attempt is allowed',
        () {
      expect(
        ModelRepository.isBackoffElapsed(
          lastFailureAt: now.subtract(const Duration(seconds: 31)),
          consecutiveFailures: 1,
          now: now,
        ),
        isTrue,
      );
    });

    test('deeper failures require proportionally longer waits', () {
      // 31 seconds after the 2nd consecutive failure: still blocked (60s).
      expect(
        ModelRepository.isBackoffElapsed(
          lastFailureAt: now.subtract(const Duration(seconds: 31)),
          consecutiveFailures: 2,
          now: now,
        ),
        isFalse,
      );
      // 61 seconds after the 2nd consecutive failure: allowed.
      expect(
        ModelRepository.isBackoffElapsed(
          lastFailureAt: now.subtract(const Duration(seconds: 61)),
          consecutiveFailures: 2,
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('ModelRepository.shouldMemoizeRawCache', () {
    test('memoizes populated database contents', () {
      expect(
        ModelRepository.shouldMemoizeRawCache(dbHasModels: true),
        isTrue,
      );
    });

    test(
        'never memoizes an empty database result (cache poisoning guard)',
        () {
      // Both a failed sync and a pathologically empty-but-successful sync
      // must leave the raw cache unset so later calls retry the pipeline
      // instead of instantly serving `[]` forever without a network attempt.
      expect(
        ModelRepository.shouldMemoizeRawCache(dbHasModels: false),
        isFalse,
      );
    });
  });
}

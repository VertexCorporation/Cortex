import 'package:cortex/performance/ttl_lru_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LRU access refreshes eviction order', () {
    var now = 0;
    final cache = TtlLruCache<String, int>(
      defaultTtl: const Duration(seconds: 10),
      maxEntries: 2,
      clockMicros: () => now,
    );

    cache.set('a', 1);
    cache.set('b', 2);
    expect(cache.get('a'), 1);
    cache.set('c', 3);

    expect(cache.peek('a'), 1);
    expect(cache.peek('b'), isNull);
    expect(cache.peek('c'), 3);
    expect(cache.stats.evictions, 1);
  });

  test('expired values are misses and are removed lazily', () {
    var now = 0;
    final cache = TtlLruCache<String, int>(
      defaultTtl: const Duration(milliseconds: 10),
      clockMicros: () => now,
    );
    cache.set('a', 1);
    now = const Duration(milliseconds: 11).inMicroseconds;

    expect(cache.get('a'), isNull);
    expect(cache.length, 0);
    expect(cache.stats.expirations, 1);
    expect(cache.stats.misses, 1);
  });

  test('weight bound evicts least recently used values', () {
    final cache = TtlLruCache<String, String>(
      defaultTtl: const Duration(minutes: 1),
      maxEntries: 10,
      maxWeight: 5,
      weigh: (_, value) => value.length,
    );

    cache.set('a', 'aa');
    cache.set('b', 'bb');
    cache.set('c', 'cc');
    expect(cache.peek('a'), isNull);
    expect(cache.peek('b'), 'bb');
    expect(cache.peek('c'), 'cc');
    expect(cache.weight, 4);
  });

  test('getOrPut computes only on miss', () {
    final cache = TtlLruCache<String, int>(
      defaultTtl: const Duration(minutes: 1),
    );
    var calls = 0;

    expect(cache.getOrPut('x', () => ++calls), 1);
    expect(cache.getOrPut('x', () => ++calls), 1);
    expect(calls, 1);
    expect(cache.stats.hits, 1);
    expect(cache.stats.misses, 1);
  });

  test('pruneExpired removes expired entries anywhere in cache', () {
    var now = 0;
    final cache = TtlLruCache<String, int>(
      defaultTtl: const Duration(milliseconds: 100),
      clockMicros: () => now,
    );
    cache.set('long', 1, ttl: const Duration(milliseconds: 100));
    cache.set('short', 2, ttl: const Duration(milliseconds: 5));
    now = const Duration(milliseconds: 10).inMicroseconds;

    expect(cache.pruneExpired(), 1);
    expect(cache.peek('long'), 1);
    expect(cache.peek('short'), isNull);
  });
}

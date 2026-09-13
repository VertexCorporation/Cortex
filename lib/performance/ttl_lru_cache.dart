import 'dart:collection';

class CacheStats {
  const CacheStats({
    required this.hits,
    required this.misses,
    required this.expirations,
    required this.evictions,
    required this.writes,
  });

  final int hits;
  final int misses;
  final int expirations;
  final int evictions;
  final int writes;

  int get requests => hits + misses;
  double get hitRate => requests == 0 ? 0 : hits / requests;

  @override
  String toString() =>
      'CacheStats(hits: $hits, misses: $misses, expirations: $expirations, '
      'evictions: $evictions, writes: $writes, hitRate: $hitRate)';
}

class _CacheEntry<V> {
  _CacheEntry({
    required this.value,
    required this.expiresAtMicros,
    required this.weight,
  });

  V value;
  int expiresAtMicros;
  int weight;
}

/// Bounded in-memory cache with lazy TTL expiration and LRU eviction.
/// No Timer is allocated per entry.
class TtlLruCache<K, V> {
  TtlLruCache({
    required this.defaultTtl,
    this.maxEntries = 256,
    this.maxWeight,
    int Function(K key, V value)? weigh,
    int Function()? clockMicros,
  })  : assert(maxEntries > 0),
        assert(maxWeight == null || maxWeight > 0),
        _weigh = weigh ?? ((_, _) => 1),
        _clockMicros = clockMicros ?? _systemMicros;

  final Duration defaultTtl;
  final int maxEntries;
  final int? maxWeight;
  final int Function(K key, V value) _weigh;
  final int Function() _clockMicros;

  final LinkedHashMap<K, _CacheEntry<V>> _entries =
      LinkedHashMap<K, _CacheEntry<V>>();

  int _weight = 0;
  int _hits = 0;
  int _misses = 0;
  int _expirations = 0;
  int _evictions = 0;
  int _writes = 0;

  static int _systemMicros() => DateTime.now().microsecondsSinceEpoch;

  int get length => _entries.length;
  int get weight => _weight;
  bool get isEmpty => _entries.isEmpty;
  bool get isNotEmpty => _entries.isNotEmpty;

  CacheStats get stats => CacheStats(
        hits: _hits,
        misses: _misses,
        expirations: _expirations,
        evictions: _evictions,
        writes: _writes,
      );

  Iterable<K> get keys => _entries.keys;

  bool containsKey(K key) {
    final entry = _entries[key];
    if (entry == null) return false;
    if (_isExpired(entry)) {
      _removeEntry(key, expired: true);
      return false;
    }
    return true;
  }

  V? peek(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_isExpired(entry)) {
      _removeEntry(key, expired: true);
      return null;
    }
    return entry.value;
  }

  V? get(K key) {
    final entry = _entries.remove(key);
    if (entry == null) {
      _misses++;
      return null;
    }

    if (_isExpired(entry)) {
      _weight -= entry.weight;
      _expirations++;
      _misses++;
      return null;
    }

    _entries[key] = entry;
    _hits++;
    return entry.value;
  }

  V getOrPut(
    K key,
    V Function() producer, {
    Duration? ttl,
  }) {
    final entry = _entries.remove(key);
    if (entry != null && !_isExpired(entry)) {
      _entries[key] = entry;
      _hits++;
      return entry.value;
    }
    if (entry != null) {
      _weight -= entry.weight;
      _expirations++;
    }
    _misses++;
    final value = producer();
    set(key, value, ttl: ttl);
    return value;
  }

  Future<V> getOrPutAsync(
    K key,
    Future<V> Function() producer, {
    Duration? ttl,
  }) async {
    final entry = _entries.remove(key);
    if (entry != null && !_isExpired(entry)) {
      _entries[key] = entry;
      _hits++;
      return entry.value;
    }
    if (entry != null) {
      _weight -= entry.weight;
      _expirations++;
    }
    _misses++;
    final value = await producer();
    set(key, value, ttl: ttl);
    return value;
  }

  void set(K key, V value, {Duration? ttl}) {
    final old = _entries.remove(key);
    if (old != null) _weight -= old.weight;

    final entryWeight = _weigh(key, value).clamp(1, 1 << 30).toInt();
    final effectiveTtl = ttl ?? defaultTtl;
    final expiresAt = _clockMicros() + effectiveTtl.inMicroseconds;
    _entries[key] = _CacheEntry<V>(
      value: value,
      expiresAtMicros: expiresAt,
      weight: entryWeight,
    );
    _weight += entryWeight;
    _writes++;

    _evictExpiredFromFront();
    _enforceBounds();
  }

  void setAll(Map<K, V> values, {Duration? ttl}) {
    for (final entry in values.entries) {
      set(entry.key, entry.value, ttl: ttl);
    }
  }

  bool remove(K key) => _removeEntry(key);

  int removeWhere(bool Function(K key, V value) predicate) {
    if (_entries.isEmpty) return 0;
    final removeKeys = <K>[];
    for (final item in _entries.entries) {
      if (predicate(item.key, item.value.value)) removeKeys.add(item.key);
    }
    for (final key in removeKeys) {
      _removeEntry(key);
    }
    return removeKeys.length;
  }

  void clear() {
    _entries.clear();
    _weight = 0;
  }

  int pruneExpired() {
    if (_entries.isEmpty) return 0;
    final now = _clockMicros();
    final expired = <K>[];
    for (final item in _entries.entries) {
      if (item.value.expiresAtMicros <= now) expired.add(item.key);
    }
    for (final key in expired) {
      _removeEntry(key, expired: true);
    }
    return expired.length;
  }

  Map<K, V> snapshot() {
    pruneExpired();
    return <K, V>{
      for (final entry in _entries.entries) entry.key: entry.value.value,
    };
  }

  Duration? remainingTtl(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    final remaining = entry.expiresAtMicros - _clockMicros();
    if (remaining <= 0) {
      _removeEntry(key, expired: true);
      return null;
    }
    return Duration(microseconds: remaining);
  }

  void refresh(K key, {Duration? ttl}) {
    final entry = _entries.remove(key);
    if (entry == null) return;
    if (_isExpired(entry)) {
      _weight -= entry.weight;
      _expirations++;
      return;
    }
    entry.expiresAtMicros =
        _clockMicros() + (ttl ?? defaultTtl).inMicroseconds;
    _entries[key] = entry;
  }

  bool _isExpired(_CacheEntry<V> entry) =>
      entry.expiresAtMicros <= _clockMicros();

  bool _removeEntry(K key, {bool expired = false}) {
    final removed = _entries.remove(key);
    if (removed == null) return false;
    _weight -= removed.weight;
    if (expired) _expirations++;
    return true;
  }

  void _evictExpiredFromFront() {
    if (_entries.isEmpty) return;
    final now = _clockMicros();
    while (_entries.isNotEmpty) {
      final first = _entries.entries.first;
      if (first.value.expiresAtMicros > now) break;
      _entries.remove(first.key);
      _weight -= first.value.weight;
      _expirations++;
    }
  }

  void _enforceBounds() {
    while (_entries.length > maxEntries ||
        (maxWeight != null && _weight > maxWeight!)) {
      if (_entries.isEmpty) break;
      final first = _entries.entries.first;
      _entries.remove(first.key);
      _weight -= first.value.weight;
      _evictions++;
    }
  }

  void resetStats() {
    _hits = 0;
    _misses = 0;
    _expirations = 0;
    _evictions = 0;
    _writes = 0;
  }
}

class NullableCacheValue<V> {
  const NullableCacheValue(this.value);
  final V? value;
}

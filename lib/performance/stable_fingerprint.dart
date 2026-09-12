/// Fast deterministic fingerprints for JSON-like values.
///
/// Fingerprints are an optimization hint, not an integrity primitive. Callers
/// that suppress correctness-sensitive work must pair a matching fingerprint
/// with [deepEquals]; [FingerprintGuard] does this automatically.
class StableFingerprint {
  const StableFingerprint._();

  static int of(Object? value) {
    var hash = 0x811c9dc5;
    hash = _mixValue(hash, value);
    return hash & 0x7fffffff;
  }

  static int _mixValue(int hash, Object? value) {
    if (value == null) return _mixInt(hash, 0x01);
    if (value is bool) return _mixInt(hash, value ? 0x11 : 0x12);
    if (value is int) return _mixInt(_mixInt(hash, 0x21), value);
    if (value is double) {
      return _mixString(_mixInt(hash, 0x22), value.toStringAsPrecision(17));
    }
    if (value is num) {
      return _mixString(_mixInt(hash, 0x23), value.toString());
    }
    if (value is String) return _mixString(_mixInt(hash, 0x31), value);
    if (value is DateTime) {
      return _mixInt(_mixInt(hash, 0x32), value.microsecondsSinceEpoch);
    }
    if (value is Iterable) {
      var out = _mixInt(hash, 0x41);
      var length = 0;
      for (final item in value) {
        out = _mixValue(out, item);
        length++;
      }
      return _mixInt(out, length);
    }
    if (value is Map) {
      var out = _mixInt(hash, 0x51);
      final entries = value.entries.toList(growable: false)
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      for (final entry in entries) {
        out = _mixString(out, entry.key.toString());
        out = _mixValue(out, entry.value);
      }
      return _mixInt(out, entries.length);
    }
    return _mixString(_mixInt(hash, 0x61), value.toString());
  }

  /// Exact structural comparison for map/list/scalar state.
  static bool deepEquals(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final entry in a.entries) {
        if (!b.containsKey(entry.key)) return false;
        if (!deepEquals(entry.value, b[entry.key])) return false;
      }
      return true;
    }

    if (a is Iterable && b is Iterable) {
      final left = a.iterator;
      final right = b.iterator;
      while (true) {
        final hasLeft = left.moveNext();
        final hasRight = right.moveNext();
        if (hasLeft != hasRight) return false;
        if (!hasLeft) return true;
        if (!deepEquals(left.current, right.current)) return false;
      }
    }

    return a == b;
  }

  /// Defensive structural snapshot for mutable map/list input.
  static Object? snapshot(Object? value) {
    if (value is Map) {
      return <Object?, Object?>{
        for (final entry in value.entries) entry.key: snapshot(entry.value),
      };
    }
    if (value is Iterable) {
      return value.map(snapshot).toList(growable: false);
    }
    return value;
  }

  static int _mixString(int hash, String value) {
    var out = hash;
    for (final unit in value.codeUnits) {
      out ^= unit;
      out = (out * 0x01000193) & 0xffffffff;
    }
    return out;
  }

  static int _mixInt(int hash, int value) {
    var out = hash;
    var x = value;
    for (var i = 0; i < 8; i++) {
      out ^= x & 0xff;
      out = (out * 0x01000193) & 0xffffffff;
      x >>= 8;
    }
    return out;
  }
}

/// Reports whether a value materially changed. Matching fingerprints are
/// verified with exact structural equality before a change is suppressed.
class FingerprintGuard {
  int? _lastHash;
  Object? _lastSnapshot;
  bool _hasValue = false;

  int? get last => _lastHash;

  bool changed(Object? value) {
    final nextHash = StableFingerprint.of(value);
    if (_hasValue &&
        _lastHash == nextHash &&
        StableFingerprint.deepEquals(_lastSnapshot, value)) {
      return false;
    }
    _lastHash = nextHash;
    _lastSnapshot = StableFingerprint.snapshot(value);
    _hasValue = true;
    return true;
  }

  void reset() {
    _lastHash = null;
    _lastSnapshot = null;
    _hasValue = false;
  }
}

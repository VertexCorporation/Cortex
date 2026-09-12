import 'dart:io';

import 'ttl_lru_cache.dart';

/// Snapshot of inexpensive filesystem metadata used by hot UI paths.
class FileProbe {
  const FileProbe({
    required this.exists,
    this.length,
    this.modifiedMicros,
  });

  final bool exists;
  final int? length;
  final int? modifiedMicros;

  static const missing = FileProbe(exists: false);
}

/// Short-lived cache around synchronous filesystem probes.
///
/// Flutter build methods sometimes need to choose between an asset and a local
/// file. Repeating `File.existsSync()` for the same path on every rebuild can
/// become visible on slow flash storage. This cache keeps that decision hot for
/// a small TTL while exposing explicit invalidation hooks for writers.
class FileProbeCache {
  FileProbeCache({
    Duration ttl = const Duration(seconds: 3),
    int maxEntries = 512,
  }) : _cache = TtlLruCache<String, FileProbe>(
          defaultTtl: ttl,
          maxEntries: maxEntries,
        );

  static final FileProbeCache shared = FileProbeCache();

  final TtlLruCache<String, FileProbe> _cache;

  int get length => _cache.length;
  CacheStats get stats => _cache.stats;

  bool existsSync(String? path) {
    if (path == null || path.isEmpty) return false;
    return probeSync(path).exists;
  }

  FileProbe probeSync(String path) {
    final cached = _cache.get(path);
    if (cached != null) return cached;

    try {
      final type = FileSystemEntity.typeSync(path, followLinks: true);
      if (type == FileSystemEntityType.notFound) {
        _cache.set(path, FileProbe.missing);
        return FileProbe.missing;
      }

      if (type != FileSystemEntityType.file) {
        final probe = FileProbe(exists: true);
        _cache.set(path, probe);
        return probe;
      }

      final stat = FileStat.statSync(path);
      final probe = FileProbe(
        exists: stat.type == FileSystemEntityType.file,
        length: stat.size,
        modifiedMicros: stat.modified.microsecondsSinceEpoch,
      );
      _cache.set(path, probe);
      return probe;
    } catch (_) {
      _cache.set(path, FileProbe.missing,
          ttl: const Duration(milliseconds: 400));
      return FileProbe.missing;
    }
  }

  Future<bool> exists(String? path) async {
    if (path == null || path.isEmpty) return false;
    final cached = _cache.get(path);
    if (cached != null) return cached.exists;

    try {
      final file = File(path);
      final exists = await file.exists();
      if (!exists) {
        _cache.set(path, FileProbe.missing);
        return false;
      }
      final stat = await file.stat();
      _cache.set(
        path,
        FileProbe(
          exists: true,
          length: stat.size,
          modifiedMicros: stat.modified.microsecondsSinceEpoch,
        ),
      );
      return true;
    } catch (_) {
      _cache.set(path, FileProbe.missing,
          ttl: const Duration(milliseconds: 400));
      return false;
    }
  }

  void noteWritten(
    String path, {
    int? length,
    DateTime? modified,
  }) {
    if (path.isEmpty) return;
    _cache.set(
      path,
      FileProbe(
        exists: true,
        length: length,
        modifiedMicros: modified?.microsecondsSinceEpoch,
      ),
    );
  }

  void noteDeleted(String path) {
    if (path.isEmpty) return;
    _cache.set(path, FileProbe.missing);
  }

  void invalidate(String? path) {
    if (path == null || path.isEmpty) return;
    _cache.remove(path);
  }

  int invalidatePrefix(String prefix) {
    if (prefix.isEmpty) return 0;
    return _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  void clear() => _cache.clear();
}

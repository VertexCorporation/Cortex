import 'dart:async';

/// Coalesces replaceable persistence work so only the newest value is written.
///
/// Intended for caches/preferences, never for transaction logs. Writer errors
/// are reported through [onError] and do not strand the queue.
class LatestWriteQueue<T> {
  LatestWriteQueue({
    required this.writer,
    this.delay = Duration.zero,
    this.onError,
  });

  final Future<void> Function(T value) writer;
  final Duration delay;
  final void Function(Object error, StackTrace stackTrace)? onError;

  T? _pending;
  bool _hasPending = false;
  bool _writing = false;
  bool _disposed = false;
  Timer? _timer;
  Completer<void>? _idleCompleter;

  bool get isWriting => _writing;
  bool get hasPending => _hasPending;
  bool get isIdle => !_writing && !_hasPending && _timer == null;

  void add(T value) {
    if (_disposed) return;
    _pending = value;
    _hasPending = true;
    _idleCompleter ??= Completer<void>();
    _schedule();
  }

  void _schedule() {
    if (_disposed || _writing) return;
    if (delay == Duration.zero) {
      scheduleMicrotask(() {
        _flushLoop().catchError((Object error, StackTrace stack) {
          onError?.call(error, stack);
        });
      });
      return;
    }
    _timer?.cancel();
    _timer = Timer(delay, () {
      _timer = null;
      _flushLoop().catchError((Object error, StackTrace stack) {
        onError?.call(error, stack);
      });
    });
  }

  Future<void> _flushLoop() async {
    if (_disposed || _writing || !_hasPending) return;
    _writing = true;
    try {
      while (!_disposed && _hasPending) {
        final value = _pending as T;
        _pending = null;
        _hasPending = false;
        try {
          await writer(value);
        } catch (error, stack) {
          onError?.call(error, stack);
        }
      }
    } finally {
      _writing = false;
      _completeIdleIfPossible();
      if (!_disposed && _hasPending) _schedule();
    }
  }

  void _completeIdleIfPossible() {
    if (!isIdle) return;
    final completer = _idleCompleter;
    _idleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  Future<void> flush() async {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    if (_hasPending && !_writing) await _flushLoop();
    await idle;
  }

  Future<void> get idle {
    if (isIdle) return Future<void>.value();
    _idleCompleter ??= Completer<void>();
    return _idleCompleter!.future;
  }

  Future<void> dispose({bool flushPending = true}) async {
    if (_disposed) return;
    if (flushPending) await flush();
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _pending = null;
    _hasPending = false;
    _completeIdleIfPossible();
  }
}

/// Keyed write-behind queue. Every key keeps its newest value while different
/// keys survive account/document changes independently.
class KeyedLatestWriteQueue<K, V> {
  KeyedLatestWriteQueue({
    required this.writer,
    this.delay = Duration.zero,
    this.onError,
  });

  final Future<void> Function(Map<K, V> values) writer;
  final Duration delay;
  final void Function(Object error, StackTrace stackTrace)? onError;

  final Map<K, V> _pending = <K, V>{};
  bool _writing = false;
  bool _disposed = false;
  Timer? _timer;
  Completer<void>? _idleCompleter;

  int get pendingCount => _pending.length;
  bool get isIdle => !_writing && _pending.isEmpty && _timer == null;

  void add(K key, V value) {
    if (_disposed) return;
    _pending[key] = value;
    _idleCompleter ??= Completer<void>();
    _schedule();
  }

  void addAll(Map<K, V> values) {
    if (_disposed || values.isEmpty) return;
    _pending.addAll(values);
    _idleCompleter ??= Completer<void>();
    _schedule();
  }

  void _schedule() {
    if (_disposed || _writing) return;
    if (delay == Duration.zero) {
      scheduleMicrotask(() {
        _flushLoop().catchError((Object error, StackTrace stack) {
          onError?.call(error, stack);
        });
      });
      return;
    }
    _timer?.cancel();
    _timer = Timer(delay, () {
      _timer = null;
      _flushLoop().catchError((Object error, StackTrace stack) {
        onError?.call(error, stack);
      });
    });
  }

  Future<void> _flushLoop() async {
    if (_disposed || _writing || _pending.isEmpty) return;
    _writing = true;
    try {
      while (!_disposed && _pending.isNotEmpty) {
        final batch = Map<K, V>.from(_pending);
        for (final key in batch.keys) {
          _pending.remove(key);
        }
        try {
          await writer(batch);
        } catch (error, stack) {
          onError?.call(error, stack);
        }
      }
    } finally {
      _writing = false;
      _completeIdleIfPossible();
      if (!_disposed && _pending.isNotEmpty) _schedule();
    }
  }

  void _completeIdleIfPossible() {
    if (!isIdle) return;
    final completer = _idleCompleter;
    _idleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  Future<void> flush() async {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    if (_pending.isNotEmpty && !_writing) await _flushLoop();
    await idle;
  }

  Future<void> get idle {
    if (isIdle) return Future<void>.value();
    _idleCompleter ??= Completer<void>();
    return _idleCompleter!.future;
  }

  Future<void> dispose({bool flushPending = true}) async {
    if (_disposed) return;
    if (flushPending) await flush();
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _pending.clear();
    _completeIdleIfPossible();
  }
}

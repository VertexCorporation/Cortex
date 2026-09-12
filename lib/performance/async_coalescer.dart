import 'dart:async';

/// Coalesces concurrent asynchronous work by key.
///
/// If multiple callers request the same [key] while the first computation is
/// still running, every caller receives the same [Future]. Once that future
/// completes (successfully or with an error), the key is released and a later
/// call can retry normally.
///
/// This is intentionally small and dependency-free so it can be used from
/// repositories, services, startup code and test doubles without pulling UI
/// concerns into lower layers.
class AsyncKeyedCoalescer<K, V> {
  final Map<K, Future<V>> _inFlight = <K, Future<V>>{};

  int get inFlightCount => _inFlight.length;
  bool get isBusy => _inFlight.isNotEmpty;
  Iterable<K> get inFlightKeys => _inFlight.keys;

  bool contains(K key) => _inFlight.containsKey(key);

  Future<V> run(K key, FutureOr<V> Function() action) {
    final existing = _inFlight[key];
    if (existing != null) return existing;

    late Future<V> future;
    future = Future<V>.sync(action).whenComplete(() {
      if (identical(_inFlight[key], future)) {
        _inFlight.remove(key);
      }
    });
    _inFlight[key] = future;
    return future;
  }

  /// Drops bookkeeping only. Running work cannot be force-cancelled by a
  /// generic coalescer; callers should use operation-specific cancellation.
  void forget(K key) {
    _inFlight.remove(key);
  }

  void clear() {
    _inFlight.clear();
  }
}

/// Coalesces one unkeyed asynchronous operation at a time.
class AsyncCoalescer<V> {
  Future<V>? _inFlight;

  bool get isBusy => _inFlight != null;

  Future<V> run(FutureOr<V> Function() action) {
    final existing = _inFlight;
    if (existing != null) return existing;

    late Future<V> future;
    future = Future<V>.sync(action).whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    _inFlight = future;
    return future;
  }

  void forget() {
    _inFlight = null;
  }
}

/// A generation token used to discard results produced for stale state.
///
/// This is useful for account/language/conversation changes where the I/O
/// itself may not be cancellable but its result must not overwrite newer state.
class OperationGeneration {
  int _value = 0;

  int get value => _value;

  int next() => ++_value;

  bool isCurrent(int generation) => generation == _value;

  void invalidate() {
    _value++;
  }
}

/// A small serial executor. Work is queued without allocating a Stream or
/// isolate and failures in one action do not poison later actions.
class SerialExecutor {
  Future<void> _tail = Future<void>.value();
  int _queued = 0;

  int get queued => _queued;
  bool get isBusy => _queued > 0;

  Future<T> run<T>(FutureOr<T> Function() action) {
    final completer = Completer<T>();
    _queued++;

    _tail = _tail.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        _queued--;
      }
    }, onError: (_) async {
      // A prior action's failure is already delivered to its own completer.
      // Keep the queue alive for subsequent work.
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        _queued--;
      }
    });

    return completer.future;
  }
}

/// Batches a burst of invalidation requests into a single asynchronous flush.
///
/// The first request schedules a microtask. Additional requests before that
/// microtask runs are folded into the same callback.
class MicrotaskCoalescer {
  bool _scheduled = false;
  bool _disposed = false;

  bool get isScheduled => _scheduled;

  void schedule(void Function() callback) {
    if (_disposed || _scheduled) return;
    _scheduled = true;
    scheduleMicrotask(() {
      _scheduled = false;
      if (_disposed) return;
      callback();
    });
  }

  void dispose() {
    _disposed = true;
    _scheduled = false;
  }
}

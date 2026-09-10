import 'dart:async';
import 'dart:collection';

class PoolResult<T> {
  const PoolResult({required this.values, required this.errors});

  final List<T?> values;
  final List<PoolError> errors;

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => values.whereType<T>().length;
}

class PoolError {
  const PoolError({
    required this.index,
    required this.error,
    required this.stackTrace,
  });

  final int index;
  final Object error;
  final StackTrace stackTrace;
}

/// Runs list work with a fixed upper bound on concurrent operations.
class BoundedPool {
  const BoundedPool({required this.concurrency}) : assert(concurrency > 0);

  final int concurrency;

  Future<List<R>> map<T, R>(
    Iterable<T> items,
    Future<R> Function(T item, int index) worker,
  ) async {
    final input = items.toList(growable: false);
    if (input.isEmpty) return <R>[];

    final results = List<R?>.filled(input.length, null);
    var next = 0;
    Object? firstError;
    StackTrace? firstStack;

    Future<void> runner() async {
      while (true) {
        if (firstError != null) return;
        final index = next++;
        if (index >= input.length) return;
        try {
          results[index] = await worker(input[index], index);
        } catch (error, stack) {
          firstError ??= error;
          firstStack ??= stack;
          return;
        }
      }
    }

    final workerCount = concurrency < input.length ? concurrency : input.length;
    await Future.wait(List<Future<void>>.generate(workerCount, (_) => runner()));

    if (firstError != null) {
      Error.throwWithStackTrace(firstError!, firstStack ?? StackTrace.current);
    }
    return results.cast<R>();
  }

  Future<PoolResult<R>> mapSettled<T, R>(
    Iterable<T> items,
    Future<R> Function(T item, int index) worker,
  ) async {
    final input = items.toList(growable: false);
    final results = List<R?>.filled(input.length, null);
    final errors = <PoolError>[];
    var next = 0;

    Future<void> runner() async {
      while (true) {
        final index = next++;
        if (index >= input.length) return;
        try {
          results[index] = await worker(input[index], index);
        } catch (error, stack) {
          errors.add(PoolError(index: index, error: error, stackTrace: stack));
        }
      }
    }

    final workerCount = concurrency < input.length ? concurrency : input.length;
    await Future.wait(List<Future<void>>.generate(workerCount, (_) => runner()));
    errors.sort((a, b) => a.index.compareTo(b.index));
    return PoolResult<R>(values: results, errors: errors);
  }
}

/// Fair asynchronous semaphore with direct permit handoff to queued waiters.
class AsyncSemaphore {
  AsyncSemaphore(this.maxPermits) : assert(maxPermits > 0);

  final int maxPermits;
  int _active = 0;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  int get active => _active;
  int get waiting => _waiters.length;
  bool get isSaturated => _active >= maxPermits;

  Future<void> acquire() async {
    if (_active < maxPermits && _waiters.isEmpty) {
      _active++;
      return;
    }
    final completer = Completer<void>();
    _waiters.addLast(completer);
    await completer.future;
    // release() transfers an existing permit directly to this waiter, so
    // _active intentionally does not change here.
  }

  void release() {
    if (_active <= 0) {
      throw StateError('AsyncSemaphore.release called without a permit');
    }
    if (_waiters.isNotEmpty) {
      final waiter = _waiters.removeFirst();
      if (!waiter.isCompleted) waiter.complete();
      return;
    }
    _active--;
  }

  Future<T> withPermit<T>(Future<T> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}

class BoundedWorkQueue {
  BoundedWorkQueue({required int concurrency})
      : _semaphore = AsyncSemaphore(concurrency);

  final AsyncSemaphore _semaphore;
  int _submitted = 0;
  int _completed = 0;
  final Set<Future<void>> _pending = <Future<void>>{};

  int get submitted => _submitted;
  int get completed => _completed;
  int get pending => _pending.length;

  Future<T> submit<T>(Future<T> Function() action) {
    _submitted++;
    final completer = Completer<T>();
    late Future<void> task;
    task = _semaphore.withPermit(() async {
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        _completed++;
      }
    }).whenComplete(() {
      _pending.remove(task);
    });
    _pending.add(task);
    return completer.future;
  }

  Future<void> drain() async {
    while (_pending.isNotEmpty) {
      await Future.wait(_pending.toList(growable: false));
    }
  }
}

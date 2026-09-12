import 'dart:async';

/// Processes CPU-light collections in chunks and yields between chunks.
class AdaptiveBatcher {
  const AdaptiveBatcher({
    this.targetSlice = const Duration(milliseconds: 4),
    this.initialBatchSize = 32,
    this.minBatchSize = 4,
    this.maxBatchSize = 256,
  })  : assert(initialBatchSize > 0),
        assert(minBatchSize > 0),
        assert(maxBatchSize >= minBatchSize);

  final Duration targetSlice;
  final int initialBatchSize;
  final int minBatchSize;
  final int maxBatchSize;

  Future<List<R>> map<T, R>(
    Iterable<T> input,
    R Function(T item, int index) transform,
  ) async {
    final items = input is List<T> ? input : input.toList(growable: false);
    if (items.isEmpty) return <R>[];

    final output = <R>[];
    var cursor = 0;
    var batchSize =
        initialBatchSize.clamp(minBatchSize, maxBatchSize).toInt();

    while (cursor < items.length) {
      final stopwatch = Stopwatch()..start();
      final end = (cursor + batchSize).clamp(0, items.length).toInt();
      for (var i = cursor; i < end; i++) {
        output.add(transform(items[i], i));
      }
      cursor = end;
      stopwatch.stop();

      if (cursor >= items.length) break;
      batchSize = _nextBatchSize(batchSize, stopwatch.elapsedMicroseconds);
      await Future<void>.delayed(Duration.zero);
    }

    return output;
  }

  Future<void> forEach<T>(
    Iterable<T> input,
    void Function(T item, int index) action,
  ) async {
    final items = input is List<T> ? input : input.toList(growable: false);
    var cursor = 0;
    var batchSize =
        initialBatchSize.clamp(minBatchSize, maxBatchSize).toInt();

    while (cursor < items.length) {
      final stopwatch = Stopwatch()..start();
      final end = (cursor + batchSize).clamp(0, items.length).toInt();
      for (var i = cursor; i < end; i++) {
        action(items[i], i);
      }
      cursor = end;
      stopwatch.stop();
      if (cursor >= items.length) break;
      batchSize = _nextBatchSize(batchSize, stopwatch.elapsedMicroseconds);
      await Future<void>.delayed(Duration.zero);
    }
  }

  int _nextBatchSize(int current, int elapsedMicros) {
    if (elapsedMicros <= 0) {
      return (current * 2).clamp(minBatchSize, maxBatchSize).toInt();
    }
    final targetMicros = targetSlice.inMicroseconds;
    if (targetMicros <= 0) return current;

    final ratio = targetMicros / elapsedMicros;
    final adjustedRatio = ratio.clamp(0.5, 2.0).toDouble();
    return (current * adjustedRatio)
        .round()
        .clamp(minBatchSize, maxBatchSize)
        .toInt();
  }
}

class AsyncChunker {
  const AsyncChunker({this.chunkSize = 32}) : assert(chunkSize > 0);

  final int chunkSize;

  Future<List<R>> map<T, R>(
    Iterable<T> input,
    FutureOr<R> Function(T item, int index) transform,
  ) async {
    final items = input is List<T> ? input : input.toList(growable: false);
    final output = <R>[];
    for (var start = 0; start < items.length; start += chunkSize) {
      final end = (start + chunkSize).clamp(0, items.length).toInt();
      for (var i = start; i < end; i++) {
        output.add(await transform(items[i], i));
      }
      if (end < items.length) await Future<void>.delayed(Duration.zero);
    }
    return output;
  }
}

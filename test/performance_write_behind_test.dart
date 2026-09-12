import 'dart:async';

import 'package:cortex/performance/write_behind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LatestWriteQueue collapses a synchronous burst to newest value', () async {
    final writes = <int>[];
    final queue = LatestWriteQueue<int>(
      writer: (value) async => writes.add(value),
    );

    queue.add(1);
    queue.add(2);
    queue.add(3);
    await queue.flush();

    expect(writes, [3]);
  });

  test('new values arriving during a write flush after active write', () async {
    final writes = <int>[];
    final firstGate = Completer<void>();
    final queue = LatestWriteQueue<int>(
      writer: (value) async {
        writes.add(value);
        if (value == 1) await firstGate.future;
      },
    );

    queue.add(1);
    await Future<void>.delayed(Duration.zero);
    queue.add(2);
    queue.add(3);
    firstGate.complete();
    await queue.flush();

    expect(writes, [1, 3]);
  });

  test('writer errors are surfaced and queue remains usable', () async {
    final errors = <Object>[];
    var attempts = 0;
    final queue = LatestWriteQueue<int>(
      writer: (value) async {
        attempts++;
        if (value == 1) throw StateError('disk');
      },
      onError: (error, _) => errors.add(error),
    );

    queue.add(1);
    await queue.flush();
    queue.add(2);
    await queue.flush();

    expect(errors, hasLength(1));
    expect(attempts, 2);
    expect(queue.isIdle, isTrue);
  });

  test('KeyedLatestWriteQueue retains latest value per key', () async {
    final batches = <Map<String, int>>[];
    final queue = KeyedLatestWriteQueue<String, int>(
      writer: (values) async => batches.add(Map<String, int>.from(values)),
    );

    queue.add('a', 1);
    queue.add('b', 2);
    queue.add('a', 3);
    await queue.flush();

    expect(batches, [
      {'a': 3, 'b': 2},
    ]);
  });
}

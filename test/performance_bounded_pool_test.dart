import 'dart:async';

import 'package:cortex/performance/bounded_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoundedPool never exceeds configured concurrency', () async {
    const pool = BoundedPool(concurrency: 3);
    var active = 0;
    var maxActive = 0;

    final values = await pool.map<int, int>(
      List<int>.generate(12, (i) => i),
      (value, _) async {
        active++;
        if (active > maxActive) maxActive = active;
        await Future<void>.delayed(const Duration(milliseconds: 2));
        active--;
        return value * 2;
      },
    );

    expect(maxActive, lessThanOrEqualTo(3));
    expect(values, List<int>.generate(12, (i) => i * 2));
  });

  test('mapSettled preserves successful values and captures failures', () async {
    const pool = BoundedPool(concurrency: 2);
    final result = await pool.mapSettled<int, int>(
      [1, 2, 3, 4],
      (value, _) async {
        if (value.isEven) throw StateError('even');
        return value * 10;
      },
    );

    expect(result.values, [10, null, 30, null]);
    expect(result.errors.map((e) => e.index), [1, 3]);
    expect(result.successCount, 2);
  });

  test('AsyncSemaphore transfers permits fairly without over-release', () async {
    final semaphore = AsyncSemaphore(1);
    final firstGate = Completer<void>();
    final order = <int>[];

    final first = semaphore.withPermit(() async {
      order.add(1);
      await firstGate.future;
    });
    await Future<void>.delayed(Duration.zero);

    final second = semaphore.withPermit(() async {
      order.add(2);
    });
    final third = semaphore.withPermit(() async {
      order.add(3);
    });

    expect(semaphore.active, 1);
    expect(semaphore.waiting, 2);
    firstGate.complete();
    await Future.wait([first, second, third]);

    expect(order, [1, 2, 3]);
    expect(semaphore.active, 0);
    expect(semaphore.waiting, 0);
  });

  test('BoundedWorkQueue drains all submitted work', () async {
    final queue = BoundedWorkQueue(concurrency: 2);
    final values = <int>[];
    final futures = <Future<int>>[];
    for (var i = 0; i < 8; i++) {
      futures.add(queue.submit(() async {
        await Future<void>.delayed(Duration.zero);
        values.add(i);
        return i;
      }));
    }

    await queue.drain();
    expect(await Future.wait(futures), List<int>.generate(8, (i) => i));
    expect(values.toSet(), Set<int>.from(List<int>.generate(8, (i) => i)));
    expect(queue.pending, 0);
    expect(queue.submitted, 8);
    expect(queue.completed, 8);
  });
}

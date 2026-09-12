import 'dart:async';

import 'package:cortex/performance/async_coalescer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncKeyedCoalescer', () {
    test('shares in-flight work for the same key', () async {
      final coalescer = AsyncKeyedCoalescer<String, int>();
      final gate = Completer<void>();
      var calls = 0;

      Future<int> work() async {
        calls++;
        await gate.future;
        return 42;
      }

      final first = coalescer.run('same', work);
      final second = coalescer.run('same', work);
      expect(identical(first, second), isTrue);
      expect(calls, 1);
      expect(coalescer.inFlightCount, 1);

      gate.complete();
      expect(await first, 42);
      expect(await second, 42);
      expect(coalescer.isBusy, isFalse);
    });

    test('different keys remain independent', () async {
      final coalescer = AsyncKeyedCoalescer<String, int>();
      final a = Completer<void>();
      final b = Completer<void>();
      var calls = 0;

      final first = coalescer.run('a', () async {
        calls++;
        await a.future;
        return 1;
      });
      final second = coalescer.run('b', () async {
        calls++;
        await b.future;
        return 2;
      });

      expect(calls, 2);
      expect(coalescer.inFlightCount, 2);
      b.complete();
      expect(await second, 2);
      a.complete();
      expect(await first, 1);
    });

    test('failed work is released and can retry', () async {
      final coalescer = AsyncKeyedCoalescer<String, int>();
      var attempts = 0;
      await expectLater(
        coalescer.run('key', () async {
          attempts++;
          throw StateError('first attempt failed');
        }),
        throwsStateError,
      );
      expect(coalescer.contains('key'), isFalse);
      final value = await coalescer.run('key', () async {
        attempts++;
        return 9;
      });
      expect(value, 9);
      expect(attempts, 2);
    });
  });

  group('OperationGeneration', () {
    test('invalidates stale asynchronous results', () {
      final generation = OperationGeneration();
      final first = generation.next();
      expect(generation.isCurrent(first), isTrue);
      final second = generation.next();
      expect(generation.isCurrent(first), isFalse);
      expect(generation.isCurrent(second), isTrue);
      generation.invalidate();
      expect(generation.isCurrent(second), isFalse);
    });
  });

  group('SerialExecutor', () {
    test('preserves submission order', () async {
      final executor = SerialExecutor();
      final events = <int>[];
      final gate = Completer<void>();

      final first = executor.run(() async {
        await gate.future;
        events.add(1);
      });
      final second = executor.run(() async {
        events.add(2);
      });
      final third = executor.run(() async {
        events.add(3);
      });

      expect(executor.queued, 3);
      gate.complete();
      await Future.wait([first, second, third]);
      expect(events, [1, 2, 3]);
      expect(executor.queued, 0);
    });

    test('one failure does not poison later work', () async {
      final executor = SerialExecutor();
      final first = executor.run<void>(() => throw StateError('boom'));
      final second = executor.run(() async => 7);
      await expectLater(first, throwsStateError);
      expect(await second, 7);
    });
  });
}

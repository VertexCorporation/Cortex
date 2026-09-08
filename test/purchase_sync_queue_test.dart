import 'dart:async';
import 'package:cortex/purchase_sync_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('concurrent duplicate receipts verify and complete once', () async {
    final queue = PurchaseSyncQueue(isSessionCurrent: () => true);
    final gate = Completer<void>();
    var verified = 0;
    var completed = 0;
    Future<void> submit() => queue.submit(
      key: 'receipt',
      verify: () async { verified++; await gate.future; },
      complete: () async { completed++; },
    );
    final first = submit();
    final duplicate = submit();
    gate.complete();
    await Future.wait([first, duplicate]);
    expect(verified, 1);
    expect(completed, 1);
  });

  test('account change during verification prevents completion and queued work', () async {
    var current = true;
    final queue = PurchaseSyncQueue(isSessionCurrent: () => current);
    var completed = 0;
    var verified = 0;
    await queue.submit(
      key: 'first',
      verify: () async { current = false; },
      complete: () async { completed++; },
    );
    await queue.submit(
      key: 'second',
      verify: () async { verified++; },
      complete: () async { completed++; },
    );
    expect(completed, 0);
    expect(verified, 0);
  });

  test('failed verification never completes and can be retried', () async {
    final queue = PurchaseSyncQueue(isSessionCurrent: () => true);
    var completed = 0;
    await expectLater(queue.submit(
      key: 'receipt',
      verify: () async { throw StateError('offline'); },
      complete: () async { completed++; },
    ), throwsStateError);
    expect(completed, 0);
    await queue.submit(
      key: 'receipt', verify: () async {},
      complete: () async { completed++; },
    );
    expect(completed, 1);
  });

  test('completion failure is retryable and does not poison queue', () async {
    final queue = PurchaseSyncQueue(isSessionCurrent: () => true);
    var completed = 0;
    await expectLater(queue.submit(
      key: 'receipt', verify: () async {},
      complete: () async { throw StateError('store offline'); },
    ), throwsStateError);
    await queue.submit(
      key: 'receipt', verify: () async {},
      complete: () async { completed++; },
    );
    await queue.drained;
    expect(completed, 1);
  });

  test('distinct purchases of the same product must not be collapsed', () async {
    final queue = PurchaseSyncQueue(isSessionCurrent: () => true);
    var completed = 0;
    await Future.wait(['transaction1', 'transaction2'].map((key) => queue.submit(
      key: key, verify: () async {},
      complete: () async { completed++; },
    )));
    expect(completed, 2);
  });
}

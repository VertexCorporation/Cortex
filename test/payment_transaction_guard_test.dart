import 'dart:async';
import 'package:cortex/funds/backend/transaction_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('overlapping callbacks for one purchase run once', () async {
    final guard = TransactionGuard();
    final pending = Completer<void>();
    var calls = 0;
    final first = guard.run('purchase-a', () async {
      calls++;
      await pending.future;
    });
    await guard.run('purchase-a', () async { calls++; });
    expect(calls, 1);
    expect(guard.isBusy, isTrue);
    pending.complete();
    await first;
    expect(guard.isBusy, isFalse);
  });

  test('a failed verification can be retried', () async {
    final guard = TransactionGuard();
    await expectLater(guard.run('purchase-a', () async {
      throw StateError('network unavailable');
    }), throwsStateError);
    var retried = false;
    await guard.run('purchase-a', () async { retried = true; });
    expect(retried, isTrue);
    expect(guard.isBusy, isFalse);
  });

  test('different purchases remain independently protected', () async {
    final guard = TransactionGuard();
    final pending = Completer<void>();
    final first = guard.run('purchase-a', () => pending.future);
    var secondRan = false;
    await guard.run('purchase-b', () async { secondRan = true; });
    expect(secondRan, isTrue);
    expect(guard.isBusy, isTrue);
    pending.complete();
    await first;
    expect(guard.isBusy, isFalse);
  });
}

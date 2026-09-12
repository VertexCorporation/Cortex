/// Serializes store events within one reconciliation session. This is only a
/// client-side duplicate guard; receipt ownership and idempotency belong on
/// the server.
class PurchaseSyncQueue {
  PurchaseSyncQueue({required this.isSessionCurrent});

  final bool Function() isSessionCurrent;
  final Set<String> _completed = {};
  Future<void> _tail = Future<void>.value();

  Future<void> get drained => _tail;

  Future<void> submit({
    required String key,
    required Future<void> Function() verify,
    required Future<void> Function() complete,
  }) {
    final task = _tail.then((_) async {
      if (!isSessionCurrent() || _completed.contains(key)) return;
      await verify();
      if (!isSessionCurrent()) return;
      await complete();
      _completed.add(key);
    });
    // A failed receipt must not poison subsequent events, and is retryable.
    _tail = task.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return task;
  }
}

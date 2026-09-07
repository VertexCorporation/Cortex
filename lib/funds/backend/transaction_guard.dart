/// Suppresses overlapping delivery attempts for the same store transaction.
/// This is not a replacement for a durable, idempotent server-side ledger.
class TransactionGuard {
  final Set<String> _active = {};

  bool get isBusy => _active.isNotEmpty;

  Future<void> run(String key, Future<void> Function() action) async {
    if (!_active.add(key)) return;
    try {
      await action();
    } finally {
      _active.remove(key);
    }
  }
}

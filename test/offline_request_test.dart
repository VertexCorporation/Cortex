import 'package:cortex/chat/services/offline_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tokens cannot follow navigation into another conversation', () {
    final history = OfflineRequest('ottoman-history');
    expect(history.accepts(history.id, 'ottoman-history'), isTrue);
    expect(history.accepts(history.id, 'different-question'), isFalse);
  });

  test('late tokens and completion cannot terminate a replacement request', () {
    final old = OfflineRequest('chat');
    old.cancel();
    final replacement = OfflineRequest('chat');
    expect(replacement.accepts(old.id, 'chat'), isFalse);
    expect(old.accepts(old.id, 'chat'), isFalse);
    expect(replacement.accepts(replacement.id, 'chat'), isTrue);
  });

  test('cancelled preparation cannot resume after an await', () {
    final request = OfflineRequest('chat');
    request.cancel();
    expect(request.accepts(request.id, 'chat'), isFalse);
  });

  test('unscoped legacy events and other unsaved requests are rejected', () {
    final request = OfflineRequest(null);
    final other = OfflineRequest(null);
    expect(request.accepts(null, null), isFalse);
    expect(request.accepts(other.id, null), isFalse);
    expect(request.accepts(request.id, null), isTrue);
  });
}

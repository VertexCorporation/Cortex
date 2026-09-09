/// Ownership of callbacks from the single native offline model instance.
class OfflineRequest {
  static int _sequence = 0;
  final String id = '${++_sequence}';
  final String? conversationId;
  bool _active = true;

  OfflineRequest(this.conversationId);

  bool accepts(Object? requestId, String? currentConversationId) =>
      _active && requestId == id && conversationId == currentConversationId;

  void cancel() => _active = false;
}

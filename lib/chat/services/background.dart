// lib/chat/services/background.dart

import 'package:flutter/foundation.dart';

/// Tracks conversations that have active AI response streams running
/// in the background. This allows the UI (Axon tiles) to show a
/// visual indicator and the system to send notifications on completion.
class BackgroundTaskService extends ChangeNotifier {
  /// Map of conversationID → accumulated text buffer for background streams.
  /// If a key is present, that conversation has an active background task.
  final Map<String, StringBuffer> _activeTasks = {};

  /// Returns true if the given conversation has an active background task.
  bool isActive(String conversationID) => _activeTasks.containsKey(conversationID);

  /// Returns the set of conversation IDs that are currently active.
  Set<String> get activeConversationIDs => _activeTasks.keys.toSet();

  /// Whether there are any active background tasks at all.
  bool get hasActiveTasks => _activeTasks.isNotEmpty;

  /// Marks a conversation as having an active background stream.
  void markActive(String conversationID) {
    if (!_activeTasks.containsKey(conversationID)) {
      _activeTasks[conversationID] = StringBuffer();
      debugPrint('[BackgroundTaskService] Marked active: $conversationID');
      notifyListeners();
    }
  }

  /// Appends a text chunk to the background buffer for a conversation.
  void appendChunk(String conversationID, String chunk) {
    _activeTasks[conversationID]?.write(chunk);
  }

  /// Gets the accumulated text for a conversation and clears the buffer.
  String consumeBuffer(String conversationID) {
    final buffer = _activeTasks[conversationID];
    if (buffer == null) return '';
    final text = buffer.toString();
    return text;
  }

  /// Clears the accumulated buffer for a conversation without marking it complete.
  void resetBuffer(String conversationID) {
    if (_activeTasks.containsKey(conversationID)) {
      _activeTasks[conversationID] = StringBuffer();
    }
  }

  /// Marks a conversation as complete and removes it from tracking.
  void markComplete(String conversationID) {
    if (_activeTasks.containsKey(conversationID)) {
      _activeTasks.remove(conversationID);
      debugPrint('[BackgroundTaskService] Marked complete: $conversationID');
      notifyListeners();
    }
  }

  /// Clears all active tasks (e.g., on logout).
  void clearAll() {
    if (_activeTasks.isNotEmpty) {
      _activeTasks.clear();
      notifyListeners();
    }
  }
}

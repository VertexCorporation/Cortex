// lib/chat/services/background.dart

import 'package:cortex/chat/messages/messages.dart';
import 'package:flutter/foundation.dart';

/// Tracks conversations that have active AI response streams running
/// in the background. This allows the UI (Axon tiles) to show a
/// visual indicator and the system to send notifications on completion.
class BackgroundTaskService extends ChangeNotifier {
  /// Internal state for each background task.
  final Map<String, _BackgroundTaskState> _activeTasks = {};

  /// Returns true if the given conversation has an active background task.
  bool isActive(String conversationID) =>
      _activeTasks.containsKey(conversationID);

  /// Returns the set of conversation IDs that are currently active.
  Set<String> get activeConversationIDs => _activeTasks.keys.toSet();

  /// Whether there are any active background tasks at all.
  bool get hasActiveTasks => _activeTasks.isNotEmpty;

  /// Marks a conversation as having an active background stream.
  void markActive(String conversationID) {
    _ensureTask(conversationID);
  }

  _BackgroundTaskState _ensureTask(String conversationID) {
    final existing = _activeTasks[conversationID];
    if (existing != null) return existing;

    final task = _BackgroundTaskState();
    _activeTasks[conversationID] = task;
    debugPrint('[BackgroundTaskService] Marked active: $conversationID');
    notifyListeners();
    return task;
  }

  /// Appends a text chunk to the background buffer for a conversation.
  void appendChunk(String conversationID, String chunk) {
    if (chunk.isEmpty) return;
    _ensureTask(conversationID).textBuffer.write(chunk);
  }

  /// Adds a generated media attachment path to the background task.
  void addMediaAttachment(String conversationID, String mediaPath) {
    final task = _ensureTask(conversationID);
    if (!task.mediaAttachments.contains(mediaPath)) {
      task.mediaAttachments.add(mediaPath);
      debugPrint(
          '[BackgroundTaskService] Added media attachment for $conversationID: $mediaPath');
    }
  }

  /// Sets the pending media generation type for the background task.
  void setPendingMediaType(
      String conversationID, MediaGenerationType mediaType) {
    _ensureTask(conversationID).pendingMediaType = mediaType;
  }

  /// Sets whether the stream is currently waiting on web search results.
  void setWebSearchActive(String conversationID, bool isActive) {
    final task = _ensureTask(conversationID);
    if (task.isWebSearchActive == isActive) return;
    task.isWebSearchActive = isActive;
    notifyListeners();
  }

  /// Gets the pending media type for a background task.
  MediaGenerationType getPendingMediaType(String conversationID) {
    return _activeTasks[conversationID]?.pendingMediaType ??
        MediaGenerationType.none;
  }

  /// Gets the accumulated media attachments for a conversation.
  List<String> getMediaAttachments(String conversationID) {
    return _activeTasks[conversationID]?.mediaAttachments ?? [];
  }

  /// Gets whether a background task is currently in web-search state.
  bool isWebSearchActive(String conversationID) {
    return _activeTasks[conversationID]?.isWebSearchActive ?? false;
  }

  /// Gets the accumulated text for a conversation.
  String consumeBuffer(String conversationID) {
    final task = _activeTasks[conversationID];
    if (task == null) return '';
    final text = task.textBuffer.toString();
    return text;
  }

  /// Gets the accumulated text without consuming (for peeking).
  String peekBuffer(String conversationID) {
    final task = _activeTasks[conversationID];
    if (task == null) return '';
    return task.textBuffer.toString();
  }

  /// Clears the accumulated buffer for a conversation without marking it complete.
  void resetBuffer(String conversationID) {
    final task = _activeTasks[conversationID];
    if (task != null) {
      task.textBuffer = StringBuffer();
      // Keep media attachments intact — only text gets reset for retries
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

/// Internal state for a single background task.
class _BackgroundTaskState {
  StringBuffer textBuffer = StringBuffer();
  List<String> mediaAttachments = [];
  MediaGenerationType pendingMediaType = MediaGenerationType.none;
  bool isWebSearchActive = false;
}

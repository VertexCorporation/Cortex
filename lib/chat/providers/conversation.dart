// lib/chat/providers/conversation.dart

import 'dart:async';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cortex/chat/messages/messages.dart';

import '../../cache.dart';

/// A dedicated provider responsible for managing the state of an active conversation.
///
/// This provider's single responsibility is to manage the lifecycle of messages.
/// It holds the list of messages, the current conversation's ID and title, and flags
/// related to the message stream, such as `isWaitingForResponse`. It does not
/// concern itself with model details, user authentication, or UI modes.
class ConversationProvider with ChangeNotifier {
  // ===========================================================================
  // SECTION 1: PRIVATE STATE VARIABLES
  // ===========================================================================

  List<Message> _messages = [];
  String? _conversationID;
  String? _conversationTitle;
  bool _isWaitingForResponse = false;
  bool _responseStopped = false;
  bool _isLoadingMessages = false;
  bool _justFinishedLoading = false;
  bool _isEphemeral = false; // [NEW] Track if session is not yet saved

  // Streaming performance: throttle UI updates
  Timer? _streamThrottleTimer;
  bool _hasPendingStreamUpdate = false;
  static const _streamThrottleDuration = Duration(milliseconds: 32); // ~30fps

  // ===========================================================================
  // SECTION 1.5: INITIALIZATION
  // ===========================================================================

  ConversationProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        resetForLogout();
      }
    });
  }

  @override
  void dispose() {
    _streamThrottleTimer?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================
  bool get isLoadingMessages => _isLoadingMessages;

  /// Marks the conversation as loading, showing skeleton UI.
  void setLoadingMessages(bool value) {
    if (_isLoadingMessages != value) {
      _isLoadingMessages = value;
      notifyListeners();
    }
  }

  List<Message> get messages => _messages;

  String? get conversationID => _conversationID;

  String? get conversationTitle => _conversationTitle;

  bool get isWaitingForResponse => _isWaitingForResponse;

  bool get wasResponseStopped => _responseStopped;

  bool get justFinishedLoading => _justFinishedLoading;

  // ===========================================================================
  // SECTION 3: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  // -------------------- Conversation Lifecycle Actions --------------------

  /// Sets the context for an existing conversation that is being loaded.
  void setConversationContext(String id, String title) {
    _conversationID = id;
    _conversationTitle = title;
    notifyListeners();
  }

  /// Clears all message and conversation data. This should be called when
  /// a chat is exited or a new one is started.
  void updateConversationTitle(String newTitle) {
    _conversationTitle = newTitle;
    notifyListeners();
  }

  void clearConversation(
      {bool resetLoadingState = true, bool startLoading = false}) {
    // Cancel any pending stream updates
    _streamThrottleTimer?.cancel();
    _streamThrottleTimer = null;
    _hasPendingStreamUpdate = false;

    _messages = [];
    _conversationID = null;
    _conversationTitle = null;
    _isWaitingForResponse = false;
    _responseStopped = false;

    if (startLoading) {
      _isLoadingMessages = true;
    } else if (resetLoadingState) {
      _isLoadingMessages = false;
    }

    _justFinishedLoading = false;
    notifyListeners();
  }

  /// Strictly resets all conversation state for a complete sign-out, ensuring
  /// no memory leaks or persisting sessions leak into another user's account.
  void resetForLogout() {
    _streamThrottleTimer?.cancel();
    _streamThrottleTimer = null;
    _hasPendingStreamUpdate = false;

    _messages = [];
    _conversationID = null;
    _conversationTitle = null;
    _isWaitingForResponse = false;
    _responseStopped = false;
    _isLoadingMessages = false;
    _justFinishedLoading = false;
    _isEphemeral = false;
    notifyListeners();
  }

  /// Stops the current AI generation/streaming process.
  /// This sets a flag that services (like SendService) check to abort their loops.
  void stopGenerating() {
    if (_isWaitingForResponse) {
      _responseStopped = true;
      _isWaitingForResponse = false;
      // Flush pending updates when stopping
      flushStreamUpdates();
      notifyListeners();
    }
  }

  // -------------------- Message Management Actions --------------------

  /// Adds a full list of messages, typically when loading a conversation from history.
  void loadMessages(List<Message> loadedMessages) {
    _messages = loadedMessages;
    _isLoadingMessages = false; // Loading complete
    _justFinishedLoading = true;
    notifyListeners();
  }

  /// This prevents the scroll action from re-triggering on subsequent rebuilds.
  void consumeJustFinishedLoadingFlag() {
    _justFinishedLoading = false;
  }

  /// Truncates the message list to a specific index.
  /// Used by the EditService to prepare the UI for editing a message.
  void truncateMessages({required int upToIndex}) {
    if (upToIndex >= 0 && upToIndex <= _messages.length) {
      _messages = _messages.sublist(0, upToIndex);
      notifyListeners();
    }
  }

  /// Starts a new conversation session with the first user message.
  /// This atomic operation sets the conversation ID, title, and adds the
  /// initial user message and a "thinking" bubble.
  void startNewConversationSession(
    String id,
    String title,
    String modelIdForStorage,
    Message userMessage, {
    String? modelTitleForStorage,
    String? modelImagePathForStorage,
  }) {
    _conversationID = id;
    _conversationTitle = title;

    final thinkingMessage = Message(
      text: "",
      isUserMessage: false,
      isThinking: true,
      model: userMessage.model,
    );

    _messages = [userMessage, thinkingMessage];
    _isWaitingForResponse = true;
    _responseStopped = false;
    _isLoadingMessages = false;

    // Persist the new conversation structure asynchronously.
    ChatStorageService.saveConversation(id, title, [],
            modelId: modelIdForStorage,
            modelTitle: modelTitleForStorage,
            modelImagePath: modelImagePathForStorage)
        .then((_) {
      ChatStorageService.upsertMessage(id, 0, userMessage);
    });
    CacheService.invalidateConversationCache();

    notifyListeners();
  }

  /// Appends a user message and a corresponding "thinking" bubble to an existing conversation.
  void appendMessageToConversation(Message userMessage) {
    final thinkingMessage = Message(
      text: "",
      isUserMessage: false,
      isThinking: true,
      model: userMessage.model,
    );

    _messages.add(userMessage);
    _messages.add(thinkingMessage);

    _isWaitingForResponse = true;
    _responseStopped = false;
    _isLoadingMessages = false;

    if (_conversationID != null) {
      ChatStorageService.upsertMessage(
          _conversationID!, _messages.length - 2, userMessage);
    }

    notifyListeners();
  }

  /// Starts a session solely in memory. Does not save to storage yet.
  /// Used for Flow Mode hidden prompts.
  void startEphemeralSession(
      String id, String modelIdForStorage, Message userMessage,
      {String? title}) {
    _conversationID = id;
    _conversationTitle = title ?? "New Chat";
    _isEphemeral = true;

    final thinkingMessage = Message(
      text: "",
      isUserMessage: false,
      isThinking: true,
      model: userMessage.model,
    );

    _messages = [userMessage, thinkingMessage];
    _isWaitingForResponse = true;
    _responseStopped = false;
    _isLoadingMessages = false;

    notifyListeners();
  }

  /// Promotes an ephemeral session to a real stored conversation.
  Future<void> promoteToPersistentSession() async {
    if (!_isEphemeral || _conversationID == null) return;

    // We can use a generic title or generate one later.
    // For Flow Mode, we might have set a specific title in startEphemeralSession
    final title = _conversationTitle ?? "New Chat";

    await ChatStorageService.saveConversation(_conversationID!, title, [],
        modelId: _messages.first.model);

    // Save existing messages
    for (int i = 0; i < _messages.length; i++) {
      await ChatStorageService.upsertMessage(_conversationID!, i, _messages[i]);
    }

    _isEphemeral = false;
  }

  /// Prepares the conversation state for a regeneration action in a single, atomic operation.
  ///
  /// This method replaces the previous two-step fade-out/finalize process. It works for two scenarios:
  /// 1. Regenerating an existing message: It truncates the message list to the target AI message's index.
  /// 2. Appending a new response (e.g., after an edit): It uses the full existing list.
  ///
  /// In both cases, it then appends a new "thinking" placeholder, ensuring the UI
  /// updates instantly and consistently without glitches or race conditions.
  ///
  /// - [aiMessageIndex]: The index where the new "thinking" bubble should be.
  ///   This is also the index at which the message list will be truncated.
  /// - [newModelId]: The model ID to associate with the new "thinking" message.
  void prepareForRegeneration(int aiMessageIndex, String newModelId) {
    if (aiMessageIndex < 0) {
      debugPrint(
          "[ConversationProvider] Invalid negative index for regeneration. Aborting.");
      return;
    }

    // Atomically truncate the list. If the index is out of bounds (for appending),
    // it effectively takes the whole list.
    if (aiMessageIndex <= _messages.length) {
      _messages = _messages.sublist(0, aiMessageIndex);
    } else {
      debugPrint(
          "[ConversationProvider] Invalid index $aiMessageIndex for list of length ${_messages.length}. Aborting regeneration prep.");
      return;
    }

    // Create and add the new "thinking" placeholder.
    final thinkingPlaceholder = Message(
      text: "",
      isThinking: true,
      isUserMessage: false,
      isError: false,
      opacity: 1.0,
      // Ensure it's visible.
      model: newModelId,
    );
    _messages.add(thinkingPlaceholder);

    // Update the provider's state to reflect the new operation.
    _isWaitingForResponse = true;
    _responseStopped = false;
    _isLoadingMessages = false;

    notifyListeners();
    debugPrint(
        "[ConversationProvider] Atomically prepared for regeneration. List truncated to index $aiMessageIndex and 'thinking' bubble added.");
  }

  /// Appends a chunk of text to the last AI message in the list (for streaming responses).
  /// Uses throttling to prevent excessive UI rebuilds during fast streaming.
  void appendToLastBotMessage(String chunk) {
    if (_messages.isNotEmpty && !_messages.last.isUserMessage) {
      final lastMessage = _messages.last;

      // Trim leading newlines if this is the very beginning of the message
      String textToAppend = chunk;
      if (lastMessage.text.isEmpty && textToAppend.trimLeft().isEmpty) {
        // If message is empty and chunk is only whitespace/newline, ignore it
        return;
      }
      if (lastMessage.text.isEmpty && textToAppend.startsWith('\n')) {
        textToAppend = textToAppend.trimLeft();
      }

      _messages[_messages.length - 1] = lastMessage.copyWith(
        text: lastMessage.text + textToAppend,
      );
    } else {
      // This case handles a stream starting before the thinking bubble is in place.
      String initialText = chunk;
      if (initialText.startsWith('\n')) {
        initialText = initialText.trimLeft();
      }
      _messages.add(
          Message(text: initialText, isUserMessage: false, isThinking: true));
    }

    // Throttle UI updates for better streaming performance
    _scheduleStreamUpdate();
  }

  void updateLastBotMessageSources(List<dynamic> sources) {
    if (_messages.isNotEmpty && !_messages.last.isUserMessage) {
      final lastMessage = _messages.last;

      // Merge with existing sources if they exist, or just use the new ones
      List<dynamic> updatedSources = [];
      if (lastMessage.webSearchSources != null) {
        updatedSources.addAll(lastMessage.webSearchSources!);
      }
      for (var source in sources) {
        // Prevent duplicates
        bool exists = updatedSources.any((existing) {
          if (existing is Map && source is Map) {
            return existing['url'] == source['url'];
          }
          return existing == source;
        });
        if (!exists) {
          updatedSources.add(source);
        }
      }

      _messages[_messages.length - 1] = lastMessage.copyWith(
        webSearchSources: updatedSources.isNotEmpty ? updatedSources : null,
      );
      _scheduleStreamUpdate(); // Reuse throttle logic
    }
  }

  /// Schedules a throttled UI update for streaming.
  void _scheduleStreamUpdate() {
    _hasPendingStreamUpdate = true;

    // If no timer is active, start a new throttle window
    if (_streamThrottleTimer == null || !_streamThrottleTimer!.isActive) {
      _streamThrottleTimer = Timer(_streamThrottleDuration, () {
        if (_hasPendingStreamUpdate) {
          _hasPendingStreamUpdate = false;
          notifyListeners();
        }
      });
    }
  }

  /// Forces an immediate UI update, bypassing throttle.
  /// Use this for important state changes like stream end.
  void flushStreamUpdates() {
    _streamThrottleTimer?.cancel();
    _streamThrottleTimer = null;
    if (_hasPendingStreamUpdate) {
      _hasPendingStreamUpdate = false;
      notifyListeners();
    }
  }

  /// Updates a specific message in the list with new data.
  void updateMessageAtIndex(int index, Message updatedMessage) {
    if (index >= 0 && index < _messages.length) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  /// Updates the opacity of a message to trigger a fade-out animation.
  void fadeOutMessage(int index) {
    if (index < 0 || index >= _messages.length) return;
    _messages[index] = _messages[index].copyWith(opacity: 0.0);
    _isWaitingForResponse = false;
    notifyListeners();
  }

  /// Removes a message at a specific index from the list.
  void removeMessageAtIndex(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      notifyListeners();
    }
  }

  /// Finalizes the AI response at a specific index, marking it as complete.
  void finishBotResponse(int index) {
    // Guard against race conditions (e.g. StopService vs SendService completion)
    if (!_isWaitingForResponse) return;
    _isWaitingForResponse = false;

    // Flush any pending stream updates before finalizing
    flushStreamUpdates();

    if (index >= 0 && index < _messages.length) {
      final msg = _messages[index];
      if (msg.isThinking) {
        _messages[index] =
            msg.copyWith(isThinking: false, includeInContext: true);
      }
      if (_conversationID != null) {
        if (_isEphemeral) {
          // If we finish a response and it's still ephemeral, save it now?
          // This handles cases where we finish without streaming (e.g. short/tool).
          // However, ideally we promote on first chunk.
          // Let's ensure we promote here just in case.
          promoteToPersistentSession().then((_) {
            ChatStorageService.upsertMessage(
                _conversationID!, index, _messages[index]);
          });
        } else {
          ChatStorageService.upsertMessage(
              _conversationID!, index, _messages[index]);
        }
      }
    }
    notifyListeners();
  }

  // -------------------- Error Handling Actions --------------------

  /// Updates an existing AI message with an error state.
  void setErrorMessage(
      int index, String errorMessage, bool isContentFlagError) {
    if (index < 0 || index >= _messages.length) return;

    final aiMessage = _messages[index];

    // REFACTORED: We want to show the error message to the user (e.g. "Check your internet")
    // instead of silently removing the bubble, which makes it look like the app is ignoring them.

    // Only fade out if there is NO error message (which shouldn't happen usually)
    if (aiMessage.isThinking &&
        aiMessage.text.isEmpty &&
        errorMessage.isEmpty) {
      debugPrint(
          "[ConversationProvider] Error/Stop occurred with empty message. Fading out.");
      _messages[index] = aiMessage.copyWith(opacity: 0.0);
      _isWaitingForResponse = false;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 250), () {
        if (index < _messages.length && _messages[index].opacity == 0.0) {
          _messages.removeAt(index);
          notifyListeners();
        }
      });
      return;
    }

    _messages[index] = aiMessage.copyWith(
      text: errorMessage,
      isThinking: false,
      isError: true,
      includeInContext: false,
    );

    if (isContentFlagError && index > 0) {
      final userMessageIndex = index - 1;
      final userMessage = _messages[userMessageIndex];
      if (userMessage.isUserMessage) {
        _messages[userMessageIndex] =
            userMessage.copyWith(includeInContext: false);
        if (_conversationID != null) {
          ChatStorageService.updateStoredMessage(
              _conversationID!, _messages[userMessageIndex], userMessageIndex);
        }
      }
    }

    _isWaitingForResponse = false;
    notifyListeners();
  }

  /// Adds a new user message and a corresponding error message to the list.
  void showSendError(
      Message userMessage, String errorMessage, bool isContentFlagError) {
    if (_messages.isNotEmpty && _messages.last.isThinking) {
      setErrorMessage(_messages.length - 1, errorMessage, isContentFlagError);
      return;
    }

    final finalUserMessage =
        userMessage.copyWith(includeInContext: !isContentFlagError);
    final errorAIMessage = Message(
        text: errorMessage,
        isUserMessage: false,
        isError: true,
        includeInContext: false);

    _messages.add(finalUserMessage);
    _messages.add(errorAIMessage);

    if (_conversationID != null) {
      ChatStorageService.upsertMessage(
          _conversationID!, _messages.length - 2, finalUserMessage);
    }

    _isWaitingForResponse = false;
    notifyListeners();
  }
}

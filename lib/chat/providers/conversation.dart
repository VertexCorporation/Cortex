// lib/chat/providers/conversation.dart

import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/foundation.dart';
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
  final bool _isLoadingMessages = false;
  bool _justFinishedLoading = false;

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================
  bool get isLoadingMessages => _isLoadingMessages;
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
  void clearConversation() {
    _messages = [];
    _conversationID = null;
    _conversationTitle = null;
    _isWaitingForResponse = false;
    _responseStopped = false;
    _justFinishedLoading = false;
    notifyListeners();
  }

  // -------------------- Message Management Actions --------------------

  /// Adds a full list of messages, typically when loading a conversation from history.
  void loadMessages(List<Message> loadedMessages) {
    _messages = loadedMessages;
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
  void startNewConversationSession(String id, String title, String modelIdForStorage, Message userMessage) {
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

    // Persist the new conversation structure asynchronously.
    ChatStorageService.saveConversation(id, title, [], modelId: modelIdForStorage).then((_) {
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

    if (_conversationID != null) {
      ChatStorageService.upsertMessage(_conversationID!, _messages.length - 2, userMessage);
    }

    notifyListeners();
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
      debugPrint("[ConversationProvider] Invalid negative index for regeneration. Aborting.");
      return;
    }

    // Atomically truncate the list. If the index is out of bounds (for appending),
    // it effectively takes the whole list.
    if (aiMessageIndex <= _messages.length) {
      _messages = _messages.sublist(0, aiMessageIndex);
    } else {
      debugPrint("[ConversationProvider] Invalid index $aiMessageIndex for list of length ${_messages.length}. Aborting regeneration prep.");
      return;
    }

    // Create and add the new "thinking" placeholder.
    final thinkingPlaceholder = Message(
      text: "",
      isThinking: true,
      isUserMessage: false,
      isError: false,
      opacity: 1.0, // Ensure it's visible.
      model: newModelId,
    );
    _messages.add(thinkingPlaceholder);

    // Update the provider's state to reflect the new operation.
    _isWaitingForResponse = true;
    _responseStopped = false;

    notifyListeners();
    debugPrint("[ConversationProvider] Atomically prepared for regeneration. List truncated to index $aiMessageIndex and 'thinking' bubble added.");
  }

  /// Appends a chunk of text to the last AI message in the list (for streaming responses).
  void appendToLastBotMessage(String chunk) {
    if (_messages.isNotEmpty && !_messages.last.isUserMessage) {
      final lastMessage = _messages.last;
      _messages[_messages.length - 1] = lastMessage.copyWith(
        text: lastMessage.text + chunk,
      );
    } else {
      // This case handles a stream starting before the thinking bubble is in place.
      _messages.add(Message(text: chunk, isUserMessage: false, isThinking: true));
    }
    notifyListeners();
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
    if (index >= 0 && index < _messages.length) {
      final msg = _messages[index];
      if (msg.isThinking) {
        _messages[index] = msg.copyWith(isThinking: false, includeInContext: true);
      }
      if (_conversationID != null) {
        ChatStorageService.upsertMessage(_conversationID!, index, _messages[index]);
      }
    }
    _isWaitingForResponse = false;
    notifyListeners();
  }

  // -------------------- Error Handling Actions --------------------

  /// Updates an existing AI message with an error state.
  void setErrorMessage(int index, String errorMessage, bool isContentFlagError) {
    if (index < 0 || index >= _messages.length) return;

    final aiMessage = _messages[index];
    _messages[index] = aiMessage.copyWith(
      text: errorMessage,
      isThinking: false,
      isError: true,
      includeInContext: false,
    );

    // If it's a content flag error, neutralize the preceding user message.
    if (isContentFlagError && index > 0) {
      final userMessageIndex = index - 1;
      final userMessage = _messages[userMessageIndex];
      if (userMessage.isUserMessage) {
        _messages[userMessageIndex] = userMessage.copyWith(includeInContext: false);
        if (_conversationID != null) {
          ChatStorageService.updateStoredMessage(_conversationID!, _messages[userMessageIndex], userMessageIndex);
        }
      }
    }

    _isWaitingForResponse = false;
    notifyListeners();
  }

  /// Adds a new user message and a corresponding error message to the list.
  void showSendError(Message userMessage, String errorMessage, bool isContentFlagError) {
    final finalUserMessage = userMessage.copyWith(includeInContext: !isContentFlagError);
    final errorAIMessage = Message(text: errorMessage, isUserMessage: false, isError: true, includeInContext: false);

    _messages.add(finalUserMessage);
    _messages.add(errorAIMessage);

    if (_conversationID != null) {
      ChatStorageService.upsertMessage(_conversationID!, _messages.length - 2, finalUserMessage);
    }

    _isWaitingForResponse = false;
    notifyListeners();
  }
}
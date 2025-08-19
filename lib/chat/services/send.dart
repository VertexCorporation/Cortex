// send.dart
//
// This file defines the SendService class which handles the logic
// for sending chat messages. It supports sending new messages, handling
// regenerate and edit modes, saving messages to storage, and streaming
// server-side message responses with chunked updates. Detailed inline
// comments explain the workflow and helper methods.

import 'dart:async';
import 'dart:io';
import 'package:cortex/chat/services/review.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../cache.dart';
import '../../models/backend/data.dart';
import '../../server/fetch.dart';
import '../chat.dart';
import '../messages/messages.dart';
import '../services/storage.dart';
import 'api.dart';
import 'moderator.dart';

/// Service responsible for sending messages in the chat.
class SendService {
  final ChatScreenState state;
  final Uuid uuid = const Uuid();
  bool _isSending = false;
  File? selectedPhoto;

  SendService(this.state);

  void abortSend() {
    _isSending = false;
  }

  /// Sends a new message.
  /// It handles various modes including editing, regenerate, or standard message sending.
  Future<void> sendMessage({
    String? textFromButton,
    bool isRegenerate = false,
    int? regenerateAiIndex,
    String? regeneratePhotoPath,
  }) async
  {
    final localizations = AppLocalizations.of(state.context)!;
    if (!state.canHandleImage) {
      selectedPhoto = null;
    }

    final String messageText = textFromButton ?? state.controller.text.trim();
    if (messageText.isEmpty && selectedPhoto == null && regeneratePhotoPath == null) return;
    if (_isSending) return;
    final bool photoAllowed   = state.canHandleImage;
    final File? photoForSend   = photoAllowed ? selectedPhoto : null;
    _isSending = true;
    String apiModelIdForSend = state.modelId!;

    if (state.modelId == 'trash') {
      await _handleTrashMessage(messageText);
      _isSending = false;
      return;
    }

    // Dismiss the keyboard and attempt to fetch user data in the background.
    FocusScope.of(state.context).unfocus();
    FetchService.fetchUserData().catchError((error) {
      debugPrint("FetchUserData error: $error");
    });

    // If modelId is missing, log an error and abort sending.
    if (state.modelId == null || state.modelId!.isEmpty) {
      debugPrint("Error: modelId is null or empty in sendMessage");
      _isSending = false;
      return;
    }

    int? aiMessageIndex;

    // If editing an existing message.
    if (state.editingMessageIndex != null) {
      final int editingIndex = state.editingMessageIndex!;
      state.setState(() {
        state.messages[editingIndex].text = messageText;
        state.messages = state.messages.sublist(0, editingIndex + 1);
        state.editingMessageIndex = null;
        state.originalMessageText = null;
        state.controller.clear();
        state.textFieldFocusNode.unfocus();
      });
      await _handleEditingMessage(messageText);
      _isSending = false;
      return;
    } else if (isRegenerate && regenerateAiIndex != null) {
      // Regenerate mode: update the corresponding message to show a thinking status.
      state.setState(() {
        state.messages[regenerateAiIndex].isThinking = true;
        state.messages[regenerateAiIndex].includeInContext = false;
        state.isWaitingForResponse = true;
        state.isSendButtonVisible = false;
        state.responseStopped = false;
      });
      aiMessageIndex = regenerateAiIndex;
      _prepareForRegenerate(regenerateAiIndex, localizations);
    } else {
      // New conversation start vs. continuing conversation.
      if (state.conversationID == null) {
        await _startNewConversation(messageText, selectedPhoto != null, apiModelIdForSend, localizations);
        aiMessageIndex = state.messages.length - 1;
      } else {
        state.setState(() {
          state.messages.add(Message(
            text: messageText,
            isUserMessage: true,
            photoPath: selectedPhoto != null ? selectedPhoto!.path : null,
            isPhotoUploading: true,
            model: apiModelIdForSend,
          ));
          state.controller.clear();
          state.isWaitingForResponse = true;
          state.isSendButtonVisible = false;
          state.responseStopped = false;
        });
        aiMessageIndex = state.messages.length;
        state.setState(() {
          state.messages.add(Message(
            text: "",
            isUserMessage: false,
            includeInContext: false,
            isThinking: true,
            model: apiModelIdForSend,
          ));
        });
        await _appendNewMessage(messageText, selectedPhoto != null, apiModelIdForSend, localizations);
      }
    }

    // Handle photo selection.
    String? photoPath = await _handlePhoto(
      photoForSend != null,
      regeneratePhotoPath,
    );
    state.inputFieldKey.currentState?.clearPhotoPanel();

    if (!photoAllowed && selectedPhoto != null) {
      state.inputFieldKey.currentState?.clearPhotoPanel();
      selectedPhoto = null;
    }

    try {
      if (!state.isServerSideModel(state.modelId)) {
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(messageText)) {
          unawaited(_sendLocalMessage(messageText, photoPath));
        } else {
          _isSending = false;
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        await _sendServerSideMessage(
          messageText,
          apiModelIdForSend,
          photoPath,
          isRegenerate,
          regenerateAiIndex,
          localizations,
          aiMessageIndex,
        );

        if (state.mounted && !state.responseStopped) {
          final int targetIndex = isRegenerate && regenerateAiIndex != null
              ? regenerateAiIndex
              : (aiMessageIndex);

          if (targetIndex >= 0 && targetIndex < state.messages.length) {
            state.setState(() {
              final msg = state.messages[targetIndex];
              msg.isThinking = false;
              msg.includeInContext = true;
              state.isWaitingForResponse = false;
            });

            if (state.conversationID != null) {
              await ChatStorageService.upsertMessage(
                  state.conversationID!, targetIndex, state.messages[targetIndex]);
            }
          }
        }
        if (!isRegenerate) {
          debugPrint("[SendService] Successful server response. Triggering review check.");
          unawaited(ReviewService().triggerReviewPromptIfNeeded(state.context));
        }
      }

      if (state.conversationID != null) {
        await ChatStorageService.updateConversationModelId(state.conversationID!, state.modelId!);
        debugPrint("[SendService] Committed model change. Conv '${state.conversationID}' now permanently uses '${state.modelId}'.");
      }

    } catch (e) {
      if (e is UserCancelledException) {
        // This was an intentional cancellation by the user (via Stop button).
        // The StopService has already handled the UI cleanup. We do nothing here
        // and just let the function end gracefully.
        debugPrint("[SendService] Caught UserCancelledException. Suppressing error UI.");
      } else {
        // This is a real, unexpected error. Show it to the user.
        _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      }
    } finally {
      _isSending = false;
    }
  }

  /// Handles the editing mode: updates an existing message.
  Future<void> _handleEditingMessage(String newText) async {
    final int editingIndex = state.editingMessageIndex!;
    if (newText.isEmpty || newText == state.originalMessageText) return;
    state.setState(() {
      state.messages[editingIndex].text = newText;
      state.messages = state.messages.sublist(0, editingIndex + 1);
      state.editingMessageIndex = null;
      state.originalMessageText = null;
      state.controller.clear();
      state.textFieldFocusNode.unfocus();
    });
    await ChatStorageService.saveCurrentMessages(state.conversationID!, state.messages);
    state.regenerateService.onRegenerate(editingIndex + 1);
  }

  /// Handles trashing a message (displaying then removing it).
  Future<void> _handleTrashMessage(String text) async {
    state.setState(() {
      state.messages.add(Message(
        text: text,
        isUserMessage: true,
      ));
      state.controller.clear();
    });
    Timer(const Duration(seconds: 1), () {
      if (!state.mounted) return;
      state.setState(() {
        state.messages.last.opacity = 0;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!state.mounted) return;
        state.setState(() {
          state.messages.removeLast();
        });
      });
    });
  }

  /// Starts a new conversation by setting conversation ID,
  /// conversation title and saving the initial messages.
  /// Starts a new conversation by setting conversation ID,
  /// conversation title and saving the initial messages.
  /// --- REFACTORED FOR RELIABILITY ---
  /// This function now correctly handles saving the first user message,
  /// even when a system prompt or other messages already exist in the state.
  /// It no longer makes unsafe assumptions about the message list's initial state.
  Future<void> _startNewConversation(
      String text,
      bool hasNewPhoto,
      String fullModelId,
      AppLocalizations localizations,
      ) async {
    state.conversationID = uuid.v4();
    state.conversationTitle = (text.trim().isEmpty && hasNewPhoto)
        ? "🖼"
        : (text.length > 28 ? text.substring(0, 28) : text);

    // First, save the conversation metadata. The messages themselves will be saved next.
    await ChatStorageService.saveConversation(
      state.conversationID!,
      state.conversationTitle!,
      [], // Message list is no longer passed here; it's handled by upsert.
      modelId: state.modelId,
    );
    CacheService.invalidateConversationCache();

    // --- THE FIX ---
    // 1. Create the message objects *before* adding them to the state.
    final userMessage = Message(
      text: text,
      isUserMessage: true,
      photoPath: hasNewPhoto ? selectedPhoto!.path : null,
      isPhotoUploading: true,
      // The user message should adopt the currently selected model
      model: fullModelId,
    );
    final aiThinkingMessage = Message(
      text: '',
      isThinking: true,
      isUserMessage: false,
      includeInContext: false,
      model: fullModelId,
    );

    // 2. Determine the correct index for the new user message.
    final userMessageIndex = state.messages.length;

    // 3. Update the UI state atomically.
    state.setState(() {
      state.messages.add(userMessage);
      state.messages.add(aiThinkingMessage);
      state.controller.clear();
      state.isWaitingForResponse = true;
      state.isSendButtonVisible = false;
      state.responseStopped = false;
    });

    // 4. Save the user's message to storage at its precise index, using the
    //    object we just created. This avoids any race conditions or incorrect
    //    assumptions about `state.messages.first`.
    await ChatStorageService.upsertMessage(
      state.conversationID!,
      userMessageIndex,
      userMessage,
    );
  }

  /// Appends a new message to an existing conversation.
  Future<void> _appendNewMessage(
      String text,
      bool hasNewPhoto,
      String fullModelId,
      AppLocalizations localizations,
      ) async {
    final idx = state.messages.length - 2;
    await ChatStorageService.upsertMessage(
      state.conversationID!,
      idx,
      state.messages[idx],
    );
  }

  /// Handles photo selection: returns the photo path if a new photo is selected,
  /// otherwise uses the provided regeneratePhotoPath.
  Future<String?> _handlePhoto(bool hasNewPhoto, String? regeneratePhotoPath) async {
    String? photoPath;
    if (hasNewPhoto) {
      state.setState(() {
        photoPath = selectedPhoto!.path;
        selectedPhoto = null;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (regeneratePhotoPath != null) {
      photoPath = regeneratePhotoPath;
    }
    return photoPath;
  }

  /// Sends a message when using a local model via a platform channel.
  Future<void> _sendLocalMessage(String text, String? photoPath) async {
    // We no longer await a complete reply here. We just fire the request.
    // The native code will send back tokens via the MethodCallHandler.
    // We wrap it in a try-catch to handle potential errors during the call itself.
    try {
      await ChatScreenState.llamaChannel.invokeMethod<void>(
        'sendMessage',
        {
          'message':   text,
          'photoPath': photoPath,
          // 'role' parameter removed as requested.
        },
      );
      // The actual response handling is now done in ChatScreenState's _methodCallHandler
      // for the 'onMessageResponse' and 'onMessageComplete' calls.
    } catch (e) {
      // If invoking the method itself fails, handle the error.
      _handleSendError(e, false, null, AppLocalizations.of(state.context)!);
    }
  }

  /// This function is now leaner and no longer contains its own try-catch block.
  /// It delegates all exception handling to its caller (`sendMessage`), which is
  /// better for separation of concerns and allows for more nuanced error handling
  /// (like distinguishing between real errors and user cancellations).
  Future<void> _sendServerSideMessage(
      String text,
      String modelIdInState,
      String? photoPath,
      bool isRegenerate,
      int? regenerateAiIndex,
      AppLocalizations localizations,
      int? aiMessageIndex,
      ) async {
    final int targetIndex = isRegenerate && regenerateAiIndex != null
        ? regenerateAiIndex
        : (aiMessageIndex ?? state.messages.length - 1);

    if (targetIndex < 0 || targetIndex >= state.messages.length) {
      debugPrint("Error: Invalid target index for AI response.");
      // Throw an exception that will be caught by sendMessage.
      throw ApiException("Internal client error: Invalid message index.");
    }

    if (state.mounted) {
      state.setState(() {
        state.messages[targetIndex].isThinking = true;
        state.messages[targetIndex].text = ''; // Clear previous text for regenerate
        state.messages[targetIndex].isError = false; // Clear error state on regenerate
      });
    }

    // NOTE: The try-catch block that was here has been REMOVED.
    // All exceptions (ApiException, UserCancelledException, etc.) will now
    // bubble up to the `catch` block in `sendMessage`.

    final memory = await state.contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelIdInState,
    );
    final bool isCharacterModel = state.selectedModelCategory == 'roleplay' || state.selectedModelCategory == 'self';

    final onStreamChunk = (String chunk) {
      if (!state.mounted || state.responseStopped) return;
      state.setState(() {
        state.messages[targetIndex].text += chunk;
      });
      if (state.scrollService.isUserAtBottom()) {
        state.scrollService.scrollToBottom();
      }
    };

    if (isCharacterModel) {
      final characterData = ModelData.getPreciseModelData(modelIdInState);
      final baseModelId = characterData['baseModelId'] as String?;

      if (baseModelId == null || baseModelId.isEmpty) {
        throw ApiException("Character '$modelIdInState' has no valid base model configured.");
      }

      await state.apiService.getCharacterResponse(
        userInput: text,
        context: memory,
        characterId: modelIdInState,
        baseModelId: baseModelId,
        photoPath: photoPath,
        onStreamChunk: onStreamChunk,
      );
    } else {
      await state.apiService.getOnlineModelResponse(
        modelId: modelIdInState,
        userInput: text,
        context: memory,
        photoPath: photoPath,
        onStreamChunk: onStreamChunk,
      );
    }
  }

  /// Prepares the UI for regenerate mode by resetting the message text.
  void _prepareForRegenerate(int regenerateIndex, AppLocalizations localizations) {
    state.setState(() {
      state.messages[regenerateIndex].isThinking = true;
      state.messages[regenerateIndex].includeInContext = false;
      state.isWaitingForResponse = true;
      state.isSendButtonVisible = false;
      state.responseStopped = false;
    });
  }

  /// --- REFACTORED & AAA-QUALITY ---
  /// Handles send errors robustly by updating the message with the error text.
  /// Now, if a content moderation error occurs, it not only flags the AI's
  /// response bubble with the error, but it also finds the PRECEDING user
  /// message that *caused* the error and marks it as `includeInContext = false`.
  /// This prevents the "toxic" message from poisoning future context and
  /// causing subsequent legitimate messages to fail moderation.
  void _handleSendError(Object error, bool isRegenerate, int? regenerateAiIndex, AppLocalizations localizations) {
    if (!state.mounted) return;

    state.setState(() {
      state.isWaitingForResponse = false;

      final int targetIndex = isRegenerate && regenerateAiIndex != null
          ? regenerateAiIndex
          : state.messages.length - 1; // Default to the last message (the AI's thinking bubble)

      // Ensure the target index for the AI message is valid.
      if (targetIndex >= 0 && targetIndex < state.messages.length) {
        final aiMessage = state.messages[targetIndex];
        aiMessage
          ..text             = error.toString()
          ..isThinking       = false
          ..includeInContext = false
          ..isError          = true;

        // --- CRITICAL FIX FOR CONTENT MODERATION ERRORS ---
        // Check if the error is a content flag error and if there's a user message right before the AI one.
        final bool isContentFlagError = error is ApiException && error.message == localizations.errorPromptFlagged;
        final int userMessageIndex = targetIndex - 1;

        if (isContentFlagError && userMessageIndex >= 0) {
          final offendingUserMessage = state.messages[userMessageIndex];
          // If the preceding message is indeed a user message, neutralize it.
          if (offendingUserMessage.isUserMessage) {
            debugPrint("[SendService] Content flag error detected. Neutralizing the offending user message at index $userMessageIndex to prevent context pollution.");
            offendingUserMessage.includeInContext = false;

            // Persist this critical change to prevent the issue after an app restart.
            if (state.conversationID != null) {
              unawaited(ChatStorageService.updateStoredMessage(
                state.conversationID!,
                offendingUserMessage,
                userMessageIndex,
              ));
            }
          }
        }
      } else {
        // Fallback if there's no message to update: create a new error message.
        state.messages.add(Message(
          text: error.toString(),
          isUserMessage: false,
          includeInContext: false,
          isError: true,
          isThinking: false,
        ));
      }
    });
  }
}
// send.dart
//
// This file defines the SendService class which handles the logic
// for sending chat messages. It supports sending new messages, handling
// regenerate and edit modes, saving messages to storage, and streaming
// server-side message responses with chunked updates. Detailed inline
// comments explain the workflow and helper methods.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:cortex/chat/services/review.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
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

  /// This method analyzes the user's input and context to pick a random, appropriate model.
  /// It NO LONGER calls setState. It only selects and returns the definitive model ID.
  Future<String> _selectAndAssignDynamicModel() async {
    debugPrint("[SendService] Dynamic mode: Selecting a model...");
    final allModels = ModelData.getCachedModelsSync();
    final hasPhoto = selectedPhoto != null;
    final hasInternet = await InternetConnection().hasInternetAccess;

    List<Map<String, dynamic>> suitableModels;

    if (!hasInternet) {
      final downloadedPaths = await UserModels.loadDownloadedModelPaths();
      suitableModels = allModels.where((m) {
        final modelData = ModelData.getPreciseModelData(m['id']);
        return modelData['type'] == 'offline' && downloadedPaths.containsKey(m['id']);
      }).toList();
      debugPrint("[SendService] Offline. Found ${suitableModels.length} suitable DOWNLOADED offline models.");
    } else {
      suitableModels = allModels.where((m) {
        final modelData = ModelData.getPreciseModelData(m['id']);
        final type = modelData['type'] as String?;
        final category = modelData['category'] as String?;

        if (category == 'roleplay' || category == 'self') {
          return false;
        }
        if (type == 'offline' && modelData['id'].startsWith('local_')) {
          return false;
        }
        if (hasPhoto) {
          return ModelData.hasModality(m['id'], 'image');
        }
        return true;
      }).toList();
      debugPrint("[SendService] Online. Has photo: $hasPhoto. Found ${suitableModels.length} suitable models (excluding characters/self).");
    }

    if (suitableModels.isEmpty) {
      throw ApiException(AppLocalizations.of(state.context)!.errorNoModelsAvailable);
    }

    final selectedModelData = suitableModels[math.Random().nextInt(suitableModels.length)];
    final selectedModelId = selectedModelData['id'] as String;

    String finalApiModelId;
    final extensionsMap = selectedModelData['extensions'] as Map<String, dynamic>?;

    if (extensionsMap != null && extensionsMap.isNotEmpty) {
      finalApiModelId = extensionsMap.keys.first;
      debugPrint("[SendService] Selected model series '${selectedModelId}' has extensions. Choosing first variant: '$finalApiModelId'");
    } else {
      finalApiModelId = selectedModelId;
    }

    debugPrint("[SendService] Dynamically selected model ID: $finalApiModelId. Returning to sendMessage for state update.");
    return finalApiModelId;
  }

  /// This function now checks the `isPersistentlyDynamic` flag.
  /// 1. If `isPersistentlyDynamic` is TRUE:
  ///    - It calls `_selectAndAssignDynamicModel` to get a NEW random model for every message.
  ///    - The chat remains identified as "dynamic".
  /// 2. If `isPersistentlyDynamic` is FALSE (meaning an assistant is pinned):
  ///    - It uses the currently set `state.modelId` as the definitive target.
  ///    - It DOES NOT call `_selectAndAssignDynamicModel`, ensuring the message goes to the pinned assistant.
  Future<void> sendMessage({
    String? textFromButton,
    bool isRegenerate = false,
    int? regenerateAiIndex,
    String? regeneratePhotoPath,
  }) async {
    final localizations = AppLocalizations.of(state.context)!;
    if (_isSending) return;

    final String messageText = textFromButton ?? state.controller.text.trim();
    if (messageText.isEmpty && selectedPhoto == null && regeneratePhotoPath == null) return;

    _isSending = true;
    FocusScope.of(state.context).unfocus();

    String apiModelIdForSend;

    try {
      // --- CORE LOGIC CHANGE FOR OBJECTIVE 1 ---
      // If the session is a persistent dynamic chat AND the user has NOT pinned an assistant, select a new model every time.
      if (state.isPersistentlyDynamic) {
        apiModelIdForSend = await _selectAndAssignDynamicModel();
      } else {
        // If an assistant IS pinned (`isPersistentlyDynamic` is false), or if it's a normal chat,
        // we MUST use the modelId from the state.
        apiModelIdForSend = state.modelId!;
      }
      // --- END OF CORE LOGIC CHANGE ---

      if (apiModelIdForSend.isEmpty) {
        throw ApiException("No valid model ID could be determined for sending.");
      }

      if (apiModelIdForSend == 'trash') {
        await _handleTrashMessage(messageText);
        _isSending = false;
        return;
      }

      FetchService.fetchUserData().catchError((error) {
        debugPrint("FetchUserData error: $error");
      });

      int? aiMessageIndex;

      if (state.editingMessageIndex != null) {
        await _handleEditingMessage(messageText);
        _isSending = false;
        return;
      } else if (isRegenerate) {
        // Regeneration in dynamic chat will also pick a new model if no assistant is pinned.
        if (state.isPersistentlyDynamic) {
          apiModelIdForSend = await _selectAndAssignDynamicModel();
        }
        aiMessageIndex = regenerateAiIndex;
        state.setState(() {
          if(state.isDynamicChatMode && aiMessageIndex != null) {
            state.messages[aiMessageIndex].model = apiModelIdForSend;
          }
          state.isWaitingForResponse = true;
          state.isSendButtonVisible = false;
          state.responseStopped = false;
        });
      } else {
        final userMessage = Message(
          text: messageText,
          isUserMessage: true,
          photoPath: selectedPhoto != null ? selectedPhoto!.path : null,
          isPhotoUploading: true,
          model: apiModelIdForSend,
        );
        final aiThinkingMessage = Message(
          text: "",
          isUserMessage: false,
          includeInContext: false,
          isThinking: true,
          model: apiModelIdForSend,
        );

        state.setState(() {
          state.messages.add(userMessage);
          state.messages.add(aiThinkingMessage);
          state.controller.clear();
          state.isWaitingForResponse = true;
          state.isSendButtonVisible = false;
          state.responseStopped = false;
        });

        state.readService.markLoaded();
        aiMessageIndex = state.messages.length - 1;

        if (state.conversationID == null) {
          // A chat is "dynamic" if it was initiated without a pre-selected model.
          // This is now determined by the `isDynamicChatMode` flag which is set on initState.
          await _startNewConversation(userMessage, state.isDynamicChatMode, apiModelIdForSend, localizations);
        } else {
          await _appendNewMessage(userMessage, localizations);
        }
      }

      final bool photoAllowed = state.canHandleImage;
      final File? photoForSend = photoAllowed ? selectedPhoto : null;
      String? photoPath = await _handlePhoto(
        photoForSend != null,
        regeneratePhotoPath,
      );
      state.inputFieldKey.currentState?.clearPhotoPanel();

      if (!photoAllowed && selectedPhoto != null) {
        selectedPhoto = null;
      }

      if (!state.isServerSideModel(apiModelIdForSend)) {
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
              : (aiMessageIndex ?? state.messages.length - 1);

          if (targetIndex >= 0 && targetIndex < state.messages.length) {
            state.setState(() {
              final msg = state.messages[targetIndex];
              msg.isThinking = false;
              msg.includeInContext = true;
              state.isWaitingForResponse = false;
            });

            if (state.conversationID != null) {
              await ChatStorageService.upsertMessage(state.conversationID!,
                  targetIndex, state.messages[targetIndex]);
            }
          }
        }
        if (!isRegenerate) {
          debugPrint("[SendService] Successful server response. Triggering review check.");
          unawaited(ReviewService().triggerReviewPromptIfNeeded(state.context));
        }
      }

      String modelSeriesId;
      try {
        final parentModel = state.loadService.allModels.firstWhere((model) {
          if (model.id == apiModelIdForSend) return true;
          return model.extensions?.containsKey(apiModelIdForSend) ?? false;
        });
        modelSeriesId = parentModel.id;
        debugPrint("[SendService] Found parent series '$modelSeriesId' for variant '$apiModelIdForSend'. Storing in recents.");
        await ChatStorageService.addRecentModel(modelSeriesId);
      } catch (e) {
        debugPrint("[SendService] Could not find parent series for '$apiModelIdForSend'. Could not update recent models. Error: $e");
      }

    } catch (e) {
      if (e is UserCancelledException) {
        debugPrint("[SendService] Caught UserCancelledException. Suppressing error UI.");
      } else {
        _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      }
    } finally {
      if (state.mounted) {
        _isSending = false;
      }
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

  /// Starts a new conversation, correctly tagging it as 'dynamic' in the database.
  Future<void> _startNewConversation(
      Message userMessage,
      bool isDynamicConversation, // This flag is true if the chat was started from the generic "Cortex" screen
      String fullModelId,
      AppLocalizations localizations,
      ) async {
    state.conversationID = uuid.v4();
    state.conversationTitle = (userMessage.text.trim().isEmpty && userMessage.photoPath != null)
        ? "🖼️"
        : (userMessage.text.length > 28 ? userMessage.text.substring(0, 28) : userMessage.text);

    // If the conversation is dynamic, its permanent ID in the database is ALWAYS 'dynamic',
    // regardless of which model (random or pinned) was used for the first message.
    // This ensures it reloads correctly from the inbox.
    final modelIdForStorage = isDynamicConversation ? 'dynamic' : fullModelId;

    await ChatStorageService.saveConversation(
      state.conversationID!,
      state.conversationTitle!,
      [],
      modelId: modelIdForStorage,
    );
    CacheService.invalidateConversationCache();

    final userMessageIndex = state.messages.length - 2;

    await ChatStorageService.upsertMessage(
      state.conversationID!,
      userMessageIndex,
      userMessage,
    );
  }

  /// Appends a new message to an existing conversation.
  Future<void> _appendNewMessage(
      Message userMessage,
      AppLocalizations localizations,
      ) async {
    // The user message is now the second to last element in the list, right before the thinking bubble.
    final idx = state.messages.length - 2;
    await ChatStorageService.upsertMessage(
      state.conversationID!,
      idx,
      userMessage,
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
    final modelData = ModelData.getPreciseModelData(modelIdInState);
    final bool isPremium = (modelData['tier'] as String? ?? 'free') == 'premium';
    debugPrint("[SendService] Sending request for model '$modelIdInState'. Is Premium: $isPremium");
    final memory = await state.contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelIdInState,
    );
    final bool isCharacterModel = state.selectedModelCategory == 'roleplay' || state.selectedModelCategory == 'self';

    final onTextChunk = (String textChunk) {
      if (!state.mounted || state.responseStopped) return;
      state.setState(() {
        state.messages[targetIndex].text += textChunk;
      });
      if (state.scrollService.isUserAtBottom()) {
        state.scrollService.scrollToBottom();
      }
    };

    final onImageReceived = (String imageUrl) async {
      if (!state.mounted || state.responseStopped) return;

      try {
        final imageBytes = base64Decode(imageUrl.split(',').last);
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${const Uuid().v4()}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        if (state.mounted) {
          state.setState(() {
            state.messages[targetIndex].photoPath = filePath;
          });

          if (state.conversationID != null) {
            await ChatStorageService.upsertMessage(
              state.conversationID!,
              targetIndex,
              state.messages[targetIndex],
            );
          }
        }
      } catch (e) {
        debugPrint("[SendService] Error saving received image: $e");
        if (state.mounted) {
          state.setState(() {
            final aiMessage = state.messages[targetIndex];
            aiMessage
              ..text = localizations.errorImageLoad
              ..isError = true
              ..isThinking = false;
          });
        }
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
        isPremium: isPremium,
        photoPath: photoPath,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
      );
    } else {
      await state.apiService.getOnlineModelResponse(
        modelId: modelIdInState,
        userInput: text,
        context: memory,
        isPremium: isPremium,
        photoPath: photoPath,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
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
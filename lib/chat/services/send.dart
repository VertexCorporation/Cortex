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

  /// This method analyzes the user's input and context to pick a model.
  /// IT NO LONGER THROWS for predictable failures. It returns a model ID on success, or null on failure.
  Future<String?> _selectAndAssignDynamicModel() async {
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

        if (category == 'roleplay' || category == 'self') return false;
        if (type == 'offline' && modelData['id'].startsWith('local_')) return false;
        if (hasPhoto) return ModelData.hasModality(m['id'], 'image');
        return true;
      }).toList();
      debugPrint("[SendService] Online. Has photo: $hasPhoto. Found ${suitableModels.length} suitable models (excluding characters/self).");
    }

    if (suitableModels.isEmpty) {
      debugPrint("[SendService] No suitable models found. Returning null.");
      return null; // Return null instead of throwing
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

  /// Determines the model to use for sending a message and executes the request.
  ///
  /// This is the central orchestration method for all outgoing messages. It handles
  /// multiple chat states and prioritizes actions in a specific order:
  ///
  /// 1.  **Override Priority:** If an `overrideModelId` is provided (e.g., from a
  ///     "Change and Regenerate" action), that model is used for this single request,
  ///     bypassing all other logic. This is the highest priority.
  ///
  /// 2.  **Dynamic Chat Mode:** If no override is present and the chat is in fully
  ///     dynamic mode (`isPersistentlyDynamic` is true), a new suitable model is
  ///     selected at random for the message.
  ///
  /// 3.  **Pinned Assistant / Standard Chat:** If none of the above, the method uses the
  ///     model currently stored in the `ChatScreenState` (`state.modelId`), which
  ///     applies to both standard chats with a selected model and dynamic chats where
  ///     a user has "pinned" a default assistant.
  ///
  /// The method also handles UI state updates (showing "thinking" bubbles), error
  /// handling (displaying error messages), and delegates the actual network or
  /// local processing to helper methods (`_sendServerSideMessage` or `_sendLocalMessage`).
  Future<void> sendMessage({
    String? textFromButton,
    bool isRegenerate = false,
    int? regenerateAiIndex,
    String? regeneratePhotoPath,
    String? overrideModelId,
  }) async {
    final localizations = AppLocalizations.of(state.context)!;
    if (_isSending) return;

    final String messageText = textFromButton ?? state.controller.text.trim();
    if (messageText.isEmpty && selectedPhoto == null && regeneratePhotoPath == null) return;

    _isSending = true;
    FocusScope.of(state.context).unfocus();

    try {
      if (state.editingMessageIndex != null) {
        await _handleEditingMessage(messageText);
        return;
      }

      String? apiModelIdForSend;
      bool isInternetRequired = false;
      String errorMessage = localizations.errorNoModelsAvailable;

      // --- THE DEFINITIVE MODEL SELECTION LOGIC ---
      // This if/else if/else chain ensures only one logic path is ever executed.
      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        // PRIORITY 1: An override is present. Use it and skip all other checks.
        apiModelIdForSend = overrideModelId;
        debugPrint("[SendService] Using OVERRIDE model ID for this request: $apiModelIdForSend");

        final bool hasInternet = await InternetConnection().hasInternetAccess;
        isInternetRequired = state.isServerSideModel(apiModelIdForSend);
        if (isInternetRequired && !hasInternet) {
          errorMessage = localizations.checkYourInternet;
          apiModelIdForSend = null;
        }
      } else if (state.isPersistentlyDynamic) {
        // PRIORITY 2: No override, and chat is in fully dynamic mode. Select a random model.
        apiModelIdForSend = await _selectAndAssignDynamicModel();
      } else {
        // PRIORITY 3: No override, and an assistant is pinned or it's a standard chat. Use the state's modelId.
        apiModelIdForSend = state.modelId;
        if (apiModelIdForSend == null || apiModelIdForSend.isEmpty) {
          errorMessage = localizations.anErrorOccurred;
          apiModelIdForSend = null; // Ensure it's null if no model is selected
        } else {
          final bool hasInternet = await InternetConnection().hasInternetAccess;
          isInternetRequired = state.isServerSideModel(apiModelIdForSend);

          if (isInternetRequired && !hasInternet) {
            errorMessage = localizations.checkYourInternet;
            apiModelIdForSend = null;
          }
        }
      }
      // --- END OF MODEL SELECTION LOGIC ---

      // Handle cases where no suitable model could be determined.
      if (apiModelIdForSend == null) {
        if (isRegenerate && regenerateAiIndex != null) {
          // Update the existing AI bubble with an error during regeneration.
          state.setState(() {
            final aiMessage = state.messages[regenerateAiIndex];
            aiMessage.text = errorMessage;
            aiMessage.isError = true;
            aiMessage.isThinking = false;
            state.isWaitingForResponse = false;
          });
        } else {
          // For new messages, add user's prompt and a new error bubble.
          final userMessage = Message(
            text: messageText,
            isUserMessage: true,
            photoPath: selectedPhoto != null ? selectedPhoto!.path : null,
          );
          final errorAIMessage = Message(
            text: errorMessage,
            isUserMessage: false,
            includeInContext: false,
            isError: true,
          );

          if (state.conversationID == null) {
            final modelIdForStorage = state.isPersistentlyDynamic ? 'dynamic' : state.modelId!;
            await _startNewConversation(userMessage, state.isPersistentlyDynamic, modelIdForStorage, localizations);
          } else {
            await _appendNewMessage(userMessage, localizations);
          }

          state.setState(() {
            state.messages.add(userMessage);
            state.messages.add(errorAIMessage);
            state.controller.clear();
            state.isWaitingForResponse = false;
          });
          state.readService.markLoaded();
        }

        state.inputFieldKey.currentState?.clearPhotoPanel();
        selectedPhoto = null;
        return;
      }

      // --- Prepare UI and messages for sending ---
      final userMessage = Message(
        text: messageText,
        isUserMessage: true,
        photoPath: selectedPhoto != null ? selectedPhoto!.path : null,
        isPhotoUploading: true,
        model: apiModelIdForSend,
      );

      int? aiMessageIndex;
      if (isRegenerate) {
        aiMessageIndex = regenerateAiIndex;
        state.setState(() {
          if (state.isDynamicChatMode && aiMessageIndex != null) {
            state.messages[aiMessageIndex].model = apiModelIdForSend;
          }
          state.isWaitingForResponse = true;
          state.responseStopped = false;
        });
      } else {
        final aiThinkingMessage = Message(
          text: "", isUserMessage: false, includeInContext: false,
          isThinking: true, model: apiModelIdForSend,
        );

        if (state.conversationID == null) {
          await _startNewConversation(userMessage, state.isDynamicChatMode, apiModelIdForSend, localizations);
        } else {
          await _appendNewMessage(userMessage, localizations);
        }

        state.setState(() {
          state.messages.add(userMessage);
          state.messages.add(aiThinkingMessage);
          state.controller.clear();
          state.isWaitingForResponse = true;
          state.responseStopped = false;
        });
        state.readService.markLoaded();
        aiMessageIndex = state.messages.length - 1;
      }

      if (apiModelIdForSend == 'trash') {
        await _handleTrashMessage(messageText);
        return;
      }

      FetchService.fetchUserData().catchError((error) {
        debugPrint("[SendService] Background fetchUserData error: $error");
      });

      final bool photoAllowed = ModelData.hasModality(apiModelIdForSend, 'image');
      final File? photoForSend = photoAllowed ? selectedPhoto : null;
      String? photoPath = await _handlePhoto(photoForSend != null, regeneratePhotoPath);
      state.inputFieldKey.currentState?.clearPhotoPanel();
      if (!photoAllowed && selectedPhoto != null) selectedPhoto = null;

      // --- Delegate to the appropriate sender (local or server-side) ---
      if (!state.isServerSideModel(apiModelIdForSend)) {
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(messageText)) {
          unawaited(_sendLocalMessage(messageText, photoPath, apiModelIdForSend));
        } else {
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
              ? regenerateAiIndex : (aiMessageIndex ?? state.messages.length - 1);
          if (targetIndex >= 0 && targetIndex < state.messages.length) {
            state.setState(() {
              final msg = state.messages[targetIndex];
              msg.isThinking = false;
              msg.includeInContext = true;
              state.isWaitingForResponse = false;
            });

            if (state.conversationID != null) {
              await ChatStorageService.upsertMessage(state.conversationID!, targetIndex, state.messages[targetIndex]);
            }
          }
        }
        if (!isRegenerate) {
          unawaited(ReviewService().triggerReviewPromptIfNeeded(state.context));
        }
      }

      // --- Post-send cleanup and updates ---
      try {
        final modelData = ModelData.getPreciseModelData(apiModelIdForSend);
        final parentId = ModelData.getBaseIdFromFullId(apiModelIdForSend);
        final modelIdToStore = parentId.isNotEmpty ? parentId : apiModelIdForSend;
        debugPrint("[SendService] Storing '$modelIdToStore' in recent models for used model '$apiModelIdForSend'.");
        await ChatStorageService.addRecentModel(modelIdToStore);
      } catch (e) {
        debugPrint("[SendService] Could not find parent series for '$apiModelIdForSend'. Could not update recent models. Error: $e");
      }
      unawaited(state.refreshRecentModels());

    } catch (e) {
      if (e is UserCancelledException) {
        if (state.isWaitingForResponse) {
          _handleSendError(ApiException("Cancelled"), isRegenerate, regenerateAiIndex, localizations);
        }
        return;
      }
      _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
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
  Future<void> _sendLocalMessage(String text, String? photoPath, String modelId) async {
    try {
      // The native code will send back tokens via the MethodCallHandler.
      // We wrap it in a try-catch to handle potential errors during the call itself.
      debugPrint("[SendService] Sending local message to model '$modelId'."); // Good for logging
      await ChatScreenState.llamaChannel.invokeMethod<void>(
        'sendMessage',
        {
          'message':   text,
          'photoPath': photoPath,
          // 'role' is handled by the context service.
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
      String modelIdForRequest,
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
    final modelData = ModelData.getPreciseModelData(modelIdForRequest);
    final bool isPremium = (modelData['tier'] as String? ?? 'free') == 'premium';
    debugPrint("[SendService] Sending request for model '$modelIdForRequest'. Is Premium: $isPremium");
    final memory = await state.contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelIdForRequest,
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
      final characterData = ModelData.getPreciseModelData(modelIdForRequest);
      final baseModelId = characterData['baseModelId'] as String?;

      if (baseModelId == null || baseModelId.isEmpty) {
        throw ApiException("Character '$modelIdForRequest' has no valid base model configured.");
      }

      await state.apiService.getCharacterResponse(
        userInput: text,
        context: memory,
        characterId: modelIdForRequest,
        baseModelId: baseModelId,
        isPremium: isPremium,
        photoPath: photoPath,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
      );
    } else {
      await state.apiService.getOnlineModelResponse(
        modelId: modelIdForRequest,
        userInput: text,
        context: memory,
        isPremium: isPremium,
        photoPath: photoPath,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
      );
    }
  }

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
// lib/chat/services/send.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:cortex/analytics/service.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/moderator.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
import '../messages/messages.dart';
import 'package:cortex/chat/providers/memory.dart';
import 'tools.dart';

/// Service responsible for sending messages. It orchestrates interactions between providers and other services.
class SendService {
  final ConversationProvider _conversationProvider;
  final InputProvider _inputProvider;
  final ApiService _apiService;
  final ContextService _contextService;
  final ScrollService _scrollService;
  final OfflineService _offlineService;
  final Uuid _uuid = const Uuid();
  bool _isSending = false;
  final ModelService _modelService;
  final VoiceService _voiceService;
  final UserMemoryProvider _userMemoryProvider;

  SendService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required InputProvider inputProvider,
    required ApiService apiService,
    required ContextService contextService,
    required ScrollService scrollService,
    required OfflineService offlineService,
    required ModelService modelService,
    required VoiceService voiceService,
    required UserMemoryProvider userMemoryProvider,
  })
      : _conversationProvider = conversationProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _offlineService = offlineService,
        _modelService = modelService,
        _voiceService = voiceService,
        _userMemoryProvider = userMemoryProvider;

  /// Main entry point to send a message.
  Future<bool> sendMessage({
    required BuildContext context,
    required AppLocalizations localizations,
    required String messageText,
    bool isRegenerate = false,
    int? regenerateAiIndex,
    String? overrideModelId,
    bool isHidden = false,
    String? voiceSystemPrompt,
  }) async {
    if (_isSending) {
      debugPrint("SendService: Already sending. Ignored.");
      return false;
    }

    final sessionProvider = context.read<ChatSessionProvider>();

    // -----------------------------------------------------------------------
    // 1. PREPARE CONTENT
    // -----------------------------------------------------------------------

    final String text = messageText.trim();
    List<String> currentAttachmentPaths = [];

    if (isRegenerate) {
      final messages = _conversationProvider.messages;
      final lastUserMessage = messages.reversed.firstWhere(
            (m) => m.isUserMessage,
        orElse: () => Message(text: '', isUserMessage: true),
      );
      currentAttachmentPaths = List.from(lastUserMessage.attachmentPaths);
    } else {
      // Use the class member _inputProvider or the local one.
      // Since we injected it, _inputProvider is safe.
      currentAttachmentPaths =
          _inputProvider.attachments.map((a) => a.file.path).toList();
    }

    if (text.isEmpty && currentAttachmentPaths.isEmpty) {
      return false;
    }

    _isSending = true;

    try {
      // -----------------------------------------------------------------------
      // 2. FEATURE MODES (Study, Quiz, etc.)
      // -----------------------------------------------------------------------
      final activeMode = _inputProvider.featureMode;
      final bool enableThinkingMode =
          activeMode == ChatInputMode.featureReasoning;
      String textForApi = text;

      // Apply voice system prompt to API text only (not shown to user)
      if (voiceSystemPrompt != null && voiceSystemPrompt.isNotEmpty) {
        textForApi = "$voiceSystemPrompt\n\n$textForApi";
      }

      if (activeMode == ChatInputMode.study) {
        textForApi = "${localizations.featureStudyMessage}\n\n$text";
      } else if (activeMode == ChatInputMode.quiz) {
        textForApi = "${localizations.featureQuizMessage}\n\n$text";
      }

      // -----------------------------------------------------------------------
      // 3. MODEL RESOLUTION
      // -----------------------------------------------------------------------
      String? apiModelIdForSend;
      String errorMessage = localizations.errorNoModelsAvailable;

      final localState = context.read<ModelLocalStateProvider>();
      final langCode = Localizations
          .localeOf(context)
          .languageCode;
      final hasInternet = await InternetConnection().hasInternetAccess;

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
      } else if (sessionProvider.isDynamicChat) {
        apiModelIdForSend = 'cortex/auto';
      } else {
        apiModelIdForSend = sessionProvider.modelId;
      }

      // Smart Selection Logic
      if (apiModelIdForSend != null && apiModelIdForSend != 'cortex/auto') {
        final ModelEntity entity = _modelService
            .getPreciseModelData(apiModelIdForSend, langCode: langCode);

        if (entity.variants != null && entity.variants!.isNotEmpty) {
          final List<dynamic> variants = entity.variants!.values.toList();
          final bool hasVisualContent =
          currentAttachmentPaths.any((path) => _isImageFile(path));

          List<dynamic> getPreferredCandidates(List<dynamic> sourceList) {
            final filtered = sourceList.where((v) {
              final String vid = v['id'].toString().toLowerCase();
              final String vTier =
                  v['tier']?.toString().toLowerCase() ?? 'free';
              return !vid.contains('guard') && vTier != 'premium';
            }).toList();
            return filtered.isNotEmpty ? filtered : sourceList;
          }

          final bool mustRunOffline = (entity.type == 'offline') ||
              (!hasInternet && !entity.isServerSide);

          if (mustRunOffline) {
            final downloadedVariants = variants
                .where((v) => localState.downloadCompleted[v['id']] == true)
                .toList();

            if (downloadedVariants.isEmpty) {
              errorMessage = localizations.errorNoModelsAvailable;
              apiModelIdForSend = null;
            } else {
              if (hasVisualContent) {
                final visionModel = downloadedVariants.firstWhere(
                      (v) => (v['modalities']?['image'] == true),
                  orElse: () => null,
                );
                apiModelIdForSend = visionModel != null
                    ? visionModel['id']
                    : getPreferredCandidates(downloadedVariants).first['id'];
              } else {
                apiModelIdForSend =
                getPreferredCandidates(downloadedVariants).first['id'];
              }
            }
          } else {
            // Online Variants
            if (hasVisualContent) {
              final visionModel = variants.firstWhere(
                    (v) => (v['modalities']?['image'] == true),
                orElse: () => null,
              );
              apiModelIdForSend = visionModel != null
                  ? visionModel['id']
                  : getPreferredCandidates(variants).first['id'];
            } else {
              apiModelIdForSend = getPreferredCandidates(variants).first['id'];
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // 4. CHECKS & UI UPDATES
      // -----------------------------------------------------------------------

      if (apiModelIdForSend == null) {
        throw ApiException(errorMessage);
      }

      final isAutoRouter = apiModelIdForSend == 'cortex/auto';
      final isServerSide = isAutoRouter ||
          Utils.isServerSideModel(apiModelIdForSend,
              langCode: langCode, modelService: _modelService);

      if (isServerSide && !hasInternet) {
        throw ApiException(localizations.checkYourInternet);
      }

      // Optimistic UI Message
      final userMessage = Message(
        text: text,
        isUserMessage: true,
        attachmentPaths: currentAttachmentPaths,
        isAttachmentUploading: currentAttachmentPaths.isNotEmpty,
        model: apiModelIdForSend,
        isVisible: !isHidden,
      );

      int aiMessageIndex;
      if (isRegenerate && regenerateAiIndex != null) {
        aiMessageIndex = regenerateAiIndex;
      } else {
        if (_conversationProvider.conversationID == null) {
          final newConvId = _uuid.v4();
          final defaultTitle =
          (text.isEmpty && currentAttachmentPaths.isNotEmpty)
              ? "📁"
              : (text.length > 32 ? text.substring(0, 32) : text);

          final modelForStorage = sessionProvider.isDynamicChat
              ? (sessionProvider.modelId ?? 'dynamic')
              : apiModelIdForSend;

          if (isHidden) {
            _conversationProvider.startEphemeralSession(
                newConvId, modelForStorage, userMessage,
                title: isHidden ? localizations.flowMode : null);
          } else {
            _conversationProvider.startNewConversationSession(
                newConvId, defaultTitle, modelForStorage, userMessage);

            // 🚀 ASYNC AI CHAT TITLE GENERATION
            if (isServerSide && text.isNotEmpty) {
              debugPrint("🚀 Triggering TitleGen for new chat...");
              _apiService
                  .generateChatTitle(text, localizations.chatTitlePrompt,
                  localizations.chatTitleCriticalInstruction)
                  .then((aiTitle) {
                if (aiTitle != null && aiTitle
                    .trim()
                    .isNotEmpty) {
                  final cleanTitle =
                  aiTitle.length > 40 ? aiTitle.substring(0, 40) : aiTitle;

                  // Update current UI if we are still on this chat
                  if (_conversationProvider.conversationID == newConvId) {
                    _conversationProvider.updateConversationTitle(cleanTitle);
                    // Also set it in DB and broadcast via storage stream so Axon Inbox sees it
                    ChatStorageService.renameConversation(
                        newConvId, cleanTitle);
                  } else {
                    // Update local storage in the background
                    ChatStorageService.renameConversation(
                        newConvId, cleanTitle);
                  }
                }
              }).catchError((e) {
                debugPrint("TitleGen error: $e");
              });
            }
          }
        } else {
          _conversationProvider.appendMessageToConversation(userMessage);
        }
        aiMessageIndex = _conversationProvider.messages.length - 1;
      }

      _inputProvider.clearAttachments();

      // -----------------------------------------------------------------------
      // 5. EXECUTION ROUTING
      // -----------------------------------------------------------------------

      if (!isServerSide) {
        // Offline Flow
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(textForApi)) {
          await _offlineService.sendMessage(
              textForApi, currentAttachmentPaths.firstOrNull);
        } else {
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        // Server Flow (with Tool Loop & featureReasoning)
        await _sendServerSideMessageWithLoop(
          initialText: textForApi,
          modelId: apiModelIdForSend,
          attachments: currentAttachmentPaths,
          localizations: localizations,
          aiMessageIndex: aiMessageIndex,
          langCode: langCode,
          enableThinkingMode: enableThinkingMode,
        );

        _conversationProvider.finishBotResponse(aiMessageIndex);

        if (_inputProvider.isVoiceModeActive) {
          _voiceService.onAiResponseFinished();
        }
      }

      // -----------------------------------------------------------------------
      // 6. ANALYTICS & HISTORY
      // -----------------------------------------------------------------------
      if (!isAutoRouter) {
        ChatStorageService.addRecentModel(apiModelIdForSend,
            langCode: langCode, modelService: _modelService)
            .ignore();
      }

      AnalyticsService().logMessageSent(
        modelType: !isServerSide ? 'offline' : 'online',
        hasAttachments: currentAttachmentPaths.isNotEmpty,
      );

      return true;
    } catch (e) {
      if (e is UserCancelledException) return false;
      _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      return false;
    } finally {
      _isSending = false;
    }
  }

  /// Manages the full conversation loop:
  /// 1. Sends Request
  /// 2. Streams Text/featureReasoning
  /// 3. Captures Tool Calls
  /// 4. Executes Tools
  /// 5. Loops back to step 1 if tools were used.
  Future<void> _sendServerSideMessageWithLoop({
    required String initialText,
    required String modelId,
    required List<String> attachments,
    required AppLocalizations localizations,
    required int aiMessageIndex,
    required String langCode,
    required bool enableThinkingMode,
  }) async {
    final ModelEntity modelData =
    _modelService.getPreciseModelData(modelId, langCode: langCode);
    final bool isPremium = modelData.isPremium;

    final bool isCharacterModel =
        (modelData.category == 'roleplay' || modelData.category == 'self') &&
            modelId != 'cortex/auto';

    // Use the enableThinkingMode passed from sendMessage (captured before clearAllInput)
    final bool enablefeatureReasoning = enableThinkingMode;

    // 1. Build Base Context (History)
    List<Map<String, dynamic>> contextMessages =
    await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelId,
      langCode: langCode,
      enableThinkingMode: enablefeatureReasoning,
      localizations: localizations,
    );

    // 2. Add Current User Message to Context (Manual Construction)
    // We do this manually because attachments need to be processed into base64 blocks
    final List<Map<String, dynamic>> userContent = [];
    if (initialText.isNotEmpty) {
      userContent.add({"type": "text", "text": initialText});
    }
    for (var path in attachments) {
      final block = await Utils.processAttachment(path);
      if (block != null) userContent.add(block);
    }

    // Extract documents for tool processing (PDF, XLSX, etc.)
    final documents = Utils.extractDocuments(userContent);
    if (documents.isNotEmpty) {
      ToolRegistry.setDocumentsContext(documents);
    }

    // Clean content blocks before sending to API (remove internal _document fields)
    final cleanedUserContent = Utils.cleanContentBlocks(userContent);

    if (cleanedUserContent.isNotEmpty) {
      contextMessages.add({"role": "user", "content": cleanedUserContent});
    }

    // Loop Variables
    bool shouldContinue = true;
    int loopCount = 0;
    const int maxLoops = 5; // Safety break

    // State for managing featureReasoning block - OUTSIDE loop to persist across iterations
    // enablefeatureReasoning is already defined above when building context
    bool isfeatureReasoningBlockActive = false;
    bool hasEverHadfeatureReasoning =
    false; // Track if we've seen any featureReasoning

    // --- THE LOOP ---
    while (shouldContinue && loopCount < maxLoops) {
      shouldContinue = false; // Stop unless tools are called
      loopCount++;

      List<dynamic> turnToolCalls = [];

      // Handler Functions (defined here to capture scope)

      void onfeatureReasoning(String featureReasoningText) {
        // Skip featureReasoning if disabled
        if (!enablefeatureReasoning) return;
        if (_conversationProvider.wasResponseStopped) return;

        // If this is the START of a featureReasoning block, open the tag
        if (!isfeatureReasoningBlockActive) {
          // If we had featureReasoning before and closed it, we're continuing - add separator
          if (hasEverHadfeatureReasoning) {
            _conversationProvider.appendToLastBotMessage("\n\n");
          }
          _conversationProvider.appendToLastBotMessage("<think>");
          isfeatureReasoningBlockActive = true;
          hasEverHadfeatureReasoning = true;
        }

        // Ensure we don't double-append headers or newlines. Just the raw text.
        _conversationProvider.appendToLastBotMessage(featureReasoningText);
      }

      void onTextChunk(String text) {
        if (_conversationProvider.wasResponseStopped) return;
        if (text.isEmpty) return; // Ignore empty keep-alive chunks

        // If we were featureReasoning and now switched to ACTUAL content, close the featureReasoning tag
        if (enablefeatureReasoning && isfeatureReasoningBlockActive) {
          _conversationProvider.appendToLastBotMessage("</think>");
          isfeatureReasoningBlockActive = false;
        }

        _conversationProvider.appendToLastBotMessage(text);
        if (_inputProvider.isVoiceModeActive) {
          _voiceService.onAiStreamCallback(text);
        }
        if (_scrollService.isUserAtBottom()) {
          _scrollService.scrollToBottom(
              duration: const Duration(milliseconds: 50));
        }
      }

      Future<void> onImageReceived(String url) async {
        if (_conversationProvider.wasResponseStopped) return;
        try {
          final bytes = base64Decode(url
              .split(',')
              .last);
          final path =
              '${(await getTemporaryDirectory()).path}/${_uuid.v4()}.png';
          await File(path).writeAsBytes(bytes);
          // UI update logic implies message provider listens to changes or reloads
        } catch (e) {
          debugPrint("Image save error: $e");
        }
      }

      // Execute Request
      if (isCharacterModel) {
        // Characters typically don't use tools in this architecture yet
        var baseModelId = modelData.baseModelId;
        if (baseModelId == 'dynamic') baseModelId = 'cortex/auto';

        await _apiService.getCharacterResponse(
          userInput: "",
          // Already in context
          context: contextMessages,
          characterId: modelId,
          baseModelId: baseModelId ?? 'cortex/auto',
          isPremium: isPremium,
          enablefeatureReasoning: enablefeatureReasoning,
          localizations: localizations,
          onTextChunk: onTextChunk,
          onfeatureReasoning: onfeatureReasoning,
          onImageReceived: onImageReceived,
        );
        // Characters exit loop immediately
        shouldContinue = false;
      } else {
        // Standard Models (Support Tools)
        final enableWebSearch = _inputProvider.enableWebSearch;
        await _apiService.getOnlineModelResponse(
          modelId: modelId,
          isPremium: isPremium,
          userInput: "",
          // Already in context
          context: contextMessages,
          localizations: localizations,
          langCode: langCode,
          enablefeatureReasoning: enablefeatureReasoning,
          enableWebSearch: enableWebSearch,
          useTools: !_voiceService.isFlowActive,
          // Disable tools in Flow Mode
          onTextChunk: onTextChunk,
          onfeatureReasoning: onfeatureReasoning,
          onImageReceived: onImageReceived,
          // Capture Tools
          onToolCall: (tools) {
            turnToolCalls = tools;
          },
          onCitations: (citations) {
            _conversationProvider.updateLastBotMessageSources(citations);
          },
        );
      }

      // Post-Response: Check for Tools
      if (turnToolCalls.isNotEmpty) {
        shouldContinue = true; // We need to loop again to send results

        // Close featureReasoning block before tool execution if it's still open
        if (enablefeatureReasoning && isfeatureReasoningBlockActive) {
          _conversationProvider.appendToLastBotMessage("</think>");
          isfeatureReasoningBlockActive = false;
        }

        // 1. Add Assistant Request to History
        contextMessages.add({
          "role": "assistant",
          "content": "", // Usually empty when calling tools
          "tool_calls": turnToolCalls
        });

        // 2. Execute Tools & Add Results
        for (var call in turnToolCalls) {
          final String callId = call['id'];
          final String name = call['function']['name'];
          final String argsStr = call['function']['arguments'];

          String result;
          final tool = ToolRegistry.getTool(name);

          // Variables for structured output
          String? widgetType;
          Map<String, dynamic>? widgetData;
          String summaryForContext = "";

          if (tool != null) {
            try {
              final args = jsonDecode(argsStr);
              // Execute tool
              result = await tool.function(args);

              // CHECK FOR STRUCTURED WIDGET RESPONSE
              try {
                if (result.trim().startsWith('{')) {
                  final jsonResult = jsonDecode(result);
                  if (jsonResult is Map && jsonResult.containsKey('widget')) {
                    widgetType = jsonResult['widget'];
                    widgetData = jsonResult['data'];
                    summaryForContext = jsonResult['summary'].toString();
                  }
                }
              } catch (_) {
                // Not a widget json, proceed as normal
              }

              if (widgetType != null) {
                // Inject Widget Marker (no extra newlines to avoid spacing issues)
                // The UI (parser) will detect this pattern and render the card
                _conversationProvider.appendToLastBotMessage(
                    "<<<WIDGET:$widgetType>>>${jsonEncode(
                        widgetData)}<<<END>>>");
                // Force immediate UI update for widget visibility
                _conversationProvider.flushStreamUpdates();

                // Use the summary for the LLM context so it doesn't get confused by raw JSON
                result = summaryForContext;
              }
            } catch (e) {
              result = "Error executing tool '$name': $e";
            }
          } else {
            result = "Tool not found.";
          }

          // Add Tool Result to History
          contextMessages.add({
            "role": "tool",
            "tool_call_id": callId,
            "name": name,
            "content": result
          });
        }
      }
    }

    // Ensure featureReasoning block is closed at the end of all iterations
    // This handles cases where the final response ends with featureReasoning
    if (enablefeatureReasoning && isfeatureReasoningBlockActive) {
      _conversationProvider.appendToLastBotMessage("</think>");
      isfeatureReasoningBlockActive = false;
    }

    // Clear documents context after processing
    ToolRegistry.clearDocumentsContext();

    // Extract memory updates if any
    final finalResponseText = _conversationProvider.messages.isNotEmpty
        ? _conversationProvider.messages.last.text
        : "";
    final memoryExp =
    RegExp(r'<memory>([\s\S]*?)(?:</memory>|$)', caseSensitive: false);
    final memoryMatch = memoryExp.firstMatch(finalResponseText);
    if (memoryMatch != null) {
      final newMemory = memoryMatch.group(1)?.trim();
      if (newMemory != null && newMemory.isNotEmpty) {
        _userMemoryProvider.updateMemory(newMemory);
        debugPrint(
            '[Memory] Successfully extracted and updated memory from response.');
      }
    }
  }

  void _handleSendError(Object error,
      bool isRegenerate,
      int? regenerateAiIndex,
      AppLocalizations localizations, {
        String? failedUserText,
        List<String>? failedAttachmentPaths,
      }) {
    final String errorMessage =
    error is ApiException ? error.message : localizations.anErrorOccurred;
    final bool isContentFlagError = error is ApiException &&
        error.message == localizations.errorPromptFlagged;

    if (isRegenerate && regenerateAiIndex != null) {
      _conversationProvider.setErrorMessage(
        regenerateAiIndex,
        errorMessage,
        isContentFlagError,
      );
    } else {
      final userMessagePlaceholder = Message(
        text: failedUserText ?? "",
        isUserMessage: true,
        attachmentPaths: failedAttachmentPaths ??
            _inputProvider.attachments.map((a) => a.file.path).toList(),
        includeInContext: !isContentFlagError,
      );

      _conversationProvider.showSendError(
        userMessagePlaceholder,
        errorMessage,
        isContentFlagError,
      );
    }
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }
}

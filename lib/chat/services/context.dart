// lib/chat/services/context.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/l10n/app_localizations.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

/// Service responsible for building the list of messages in the format
/// required by the backend API. It reads the current state from the relevant providers.
class ContextService {
  final ChatSessionProvider _sessionProvider;
  final ConversationProvider _conversationProvider;
  final ModelService _modelService;

  ContextService({
    required ChatSessionProvider sessionProvider,
    required ConversationProvider conversationProvider,
    required ModelService modelService,
  })
      : _sessionProvider = sessionProvider,
        _conversationProvider = conversationProvider,
        _modelService = modelService;

  /// Builds the list of messages for the API context.
  Future<List<Map<String, dynamic>>> buildContextMessages({
    bool includeLastUser = true,
    required String targetModelId,
    required String langCode,
    bool enableThinkingMode = false,
    bool isServerSide = true,
    bool isCharacterModel = false,
    AppLocalizations? localizations,
    String? userMemory,
    String? customInstruction,
    int memoryCharLimit = 1000,
  }) async {
    final List<Map<String, dynamic>> contextMessages = [];

    // Read the system role from the session provider.
    String? systemRole = _sessionProvider.role;

    // Determine fallback role
    final String fallbackRole = localizations?.systemRoleFallback ??
        "You are a helpful assistant.";

    if (isServerSide && userMemory != null && userMemory
        .trim()
        .isNotEmpty) {
      final memoryPrompt = localizations != null
          ? localizations.systemMemoryReminder(userMemory)
          : "\n\nAlways remember this about the user:\n$userMemory";
      systemRole = (systemRole ?? fallbackRole) + memoryPrompt;
    }

    // Inject custom instruction (Intelligence) after memory
    if (customInstruction != null &&
        customInstruction
            .trim()
            .isNotEmpty &&
        localizations != null) {
      final instructionPrompt =
          "\n\n${localizations.intelligenceSystemPrompt(
          customInstruction.trim())}";
      systemRole = (systemRole ?? fallbackRole) + instructionPrompt;
    }

    // Inject Cortex Persona if it's an online model and NOT a character model
    if (isServerSide && localizations != null && !isCharacterModel) {
      systemRole =
          (systemRole ?? fallbackRole) + localizations.cortexSystemPersona;
    }

    // If thinking mode is enabled, append the localized instruction to system prompt
    if (enableThinkingMode && localizations != null) {
      final thinkingInstruction = "\n\n${localizations
          .thinkingModeInstruction}";
      if (systemRole != null && systemRole.isNotEmpty) {
        systemRole = systemRole + thinkingInstruction;
      } else {
        systemRole = (fallbackRole) + thinkingInstruction;
      }
    }

    // Read the message list from the conversation provider and filter for valid context.
    // We specifically exclude messages that are not visible to the user (e.g., pre-input prompts).
    List<Message> history = _conversationProvider.messages
        .where((m) =>
    m.includeInContext && !m.isThinking && !m.isError && m.isVisible)
        .toList();

    int userMessageCount = history
        .where((m) => m.isUserMessage)
        .length;

    // Inject memory extraction instruction for non-character server-side models.
    // Character models (roleplay/self) should NOT get this directive because:
    // 1. They should focus on their persona, not analyze user facts.
    // 2. The directive is a massive English-only text block that overwhelms
    //    the localized language instruction, causing characters to default to English.
    if (isServerSide && !isCharacterModel && userMessageCount >= 0) {
      final extractionInstruction = localizations != null
          ? localizations.systemMemoryDirective
          : "\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalyze the conversation so far. If you learned ANY new distinct facts about the user (preferences, name, habits, context), you MUST output your ENTIRE updated memory about the user inside <memory>...</memory> tags AT THE VERY END of your response. CRITICAL: You must NEVER erase or overwrite previous memory. ALWAYS append new facts to the existing memory. If absolutely nothing new was learned, omit the tag. Example: <memory>Loves football and tennis. Prefers short answers.</memory>";
      systemRole = (systemRole ?? fallbackRole) + extractionInstruction;
    }

    // Inject language instruction
    if (localizations != null) {
      systemRole = (systemRole ?? fallbackRole) +
          localizations.systemLanguageInstruction;
    }

    // Inject current date and time (localized) for ALL models including characters.
    // This replaces the old server-side English-only time injection.
    if (localizations != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat.yMMMd(langCode).add_Hm().format(now);
      systemRole = (systemRole ?? fallbackRole) +
          localizations.systemTimeInfo(formattedTime);
    }

    final bool shouldIncludeAllMedia =
        targetModelId == 'cortex/auto' || targetModelId == 'dynamic';
    final bool targetModelSupportsImages = shouldIncludeAllMedia ||
        _modelService.hasModality(
          targetModelId,
          langCode: langCode,
          modality: 'image',
        );

    // Add the system prompt to the context, if it exists.
    if (systemRole != null && systemRole.isNotEmpty) {
      contextMessages.add({"role": "system", "content": systemRole});
    }

    // If we're regenerating a response, exclude the last user message
    // because it will be added again by the SendService.
    if (!includeLastUser && history.isNotEmpty) {
      final int lastUserMessageIndex =
      history.lastIndexWhere((m) => m.isUserMessage);
      if (lastUserMessageIndex != -1) {
        history = history.sublist(0, lastUserMessageIndex);
      }
    }

    // Loop through the filtered history and format each message into the API's required JSON structure.
    for (final message in history) {
      contextMessages.addAll(await _formatMessagesToJson(
        message,
        includeImage: targetModelSupportsImages,
        includeAllMedia: shouldIncludeAllMedia,
        localizations: localizations,
      ));
    }

    // Safety check: Filter out empty messages
    return contextMessages.where((m) {
      final content = m['content'];
      if (content is String) return content.isNotEmpty;
      if (content is List) return content.isNotEmpty;
      return false;
    }).toList();
  }

  /// Helper function to convert a single `Message` object to the required
  /// multimodal JSON format. If the assistant generated an image, we split it
  /// into a separate synthetic user message so the vision API accepts it.
  Future<List<Map<String, dynamic>>> _formatMessagesToJson(Message message,
      {required bool includeImage, required bool includeAllMedia, AppLocalizations? localizations}) async {
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> textParts = [];
    List<Map<String, dynamic>> mediaParts = [];

    // 1. Text Content
    if (message.text.isNotEmpty) {
      textParts.add({"type": "text", "text": message.text});
    }

    // 2. Attachment Content
    if (includeImage && message.hasAttachments) {
      for (final path in message.attachmentPaths) {
        if (_isImageFile(path) ||
            (includeAllMedia && (_isVideoFile(path) || _isAudioFile(path)))) {
          final String? base64Image = await Utils.formatBase64Media(path);
          if (base64Image != null) {
            mediaParts.add({
              "type": "image_url",
              "image_url": {"url": base64Image}
            });
          }
        }
      }
    }

    List<Map<String, dynamic>> results = [];

    if (role == "user") {
      // User messages can have both text and media in the same block
      results.add({
        "role": "user",
        "content": [...textParts, ...mediaParts]
      });
    } else {
      // Assistant messages: Text goes to assistant, Media goes to a synthetic user block
      if (textParts.isNotEmpty || mediaParts.isEmpty) {
        results.add({
          "role": "assistant",
          "content": textParts.isNotEmpty ? textParts : [
            {"type": "text", "text": " "}
          ]
        });
      }

      if (mediaParts.isNotEmpty) {
        final noteText = localizations?.systemNotePreviousMedia ??
            "[System Note: Below is the media generated previously, you may reference or edit it.]";
        mediaParts.insert(0, {"type": "text", "text": noteText});
        results.add({
          "role": "user",
          "content": mediaParts
        });
      }
    }

    return results;
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }

  bool _isVideoFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['mp4', 'mov', 'm4v', 'webm', 'mkv', 'avi'].contains(ext);
  }

  bool _isAudioFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'opus'].contains(ext);
  }
}

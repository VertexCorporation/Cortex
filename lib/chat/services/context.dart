// lib/chat/services/context.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/l10n/app_localizations.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

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
    AppLocalizations? localizations,
  }) async {
    final List<Map<String, dynamic>> contextMessages = [];

    // Read the system role from the session provider.
    String? systemRole = _sessionProvider.role;

    // If thinking mode is enabled, append the localized instruction to system prompt
    if (enableThinkingMode && localizations != null) {
      final thinkingInstruction = "\n\n${localizations.thinkingModeInstruction}";
      if (systemRole != null && systemRole.isNotEmpty) {
        systemRole = systemRole + thinkingInstruction;
      } else {
        systemRole = thinkingInstruction.trim();
      }
    }

    // Read the message list from the conversation provider and filter for valid context.
    List<Message> history = _conversationProvider.messages
        .where((m) => m.includeInContext && !m.isThinking && !m.isError)
        .toList();

    final bool targetModelSupportsImages = _modelService.hasModality(
        targetModelId, langCode: langCode, modality: 'image');

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
      contextMessages.add(await _formatMessageToJson(
        message,
        includeImage: targetModelSupportsImages,
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
  /// multimodal JSON format.
  Future<Map<String, dynamic>> _formatMessageToJson(Message message,
      {required bool includeImage}) async {
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> contentParts = [];

    // 1. Text Content
    if (message.text.isNotEmpty) {
      contentParts.add({"type": "text", "text": message.text});
    }

    // 2. Attachment Content (Images only for now)
    if (includeImage && message.hasAttachments) {
      for (final path in message.attachmentPaths) {
        if (_isImageFile(path)) {
          final String? base64Image = await Utils.formatBase64Image(path);
          if (base64Image != null) {
            contentParts.add({
              "type": "image_url",
              "image_url": {"url": base64Image}
            });
          }
        }
      }
    }

    return {"role": role, "content": contentParts};
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }
}
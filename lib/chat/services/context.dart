// lib/chat/services/context.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/service.dart';

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
  })  : _sessionProvider = sessionProvider,
        _conversationProvider = conversationProvider,
        _modelService = modelService;

  /// Builds the list of messages for the API context.
  ///
  /// This method formats all relevant messages into the multimodal array format
  /// that the API expects. It reads the system role from the `ChatSessionProvider`
  /// and the message history from the `ConversationProvider`.
  ///
  /// [targetModelId]: The ID of the model the message will be sent to. This is used
  ///                  to determine if image data should be included.
  /// [includeLastUser]: If `false`, the very last user message in the history
  ///                    will be excluded. This is used for regeneration scenarios.
  Future<List<Map<String, dynamic>>> buildContextMessages({
    bool includeLastUser = true,
    required String targetModelId,
    required String langCode,
  }) async {
    final List<Map<String, dynamic>> contextMessages = [];

    // Read the system role from the session provider.
    final String? systemRole = _sessionProvider.role;

    // Read the message list from the conversation provider and filter for valid context.
    List<Message> history = _conversationProvider.messages
        .where((m) => m.includeInContext && !m.isThinking && !m.isError)
        .toList();

    final bool targetModelSupportsImages = _modelService.hasModality(targetModelId, langCode: langCode, modality: 'image');

    // Add the system prompt to the context, if it exists.
    if (systemRole != null && systemRole.isNotEmpty) {
      contextMessages.add({"role": "system", "content": systemRole});
    }

    // If we're regenerating a response, exclude the last user message
    // because it will be added again by the SendService.
    if (!includeLastUser && history.isNotEmpty) {
      final int lastUserMessageIndex = history.lastIndexWhere((m) => m.isUserMessage);
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

    // As a final safety check, filter out any potential empty messages that might have been created.
    return contextMessages.where((m) {
      final content = m['content'];
      if (content is String) return content.isNotEmpty;
      if (content is List) return content.isNotEmpty;
      return false;
    }).toList();
  }

  /// Helper function to convert a single `Message` object to the required
  /// multimodal JSON format (`"content": [ ... ]`).
  ///
  /// This is a pure utility function that transforms data without side effects.
  Future<Map<String, dynamic>> _formatMessageToJson(
      Message message, {
        required bool includeImage,
      }) async {
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> contentParts = [];

    // Add the text part of the message if it's not empty.
    if (message.text.isNotEmpty) {
      contentParts.add({"type": "text", "text": message.text});
    }

    // Conditionally add the image part.
    // This is done only if the target model supports images AND the message has a photo.
    if (includeImage && message.photoPath?.isNotEmpty == true) {
      final String? base64Image = await Utils.formatBase64Image(message.photoPath!);
      if (base64Image != null) {
        contentParts.add({
          "type": "image_url",
          "image_url": {"url": base64Image}
        });
      }
    }

    // The API always expects the content to be a list, even for text-only messages.
    return {"role": role, "content": contentParts};
  }
}
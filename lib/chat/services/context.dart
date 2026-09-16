// lib/chat/services/context.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/chat/services/compression.dart';
import 'package:cortex/chat/services/metrics.dart';
import 'package:cortex/chat/services/pii_filter.dart';
import 'package:cortex/chat/services/flow.dart';

/// Service responsible for building the list of messages in the format
/// required by the backend API. It reads the current state from the relevant providers.
class ContextService {
  static final RegExp _toolWidgetMarker = RegExp(
    r'<<<WIDGET:[\s\S]*?<<<END>>>',
    caseSensitive: false,
  );
  final ConversationProvider _conversationProvider;
  final ModelService _modelService;

  ContextService({
    required this._conversationProvider,
    required this._modelService,
  });

  /// Builds the list of messages for the API context.
  Future<List<Map<String, dynamic>>> buildContextMessages({
    bool includeLastUser = true,
    required String targetModelId,
    required String langCode,
    bool isCharacterModel = false,
    bool preserveFlowHistory = false,
  }) async {
    final List<Map<String, dynamic>> contextMessages = [];

    // Read the message list from the conversation provider and filter for valid context.
    // We specifically exclude messages that are not visible to the user (e.g., pre-input prompts).
    List<Message> history = _conversationProvider.messages
        .where(
          (m) =>
              m.includeInContext && !m.isThinking && !m.isError && m.isVisible,
        )
        .toList();

    final bool isLowEnd = _isLowEndModel(targetModelId);

    final bool shouldIncludeAllMedia =
        targetModelId == 'cortex/auto' || targetModelId == 'dynamic';
    final bool targetModelSupportsImages =
        shouldIncludeAllMedia ||
        _modelService.hasModality(
          targetModelId,
          langCode: langCode,
          modality: 'image',
        );

    // If we're regenerating a response, exclude the last user message
    // because it will be added again by the SendService.
    if (!includeLastUser && history.isNotEmpty) {
      final int lastUserMessageIndex = history.lastIndexWhere(
        (m) => m.isUserMessage,
      );
      if (lastUserMessageIndex != -1) {
        history = history.sublist(0, lastUserMessageIndex);
      }
    }

    // Loop through the filtered history and format each message into the API's required JSON structure.
    for (final message in history) {
      contextMessages.addAll(
        await _formatMessagesToJson(
          message,
          includeImage: targetModelSupportsImages,
          includeAllMedia: shouldIncludeAllMedia,
        ),
      );
    }

    int totalContentLength(List<Map<String, dynamic>> msgs) {
      int len = 0;
      for (final m in msgs) {
        final c = m['content'];
        if (c is String) len += c.length + 1;
      }
      return len;
    }

    final int originalLength = totalContentLength(contextMessages);
    final int keepCount = preserveFlowHistory
        ? 16
        : (isLowEnd ? 4 : (isCharacterModel ? 6 : 5));
    final compressedMessages = PromptCompressionEngine.compressContextMessages(
      contextMessages,
      keepUncompressedCount: keepCount,
    );
    final int compressedLength = totalContentLength(compressedMessages);

    MetricsTracker().startTracking(
      targetModelId,
      originalPromptLength: originalLength,
      compressedPromptLength: compressedLength,
    );

    // Safety check: Filter out empty messages
    return compressedMessages.where((m) {
      final content = m['content'];
      if (content is String) return content.isNotEmpty;
      if (content is List) return content.isNotEmpty;
      return false;
    }).toList();
  }

  /// Helper function to convert a single `Message` object to the required
  /// multimodal JSON format. If the assistant generated an image, we split it
  /// into a separate synthetic user message so the vision API accepts it.
  Future<List<Map<String, dynamic>>> _formatMessagesToJson(
    Message message, {
    required bool includeImage,
    required bool includeAllMedia,
  }) async {
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> textParts = [];
    List<Map<String, dynamic>> mediaParts = [];

    // 1. Text Content. `message.model` is UI/storage metadata, not dialogue.
    // Prefixing it into assistant text causes cross-model identity contamination
    // when the user switches from e.g. Cortex to Llama or Claude.
    if (message.text.isNotEmpty) {
      final String processedText = message.isUserMessage
          ? LocalPiiRedactionFilter.redact(message.text)
          : message.text;
      final cleanedAssistantText = processedText
          .replaceAll(_toolWidgetMarker, '')
          .trim();
      final participant = FlowParticipantMetadata.fromKey(
        message.flowParticipant,
      );
      final contextText = message.isUserMessage
          ? processedText
          : participant == null
          ? cleanedAssistantText
          : '[${participant.displayName} participant]\n$cleanedAssistantText';
      if (contextText.isNotEmpty) {
        textParts.add({"type": "text", "text": contextText});
      }
    }

    // Preserve the same media type and MIME detection used on the first turn.
    // Missing or unsupported visual evidence must not disappear silently.
    if (message.hasAttachments) {
      for (final path in message.attachmentPaths) {
        final kind = await Utils.mediaKind(path);
        if (kind == null) continue;
        final allowed = includeImage && (kind == 'image' || includeAllMedia);
        final block = allowed ? await Utils.processAttachment(path) : null;
        if (block != null) {
          mediaParts.add(block);
        } else {
          textParts.add({
            'type': 'text',
            'text':
                '[A $kind attachment from this turn is unavailable to you. '
                'Do not infer its contents or claim to have inspected it. '
                'If needed, ask the user to attach it again or use a compatible model.]',
          });
        }
      }
    }

    List<Map<String, dynamic>> results = [];

    if (role == "user") {
      if (mediaParts.isEmpty) {
        results.add({
          "role": "user",
          "content": textParts.isNotEmpty
              ? textParts.map((part) => part['text']).join('\n')
              : " ",
        });
      } else {
        results.add({
          "role": "user",
          "content": [...textParts, ...mediaParts],
        });
      }
    } else {
      if (textParts.isNotEmpty || mediaParts.isEmpty) {
        results.add({
          "role": "assistant",
          "content": textParts.isNotEmpty
              ? textParts.map((part) => part['text']).join('\n')
              : " ",
        });
      }

      if (mediaParts.isNotEmpty) {
        const String noteText =
            "[System Note: Below is the media generated previously, you may reference or edit it.]";
        mediaParts.insert(0, {"type": "text", "text": noteText});
        results.add({"role": "user", "content": mediaParts});
      }
    }

    return results;
  }

  bool _isLowEndModel(String modelId) {
    final lowerId = modelId.toLowerCase();
    return lowerId.contains('mini') ||
        lowerId.contains('haiku') ||
        lowerId.contains('flash') ||
        lowerId.contains('tiny') ||
        lowerId.contains('phi-2') ||
        lowerId.contains('qwen2-0') ||
        lowerId.contains('qwen2-1');
  }
}

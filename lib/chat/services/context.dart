// lib/chat/services/context.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/services/memory_store.dart';
import 'package:cortex/chat/services/compression.dart';
import 'package:cortex/chat/services/metrics.dart';
import 'package:cortex/chat/services/pii_filter.dart';

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
  })  : _sessionProvider = sessionProvider,
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

    String? systemRole = _sessionProvider.role;
    String? runtimeIdentityDirective;

    final String fallbackRole =
        localizations?.systemRoleFallback ?? "You are a helpful assistant.";

    if (localizations != null) {
      systemRole = (systemRole ?? fallbackRole) +
          localizations.systemLanguageInstruction;
    }

    if (localizations != null && !isCharacterModel) {
      final now = DateTime.now();
      final formattedTime = DateFormat.yMMMd(langCode).add_Hm().format(now);
      systemRole = (systemRole ?? fallbackRole) +
          localizations.systemTimeInfo(formattedTime);
    }

    if (isServerSide && userMemory != null && userMemory.trim().isNotEmpty) {
      final memoryPrompt = "\n\n[User Memory]\n$userMemory";
      systemRole = (systemRole ?? fallbackRole) + memoryPrompt;
    }

    if (customInstruction != null &&
        customInstruction.trim().isNotEmpty &&
        localizations != null) {
      final instructionPrompt =
          "\n\n${localizations.intelligenceSystemPrompt(customInstruction.trim())}";
      systemRole = (systemRole ?? fallbackRole) + instructionPrompt;
    }

    if (!isCharacterModel) {
      const toneDirective =
          "\n\nBe natural, conversational and direct. Avoid poetic or dramatic language unless asked.";
      systemRole = (systemRole ?? fallbackRole) + toneDirective;
    }

    // Model IDs stored on assistant messages are presentation/storage metadata.
    // Keep the model's runtime identity out of conversation history and define it
    // once from the actual model selected for this request.
    if (!isCharacterModel) {
      final isDynamicIdentity = _sessionProvider.isDynamicChat ||
          targetModelId == 'cortex/auto' ||
          targetModelId == 'dynamic';

      if (isDynamicIdentity) {
        runtimeIdentityDirective =
            "[Runtime identity]\nYou are Cortex Dynamic Chat. The underlying provider may be selected automatically per request. If the user asks which model you are, identify yourself as Cortex Dynamic Chat and do not invent or claim a specific OpenAI, Anthropic, Meta, Google, or other provider model.";
      } else {
        final targetModel =
            _modelService.getPreciseModelData(targetModelId, langCode: langCode);
        final title = targetModel.displayTitle.trim();
        final producer = targetModel.producer.trim();
        final identity = producer.isNotEmpty &&
                producer.toLowerCase() != 'unknown' &&
                !title.toLowerCase().startsWith(producer.toLowerCase())
            ? '$producer $title'
            : title;
        runtimeIdentityDirective =
            "[Runtime identity]\nYou are currently running as ${identity.isEmpty ? targetModel.id : identity} (model id: ${targetModel.id}). If the user asks which model you are, use this runtime identity. Never claim to be a different model or provider based on training data, prior assistant messages, or guesses.";
      }
    }

    if (enableThinkingMode && localizations != null) {
      final thinkingInstruction =
          "\n\n${localizations.thinkingModeInstruction}";
      systemRole = (systemRole ?? fallbackRole) + thinkingInstruction;
    }

    List<Message> history = _conversationProvider.messages
        .where((m) =>
            m.includeInContext && !m.isThinking && !m.isError && m.isVisible)
        .toList();

    int userMessageCount = history.where((m) => m.isUserMessage).length;

    final bool isLowEnd = _isLowEndModel(targetModelId);

    if (isServerSide && !isCharacterModel && userMessageCount >= 3) {
      final extractionInstruction = localizations != null
          ? localizations.systemMemoryDirective
          : "\n\nIf you learned new facts about the user, output them inside <memory>...</memory> at the end. If nothing new, omit.";
      systemRole = (systemRole ?? fallbackRole) + extractionInstruction;
    }

    String? lastUserText;
    if (history.isNotEmpty) {
      final lastUserMsg =
          history.lastWhere((m) => m.isUserMessage, orElse: () => history.last);
      lastUserText = lastUserMsg.text;
    }
    if (lastUserText != null && lastUserText.trim().isNotEmpty) {
      final semanticMemService = SemanticMemoryService();
      final relevantMemories =
          await semanticMemService.queryRelevantMemories(lastUserText);
      if (relevantMemories.isNotEmpty) {
        final limitedMemories =
            relevantMemories.take(isLowEnd ? 1 : 3).toList();
        final memoryLines =
            limitedMemories.map((m) => "- ${m['content']}").join("\n");
        final String semanticMemoryPrompt = "\n\n[Past context]\n$memoryLines";
        systemRole = (systemRole ?? fallbackRole) + semanticMemoryPrompt;
      }
    }

    final bool shouldIncludeAllMedia =
        targetModelId == 'cortex/auto' || targetModelId == 'dynamic';
    final bool targetModelSupportsImages = shouldIncludeAllMedia ||
        _modelService.hasModality(
          targetModelId,
          langCode: langCode,
          modality: 'image',
        );

    const int systemBudget = 2500;
    if (runtimeIdentityDirective != null) {
      final reserved = runtimeIdentityDirective.length + 2;
      final int baseBudget =
          systemBudget > reserved ? systemBudget - reserved : 0;
      final base = systemRole ?? fallbackRole;
      systemRole = base.length > baseBudget
          ? base.substring(0, baseBudget)
          : base;
      systemRole = '$systemRole\n\n$runtimeIdentityDirective';
    }
    if (systemRole != null && systemRole.length > systemBudget) {
      systemRole = systemRole.substring(0, systemBudget);
    }

    if (systemRole != null && systemRole.isNotEmpty) {
      contextMessages.add({"role": "system", "content": systemRole});
    }

    if (!includeLastUser && history.isNotEmpty) {
      final int lastUserMessageIndex =
          history.lastIndexWhere((m) => m.isUserMessage);
      if (lastUserMessageIndex != -1) {
        history = history.sublist(0, lastUserMessageIndex);
      }
    }

    for (final message in history) {
      contextMessages.addAll(await _formatMessagesToJson(
        message,
        includeImage: targetModelSupportsImages,
        includeAllMedia: shouldIncludeAllMedia,
        localizations: localizations,
      ));
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
    final int keepCount = isLowEnd ? 4 : (isCharacterModel ? 6 : 5);
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

    final result = compressedMessages.where((m) {
      final content = m['content'];
      if (content is String) return content.isNotEmpty;
      if (content is List) return content.isNotEmpty;
      return false;
    }).toList();

    // OfflineService intentionally converts only user/assistant history turns
    // into the native llama prompt. Carry the runtime identity as the final
    // offline context instruction so local models cannot self-identify from
    // their training data instead of the model Cortex actually loaded.
    if (!isServerSide && runtimeIdentityDirective != null) {
      result.add({
        "role": "user",
        "content": runtimeIdentityDirective,
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> _formatMessagesToJson(Message message,
      {required bool includeImage,
      required bool includeAllMedia,
      AppLocalizations? localizations}) async {
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> textParts = [];
    List<Map<String, dynamic>> mediaParts = [];

    // `message.model` is UI/storage metadata, not dialogue. Prefixing it into
    // assistant content contaminates the next model after a model switch.
    if (message.text.isNotEmpty) {
      final String processedText = message.isUserMessage
          ? LocalPiiRedactionFilter.redact(message.text)
          : message.text;
      textParts.add({"type": "text", "text": processedText});
    }

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
      if (mediaParts.isEmpty) {
        results.add({
          "role": "user",
          "content": textParts.isNotEmpty ? textParts.first["text"] : " "
        });
      } else {
        results.add({
          "role": "user",
          "content": [...textParts, ...mediaParts]
        });
      }
    } else {
      if (textParts.isNotEmpty || mediaParts.isEmpty) {
        results.add({
          "role": "assistant",
          "content": textParts.isNotEmpty ? textParts.first["text"] : " "
        });
      }

      if (mediaParts.isNotEmpty) {
        final noteText = localizations?.systemNotePreviousMedia ??
            "[System Note: Below is the media generated previously, you may reference or edit it.]";
        mediaParts.insert(0, {"type": "text", "text": noteText});
        results.add({"role": "user", "content": mediaParts});
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

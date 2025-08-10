// context.dart

import 'package:cortex/models/backend/data.dart';
import 'package:cortex/chat/chat.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'api.dart';

class ContextService {
  final ChatScreenState state;

  ContextService(this.state);

  /// --- THE NEW, CORRECTED IMPLEMENTATION ---
  /// Builds the list of messages for the API context. This method now considers the
  /// target model's capabilities and, most importantly, formats the system prompt
  /// according to the correct API standard (as a simple string).
  ///
  /// [targetModelId]: The ID of the model the message will be sent to.
  /// [includeLastUser]: Whether to include the very last user message in the context.
  Future<List<Map<String, dynamic>>> buildContextMessages({
    bool includeLastUser = true,
    required String targetModelId,
  }) async {
    final List<Map<String, dynamic>> contextMessages = [];
    final String? systemRole = state.role;

    final modelData = ModelData.getPreciseModelData(targetModelId);
    final bool targetModelSupportsImages = modelData['vision'] ?? false;

    // --- THE FIX: Add the system prompt, if it exists, in the CORRECT format. ---
    // The content of a system message must be a plain string.
    if (systemRole != null && systemRole.isNotEmpty) {
      contextMessages.add({"role": "system", "content": systemRole});
    }

    final List<Message> history = state.messages
        .where((m) => m.includeInContext && !m.isThinking && !m.isError)
        .toList();

    if (!includeLastUser && history.isNotEmpty && history.last.isUserMessage) {
      history.removeLast();
    }

    for (final message in history) {
      contextMessages.add(await _formatMessageToJson(
        message,
        includeImage: targetModelSupportsImages,
      ));
    }

    // Filter out any potential empty messages, although this is less likely now.
    // The check below is robust for both string and list content types.
    return contextMessages.where((m) {
      final content = m['content'];
      if (content is String) return content.isNotEmpty;
      if (content is List) return content.isNotEmpty;
      return false;
    }).toList();
  }

  /// Helper function to convert a Message object to the required JSON format.
  /// It now conditionally includes image data based on the `includeImage` flag.
  Future<Map<String, dynamic>> _formatMessageToJson(
      Message message, {
        required bool includeImage,
      }) async {
    // This function only handles 'user' and 'assistant' roles. System role is handled above.
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> contentParts = [];

    if (message.text.isNotEmpty) {
      contentParts.add({"type": "text", "text": message.text});
    }

    if (includeImage && message.photoPath?.isNotEmpty == true) {
      final String? base64Image = await ApiService.formatBase64Image(message.photoPath!);
      if (base64Image != null) {
        contentParts.add({
          "type": "image_url",
          "image_url": {"url": base64Image}
        });
      }
    }

    return {"role": role, "content": contentParts};
  }
}
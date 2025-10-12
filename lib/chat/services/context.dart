// context.dart

import 'package:cortex/models/backend/data.dart';
import 'package:cortex/chat/chat.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'api.dart';

class ContextService {
  final ChatScreenState state;

  ContextService(this.state);

  /// Builds the list of messages for the API context. This method now formats
  /// ALL messages (historical and current) into a consistent, modern,
  /// multimodal array format that the API expects. This solves the "amnesia"
  /// bug where the API would ignore historical context due to format mismatch.
  ///
  /// [targetModelId]: The ID of the model the message will be sent to.
  /// [includeLastUser]: Whether to include the very last user message in the context.
  Future<List<Map<String, dynamic>>> buildContextMessages({
    bool includeLastUser = true,
    required String targetModelId,
  }) async {
    final List<Map<String, dynamic>> contextMessages = [];
    final String? systemRole = state.role;

    // --- IMPROVEMENT: Use the correct method to check for image capability ---
    // Instead of a non-existent 'vision' flag, we use the reliable central method.
    final bool targetModelSupportsImages = ModelData.hasModality(targetModelId, 'image');

    // Add the system prompt, if it exists, in the correct plain string format.
    if (systemRole != null && systemRole.isNotEmpty) {
      contextMessages.add({"role": "system", "content": systemRole});
    }

    // Filter messages from the UI state to get the conversation history.
    final List<Message> history = state.messages
        .where((m) => m.includeInContext && !m.isThinking && !m.isError)
        .toList();

    // If we're regenerating a response, we don't include the last user message
    // because it will be added again by the ApiService.
    if (!includeLastUser && history.isNotEmpty && history.last.isUserMessage) {
      history.removeLast();
    }

    // --- THE CORE FIX: Loop through history and format EACH message correctly ---
    for (final message in history) {
      contextMessages.add(await _formatMessageToJson(
        message,
        includeImage: targetModelSupportsImages,
      ));
    }

    // Filter out any potential empty messages.
    return contextMessages.where((m) {
      final content = m['content'];
      if (content is String) return content.isNotEmpty;
      if (content is List) return content.isNotEmpty;
      return false;
    }).toList();
  }

  /// Helper function to convert a single `Message` object to the required
  /// multimodal JSON format (`"content": [ ... ]`). This is now the single
  /// source of truth for message formatting in the context.
  Future<Map<String, dynamic>> _formatMessageToJson(
      Message message, {
        required bool includeImage,
      }) async {
    // This function only handles 'user' and 'assistant' roles.
    String role = message.isUserMessage ? "user" : "assistant";
    List<Map<String, dynamic>> contentParts = [];

    // Add the text part if it exists.
    if (message.text.isNotEmpty) {
      contentParts.add({"type": "text", "text": message.text});
    }

    // Conditionally add the image part if the target model supports it.
    if (includeImage && message.photoPath?.isNotEmpty == true) {
      final String? base64Image = await ApiService.formatBase64Image(message.photoPath!);
      if (base64Image != null) {
        contentParts.add({
          "type": "image_url",
          "image_url": {"url": base64Image}
        });
      }
    }

    // Always return the content as a list, even if it only has one part.
    // This ensures consistency across the entire payload.
    return {"role": role, "content": contentParts};
  }
}
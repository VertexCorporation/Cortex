class PromptCompressionEngine {
  // Common conversational fillers in English/Turkish that don't add semantic value to history
  static const List<String> _fillers = [
    'nasılsın',
    'nasıl yardımcı olabilirim',
    'tabii ki',
    'tabii',
    'anlaşıldı',
    'anlıyorum',
    'size nasıl yardımcı olabilirim',
    'how can i help you today',
    'how can i help you',
    'you are welcome',
    'bir şey değil',
    'rica ederim',
    'merhaba',
    'selam',
    'hey there',
    'hello',
  ];

  /// Compresses a message's text by stripping out excess whitespace, 
  /// linebreaks, and unnecessary conversational filler words, while keeping the core semantic content.
  static String compressText(String text, {bool isSystem = false}) {
    if (text.isEmpty) return text;

    // 1. Normalize whitespaces and linebreaks
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 2. For non-system messages, we can filter out common repetitive fillers at the start/end of the message
    if (!isSystem) {
      final lower = cleaned.toLowerCase();
      for (final filler in _fillers) {
        if (lower.startsWith(filler)) {
          // Remove filler from beginning if followed by punctuation or space
          final len = filler.length;
          if (cleaned.length > len) {
            final nextChar = cleaned[len];
            if (nextChar == ',' || nextChar == '.' || nextChar == '!' || nextChar == ' ') {
              cleaned = cleaned.substring(len).trim();
              if (cleaned.startsWith(',') || cleaned.startsWith('.') || cleaned.startsWith('!')) {
                cleaned = cleaned.substring(1).trim();
              }
            }
          }
        }
      }
    }

    return cleaned;
  }

  /// Compresses the older message history (excluding the last few messages).
  /// This yields significant token savings while retaining prompt context quality.
  /// Compresses the older message history (excluding the last few messages).
  /// This yields significant token savings while retaining prompt context quality.
  /// Handles both String and `List<Map<String, dynamic>>` content structures.
  static List<Map<String, dynamic>> compressContextMessages(
    List<Map<String, dynamic>> messages, {
    required int keepUncompressedCount,
  }) {
    if (messages.length <= keepUncompressedCount) return messages;

    final List<Map<String, dynamic>> compressed = [];
    final int compressThreshold = messages.length - keepUncompressedCount;

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final role = msg['role'] as String?;
      final dynamic rawContent = msg['content'];

      if (rawContent != null && role != null) {
        if (i < compressThreshold && role != 'system') {
          // Compress old message
          if (rawContent is String) {
            final compressedContent = compressText(rawContent, isSystem: false);
            compressed.add({
              ...msg,
              'content': compressedContent,
            });
          } else if (rawContent is List) {
            final List<Map<String, dynamic>> updatedContent = [];
            for (final item in rawContent) {
              if (item is Map && item['type'] == 'text' && item['text'] is String) {
                updatedContent.add({
                  ...Map<String, dynamic>.from(item),
                  'text': compressText(item['text'] as String, isSystem: false),
                });
              } else if (item is Map) {
                updatedContent.add(Map<String, dynamic>.from(item));
              }
            }
            compressed.add({
              ...msg,
              'content': updatedContent,
            });
          } else {
            compressed.add(msg);
          }
        } else {
          // Keep system and recent messages uncompressed
          compressed.add(msg);
        }
      } else {
        compressed.add(msg);
      }
    }

    return compressed;
  }
}

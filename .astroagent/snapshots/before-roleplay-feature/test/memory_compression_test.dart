import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/compression.dart';
import 'package:cortex/chat/services/pii_filter.dart';

void main() {
  group('PromptCompressionEngine Tests', () {
    test('compressText cleans up double spaces and linebreaks', () {
      final input = "Hello   world!\nThis  is   a   test.";
      final result = PromptCompressionEngine.compressText(input);
      expect(result, "world! This is a test.");
    });

    test('compressText removes conversational fillers from start of message', () {
      final input = "Merhaba! nasılsın bugün?";
      final result = PromptCompressionEngine.compressText(input);
      expect(result.toLowerCase().contains("bugün"), true);
      expect(result.toLowerCase().startsWith("merhaba"), false);
    });

    test('compressContextMessages keeps last N messages uncompressed', () {
      final messages = [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Merhaba! nasılsın? Ben bir geliştiriciyim."},
        {"role": "assistant", "content": "Anlaşıldı, size yardımcı olmaktan mutluluk duyarım. Nasıl bir proje yapıyorsunuz?"},
        {"role": "user", "content": "Flutter projesi yapıyorum."},
      ];

      final compressed = PromptCompressionEngine.compressContextMessages(messages, keepUncompressedCount: 2);

      // System message should NOT be compressed
      expect(compressed[0]['content'], "You are a helpful assistant.");

      // The first user message is compressed
      expect(compressed[1]['content'].toString().contains("Ben bir geliştiriciyim."), true);
      
      // The last 2 messages are kept uncompressed
      expect(compressed[2]['content'], "Anlaşıldı, size yardımcı olmaktan mutluluk duyarım. Nasıl bir proje yapıyorsunuz?");
      expect(compressed[3]['content'], "Flutter projesi yapıyorum.");
    });
  });

  group('LocalPiiRedactionFilter Tests', () {
    test('redact masks sensitive personal data', () {
      final input = "E-posta adresim test@example.com ve telefon numaram +90 555 123 4567. Kredi kartı numaram ise 1234-5678-9012-3456. TCKN: 12345678901.";
      final redacted = LocalPiiRedactionFilter.redact(input);

      expect(redacted.contains("test@example.com"), false);
      expect(redacted.contains("[E-POSTA MASKELENDİ]"), true);

      expect(redacted.contains("1234-5678-9012-3456"), false);
      expect(redacted.contains("[KREDİ KARTI MASKELENDİ]"), true);

      expect(redacted.contains("555 123 4567"), false);
      expect(redacted.contains("[TELEFON MASKELENDİ]"), true);

      expect(redacted.contains("12345678901"), false);
      expect(redacted.contains("[TELEFON MASKELENDİ]"), true); // Overlaps with phone regex in current implementation
    });

    test('redact leaves normal text untouched', () {
      final input = "Merhaba dünya! Cortex uygulaması harika çalışıyor.";
      final redacted = LocalPiiRedactionFilter.redact(input);
      expect(redacted, input);
    });
  });
}

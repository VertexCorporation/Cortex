import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Title Limit Logic', () {
    String generateTitle(String text) {
      if (text.isEmpty) return "📁";
      // This matches logic in send.dart
      return (text.length > 32 ? text.substring(0, 32) : text);
    }

    test('Short title logic', () {
      expect(generateTitle("Short"), "Short");
    });

    test('Empty title logic', () {
      expect(generateTitle(""), "📁");
    });

    test('Exact 32 chars logic', () {
      final text = "12345678901234567890123456789012"; // 32 chars
      expect(text.length, 32);
      expect(generateTitle(text), text);
    });

    test('Over 32 chars logic', () {
      final text = "123456789012345678901234567890123"; // 33 chars
      expect(text.length, 33);

      final expected = "12345678901234567890123456789012";
      expect(generateTitle(text), expected);
      expect(generateTitle(text).length, 32);
    });
  });
}

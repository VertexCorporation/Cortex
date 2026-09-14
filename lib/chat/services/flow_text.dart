/// Presentation-only removal of a leading Flow speaker label. Raw messages
/// remain available for persistence and shared conversation context.
class FlowText {
  static final _marker = RegExp(
    r'^\s*(?:\[\s*(?:blue|red|green|yellow)\s+participant\s*:?[\s]*\]|(?:blue|red|green|yellow)\s+participant\b)\s*:?\s*',
    caseSensitive: false,
  );

  static String sanitize(String text, {bool streaming = false}) {
    final match = _marker.firstMatch(text);
    if (match != null) return text.substring(match.end);
    if (streaming) {
      final prefix = text.trimLeft().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      for (final color in ['blue', 'red', 'green', 'yellow']) {
        for (final expected in [
          '[$color participant]',
          '[$color participant:]',
          '$color participant:',
        ]) {
          if (expected.replaceAll(' ', '').startsWith(prefix)) return '';
        }
      }
    }
    return text;
  }
}

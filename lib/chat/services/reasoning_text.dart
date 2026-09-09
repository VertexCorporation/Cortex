/// Splits model-provided thinking from the answer without changing stored text.
/// Literal tags inside Markdown code are preserved. Spans retain raw offsets so
/// hiding reasoning does not consume the answer's animation range.
class ReasoningText {
  final String answer;
  final String reasoning;
  final bool hasReasoning;
  final bool isReasoningOpen;
  final List<(int, int)> _answerSpans;

  ReasoningText._(this.answer, this.reasoning, this.hasReasoning,
      this.isReasoningOpen, this._answerSpans);

  static final _markers = RegExp(r'`+|~{3,}|<think>|</think>', caseSensitive: false);

  factory ReasoningText.parse(String text, {bool isFinished = true}) {
    final answer = StringBuffer();
    final reasoning = StringBuffer();
    final spans = <(int, int)>[];
    var depth = 0;
    var codeWidth = 0;
    var codeCharacter = '';
    var cursor = 0;
    var hasReasoning = false;

    void append(int start, int end) {
      if (start >= end) return;
      if (depth > 0) {
        reasoning.write(text.substring(start, end));
      } else {
        answer.write(text.substring(start, end));
        spans.add((start, end));
      }
    }

    for (final match in _markers.allMatches(text)) {
      append(cursor, match.start);
      final marker = match.group(0)!;
      if (_isEscaped(text, match.start)) {
        append(match.start, match.end);
      } else if (marker.startsWith('`') || marker.startsWith('~')) {
        append(match.start, match.end);
        if (codeWidth == 0) {
          codeWidth = marker.length;
          codeCharacter = marker[0];
        } else if (codeCharacter == marker[0] &&
            (codeWidth == marker.length || (codeWidth >= 3 && marker.length > codeWidth))) {
          codeWidth = 0;
        }
      } else if (codeWidth != 0) {
        append(match.start, match.end);
      } else if (marker.toLowerCase() == '<think>') {
        if (depth == 0 && reasoning.isNotEmpty) reasoning.write('\n\n');
        depth++;
        hasReasoning = true;
      } else if (depth > 0) {
        depth--;
      } else {
        // An unmatched closing tag could be literal text; do not invent a
        // preceding reasoning block or discard the answer before it.
        append(match.start, match.end);
      }
      cursor = match.end;
    }

    var end = text.length;
    if (!isFinished && codeWidth == 0) {
      // Don't flash a partial control marker while its next chunk is pending.
      final start = text.lastIndexOf('<');
      if (start >= cursor) {
        final tail = text.substring(start).toLowerCase();
        if ('<think>'.startsWith(tail) || '</think>'.startsWith(tail)) end = start;
      }
    }
    append(cursor, end);
    return ReasoningText._(answer.toString(), reasoning.toString(),
        hasReasoning, depth > 0, spans);
  }

  int answerLengthBefore(int rawOffset) {
    var length = 0;
    for (final span in _answerSpans) {
      if (rawOffset <= span.$1) break;
      length += (rawOffset < span.$2 ? rawOffset : span.$2) - span.$1;
    }
    return length;
  }

  static bool _isEscaped(String text, int offset) {
    var count = 0;
    for (var i = offset - 1; i >= 0 && text.codeUnitAt(i) == 92; i--) {
      count++;
    }
    return count.isOdd;
  }
}

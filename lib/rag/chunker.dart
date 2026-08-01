// lib/rag/chunker.dart
//
// Splits extracted document text into overlapping, boundary-aware chunks
// that fit inside the model context window.

class DocumentChunker {
  /// Target chunk size in characters (roughly ~225 tokens for English).
  static const int defaultChunkSize = 900;

  /// Overlap ratio between consecutive chunks to preserve context across
  /// split boundaries.
  static const double defaultOverlapRatio = 0.15;

  final int chunkSize;
  final double overlapRatio;

  const DocumentChunker({
    this.chunkSize = defaultChunkSize,
    this.overlapRatio = defaultOverlapRatio,
  });

  /// Splits [text] into a list of chunks. Chunks are trimmed and empty
  /// chunks are dropped. Returns `[]` when [text] is empty.
  List<String> chunk(String text) {
    if (text.trim().isEmpty) return const [];

    // Normalize line endings.
    final normalized = text.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const [];

    final overlapChars = (chunkSize * overlapRatio).round();

    // Prefer paragraph boundaries, then sentence/line boundaries, and
    // finally fall back to hard char slicing.
    final paragraphs = _splitParagraphs(normalized);
    final List<String> result = [];
    final StringBuffer current = StringBuffer();

    void flush() {
      final value = current.toString().trim();
      if (value.isNotEmpty) result.add(value);
      current.clear();
    }

    for (final para in paragraphs) {
      if (current.length + para.length + 1 > chunkSize) {
        flush();
      }
      if (current.length > 0) {
        current.write('\n\n');
      }
      current.write(para);

      // A single paragraph can exceed the chunk size; hard-slice it.
      while (current.length >= chunkSize) {
        final slice = _splitLongText(
          current.toString(),
          chunkSize,
          overlapChars,
        );
        if (slice.text.trim().isNotEmpty) result.add(slice.text.trim());
        current.clear();
        current.write(slice.remainder);
      }
    }
    flush();

    return result;
  }

  /// Splits [text] into paragraph groups.
  List<String> _splitParagraphs(String text) {
    final result = <String>[];
    for (final part in text.split(RegExp(r'\n\s*\n'))) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      result.add(trimmed);
    }
    return result;
  }

  /// Slices [text] into a head chunk (up to [chunkSize]) keeping [overlap]
  /// trailing characters and returns the remainder for further slicing.
  _SliceResult _splitLongText(String text, int size, int overlap) {
    if (text.length <= size) return _SliceResult(text, '');

    int cut = size;
    final window = text.substring(0, size);

    // Prefer a newline boundary in the second half of the window.
    final lastNewline = window.lastIndexOf('\n');
    if (lastNewline >= size ~/ 2) {
      cut = lastNewline;
    } else {
      // Otherwise try a sentence boundary.
      final sentenceMatches =
          RegExp(r'[.!?؟۔]\s').allMatches(window).map((m) => m.start).toList();
      if (sentenceMatches.isNotEmpty) {
        final lastSentence = sentenceMatches.last;
        if (lastSentence >= size ~/ 2) {
          cut = lastSentence + 1;
        }
      }
    }

    final head = text.substring(0, cut);
    final tailStart = (cut - overlap).clamp(0, text.length);
    return _SliceResult(head, text.substring(tailStart));
  }
}

class _SliceResult {
  final String text;
  final String remainder;

  const _SliceResult(this.text, this.remainder);
}

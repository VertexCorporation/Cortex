// lib/rag/offline_pdf_guard.dart
//
// Final deterministic guard applied after PDF retrieval. If the user names an
// explicit page or page range, evidence from other pages is removed before the
// prompt reaches a tiny local model.

class OfflinePdfPageGuard {
  const OfflinePdfPageGuard._();

  static String apply({
    required String queryText,
    required String context,
  }) {
    final requested = requestedPages(queryText);
    if (requested.isEmpty || context.isEmpty) return context;

    final lines = context.split('\n');
    final output = <String>[];
    var insideSource = false;
    var keepSource = false;
    var matchedSource = false;

    final sourceHeader = RegExp(
      r'^\[SOURCE .* \| PAGE (\d{1,4})(?: \||\])',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = sourceHeader.firstMatch(line);
      if (match != null) {
        insideSource = true;
        final page = int.tryParse(match.group(1) ?? '');
        keepSource = page != null && requested.contains(page);
        if (keepSource) {
          matchedSource = true;
          output.add(line);
        }
        continue;
      }

      if (line == '[/DOCUMENT_CONTEXT]') {
        insideSource = false;
        keepSource = false;
        output.add(line);
        continue;
      }

      // Preamble and status lines live before the first SOURCE block and are
      // always safe to keep. Evidence body is retained only for target pages.
      if (!insideSource || keepSource) output.add(line);
    }

    if (matchedSource) return output.join('\n');

    // The requested page may be outside the bounded local index. Do not fall
    // back to unrelated evidence; tell the model the requested source page is
    // unavailable so it can answer honestly.
    final pages = requested.toList()..sort();
    return '[DOCUMENT_CONTEXT]\n'
        '[STATUS] Requested PDF page(s) ${pages.join(', ')} were not available in the local index. Do not infer their contents.\n'
        '[/DOCUMENT_CONTEXT]';
  }

  static Set<int> requestedPages(String query) {
    final pages = <int>{};

    void add(String? raw) {
      final page = int.tryParse(raw ?? '');
      if (page != null && page > 0 && page <= 1500) pages.add(page);
    }

    final afterWord = RegExp(
      r'\b(?:sayfa|page)\s*(?:no\.?|number)?\s*[:#]?\s*(\d{1,4})\b',
      caseSensitive: false,
    );
    final beforeWord = RegExp(
      r'\b(\d{1,4})\.?\s*(?:sayfa|page)\b',
      caseSensitive: false,
    );
    final range = RegExp(
      r'\b(?:sayfa|page)\s*(\d{1,4})\s*[-–—]\s*(\d{1,4})\b',
      caseSensitive: false,
    );

    for (final match in afterWord.allMatches(query)) {
      add(match.group(1));
    }
    for (final match in beforeWord.allMatches(query)) {
      add(match.group(1));
    }
    for (final match in range.allMatches(query)) {
      final start = int.tryParse(match.group(1) ?? '');
      final end = int.tryParse(match.group(2) ?? '');
      if (start == null || end == null || start <= 0 || end < start) continue;
      final cappedEnd = end > start + 19 ? start + 19 : end;
      for (var page = start; page <= cappedEnd && page <= 1500; page++) {
        pages.add(page);
      }
    }

    return pages;
  }
}

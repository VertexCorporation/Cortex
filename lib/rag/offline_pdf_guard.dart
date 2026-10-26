// lib/rag/offline_pdf_guard.dart
//
// Final deterministic guard applied after PDF retrieval. If the user names an
// explicit page or page range, evidence from other pages is removed before the
// prompt reaches a tiny local model.

class OfflinePdfPageGuard {
  const OfflinePdfPageGuard._();

  // Turkish users naturally write forms such as "3. sayfada", "3. sayfayı",
  // "3. sayfanın" and "3. sayfası". Keep the accepted suffixes explicit so a
  // random word beginning with "sayfa" cannot accidentally become a page
  // selector.
  static const String _trPageWord =
      r'sayfa(?:da|de|dan|den|nın|nin|nun|nün|yı|yi|yu|yü|sı|si|su|sü)?';

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

  /// Normalizes explicit page intent for the retrieval engine without changing
  /// the user's real question. The current retriever recognizes canonical
  /// `page N` metadata selectors, so Turkish inflected forms are appended as
  /// canonical selectors. The final guard still receives the original query.
  static String normalizeForRetrieval(String query) {
    final pages = requestedPages(query).toList()..sort();
    if (pages.isEmpty) return query;
    final canonical = pages.map((page) => 'page $page').join(' ');
    return '$query $canonical';
  }

  static Set<int> requestedPages(String query) {
    final pages = <int>{};

    void add(String? raw) {
      final page = int.tryParse(raw ?? '');
      if (page != null && page > 0 && page <= 1500) pages.add(page);
    }

    final afterWord = RegExp(
      '\\b(?:$_trPageWord|page)\\s*(?:no\\.?|number)?\\s*[:#]?\\s*(\\d{1,4})\\b',
      caseSensitive: false,
      unicode: true,
    );
    final beforeWord = RegExp(
      '\\b(\\d{1,4})\\.?\\s*(?:$_trPageWord|page)(?![\\p{L}\\p{N}_])',
      caseSensitive: false,
      unicode: true,
    );
    final rangeAfterWord = RegExp(
      '\\b(?:$_trPageWord|page)\\s*(\\d{1,4})\\s*[-–—]\\s*(\\d{1,4})\\b',
      caseSensitive: false,
      unicode: true,
    );
    final rangeBeforeWord = RegExp(
      '\\b(\\d{1,4})\\s*[-–—]\\s*(\\d{1,4})\\.?\\s*(?:$_trPageWord|page)(?![\\p{L}\\p{N}_])',
      caseSensitive: false,
      unicode: true,
    );

    for (final match in afterWord.allMatches(query)) {
      add(match.group(1));
    }
    for (final match in beforeWord.allMatches(query)) {
      add(match.group(1));
    }

    void addRange(RegExpMatch match) {
      final start = int.tryParse(match.group(1) ?? '');
      final end = int.tryParse(match.group(2) ?? '');
      if (start == null || end == null || start <= 0 || end < start) return;
      // A page request is a precision operation. Bound a user-supplied range
      // so it can never turn into an accidental whole-document context dump.
      final cappedEnd = end > start + 19 ? start + 19 : end;
      for (var page = start; page <= cappedEnd && page <= 1500; page++) {
        pages.add(page);
      }
    }

    for (final match in rangeAfterWord.allMatches(query)) {
      addRange(match);
    }
    for (final match in rangeBeforeWord.allMatches(query)) {
      addRange(match);
    }

    return pages;
  }
}

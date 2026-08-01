// lib/rag/injector.dart
//
// Formats retrieved chunks into a compact context block that is prepended to
// the user message before it reaches the model.

import 'package:cortex/rag/models.dart';

class RagContextInjector {
  /// Hard cap on total retrieved characters injected into the prompt.
  static const int defaultCharBudget = 3500;

  final int charBudget;

  const RagContextInjector({this.charBudget = defaultCharBudget});

  /// Builds a single context string from [results], keeping the top results
  /// within [charBudget]. Empty when there is nothing relevant.
  String buildContext(
    List<RagRetrievalResult> results, {
    String? langCode,
  }) {
    if (results.isEmpty) return '';

    final sb = StringBuffer();
    var used = 0;

    for (final result in results) {
      if (used >= charBudget) break;

      final chunk = result.chunk.text.trim();
      if (chunk.isEmpty) continue;

      final header = '[Belge: ${result.document.title}]\n';
      final remaining = charBudget - used - header.length;
      final content = chunk.length > remaining
          ? '${chunk.substring(0, remaining > 0 ? remaining : 0)}…'
          : chunk;

      sb.write(header);
      sb.write('"');
      sb.write(content);
      sb.write('"\n\n');

      used += header.length + content.length + 3;
    }

    final context = sb.toString().trim();
    return context;
  }

  /// Wraps [context] with a short instruction so the model treats the quoted
  /// passages as reference material, not as a direct user statement.
  String buildSystemInstruction(String context, {String? langCode}) {
    if (context.isEmpty) return '';
    // Language-neutral instruction; the surrounding system prompt is already
    // localized by the caller.
    return '\n\n[Referans belgeler]\nYalnızca bu referanslardan bilgi al. '
        'Bilgi yoksa "belgelerde bu bilgi yok" de.\n$context';
  }
}

// overflow.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// A private utility function to sanitize a string by removing the Unicode
/// replacement character (U+FFFD), which often appears in malformed or
/// incomplete UTF-16 strings. This prevents crashes in the text rendering engine.
///
/// This function is used centrally within this widget to ensure all text processing
/// is safe.
String _sanitizeText(String text) {
  return text.replaceAll('\uFFFD', '');
}

/// A text widget that gracefully handles overflow by truncating the text and
/// applying a fade-out effect to the last few characters.
///
/// It is designed to be robust against rendering errors by internally sanitizing
/// input strings and correctly handling Unicode characters (runes), including emojis.
class OverflowText extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The style to use for the text. If null, the default style from the
  /// context will be used.
  final TextStyle? style;

  /// The maximum number of lines for the text to span.
  final int maxLines;

  /// The number of characters at the end of the text to apply the fade-out effect to.
  final int fadeLength;

  /// An optional animation to control the opacity of the fading part, useful for
  /// entrance/exit animations.
  final Animation<double>? animation;

  const OverflowText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.fadeLength = 6,
    this.animation,
  }) : super(key: key);

  /// Calculates the number of characters (runes) that can fit within the given
  /// constraints without overflowing.
  ///
  /// This method uses a binary search algorithm for efficient calculation and
  /// operates on runes to correctly handle multi-byte characters like emojis.
  int _findFittingTextLength(String textToMeasure, TextStyle? style, BoxConstraints constraints, BuildContext context) {
    // Sanitize the text before any measurement to prevent crashes from malformed strings.
    final sanitizedText = _sanitizeText(textToMeasure);
    if (sanitizedText.isEmpty) return 0;

    final TextStyle effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: sanitizedText, style: effectiveStyle),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
    );

    final double maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : double.infinity;
    textPainter.layout(maxWidth: maxWidth);

    // If the entire text fits, return its full length in runes.
    if (!textPainter.didExceedMaxLines && textPainter.width <= maxWidth) {
      return sanitizedText.runes.length;
    }

    // If the text overflows, perform a binary search to find the fitting character count.
    final runes = sanitizedText.runes.toList();
    int low = 0;
    int high = runes.length;
    int fittingRuneCount = 0;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (mid == 0) {
        low = mid + 1;
        continue;
      }

      // Create a test string from a subset of runes to ensure it's always valid.
      final testText = String.fromCharCodes(runes.sublist(0, mid));

      final testPainter = TextPainter(
        text: TextSpan(text: testText, style: effectiveStyle),
        maxLines: maxLines,
        textDirection: ui.TextDirection.ltr,
      );
      testPainter.layout(maxWidth: maxWidth);

      if (testPainter.didExceedMaxLines || testPainter.width > maxWidth) {
        high = mid - 1;
      } else {
        fittingRuneCount = mid; // This `mid` value fits, try for more.
        low = mid + 1;
      }
    }
    return fittingRuneCount;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // First, calculate how many characters of the original text will fit.
        final fittingRuneLength = _findFittingTextLength(text, style, constraints, context);

        if (fittingRuneLength == 0) {
          return const SizedBox.shrink();
        }

        // Sanitize the text that will actually be rendered.
        final sanitizedText = _sanitizeText(text);
        final totalRunes = sanitizedText.runes.length;

        // If the sanitized text fits completely, render a simple Text widget.
        if (fittingRuneLength >= totalRunes) {
          return Text(
            sanitizedText,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.clip,
          );
        }

        // --- Build the faded text using RichText for character-by-character styling ---

        // Truncate the text based on the calculated number of fitting runes.
        final String displayText = String.fromCharCodes(sanitizedText.runes.take(fittingRuneLength));
        final int displayRunesLength = displayText.runes.length;
        final int actualCharsToFade = math.min(displayRunesLength, fadeLength);

        // If no fading is needed, render the truncated text.
        if (actualCharsToFade <= 0) {
          return Text(
            displayText,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.clip,
          );
        }

        // Split the display text into the solid part and the part to be faded.
        final int solidPartRuneLength = displayRunesLength - actualCharsToFade;
        final String solidText = String.fromCharCodes(displayText.runes.take(solidPartRuneLength));
        final String fadingText = String.fromCharCodes(displayText.runes.skip(solidPartRuneLength));

        final List<InlineSpan> spans = [];
        if (solidText.isNotEmpty) {
          spans.add(TextSpan(text: solidText, style: style));
        }

        // Prepare colors for the fade effect.
        final Color defaultColor = DefaultTextStyle.of(context).style.color ?? Colors.black;
        final Color baseColorForFade = (style?.color ?? defaultColor).withAlpha(0xFF); // Color without its original alpha.
        final double originalStyleAlpha = (style?.color ?? defaultColor).opacity; // Original opacity from the style.
        const double fadeTargetMinRelativeOpacity = 0.2; // How dim the last character should be (e.g., 20% of original opacity).

        final fadingRunes = fadingText.runes.toList();
        for (int i = 0; i < fadingRunes.length; i++) {
          final double relativeFadeProgress = (actualCharsToFade <= 1) ? 1.0 : i / (actualCharsToFade - 1);

          // Interpolate opacity from the original style's alpha down to the target minimum.
          final double charOpacity = originalStyleAlpha * (1.0 - relativeFadeProgress * (1.0 - fadeTargetMinRelativeOpacity));
          final double animatedOpacity = (animation?.value ?? 1.0) * charOpacity;

          final TextStyle? charStyle = style?.copyWith(
            color: baseColorForFade.withOpacity(animatedOpacity.clamp(0.0, 1.0)),
          );

          spans.add(TextSpan(
            text: String.fromCharCode(fadingRunes[i]),
            style: charStyle,
          ));
        }

        return RichText(
          text: TextSpan(children: spans),
          maxLines: maxLines,
          overflow: TextOverflow.clip,
        );
      },
    );
  }
}
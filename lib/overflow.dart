// overflow.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class OverflowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final int fadeLength; // İstenen maksimum soluklaştırma karakter sayısı
  final Animation<double>? animation; // Animasyon için (örneğin fade-in)

  const OverflowText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.fadeLength = 6,
    this.animation,
  }) : super(key: key);

  int _findFittingTextLength(String text, TextStyle? style, BoxConstraints constraints, BuildContext context) {
    final TextStyle effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
    );

    final double maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : double.infinity;

    textPainter.layout(maxWidth: maxWidth);
    if (!textPainter.didExceedMaxLines && textPainter.width <= maxWidth) {
      return text.length;
    }

    int low = 0;
    int high = text.length;
    int fitting = 0;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (mid == 0) {
        fitting = 0;
        low = mid + 1;
        continue;
      }
      final testText = text.substring(0, mid);
      final testPainter = TextPainter(
        text: TextSpan(text: testText, style: effectiveStyle),
        maxLines: maxLines,
        textDirection: ui.TextDirection.ltr,
      );
      testPainter.layout(maxWidth: maxWidth);

      if (testPainter.didExceedMaxLines || testPainter.width > maxWidth) {
        high = mid - 1;
      } else {
        fitting = mid;
        low = mid + 1;
      }
    }
    return fitting;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fittingLength = _findFittingTextLength(text, style, constraints, context);

        if (fittingLength == 0) {
          return const SizedBox.shrink();
        }

        if (fittingLength >= text.length) {
          return Text(
            text,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.clip,
          );
        }

        final String displayText = text.substring(0, fittingLength);
        final int actualCharsToFade = math.min(displayText.length, fadeLength);

        if (actualCharsToFade <= 0) {
          return Text(
            displayText,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.clip,
          );
        }

        final int normalPartLength = displayText.length - actualCharsToFade;
        final String normalText = displayText.substring(0, normalPartLength);
        final String fadingTextPart = displayText.substring(normalPartLength);

        List<InlineSpan> spans = [];
        if (normalText.isNotEmpty) {
          // Normal kısım, orijinal stille (ve opaklığıyla) çizilir
          spans.add(TextSpan(text: normalText, style: style));
        }

        // Soluklaştırma için temel rengi (opaklığı 1.0 varsayılarak) ve stilin orijinal alfa değerini al
        final Color defaultColor = DefaultTextStyle.of(context).style.color ?? Colors.black;
        final Color baseColorForFade = (style?.color ?? defaultColor).withAlpha(0xFF); // Rengin alfa'sız hali
        final double styleAlpha = (style?.color ?? defaultColor).opacity; // Stildeki orijinal opaklık (örn: 0.5)

        // Soluklaştırmanın ne kadar derine ineceğini belirten faktör (örn: orijinal opaklığın %20'sine kadar)
        final double fadeTargetMinRelativeOpacity = 0.2;

        for (int i = 0; i < fadingTextPart.length; i++) {
          double relativeFadeProgress; // 0.0 (soluklaştırmanın başı) to 1.0 (soluklaştırmanın sonu)
          if (actualCharsToFade <= 1) {
            relativeFadeProgress = 1.0; // Tek karakter soluyorsa en sönük olsun
          } else {
            relativeFadeProgress = i / (actualCharsToFade - 1);
          }

          // Karakterin opaklığını hesapla: styleAlpha'dan başlar, styleAlpha * fadeTargetMinRelativeOpacity değerine düşer
          double charOpacity = styleAlpha * (1.0 - relativeFadeProgress * (1.0 - fadeTargetMinRelativeOpacity));

          // Varsa animasyonun opaklık değerini uygula
          charOpacity *= (animation?.value ?? 1.0);
          charOpacity = charOpacity.clamp(0.0, 1.0); // Geçerli opaklık aralığında kalmasını sağla

          final TextStyle? charStyle = style?.copyWith( // Font boyutu vb. için orijinal stili temel al
            color: baseColorForFade.withOpacity(charOpacity), // Temel renge hesaplanan opaklığı uygula
          );

          spans.add(TextSpan(
            text: fadingTextPart[i],
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
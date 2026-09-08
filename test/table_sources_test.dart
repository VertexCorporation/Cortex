import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:cortex/chat/screen/widgets/bottom/sources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'weather table survives preprocessing and preserves following prose',
      (tester) async {
    const text = '''**İstanbul’da şu anki hava durumu**

| Özellik | Değer |
| --------------------------- | ------------------------------------------------------ |
| **Sıcaklık** | 84 °F ≈ 29 °C |
| **Hissedilen sıcaklık** | 87 °F ≈ 31 °C |
| **Gökyüzü** | Çoğunlukla güneşli / az bulutlu |
| **Nem** | %55‑61 |
| **Rüzgar** | 9‑10 mph (≈ 14‑16 km/h) kuzey‑kuzeydoğu (NNE) yönünden |
| **Basınç** | 29.81‑29.86 inHg |
| **Yağış ihtimali** | %1‑2 (neredeyse yok) |
| **Gün doğumu / gün batımı** | 06:21 AM / 07:52 PM |

### Kısa vadeli tahmin

- **18:00** – Çoğunlukla güneşli
''';
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: Builder(
          builder: (context) => RichText(
                  text: TextSpan(
                children: parseText(context, text, isFinished: true),
              ))),
    ))));
    expect(find.byType(Table), findsOneWidget);
    expect(tester.widget<Table>(find.byType(Table)).children.length, 9);
    expect(find.textContaining('Kısa vadeli tahmin', findRichText: true),
        findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'embedded and bare links produce deduplicated sources only at completion',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    const text =
        '[link](https://example.com/Function_(math)) and https://example.org/docs.';
    for (final complete in [false, true]) {
      final spans = parseText(context, text,
          isFinished: complete, citations: ['https://example.org/docs']);
      final sources = spans
          .whereType<WidgetSpan>()
          .map((s) => s.child)
          .whereType<Padding>()
          .map((p) => p.child)
          .whereType<WebSearchSourcesWidget>()
          .toList();
      expect(sources.length, complete ? 1 : 0);
      if (complete) {
        expect(sources.single.sources, [
          'https://example.org/docs',
          'https://example.com/Function_(math)',
        ]);
      }
    }
  });
}

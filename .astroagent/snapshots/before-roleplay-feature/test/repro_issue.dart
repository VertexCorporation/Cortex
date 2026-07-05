import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Reproduction of Enes Batur text parsing',
          (WidgetTester tester) async {
        const userText = r'''
Enes Batur (full name: Enes Batur Sungurtekin) is a Turkish YouTuber, gamer, vlogger, actor, and producer born on April 9, 1998, in Ankara, Turkey, making him 27 years old as of 2026.**[1][2][3][5]

His main YouTube channel, **NDNG - Enes Batur** (also known as newdaynewgame), launched in 2012-2013, has over **16 million subscribers** and features simulator Let's Plays, challenge videos, vlogs, and music videos like "Dolunay" (170 million views) and "Biliyom" (138 million views).[1][2][3][5] He holds the record for the most-subscribed personal YouTube channel in Turkey.[2][3]

In his acting career, he starred in films such as **"Enes Batur: Imagination or Reality?" (2018)**, **"Kafalar Karisik" (2018)**, and **"Enes Batur: Gerçek Kahraman" (2019)**, and produced the 2021 series **"Enes Batur'la Bulusma."**[2] He has released singles including "Dolunay," "Biliyom," and "Yüreğine İnan."[2] Awards include the **Golden Palm Award for Best Social Media Phenomenon (2018)** and **Ayakli Gazete TV Stars Award for Best Youtuber (2021)**.[2]

His estimated **net worth is $10 million** from YouTube, acting, and production.[2] He studied computer science at Antalya Bilim University before switching to cinema and television at Nişantaşı University.[2] Personally, he dated YouTuber Başak Karahan (2017-2018) and staged a fake marriage to Damla Aslanalp in 2019 for film promotion.[3] His parents are Arzu (from Malatya) and Fatih (from Adana).[2][3] He also streams on Twitch.[1]
''';

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              final spans = parseText(context, userText);
              if (kDebugMode) {
                print('Parsed spans count: ${spans.length}');
              }
              for (var span in spans) {
                // print('Span: $span');
                if (span is WidgetSpan) {
                  if (kDebugMode) {
                    print('  WidgetSpan: ${span.child.runtimeType}');
                  }
                } else if (span is TextSpan) {
                  if (kDebugMode) {
                    print('  TextSpan: "${span.text}" style: ${span.style}');
                  }
                  if (span.children != null) {
                    if (kDebugMode) {
                      print('    Children: ${span.children!.length}');
                    }
                    for (var child in span.children!) {
                      if (child is WidgetSpan) {
                        if (kDebugMode) {
                          print('      WidgetSpan Child: ${child.child
                              .runtimeType}');
                        }
                      } else if (child is TextSpan) {
                        if (kDebugMode) {
                          print('      TextSpan Child: "${child.text}"');
                        }
                      }
                    }
                  }
                }
              }
              return Container();
            },
          ),
        ));
      });
}

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter/services.dart';
import 'package:highlight/highlight.dart' as highlight;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const oneDarkProTheme = {
  'comment': TextStyle(color: Color(0xff5c6370)), // Gri (yorumlar)
  'quote': TextStyle(color: Color(0xff5c6370)), // Gri (alıntılar)
  'variable': TextStyle(color: Color(0xffe06c75)), // Kırmızı
  'template-variable': TextStyle(color: Color(0xffe06c75)), // Kırmızı
  'attribute': TextStyle(color: Color(0xffd19a66)), // Turuncu
  'tag': TextStyle(color: Color(0xffe06c75)), // Kırmızı
  'name': TextStyle(color: Color(0xff61afef)), // Mavi
  'regexp': TextStyle(color: Color(0xff98c379)), // Yeşil
  'link': TextStyle(color: Color(0xff61afef)), // Mavi
  'selector-id': TextStyle(color: Color(0xffd19a66)), // Turuncu
  'selector-class': TextStyle(color: Color(0xffd19a66)), // Turuncu
  'number': TextStyle(color: Color(0xffd19a66)), // Turuncu
  'meta': TextStyle(color: Color(0xff61afef)), // Mavi
  'built_in': TextStyle(color: Color(0xffe5c07b)), // Açık sarı
  'builtin-name': TextStyle(color: Color(0xffe5c07b)), // Açık sarı
  'literal': TextStyle(color: Color(0xff56b6c2)), // Cam göbeği
  'type': TextStyle(color: Color(0xffe5c07b)), // Açık sarı
  'params': TextStyle(color: Color(0xffabb2bf)), // Açık gri
  'string': TextStyle(color: Color(0xff98c379)), // Yeşil
  'symbol': TextStyle(color: Color(0xff98c379)), // Yeşil
  'bullet': TextStyle(color: Color(0xff98c379)), // Yeşil
  'title': TextStyle(color: Color(0xff61afef)), // Mavi
  'section': TextStyle(color: Color(0xff61afef)), // Mavi
  'keyword': TextStyle(color: Color(0xffc678dd)), // Mor
  'selector-tag': TextStyle(color: Color(0xffc678dd)), // Mor
  'root': TextStyle(
    backgroundColor: Color(0xFF141414),
    color: Color(0xffabb2bf),
  ),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

class CodeBlockWidget extends StatefulWidget {
  final String code;

  const CodeBlockWidget({Key? key, required this.code}) : super(key: key);

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  String? detectedLanguage;

  @override
  void initState() {
    super.initState();
    _detectLanguage();
  }

  void _detectLanguage() {
    final result = highlight.highlight.parse(
      widget.code,
      autoDetection: true,
    );
    setState(() {
      detectedLanguage = result.language;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUnknown = detectedLanguage == null || detectedLanguage!.isEmpty;
    final languageName = isUnknown
        ? AppLocalizations.of(context)!.text // Örn. "Bilinmeyen"
        : detectedLanguage!;

    return Stack(
      children: [
        Container(
          // Arka plan rengini temada belirtilen "root" rengiyle aynı ayarlıyoruz
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              widget.code,
              language: isUnknown ? null : detectedLanguage,
              // One Dark Pro temasını kullanıyoruz
              theme: oneDarkProTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
        // Sol üst köşede algılanan dil adı veya "Bilinmeyen"
        Positioned(
          top: 4,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              languageName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.copy, size: 16, color: Colors.white),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: widget.code));
            },
          ),
        ),
      ],
    );
  }
}
import 'package:cortex/design.dart';
import 'package:cortex/theme.dart';
import '../../app.dart';
// ================ lib/chat/messages/codeblocks.dart (FULLY REFACTORED AND FIXED) ================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:highlight/highlight.dart' as highlight;
import 'package:highlight/languages/all.dart';
import 'package:provider/provider.dart';

import '../../notifications/introvert.dart';

const Map<String, TextStyle> oneDarkProTheme = {
  'root':
      TextStyle(backgroundColor: Color(0xFF141414), color: Color(0xffabb2bf)),
  'comment': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'variable': TextStyle(color: Color(0xffe06c75)),
  'template-variable': TextStyle(color: Color(0xffe06c75)),
  'tag': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xff61afef)),
  'selector-id': TextStyle(color: Color(0xffe06c75)),
  'selector-class': TextStyle(color: Color(0xffe06c75)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'built_in': TextStyle(color: Color(0xffe5c07b)),
  'builtin-name': TextStyle(color: Color(0xffe5c07b)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'type': TextStyle(color: Color(0xffe5c07b)),
  'params': TextStyle(color: Color(0xffabb2bf)),
  'meta': TextStyle(color: Color(0xffc678dd)),
  'meta-keyword': TextStyle(color: Color(0xffc678dd)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'string': TextStyle(color: Color(0xff98c379)),
  'symbol': TextStyle(color: Color(0xff56b6c2)),
  'bullet': TextStyle(color: Color(0xff56b6c2)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'title': TextStyle(color: Color(0xff61afef)),
  'section': TextStyle(color: Color(0xff61afef)),
  'keyword': TextStyle(color: Color(0xffc678dd)),
  'selector-tag': TextStyle(color: Color(0xffc678dd)),
  'attribute': TextStyle(color: Color(0xffd19a66)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

class CodeBlockWidget extends StatefulWidget {
  final String code;
  final String? language;

  const CodeBlockWidget({
    super.key,
    required this.code,
    this.language,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  String? _resolvedLanguage;
  bool _copying = false;

  static final _autoDetectCache = <String, String?>{};
  static const int _maxAutoDetectLength = 50000;

  @override
  void initState() {
    super.initState();
    _resolveLanguage();
  }

  @override
  void didUpdateWidget(covariant CodeBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.language != oldWidget.language ||
        widget.code != oldWidget.code) {
      _resolveLanguage();
    }
  }

  void _resolveLanguage() {
    String? finalLang;
    final providedLang = widget.language?.toLowerCase().trim();

    if (providedLang != null && providedLang.isNotEmpty) {
      if (allLanguages.containsKey(providedLang)) {
        finalLang = providedLang;
      }
    }

    if (widget.code.contains('<!DOCTYPE html>') ||
        (widget.code.contains('<html') && widget.code.contains('</html')) ||
        (widget.code.contains('<div') && widget.code.contains('</div'))) {
      finalLang = 'html';
    }

    if (finalLang == null && widget.code.isNotEmpty) {
      if (_autoDetectCache.containsKey(widget.code)) {
        finalLang = _autoDetectCache[widget.code];
      } else if (widget.code.length < _maxAutoDetectLength) {
        final code = widget.code;
        Future(() {
          if (!mounted) return;
          final result = highlight.highlight.parse(code, autoDetection: true);
          _autoDetectCache[code] = result.language;
          if (_autoDetectCache.length > 200) {
            final key = _autoDetectCache.keys.first;
            _autoDetectCache.remove(key);
          }
          if (mounted && _resolvedLanguage != result.language) {
            setState(() {
              _resolvedLanguage = result.language;
            });
          }
        });
      }
    }

    if (mounted && _resolvedLanguage != finalLang) {
      setState(() {
        _resolvedLanguage = finalLang;
      });
    }
  }

  Future<void> _copyCodeToClipboard() async {
    if (_copying) return;
    if (mounted) setState(() => _copying = true);
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (mounted) {
      Provider.of<IntrovertNotificationService>(context, listen: false)
          .showNotification(
        message: AppLocalizations.of(context)!.messageCopied,
        type: NotificationType.success,
        bottomOffset: 0.02,
        isChatMode: true,
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _copying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageNameForDisplay =
        _resolvedLanguage != null && _resolvedLanguage!.isNotEmpty
            ? (_resolvedLanguage![0].toUpperCase() +
                _resolvedLanguage!.substring(1))
            : AppLocalizations.of(context)!.text;

    final languageForHighlighter = _resolvedLanguage ?? 'plaintext';
    final highlightTheme = Map<String, TextStyle>.of(oneDarkProTheme)
      ..['root'] = TextStyle(
        backgroundColor: AppColors.background,
        color: const Color(0xffabb2bf),
      );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF5F56),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFBD2E),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: Color(0xFF27C93F),
                              shape: BoxShape.circle)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    languageNameForDisplay,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _copyCodeToClipboard,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _copying
                            ? const Icon(Icons.check_rounded,
                                size: CortexDesign.icon,
                                color: Color(0xFF27C93F),
                                key: ValueKey('check'))
                            : SvgPicture.asset(
                                'assets/icons/copy.svg',
                                width: CortexDesign.icon,
                                height: CortexDesign.icon,
                                colorFilter: ColorFilter.mode(
                                  AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                                  BlendMode.srcIn,
                                ),
                                key: const ValueKey('copy'),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: HighlightView(
                      widget.code,
                      language: languageForHighlighter,
                      theme: highlightTheme,
                      padding: const EdgeInsets.all(16),
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

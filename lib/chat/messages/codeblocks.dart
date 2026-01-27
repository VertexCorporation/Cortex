// ================ lib/chat/messages/codeblocks.dart (FULLY REFACTORED AND FIXED) ================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:highlight/highlight.dart' as highlight;
import 'package:highlight/languages/all.dart';
import 'package:provider/provider.dart';

import '../../notifications/introvert.dart';
import '../../theme.dart';

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

/// A widget that displays a block of code with syntax highlighting, a copy button,
/// and a language identifier.
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

  /// Resolves the language to be used for highlighting.
  /// Priority:
  /// 1. Use the language hint provided by the parser if it's valid and supported.
  /// 2. If no valid hint is provided, fall back to auto-detection.
  void _resolveLanguage() {
    String? finalLang;
    final providedLang = widget.language?.toLowerCase().trim();

    if (providedLang != null && providedLang.isNotEmpty) {
      if (allLanguages.containsKey(providedLang)) {
        finalLang = providedLang;
        debugPrint(
            "[CodeBlock] Using provided and supported language hint: '$finalLang'");
      } else {
        debugPrint(
            "[CodeBlock] Provided language hint '${widget.language}' is not in `allLanguages`. Falling back to auto-detection.");
      }
    }

    // If no valid hint was found or provided, and the code is not empty, fall back to auto-detection.
    if (finalLang == null && widget.code.isNotEmpty) {
      final result =
          highlight.highlight.parse(widget.code, autoDetection: true);
      finalLang = result.language; // This can still be null if detection fails.
      debugPrint(
          "[CodeBlock] No valid hint. Auto-detected language: '$finalLang'");
    }

    if (mounted) {
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Force dark background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Code Content
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: HighlightView(
                widget.code,
                language: languageForHighlighter,
                theme: oneDarkProTheme,
                padding: const EdgeInsets.fromLTRB(
                    16, 48, 16, 16), // Adjusted padding
                textStyle:
                    const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Slightly lighter header
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      languageNameForDisplay,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: _copyCodeToClipboard,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _copying
                              ? const Icon(Icons.check,
                                  size: 16,
                                  color: Colors.greenAccent,
                                  key: ValueKey('check'))
                              : const Icon(Icons.copy_all_outlined,
                                  size: 16,
                                  color: Colors.white54,
                                  key: ValueKey('copy')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

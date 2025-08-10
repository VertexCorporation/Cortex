import 'package:cortex/chat/messages/parser.dart';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../notifications.dart';
import '../../theme.dart';

class SelectTextScreen extends StatefulWidget {
  /// A notifier holding the complete message string to be displayed.
  /// This screen uses the final value from the notifier upon being built.
  final ValueNotifier<String> messageNotifier;

  const SelectTextScreen({Key? key, required this.messageNotifier})
      : super(key: key);

  @override
  _SelectTextScreenState createState() => _SelectTextScreenState();
}

class _SelectTextScreenState extends State<SelectTextScreen> {
  /// Determines whether to show the rich, parsed text or the plain, stripped text.
  bool _hideSpecial = false;

  /// Toggles the visibility of Markdown and LaTeX formatting.
  void _toggleSpecialVisibility() {
    setState(() {
      _hideSpecial = !_hideSpecial;
    });
  }

  /// Copies the current version of the text (either rich or stripped) to the clipboard.
  void _copyText(BuildContext ctx) {
    final rawText = widget.messageNotifier.value;
    final textToCopy = _hideSpecial ? _stripMarkup(rawText) : rawText;

    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show a confirmation notification.
    Provider.of<NotificationService>(ctx, listen: false).showNotification(
      message: AppLocalizations.of(ctx)!.messageCopied,
      isSuccess: true,
      bottomOffset: 0.01,
    );
  }

  /// **Why this function exists and is separate from the main parser:**
  ///
  /// The main `parseText` function converts a raw string into a `List<InlineSpan>`
  /// for rich visual rendering. Its purpose is to *display* formatted content.
  ///
  /// This `_stripMarkup` function serves a different purpose: it converts a raw string
  /// into a plain `String` by removing all formatting markers. This is used for
  /// the "Hide Special" view and for copying plain text. It extracts the semantic
  /// content, discarding the presentation.
  ///
  /// By keeping this logic here, we avoid polluting the main parser with a
  /// string-to-string conversion responsibility.
  String _stripMarkup(String text) {
    // Stage 1: Replace block elements with their content.
    // Order is important: code blocks first, then others.

    // Codeblocks (```lang\n … ```) -> content
    text = text.replaceAllMapped(
        RegExp(r'```(?:\w+\n)?([\s\S]*?)```', dotAll: true),
            (m) => m[1]?.trim() ?? '');

    // Headers (e.g., "## Header") -> "Header"
    text = text.replaceAllMapped(
        RegExp(r'^(#{1,6})\s+(.*)', multiLine: true), (m) => m[2] ?? '');

    // Table content is complex to extract cleanly, so we'll just remove the structure.
    text = text.replaceAll(RegExp(r'\|'), ' ');

    // List bullets (*, -, +)
    text = text.replaceAll(RegExp(r'^\s*[\*\-\+]\s+', multiLine: true), '');

    // Horizontal rules
    text = text.replaceAll(RegExp(r'^---$', multiLine: true), '');

    // Stage 2: Replace inline elements with their content.

    // Links & images: ![alt](src) -> alt, [text](src) -> text
    text = text.replaceAllMapped(
        RegExp(r'!\[([^\]]*)\]\([^)]+\)'), (m) => m[1] ?? '');
    text = text.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m[1] ?? '');

    // LaTeX ($...$, $$...$$, etc.) - remove delimiters and commands, keep content.
    text = text.replaceAllMapped(
        RegExp(r'(\$\$|\$|\\\[|\\\]|\\\(|\\\)|\\begin\{[a-z]+\*?\}|\\end\{[a-z]+\*?\})'),
            (_) => ''
    );
    // Remove leftover LaTeX commands like \frac, \sqrt, etc.
    text = text.replaceAll(RegExp(r'\\[a-zA-Z]+'), ' ');

    // Bold, italic, strikethrough, inline code (extract content)
    for (final r in [
      RegExp(r'(\*\*\*|___)(.*?)\1', dotAll: true), // Bold-Italic
      RegExp(r'(\*\*|__)(.*?)\1', dotAll: true),   // Bold
      RegExp(r'(\*|_)(.*?)\1', dotAll: true),       // Italic
      RegExp(r'~~(.*?)~~', dotAll: true),         // Strikethrough
      RegExp(r'`([^`]+)`', dotAll: true),        // Inline Code
    ]) {
      text = text.replaceAllMapped(r, (m) => m[2] ?? m[1] ?? '');
    }

    // Stage 3: Clean up whitespace and remaining artifacts.
    text = text.replaceAll(RegExp(r'\\([{}])'), r'$1'); // Un-escape chars \{ -> {
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');     // Collapse multiple spaces
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // Collapse excess newlines

    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final fg = AppColors.primaryColor.inverted;
    final bg = AppColors.background;

    final baseTextStyle = TextStyle(color: fg, fontSize: 16, height: 1.4);
    final rawText = widget.messageNotifier.value;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: fg),
        titleSpacing: 0,
        centerTitle: false,
        title: Text(loc.selectText,
            style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: IconButton(
              key: ValueKey(_hideSpecial),
              icon: Icon(
                _hideSpecial ? Icons.visibility_off : Icons.visibility,
                color: fg,
              ),
              tooltip: _hideSpecial ? loc.showLatex : loc.hideLatex,
              onPressed: _toggleSpecialVisibility,
            ),
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/copy.svg',
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                width: 24,
                height: 24),
            tooltip: loc.copy,
            onPressed: () => _copyText(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _hideSpecial
              ? _buildStrippedTextView(rawText, baseTextStyle)
              : _buildRichTextView(rawText, baseTextStyle),
        ),
      ),
    );
  }

  /// Builds the view for the plain, stripped text.
  Widget _buildStrippedTextView(String rawText, TextStyle style) {
    return SingleChildScrollView(
      key: const ValueKey('stripped'),
      child: SelectableText(
        _stripMarkup(rawText),
        style: style,
      ),
    );
  }

  /// Builds the view for the rich text, parsed with Markdown and LaTeX.
  Widget _buildRichTextView(String rawText, TextStyle style) {
    return SingleChildScrollView(
      key: const ValueKey('rich'),
      child: SelectableText.rich(
        TextSpan(
          children: parseText(rawText),
          style: style,
        ),
      ),
    );
  }
}
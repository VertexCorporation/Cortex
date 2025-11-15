// lib/messages/options/select.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/messages/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../notifications/introvert.dart';
import '../../../theme.dart';

/// A screen that displays a message and allows the user to view it with or
/// without rich formatting, and to copy it to the clipboard.
class SelectTextScreen extends StatefulWidget {
  /// A notifier holding the complete message string to be displayed.
  final ValueNotifier<String> messageNotifier;

  const SelectTextScreen({super.key, required this.messageNotifier});

  @override
  SelectTextScreenState createState() => SelectTextScreenState();
}

class SelectTextScreenState extends State<SelectTextScreen> {
  /// Determines whether to show the rich, parsed text or the plain, stripped text.
  bool _hideSpecialFormatting = false;

  /// Toggles the visibility of Markdown and LaTeX formatting.
  void _toggleFormattingVisibility() {
    setState(() {
      _hideSpecialFormatting = !_hideSpecialFormatting;
    });
  }

  /// Copies the current version of the text (either formatted or plain) to the clipboard.
  void _copyText(BuildContext ctx) {
    final rawText = widget.messageNotifier.value;
    // Use the reliable, centralized `stripMarkup` function from the parser.
    final textToCopy = _hideSpecialFormatting ? stripMarkup(rawText) : rawText;

    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show a confirmation notification.
    Provider.of<IntrovertNotificationService>(ctx, listen: false).showNotification(
      message: AppLocalizations.of(ctx)!.messageCopied,
      type: NotificationType.success,
      bottomOffset: 0.01,
    );
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
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: IconButton(
              key: ValueKey(_hideSpecialFormatting),
              icon: Icon(
                _hideSpecialFormatting
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: fg,
              ),
              tooltip: _hideSpecialFormatting ? loc.showLatex : loc.hideLatex,
              onPressed: _toggleFormattingVisibility,
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
          child: _hideSpecialFormatting
              ? _buildStrippedTextView(rawText, baseTextStyle)
              : _buildRichTextView(rawText, baseTextStyle),
        ),
      ),
    );
  }

  /// Builds the view for the plain, stripped text.
  /// It now uses the robust, centralized `stripMarkup` function.
  Widget _buildStrippedTextView(String rawText, TextStyle style) {
    return SingleChildScrollView(
      key: const ValueKey('stripped'),
      child: SelectableText(
        stripMarkup(rawText),
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
          children: parseText(context, rawText, fontSize: style.fontSize),
          style: style,
        ),
      ),
    );
  }
}
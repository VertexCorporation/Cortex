// lib/messages/options/select.dart

import 'package:cortex/app.dart';
import 'package:cortex/appbar.dart';
import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../notifications/introvert.dart';
import '../../../theme.dart';

/// A screen that displays a message and allows the user to view it with or
/// without rich formatting, and to copy it to the clipboard.
///
/// This screen is now fully responsive, scaling typography and layout elements
/// dynamically based on the device screen width.
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
    // If formatting is hidden visually, we also copy the stripped version.
    final textToCopy = _hideSpecialFormatting ? stripMarkup(rawText) : rawText;

    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show a confirmation notification using the app's internal notification service.
    Provider.of<IntrovertNotificationService>(ctx, listen: false)
        .showNotification(
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

    // --- Dynamic Scaling Calculation ---
    // We establish a scaling factor based on a reference mobile width (400dp).
    // This ensures consistent visual density across phones and tablets.
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = screenWidth / 400.0;

    // Define dynamic dimensions
    final double bodyFontSize = 16.0 * scale;
    final double iconSize = 24.0 * scale;
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      16.0 * scale,
      8.0 * scale,
      16.0 * scale,
      16.0 * scale,
    );

    final baseTextStyle = TextStyle(
      color: fg,
      fontSize: bodyFontSize,
      height: 1.4,
    );
    final rawText = widget.messageNotifier.value;

    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      appBar: CortexAppBar(
        leadingMode: CortexLeadingMode.back,
        titleText: loc.selectText,
        showGradient: false,
        actions: [
          // Toggle Formatting Button
          AppBarButton(
            size: 42.0,
            onTap: _toggleFormattingVisibility,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _hideSpecialFormatting
                    ? Icons.visibility_off
                    : Icons.visibility,
                key: ValueKey(_hideSpecialFormatting),
                color: fg,
                size: iconSize,
              ),
            ),
          ),
          // Copy Button
          AppBarButton(
            size: 42.0,
            onTap: () => _copyText(context),
            child: SvgPicture.asset(
              'assets/icons/copy.svg',
              colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              width: iconSize,
              height: iconSize,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: contentPadding,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _hideSpecialFormatting
                ? _buildStrippedTextView(rawText, baseTextStyle)
                : _buildRichTextView(rawText, baseTextStyle),
          ),
        ),
      ),
    );
  }

  /// Builds the view for the plain, stripped text.
  /// Uses the dynamic [style] passed from the build method.
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
  /// The [parseText] function is aware of the dynamic font size to scale
  /// equations and headers correctly.
  Widget _buildRichTextView(String rawText, TextStyle style) {
    return SingleChildScrollView(
      key: const ValueKey('rich'),
      child: SelectableText.rich(
        TextSpan(
          // Ensure the parser knows the base font size for relative scaling of markdown elements.
          children: parseText(context, rawText, fontSize: style.fontSize),
          style: style,
        ),
      ),
    );
  }
}

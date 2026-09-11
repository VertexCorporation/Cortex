import 'package:cortex/design.dart';
import 'package:cortex/app.dart';
import 'package:cortex/fog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/notifications/introvert.dart';

double baseFs(BuildContext context) {
  final view = View.of(context);
  final physicalWidth = view.physicalSize.width;
  final devicePixelRatio = view.devicePixelRatio;
  return (physicalWidth / devicePixelRatio) * 0.044;
}

class SafeMathTex extends StatefulWidget {
  final String latex;
  final TextStyle textStyle;

  /// `false` (default, `$…$`) — renders inline, flowing with the text.
  /// `true` (`$$…$$`) — standalone block: vertical padding, full width,
  /// and horizontal scroll behind fog edges when the equation overflows.
  final bool display;

  const SafeMathTex({
    required this.latex,
    required this.textStyle,
    this.display = false,
    super.key,
  });

  @override
  State<SafeMathTex> createState() => _SafeMathTexState();
}

class _SafeMathTexState extends State<SafeMathTex> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // flutter_math_fork renders malformed input through onErrorFallback
    // (literal source text) — the outer catch is belt and braces so a math
    // span can never crash the whole message pipeline.
    Widget content;
    try {
      content = Math.tex(
        widget.latex,
        textStyle: widget.textStyle,
        onErrorFallback: (_) => Text(widget.latex, style: widget.textStyle),
      );
    } catch (_) {
      content = Text(widget.latex, style: widget.textStyle);
    }

    if (!widget.display) {
      // Inline math: sit in the text flow, no scrolling container (a
      // horizontal ScrollView inside a WidgetSpan would greedily take the
      // full line width and break the paragraph layout).
      return content;
    }

    // Display math: wide equations scroll horizontally behind the shared
    // fade-out fog edges (lib/fog.dart), exactly like code blocks. The
    // LayoutBuilder guard keeps this safe even if some future host hands
    // the span unbounded width (a bare SizedBox(infinity) would crash then).
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
          child: ScrollFogHorizontal(
            scrollController: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: content,
            ),
          ),
        );
      }),
    );
  }
}

class MatchRange {
  final int start, end;
  final String text, type;

  MatchRange(
      {required this.start,
      required this.end,
      required this.text,
      required this.type});
}

void openLink(BuildContext context, String urlString) async {
  final uri = Uri.tryParse(urlString);
  if (uri == null) return;
  final l10n = AppLocalizations.of(context)!;
  final warningMessage =
      l10n.openLinkWarningMessage(urlString).replaceAll(r'\n', '\n');

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        width: 1.0,
      ),
    ),
    builder: (BuildContext sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/world.svg',
                  width: CortexDesign.icon,
                  height: CortexDesign.icon,
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.openLinkWarningTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              warningMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor.inverted,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    l10n.openLinkCancel,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.inverted,
                    foregroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final success = await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                    if (!success && context.mounted) {
                      Provider.of<IntrovertNotificationService>(context,
                              listen: false)
                          .showNotification(
                        message: AppLocalizations.of(context)!.anErrorOccurred,
                        type: NotificationType.success,
                        bottomOffset: 0.22,
                      );
                    }
                  },
                  child: Text(l10n.openLinkConfirm),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

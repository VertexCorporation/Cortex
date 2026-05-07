import 'package:cortex/app.dart';
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
  return (physicalWidth / devicePixelRatio) * 0.042;
}

class SafeMathTex extends StatelessWidget {
  final String latex;
  final TextStyle textStyle;

  const SafeMathTex({required this.latex, required this.textStyle, super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          latex,
          textStyle: textStyle,
          onErrorFallback: (_) => Text(latex, style: textStyle),
        ),
      );
    } catch (_) {
      return Text(latex, style: textStyle);
    }
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
                  width: 24,
                  height: 24,
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
              l10n.openLinkWarningMessage(urlString),
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

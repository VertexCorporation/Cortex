import 'package:cortex/design.dart';
// lib/chat/screen/selected/widgets/input/panels/edit.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/sheet.dart';

class EditPanelWidget extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final VoidCallback onCancel;

  const EditPanelWidget({
    super.key,
    required this.slideAnimation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bool isTablet = screenWidth >= 600;
    final localizations = AppLocalizations.of(context)!;

    // The banner hugs the composer capsule exactly: the same reading-band
    // inset and the same expanded share the composer paints while the edit
    // field is active — it never spreads over the detached control bubbles.
    final double capsuleInset =
        composerCapsuleInset(screenWidth, expanded: true);
    final double bannerWidth = screenWidth -
        2 * (CortexDesign.readingInset(screenWidth) + capsuleInset);

    // --- DYNAMIC SCALING ---
    // Using screenWidth for height calculations on tablet to maintain proportions

    // Height: Tablet 6% of width. Phone 5% of height.
    final double height = isTablet ? screenWidth * 0.06 : screenHeight * 0.05;

    // Icon: Tablet 3% of width. Phone 5%.
    final double iconSize = CortexDesign.icon;

    // Text: Tablet 2.2% of width. Phone 3.5%.
    final double fontSize =
        isTablet ? screenWidth * 0.022 : screenWidth * 0.035;

    // Radius: match the composer capsule (CortexDesign.cardRadius) so the
    // banner reads as the capsule growing an extra story, not a detached
    // full-width sheet fragment.
    final double radius = CortexDesign.cardRadius;

    // The capsule-width banner must float exactly over the composer capsule.
    // SizeTransition's vertical-axis default alignment presses any child
    // narrower than the bar to the start edge, so this widget centers
    // itself instead of trusting the parent to align it.
    return Center(
      child: SlideTransition(
        position: slideAnimation,
        child: LiquidGlassPanel(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            key: const ValueKey('edit_banner'),
            width: bannerWidth,
            height: height,
            // Same material as the composer capsule: opaque background,
            // full border, matching radius.
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                Expanded(
                  child: Text(
                    localizations.editingNotification,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.007),
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Icon(
                      Icons.cancel,
                      size: CortexDesign.iconSmall,
                      color: AppColors.primaryColor.inverted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

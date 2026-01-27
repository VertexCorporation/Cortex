// lib/chat/screen/widgets/bottom/features/button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';

import '../../../../../../app.dart';

class FeaturesSheetButton extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  // Provide EITHER iconPath (SVG) OR iconData (Flutter Icon)
  final String? iconPath;
  final IconData? iconData;

  final bool isDisabled;
  final bool isSelected;

  const FeaturesSheetButton({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.iconPath,
    this.iconData,
    this.isDisabled = false,
    this.isSelected = false,
  }) : assert(iconPath != null || iconData != null,
  'Provide either iconPath or iconData');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth >= 600;

    // Dimensions
    final double horizontalMargin = isTablet ? 24.0 : 16.0;
    final double verticalMargin = isTablet ? 6.0 : 4.0;
    final double paddingVertical = isTablet ? 16.0 : 14.0;
    final double paddingHorizontal = isTablet ? 20.0 : 16.0;
    final double borderRadius = isTablet ? 16.0 : 14.0;

    final double iconContainerSize = isTablet
        ? screenWidth * 0.09
        : screenWidth * 0.11;
    final double innerIconSize = iconContainerSize * 0.5;
    final double titleSize = isTablet ? screenWidth * 0.028 : screenWidth *
        0.04;
    final double descSize = isTablet ? screenWidth * 0.02 : screenWidth * 0.032;

    // --- COLOR ANIMATION LOGIC ---
    // Normal:   Bg = Background, Text = Inverted
    // Selected: Bg = Inverted,   Text = Background
    final Color normalBg = AppColors.background;
    final Color normalFg = AppColors.primaryColor.inverted;

    final Color targetBg = isSelected ? normalFg : normalBg;
    final Color targetFg = isSelected ? normalBg : normalFg;

    // Border disappears when selected to look cleaner
    final Color targetBorder = isSelected ? Colors.transparent : AppColors
        .border;

    final double opacity = isDisabled ? 0.4 : 1.0;

    // Animation Duration
    const Duration animDuration = Duration(milliseconds: 400);
    const Curve animCurve = Curves.easeOutCubic;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: verticalMargin,
        ),
        // 1. ANIMATED CONTAINER for smooth Background Fade
        child: AnimatedContainer(
          duration: animDuration,
          curve: animCurve,
          decoration: BoxDecoration(
            color: targetBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: targetBorder,
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: targetFg.withValues(alpha: 0.1),
              highlightColor: targetFg.withValues(alpha: 0.05),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: paddingVertical,
                  horizontal: paddingHorizontal,
                ),
                child: Row(
                  children: [
                    // 2. Icon Container
                    AnimatedContainer(
                      duration: animDuration,
                      curve: animCurve,
                      width: iconContainerSize,
                      height: iconContainerSize,
                      decoration: BoxDecoration(
                        // Logic: When selected, the icon circle is slightly visible against the dark bg
                        color: isSelected
                            ? targetFg.withValues(alpha: 0.2)
                            : AppColors.secondaryColor.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        // Note: SVG color animation isn't implicit, but the container fade
                        // makes the switch look smooth enough.
                        child: iconPath != null
                            ? SvgPicture.asset(
                          iconPath!,
                          width: innerIconSize,
                          height: innerIconSize,
                          colorFilter: ColorFilter.mode(
                            targetFg,
                            BlendMode.srcIn,
                          ),
                        )
                            : Icon(
                          iconData,
                          size: innerIconSize,
                          color: targetFg,
                        ),
                      ),
                    ),
                    SizedBox(width: paddingHorizontal * 0.8),

                    // 3. Texts with Animated Styles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: animDuration,
                            curve: animCurve,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: titleSize,
                              fontWeight: FontWeight.w600,
                              color: targetFg,
                              letterSpacing: 0.3,
                            ),
                            child: Text(title),
                          ),
                          SizedBox(height: isTablet ? 4.0 : 2.0),
                          AnimatedDefaultTextStyle(
                            duration: animDuration,
                            curve: animCurve,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: descSize,
                              fontWeight: FontWeight.w400,
                              color: targetFg.withValues(alpha: 0.6),
                              height: 1.2,
                            ),
                            child: Text(description),
                          ),
                        ],
                      ),
                    ),

                    // 4. Navigation Arrow (Only for non-selectable actions like Explore)
                    // We REMOVED the Checkmark (Tick) as requested.
                    if (!isDisabled && !isSelected &&
                        (title == 'Explore' || title == 'Keşfet'))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.tertiaryColor.withValues(alpha: 0.5),
                          size: 18.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
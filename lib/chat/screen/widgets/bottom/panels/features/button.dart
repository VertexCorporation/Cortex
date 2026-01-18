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

  const FeaturesSheetButton({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.iconPath,
    this.iconData,
    this.isDisabled = false,
  }) : assert(iconPath != null ||
      iconData != null, 'Provide either iconPath or iconData');

  @override
  Widget build(BuildContext context) {
    // --- Responsive Dimensions ---
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isTablet = screenWidth >= 600;

    // Dynamic Sizing
    final double paddingVertical = isTablet ? 20.0 : 16.0;
    final double paddingHorizontal = isTablet ? 24.0 : 20.0;

    // Icon sizing
    final double iconContainerSize = isTablet
        ? screenWidth * 0.1
        : screenWidth * 0.13;
    final double innerIconSize = iconContainerSize * 0.5;

    // Font sizing
    final double titleSize = isTablet ? screenWidth * 0.03 : screenWidth *
        0.045;
    final double descSize = isTablet ? screenWidth * 0.022 : screenWidth *
        0.035;

    final Color contentColor = AppColors.primaryColor.inverted;

    // Opacity for disabled state
    final double opacity = isDisabled ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          splashColor: contentColor.withValues(alpha: 0.1),
          highlightColor: contentColor.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: paddingVertical,
              horizontal: paddingHorizontal,
            ),
            child: Row(
              children: [
                // 1. Circle Icon Container
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: iconPath != null
                        ? SvgPicture.asset(
                      iconPath!,
                      width: innerIconSize,
                      height: innerIconSize,
                      colorFilter: ColorFilter.mode(
                        contentColor,
                        BlendMode.srcIn,
                      ),
                    )
                        : Icon(
                      iconData,
                      size: innerIconSize,
                      color: contentColor,
                    ),
                  ),
                ),
                SizedBox(width: paddingHorizontal * 0.8),

                // 2. Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: contentColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4.0 : 2.0),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: descSize,
                          fontWeight: FontWeight.w400,
                          color: contentColor.withValues(alpha: 0.7),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Arrow (Optional visual cue)
                if (!isDisabled)
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.tertiaryColor.withValues(alpha: 0.3),
                      size: titleSize * 1.5,
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
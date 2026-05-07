// lib/axon/item.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app.dart';

class AxonItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;
  final bool reduceIconSize;
  final bool isOfflineActive; // Kept for interface consistency
  final bool isActive;
  final double screenHeight;
  final double referenceWidth;

  const AxonItem({
    super.key,
    required this.label,
    required this.iconPath,
    this.onTap,
    required this.screenHeight,
    required this.referenceWidth,
    this.reduceIconSize = false,
    this.isOfflineActive = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Colors & Styles
    // Pre-calculating these avoids logic inside the widget tree construction
    final Color textColor = AppColors.primaryColor.inverted;
    final Color iconColor = AppColors.primaryColor.inverted;

    // Optimization: Use withValues for cleaner opacity handling
    final Color targetBackgroundColor = isActive
        ? AppColors.primaryColor.inverted.withValues(alpha: 0.05)
        : Colors.transparent;

    final FontWeight fontWeight = isActive ? FontWeight.w600 : FontWeight.w500;

    // Dimensions
    // Dimensions — aligned with footer horizontal padding
    final double itemPaddingV = screenHeight * 0.011;
    final double itemPaddingH = referenceWidth * 0.04;
    final double baseIconSize = referenceWidth * 0.055;
    final double iconSize = reduceIconSize ? baseIconSize * 0.78 : baseIconSize;
    final double fontSize = referenceWidth * 0.04;
    final double borderRadius = referenceWidth * 0.03;

    // --- ANIMATED CONTAINER WRAPPER ---
    return Padding(
      // Optimization: Added minimal padding wrapper to prevent clipping issues
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.002),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuad, // Slightly smoother curve for hover effects
        decoration: BoxDecoration(
          color: targetBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior: Clip.hardEdge, // PERFORMANCE: hardEdge avoids saveLayer
          child: InkWell(
            onTap: onTap != null
                ? () {
                    HapticFeedback.lightImpact();
                    onTap!();
                  }
                : null,
            splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            highlightColor:
                AppColors.primaryColor.inverted.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: itemPaddingV, horizontal: itemPaddingH),
              child: Row(
                children: [
                  // Icon Area
                  SizedBox(
                    width: iconSize * 1.2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                        // Optimization: BlendMode.srcIn is faster than masking
                        colorFilter:
                            ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(width: referenceWidth * 0.03),

                  // Label Area
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

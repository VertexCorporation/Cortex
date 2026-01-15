// lib/axon/item.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';

class AxonItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;
  final bool reduceIconSize;
  final bool isOfflineActive;
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
    // Colors
    final Color textColor = AppColors.primaryColor.inverted;
    final Color iconColor = AppColors.primaryColor.inverted;

    final Color targetBackgroundColor = isActive
        ? AppColors.primaryColor.inverted.withValues(alpha: 0.05)
        : Colors.transparent;

    final FontWeight fontWeight = isActive ? FontWeight.w600 : FontWeight.w500;

    // Dimensions
    final double itemPaddingV = screenHeight * 0.015;
    final double itemPaddingH = referenceWidth * 0.04;
    final double baseIconSize = referenceWidth * 0.065;
    final double iconSize = reduceIconSize ? baseIconSize * 0.85 : baseIconSize;
    final double fontSize = referenceWidth * 0.042;
    final double borderRadius = referenceWidth * 0.03;

    // --- ANIMATED CONTAINER WRAPPER ---
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: targetBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // FIX: Removed onLongPress: onTap to prevent accidental triggers
          splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
          highlightColor: AppColors.primaryColor.inverted.withValues(
              alpha: 0.05),
          child: Container(
            width: referenceWidth * 0.85,
            padding: EdgeInsets.symmetric(
                vertical: itemPaddingV, horizontal: itemPaddingH),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: iconSize * 1.2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      iconPath,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                SizedBox(width: referenceWidth * 0.03),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.roboto(
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
    );
  }
}
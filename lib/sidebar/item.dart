// lib/sidebar/item.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app.dart';

class SidebarItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool reduceIconSize;
  final bool isOfflineActive;

  final double screenHeight;
  final double referenceWidth;

  const SidebarItem({
    super.key,
    required this.label,
    required this.iconPath,
    this.onTap,
    this.isPrimary = false,
    required this.screenHeight,
    required this.referenceWidth,
    this.reduceIconSize = false,
    this.isOfflineActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool highlight = isPrimary || isOfflineActive;

    final color = highlight
        ? AppColors.primaryColor.inverted
        : AppColors.primaryColor.inverted.withValues(alpha: 0.85);

    final iconColor = highlight
        ? AppColors.primaryColor.inverted
        : AppColors.tertiaryColor;

    final double itemPaddingV = screenHeight * 0.012;
    // Reduce horizontal padding slightly to prevent overflow jitter
    final double itemPaddingH = referenceWidth * 0.04;

    final double baseIconSize = referenceWidth * 0.06;
    final double iconSize = reduceIconSize ? baseIconSize * 0.85 : baseIconSize;

    final double fontSize = referenceWidth * 0.04;
    final double borderRadius = referenceWidth * 0.03;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.secondaryColor.withValues(alpha: 0.5),
        highlightColor: AppColors.secondaryColor.withValues(alpha: 0.3),
        child: Container(
          width: referenceWidth * 0.9, // Constrain width explicitly
          padding: EdgeInsets.symmetric(vertical: itemPaddingV, horizontal: itemPaddingH),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: highlight ? AppColors.secondaryColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed container for Icon to prevent alignment shifts
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
              // Use Flexible instead of Expanded to allow natural text sizing without forcing recalculation
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
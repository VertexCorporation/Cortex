import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


class AttachmentSheetButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final double? height;

  const AttachmentSheetButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // SCREEN METRICS
    final screenWidth = MediaQuery.sizeOf(context).width;

    // DYNAMIC DIMENSIONS
    final double itemWidth = (screenWidth * 0.85) / 3;
    final double itemHeight = height ?? itemWidth;

    final double iconSize = itemWidth * 0.30; // Slightly compact icon
    final double borderRadius = screenWidth * 0.04; // Responsive radius
    final double fontSize = screenWidth * 0.030; // Adjusted font size
    final double gapHeight = 6.0; // Fixed gap between icon and text

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: itemWidth,
          height: itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor.inverted,
                  BlendMode.srcIn,
                ),
              ),

              SizedBox(height: gapHeight),

              // Text
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


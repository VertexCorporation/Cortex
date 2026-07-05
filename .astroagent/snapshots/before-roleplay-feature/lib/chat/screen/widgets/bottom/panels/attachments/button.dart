// lib/chat/screen/widgets/bottom/panels/attachments/button.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../app.dart';

class AttachmentSheetButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const AttachmentSheetButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // SCREEN METRICS
    
    final screenWidth = MediaQuery.sizeOf(context).width;

    // DYNAMIC DIMENSIONS
    // 3 items per row logic
    final double itemWidth = (screenWidth * 0.85) / 3;
    // Made height equal to width (Square) to fit icon and text comfortably inside
    final double itemHeight = itemWidth;

    final double iconSize = itemWidth * 0.35; // Icon size balanced
    final double borderRadius = screenWidth * 0.04; // Responsive radius
    final double fontSize = screenWidth *
        0.032; // Font size adjusted for internal fit
    final double gapHeight = 8.0; // Fixed gap between icon and text

    return Material(
      color: AppColors.background, // Requested Background
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.border, // Requested Border
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              // Text (Inside the button now)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
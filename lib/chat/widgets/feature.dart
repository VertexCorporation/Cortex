// lib/chat/screen/unselected/widgets/feature.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';

/// A reusable, styled card for feature buttons on the welcome screen.
///
/// This is a "dumb" widget that receives all its data and behavior
/// via its constructor. It is responsible solely for its own presentation.
class FeatureCard extends StatelessWidget {
  final String text;
  final String iconPath;
  final double height;
  final VoidCallback onTap;
  final bool isSmall;

  const FeatureCard({
    super.key,
    required this.text,
    required this.iconPath,
    required this.height,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(24);
    final iconSize = screenWidth * 0.06;

    return Material(
      color: AppColors.background,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
        child: Container(
          height: height,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withValues(alpha: 0.8), BlendMode.srcIn),
                  ),
                  Icon(Icons.arrow_forward, color: AppColors.primaryColor.inverted, size: screenWidth * 0.05),
                ],
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: isSmall ? screenWidth * 0.04 : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor.inverted,
                        height: 1.2,
                      ),
                    ),
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
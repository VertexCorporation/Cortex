import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';

class FeaturesSheetGridItem extends StatelessWidget {
  final String title;
  final String? description;
  final String iconPath;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isSelected;

  const FeaturesSheetGridItem({
    super.key,
    required this.title,
    this.description,
    required this.iconPath,
    this.onTap,
    this.isDisabled = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double borderRadius = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.07;
    final double titleSize = screenWidth * 0.032;
    final double descSize = screenWidth * 0.026;

    final Color normalBg = AppColors.background;
    final Color normalFg = AppColors.primaryColor.inverted;

    final Color targetBg = isSelected ? normalFg : normalBg;
    final Color targetFg = isSelected ? normalBg : normalFg;
    final Color targetBorder = isSelected ? Colors.transparent : AppColors.border;
    final double opacity = isDisabled ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: targetBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: targetBorder, width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isDisabled ? null : () { HapticFeedback.lightImpact(); onTap?.call(); },
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: targetFg.withValues(alpha: 0.1),
            highlightColor: targetFg.withValues(alpha: 0.05),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035, horizontal: screenWidth * 0.025),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? targetFg.withValues(alpha: 0.2)
                          : AppColors.secondaryColor.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: iconSize * 0.5,
                        height: iconSize * 0.5,
                        colorFilter: ColorFilter.mode(targetFg, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: targetFg,
                    ),
                    child: Text(title, textAlign: TextAlign.center),
                  ),
                  if (description != null) ...[
                    SizedBox(height: screenWidth * 0.008),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: descSize,
                        fontWeight: FontWeight.w400,
                        color: targetFg.withValues(alpha: 0.6),
                      ),
                      child: Text(description!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

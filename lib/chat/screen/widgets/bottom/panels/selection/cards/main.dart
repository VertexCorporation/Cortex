// lib/chat/screen/widgets/bottom/selection/cards/main.dart

import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../../../app.dart';
import '../../../../../../../overflow.dart';

class ModelCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final bool isExpanded;
  final bool showExpansionArrow;
  final VoidCallback onBodyTap;
  final VoidCallback? onArrowTap;
  final Gradient? backgroundGradient;

  const ModelCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onBodyTap,
    this.isExpanded = false,
    this.showExpansionArrow = false,
    this.onArrowTap,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isTablet = screenWidth >= 600;

    // --- DYNAMIC SIZES ---
    final double iconBoxSize = isTablet ? 48.0 : screenWidth * 0.11;
    final double borderRadius = isTablet ? 24 : screenWidth * 0.05;
    final double innerPadding = screenWidth * 0.025;
    final double gapSize = screenWidth * 0.025;

    final double titleFontSize = isTablet ? 16.0 : screenWidth * 0.038;
    final double subTitleFontSize = isTablet ? 12.0 : screenWidth * 0.026;
    final double arrowBoxWidth = isTablet ? 50.0 : screenWidth * 0.11;
    final double arrowIconSize = isTablet ? 24.0 : screenWidth * 0.06;

    final Color cardBackgroundColor =
        isSelected ? AppColors.primaryColor.inverted : AppColors.background;

    final Color iconContentColor =
        isSelected ? AppColors.primaryColor : AppColors.primaryColor.inverted;

    final Color textColor =
        isSelected ? AppColors.primaryColor : AppColors.primaryColor.inverted;

    final Color subTextColor = isSelected
        ? AppColors.primaryColor.withValues(alpha: 0.7)
        : AppColors.tertiaryColor;

    final Color borderColor =
        isSelected ? Colors.transparent : AppColors.border;

    final Color arrowColor = isSelected
        ? AppColors.primaryColor
        : AppColors.primaryColor.inverted.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
        ),
        child: Stack(
          children: [
            if (backgroundGradient != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: backgroundGradient,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. LEFT SIDE: Main Body
                Expanded(
                  child: InkWell(
                    onTap: onBodyTap,
                    splashColor: isSelected
                        ? AppColors.primaryColor.withValues(alpha: 0.2)
                        : AppColors.primaryColor.inverted
                            .withValues(alpha: 0.1),
                    highlightColor: isSelected
                        ? AppColors.primaryColor.withValues(alpha: 0.1)
                        : AppColors.primaryColor.inverted
                            .withValues(alpha: 0.05),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: innerPadding),
                      child: Row(
                        children: [
                          // --- DYNAMIC ICON CONTAINER ---
                          Container(
                            width: iconBoxSize,
                            height: iconBoxSize,
                            padding: imagePath.endsWith('.svg')
                                ? EdgeInsets.all(iconBoxSize * 0.22)
                                : EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(borderRadius * 0.45),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: imagePath.isNotEmpty
                                ? (imagePath.endsWith('.svg')
                                    ? (imagePath.startsWith('assets')
                                        ? SvgPicture.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                            colorFilter: ColorFilter.mode(
                                              iconContentColor,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                        : (!kIsWeb
                                            ? SvgPicture.file(
                                                File(imagePath) as dynamic,
                                                fit: BoxFit.contain,
                                                colorFilter: ColorFilter.mode(
                                                  iconContentColor,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : Icon(Icons.broken_image,
                                                size: iconBoxSize * 0.6,
                                                color: iconContentColor)))
                                    : (imagePath.startsWith('assets')
                                        ? Image.asset(
                                            imagePath,
                                            fit: BoxFit.cover,
                                          )
                                        : (!kIsWeb
                                            ? Image.file(
                                                File(imagePath),
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(Icons.broken_image,
                                                size: iconBoxSize * 0.6,
                                                color: iconContentColor))))
                                : Icon(Icons.token,
                                    size: iconBoxSize * 0.6,
                                    color: iconContentColor),
                          ),

                          SizedBox(width: gapSize),

                          // Text Area
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OverflowText(
                                  text: title,
                                  scrollable: true,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                if (showExpansionArrow) ...[
                                  SizedBox(height: screenWidth * 0.005),
                                  FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      l10n.alwaysBest,
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: subTitleFontSize,
                                        fontWeight: FontWeight.normal,
                                        color: subTextColor,
                                      ),
                                      maxLines: 1,
                                    ),
                                  )
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. RIGHT SIDE: Expansion Arrow
                if (showExpansionArrow && onArrowTap != null) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onArrowTap,
                      splashColor: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.2)
                          : AppColors.primaryColor.inverted
                              .withValues(alpha: 0.1),
                      child: SizedBox(
                        width: arrowBoxWidth,
                        child: Center(
                          child: AnimatedRotation(
                            turns: isExpanded ? 0.25 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: arrowColor,
                              size: arrowIconSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

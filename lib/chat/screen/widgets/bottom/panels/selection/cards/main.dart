// lib/chat/screen/widgets/bottom/selection/cards/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../../../app.dart';

class ModelCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final bool isExpanded;
  final bool showExpansionArrow;
  final VoidCallback onBodyTap;
  final VoidCallback? onArrowTap;

  const ModelCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onBodyTap,
    this.isExpanded = false,
    this.showExpansionArrow = false,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isTablet = MediaQuery
        .of(context)
        .size
        .width >= 600;
    final double borderRadius = isTablet ? 24 : 20;

    // --- Visual State Colors ---
    final Color backgroundColor = isSelected
        ? AppColors.primaryColor.inverted
        : AppColors.background;

    final Color textColor = isSelected
        ? AppColors.primaryColor
        : AppColors.primaryColor.inverted;

    final Color subTextColor = isSelected
        ? AppColors.primaryColor.withValues(alpha: 0.7)
        : AppColors.tertiaryColor;

    final Color borderColor = isSelected
        ? Colors.transparent
        : AppColors.border;

    final Color arrowColor = isSelected
        ? AppColors.primaryColor
        : AppColors.primaryColor.inverted.withValues(alpha: 0.6);

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. LEFT SIDE: Main Body (Selects Default)
          Expanded(
            child: InkWell(
              onTap: onBodyTap,
              splashColor: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.2)
                  : AppColors.primaryColor.inverted.withValues(alpha: 0.1),
              highlightColor: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : AppColors.primaryColor.inverted.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    // Icon/Image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.quaternaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imagePath.isNotEmpty
                          ? (imagePath.startsWith('assets')
                          ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        cacheWidth: 90,
                      )
                          : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        cacheWidth: 90,
                      ))
                          : Icon(Icons.token, color: AppColors.tertiaryColor),
                    ),
                    const SizedBox(width: 10),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (showExpansionArrow) ...[
                            const SizedBox(height: 1),
                            FittedBox(
                              child: Text(
                                l10n.alwaysBest,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: subTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

          // 2. RIGHT SIDE: Expansion Arrow (Only if requested)
          if (showExpansionArrow && onArrowTap != null) ...[

            // Arrow Area
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onArrowTap,
                splashColor: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.2)
                    : AppColors.primaryColor.inverted.withValues(alpha: 0.1),
                child: SizedBox(
                  width: 44,
                  child: Center(
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: arrowColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
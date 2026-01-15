// lib/chat/screen/widgets/bottom/selection/cards/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../../app.dart';

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

    // Dynamic styling based on screen width
    final bool isTablet = MediaQuery
        .of(context)
        .size
        .width >= 600;
    final double borderRadius = isTablet ? 24 : 20;

    // Define colors once
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

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. MAIN BODY
          Positioned.fill(
            child: InkWell(
              onTap: onBodyTap,
              splashColor: AppColors.primaryColor.withValues(alpha: 0.15),
              highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Icon/Image
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.quaternaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imagePath.isNotEmpty
                          ? (imagePath.startsWith('assets')
                          ? Image.asset(imagePath, fit: BoxFit.cover)
                          : Image.file(File(imagePath), fit: BoxFit.cover))
                          : Icon(Icons.token, color: AppColors.tertiaryColor),
                    ),
                    const SizedBox(width: 12),
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (showExpansionArrow) ...[
                            const SizedBox(height: 2),
                            Text(
                              l10n.alwaysBest,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: subTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Spacer
                    if (showExpansionArrow) const SizedBox(width: 32),
                  ],
                ),
              ),
            ),
          ),

          // 2. EXPANSION ARROW
          if (showExpansionArrow && onArrowTap != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 48,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onArrowTap,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(borderRadius),
                    bottomRight: Radius.circular(borderRadius),
                  ),
                  splashColor: AppColors.primaryColor.withValues(alpha: 0.2),
                  child: Center(
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: textColor.withValues(alpha: 0.6),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
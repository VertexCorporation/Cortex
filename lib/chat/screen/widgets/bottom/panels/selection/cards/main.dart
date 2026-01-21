// lib/chat/screen/widgets/bottom/selection/cards/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:flutter_svg/svg.dart';
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
    final bool isTablet = MediaQuery
        .of(context)
        .size
        .width >= 600;
    final double borderRadius = isTablet ? 24 : 20;

    // --- Visual State Colors ---
    final Color backgroundColor =
    isSelected ? AppColors.primaryColor.inverted : AppColors.background;

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
          color: backgroundColor, // Base color
          gradient: backgroundGradient, // Overlay gradient
        ),
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
                          color: imagePath.endsWith('.svg')
                              ? Colors.transparent
                              : AppColors.quaternaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePath.isNotEmpty
                            ? (imagePath.endsWith('.svg')
                            ? (imagePath.startsWith('assets')
                            ? SvgPicture.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          colorFilter: isSelected
                              ? ColorFilter.mode(
                              AppColors.primaryColor,
                              BlendMode.srcIn)
                              : null,
                        )
                            : SvgPicture.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          colorFilter: isSelected
                              ? ColorFilter.mode(
                              AppColors.primaryColor.inverted,
                              BlendMode.srcIn)
                              : null,
                        ))
                            : (imagePath.startsWith('assets')
                            ? Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          cacheWidth: 90,
                        )
                            : Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          cacheWidth: 90,
                        )))
                            : Icon(Icons.token, color: AppColors.tertiaryColor),
                      ),
                      const SizedBox(width: 10),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ScrollableText(
                              text: title,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
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
      ),
    );
  }
}

class _ScrollableText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _ScrollableText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )
          ..layout(maxWidth: double.infinity);

        final bool shouldScroll = textPainter.width > constraints.maxWidth;

        if (!shouldScroll) {
          return Text(
            text,
            style: style,
            softWrap: false,
            overflow: TextOverflow.visible,
            maxLines: 1,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Text(
              text,
              style: style,
              softWrap: false,
              overflow: TextOverflow.visible,
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }
}

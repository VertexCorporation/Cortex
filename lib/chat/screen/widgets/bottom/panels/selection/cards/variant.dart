// lib/chat/screen/widgets/bottom/selection/cards/variant.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../../../app.dart';
import '../../../../../../../theme.dart';

class ModelVariantCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isPremium;
  final VoidCallback onTap;

  const ModelVariantCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    // Constants
    final double fontSize = isTablet ? 14 : 13;
    final double borderRadius = isTablet ? 18 : 16;

    // Colors
    final Color bgColor = isSelected
        ? AppColors.primaryColor.inverted
        : AppColors.background;
    final Color textColor = isSelected
        ? AppColors.primaryColor
        : AppColors.primaryColor.inverted;
    final Color borderColor = isSelected
        ? Colors.transparent
        : AppColors.border;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: isSelected
            ? AppColors.primaryColor.withValues(alpha: 0.2)
            : AppColors.primaryColor.inverted.withValues(alpha: 0.15),
        highlightColor: isSelected
            ? AppColors.primaryColor.withValues(alpha: 0.1)
            : AppColors.primaryColor.inverted.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _ScrollableText(
                    text: title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight
                          .normal,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              if (isPremium)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: SvgPicture.asset(
                    'assets/icons/sparkle.svg',
                    width: 12,
                    height: 12,
                    colorFilter: ColorFilter.mode(
                        textColor,
                        BlendMode.srcIn
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
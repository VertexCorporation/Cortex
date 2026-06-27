// lib/chat/widgets/options/item.dart

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Defines the layout metrics for an option item, calculated as factors of
/// the screen width for a responsive UI.
class _UIFactors {
  static const double iconSizeFactor = 0.055;
  static const double defaultFontSizeFactor = 0.035;
  static const double iconTextSpacingFactor = 0.025;
  static const double optionMinHeightFactor = 0.06;
}

/// A stateless widget that renders a single, tappable option item within the
/// options panel.
///
/// This widget is responsible for the consistent styling of all options,
/// including the icon, label, and tap feedback. It features an intelligent
/// text handling mechanism:
///
/// - If the label fits within 4 lines, it is displayed as a standard multi-line text.
/// - If the label exceeds 4 lines, it is rendered as a single, horizontally
///   scrollable line, allowing the user to read the full text without cluttering
///   the UI.
class OptionPanelItem extends StatelessWidget {
  /// The text label to display for the option.
  final String label;

  /// The asset path for the SVG icon.
  final String iconAsset;

  /// The callback function to execute when the item is tapped.
  final VoidCallback onTap;

  /// An optional override for the icon's size.
  final double? iconSizeOverride;

  /// An optional horizontal and vertical offset for fine-tuning the icon's position.
  final Offset iconOffset;

  /// Custom padding for the item. If null, default padding is used.
  final EdgeInsets? padding;

  /// A flag to visually dim the item and disable its tap functionality.
  final bool isDisabled;

  /// The border radius to apply to the InkWell's ripple effect, matching the panel's corners.
  final double borderRadius;

  const OptionPanelItem({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onTap,
    this.iconSizeOverride,
    this.iconOffset = Offset.zero,
    this.padding,
    this.isDisabled = false,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Define layout values based on screen size for responsiveness.
    final double iconSize = iconSizeOverride ?? screenWidth * _UIFactors.iconSizeFactor;
    final double defaultHorizontalPadding = screenWidth * 0.04;
    final double defaultVerticalPadding = screenWidth * 0.02;
    final double iconTextSpacing = screenWidth * _UIFactors.iconTextSpacingFactor;
    final double fontSize = screenWidth * _UIFactors.defaultFontSizeFactor;
    final double minHeight = screenHeight * _UIFactors.optionMinHeightFactor;

    final EdgeInsets effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: defaultHorizontalPadding,
          vertical: defaultVerticalPadding,
        );

    final textStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: fontSize,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.primaryColor.inverted.withValues(alpha:0.1),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha:0.05),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: effectivePadding,
          alignment: Alignment.centerLeft,
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Transform.translate(
              offset: iconOffset,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconAsset,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted,
                      BlendMode.srcIn,
                    ),
                    width: iconSize,
                    height: iconSize,
                  ),
                  SizedBox(width: iconTextSpacing),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Use a TextPainter to efficiently measure if the text will
                        // overflow the available space when limited to 4 lines.
                        final painter = TextPainter(
                          text: TextSpan(text: label, style: textStyle),
                          maxLines: 4,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);

                        // If the text exceeds the 4-line limit, render it in a
                        // horizontally scrollable view for a clean UI.
                        if (painter.didExceedMaxLines) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              label,
                              style: textStyle,
                              maxLines: 1,      // Render as a single line to enable horizontal scrolling.
                              softWrap: false,  // Prevent the text from wrapping to the next line.
                              overflow: TextOverflow.visible, // Allow the text to render beyond the visible bounds.
                            ),
                          );
                        } else {
                          // Otherwise, if the text fits, render the standard
                          // multi-line Text widget.
                          return Text(
                            label,
                            style: textStyle,
                            maxLines: 4,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis, // Fallback for edge cases.
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
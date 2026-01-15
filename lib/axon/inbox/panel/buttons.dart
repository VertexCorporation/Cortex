// lib/inbox/widgets/tiles/actions/buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A styled button for use inside the [ActionPanel].
///
/// This is a stateless and highly configurable widget that displays an optional
/// leading icon and a text label. It is designed to be a menu item in a pop-up panel.
class ActionPanelButton extends StatelessWidget {
  /// The asset path for the SVG icon to be displayed. If null, no icon is shown.
  final String? iconAsset;

  /// The color to apply to the icon.
  final Color iconColor;

  /// The text label for the button.
  final String text;

  /// The color for the text label.
  final Color textColor;

  /// The callback function that is executed when the button is pressed.
  final VoidCallback onPressed;

  const ActionPanelButton({
    super.key,
    this.iconAsset,
    required this.iconColor,
    required this.text,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Define a consistent container size for the icon to ensure all buttons have the same alignment.
    final double iconContainerSize = screenWidth * 0.05;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        // Use the button's foregroundColor property for the ripple effect.
        foregroundColor: textColor.withValues(alpha:0.1),
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        // Ensure the button has a minimum height for a good tap target size.
        minimumSize: Size(0, screenWidth * 0.1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // Align content to the start (left).
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Subtle rounded corners for the ripple
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // The row should only be as wide as its content.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Only build the icon container if an icon asset is provided.
          if (iconAsset != null)
            SizedBox(
              width: iconContainerSize,
              height: iconContainerSize,
              child: Center(
                child: SvgPicture.asset(
                  iconAsset!,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  // The icon itself can be slightly smaller than its container for better visual spacing.
                  width: iconContainerSize * 0.9,
                  height: iconContainerSize * 0.9,
                ),
              ),
            ),
          SizedBox(width: screenWidth * 0.03),
          // Use Flexible to ensure the text wraps if it's too long, preventing overflow.
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500, // Medium weight for clarity
              ),
            ),
          ),
        ],
      ),
    );
  }
}
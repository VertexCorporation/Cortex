// settings/skeleton.dart

import 'package:cortex/theme.dart'; // For AppColors
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // For Shimmer effect

/// A widget that displays a skeleton loading UI for the settings screen.
///
/// This is shown while the actual user data is being fetched.
class SkeletonLoader extends StatelessWidget { // Renamed to SkeletonLoaderSection for consistency
  const SkeletonLoader({Key? key}) : super(key: key);

  /// Builds a circular skeleton placeholder.
  Widget _buildCircle(BuildContext context, double size) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase, // Placeholder color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Builds a rectangular skeleton placeholder for a section of content.
  Widget _buildSkeletonContent(
      BuildContext context, {
        required double width,
        required double height,
        double radius = 8.0,
      }) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase, // Placeholder color
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// Builds a skeleton placeholder for a badge.
  Widget _buildSkeletonBadge(BuildContext context, double iconSize, double textWidth, double textHeight) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: iconSize * 0.6, // Proportional padding
          vertical: iconSize * 0.3,   // Proportional padding
        ),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase, // Placeholder color
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Important for Row to not expand unnecessarily
          children: [
            _buildSkeletonContent( // For the icon part of the badge
              context,
              width: iconSize,
              height: iconSize,
              radius: iconSize / 2, // Circular icon
            ),
            SizedBox(width: iconSize * 0.4), // Space between icon and text
            _buildSkeletonContent( // For the text part of the badge
              context,
              width: textWidth,
              height: textHeight,
              radius: textHeight / 2, // Rounded text placeholder
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a skeleton placeholder for a button.
  Widget _buildSkeletonButton(BuildContext context, double height, {double? width}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width ?? screenWidth * 0.92, // Default to almost full width considering ListView padding
        height: height,
        margin: EdgeInsets.symmetric(vertical: height * 0.1), // Consistent margin with actual buttons
        decoration: BoxDecoration(
          color: AppColors.shimmerBase, // Placeholder color
          borderRadius: BorderRadius.circular(10.0), // Match actual button border radius
        ),
      ),
    );
  }

  /// Builds a skeleton placeholder for a settings item (like those in GeneralSettingsSection).
  Widget _buildSkeletonSettingsItem(
      BuildContext context, {
        required double iconSize,
        required double textWidthRatio, // Ratio of screen width for text
        required double textHeight,
        required double containerHeight, // Total height of the item row
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04; // Consistent with actual items
    final arrowSize = iconSize * 0.8; // Proportional arrow size

    return Padding(
      padding: const EdgeInsets.only(bottom: 0.5), // Mimic divider height
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          height: containerHeight,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: AppColors.shimmerBase, // Placeholder color
            // No specific border radius here if it's part of a ClipRRect group
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildSkeletonContent(context, width: iconSize, height: iconSize, radius: iconSize / 2), // Icon
                  SizedBox(width: horizontalPadding), // Space between icon and text
                  _buildSkeletonContent(context, width: screenWidth * textWidthRatio, height: textHeight, radius: 4), // Text
                ],
              ),
              _buildSkeletonContent(context, width: arrowSize, height: arrowSize, radius: 4), // Arrow
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define common dimensions for skeleton elements to match actual UI
    final double avatarSize = screenWidth * 0.25;
    final double titleHeight = screenHeight * 0.028; // Adjusted for visual balance
    final double descriptionHeight = screenHeight * 0.018; // Adjusted
    final double buttonHeight = screenHeight * 0.072;
    final double settingsItemHeight = screenHeight * 0.062; // Height of each settings row

    // Spacing values
    final double smallSpacing = screenHeight * 0.01;
    final double medSpacing = screenHeight * 0.02;
    final double largeSpacing = screenHeight * 0.035;

    return ListView(
      key: const ValueKey('skeletonLoader'), // Unique key for AnimatedSwitcher
      padding: EdgeInsets.all(screenWidth * 0.04), // Match padding of the main content
      children: [
        // Profile Header Skeleton
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCircle(context, avatarSize),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: avatarSize * 0.1),
                  _buildSkeletonContent(context, width: screenWidth * 0.5, height: titleHeight * 1.2), // Display Name
                  SizedBox(height: smallSpacing * 0.7),
                  _buildSkeletonContent(context, width: screenWidth * 0.52, height: descriptionHeight * 1.4), // Email
                  SizedBox(height: medSpacing * 0.4),
                  Row( // Badges
                    children: [
                      _buildSkeletonBadge(context, screenWidth * 0.045, screenWidth * 0.12, descriptionHeight * 0.9),
                      SizedBox(width: screenWidth * 0.02),
                      _buildSkeletonBadge(context, screenWidth * 0.045, screenWidth * 0.1, descriptionHeight * 0.9),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: largeSpacing * 0.9), // Space after header

        // User Section Skeleton
        _buildSkeletonContent(context, width: screenWidth * 0.2, height: titleHeight * 1.5), // Section Title
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight), // Section Description
        SizedBox(height: medSpacing * 0.52),
        _buildSkeletonButton(context, buttonHeight), // Edit Profile
        _buildSkeletonButton(context, buttonHeight), // Change Password
        _buildSkeletonButton(context, buttonHeight), // Logout
        SizedBox(height: largeSpacing * 0.6),

        // Language Section Skeleton
        _buildSkeletonContent(context, width: screenWidth * 0.4, height: titleHeight * 1.5), // Section Title
        SizedBox(height: smallSpacing * 0.1),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.1),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.1),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight), // Section Description
        _buildSkeletonButton(context, buttonHeight), // Language Button
        SizedBox(height: largeSpacing * 0.5),

        // Theme Section Skeleton
        _buildSkeletonContent(context, width: screenWidth * 0.4, height: titleHeight * 1.5), // Section Title
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight), // Section Description
        SizedBox(height: medSpacing),
        _buildSkeletonButton(context, buttonHeight), // Theme Button
        SizedBox(height: largeSpacing * 0.5),

        // General Settings Section Skeleton
        _buildSkeletonContent(context, width: screenWidth * 0.32, height: titleHeight * 1.5), // Section Title
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight), // Section Description
        SizedBox(height: medSpacing),
        ClipRRect( // To match the rounded corners of the actual settings group
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            children: List.generate(6, (index) => _buildSkeletonSettingsItem(
              context,
              iconSize: screenWidth * 0.05,
              textWidthRatio: 0.35 + (index % 3 * 0.05), // Varying text widths for realism
              textHeight: descriptionHeight * 1.1, // Slightly taller text for settings
              containerHeight: settingsItemHeight,
            )),
          ),
        ),
        SizedBox(height: largeSpacing * 0.5),

        // Delete Section Skeleton
        _buildSkeletonContent(context, width: screenWidth * 0.32, height: titleHeight * 1.5), // Section Title
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context, width: screenWidth * 0.7, height: descriptionHeight),// Section Description
        SizedBox(height: medSpacing),
        _buildSkeletonButton(context, buttonHeight, width: screenWidth * 0.92), // Delete Conversations
        _buildSkeletonButton(context, buttonHeight, width: screenWidth * 0.92), // Delete Account
        SizedBox(height: largeSpacing),
      ],
    );
  }
}
// lib/settings/skeleton.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  Widget _buildCircle(BuildContext context, double size) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

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
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildSkeletonBadge(BuildContext context, double iconSize,
      double textWidth, double textHeight) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: iconSize * 0.6,
          vertical: iconSize * 0.3,
        ),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSkeletonContent(
              context,
              width: iconSize,
              height: iconSize,
              radius: iconSize / 2,
            ),
            SizedBox(width: iconSize * 0.4),
            _buildSkeletonContent(
              context,
              width: textWidth,
              height: textHeight,
              radius: textHeight / 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonButton(BuildContext context, double height,
      {double? width}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width ?? screenWidth * 0.92,
        height: height,
        margin: EdgeInsets.symmetric(vertical: height * 0.1),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildSkeletonSettingsItem(
    BuildContext context, {
    required double iconSize,
    required double textWidthRatio,
    required double textHeight,
    required double containerHeight,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04;
    final arrowSize = iconSize * 0.8;

    return Padding(
      padding: const EdgeInsets.only(bottom: 0.5),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          height: containerHeight,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildSkeletonContent(context,
                      width: iconSize, height: iconSize, radius: iconSize / 2),
                  SizedBox(width: horizontalPadding),
                  _buildSkeletonContent(context,
                      width: screenWidth * textWidthRatio,
                      height: textHeight,
                      radius: 4),
                ],
              ),
              _buildSkeletonContent(context,
                  width: arrowSize, height: arrowSize, radius: 4),
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

    final double topHeight = MediaQuery.of(context).padding.top;
    final double horizontalPadding = screenWidth * 0.04;

    final double avatarSize = screenWidth * 0.25;
    final double titleHeight = screenHeight * 0.028;
    final double descriptionHeight = screenHeight * 0.018;
    final double buttonHeight = screenHeight * 0.072;
    final double settingsItemHeight = screenHeight * 0.062;

    final double smallSpacing = screenHeight * 0.01;
    final double medSpacing = screenHeight * 0.02;
    final double largeSpacing = screenHeight * 0.035;

    return ListView(
      key: const ValueKey('skeletonLoader'),
      padding: EdgeInsets.only(
        top: topHeight,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: horizontalPadding,
      ),
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
                  _buildSkeletonContent(context,
                      width: screenWidth * 0.5, height: titleHeight * 1.2),
                  SizedBox(height: smallSpacing * 0.7),
                  _buildSkeletonContent(context,
                      width: screenWidth * 0.52,
                      height: descriptionHeight * 1.4),
                  SizedBox(height: medSpacing * 0.4),
                  Row(
                    children: [
                      _buildSkeletonBadge(context, screenWidth * 0.045,
                          screenWidth * 0.12, descriptionHeight * 0.9),
                      SizedBox(width: screenWidth * 0.02),
                      _buildSkeletonBadge(context, screenWidth * 0.045,
                          screenWidth * 0.1, descriptionHeight * 0.9),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: largeSpacing * 0.9),

        // User Section Skeleton
        _buildSkeletonContent(context,
            width: screenWidth * 0.2, height: titleHeight * 1.5),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: medSpacing * 0.52),
        _buildSkeletonButton(context, buttonHeight),
        _buildSkeletonButton(context, buttonHeight),
        _buildSkeletonButton(context, buttonHeight),
        _buildSkeletonButton(context, buttonHeight),
        SizedBox(height: largeSpacing * 0.6),

        // Language Section Skeleton
        _buildSkeletonContent(context,
            width: screenWidth * 0.4, height: titleHeight * 1.5),
        SizedBox(height: smallSpacing * 0.1),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.1),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.1),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        _buildSkeletonButton(context, buttonHeight),
        SizedBox(height: largeSpacing * 0.5),

        // Theme Section Skeleton
        _buildSkeletonContent(context,
            width: screenWidth * 0.4, height: titleHeight * 1.5),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: medSpacing),
        _buildSkeletonButton(context, buttonHeight),
        SizedBox(height: largeSpacing * 0.5),

        // General Settings Section
        _buildSkeletonContent(context,
            width: screenWidth * 0.32, height: titleHeight * 1.5),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: medSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            children: List.generate(
                6,
                (index) => _buildSkeletonSettingsItem(
                      context,
                      iconSize: screenWidth * 0.05,
                      textWidthRatio: 0.35 + (index % 3 * 0.05),
                      textHeight: descriptionHeight * 1.1,
                      containerHeight: settingsItemHeight,
                    )),
          ),
        ),
        SizedBox(height: largeSpacing * 0.5),

        // Delete Section
        _buildSkeletonContent(context,
            width: screenWidth * 0.32, height: titleHeight * 1.5),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: smallSpacing * 0.2),
        _buildSkeletonContent(context,
            width: screenWidth * 0.7, height: descriptionHeight),
        SizedBox(height: medSpacing),
        _buildSkeletonButton(context, buttonHeight, width: screenWidth * 0.92),
        _buildSkeletonButton(context, buttonHeight, width: screenWidth * 0.92),
        SizedBox(height: largeSpacing),
      ],
    );
  }
}

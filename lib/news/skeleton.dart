// lib/news/skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../theme.dart';

/// A generic, reusable shimmer placeholder widget.
///
/// It can be used in any part of the app where a loading state
/// needs to be indicated with a shimmering effect.
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border.withValues(alpha: 0.5),
      highlightColor: AppColors.border.withValues(alpha: 0.2),
      child: Container(color: AppColors.border),
    );
  }
}

/// A widget that displays a list of shimmering news card skeletons.
///
/// This is shown to the user while the actual news articles are being fetched.
class ShimmerNewsList extends StatelessWidget {
  const ShimmerNewsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Typically shows 2-3 skeleton cards to indicate a list is loading.
    return Column(
      children: List.generate(2, (index) => const ShimmerNewsCard()),
    );
  }
}

/// A skeleton widget that mimics the layout of a [NewsArticleCard].
///
/// Its dimensions and structure are based on screen-relative values to ensure
/// a perfect match with the real card, providing a seamless loading transition.
class ShimmerNewsCard extends StatelessWidget {
  const ShimmerNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the same screen-relative values as the real card for consistency.
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06;
    final double basePadding = screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.only(bottom: basePadding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(cardRadius - 1)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Shimmer.fromColors(
                  baseColor: AppColors.border,
                  highlightColor: AppColors.background,
                  child: Container(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(basePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(context, 0.8, screenWidth * 0.045),
                  // Title
                  SizedBox(height: screenWidth * 0.02),
                  _buildShimmerLine(context, 0.4, screenWidth * 0.032),
                  // Date
                  SizedBox(height: basePadding),
                  _buildShimmerLine(context, 1.0, screenWidth * 0.038),
                  // Summary line 1
                  SizedBox(height: screenWidth * 0.015),
                  _buildShimmerLine(context, 0.7, screenWidth * 0.038),
                  // Summary line 2
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to build a single shimmering line with dynamic width and height.
  Widget _buildShimmerLine(
      BuildContext context, double widthFactor, double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.background,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

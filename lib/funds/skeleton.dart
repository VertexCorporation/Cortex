// funds/skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/theme.dart';

class FundsSkeletonLoader extends StatelessWidget {
  const FundsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final double topPadding = MediaQuery.of(context).padding.top;

    final double contentTopPadding = topPadding + screenHeight * 0.01;

    final double contentBottomPadding = screenHeight * 0.015;
    final double bottomPadding =
        screenHeight * 0.02 + MediaQuery.of(context).padding.bottom;

    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);
    final badgeHeight = 36.0 * scale;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: AppColors.background,
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          children: [
            // --- 1. HEADER (DISCOUNT BANNER SKELETON) ---
            Padding(
              padding: EdgeInsets.only(
                  top: contentTopPadding, bottom: contentBottomPadding),
              child: Center(
                child: Container(
                  width: screenWidth * 0.45,
                  height: badgeHeight,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(36.0 * scale),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(1, (_) => _buildSkeletonPage(context)),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.06,
                  screenHeight * 0.01, screenWidth * 0.06, bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (index) => Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01),
                              width: index == 1
                                  ? screenWidth * 0.06
                                  : screenWidth * 0.022,
                              height: screenWidth * 0.022,
                              decoration: BoxDecoration(
                                color: AppColors.shimmerBase,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.022),
                              ),
                            )),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Main Button
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.007),

                  // Restore Text Placeholder
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: screenWidth * 0.35,
                    height: screenHeight * 0.015,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Terms Text Placeholder
                  SizedBox(height: screenHeight * 0.007),
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonPage(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final double horizontalPadding = screenWidth * 0.06;
    final double verticalSpacingSmall = screenHeight * 0.005;
    final double verticalSpacingMedium = screenHeight * 0.01;
    final double verticalSpacingLarge = screenHeight * 0.03;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            // --- TITLE ---
            Container(
              width: screenWidth * 0.6,
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: verticalSpacingSmall),

            // --- DESCRIPTION ---
            Container(
              width: screenWidth * 0.8,
              height: screenWidth * 0.032 * 1.2,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            SizedBox(height: verticalSpacingLarge),

            // --- ANNUAL OPTION ---
            _skeletonOptionBox(context),

            SizedBox(height: verticalSpacingMedium),

            // --- MONTHLY OPTION ---
            _skeletonOptionBox(context),

            SizedBox(height: verticalSpacingLarge),

            // --- BENEFITS LIST ---
            _skeletonBenefitsGrid(context),

            SizedBox(height: verticalSpacingLarge),
          ],
        ),
      ),
    );
  }

  Widget _skeletonOptionBox(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final estimatedHeight = (screenHeight * 0.03) +
        (screenWidth * 0.085) +
        (screenHeight * 0.006) +
        30;

    return Container(
      width: double.infinity,
      height: estimatedHeight,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.shimmerBase, width: 1.0),
      ),
    );
  }

  Widget _skeletonBenefitsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: screenWidth * 0.012,
      runSpacing: screenWidth * 0.057,
      children: List.generate(6, (index) {
        return SizedBox(
          width:
              (screenWidth - (screenWidth * 0.06 * 2) - (screenWidth * 0.02)) /
                  2,
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.057,
                height: screenWidth * 0.057,
                decoration: BoxDecoration(
                    color: AppColors.shimmerBase, shape: BoxShape.circle),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Container(
                  height: screenWidth * 0.034,
                  decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(4)),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

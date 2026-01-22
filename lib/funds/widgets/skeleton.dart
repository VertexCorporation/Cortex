// funds/skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/theme.dart';

/// A standalone skeleton loader widget extracted from FundsScreen.
class FundsSkeletonLoader extends StatelessWidget {
  const FundsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenHeight * 0.03,
          ),
          child: Column(
            children: [
              // Badge Skeleton (Pill)
              Container(
                width: screenWidth * 0.45,
                height: 36.0 * (screenWidth / 375.0).clamp(0.85, 1.2),
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(36.0),
                ),
              ),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      List.generate(1, (_) => _buildSkeletonPage(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonPage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.022),
          _line(screenWidth * 0.65, screenHeight * 0.05, screenWidth),
          SizedBox(height: screenHeight * 0.01),
          _line(screenWidth * 0.75, screenHeight * 0.025, screenWidth),
          SizedBox(height: screenHeight * 0.0016),
          _line(screenWidth * 0.65, screenHeight * 0.025, screenWidth),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: screenWidth * 0.25,
            height: screenWidth * 0.25,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          _block(screenWidth, screenHeight * 0.1, screenWidth),
          SizedBox(height: screenHeight * 0.009),
          _block(screenWidth, screenHeight * 0.1, screenWidth),
          SizedBox(height: screenHeight * 0.024),
          _wrapChecks(screenWidth),
          SizedBox(height: screenHeight * 0.027),
          _dots(screenWidth),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.07,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Column(
            children: List.generate(
                5,
                (index) => Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.0012),
                      child: Container(
                        width:
                            index == 4 ? screenWidth * 0.6 : screenWidth * 0.9,
                        height: screenHeight * 0.014,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerBase,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _line(double width, double height, double screenWidth) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(screenWidth * 0.015),
        ),
      );

  Widget _block(double screenWidth, double height, double screenWidthParam) =>
      Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidthParam * 0.005),
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(screenWidthParam * 0.035),
        ),
      );

  Widget _wrapChecks(double screenWidth) => Wrap(
        spacing: screenWidth * 0.012,
        runSpacing: screenWidth * 0.012,
        children: List.generate(
            6,
            (index) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Container(
                      width: ((screenWidth -
                                  2 * screenWidth * 0.04 -
                                  screenWidth * 0.024) /
                              2) -
                          (screenWidth * 0.05 + screenWidth * 0.01),
                      height: screenWidth * 0.03,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                  ],
                )),
      );

  Widget _dots(double screenWidth) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            4,
            (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
                  width: screenWidth * 0.032,
                  height: screenWidth * 0.032,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    shape: BoxShape.circle,
                  ),
                )),
      );
}

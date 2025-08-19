import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// A reusable skeleton (shimmer) screen widget for models loading states.
class SkeletonScreen extends StatelessWidget {
  /// Optional key to distinguish different shimmer instances.
  final Key? key;

  const SkeletonScreen({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Categories to display shimmering headers
    final List<String> shimmerCategories = [
      localizations.localModels,
      localizations.serverSideModels,
      localizations.roleModels,
      localizations.myModels,
    ];

    // Total list items: one search bar placeholder + 4 items per category
    final int totalItems = 1 + shimmerCategories.length * 4;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      key: key ?? const ValueKey('skeleton'),
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Search bar placeholder
            return Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
              child: Container(
                width: double.infinity,
                height: screenWidth * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
              ),
            );
          }

          final int adjustedIndex = index - 1;
          final int categoryIndex = adjustedIndex ~/ 4;
          final int itemIndex = adjustedIndex % 4;

          if (categoryIndex >= shimmerCategories.length) {
            return const SizedBox.shrink();
          }

          if (itemIndex == 0) {
            // Category header placeholder
            return Padding(
              padding: EdgeInsets.only(
                top: screenWidth * 0.04,
                bottom: screenWidth * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ],
              ),
            );
          }

          // Model tile placeholder
          return Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(width: screenWidth * 0.025),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: screenWidth * 0.04,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Container(
                        width: double.infinity,
                        height: screenWidth * 0.03,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Container(
                        width: screenWidth * 0.25,
                        height: screenWidth * 0.03,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.025),
                Container(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// lib/chat/screen/widgets/bottom/selection/skeleton.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ModelSelectionSkeleton extends StatelessWidget {
  const ModelSelectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sw = mediaQuery.size.width;
    final sh = mediaQuery.size.height;

    // Layout constants (matching sheet.dart)
    final sp16 = sw * 0.04;
    final sp12 = sw * 0.03;

    // Grid calculations
    final gridWidth = sw - (2 * sp16);
    final itemWidth = (gridWidth - sp12) / 2;
    final desiredHeight = sh * 0.085;
    final childAspectRatio = itemWidth / desiredHeight;

    // Border Radius (matching ModelCard)
    final double borderRadius = sw >= 600 ? 24 : sw * 0.05;

    // Fine-tuned alignment padding
    return Padding(
      padding: EdgeInsetsGeometry.only(top: sh * 0.007),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- SECTION 1: DYNAMIC (CORTEX) ---
            _buildSeparator(sw),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: sp16),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: itemWidth,
                    height: desiredHeight,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
              ),
            ),

            // --- SECTION 2: OFFLINE MODELS (24 items) ---
            _buildSeparator(sw),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: sp16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: sp12,
                  mainAxisSpacing: sp12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    );
                  },
                  childCount: 24,
                ),
              ),
            ),

            // --- SECTION 3: ONLINE MODELS (10 items) ---
            _buildSeparator(sw),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: sp16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: sp12,
                  mainAxisSpacing: sp12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    );
                  },
                  childCount: 10,
                ),
              ),
            ),

            // Bottom Spacing
            SliverPadding(
              padding: EdgeInsets.only(bottom: sh * 0.05),
            ),
          ],
        ),
      ),
    );
  }

  // Line - Box - Line Separator
  Widget _buildSeparator(double sw) {
    final sp16 = sw * 0.04;
    final sp12 = sw * 0.03;
    final categoryHeight = sw >= 600 ? sw * 0.025 : sw * 0.038;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sp16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Container(height: 1, color: AppColors.shimmerBase),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sp12),
              child: Container(
                width: sw * 0.25,
                height: categoryHeight,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: AppColors.shimmerBase),
            ),
          ],
        ),
      ),
    );
  }
}
// skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme.dart';

/// A fixed, reusable skeleton loader—no constructor params needed.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor      = AppColors.shimmerBase;
    final highlightColor = AppColors.shimmerHighlight;
    final w              = MediaQuery.of(context).size.width;
    final h              = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: h * 0.01),
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // big title bar
            Container(
              width: w * 0.6,
              height: h * 0.04,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
            ),
            SizedBox(height: h * 0.005),
            // line 1
            Container(
              width: w * 0.9,
              height: h * 0.025,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
            ),
            SizedBox(height: h * 0.005),
            // line 2
            Container(
              width: w * 0.6,
              height: h * 0.025,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
            ),
            SizedBox(height: h * 0.005),
            // body block
            Container(
              width: double.infinity,
              height: h * 0.10,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
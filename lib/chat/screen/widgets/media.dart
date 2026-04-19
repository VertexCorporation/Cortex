// lib/chat/screen/widgets/media_shimmer.dart

import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer placeholder widget displayed while a Fal model generates media.
///
/// Shape varies by type:
/// - **Audio**: Compressed rectangle (short height, wider), left-aligned
/// - **Image**: Square with rounded corners
/// - **Video**: Square with rounded corners (same as image)
///
/// Designed to crossfade into the real content via [AnimatedSwitcher].
class MediaShimmerPlaceholder extends StatelessWidget {
  final MediaGenerationType type;

  const MediaShimmerPlaceholder({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    // Determine shape dimensions based on media type
    final double width;
    final double height;
    final double borderRadius;

    switch (type) {
      case MediaGenerationType.audio:
        // Compressed: short height, extends right, left-aligned
        width = isTablet ? screenWidth * 0.5 : screenWidth * 0.7;
        height = isTablet ? 90 : 80;
        borderRadius = 20;
        break;
      case MediaGenerationType.image:
        width = isTablet ? screenWidth * 0.3 : screenWidth * 0.4;
        height = width; // Perfect square
        borderRadius = 12;
        break;
      case MediaGenerationType.video:
        // Match video card ratio to avoid abrupt layout jump on swap.
        width = isTablet ? screenWidth * 0.3 : screenWidth * 0.4;
        height = width * 0.7;
        borderRadius = 12;
        break;
      case MediaGenerationType.none:
        return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.tertiaryColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: _buildInnerContent(type, isTablet, screenWidth),
        ),
      ),
    );
  }

  /// Builds subtle inner content hints for the shimmer placeholder.
  /// These are decorative elements that hint at what content is loading.
  Widget _buildInnerContent(
      MediaGenerationType type, bool isTablet, double screenWidth) {
    switch (type) {
      case MediaGenerationType.audio:
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 18 : 14,
          ),
          child: Row(
            children: [
              // Play button circle hint
              Container(
                width: isTablet ? 40 : 34,
                height: isTablet ? 40 : 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Waveform bars hint
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(12, (i) {
                    // Create varied heights for waveform effect
                    final heights = [
                      0.3,
                      0.5,
                      0.7,
                      0.9,
                      0.6,
                      0.8,
                      1.0,
                      0.7,
                      0.5,
                      0.8,
                      0.4,
                      0.6
                    ];
                    final h =
                        heights[i % heights.length] * (isTablet ? 36 : 30);
                    return Container(
                      width: isTablet ? 4 : 3,
                      height: h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );

      case MediaGenerationType.image:
        return Center(
          child: Container(
            width: isTablet ? 44 : 36,
            height: isTablet ? 44 : 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

      case MediaGenerationType.video:
        return Center(
          child: Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
        );

      case MediaGenerationType.none:
        return const SizedBox.shrink();
    }
  }
}

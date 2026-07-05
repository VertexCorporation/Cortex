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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;

    // Determine shape dimensions based on media type
    final double width;
    final double height;
    final double borderRadius;

    switch (type) {
      case MediaGenerationType.audio:
        width = isTablet ? screenWidth * 0.5 : screenWidth * 0.7;
        height = isTablet ? 90 : 80;
        borderRadius = 20;
        break;
      case MediaGenerationType.image:
        width = isTablet ? screenWidth * 0.4 : screenWidth * 0.65;
        height = width;
        borderRadius = 24.0;
        break;
      case MediaGenerationType.video:
        width = isTablet ? screenWidth * 0.4 : screenWidth * 0.65;
        height = width * 0.7;
        borderRadius = 24.0;
        break;
      case MediaGenerationType.none:
        return const SizedBox.shrink();
    }

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (type == MediaGenerationType.image) {
      content = Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.tertiaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Görsel oluşturuluyor",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            // Grid of dots to match the user's reference
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                  40,
                  (index) => Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor
                              .withValues(alpha: 0.2 + (index % 5) * 0.1),
                          shape: BoxShape.circle,
                        ),
                      )),
            ),
            const Spacer(),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        period: const Duration(milliseconds: 1500),
        child: content,
      ),
    );
  }
}

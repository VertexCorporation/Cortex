import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme.dart';

class SkeletonChatList extends StatelessWidget {
  const SkeletonChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return const SkeletonChatTile();
      },
    );
  }
}

class SkeletonChatTile extends StatelessWidget {
  const SkeletonChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define padding similar to ConversationTile
    final horizontalPadding = screenWidth * 0.03;
    final verticalPadding = screenHeight * 0.01;

    // Calculate container width based on padding
    final containerWidth =
        screenWidth - 2 * (horizontalPadding + screenWidth * 0.04);

    // Define height based on image size and padding
    final imageSize = screenWidth * 0.15;
    final containerHeight = imageSize + 2 * (screenHeight * 0.02);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            color: AppColors.tertiaryColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
        ),
      ),
    );
  }
}
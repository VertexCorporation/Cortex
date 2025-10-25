// lib/chat/messages/skeleton.dart

import 'dart:math';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a skeleton loading indicator for a list of chat messages.
///
/// It renders a series of shimmering placeholders with randomized widths and heights
/// to simulate the appearance of a real conversation while data is being loaded.
class MessageListSkeleton extends StatelessWidget {
  /// Creates a message list skeleton widget.
  const MessageListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final random = Random();

    // Use a ListView that cannot be scrolled by the user during loading.
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      itemCount: 20, // A fixed number of skeletons to fill the screen
      itemBuilder: (context, index) {
        // Alternate between user and bot message skeletons
        final bool isUserMessage = index % 2 == 0;
        final double height;
        final double width;

        // Generate random dimensions to make the skeleton look more natural
        if (isUserMessage) {
          height = screenHeight * (0.05 + random.nextDouble() * 0.03);
          width = screenWidth * (0.4 + random.nextDouble() * 0.3);
        } else {
          width = screenWidth * (0.7 + random.nextDouble() * 0.2);
          height = screenHeight * (0.08 + random.nextDouble() * 0.07);
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.008,
            horizontal: screenWidth * 0.04,
          ),
          child: Align(
            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBase,
              highlightColor: AppColors.shimmerHighlight,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryColor,
                  borderRadius: BorderRadius.circular(
                      isUserMessage ? (height / 2) : 12
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
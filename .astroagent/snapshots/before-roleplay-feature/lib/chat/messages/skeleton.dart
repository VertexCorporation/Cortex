// lib/chat/messages/skeleton.dart

import 'dart:math';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a skeleton loading indicator for a list of chat messages.
///
/// It renders a series of shimmering placeholders with randomized widths and heights
/// to simulate the appearance of a real conversation while data is being loaded.
class MessageListSkeleton extends StatefulWidget {
  /// Creates a message list skeleton widget.
  const MessageListSkeleton({super.key});

  @override
  State<MessageListSkeleton> createState() => _MessageListSkeletonState();
}

class _MessageListSkeletonState extends State<MessageListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late final ScrollController _scrollController;

  // PERFORMANCE: Pre-compute skeleton dimensions in initState instead of
  // creating new Random() and recalculating on every build() call.
  late final List<_SkeletonItemData> _skeletonItems;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Handles the "fade in" requirement when the skeleton first appears
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Pre-compute all skeleton item dimensions once
    _skeletonItems = _generateSkeletonItems();
  }

  List<_SkeletonItemData> _generateSkeletonItems() {
    final random = Random(42); // Fixed seed for consistent layout
    const itemCount = 12; // Reduced from 16
    return List.generate(itemCount, (index) {
      final bool isUserMessage = index % 2 == 0;
      double heightFraction;
      double widthFraction;

      if (isUserMessage) {
        final heightVariant = random.nextInt(100);
        if (heightVariant < 40) {
          heightFraction = 0.045;
          widthFraction = 0.35 + random.nextDouble() * 0.25;
        } else if (heightVariant < 75) {
          heightFraction = 0.08;
          widthFraction = 0.5 + random.nextDouble() * 0.35;
        } else {
          heightFraction = 0.12;
          widthFraction = 0.65 + random.nextDouble() * 0.25;
        }
      } else {
        final heightVariant = random.nextInt(100);
        if (heightVariant < 25) {
          heightFraction = 0.07;
          widthFraction = 0.5 + random.nextDouble() * 0.3;
        } else if (heightVariant < 60) {
          heightFraction = 0.12;
          widthFraction = 0.65 + random.nextDouble() * 0.25;
        } else {
          heightFraction = 0.16;
          widthFraction = 0.75 + random.nextDouble() * 0.2;
        }
      }

      return _SkeletonItemData(
        isUserMessage: isUserMessage,
        heightFraction: heightFraction,
        widthFraction: widthFraction,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // PERFORMANCE: Single Shimmer wrapper instead of 16 (now 12) independent
    // AnimationControllers. Each Shimmer.fromColors creates its own controller.
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RepaintBoundary(
        child: Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
            itemCount: _skeletonItems.length,
            itemBuilder: (context, index) {
              final item = _skeletonItems[index];
              final height = screenHeight * item.heightFraction;
              final width = screenWidth * item.widthFraction;

              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.008,
                  horizontal: screenWidth * 0.04,
                ),
                child: Align(
                  alignment: item.isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryColor,
                      borderRadius: BorderRadius.circular(
                          item.isUserMessage ? (height / 2) : 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Pre-computed skeleton item dimensions to avoid recalculating on every build.
class _SkeletonItemData {
  final bool isUserMessage;
  final double heightFraction;
  final double widthFraction;

  const _SkeletonItemData({
    required this.isUserMessage,
    required this.heightFraction,
    required this.widthFraction,
  });
}
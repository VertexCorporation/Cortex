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
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final random = Random();

    // Wrapping in FadeTransition for enter animation, 
    // and RepaintBoundary to ensure exit fade (AnimatedSwitcher in parent) handles ShaderMask properly
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RepaintBoundary(
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      itemCount: 16, // Realistic number of skeleton items
      itemBuilder: (context, index) {
        // Alternate between user and bot message skeletons
        final bool isUserMessage = index % 2 == 0;
        final double height;
        final double width;

        // Generate varied dimensions with more realistic message lengths
        if (isUserMessage) {
          // User messages: shorter, right-aligned
          final heightVariant = random.nextInt(100);
          if (heightVariant < 40) {
            // Short message (single line)
            height = screenHeight * 0.045;
            width = screenWidth * (0.35 + random.nextDouble() * 0.25);
          } else if (heightVariant < 75) {
            // Medium message (2 lines)
            height = screenHeight * 0.08;
            width = screenWidth * (0.5 + random.nextDouble() * 0.35);
          } else {
            // Longer message (3 lines)
            height = screenHeight * 0.12;
            width = screenWidth * (0.65 + random.nextDouble() * 0.25);
          }
        } else {
          // Bot messages: longer, left-aligned
          final heightVariant = random.nextInt(100);
          if (heightVariant < 25) {
            // Short response
            height = screenHeight * 0.07;
            width = screenWidth * (0.5 + random.nextDouble() * 0.3);
          } else if (heightVariant < 60) {
            // Medium response (2-3 lines)
            height = screenHeight * 0.12;
            width = screenWidth * (0.65 + random.nextDouble() * 0.25);
          } else {
            // Longer response (4 lines or more)
            height = screenHeight * 0.16;
            width = screenWidth * (0.75 + random.nextDouble() * 0.2);
          }
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
    ),
      ),
    );
  }
}
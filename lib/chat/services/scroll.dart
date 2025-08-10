// lib/chat/services/scroll.dart

import 'package:cortex/theme.dart'; // Make sure this import points to your theme file
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A service class to manage all scrolling-related logic for a ScrollController.
/// It provides robust methods for checking scroll position and programmatically scrolling.
class ScrollService {
  final ScrollController scrollController;

  ScrollService({required this.scrollController});

  /// Checks if the user is near the bottom of the scrollable area.
  ///
  /// [threshold] defines the distance from the bottom (in pixels) to be considered "at the bottom".
  /// Returns `true` if the current scroll offset is within the threshold of the max scroll extent.
  bool isUserAtBottom({double threshold = 100.0}) {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    // If there's nothing to scroll, we are always at the bottom.
    if (maxScroll == 0.0) return true;
    return (maxScroll - currentScroll) <= threshold;
  }

  /// Smoothly animates the scroll position to the very bottom of the list.
  ///
  /// This method waits for the end of the current frame to ensure the layout
  /// (and `maxScrollExtent`) is fully updated before initiating the scroll.
  /// This is crucial for reliability when new items are added to the list.
  Future<void> scrollToBottom({
    double threshold = 10.0,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (!scrollController.hasClients) return;

    // Wait for the UI to settle before calculating scroll position.
    await WidgetsBinding.instance.endOfFrame;
    if (!scrollController.hasClients) return; // Re-check after await

    final targetOffset = scrollController.position.maxScrollExtent;
    final currentOffset = scrollController.offset;

    // Don't scroll if we're already very close to the target.
    if ((targetOffset - currentOffset).abs() < threshold) return;

    try {
      await scrollController.animateTo(
        targetOffset,
        duration: duration,
        curve: Curves.easeOut,
      );
    } catch (e) {
      // Catch potential errors if the scroll view is disposed during animation.
      debugPrint("Could not complete scrollToBottom: $e");
    }
  }

  /// Forcefully scrolls to the bottom, typically used when the content size might be changing dynamically.
  ///
  /// It performs a series of quick, linear animations to ensure it reaches the
  /// final bottom position, even if the content is still growing (e.g., images loading).
  Future<void> jumpToBottom({
    int maxIterations = 10,
    double threshold = 10.0,
    Duration iterationDelay = const Duration(milliseconds: 100),
  }) async {
    if (!scrollController.hasClients) return;

    // Wait for the UI to settle before starting.
    await WidgetsBinding.instance.endOfFrame;
    if (!scrollController.hasClients) return;

    int iterations = 0;
    while (iterations < maxIterations) {
      final targetOffset = scrollController.position.maxScrollExtent;
      final currentOffset = scrollController.offset;
      if ((targetOffset - currentOffset).abs() < threshold) break;

      try {
        await scrollController.animateTo(
          targetOffset,
          duration: iterationDelay,
          curve: Curves.linear,
        );
      } catch (e) {
        debugPrint("Could not complete jumpToBottom iteration: $e");
        break; // Exit loop on error
      }
      iterations++;
    }
  }

  /// If the user is already near the bottom, this scrolls to the absolute bottom.
  ///
  /// This is useful for "locking" the scroll to the bottom when new messages arrive,
  /// but only if the user was already following the conversation.
  Future<void> maintainScrollAtBottom({double threshold = 100.0}) async {
    if (!scrollController.hasClients) return;

    // The check is performed using the service's own method.
    if (isUserAtBottom(threshold: threshold)) {
      await scrollToBottom();
    }
  }

  /// Builds the animated "Scroll to Bottom" button.
  ///
  /// The visibility and positioning are controlled by the parent widget.
  /// This widget just handles its own appearance animations (fade, scale).
  /// It now uses the AppColors class to determine icon color, removing the need for BuildContext.
  Widget buildScrollDownButton({
    required double screenWidth,
    required double inputFieldHeight,
    required bool showScrollDownButton,
  }) {
    // --- CORRECTED LOGIC ---
    // Get the color definitions for the currently active theme from your static class.
    final themeColors = AppColors.getThemeColors(AppColors.currentTheme);

    // Determine the icon color based on the theme's overall brightness.
    // If status bar icons are light (meaning a dark theme), use a light icon color.
    // If status bar icons are dark (meaning a light theme), use a dark icon color.
    final Color iconColor =
    themeColors.statusBarIconBrightness == Brightness.light
        ? Colors.white
        : Colors.black;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200), // Slightly smoother animation
      curve: Curves.easeOutCubic,
      right: screenWidth * 0.025,
      // The position is calculated relative to the input field container.
      // The parent widget (ChatScreen) is responsible for hiding this
      // when the keyboard is open to prevent UI glitches.
      bottom: inputFieldHeight + 16.0,
      child: AnimatedOpacity(
        opacity: showScrollDownButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: showScrollDownButton ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: IgnorePointer(
            ignoring: !showScrollDownButton,
            child: GestureDetector(
              onTap: () => scrollToBottom(),
              child: Container(
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
                decoration: BoxDecoration(
                  // This correctly uses the background color from your AppColors class.
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/arrov.svg',
                    // Apply the dynamically determined icon color here.
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    width: screenWidth * 0.08 * 0.7, // Adjusted size for better padding
                    height: screenWidth * 0.08 * 0.7,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
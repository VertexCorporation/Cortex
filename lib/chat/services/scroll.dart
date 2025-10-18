// lib/chat/services/scroll.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    if (!scrollController.hasClients) return true; // If no clients, conceptually at bottom
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    // If there's nothing to scroll, we are always at the bottom.
    if (maxScroll == 0.0) return true;
    return (maxScroll - currentScroll) <= threshold;
  }

  /// Smoothly animates the scroll position to the very bottom of the list.
  ///
  /// This method is safe to call at any time. It waits for the UI to settle
  /// before attempting to scroll, preventing crashes.
  Future<void> scrollToBottom({
    double threshold = 10.0,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    // Wait for the end of the current frame to ensure layout is complete.
    await WidgetsBinding.instance.endOfFrame;

    // After waiting, we can safely check for clients and scroll.
    if (!scrollController.hasClients) return;

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
      debugPrint("[ScrollService] Could not complete scrollToBottom: $e");
    }
  }

  /// This function is now completely safe. It uses a post-frame callback
  /// to ensure that the jump operation is only attempted *after* the widget
  /// tree has been fully built and the ScrollController is attached to a list.
  /// This prevents the 'hasClients' error and null check exceptions.
  void jumpToBottom() {
    // Use WidgetsBinding to schedule the jump for the end of the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // By the time this callback executes, the UI is stable.
      // We still check 'hasClients' as a final safety measure.
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(maxScroll);
        debugPrint("[ScrollService] Safely jumped to bottom (max: $maxScroll).");
      } else {
        debugPrint("[ScrollService] Jump to bottom skipped: ScrollController has no clients.");
      }
    });
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
  Widget buildScrollDownButton({
    required double screenWidth,
    required double inputFieldHeight,
    required bool showScrollDownButton,
    required double safeAreaBottomPadding, // Parameter for the bottom safe area inset.
  }) {
    // Get the full ThemeColors object for the currently active theme.
    final themeColors = AppColors.getThemeColors(AppColors.currentTheme);

    // Determine the icon color based on the theme's status bar brightness.
    final Color iconColor = themeColors.statusBarIconBrightness == Brightness.light
        ? Colors.white.withOpacity(0.8)
        : Colors.black.withOpacity(0.7);

    return Positioned(
      right: screenWidth * 0.04,
      // The button's bottom position is now calculated correctly by including the safe area padding.
      bottom: inputFieldHeight + safeAreaBottomPadding + 16.0,
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
              onTap: scrollToBottom, // Directly call the safe method
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/icons/arrov.svg',
                  // Apply the dynamically determined icon color here.
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// lib/chat/services/scroll.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

/// A service class to manage all scrolling-related logic.
class ScrollService {
  ScrollController? _scrollController;
  ValueNotifier<bool>? _showScrollDownButtonNotifier;
  VoidCallback? _listener;

  ScrollService();

  /// Sets the ScrollController. MUST be called before usage (e.g. in initState).
  void setController(ScrollController controller) {
    if (_scrollController != null) {
      detachListener();
    }
    _scrollController = controller;
  }

  /// Manually forces the button to hide and resets internal state.
  /// Call this when leaving the chat (dispose) or switching conversations.
  void reset() {
    detachListener();
    hideButtonImmediately(); // FIX: Explicitly hide button when resetting/leaving chat
    _scrollController = null;
  }

  ScrollPosition? _getSafePosition() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return null;
    // Allow multiple positions but use the first valid one
    if (controller.positions.isEmpty) return null;

    try {
      return controller.position;
    } catch (e) {
      // If multiple positions exist, try to get the first one
      if (controller.positions.isNotEmpty) {
        return controller.positions.first;
      }
      return null;
    }
  }

  bool isUserAtBottom({double threshold = 20.0}) {
    final position = _getSafePosition();
    if (position == null) {
      return true;
    }
    if (position.maxScrollExtent <= 0.0) return true;
    return (position.maxScrollExtent - position.pixels) <= threshold;
  }

  void hideButtonImmediately() {
    if (_showScrollDownButtonNotifier != null) {
      try {
        if (_showScrollDownButtonNotifier!.value) {
          _showScrollDownButtonNotifier!.value = false;
        }
      } catch (e) {
        // wow
      }
    }
  }

  void updateButtonVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listener?.call();
    });
  }

  void attachListener({
    required ValueNotifier<bool> notifier,
    required int Function() messageCountProvider,
  }) {
    if (_scrollController == null) return;

    if (_listener != null) {
      detachListener();
    }

    _showScrollDownButtonNotifier = notifier;

    _listener = () {
      if (_scrollController == null ||
          !_scrollController!.hasClients ||
          _showScrollDownButtonNotifier == null) {
        return;
      }

      final int msgCount = messageCountProvider();

      // If no messages, hide button
      if (msgCount == 0) {
        if (_showScrollDownButtonNotifier!.value) {
          _showScrollDownButtonNotifier!.value = false;
        }
        return;
      }

      final bool isAtBottom = isUserAtBottom();
      // Show button when NOT at bottom (regardless of message count - long messages need scroll too)
      final bool shouldShow = !isAtBottom;

      try {
        if (_showScrollDownButtonNotifier!.value != shouldShow) {
          _showScrollDownButtonNotifier!.value = shouldShow;
        }
      } catch (e) {
        detachListener();
      }
    };

    try {
      _scrollController!.addListener(_listener!);
      // Initial check - run listener once immediately after attaching
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listener?.call();
      });
    } catch (e) {
      debugPrint("[ScrollService] Listener attach error: $e");
    }
  }

  /// Removes the listener and ensures the button is hidden.
  void detachListener() {
    if (_showScrollDownButtonNotifier != null) {
      try {
        _showScrollDownButtonNotifier!.value = false;
      } catch (e) {
// wow
      }
    }

    if (_listener != null && _scrollController != null) {
      try {
        if (_scrollController!.hasClients) {
          _scrollController!.removeListener(_listener!);
        }
      } catch (e) {
// wow
      }
    }

    _listener = null;
    _showScrollDownButtonNotifier = null;
  }

  Future<void> scrollToBottom({
    double threshold = 10.0,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await WidgetsBinding.instance.endOfFrame;

    final position = _getSafePosition();
    if (position == null) return;

    try {
      final targetOffset = position.maxScrollExtent;
      if ((targetOffset - position.pixels).abs() < threshold) return;

      await _scrollController!.animateTo(
        targetOffset,
        duration: duration,
        curve: Curves.easeOut,
      );
    } catch (e) {
      // wow
    }
  }

  void jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = _getSafePosition();
      if (position != null) {
        _scrollController!.jumpTo(position.maxScrollExtent);
      }
    });
  }

  Future<void> maintainScrollAtBottom({double threshold = 100.0}) async {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    if (isUserAtBottom(threshold: threshold)) {
      await scrollToBottom();
    }
  }

  Widget buildScrollDownButton({
    required double screenWidth,
    required double screenHeight,
    required double bottomPanelHeight,
    required bool showScrollDownButton,
    required bool isKeyboardOpen,
    required double keyboardHeight,
    Offset slideOffset = Offset.zero,
  }) {
    final themeColors = AppColors.getThemeColors(AppColors.currentTheme);
    final Color iconColor =
        themeColors.statusBarIconBrightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.8);

    // Add extra padding so it perfectly clears the input field edge and shadow
    const double extraMargin = 24.0;

    // Use dynamic height tracking exclusively.
    // Scaffold natively resizes due to resizeToAvoidBottomInset: true.
    double bottomOffset = bottomPanelHeight + extraMargin;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: Center(
        child: AnimatedSlide(
          offset: slideOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Hide button immediately on tap
                      hideButtonImmediately();
                      scrollToBottom();
                    },
                    customBorder: const CircleBorder(),
                    splashColor: AppColors.primaryColor.withValues(alpha: 0.3),
                    highlightColor:
                        AppColors.primaryColor.withValues(alpha: 0.1),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrov.svg',
                        width: screenWidth * 0.045,
                        height: screenWidth * 0.045,
                        colorFilter:
                            ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                    ),
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

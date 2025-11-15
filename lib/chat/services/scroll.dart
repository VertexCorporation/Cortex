// lib/chat/services/scroll.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A service class to manage all scrolling-related logic.
/// It is initialized without a ScrollController and is configured later by the UI layer.
class ScrollService {
  // The ScrollController is now nullable and set later.
  ScrollController? _scrollController;

  // Internal state for the listener and the UI notifier.
  ValueNotifier<bool>? _showScrollDownButtonNotifier;
  VoidCallback? _listener;

  /// The constructor is now empty, allowing this service to be created
  /// in main.dart before a ScrollController exists.
  ScrollService();

  /// Sets the ScrollController for this service to manage.
  /// This method MUST be called from the UI layer (e.g., ChatScreenState's initState)
  /// before any other methods are used.
  void setController(ScrollController controller) {
    // If a controller was previously set, detach the old listener first.
    if (_scrollController != null) {
      detachListener();
    }
    _scrollController = controller;
    debugPrint("[ScrollService] Controller has been set.");
  }

  ScrollPosition? _getSafePosition() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) {
      return null;
    }

    final positions = controller.positions;
    if (positions.length != 1) {
      debugPrint(
        "[ScrollService] Multiple (${positions.length}) scroll positions attached. "
            "Skipping scroll computation for safety.",
      );
      return null;
    }

    try {
      return controller.position;
    } catch (e, s) {
      debugPrint(
        "[ScrollService] Error accessing ScrollController.position: $e\n$s",
      );
      return null;
    }
  }

  /// Checks if the user is near the bottom of the scrollable area.
  bool isUserAtBottom({double threshold = 100.0}) {
    final position = _getSafePosition();
    if (position == null) return true;

    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    if (maxScroll == 0.0) return true;
    return (maxScroll - currentScroll) <= threshold;
  }

  void hideButtonImmediately() {
    if (_showScrollDownButtonNotifier != null && _showScrollDownButtonNotifier!.value) {
      _showScrollDownButtonNotifier!.value = false;
    }
  }

  /// Manually triggers the logic within the scroll listener.
  void updateButtonVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listener?.call();
    });
  }

  /// Attaches a listener to the scroll controller to manage UI state.
  void attachListener({
    required ValueNotifier<bool> notifier,
    required int Function() messageCountProvider,
  }) {
    if (_scrollController == null) {
      debugPrint("[ScrollService] Cannot attach listener: Controller has not been set.");
      return;
    }
    _showScrollDownButtonNotifier = notifier;
    _listener = () {
      if (_scrollController == null || !_scrollController!.hasClients || _showScrollDownButtonNotifier == null) return;

      final bool isAtBottom = isUserAtBottom();
      final bool shouldShow = !isAtBottom && messageCountProvider() > 1;

      if (_showScrollDownButtonNotifier!.value != shouldShow) {
        _showScrollDownButtonNotifier!.value = shouldShow;
      }
    };
    _scrollController!.addListener(_listener!);
    debugPrint("[ScrollService] Listener attached successfully.");
  }

  /// Removes the listener from the scroll controller to prevent memory leaks.
  void detachListener() {
    if (_listener != null && _scrollController != null) {
      // Use a try-catch as a safeguard in case the controller is already disposed.
      try {
        _scrollController!.removeListener(_listener!);
      } catch (e) {
        debugPrint("[ScrollService] Error removing listener (might be already disposed): $e");
      }
      _listener = null;
    }
    // Clear the notifier reference to avoid memory leaks.
    _showScrollDownButtonNotifier = null;
    debugPrint("[ScrollService] Listener detached.");
  }

  /// Smoothly animates the scroll position to the very bottom of the list.
  /// This version includes enhanced safety checks to prevent crashes during rapid rebuilds.
  /// Smoothly animates the scroll position to the very bottom of the list.
  Future<void> scrollToBottom({
    double threshold = 10.0,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await WidgetsBinding.instance.endOfFrame;

    final position = _getSafePosition();
    if (position == null) {
      debugPrint(
        "[ScrollService] scrollToBottom skipped: No safe ScrollPosition available.",
      );
      return;
    }

    try {
      final targetOffset = position.maxScrollExtent;
      final currentOffset = position.pixels;

      if ((targetOffset - currentOffset).abs() < threshold) return;

      await _scrollController!.animateTo(
        targetOffset,
        duration: duration,
        curve: Curves.easeOut,
      );
    } catch (e, s) {
      debugPrint(
        "[ScrollService] Could not complete scrollToBottom due to an error. "
            "Error: $e\n$s",
      );
    }
  }

  /// Instantly jumps the scroll position to the bottom of the list.
  void jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = _getSafePosition();
      if (position == null) {
        debugPrint(
          "[ScrollService] Jump to bottom skipped: No safe ScrollPosition.",
        );
        return;
      }

      final maxScroll = position.maxScrollExtent;
      _scrollController!.jumpTo(maxScroll);
      debugPrint("[ScrollService] Safely jumped to bottom (max: $maxScroll).");
    });
  }

  /// If the user is already near the bottom, this scrolls to the absolute bottom.
  Future<void> maintainScrollAtBottom({double threshold = 100.0}) async {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    if (isUserAtBottom(threshold: threshold)) {
      await scrollToBottom();
    }
  }

  Widget buildScrollDownButton({
    required double screenWidth,
    required double screenHeight,
    required double bottomPanelHeight,      // height of panel (edit + input + briefing)
    required bool showScrollDownButton,
    required double safeAreaBottomPadding,  // typically MediaQuery.padding.bottom
    required bool isKeyboardOpen,
    required double keyboardHeight,         // MediaQuery.viewInsets.bottom
  }) {
    final themeColors = AppColors.getThemeColors(AppColors.currentTheme);
    final Color iconColor =
    themeColors.statusBarIconBrightness == Brightness.light
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.8);

    // Base: distance from the *top of the bottom panel* up to the button.
    final double panelTopMargin = screenHeight * 0.02;

    // ————————————————————————————————————————————————
    // Compute distance from SCREEN BOTTOM to button:
    //
    // 1) When keyboard is OPEN:
    //    screen bottom → keyboard top     = keyboardHeight
    //    keyboard top → panel top         = bottomPanelHeight
    //    panel top → button               = panelTopMargin
    //
    //    => bottomOffset = keyboardHeight + bottomPanelHeight + panelTopMargin
    //
    // 2) When keyboard is CLOSED:
    //    screen bottom → panel top        = bottomPanelHeight + safeAreaBottomPadding
    //    panel top → button               = panelTopMargin
    //
    //    => bottomOffset = bottomPanelHeight + safeAreaBottomPadding + panelTopMargin
    //       and then clamped so it doesn’t hug the very bottom.
    // ————————————————————————————————————————————————

    double bottomOffset;

    if (isKeyboardOpen) {
      bottomOffset = keyboardHeight +
          bottomPanelHeight +
          panelTopMargin;
    } else {
      bottomOffset = bottomPanelHeight +
          safeAreaBottomPadding +
          panelTopMargin;

      // Keep it at least some distance from the absolute bottom when
      // keyboard is not visible, so it doesn't visually merge with the input.
      final double minBottomOffset = screenHeight * 0.02; // 2% of screen height
      if (bottomOffset < minBottomOffset) {
        bottomOffset = minBottomOffset;
      }
    }

    return Positioned(
      right: screenWidth * 0.02,
      bottom: bottomOffset,
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
              onTap: scrollToBottom,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.9),
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
                  width: screenWidth * 0.04,
                  height: screenWidth * 0.04,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
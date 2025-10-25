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

  /// Checks if the user is near the bottom of the scrollable area.
  bool isUserAtBottom({double threshold = 100.0}) {
    if (_scrollController == null || !_scrollController!.hasClients) return true;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.offset;
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
  Future<void> scrollToBottom({
    double threshold = 10.0,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    if (_scrollController == null || !_scrollController!.hasClients) return;

    final targetOffset = _scrollController!.position.maxScrollExtent;
    final currentOffset = _scrollController!.offset;

    if ((targetOffset - currentOffset).abs() < threshold) return;

    try {
      await _scrollController!.animateTo(
        targetOffset,
        duration: duration,
        curve: Curves.easeOut,
      );
    } catch (e) {
      debugPrint("[ScrollService] Could not complete scrollToBottom: $e");
    }
  }

  /// Instantly jumps the scroll position to the bottom of the list.
  void jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null && _scrollController!.hasClients) {
        final maxScroll = _scrollController!.position.maxScrollExtent;
        _scrollController!.jumpTo(maxScroll);
        debugPrint("[ScrollService] Safely jumped to bottom (max: $maxScroll).");
      } else {
        debugPrint("[ScrollService] Jump to bottom skipped: ScrollController has no clients or controller is null.");
      }
    });
  }

  /// If the user is already near the bottom, this scrolls to the absolute bottom.
  Future<void> maintainScrollAtBottom({double threshold = 100.0}) async {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    if (isUserAtBottom(threshold: threshold)) {
      await scrollToBottom();
    }
  }

  /// Builds the animated "Scroll to Bottom" button.
  Widget buildScrollDownButton({
    required double screenWidth,
    required double inputFieldHeight,
    required bool showScrollDownButton,
    required double safeAreaBottomPadding,
  }) {
    // This method's implementation is correct and requires no changes.
    final themeColors = AppColors.getThemeColors(AppColors.currentTheme);
    final Color iconColor = themeColors.statusBarIconBrightness == Brightness.light
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.8);

    return Positioned(
      right: screenWidth * 0.02,
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
              onTap: scrollToBottom,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
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
                  color: iconColor,
                  width: screenWidth * 0.04,
                  height: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
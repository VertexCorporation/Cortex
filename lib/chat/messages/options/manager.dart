// lib/chat/widgets/options/manager.dart

import 'package:cortex/chat/messages/messages.dart';
import 'package:flutter/material.dart';
import 'panel.dart';

/// This file acts as the public API for the 'options' module, providing
/// global functions to manage the lifecycle of the message options panel.

/// A private, module-level variable to keep track of the currently displayed
/// message options overlay. This is the cornerstone of ensuring that only one
/// panel can be shown on the screen at any given time.
OverlayEntry? _currentMessageOptionsEntry;

/// Dismisses the currently visible message options panel, if one exists.
///
/// This function is safe to call at any time, even if no panel is currently
/// on screen. It handles the removal of the [OverlayEntry] and resets the
/// global reference, making the system ready to show a new panel.
void dismissCurrentMessageOptions() {
  if (_currentMessageOptionsEntry != null) {
    // Check if the overlay entry is still part of the tree ('mounted').
    // This prevents errors if it was already removed by other means (e.g., navigation).
    if (_currentMessageOptionsEntry!.mounted) {
      _currentMessageOptionsEntry!.remove();
    }
    // Always clear the reference to prevent memory leaks and dangling pointers.
    _currentMessageOptionsEntry = null;
  }
}

/// Displays the [AnimatedMessageOptionsPanel] as an overlay on the screen.
///
/// This is the primary entry point for triggering the message options UI. It
/// orchestrates the creation and insertion of the overlay panel.
///
/// The function's signature is intentionally lean. It only requires the essential
/// information to position and build the panel. All complex application state
/// (like user subscription status, internet connectivity, etc.) is fetched by
/// the [AnimatedMessageOptionsPanel] itself using Providers.
///
/// Parameters:
/// - `context`: The build context from which to show the overlay.
/// - `tapPosition`: The global coordinates of the tap/event that triggered the options.
/// - `message`: The core [Message] object for which options are being shown.
/// - `on...` callbacks: The specific actions to be executed when an option is selected.
Future<void> showMessageOptions({
  required BuildContext context,
  required Offset tapPosition,
  required Message message,
  VoidCallback? onReport,
  void Function({String? newModelId})? onRegenerate,
  VoidCallback? onStop,
  VoidCallback? onEdit,
}) async {
  // First, ensure any previously existing panel is dismissed.
  dismissCurrentMessageOptions();

  final overlay = Overlay.of(context);
  final renderBox = overlay.context.findRenderObject() as RenderBox?;
  if (renderBox == null) {
    return; // Cannot proceed without a renderBox.
  }

  final localPosition = renderBox.globalToLocal(tapPosition);

  // A ValueNotifier is still useful for the 'Select Text' feature.
  final messageNotifier = ValueNotifier<String>(message.text);

  _currentMessageOptionsEntry = OverlayEntry(
    builder: (overlayContext) {
      // The builder creates the panel instance.
      // Note that the `onChangeModel` callback is no longer needed here.
      return AnimatedMessageOptionsPanel(
        message: message,
        position: localPosition,
        messageNotifier: messageNotifier,
        onDismiss: dismissCurrentMessageOptions,
        onReport: onReport,
        onRegenerate: onRegenerate, // Pass the powerful, unified callback.
        onStop: onStop,
        onEdit: onEdit,
      );
    },
  );

  // Insert the newly created entry into the overlay, making it visible.
  overlay.insert(_currentMessageOptionsEntry!);
}
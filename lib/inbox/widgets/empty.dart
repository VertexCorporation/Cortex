// lib/inbox/widgets/empty.dart

import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../app.dart';
import '../../main.dart';
import '../../theme.dart';

/// A widget that is displayed when a list of conversations is empty.
///
/// It provides a user-friendly message and a call-to-action button.
/// The content (text and button action) can be customized for different
/// contexts, such as an empty "All Chats" list versus an empty "Starred" list.
class EmptyStateView extends StatelessWidget {
  /// Determines if the empty state is for the "Starred" tab.
  /// If `true`, it shows a message about starring conversations.
  /// If `false`, it shows a message about starting a new conversation.
  final bool isForStarred;

  /// A callback that is triggered when the "Go to Chats" button is pressed.
  /// This is used in the "Starred" context to switch the user back to the "All Chats" tab.
  final VoidCallback? onGoToAllChats;

  /// Creates an instance of [EmptyStateView].
  const EmptyStateView({
    super.key,
    required this.isForStarred,
    this.onGoToAllChats,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the content based on the context (All Chats vs. Starred).
    final String title =
    isForStarred ? localizations.noStarredChats : localizations.noChats;
    final String message = isForStarred
        ? localizations.noStarredChatsMessage
        : localizations.noConversationsMessage;
    final String buttonText =
    isForStarred ? localizations.goToChats : localizations.startChat;

    // Define the button's action based on the context.
    final VoidCallback onPressedAction = isForStarred
        ? () {
      // Match old behavior: hide any snackbar, then switch to "All Chats".
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      onGoToAllChats?.call();
    }
        : () {
      // For the "All Chats" empty state, navigate to the new chat screen.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      mainScreenKey.currentState?.onItemTapped(0);
    };

    // Use a TweenAnimationBuilder to fade the widget in smoothly.
    return TweenAnimationBuilder<double>(
      key: ValueKey(isForStarred ? 'empty_starred_state' : 'empty_all_state'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Text
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.primaryColor.inverted,
                fontSize: screenWidth * 0.07, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Informational Message
            Text(
              message,
              style: TextStyle(
                color: AppColors.tertiaryColor,
                fontSize: screenWidth * 0.04, // Responsive font size
                height: 1.5, // Improved line spacing for readability
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Call-to-Action Button
            Center(
              child: ElevatedButton(
                onPressed: onPressedAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.inverted,
                  foregroundColor: AppColors.primaryColor, // Text/icon color
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenWidth * 0.035,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
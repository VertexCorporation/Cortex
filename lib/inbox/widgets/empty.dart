// lib/inbox/widgets/empty.dart

import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../app.dart';
import '../../theme.dart';
import '../../main.dart';

/// A widget that is displayed when a list of conversations is empty.
class EmptyStateView extends StatelessWidget {
  /// Determines if the empty state is for the "Starred" tab.
  /// (Note: In the new Sidebar design, this might be less relevant,
  /// but kept for compatibility if you use this widget elsewhere).
  final bool isForStarred;

  /// Callback mainly kept for backward compatibility or specific UI flows.
  final VoidCallback? onGoToAllChats;

  const EmptyStateView({
    super.key,
    required this.isForStarred,
    this.onGoToAllChats,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    final String title =
    isForStarred ? localizations.noStarredChats : localizations.noChats;

    final String message = isForStarred
        ? localizations.noStarredChatsMessage
        : localizations.noConversationsMessage;

    final String buttonText =
    isForStarred ? localizations.goToChats : localizations.startChat;

    // Define the button's action based on context.
    final VoidCallback onPressedAction = isForStarred
        ? () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      onGoToAllChats?.call();
    }
        : () {
      // FIX: Changed from onItemTapped(0) to startNewConversation()
      // This aligns with the new Single-Screen architecture.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      mainScreenKey.currentState?.startNewConversation();
    };

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
                fontSize: screenWidth * 0.07,
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
                fontSize: screenWidth * 0.04,
                height: 1.5,
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
                  foregroundColor: AppColors.primaryColor,
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
// lib/axon/widgets/menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';

// Providers & Services (Required for New Chat logic)
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/storage.dart';

// Components
import 'item.dart';

class AxonMenu extends StatelessWidget {
  final double referenceWidth;
  final double screenHeight;
  final int activeTab;
  final bool isNewChatActive;
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onNewsTap;

  const AxonMenu({
    super.key,
    required this.referenceWidth,
    required this.screenHeight,
    required this.activeTab,
    required this.isNewChatActive,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onNewsTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // --- Layout Constants ---
    final double horizontalPadding = referenceWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.005;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.8),
      child: Column(
        children: [
          // --- 1. NEW CHAT ---
          AxonItem(
            label: localizations.newChat,
            iconPath: 'assets/icons/chat.svg',
            onTap: () {
              // 1. Close Keyboard
              FocusScope.of(context).unfocus();

              // 2. Reset Chat Logic if needed
              final conversation = context.read<ConversationProvider>();
              if (conversation.messages.isNotEmpty) {
                // If there was an active conversation, turn off Flux/Ghost mode
                // to ensure a fresh start.
                context.read<ChatSessionProvider>().setFluxMode(false);
                ChatStorageService.isFluxMode = false;
              }

              // 3. Navigation Callback
              onNewChatTap();
            },
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: isNewChatActive,
          ),
          SizedBox(height: verticalSpacing),

          // --- 2. LIBRARY ---
          AxonItem(
            label: localizations.library,
            iconPath: 'assets/icons/library.svg',
            onTap: onLibraryTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: activeTab == 1,
          ),
          SizedBox(height: verticalSpacing),

          // --- 3. NEWS ---
          AxonItem(
            label: localizations.news,
            iconPath: 'assets/icons/news.svg',
            onTap: onNewsTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: activeTab == 2,
          ),

          // Bottom Spacing before the list starts
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
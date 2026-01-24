// lib/axon/content.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Theme & Logic
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/providers/conversation.dart';
import '../../banner.dart';

// Modular Widgets
import 'widgets/header.dart';
import 'widgets/menu.dart';
import 'widgets/list.dart';
import 'widgets/footer.dart';

class AxonContent extends StatelessWidget {
  final double referenceWidth;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchActive;
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onNewsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onExitSearchTap;
  final ValueChanged<String> onSearchChanged;
  final int activeTab;
  final BannerService bannerService;

  const AxonContent({
    super.key,
    required this.referenceWidth,
    required this.scrollController,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchActive,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onNewsTap,
    required this.onSettingsTap,
    required this.onExitSearchTap,
    required this.onSearchChanged,
    required this.activeTab,
    required this.bannerService,
  });

  @override
  Widget build(BuildContext context) {
    // 1. PERFORMANCE: RepaintBoundary
    // This creates a separate display list for the drawer.
    // When the drawer slides closed, Flutter composites this texture
    // instead of repainting the entire widget tree every pixel.
    return RepaintBoundary(
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    final conversationProvider = context.watch<ConversationProvider>();
    final String? currentConversationId = conversationProvider.conversationID;

    // Logic: Active Tab is Chat (0) AND no conversation loaded
    final bool isNewChatActive = (activeTab == 0) &&
        (currentConversationId == null || currentConversationId.isEmpty);

    final double horizontalPadding = referenceWidth * 0.05;
    final double fontSizeBody = referenceWidth * 0.045;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. HEADER ---
        AxonHeader(
          referenceWidth: referenceWidth,
          screenHeight: screenHeight,
          searchController: searchController,
          searchFocusNode: searchFocusNode,
          isSearchActive: isSearchActive,
          onExitSearchTap: onExitSearchTap,
          onSearchChanged: onSearchChanged,
        ),

        // --- 2. MENU ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: isSearchActive
              ? const SizedBox(width: double.infinity, height: 0)
              : AnimatedSlide(
                  offset: isSearchActive ? const Offset(0, -0.2) : Offset.zero,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSearchActive ? 0.0 : 1.0,
                    child: AxonMenu(
                      referenceWidth: referenceWidth,
                      screenHeight: screenHeight,
                      activeTab: activeTab,
                      isNewChatActive: isNewChatActive,
                      onNewChatTap: onNewChatTap,
                      onLibraryTap: onLibraryTap,
                      onNewsTap: onNewsTap,
                    ),
                  ),
                ),
        ),

        // --- 3. DIVIDER ---
        if (!isSearchActive)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding * 1.5,
              right: horizontalPadding,
              bottom: screenHeight * 0.008,
            ),
            child: Row(
              children: [
                Text(
                  localizations.chats,
                  style: GoogleFonts.roboto(
                    color: AppColors.tertiaryColor,
                    fontSize: fontSizeBody * 0.85,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: referenceWidth * 0.04),
                Expanded(
                  child: Container(
                    height: 0.8,
                    margin: EdgeInsets.only(right: horizontalPadding * 0.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // --- 4. LIST AREA ---
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: AxonConversationList(
                  referenceWidth: referenceWidth,
                  screenHeight: screenHeight,
                  scrollController: scrollController,
                  isSearchActive: isSearchActive,
                  searchController: searchController,
                ),
              ),

              // Gradient Overlay
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: referenceWidth * 0.1,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.background.withValues(alpha: 0.0),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Banner
              Positioned(
                bottom: 0,
                left: horizontalPadding * 0.5,
                right: horizontalPadding * 0.5,
                child: ValueListenableBuilder<bool>(
                  valueListenable: bannerService.showInviteBannerNotifier,
                  builder: (context, showBanner, child) {
                    // Only render the banner widget when it should be visible.
                    if (!showBanner) {
                      return const SizedBox.shrink();
                    }
                    return FloatingInfoBanner(
                      isEmbedded: true,
                      referenceWidth: referenceWidth,
                      onDismissed: () => bannerService.startCooldown(),
                      onTap: () =>
                          bannerService.generateAndShareInviteLink(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // --- 5. FOOTER ---
        AxonFooter(
          referenceWidth: referenceWidth,
          isSearchActive: isSearchActive,
          onSettingsTap: onSettingsTap,
        ),
      ],
    );
  }
}

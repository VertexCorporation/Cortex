// lib/axon/content.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cortex/axon/inbox/logic/general.dart';
import 'package:cortex/notifications/introvert.dart';

// Theme & Logic
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/providers/conversation.dart';
// import 'package:cortex/fog.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/funds/backend/service.dart';

// Modular Widgets
import '../app.dart';
import '../../navigation.dart';
import 'widgets/header.dart';
import 'widgets/menu.dart';
import 'widgets/list.dart';

class AxonContent extends StatelessWidget {
  final double referenceWidth;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Animation<double> searchModeAnimation;
  final bool isSearchActive;
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onCreateAITap;
  final VoidCallback onArtsTap;
  final VoidCallback onNewsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onExitSearchTap;
  final VoidCallback onCloseAxon;
  final ValueChanged<String> onSearchChanged;
  final int activeTab;

  const AxonContent({
    super.key,
    required this.referenceWidth,
    required this.scrollController,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchModeAnimation,
    required this.isSearchActive,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onCreateAITap,
    required this.onArtsTap,
    required this.onNewsTap,
    required this.onSettingsTap,
    required this.onExitSearchTap,
    required this.onCloseAxon,
    required this.onSearchChanged,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final inboxViewModel = context.watch<InboxViewModel>();

    context.select<ConversationProvider, String?>((p) => p.conversationID);

    // PERFORMANCE: Granular selects instead of full watch to prevent
    // unnecessary rebuilds when unrelated UserProvider fields change.
    final isUserStateReady =
        context.select<UserProvider, bool>((u) => u.isUserStateReady);
    final isAnonymous =
        context.select<UserProvider, bool>((u) => u.isAnonymous);
    final isSubscribed =
        context.select<UserProvider, bool>((u) => u.isSubscriptionActive);
    final shouldShowSpecialOfferEntryPoint = context
        .select<FundsBackend, bool>((f) => f.shouldShowSpecialOfferEntryPoint);
    final hasFreeTrial =
        context.select<FundsBackend, bool>((f) => f.hasFreeTrial);

    final double horizontalPadding = referenceWidth * 0.05;
    final double fontSizeBody = referenceWidth * 0.04;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            AxonHeader(
              referenceWidth: referenceWidth,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              searchController: searchController,
              searchFocusNode: searchFocusNode,
              searchModeAnimation: searchModeAnimation,
              isSearchActive: isSearchActive,
              onExitSearchTap: onExitSearchTap,
              onCloseAxon: onCloseAxon,
              onSearchChanged: onSearchChanged,
              onSettingsTap: onSettingsTap,
            ),

            // 2-4. COLLAPSIBLE SECTION
            // PERFORMANCE: Consolidated from 9 implicit animations (3 sections
            // × AnimatedSlide+AnimatedOpacity+AnimatedSize) into 3 total.
            // This reduces from 9 independent AnimationControllers to 3.
            AnimatedSlide(
              offset: (isSearchActive || inboxViewModel.isSelectionMode) ? const Offset(0, -0.3) : Offset.zero,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: (isSearchActive || inboxViewModel.isSelectionMode) ? 0.0 : 1.0,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: (isSearchActive || inboxViewModel.isSelectionMode)
                      ? const SizedBox(width: double.infinity, height: 0)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SHORTCUTS HEADER
                            Padding(
                              padding: EdgeInsets.only(
                                left: horizontalPadding * 1.5,
                                right: horizontalPadding,
                                bottom: screenHeight * 0.008,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    localizations.shortcuts,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: AppColors.primaryColor.inverted,
                                      fontSize: fontSizeBody * 0.95,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: referenceWidth * 0.04),
                                  Expanded(
                                    child: Container(
                                      height: 0.8,
                                      margin: EdgeInsets.only(
                                          right: horizontalPadding * 0.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF333333),
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // MENU
                            AxonMenu(
                              referenceWidth: referenceWidth,
                              screenHeight: screenHeight,
                              activeTab: activeTab,
                              onLibraryTap: onLibraryTap,
                              onCreateAITap: onCreateAITap,
                              onArtsTap: onArtsTap,
                              onNewsTap: onNewsTap,
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // 3. RECENTS / SELECTION HEADER (Visible unless searching)
            if (!isSearchActive)
              Padding(
                padding: EdgeInsets.only(
                  left: inboxViewModel.isSelectionMode
                      ? horizontalPadding * 0.5
                      : horizontalPadding * 1.5,
                  right: horizontalPadding,
                  top: inboxViewModel.isSelectionMode ? 8.0 : 0.0,
                  bottom: screenHeight * 0.008,
                ),
                child: inboxViewModel.isSelectionMode
                    ? Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.primaryColor.inverted,
                              size: referenceWidth * 0.055,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              inboxViewModel.setSelectionMode(false);
                            },
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            localizations.localeName == 'tr'
                                ? '${inboxViewModel.selectedIDs.length} Seçildi'
                                : '${inboxViewModel.selectedIDs.length} Selected',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.primaryColor.inverted,
                              fontSize: fontSizeBody * 0.95,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Select All / Deselect All
                          IconButton(
                            icon: Icon(
                              inboxViewModel.selectedIDs.length == inboxViewModel.conversations.length
                                  ? Icons.deselect_rounded
                                  : Icons.select_all_rounded,
                              color: AppColors.primaryColor.inverted,
                              size: referenceWidth * 0.055,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (inboxViewModel.selectedIDs.length == inboxViewModel.conversations.length) {
                                inboxViewModel.clearSelection();
                              } else {
                                inboxViewModel.selectAllConversations();
                              }
                            },
                          ),
                          // Delete Selected
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: inboxViewModel.selectedIDs.isEmpty
                                  ? AppColors.primaryColor.inverted.withValues(alpha: 0.3)
                                  : Colors.redAccent,
                              size: referenceWidth * 0.055,
                            ),
                            onPressed: inboxViewModel.selectedIDs.isEmpty
                                ? null
                                : () {
                                    HapticFeedback.heavyImpact();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          backgroundColor: AppColors.secondaryColor,
                                          title: Text(
                                            localizations.localeName == 'tr'
                                                ? 'Seçilenleri Sil?'
                                                : 'Delete Selected?',
                                            style: TextStyle(color: AppColors.primaryColor.inverted),
                                          ),
                                          content: Text(
                                            localizations.localeName == 'tr'
                                                ? 'Seçili ${inboxViewModel.selectedIDs.length} sohbeti silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'
                                                : 'Are you sure you want to delete the selected ${inboxViewModel.selectedIDs.length} chats? This action cannot be undone.',
                                            style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha: 0.8)),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(dialogContext),
                                              child: Text(
                                                localizations.localeName == 'tr' ? 'Vazgeç' : 'Cancel',
                                                style: TextStyle(color: AppColors.primaryColor.inverted),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                                inboxViewModel.deleteSelectedConversations();
                                                Provider.of<IntrovertNotificationService>(context, listen: false)
                                                    .showNotification(
                                                  message: localizations.localeName == 'tr'
                                                      ? 'Seçili sohbetler silindi'
                                                      : 'Selected chats deleted',
                                                  type: NotificationType.success,
                                                  isAxonMode: true,
                                                  axonWidth: referenceWidth,
                                                );
                                              },
                                              child: const Text(
                                                'Sil',
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            localizations.chats,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.primaryColor.inverted,
                              fontSize: fontSizeBody * 0.95,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: referenceWidth * 0.04),
                          Expanded(
                            child: Container(
                              height: 0.8,
                              margin: EdgeInsets.only(
                                  right: horizontalPadding * 0.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF333333),
                                borderRadius:
                                    BorderRadius.circular(2.0),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

            // 4. LIST AREA
            Expanded(
              child: AxonConversationList(
                referenceWidth: referenceWidth,
                screenHeight: screenHeight,
                scrollController: scrollController,
                isSearchActive: isSearchActive,
                searchController: searchController,
              ),
            ),
          ],
        ),
        if (!inboxViewModel.isSelectionMode)
          Positioned(
            right: horizontalPadding,
            bottom: screenHeight * 0.03,
            child: Material(
              color: AppColors.primaryColor.inverted,
              shape: const StadiumBorder(),
              elevation: 8.0,
              shadowColor: Colors.black54,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNewChatTap();
                },
                customBorder: const StadiumBorder(),
                splashColor: AppColors.primaryColor.withValues(alpha: 0.15),
                highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: referenceWidth * 0.05,
                    vertical: referenceWidth * 0.035,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/new.svg',
                        width: referenceWidth * 0.055,
                        height: referenceWidth * 0.055,
                        colorFilter: ColorFilter.mode(
                          AppColors.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: referenceWidth * 0.02),
                      Text(
                        localizations.newChat,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: referenceWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Login Button — bottom-left, shown only for anonymous users
        if (isUserStateReady && isAnonymous)
          Positioned(
            left: horizontalPadding,
            bottom: screenHeight * 0.03,
            child: Material(
              color: AppColors.primaryColor.inverted,
              shape: const StadiumBorder(),
              elevation: 8.0,
              shadowColor: Colors.black54,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  navigateToScreen(
                    const UpgradeAccountScreen(showLoginFirst: true),
                    direction: const Offset(0.0, 1.0),
                  );
                },
                customBorder: const StadiumBorder(),
                splashColor: AppColors.primaryColor.withValues(alpha: 0.15),
                highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: referenceWidth * 0.05,
                    vertical: referenceWidth * 0.035,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryColor,
                        size: referenceWidth * 0.055,
                      ),
                      SizedBox(width: referenceWidth * 0.02),
                      Text(
                        localizations.logIn,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: referenceWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Special Offer Button — bottom-left
        if (isUserStateReady &&
            !isAnonymous &&
            !isSubscribed &&
            (shouldShowSpecialOfferEntryPoint || hasFreeTrial))
          Positioned(
            left: horizontalPadding,
            bottom: screenHeight * 0.03,
            child: Builder(
              builder: (context) {
                // Glassmorphism: same formula as the appbar ClaimOfferButton
                final Color baseColor =
                    AppColors.premium.withValues(alpha: 0.25);
                final Color glassBackground =
                    Color.alphaBlend(baseColor, AppColors.background);
                final Color borderColor =
                    AppColors.premium.withValues(alpha: 0.4);
                final Color contentColor = AppColors.premium;

                return Material(
                  color: glassBackground,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: borderColor,
                      width: 0.8,
                    ),
                  ),
                  elevation: 0.0,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      navigateToScreen(
                        const FundsScreen(),
                        direction: const Offset(1.0, 0.0),
                      );
                    },
                    customBorder: const StadiumBorder(),
                    splashColor: contentColor.withValues(alpha: 0.2),
                    highlightColor: contentColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: referenceWidth * 0.05,
                        vertical: referenceWidth * 0.035,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            color: contentColor,
                            size: referenceWidth * 0.055,
                          ),
                          SizedBox(width: referenceWidth * 0.02),
                          Text(
                            shouldShowSpecialOfferEntryPoint
                                ? AppLocalizations.of(context)!.claimOffer
                                : AppLocalizations.of(context)!.freeOffer,
                            style: TextStyle(
                              color: contentColor,
                              fontSize: referenceWidth * 0.04,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// lib/axon/widgets/list.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Logic & Data
import 'package:cortex/axon/inbox/logic/general.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

// Components
import 'package:cortex/axon/inbox/empty.dart';
import 'package:cortex/axon/inbox/tile/view.dart';

import '../../app.dart';
import '../../fog.dart';
import '../../notifications/introvert.dart';

class AxonConversationList extends StatelessWidget {
  final double referenceWidth;
  final double screenHeight;
  final ScrollController scrollController;
  final bool isSearchActive;
  final TextEditingController searchController;

  const AxonConversationList({
    super.key,
    required this.referenceWidth,
    required this.screenHeight,
    required this.scrollController,
    required this.isSearchActive,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inboxViewModel = context.watch<InboxViewModel>();

    // Layout Constants
    final double horizontalPadding = referenceWidth * 0.05;

    // --- 1. Loading State ---
    if (inboxViewModel.isLoading) {
      return Center(
        key: const ValueKey('loading'),
        child: CircularProgressIndicator(
          strokeWidth: referenceWidth * 0.005,
          color: Colors.white30,
        ),
      );
    }

    // --- Logic for Empty States ---
    final List<String> displayConversations = inboxViewModel.conversations;
    final bool isEmpty = displayConversations.isEmpty;
    final bool hasSearchText = searchController.text
        .trim()
        .isNotEmpty;
    final bool showNoResults = isSearchActive && hasSearchText && isEmpty;

    // --- 2. Empty / No Results State ---
    if (isEmpty) {
      if (showNoResults) {
        return _buildNoResultsFound(context, localizations);
      } else {
        return const Center(
          key: ValueKey('empty_state'),
          child: EmptyStateView(isForStarred: false),
        );
      }
    }

    // --- 3. Active List with Fog Effect ---
    return ScrollFog(
      key: const ValueKey('list'),
      scrollController: scrollController,
      fogColor: AppColors.background,
      topFogHeight: 15,
      bottomFogHeight: 30,
      showTop: true,
      showBottom: true,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding * 0.5,
          screenHeight * 0.005,
          horizontalPadding * 0.5,
          screenHeight * 0.1, // Extra padding at bottom for banner
        ),
        itemCount: inboxViewModel.conversations.length,
        itemBuilder: (context, index) {
          final id = inboxViewModel.conversations[index];
          final manager = inboxViewModel.conversationManagers[id];

          if (manager == null) return const SizedBox.shrink();

          return AxonConversationTile(
            key: ValueKey(id),
            manager: manager,
            onDelete: () {
              inboxViewModel.deleteConversation(id);
              // Show "Deleted" notification
              Provider.of<IntrovertNotificationService>(context, listen: false)
                  .showNotification(
                message: localizations.conversationDeleted,
                type: NotificationType.success,
                isAxonMode: true,
                axonWidth: referenceWidth,
              );
            },
            onEdit: (newTitle) => inboxViewModel.editConversation(id, newTitle),
            onTogglePin: () => inboxViewModel.togglePinStatus(id),
          );
        },
      ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context,
      AppLocalizations localizations) {
    return Padding(
      key: const ValueKey('no_results'),
      padding: EdgeInsets.only(top: screenHeight * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/warning.svg',
            width: referenceWidth * 0.12,
            height: referenceWidth * 0.12,
            colorFilter: ColorFilter.mode(
              AppColors.tertiaryColor.withValues(alpha: 0.4),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            localizations.noFoundTitle,
            style: GoogleFonts.roboto(
              color: AppColors.primaryColor.inverted,
              fontSize: referenceWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            localizations.noFoundMessage,
            style: GoogleFonts.roboto(
              color: AppColors.tertiaryColor,
              fontSize: referenceWidth * 0.038,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
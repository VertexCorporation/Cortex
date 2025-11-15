// lib/inbox/widgets/list.dart

import 'package:cortex/inbox/widgets/tiles/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../fog.dart';
import '../manager.dart';
import '../providers/general.dart';
import '../skeleton.dart';
import 'empty.dart';

/// A widget responsible for displaying a list of conversations.
///
/// This widget handles three primary states:
/// 1. **Loading State**: Displays a [SkeletonChatList] while conversations are being fetched.
/// 2. **Empty State**: Displays an [EmptyStateView] if there are no conversations to show.
/// 3. **Data State**: Displays a [ListView] of [ConversationTile] widgets.
///
/// It is designed to be used within a [TabBarView] for both "All Chats" and "Starred" lists.
class ConversationListView extends StatelessWidget {
  /// A key to identify the list widget and preserve its scroll position.
  final Key? listKey;

  /// The scroll controller for the list, used to manage scroll position and effects like [ScrollFog].
  final ScrollController scrollController;

  /// Determines if this list is for the "Starred" tab. This helps in selecting the correct
  /// data source from the ViewModel and showing the appropriate empty state.
  final bool isForStarred;

  /// A callback to handle tab switching, specifically for the "Go to Chats" button in the
  /// empty state of the "Starred" tab.
  final VoidCallback? onGoToAllChats;

  const ConversationListView({
    super.key,
    required this.listKey,
    required this.scrollController,
    required this.isForStarred,
    this.onGoToAllChats,
  });

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the ViewModel to rebuild the UI accordingly.
    final viewModel = context.watch<InboxViewModel>();
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine which list of IDs to use based on the `isForStarred` flag.
    final conversationIDs = isForStarred
        ? viewModel.starredConversationIDs
        : viewModel.orderedConversationIDs;

    final Widget listContent;

    if (viewModel.isLoading && conversationIDs.isEmpty) {
      // Show skeleton only on initial load when there's no cached data.
      listContent = SkeletonChatList(
        key: ValueKey(isForStarred ? 'skeleton_starred' : 'skeleton_all'),
      );
    } else if (conversationIDs.isEmpty) {
      // Show empty state if the list is empty after loading.
      listContent = EmptyStateView(
        isForStarred: isForStarred,
        onGoToAllChats: onGoToAllChats,
      );
    } else {
      // Show the list with the conversation data.
      listContent = ListView.builder(
        key: listKey,
        controller: scrollController,
        itemCount: conversationIDs.length,
        itemBuilder: (context, index) {
          final convID = conversationIDs[index];
          final manager = viewModel.conversationManagers[convID];

          if (manager == null) {
            // This can happen briefly if an item is deleted while the list rebuilds.
            // Returning an empty box is a safe fallback.
            return const SizedBox.shrink();
          }

          return _buildTile(
            context,
            manager,
            localizations,
          );
        },
      );
    }

    // Wrap the final content with the ScrollFog for a polished visual effect.
    return ScrollFog(
      scrollController: scrollController,
      fogColor: Theme.of(context).scaffoldBackgroundColor,
      topFogHeight: screenHeight * 0.02,
      showTop: true,
      showBottom: false,
      child: listContent,
    );
  }

  /// Builds a [ConversationTile] hooked up to the [InboxViewModel] actions.
  /// Uses an [AnimatedSwitcher] wrapped in a [KeyedSubtree] so that each
  /// row's animation state is tied to its conversation ID, not its index.
  Widget _buildTile(
      BuildContext context,
      ConversationManager manager,
      AppLocalizations localizations,
      ) {
    final viewModel = context.read<InboxViewModel>();
    final isDeleting =
    viewModel.deletingConversationIDs.contains(manager.conversationID);

    // Normal tile widget (no key needed here; outer KeyedSubtree will handle identity).
    final tile = ConversationTile(
      manager: manager,
      onDelete: () => viewModel.deleteConversation(
        manager.conversationID,
        localizations.conversationDeleted,
      ),
      onEdit: (newTitle) => viewModel.editConversation(
        manager.conversationID,
        newTitle,
        localizations.conversationTitleUpdated,
      ),
      onToggleStar: () => viewModel.toggleStarStatus(manager.conversationID),
    );

    return KeyedSubtree(
      key: ValueKey(manager.conversationID),
      child: AnimatedSwitcher(
        // Match old AnimatedList remove animation duration.
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          // axisAlignment default (0.0) → shrink from center,
          // beneath items simply slide up smoothly like before.
          return SizeTransition(
            sizeFactor: curved,
            child: FadeTransition(
              opacity: curved,
              child: child,
            ),
          );
        },
        child: isDeleting
            ? const SizedBox.shrink()
            : tile,
      ),
    );
  }
}
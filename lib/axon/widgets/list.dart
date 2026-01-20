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

import 'package:shimmer/shimmer.dart';
import '../../app.dart';
import '../../fog.dart';
import '../../notifications/introvert.dart';

class AxonConversationList extends StatefulWidget {
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
  State<AxonConversationList> createState() => _AxonConversationListState();
}

class _AxonConversationListState extends State<AxonConversationList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> _displayedIds = [];

  @override
  void initState() {
    super.initState();
    // Initial Population
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<InboxViewModel>();
      if (vm.conversations.isNotEmpty) {
        setState(() {
          _displayedIds = List.from(vm.conversations);
        });
      }
    });
  }

  @override
  void didUpdateWidget(AxonConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForUpdates();
  }

  void _checkForUpdates() {
    final vm = context.read<InboxViewModel>();
    final newIds = vm.conversations;

    // Fast path: if identical, do nothing
    if (_areListsEqual(_displayedIds, newIds)) return;

    _calculateDiffs(List.from(_displayedIds), newIds);
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _calculateDiffs(List<String> oldList, List<String> newList) {
    // We will perform a sequence of removals and insertions to transform oldList -> newList.
    // 1. Remove items that are no longer in newList (from highest index to lowest)
    // 2. Insert items that are new in newList (from lowest to highest)
    // 3. Handle moves as Remove + Insert

    // A simple diff algorithm for Flutter AnimatedList:
    // It is often safer to reconcile manually or use a diff package.
    // Given we don't have a diff package, we'll use a pragmatic approach:
    // "Remove all items that moved or deleted" vs "Insert all items that moved or added".

    int i = 0;
    while (i < _displayedIds.length) {
      if (!newList.contains(_displayedIds[i])) {
        // DELETE
        final removedId = _displayedIds.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedItem(removedId, animation),
          duration: const Duration(milliseconds: 300),
        );
      } else {
        i++;
      }
    }

    // Now _displayedIds contains only items that exist in both (in old order).
    // We need to reorder them or insert new ones.
    // This part is tricky with just insertions.
    // Strategy: To animate REORDERING, we must also remove them if their index changed significantly?
    // Actually, AnimatedList doesn't support "Move".
    // The visual trick is: Remove from old, Insert at new.

    // Let's do a more robust standard diff:
    // We will walk through the new list and ensure _displayedIds matches it.

    // Reset loop
    _displayedIds = List.from(oldList); // Reset to verify logic cleanly

    // 1. Identification phase
    // Find items that need to be removed (not in new list)
    for (int index = _displayedIds.length - 1; index >= 0; index--) {
      final id = _displayedIds[index];
      if (!newList.contains(id)) {
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRemovedItem(id, animation),
          duration: const Duration(milliseconds: 300),
        );
        _displayedIds.removeAt(index);
      }
    }

    // 2. Alignment phase
    // Now displayedIds contains only items that ARE in the new list, but maybe in wrong order.
    // And it doesn't have the new items.
    // We iterate through NEW list.
    for (int index = 0; index < newList.length; index++) {
      final newId = newList[index];

      if (index < _displayedIds.length) {
        final oldId = _displayedIds[index];
        if (oldId == newId) {
          // Sync, continue
          continue;
        } else {
          // IDs mismatch at this index.
          // Is the `newId` somewhere later in our displayed list?
          final existingIndex = _displayedIds.indexOf(newId, index);

          if (existingIndex != -1) {
             // It exists later. This implies `oldId` (and others) have shifted down,
             // or `newId` moved up.
             // We remove it from the old position and insert it here.
             final idToMove = _displayedIds.removeAt(existingIndex);
             _listKey.currentState?.removeItem(
                existingIndex,
                 (context, _) => SizedBox.shrink(), // Instant remove (visual hack)
                duration: Duration.zero
             );
             _displayedIds.insert(index, idToMove);
             _listKey.currentState?.insertItem(index);
          } else {
            // It doesn't exist. It's a new item. Match!
             _displayedIds.insert(index, newId);
             _listKey.currentState?.insertItem(
               index,
               duration: const Duration(milliseconds: 300)
             );
          }
        }
      } else {
        // Appending new item
        _displayedIds.add(newId);
        _listKey.currentState?.insertItem(
            index,
            duration: const Duration(milliseconds: 300)
        );
      }
    }
  }

  Widget _buildRemovedItem(String id, Animation<double> animation) {
    // We need to fetch data from provider momentarily, or fallback if deleted.
    // Ideally we'd have the data snapshot.
    // For deleted items, we just slide them out.
    // Since manager might be gone from VM, `AxonConversationTile` handles null gracefully?
    // The `AxonConversationList` builder checks `manager == null`.
    // If manager is gone, we can't show the tile.
    // So we assume for "moves" manager exists. For "deletes" it might be gone.

    final inboxViewModel = context.read<InboxViewModel>();
    final manager = inboxViewModel.conversationManagers[id];

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0, // Collapse upwards
      child: FadeTransition(
        opacity: animation,
        child: manager != null
            ? AxonConversationTile(
                manager: manager,
                onDelete: () {}, // No op during animation
                onEdit: (_) {},
                onTogglePin: () {},
                key: ValueKey(id),
              )
            : const SizedBox.shrink(), // Item data gone, shrink away
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inboxViewModel = context.watch<InboxViewModel>();

    // Layout Constants
    final double horizontalPadding = widget.referenceWidth * 0.05;

    // --- 1. Loading State ---
    if (inboxViewModel.isLoading && _displayedIds.isEmpty) {
      return ListView.separated(
        key: const ValueKey('loading_skeletons'),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding * 0.5,
          widget.screenHeight * 0.005,
          horizontalPadding * 0.5,
          widget.screenHeight * 0.1,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return const _SkeletonTile();
        },
      );
    }

    // --- Logic for Empty States ---
    final List<String> currentIds = inboxViewModel.conversations;
    // Initial sync if we missed it (Edge case)
    if (_displayedIds.isEmpty && currentIds.isNotEmpty && _listKey.currentState == null) {
       _displayedIds = List.from(currentIds);
    }

    final bool isEmpty = currentIds.isEmpty && _displayedIds.isEmpty;
    final bool hasSearchText = widget.searchController.text.trim().isNotEmpty;
    final bool showNoResults = widget.isSearchActive && hasSearchText && isEmpty;

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
    // If the View Model reset (e.g. search changed drastically), re-sync immediately?
    // We rely on `didUpdateWidget` diffing.

    return ScrollFog(
      key: const ValueKey('list'),
      scrollController: widget.scrollController,
      fogColor: AppColors.background,
      topFogHeight: 15,
      bottomFogHeight: 30,
      showTop: true,
      showBottom: true,
      child: AnimatedList(
        key: _listKey,
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding * 0.5,
          widget.screenHeight * 0.005,
          horizontalPadding * 0.5,
          widget.screenHeight * 0.1,
        ),
        initialItemCount: _displayedIds.length,
        itemBuilder: (context, index, animation) {
          if (index >= _displayedIds.length) return const SizedBox.shrink();
          final id = _displayedIds[index];
          final manager = inboxViewModel.conversationManagers[id];

          if (manager == null) return const SizedBox.shrink();

          // Wrap tile in transition for Insert animations
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(0, 0.5), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: FadeTransition(
              opacity: animation,
              child: AxonConversationTile(
                key: ValueKey(id),
                manager: manager,
                onDelete: () {
                  inboxViewModel.deleteConversation(id);
                  Provider.of<IntrovertNotificationService>(context, listen: false)
                      .showNotification(
                    message: localizations.conversationDeleted,
                    type: NotificationType.success,
                    isAxonMode: true,
                    axonWidth: widget.referenceWidth,
                  );
                },
                onEdit: (newTitle) => inboxViewModel.editConversation(id, newTitle),
                onTogglePin: () => inboxViewModel.togglePinStatus(id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context,
      AppLocalizations localizations) {
      // (Keep existing implementation)
    return Padding(
      key: const ValueKey('no_results'),
      padding: EdgeInsets.only(top: widget.screenHeight * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/warning.svg',
            width: widget.referenceWidth * 0.12,
            height: widget.referenceWidth * 0.12,
            colorFilter: ColorFilter.mode(
              AppColors.tertiaryColor.withValues(alpha: 0.4),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.02),
          Text(
            localizations.noFoundTitle,
            style: GoogleFonts.roboto(
              color: AppColors.primaryColor.inverted,
              fontSize: widget.referenceWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.008),
          Text(
            localizations.noFoundMessage,
            style: GoogleFonts.roboto(
              color: AppColors.tertiaryColor,
              fontSize: widget.referenceWidth * 0.038,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.secondaryColor,
      highlightColor: AppColors.tertiaryColor.withValues(alpha: 0.1),
      child: Container(
        height: 80, // Approximate tile height
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Avatar Circle
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            // Text Lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                    margin: const EdgeInsets.only(right: 60),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                    margin: const EdgeInsets.only(right: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

// lib/axon/widgets/list.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  InboxViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _viewModel = context.read<InboxViewModel>();
      _viewModel!.addListener(_onViewModelUpdate);

      if (_viewModel!.conversations.isNotEmpty) {
        setState(() {
          _displayedIds = List.from(_viewModel!.conversations);
        });
      }
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelUpdate);
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (!mounted) return;
    _checkForUpdates();
  }

  @override
  void didUpdateWidget(AxonConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No longer need to check here, listener handles it.
  }

  void _checkForUpdates() {
    final vm = context.read<InboxViewModel>();
    final newIds = vm.conversations;

    final wasEmpty = _displayedIds.isEmpty;

    if (_areListsEqual(_displayedIds, newIds)) return;
    _calculateDiffs(List.from(_displayedIds), newIds);

    final isEmptyNow = _displayedIds.isEmpty;
    if (wasEmpty != isEmptyNow) {
      setState(() {});
    }
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _calculateDiffs(List<String> oldList, List<String> newList) {
    // 1. Deletions
    for (int i = oldList.length - 1; i >= 0; i--) {
      final item = oldList[i];
      if (!newList.contains(item)) {
        _displayedIds.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedItem(item, animation),
          duration: const Duration(milliseconds: 150),
        );
      }
    }

    // 2. Additions
    int index = 0;
    while (index < newList.length) {
      final newItem = newList[index];
      if (index >= _displayedIds.length) {
        _displayedIds.insert(index, newItem);
        _listKey.currentState
            ?.insertItem(index, duration: const Duration(milliseconds: 150));
      } else {
        final currentDisplayedItem = _displayedIds[index];
        if (currentDisplayedItem != newItem) {
          final int existingIndex = _displayedIds.indexOf(newItem, index);
          if (existingIndex != -1) {
            final movedItem = _displayedIds.removeAt(existingIndex);
            _listKey.currentState?.removeItem(
                existingIndex, (context, animation) => const SizedBox.shrink(),
                duration: Duration.zero);
            _displayedIds.insert(index, movedItem);
            _listKey.currentState?.insertItem(index,
                duration: const Duration(milliseconds: 150));
          } else {
            _displayedIds.insert(index, newItem);
            _listKey.currentState?.insertItem(index,
                duration: const Duration(milliseconds: 150));
          }
        }
      }
      index++;
    }

    while (_displayedIds.length > newList.length) {
      final lastIndex = _displayedIds.length - 1;
      _displayedIds.removeAt(lastIndex);
      _listKey.currentState?.removeItem(
        lastIndex,
        (context, animation) => const SizedBox.shrink(),
        duration: Duration.zero,
      );
    }
  }

  Widget _buildRemovedItem(String id, Animation<double> animation) {
    final manager = _viewModel?.conversationManagers[id];

    // The tile has already animated its size and opacity down to 0 via its own
    // internal _deleteController BEFORE triggering this removal if manually deleted.
    // Returning SizedBox.shrink() prevents the 'double playback' bug.
    if (manager == null || manager.isDeleted) {
      return const SizedBox.shrink();
    }

    // If it was removed due to search filtering, animate it out smoothly.
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 1.0,
      child: FadeTransition(
        opacity: animation,
        child: AxonConversationTile(
          key: ValueKey('removed_$id'),
          manager: manager,
          onDelete: () {},
          onEdit: (_) async {},
          onTogglePin: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Use context.select to only rebuild when isLoading changes.
    // The conversation list updates are handled by the dedicated listener.
    final bool isLoading = context.select<InboxViewModel, bool>(
      (vm) => vm.isLoading,
    );

    final double horizontalPadding = widget.referenceWidth * 0.05;
    final bool showSkeletons = isLoading && _displayedIds.isEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,

      // --- CRITICAL UPDATE: Custom Transition ---
      // Smooth Fade to Content (Shimmer -> Content)
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child, // Removed ScaleTransition to prevent layout jumps
        );
      },

      // Overlap (Stack) Layout
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      // PERFORMANCE: Single Shimmer wrapper instead of 8 independent
      // AnimationControllers. Each Shimmer.fromColors creates its own
      // controller; wrapping all tiles in one reduces overhead significantly.
      child: showSkeletons
          ? Shimmer.fromColors(
              key: const ValueKey('loading_skeletons'),
              baseColor: AppColors.secondaryColor,
              highlightColor: AppColors.tertiaryColor.withValues(alpha: 0.1),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding * 0.5,
                  0,
                  horizontalPadding * 0.5,
                  0,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  return _SkeletonTilePlain(
                    referenceWidth: widget.referenceWidth,
                    screenHeight: widget.screenHeight,
                  );
                },
              ),
            )
          : _buildListContent(
              localizations,
              context.read<InboxViewModel>(),
              horizontalPadding,
            ),
    );
  }

  Widget _buildListContent(AppLocalizations localizations,
      InboxViewModel inboxViewModel, double horizontalPadding) {
    final List<String> currentIds = inboxViewModel.conversations;
    if (_displayedIds.isEmpty &&
        currentIds.isNotEmpty &&
        _listKey.currentState == null) {
      _displayedIds = List.from(currentIds);
    }

    final bool isEmpty = currentIds.isEmpty && _displayedIds.isEmpty;
    final bool hasSearchText = widget.searchController.text.trim().isNotEmpty;
    final bool showNoResults =
        widget.isSearchActive && hasSearchText && isEmpty;

    return Stack(
      key: const ValueKey('loaded_content'),
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isEmpty
                ? Center(
                    key: ValueKey(showNoResults ? 'no_results' : 'empty'),
                    child: showNoResults
                        ? _buildNoResultsFound(context, localizations)
                        : const EmptyStateView(isForStarred: false),
                  )
                : const SizedBox.shrink(key: ValueKey('not_empty')),
          ),
        ),
        Positioned.fill(
          child: ScrollFog(
            key: const ValueKey('list'),
            scrollController: widget.scrollController,
            topFogHeight: 15,
            bottomFogHeight: 30,
            showTop: true,
            showBottom: true,
            child: AnimatedList(
              key: _listKey,
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding * 0.5,
                0,
                horizontalPadding * 0.5,
                0,
              ),
              initialItemCount: _displayedIds.length,
              itemBuilder: (context, index, animation) {
                if (index >= _displayedIds.length) {
                  return const SizedBox.shrink();
                }
                final id = _displayedIds[index];
                final manager = inboxViewModel.conversationManagers[id];

                if (manager == null) return const SizedBox.shrink();

                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 1.0,
                  child: FadeTransition(
                    opacity: animation,
                    child: AxonConversationTile(
                      key: ValueKey(id),
                      manager: manager,
                      onDelete: () {
                        inboxViewModel.deleteConversation(id);
                        Provider.of<IntrovertNotificationService>(context,
                                listen: false)
                            .showNotification(
                          message: localizations.conversationDeleted,
                          type: NotificationType.success,
                          isAxonMode: true,
                          axonWidth: widget.referenceWidth,
                        );
                      },
                      onEdit: (newTitle) =>
                          inboxViewModel.editConversation(id, newTitle),
                      onTogglePin: () => inboxViewModel.togglePinStatus(id),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsFound(
      BuildContext context, AppLocalizations localizations) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      key: const ValueKey('no_results'),
      padding: EdgeInsets.only(
        top: widget.screenHeight * 0.05,
        bottom: bottomInset > 0 ? bottomInset * 0.8 : 0,
        left: widget.referenceWidth * 0.05,
        right: widget.referenceWidth * 0.05,
      ),
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
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.primaryColor.inverted,
              fontSize: widget.referenceWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.008),
          Text(
            localizations.noFoundMessage,
            style: TextStyle(
              fontFamily: 'Inter',
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

/// PERFORMANCE: Plain skeleton tile without its own Shimmer wrapper.
/// The parent wraps all tiles in a single Shimmer.fromColors to avoid
/// creating 8 independent AnimationControllers.
class _SkeletonTilePlain extends StatelessWidget {
  final double referenceWidth;
  final double screenHeight;

  const _SkeletonTilePlain({
    required this.referenceWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Margins
    final double marginV = screenHeight * 0.003;
    final double marginH = referenceWidth * 0.01;

    // 2. Padding (Inner)
    final double innerPaddingV = screenHeight * 0.012;

    // 3. Avatar Size
    final double avatarSize = referenceWidth * 0.072;

    // 4. Border Radius
    final double borderRadius = referenceWidth * 0.03;

    // 5. Total Height = Avatar + (InnerPadding * 2)
    final double contentHeight = avatarSize + (innerPaddingV * 2);

    return Container(
      height: contentHeight,
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          SizedBox(width: referenceWidth * 0.03),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: referenceWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: referenceWidth * 0.035,
                  color: Colors.white,
                  margin: EdgeInsets.only(right: referenceWidth * 0.15),
                ),
              ],
            ),
          ),
          SizedBox(width: referenceWidth * 0.03),
        ],
      ),
    );
  }
}

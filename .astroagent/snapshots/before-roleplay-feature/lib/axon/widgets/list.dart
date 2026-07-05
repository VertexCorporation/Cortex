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
import 'package:cortex/axon/widgets/search_hit_tile.dart';
import 'package:cortex/axon/inbox/logic/search_hit.dart';
import '../../main.dart';

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
  List<String> _displayedIds = [];
  InboxViewModel? _viewModel;
  int _currentLimit = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _viewModel = context.read<InboxViewModel>();
      _viewModel!.addListener(_onViewModelUpdate);

      widget.scrollController.addListener(_onScroll);

      if (_viewModel!.conversations.isNotEmpty) {
        setState(() {
          _updateDisplayedIds(_viewModel!.conversations);
        });
      }
    });
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    
    // Load more when user scrolls near the bottom
    if (widget.scrollController.position.pixels >= 
        widget.scrollController.position.maxScrollExtent - 200) {
      if (_viewModel == null) return;
      
      final newIds = _viewModel!.conversations;
      if (_currentLimit < newIds.length) {
        setState(() {
          _currentLimit += 15;
          _updateDisplayedIds(newIds);
        });
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _viewModel?.removeListener(_onViewModelUpdate);
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (!mounted) return;
    _checkForUpdates();
  }

  void _updateDisplayedIds(List<String> newIds) {
    if (newIds.length > _currentLimit) {
      _displayedIds = newIds.sublist(0, _currentLimit);
    } else {
      _displayedIds = List.from(newIds);
    }
  }

  void _checkForUpdates() {
    final vm = context.read<InboxViewModel>();
    final newIds = vm.conversations;
    
    List<String> newDisplayed;
    if (newIds.length > _currentLimit) {
      newDisplayed = newIds.sublist(0, _currentLimit);
    } else {
      newDisplayed = List.from(newIds);
    }

    if (_areListsEqual(_displayedIds, newDisplayed)) return;
    
    setState(() {
      _displayedIds = newDisplayed;
    });
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Use context.select to only rebuild when isLoading changes.
    final bool isLoading = context.select<InboxViewModel, bool>(
      (vm) => vm.isLoading,
    );

    final double horizontalPadding = widget.referenceWidth * 0.05;
    final bool showSkeletons = isLoading && _displayedIds.isEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
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
    
    final bool hasSearchText = widget.searchController.text.trim().isNotEmpty;
    final bool isDeepSearch = widget.isSearchActive && hasSearchText && widget.searchController.text.trim().length >= 2;
    
    final List<String> currentIds = inboxViewModel.conversations;
    final List<SearchHit> searchHits = inboxViewModel.searchHits;
    
    final bool isEmpty = isDeepSearch 
        ? searchHits.isEmpty 
        : (currentIds.isEmpty && _displayedIds.isEmpty);
        
    final bool showNoResults =
        widget.isSearchActive && hasSearchText && isEmpty;

    return Stack(
      key: const ValueKey('loaded_content'),
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
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
            child: isDeepSearch 
            ? ListView.builder(
                controller: widget.scrollController,
                padding: EdgeInsets.fromLTRB(horizontalPadding * 0.5, 0, horizontalPadding * 0.5, 0),
                itemCount: searchHits.length,
                itemBuilder: (context, index) {
                  final hit = searchHits[index];
                  return SearchHitTile(
                    hit: hit,
                    onTap: () {
                      mainScreenKey.currentState?.closeAxon();
                      final manager = inboxViewModel.conversationManagers[hit.conversationId];
                      if (manager != null) {
                        mainScreenKey.currentState?.openConversation(manager);
                      }
                    },
                  );
                },
              )
            : ListView.builder(
              controller: widget.scrollController,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding * 0.5,
                0,
                horizontalPadding * 0.5,
                0,
              ),
              itemCount: _displayedIds.length,
              itemBuilder: (context, index) {
                if (index >= _displayedIds.length) {
                  return const SizedBox.shrink();
                }
                final id = _displayedIds[index];
                final manager = inboxViewModel.conversationManagers[id];

                if (manager == null) return const SizedBox.shrink();

                return AxonConversationTile(
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
                  onTogglePin: () async {
                    bool success = await inboxViewModel.togglePinStatus(id);
                    if (!success) {
                      if (!context.mounted) return;
                      Provider.of<IntrovertNotificationService>(context,
                              listen: false)
                          .showNotification(
                        message: localizations.pinLimitReached,
                        type: NotificationType.error,
                        isAxonMode: true,
                        axonWidth: widget.referenceWidth,
                      );
                    }
                  },
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

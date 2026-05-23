// lib/axon/view.dart

import 'package:cortex/axon/inbox/logic/general.dart';
import 'package:cortex/axon/inbox/panel/view.dart';
import 'package:cortex/settings/controller.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation.dart';
import 'content.dart';

class Axon extends StatefulWidget {
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onCreateAITap;
  final VoidCallback onArtsTap;
  final VoidCallback onNewsTap;
  final VoidCallback onCloseAxon;
  final VoidCallback onOpenAxon;
  final double referenceWidth;
  final int activeTab;
  final bool isOpen;

  const Axon({
    super.key,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onCreateAITap,
    required this.onArtsTap,
    required this.onNewsTap,
    required this.onCloseAxon,
    required this.onOpenAxon,
    required this.referenceWidth,
    required this.activeTab,
    required this.isOpen,
  });

  @override
  State<Axon> createState() => _AxonState();
}

class _AxonState extends State<Axon> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  // Search mode animation controller — now internal to Axon
  late final AnimationController _searchModeController;

  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchModeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 0.0,
    );

    _searchFocusNode.addListener(_onSearchFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchModeController.dispose();

    ActionPanelController.closeCurrent();
    super.dispose();
  }

  @override
  void didUpdateWidget(Axon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen && !widget.isOpen) {
      _handleExitSearchMode();
    }
  }

  void _onSearchFocusChange() {
    final isFocused = _searchFocusNode.hasFocus;
    if (_isSearchActive != isFocused) {
      setState(() => _isSearchActive = isFocused);
      if (isFocused) {
        _searchModeController.forward();
      } else {
        _searchModeController.reverse();
        _handleExitSearchMode();
      }
    }
  }

  void _handleSettingsTap() async {
    ActionPanelController.closeCurrent(); // Close context menu

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    // For Desktop sizes, open Settings in a centered dialog.
    if (screenWidth >= 800) {
      await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
              side: BorderSide(
                color: AppColors.senaryColor,
                width: 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 680,
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.9,
              ),
              child: const SettingsScreen(),
            ),
          );
        },
      );
    } else {
      // Mobile behavior: Push Route without closing Axon
      await navigateToScreen(
        const SettingsScreen(),
        direction: const Offset(1.0, 0.0), // Slide from right to left
      );
    }
  }

  void _handleExitSearchMode() {
    _searchController.clear();
    if (mounted) {
      context.read<InboxViewModel>().filterConversations('');
    }
    _searchFocusNode.unfocus();
  }

  void _handleSearchQueryChanged(String query) {
    context.read<InboxViewModel>().filterConversations(query);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: AxonContent(
          referenceWidth: widget.referenceWidth,
          scrollController: _scrollController,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          searchModeAnimation: _searchModeController,
          isSearchActive: _isSearchActive,
          onNewChatTap: widget.onNewChatTap,
          onLibraryTap: widget.onLibraryTap,
          onCreateAITap: widget.onCreateAITap,
          onArtsTap: widget.onArtsTap,
          onNewsTap: widget.onNewsTap,
          onSettingsTap: _handleSettingsTap,
          onSearchChanged: _handleSearchQueryChanged,
          onExitSearchTap: _handleExitSearchMode,
          onCloseAxon: widget.onCloseAxon,
          activeTab: widget.activeTab,

        ),
      ),
    );
  }
}

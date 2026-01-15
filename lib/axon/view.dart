// lib/axon/view.dart

import 'package:cortex/axon/inbox/logic/general.dart';
import 'package:cortex/settings/controller.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../banner.dart';
import '../../navigation.dart';
import 'content.dart';

class Axon extends StatefulWidget {
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onNewsTap;
  final VoidCallback onCloseAxon;
  final VoidCallback onOpenAxon;
  final ValueChanged<bool>? onSearchFocusChanged;
  final double referenceWidth;
  final int activeTab;

  const Axon({
    super.key,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onNewsTap,
    required this.onCloseAxon,
    required this.onOpenAxon,
    required this.referenceWidth,
    this.onSearchFocusChanged,
    required this.activeTab,
  });

  @override
  State<Axon> createState() => _AxonState();
}

class _AxonState extends State<Axon> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final BannerService _bannerService;

  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _bannerService = BannerService();

    _searchFocusNode.addListener(_onSearchFocusChange);
    _bannerService.checkAndTriggerBanner();

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
    _bannerService.dispose();

    super.dispose();
  }

  void _onSearchFocusChange() {
    final isFocused = _searchFocusNode.hasFocus;
    if (_isSearchActive != isFocused) {
      setState(() => _isSearchActive = isFocused);
      widget.onSearchFocusChanged?.call(isFocused);
    }
  }

  void _handleSettingsTap() async {
    widget.onCloseAxon();

    await navigateToScreen(
      const SettingsScreen(),
      direction: const Offset(0.1, 0.0),
    );

    if (mounted) widget.onOpenAxon();
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
          isSearchActive: _isSearchActive,
          onNewChatTap: widget.onNewChatTap,
          onLibraryTap: widget.onLibraryTap,
          onNewsTap: widget.onNewsTap,
          onSettingsTap: _handleSettingsTap,
          onSearchChanged: _handleSearchQueryChanged,
          onExitSearchTap: _handleExitSearchMode,
          activeTab: widget.activeTab,
          bannerService: _bannerService,
        ),
      ),
    );
  }
}
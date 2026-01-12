// lib/sidebar/view.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../fog.dart';
import '../inbox/providers/general.dart';
import '../inbox/widgets/tile.dart';
import '../l10n/app_localizations.dart';
import '../server/user.dart';
import '../settings/controller.dart';
import 'item.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onNewsTap;
  final VoidCallback onCloseSidebar;
  final VoidCallback onOpenSidebar;
  final Function(bool) onOfflineModeChanged;
  final ValueChanged<bool>? onSearchFocusChanged;
  final double referenceWidth;

  const Sidebar({
    super.key,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onNewsTap,
    required this.onCloseSidebar,
    required this.onOpenSidebar, // NEW
    required this.onOfflineModeChanged,
    required this.referenceWidth,
    this.onSearchFocusChanged,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _chatListController = ScrollController();

  bool _isOfflineMode = false;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    final isFocused = _searchFocusNode.hasFocus;
    if (_isSearchActive != isFocused) {
      setState(() {
        _isSearchActive = isFocused;
      });
      widget.onSearchFocusChanged?.call(isFocused);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _chatListController.dispose();
    super.dispose();
  }

  // UPDATED: Async navigation to handle re-opening sidebar on return
  void _navigateToSettings() async {
    // 1. Close sidebar first for a clean exit transition
    widget.onCloseSidebar();

    // 2. Push Settings (Slide from Right) and WAIT for it to close
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );

    // 3. When settings is popped (user goes back), re-open the sidebar
    if (mounted) {
      widget.onOpenSidebar();
    }
  }

  void _exitSearchMode() {
    _searchController.clear();
    context.read<InboxViewModel>().filterConversations('');
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inboxViewModel = context.watch<InboxViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final double refWidth = widget.referenceWidth;

    final double horizontalPadding = refWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.005;
    final double searchBarHeight = screenHeight * 0.055;
    final double searchIconSize = refWidth * 0.06;
    final double brandIconHeight = screenHeight * 0.035;
    final double fontSizeBody = refWidth * 0.045;

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ColorFilter? smartCortexFilter = isDarkMode
        ? const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ])
        : null;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Header (Search + Brand) ---
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                screenHeight * 0.025,
                horizontalPadding,
                screenHeight * 0.015,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: searchBarHeight,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(refWidth * 0.045),
                        border: Border.all(
                          color: _isSearchActive
                              ? AppColors.primaryColor.inverted
                              : AppColors.border.withValues(alpha: 0.3),
                          width: _isSearchActive ? 1.0 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: TextStyle(
                            color: AppColors.primaryColor.inverted,
                            fontSize: fontSizeBody,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: localizations.searchHint,
                            hintStyle: TextStyle(
                              color: AppColors.tertiaryColor,
                              fontSize: fontSizeBody,
                            ),
                            prefixIcon: GestureDetector(
                              onTap: _isSearchActive ? _exitSearchMode : null,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  _isSearchActive ? Icons.arrow_back : Icons.search,
                                  key: ValueKey(_isSearchActive),
                                  size: searchIconSize,
                                  color: _isSearchActive
                                      ? AppColors.primaryColor.inverted
                                      : AppColors.tertiaryColor,
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (val) {
                            inboxViewModel.filterConversations(val);
                          },
                        ),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      width: _isSearchActive ? 0 : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _isSearchActive ? 0.0 : 1.0,
                        child: Row(
                          children: [
                            SizedBox(width: refWidth * 0.03),
                            SvgPicture.asset(
                              'assets/cortex.svg',
                              height: brandIconHeight,
                              colorFilter: smartCortexFilter,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. Static Menu Items ---
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: _isSearchActive ? 0 : null,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.8),
                    child: Column(
                      children: [
                        SidebarItem(
                          label: localizations.newChat,
                          iconPath: 'assets/icons/chat.svg',
                          onTap: widget.onNewChatTap,
                          isPrimary: true,
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                          reduceIconSize: true,
                        ),
                        SizedBox(height: verticalSpacing),
                        SidebarItem(
                          label: localizations.library,
                          iconPath: 'assets/icons/library.svg',
                          onTap: widget.onLibraryTap,
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                          reduceIconSize: true,
                        ),
                        SizedBox(height: verticalSpacing),
                        SidebarItem(
                          label: localizations.selectionScreenNewsAndUpdates,
                          iconPath: 'assets/icons/news.svg',
                          onTap: widget.onNewsTap,
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                          reduceIconSize: true,
                        ),
                        SizedBox(height: verticalSpacing),
                        SidebarItem(
                          label: localizations.selectionScreenFeatureOffline,
                          iconPath: 'assets/icons/context.svg',
                          onTap: () {
                            bool newVal = !_isOfflineMode;
                            setState(() => _isOfflineMode = newVal);
                            widget.onOfflineModeChanged(newVal);
                          },
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                          reduceIconSize: true,
                          isOfflineActive: _isOfflineMode,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- 3. Chats Header ---
            if (!_isSearchActive)
              Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding * 1.5,
                  right: 0,
                  top: screenHeight * 0.01,
                  bottom: screenHeight * 0.01,
                ),
                child: Row(
                  children: [
                    Text(
                      localizations.chats.toUpperCase(),
                      style: GoogleFonts.roboto(
                        color: AppColors.tertiaryColor,
                        fontSize: fontSizeBody * 0.85,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: refWidth * 0.04),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: EdgeInsets.only(right: horizontalPadding * 1.2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- 4. Chat List ---
            Expanded(
              child: inboxViewModel.isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: refWidth * 0.005,
                  color: Colors.white30,
                ),
              )
                  : inboxViewModel.conversations.isEmpty
                  ? Center(
                child: Text(
                  _isSearchActive
                      ? localizations.noModelsFoundTitle
                      : localizations.noRecentChatsMessage,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: fontSizeBody,
                  ),
                ),
              )
                  : ScrollFog(
                scrollController: _chatListController,
                fogColor: AppColors.background,
                topFogHeight: 15,
                bottomFogHeight: 30,
                showTop: true,
                showBottom: true,
                child: ListView.builder(
                  controller: _chatListController,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding * 0.5,
                    vertical: screenHeight * 0.005,
                  ),
                  itemCount: inboxViewModel.conversations.length,
                  itemBuilder: (context, index) {
                    final id = inboxViewModel.conversations[index];
                    final manager = inboxViewModel.conversationManagers[id];

                    if (manager == null) return const SizedBox.shrink();

                    if (inboxViewModel.deletingConversationIDs.contains(id)) {
                      return const SizedBox.shrink();
                    }

                    return SidebarConversationTile(
                      manager: manager,
                      onDelete: () => inboxViewModel.deleteConversation(id),
                      onEdit: (newTitle) => inboxViewModel.editConversation(id, newTitle),
                      onTogglePin: () => inboxViewModel.togglePinStatus(id),
                    );
                  },
                ),
              ),
            ),

            // --- 5. Settings Footer ---
            if (!_isSearchActive)
              _buildSettingsFooter(
                context,
                horizontalPadding,
                fontSizeBody,
                refWidth,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsFooter(
      BuildContext context, double hPadding, double fontSize, double refWidth) {
    final userProvider = context.watch<UserProvider>();
    final String initials = userProvider.profileInitial;
    final String name = userProvider.username;
    final String settingsText = AppLocalizations.of(context)!.settings;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding * 0.8,
        vertical: 16.0,
      ),
      child: InkWell(
        onTap: _navigateToSettings,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.secondaryColor.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: refWidth * 0.11,
                height: refWidth * 0.11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.quaternaryColor,
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: fontSize * 1.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted,
                  ),
                ),
              ),
              SizedBox(width: refWidth * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: fontSize * 0.95,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    settingsText,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: fontSize * 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/sidebar.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'inbox/providers/general.dart';
import 'inbox/widgets/tile.dart';
import 'l10n/app_localizations.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onNewsTap;
  final Function(bool) onOfflineModeChanged;
  final ValueChanged<bool>? onSearchFocusChanged;

  // We pass the "Standard" width (85%) just for font sizing reference.
  // The ACTUAL width is determined by the parent container size.
  final double referenceWidth;

  const Sidebar({
    super.key,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onNewsTap,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inboxViewModel = context.watch<InboxViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Use referenceWidth (85%) for sizing elements so they don't get huge when stretched
    final double refWidth = widget.referenceWidth;

    // --- DYNAMIC DIMENSIONS BASED ON REFERENCE WIDTH ---
    final double horizontalPadding = refWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.005;
    final double searchBarHeight = screenHeight * 0.055;
    final double searchIconSize = refWidth * 0.06;
    final double brandIconHeight = screenHeight * 0.035;
    final double fontSizeBody = refWidth * 0.045;

    // Smart Logo Logic
    final bool isDarkBackground = AppColors.background.computeLuminance() < 0.5;
    final ColorFilter? smartCortexFilter = isDarkBackground
        ? const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ])
        : null;

    return Material(
      color: AppColors.background,
      // No SizedBox(width:...) here. We let the parent define the width.
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Header (Search + Brand) ---
            Padding(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  screenHeight * 0.025,
                  horizontalPadding, // Right padding stays constant relative to edge
                  screenHeight * 0.015
              ),
              child: Row(
                children: [
                  // Search Bar
                  // Using Expanded ensures it stretches when the Sidebar gets wider
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: searchBarHeight,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(refWidth * 0.03),
                        border: Border.all(
                          color: _isSearchActive
                              ? AppColors.senaryColor
                              : AppColors.border.withValues(alpha: 0.3),
                          width: 0.5,
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
                            prefixIcon: Icon(
                                Icons.search,
                                size: searchIconSize,
                                color: _isSearchActive
                                    ? AppColors.senaryColor
                                    : AppColors.tertiaryColor
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

                  // Brand Icon
                  // Pushed to the right automatically by Expanded above
                  if (!_isSearchActive) ...[
                    SizedBox(width: refWidth * 0.03),
                    SvgPicture.asset(
                      'assets/cortex.svg',
                      height: brandIconHeight,
                      colorFilter: smartCortexFilter ?? ColorFilter.mode(
                          AppColors.primaryColor.inverted,
                          BlendMode.srcIn
                      ),
                    ),
                  ],

                  // Cancel Button
                  if (_isSearchActive) ...[
                    SizedBox(width: refWidth * 0.02),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        inboxViewModel.filterConversations('');
                        _searchFocusNode.unfocus();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: refWidth * 0.02),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        localizations.cancel,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: fontSizeBody,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // --- 2. Static Items ---
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
                        _SidebarItem(
                          label: localizations.newChat,
                          iconPath: 'assets/icons/chat.svg',
                          onTap: widget.onNewChatTap,
                          isPrimary: true,
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                        ),
                        SizedBox(height: verticalSpacing),
                        _SidebarItem(
                          label: localizations.library,
                          iconPath: 'assets/icons/library.svg',
                          onTap: widget.onLibraryTap,
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                        ),
                        SizedBox(height: verticalSpacing),
                        _SidebarItem(
                          label: localizations.selectionScreenNewsAndUpdates,
                          iconPath: 'assets/icons/news.svg',
                          onTap: widget.onNewsTap,
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                        ),
                        SizedBox(height: verticalSpacing),
                        _SidebarItem(
                          label: localizations.selectionScreenFeatureOffline,
                          iconPath: 'assets/icons/context.svg',
                          isSwitch: true,
                          switchValue: _isOfflineMode,
                          onSwitchChanged: (val) {
                            setState(() => _isOfflineMode = val);
                            widget.onOfflineModeChanged(val);
                          },
                          screenHeight: screenHeight,
                          referenceWidth: refWidth,
                        ),

                        SizedBox(height: screenHeight * 0.02),
                        Divider(
                            color: const Color(0xFF333333),
                            height: 1,
                            indent: horizontalPadding,
                            endIndent: horizontalPadding
                        ),
                        SizedBox(height: screenHeight * 0.01),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- 3. Chats Header ---
            if (!_isSearchActive)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding * 1.5,
                    vertical: screenHeight * 0.01
                ),
                child: Text(
                  localizations.chats.toUpperCase(),
                  style: GoogleFonts.roboto(
                    color: AppColors.tertiaryColor,
                    fontSize: fontSizeBody * 0.85,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

            // --- 4. Chat List with Fog ---
            Expanded(
              child: inboxViewModel.isLoading
                  ? Center(
                  child: CircularProgressIndicator(
                      strokeWidth: refWidth * 0.005,
                      color: Colors.white30
                  )
              )
                  : inboxViewModel.conversations.isEmpty
                  ? Center(
                child: Text(
                  _isSearchActive
                      ? localizations.noModelsFoundTitle
                      : localizations.noRecentChatsMessage,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: fontSizeBody
                  ),
                ),
              )
                  : ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    // Adjust stops to ensure fog stays at the edge even when wide
                    stops: [0.0, 0.9, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding * 0.5,
                      vertical: screenHeight * 0.005
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
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool switchValue;
  final Function(bool)? onSwitchChanged;
  final bool isPrimary;

  final double screenHeight;
  final double referenceWidth;

  const _SidebarItem({
    required this.label,
    required this.iconPath,
    this.onTap,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.isPrimary = false,
    required this.screenHeight,
    required this.referenceWidth,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary
        ? AppColors.primaryColor.inverted
        : AppColors.primaryColor.inverted.withValues(alpha: 0.85);

    final iconColor = isPrimary
        ? AppColors.primaryColor.inverted
        : AppColors.tertiaryColor;

    final double itemPaddingV = screenHeight * 0.012;
    final double itemPaddingH = referenceWidth * 0.05;
    final double iconSize = referenceWidth * 0.06;
    final double fontSize = referenceWidth * 0.04;
    final double borderRadius = referenceWidth * 0.03;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSwitch ? () => onSwitchChanged!(!switchValue) : onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.secondaryColor.withValues(alpha: 0.5),
        highlightColor: AppColors.secondaryColor.withValues(alpha: 0.3),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: itemPaddingV, horizontal: itemPaddingH),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: isPrimary ? AppColors.secondaryColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              SizedBox(width: referenceWidth * 0.04),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (isSwitch)
                SizedBox(
                  height: iconSize * 1.3,
                  width: iconSize * 2.0,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Switch(
                      value: switchValue,
                      onChanged: onSwitchChanged,
                      activeThumbColor: AppColors.background,
                      activeTrackColor: AppColors.senaryColor,
                      inactiveThumbColor: AppColors.tertiaryColor,
                      inactiveTrackColor: AppColors.secondaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
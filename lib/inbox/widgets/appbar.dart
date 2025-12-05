// lib/inbox/widgets/appbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../app.dart';
import '../../theme.dart';

/// The AppBar used in the Inbox screen.
class InboxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final VoidCallback onNewChatPressed;

  const InboxAppBar({
    super.key,
    required this.tabController,
    required this.onNewChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // RESPONSIVE LOGIC
    final bool isTablet = screenWidth >= 600;

    // --- DIMENSIONS & SCALING ---

    // Main Toolbar Height:
    // Phone: Default. Tablet: Explicitly requested screenWidth * 0.14
    final double toolbarHeight = isTablet ? screenWidth * 0.14 : kToolbarHeight;

    // Title Font Size:
    // Phone: Scales (6%). Tablet: Fixed Large (36).
    final double titleFontSize = isTablet ? 36.0 : screenWidth * 0.06;

    // New Chat Icon Size:
    // Phone: Scales (5.5%). Tablet: Fixed Large (32).
    final double iconSize = isTablet ? 32.0 : screenWidth * 0.055;

    // Tab Bar Container Height:
    // Phone: Scales (12%). Tablet: Fixed Taller (60).
    final double tabBarHeight = isTablet ? 60.0 : screenWidth * 0.12;

    // Tab Label Font Size:
    // Phone: Scales (4%). Tablet: Fixed (22).
    final double tabLabelFontSize = isTablet ? 22.0 : screenWidth * 0.04;

    // Tab Indicator Thickness:
    final double indicatorThickness = isTablet ? 2.0 : screenWidth * 0.004;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: toolbarHeight,

      // --- TITLE WITH TABLET PADDING ---
      // Wrapped in a Container to apply the exact same left padding as ModelsAppBar
      title: Container(
        padding: EdgeInsets.only(left: isTablet ? 16.0 : 0),
        child: Text(
          localizations.conversationsTitle,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryColor.inverted,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      actions: [
        IconButton(
          tooltip: localizations.startChat,
          icon: SvgPicture.asset(
            'assets/icons/new.svg',
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor.inverted,
              BlendMode.srcIn,
            ),
            width: iconSize,
            height: iconSize,
          ),
          onPressed: onNewChatPressed,
        ),
        SizedBox(width: isTablet ? 16.0 : 4), // Extra padding on tablet
      ],

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(tabBarHeight),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
            highlightColor: AppColors.quaternaryColor.withValues(alpha: 0.1),
          ),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: tabBarHeight,
            child: TabBar(
              controller: tabController,
              isScrollable: false,

              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: indicatorThickness,
                  color: AppColors.primaryColor.inverted,
                ),
                insets: EdgeInsets.zero,
              ),

              indicatorSize: TabBarIndicatorSize.tab,

              labelColor: AppColors.primaryColor.inverted,
              unselectedLabelColor:
              AppColors.primaryColor.inverted.withValues(alpha: 0.6),

              labelStyle: TextStyle(
                fontSize: tabLabelFontSize,
                fontWeight: FontWeight.w600,
              ),

              tabs: [
                Tab(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(localizations.allChats),
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(localizations.starredChats),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(160);
}
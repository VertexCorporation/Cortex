// lib/inbox/widgets/appbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../app.dart';
import '../../theme.dart';

/// The AppBar used in the Inbox screen, matching the legacy design from MenuScreen.
/// This includes:
/// - Title
/// - "New chat" action button
/// - Underline TabBar (All / Starred)
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
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,

      title: Text(
        localizations.conversationsTitle,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: AppColors.primaryColor.inverted,
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
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
            width: screenWidth * 0.055,
            height: screenWidth * 0.055,
          ),
          onPressed: onNewChatPressed,
        ),
        const SizedBox(width: 4),
      ],

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(screenWidth * 0.12),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
            highlightColor: AppColors.quaternaryColor.withValues(alpha: 0.1),
          ),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: TabBar(
              controller: tabController,
              isScrollable: false,

              // Underline indicator (legacy design)
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: screenWidth * 0.004,
                  color: AppColors.primaryColor.inverted,
                ),
                insets: EdgeInsets.zero,
              ),

              indicatorSize: TabBarIndicatorSize.tab,

              labelColor: AppColors.primaryColor.inverted,
              unselectedLabelColor:
              AppColors.primaryColor.inverted.withValues(alpha: 0.6),

              labelStyle: TextStyle(
                fontSize: screenWidth * 0.04,
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

  /// Standard AppBar height + TabBar height
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
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

  // Pre-calculated dimensions to ensure preferredSize matches build logic perfectly.
  final double _toolbarHeight;
  final double _tabBarHeight;
  final double _totalHeight;
  final bool _isTablet;
  final double _titleFontSize;
  final double _iconSize;
  final double _tabLabelFontSize;
  final double _indicatorThickness;

  /// We need the [context] in the constructor to calculate dimensions immediately
  /// for the [preferredSize] getter.
  InboxAppBar({
    super.key,
    required BuildContext context, // Added context to calculate sizes upfront
    required this.tabController,
    required this.onNewChatPressed,
  }) :
  // 1. Calculate Screen Metrics
        _isTablet = MediaQuery.of(context).size.width >= 600,

  // 2. Calculate Toolbar Height
  // Phone: Standard kToolbarHeight (56.0) -> Compact & Clean
  // Tablet: Dynamic (screenWidth * 0.14) -> Spacious
        _toolbarHeight = MediaQuery.of(context).size.width >= 600
            ? MediaQuery.of(context).size.width * 0.14
            : kToolbarHeight,

  // 3. Calculate TabBar Height
  // Phone: Standard ~46.0 (or dynamic 12% if you prefer scaling, but 46 is safer for phones)
  // Tablet: Fixed 60.0
        _tabBarHeight = MediaQuery.of(context).size.width >= 600
            ? 60.0
            : (MediaQuery.of(context).size.width * 0.12).clamp(44.0, 52.0), // Clamped for consistency on phones

  // 4. Calculate Total Height for PreferredSize
        _totalHeight = (MediaQuery.of(context).size.width >= 600
            ? MediaQuery.of(context).size.width * 0.14
            : kToolbarHeight) +
            (MediaQuery.of(context).size.width >= 600
                ? 60.0
                : (MediaQuery.of(context).size.width * 0.12).clamp(44.0, 52.0)),

  // 5. Calculate Font & Icon Sizes
        _titleFontSize = MediaQuery.of(context).size.width >= 600
            ? 36.0
            : MediaQuery.of(context).size.width * 0.06,
        _iconSize = MediaQuery.of(context).size.width >= 600
            ? 32.0
            : MediaQuery.of(context).size.width * 0.055,
        _tabLabelFontSize = MediaQuery.of(context).size.width >= 600
            ? 22.0
            : MediaQuery.of(context).size.width * 0.04,
        _indicatorThickness = MediaQuery.of(context).size.width >= 600
            ? 2.0
            : MediaQuery.of(context).size.width * 0.004;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: _toolbarHeight, // Use pre-calculated height

      // --- TITLE WITH TABLET PADDING ---
      title: Container(
        padding: EdgeInsets.only(left: _isTablet ? 16.0 : 0),
        child: Text(
          localizations.conversationsTitle,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryColor.inverted,
            fontSize: _titleFontSize,
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
            width: _iconSize,
            height: _iconSize,
          ),
          onPressed: onNewChatPressed,
        ),
        SizedBox(width: _isTablet ? 16.0 : 4), // Extra padding on tablet
      ],

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_tabBarHeight),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: AppColors.quaternaryColor.withValues(alpha: 0.3),
            highlightColor: AppColors.quaternaryColor.withValues(alpha: 0.1),
          ),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: _tabBarHeight,
            child: TabBar(
              controller: tabController,
              isScrollable: false,

              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: _indicatorThickness,
                  color: AppColors.primaryColor.inverted,
                ),
                insets: EdgeInsets.zero,
              ),

              indicatorSize: TabBarIndicatorSize.tab,

              labelColor: AppColors.primaryColor.inverted,
              unselectedLabelColor:
              AppColors.primaryColor.inverted.withValues(alpha: 0.6),

              labelStyle: TextStyle(
                fontSize: _tabLabelFontSize,
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
  // Dynamic size based on device type calculated in constructor.
  // Phone: ~100-108px (Compact)
  // Tablet: ~170px+ (Spacious)
  Size get preferredSize => Size.fromHeight(_totalHeight);
}
// lib/library/screen/models/widgets/appbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../app.dart';
import '../../../../theme.dart';

/// A custom AppBar for the ModelsScreen, encapsulating the title and the 'Create' action button.
class ModelsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String createButtonText;
  final VoidCallback onOpenCreateScreen;

  // Pre-calculated metrics
  final double _toolbarHeight;
  final bool _isTablet;
  final double _titleFontSize;

  // Button Metrics
  final double _buttonWidth;
  final double _buttonHeight;
  final double _circleSize;
  final double _textSize;
  final double _iconSize;
  final double _actionAreaPadding;

  ModelsAppBar({
    super.key,
    required BuildContext context,
    required this.title,
    required this.createButtonText,
    required this.onOpenCreateScreen,
  }) :
        _isTablet = MediaQuery.of(context).size.width >= 600,

        _toolbarHeight = MediaQuery.of(context).size.width >= 600
            ? MediaQuery.of(context).size.width * 0.14
            : kToolbarHeight,

        _titleFontSize = MediaQuery.of(context).size.width >= 600
            ? 32.0 // Slightly smaller for better centering
            : MediaQuery.of(context).size.width * 0.06,

        _buttonWidth = MediaQuery.of(context).size.width >= 600
            ? 180.0
            : 110.0, // Adjusted width to fit with centered title

        _buttonHeight = MediaQuery.of(context).size.width >= 600
            ? 56.0
            : 34.0,

        _circleSize = MediaQuery.of(context).size.width >= 600
            ? 56.0
            : 34.0,

        _textSize = MediaQuery.of(context).size.width >= 600
            ? 18.0
            : 13.0,

        _iconSize = MediaQuery.of(context).size.width >= 600
            ? 26.0
            : 16.0,

        _actionAreaPadding = MediaQuery.of(context).size.width >= 600 ? 24.0 : 16.0;

  @override
  Widget build(BuildContext context) {
    // The total width reserved for the action area (button + padding)
    final double actionAreaTotalWidth = _buttonWidth + _actionAreaPadding;

    // Icon size for the menu button
    final double leadingIconSize = _isTablet ? 36.0 : 24.0;

    return AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      centerTitle: true, // CENTERED TITLE
      backgroundColor: AppColors.background,
      elevation: 0,

      // --- LEADING (Menu/Back) ---
      // If used in a Scaffold with a Drawer, this will automatically show the menu icon.
      // Or we can force it if we are pushing this screen.
      leading: Builder(
        builder: (context) {
          // Check if we can pop (Back) or if we should open drawer (Menu)
          final canPop = Navigator.of(context).canPop();

          return IconButton(
            icon: SvgPicture.asset(
              'assets/icons/sidebar.svg', // Use standard icon
              width: leadingIconSize,
              height: leadingIconSize,
              colorFilter: ColorFilter.mode(
                  AppColors.primaryColor.inverted,
                  BlendMode.srcIn
              ),
            ),
            onPressed: () {
              if (canPop) {
                Navigator.of(context).pop();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          );
        },
      ),

      // --- TITLE ---
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: AppColors.primaryColor.inverted,
          fontSize: _titleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),

      // --- CREATE BUTTON ---
      actions: [
        Container(
          width: actionAreaTotalWidth,
          height: _toolbarHeight,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: _isTablet ? 24.0 : 16.0),
          child: SizedBox(
            width: _buttonWidth,
            height: _buttonHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Pill Background
                Positioned(
                  right: 0,
                  child: Container(
                    width: _buttonWidth - (_circleSize / 2),
                    height: _buttonHeight,
                    decoration: BoxDecoration(
                      color: AppColors.senaryColor.withValues(alpha:0.9),
                      borderRadius: BorderRadius.circular(_isTablet ? 30 : 20),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        left: _isTablet ? 12 : 4,
                        right: _circleSize * 0.6 // Space for the circle overlap
                    ),
                    child: Text(
                      createButtonText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _textSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // 2. Circle Icon
                Positioned(
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onOpenCreateScreen,
                      borderRadius: BorderRadius.circular(100),
                      splashFactory: NoSplash.splashFactory,
                      child: Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.senaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/plus.svg',
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            width: _iconSize,
                            height: _iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Full Touch Area
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onOpenCreateScreen,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(_isTablet ? 30 : 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(_toolbarHeight);
  }
}
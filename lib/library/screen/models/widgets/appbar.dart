// lib/models/screen/widget/appbar.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    required BuildContext context, // Added context for pre-calculation
    required this.title,
    required this.createButtonText,
    required this.onOpenCreateScreen,
  }) :
  // 1. Determine Device Type
        _isTablet = MediaQuery.of(context).size.width >= 600,

  // 2. Calculate Toolbar Height
  // Tablet: Dynamic (approx 14%). Phone: Standard 56.0.
        _toolbarHeight = MediaQuery.of(context).size.width >= 600
            ? MediaQuery.of(context).size.width * 0.14
            : kToolbarHeight,

  // 3. Calculate Font Size
        _titleFontSize = MediaQuery.of(context).size.width >= 600
            ? 36.0
            : MediaQuery.of(context).size.width * 0.07,

  // 4. Calculate Button Dimensions
  // We keep the scaling logic for the button internals so it looks nice on different phone sizes,
  // but we ensure it fits within the 56px toolbar.
        _buttonWidth = MediaQuery.of(context).size.width >= 600
            ? 200.0
            : 120.0 * ((MediaQuery.of(context).size.width / 400.0).clamp(0.8, 1.2)),

        _buttonHeight = MediaQuery.of(context).size.width >= 600
            ? 60.0
            : 36.0 * ((MediaQuery.of(context).size.width / 400.0).clamp(0.8, 1.2)),

        _circleSize = MediaQuery.of(context).size.width >= 600
            ? 60.0
            : 36.0 * ((MediaQuery.of(context).size.width / 400.0).clamp(0.8, 1.2)),

        _textSize = MediaQuery.of(context).size.width >= 600
            ? 20.0
            : MediaQuery.of(context).size.width * 0.036,

        _iconSize = MediaQuery.of(context).size.width >= 600
            ? 28.0
            : MediaQuery.of(context).size.width * 0.035,

        _actionAreaPadding = MediaQuery.of(context).size.width >= 600 ? 32.0 : 20.0;

  @override
  Widget build(BuildContext context) {
    // The entire action area width includes the button + padding
    final double actionAreaWidth = _buttonWidth + _actionAreaPadding;

    return AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      centerTitle: false,
      backgroundColor: AppColors.background,
      elevation: 0,

      // --- TITLE ---
      title: Container(
        height: _toolbarHeight,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: _isTablet ? 16.0 : 0),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryColor.inverted,
            fontSize: _titleFontSize,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),

      // --- CREATE BUTTON ---
      actions: [
        Container(
          width: actionAreaWidth,
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
                      color: AppColors.senaryColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(_isTablet ? 30 : 20),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        left: _isTablet ? 16 : 2,
                        // Increased right padding for tablet to give text more breathing room
                        right: _isTablet ? _circleSize * 0.9 : _circleSize * 0.7
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
                                color: Colors.black.withValues(alpha: 0.1),
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
  // Dynamic size: ~120px+ for Tablets, 56px for Phones.
  Size get preferredSize {
    return Size.fromHeight(_toolbarHeight);
  }
}
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

  const ModelsAppBar({
    super.key,
    required this.title,
    required this.createButtonText,
    required this.onOpenCreateScreen,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // RESPONSIVE LOGIC
    final bool isTablet = screenWidth >= 600;

    // --- Dynamic Height Logic ---
    final double toolbarHeight = isTablet
        ? screenWidth * 0.14
        : kToolbarHeight * ((screenWidth / 400.0).clamp(0.8, 1.2));

    // --- Tablet Scaling Factors ---
    final double titleFontSize = isTablet ? 36.0 : screenWidth * 0.07;

    // Create Button Dimensions
    final double buttonWidth = isTablet ? 200.0 : 120.0 * ((screenWidth / 400.0).clamp(0.8, 1.2));
    final double buttonHeight = isTablet ? 60.0 : 36.0 * ((screenWidth / 400.0).clamp(0.8, 1.2));
    final double circleSize = isTablet ? 60.0 : 36.0 * ((screenWidth / 400.0).clamp(0.8, 1.2));

    final double textSize = isTablet ? 20.0 : screenWidth * 0.036;
    final double iconSize = isTablet ? 28.0 : screenWidth * 0.035;

    // The entire action area width
    final double actionAreaWidth = buttonWidth + (isTablet ? 32.0 : 20.0);

    return AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: toolbarHeight,
      centerTitle: false,
      backgroundColor: AppColors.background,
      elevation: 0,

      // --- TITLE ---
      title: Container(
        height: toolbarHeight,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: isTablet ? 16.0 : 0),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryColor.inverted,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),

      // --- CREATE BUTTON ---
      actions: [
        Container(
          width: actionAreaWidth,
          height: toolbarHeight,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: isTablet ? 24.0 : 16.0),
          child: SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Pill Background
                Positioned(
                  right: 0,
                  child: Container(
                    width: buttonWidth - (circleSize / 2),
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: AppColors.senaryColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(isTablet ? 30 : 20),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        left: isTablet ? 16 : 10,
                        // Increased right padding for tablet to give text more breathing room
                        right: isTablet ? circleSize * 0.9 : circleSize * 0.7
                    ),
                    child: Text(
                      createButtonText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
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
                        width: circleSize,
                        height: circleSize,
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
                            width: iconSize,
                            height: iconSize,
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
                      borderRadius: BorderRadius.circular(isTablet ? 30 : 20),
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
    return const Size.fromHeight(80);
  }
}
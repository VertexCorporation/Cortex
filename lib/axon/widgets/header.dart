// lib/axon/widgets/header.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../app.dart';
import '../../../webview.dart';

class AxonHeader extends StatelessWidget {
  final double referenceWidth;
  final double screenHeight;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchActive;
  final VoidCallback onExitSearchTap;
  final ValueChanged<String> onSearchChanged;

  const AxonHeader({
    super.key,
    required this.referenceWidth,
    required this.screenHeight,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchActive,
    required this.onExitSearchTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // --- Layout Constants ---
    final double horizontalPadding = referenceWidth * 0.05;
    final double searchBarHeight = screenHeight * 0.050;
    final double searchIconSize = referenceWidth * 0.06;
    final double brandIconHeight = screenHeight * 0.035;
    final double fontSizeBody = referenceWidth * 0.045;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        screenHeight * 0.025,
        horizontalPadding * 1.5,
        screenHeight * 0.015,
      ),
      child: Row(
        children: [
          // --- Search Bar Container ---
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(referenceWidth * 0.06),
                border: Border.all(
                  color: isSearchActive
                      ? AppColors.primaryColor.inverted
                      : AppColors.border.withValues(alpha: 0.3),
                  width: isSearchActive ? 1.0 : 0.5,
                ),
              ),
              child: Center(
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
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
                    // --- Animated Icon (Search Glass <-> Arrow) ---
                    prefixIcon: GestureDetector(
                      onTap: isSearchActive ? onExitSearchTap : null,
                      behavior: HitTestBehavior
                          .translucent, // Ensure touches are caught
                      child: Container(
                        // Expand touch target
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        color:
                            Colors.transparent, // Visual debug or transparent
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) {
                            return ScaleTransition(scale: anim, child: child);
                          },
                          child: isSearchActive
                              ? Transform.rotate(
                                  angle: (Directionality.of(context) ==
                                          TextDirection.rtl)
                                      ? -math.pi / 2
                                      : math.pi / 2,
                                  child: SvgPicture.asset(
                                    'assets/icons/arrov.svg',
                                    key: const ValueKey('arrow'),
                                    width: searchIconSize,
                                    height: searchIconSize,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.primaryColor.inverted,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  key: const ValueKey('search'),
                                  size: searchIconSize,
                                  color: AppColors.tertiaryColor,
                                ),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: onSearchChanged,
                ),
              ),
            ),
          ),

          // --- Brand Icon (Collapses on Search) ---
          // OPTIMIZATION: RepaintBoundary prevents the complex SVG from being
          // re-rasterized every frame while its parent size changes.
          RepaintBoundary(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.centerRight, // Shrink from Left
              child: SizedBox(
                width: isSearchActive ? 0 : null,
                child: AnimatedSlide(
                  offset: isSearchActive ? const Offset(-0.5, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    curve: isSearchActive ? Curves.easeInQuint : Curves.easeOut,
                    opacity: isSearchActive ? 0.0 : 1.0,
                    child: Row(
                      children: [
                        SizedBox(width: referenceWidth * 0.03),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            showAppWebViewModal(
                              context,
                              "Vertex",
                              "https://vertexishere.com",
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/cortex.svg',
                            height: brandIconHeight,
                            colorFilter: ColorFilter.mode(
                              AppColors.primaryColor.inverted,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

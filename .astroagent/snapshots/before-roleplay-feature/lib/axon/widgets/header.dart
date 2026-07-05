// lib/axon/widgets/header.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// Logic & Theme
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/chat/providers/session.dart';

import '../../app.dart';
import '../helpers.dart';

class AxonHeader extends StatelessWidget {
  final double referenceWidth;
  final double screenHeight;
  final double screenWidth;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Animation<double> searchModeAnimation;
  final bool isSearchActive;
  final VoidCallback onExitSearchTap;
  final VoidCallback onCloseAxon;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSettingsTap;

  const AxonHeader({
    super.key,
    required this.referenceWidth,
    required this.screenHeight,
    required this.screenWidth,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchModeAnimation,
    required this.isSearchActive,
    required this.onExitSearchTap,
    required this.onCloseAxon,
    required this.onSearchChanged,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // --- User Data for Avatar ---
    final userProvider = context.watch<UserProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final bool isUserStateReady = userProvider.isUserStateReady;
    final bool isUserSubscribed =
        isUserStateReady && sessionProvider.isUserSubscribed;

    String initials;
    if (!isUserStateReady) {
      initials = '';
    } else if (userProvider.isAnonymous) {
      final String anonString = localizations.anonymousEntity;
      initials = anonString.isNotEmpty ? anonString[0].toUpperCase() : '?';
    } else {
      initials = userProvider.profileInitial;
    }

    // --- Layout Constants ---
    final double horizontalPadding = referenceWidth * 0.05;
    final double iconHeight = screenHeight * 0.032;

    final double bubbleHeight = screenHeight * 0.054;
    final double fontSizeSearch = referenceWidth * 0.04;

    // Pill corner radius
    final double radius = bubbleHeight / 2;

    // Colors
    final invertedColor = AppColors.primaryColor.inverted;
    final borderColor = invertedColor.withValues(alpha: 0.12);
    final splashColor = invertedColor.withValues(alpha: 0.15);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        screenHeight * 0.02,
        horizontalPadding,
        screenHeight * 0.012,
      ),
      child: SizedBox(
        height: bubbleHeight,
        child: AnimatedBuilder(
          animation: searchModeAnimation,
          builder: (context, child) {
            final double searchProgress =
                Curves.easeInOutCubic.transform(searchModeAnimation.value);

            return Stack(
              children: [
                // --- NORMAL MODE: Logo (Left) + Dual Pill (Right) ---
                Positioned.fill(
                  child: Opacity(
                    opacity: (1.0 - searchProgress * 2.0).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: searchProgress > 0.3,
                      child: Stack(
                        children: [
                          // 1. LEFT: CORTEX LOGO
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: onCloseAxon,
                                onLongPress: () {
                                  HapticFeedback.heavyImpact();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.background,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                        side: BorderSide(color: AppColors.border, width: 1.0),
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(Icons.auto_awesome, color: AppColors.primaryColor.inverted),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Cortex Protocol',
                                            style: TextStyle(color: AppColors.primaryColor.inverted),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'Astro 8 PRO: Developer Mode Activated.\n\nVertexCorporation — 2026',
                                        style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha: 0.8)),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(
                                            'OK',
                                            style: TextStyle(color: AppColors.primaryColor.inverted),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                behavior: HitTestBehavior.opaque,
                                child: SvgPicture.asset(
                                  'assets/cortext.svg',
                                  height: iconHeight * 1.1,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.primaryColor.inverted,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. RIGHT: DUAL ACTION PILL (Search + Avatar)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              height: bubbleHeight,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(radius),
                                border:
                                    Border.all(color: borderColor, width: 0.8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(radius),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // LEFT: SEARCH BUTTON
                                    SizedBox(
                                      width: bubbleHeight,
                                      height: bubbleHeight,
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          searchFocusNode.requestFocus();
                                        },
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(radius),
                                          bottomLeft: Radius.circular(radius),
                                        ),
                                        splashColor: splashColor,
                                        highlightColor:
                                            splashColor.withValues(alpha: 0.05),
                                        child: Center(
                                          child: Icon(
                                            Icons.search_rounded,
                                            size: referenceWidth * 0.06,
                                            color:
                                                AppColors.primaryColor.inverted,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // MIDDLE: DIVIDER
                                    Container(
                                      width: 1,
                                      height: bubbleHeight * 0.6,
                                      color: borderColor,
                                    ),

                                    // RIGHT: USER AVATAR (directly, no extra frame)
                                    SizedBox(
                                      width: bubbleHeight,
                                      height: bubbleHeight,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Avatar — no extra border frame
                                          AxonAvatar(
                                            initials: initials,
                                            isSubscribed: isUserSubscribed,
                                            size:
                                                bubbleHeight, // Exactly pill height
                                            fontSize: bubbleHeight *
                                                0.35, // Slightly larger letter
                                          ),
                                          // Tap overlay
                                          Positioned.fill(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  onSettingsTap();
                                                },
                                                borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(radius),
                                                  bottomRight:
                                                      Radius.circular(radius),
                                                ),
                                                splashColor: splashColor,
                                                highlightColor: splashColor
                                                    .withValues(alpha: 0.05),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- SEARCH MODE: Full-width search bar ---
                Positioned.fill(
                  child: Opacity(
                    opacity: searchProgress,
                    child: IgnorePointer(
                      ignoring: searchProgress < 0.3,
                      child: Container(
                        height: bubbleHeight,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(
                            color: isSearchActive
                                ? AppColors.primaryColor.inverted
                                    .withValues(alpha: 0.3)
                                : AppColors.border.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // LEFT: Back arrow (arrov.svg)
                            Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onExitSearchTap,
                                child: Container(
                                  width: bubbleHeight,
                                  height: bubbleHeight,
                                  alignment: Alignment.center,
                                  child: Transform.rotate(
                                    angle: isRtl ? -math.pi / 2 : math.pi / 2,
                                    child: SvgPicture.asset(
                                      'assets/icons/arrov.svg',
                                      width: referenceWidth * 0.045,
                                      height: referenceWidth * 0.045,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primaryColor.inverted,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // CENTER: Search input field
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                focusNode: searchFocusNode,
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                  fontSize: fontSizeSearch,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: localizations.searchHint,
                                  hintStyle: TextStyle(
                                    color: AppColors.tertiaryColor,
                                    fontSize: fontSizeSearch,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                onChanged: onSearchChanged,
                              ),
                            ),

                            // RIGHT: Search icon
                            Padding(
                              padding:
                                  EdgeInsets.only(right: bubbleHeight * 0.25),
                              child: Icon(
                                Icons.search_rounded,
                                size: referenceWidth * 0.055,
                                color: AppColors.tertiaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

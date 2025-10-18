// appbar.dart
//
// This file defines a custom AppBar widget for the chat application.
// The widget is responsible for rendering the navigation bar, displaying
// title information, and handling actions such as exit and account tap.
// It now delegates chat-specific title rendering to the ChatTitle widget
// and displays an animated border for subscribed users.

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../../extensions.dart';
import '../../../theme.dart';
import '../../chat.dart';
import 'chat.dart';
import 'credits.dart';

/// A self-contained, animated painter for creating a rotating gradient border.
/// It is used by the user avatar to indicate a subscription status.
class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;

  AnimatedBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    final Rect rect = Offset.zero & size;
    final double radius = size.width / 2;

    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: AppColors.animatedBorderGradientColors,
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(animationValue),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final String? modelTitle;
  final String? modelImagePath;
  final GlobalKey exitButtonKey;
  final GlobalKey accountButtonKey;
  final Map<String, dynamic>? userData;
  final VoidCallback onExit;
  final VoidCallback onAccountTap;
  final VoidCallback onTitleTap;
  final String appTitle;
  final GlobalKey extensionKey;
  final Extensions extensions;
  final VoidCallback onCreditsInfoTapped;
  final VoidCallback? onInfoPanelWillShow;
  final VoidCallback? onInfoPanelDidHide;
  final ValueNotifier<AppBarMode> appBarModeNotifier;
  final GlobalKey<ChatTitleState> chatTitleKey;

  // NEW: Add the callback property to the Appbar widget itself.
  final VoidCallback onShowExtensionInfoRequest;

  const Appbar({
    Key? key,
    this.modelTitle,
    this.modelImagePath,
    required this.exitButtonKey,
    required this.accountButtonKey,
    this.userData,
    required this.onExit,
    required this.onAccountTap,
    required this.onTitleTap,
    required this.appTitle,
    required this.extensionKey,
    required this.extensions,
    required this.onCreditsInfoTapped,
    this.onInfoPanelWillShow,
    this.onInfoPanelDidHide,
    required this.chatTitleKey,
    required this.appBarModeNotifier,
    required this.onShowExtensionInfoRequest, // NEW: Add to the constructor.
  }) : super(key: key);

  @override
  State<Appbar> createState() => AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppbarState extends State<Appbar> with TickerProviderStateMixin {
  final GlobalKey<CreditsBarState> _creditsBarKey = GlobalKey<CreditsBarState>();

  late AnimationController _animationController;
  late AnimationController _borderAnimationController; // For the subscription border
  late Animation<double> _borderAnimation; // Animation tween
  bool _isCreditsPanelVisible = false;

  // Public method to check if any panel controlled by the AppBar is visible.
  bool isAPanelShowing() {
    // It's visible if either the credits panel OR the extensions panel is open.
    return _isCreditsPanelVisible || widget.extensions.isPanelVisible;
  }

  // Public method to close any open panel. This will be called from ChatScreen.
  void closeAnyOpenPanels() {
    if (_isCreditsPanelVisible) {
      _creditsBarKey.currentState?.hideCreditsInfo();
    }
    if (widget.extensions.isPanelVisible) {
      widget.extensions.closePanel();
    }
  }

  /// Checks the user's subscription level and expiry date to determine
  /// if they have an active subscription.
  bool get _isUserSubscribed {
    if (widget.userData == null) return false;
    final int level = widget.userData!['hasCortexSubscription'] as int? ?? 0;
    if (level == 0) return false;

    // A subscription level exists, now check the expiry date safely.
    final dynamic expiresAtValue = widget.userData!['subscriptionExpiresAt'];
    Timestamp? parsedTimestamp;

    if (expiresAtValue is Timestamp) {
      parsedTimestamp = expiresAtValue;
    } else if (expiresAtValue is String) {
      final DateTime? parsedDate = DateTime.tryParse(expiresAtValue);
      if (parsedDate != null) {
        parsedTimestamp = Timestamp.fromDate(parsedDate);
      }
    }

    if (parsedTimestamp == null || parsedTimestamp.toDate().isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  /// Helper to calculate subscription status from a userData map.
  bool _calculateSubscriptionStatus(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    final int level = userData['hasCortexSubscription'] as int? ?? 0;
    if (level == 0) return false;

    final dynamic expiresAtValue = userData['subscriptionExpiresAt'];
    Timestamp? parsedTimestamp;

    if (expiresAtValue is Timestamp) {
      parsedTimestamp = expiresAtValue;
    } else if (expiresAtValue is String) {
      final DateTime? parsedDate = DateTime.tryParse(expiresAtValue);
      if (parsedDate != null) {
        parsedTimestamp = Timestamp.fromDate(parsedDate);
      }
    }

    if (parsedTimestamp == null || parsedTimestamp.toDate().isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _borderAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_borderAnimationController);
    if (_isUserSubscribed) {
      _borderAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(Appbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasSubscribed = _calculateSubscriptionStatus(oldWidget.userData);
    final bool isNowSubscribed = _isUserSubscribed;

    if (!wasSubscribed && isNowSubscribed) {
      _borderAnimationController.repeat();
    } else if (wasSubscribed && !isNowSubscribed) {
      _borderAnimationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _borderAnimationController.dispose();
    _creditsBarKey.currentState?.hideCreditsInfo(isDisposing: true);
    super.dispose();
  }

  /// Hides any open panels (extensions or credits info)
  void closeAllPanels() {
    if (widget.extensions.isPanelVisible) {
      widget.extensions.closePanel();
    }
    _creditsBarKey.currentState?.hideCreditsInfo();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    void handleExitPress() {
      if (_isCreditsPanelVisible) {
        _creditsBarKey.currentState?.hideCreditsInfo();
      } else {
        widget.onExit();
      }
    }

    return ValueListenableBuilder<AppBarMode>(
      valueListenable: widget.appBarModeNotifier,
      builder: (context, mode, child) {
        Widget leadingWidget;
        Widget titleContentWidget;

        switch (mode) {
          case AppBarMode.notSelected:
            leadingWidget = CreditsBar(
              key: _creditsBarKey,
              onCreditsInfoTapped: widget.onCreditsInfoTapped,
              onPanelShown: () {
                if (mounted) setState(() => _isCreditsPanelVisible = true);
              },
              onPanelHidden: () {
                if (mounted) setState(() => _isCreditsPanelVisible = false);
              },
            );
            titleContentWidget = Text(
              widget.appTitle,
              key: const ValueKey('app_title'),
              style: GoogleFonts.mavenPro(
                  color: AppColors.primaryColor.inverted,
                  fontSize: screenWidth * 0.08),
            );
            break;

          case AppBarMode.dynamicChat:
            leadingWidget = Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    key: const ValueKey('exit_dynamic_chat_button'),
                    icon: Icon(Icons.arrow_back,
                        color: AppColors.primaryColor.inverted,
                        size: screenWidth * 0.06),
                    onPressed: handleExitPress),
              ),
            );
            titleContentWidget = Container(
              key: widget.chatTitleKey,
              child: Column(
                key: const ValueKey('dynamic_chat_title_column'),
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.appTitle,
                    style: GoogleFonts.mavenPro(
                      color: AppColors.primaryColor.inverted,
                      fontSize: screenWidth * 0.08,
                      height: 1.0,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: const ValueKey('dynamic_subtitle'),
                      child: Container(
                        margin: const EdgeInsets.only(top: 2.0),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: Text(
                          localizations.dynamicChatTitle + ' (Beta)',
                          style: GoogleFonts.mavenPro(
                            color: AppColors.primaryColor.inverted.withOpacity(0.8),
                            fontSize: screenWidth * 0.025,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
            break;

          case AppBarMode.inSelection:
          case AppBarMode.modelSelected:
            leadingWidget = Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    key: const ValueKey('back_button'),
                    icon: Icon(Icons.arrow_back,
                        color: AppColors.primaryColor.inverted,
                        size: screenWidth * 0.06),
                    onPressed: handleExitPress),
              ),
            );
            titleContentWidget = mode == AppBarMode.inSelection
                ? FittedBox(
              key: const ValueKey('explore_title'),
              fit: BoxFit.scaleDown,
              child: Text(
                localizations.explore,
                style: GoogleFonts.mavenPro(
                  color: AppColors.primaryColor.inverted,
                  fontSize: screenWidth * 0.08,
                ),
              ),
            )
            // UPDATED: Pass the required 'onShowInfoRequest' callback to the ChatTitle widget.
                : ChatTitle(
              key: widget.chatTitleKey,
              modelTitle: widget.modelTitle,
              extensions: widget.extensions,
              onTitleTap: widget.onTitleTap,
              extensionKey: widget.extensionKey,
              onShowInfoRequest: widget.onShowExtensionInfoRequest, // <-- THE FIX IS HERE
            );
            break;
        }

        return AppBar(
          toolbarHeight: screenHeight * 0.08,
          backgroundColor: AppColors.background,
          centerTitle: true,
          scrolledUnderElevation: 0,
          leadingWidth: screenWidth * 0.3,
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(-0.5, 0.0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: child,
                ),
              );
            },
            child: leadingWidget,
          ),
          title: GestureDetector(
            onTap: (mode == AppBarMode.modelSelected || mode == AppBarMode.dynamicChat)
                ? widget.onTitleTap
                : null,
            child: Container(
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: titleContentWidget,
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: screenWidth * 0.3,
              child: Stack(
                children: [
                  Positioned(
                    right: 16.0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                        key: widget.accountButtonKey,
                        onTap: widget.onAccountTap,
                        child: _buildUserAvatar(
                            context, screenWidth, screenHeight)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserAvatar(BuildContext context, double screenWidth, double screenHeight) {
    String initial = '?';
    if (widget.userData != null) {
      final String? username = widget.userData!['username'] as String?;
      final String? displayName = widget.userData!['displayName'] as String?;
      final String? email = widget.userData!['email'] as String?;
      String nameSource = "";
      if (username != null && username.isNotEmpty) {
        nameSource = username;
      } else if (displayName != null && displayName.isNotEmpty) {
        nameSource = displayName;
      } else if (email != null && email.isNotEmpty) {
        nameSource = email;
      }
      if (nameSource.isNotEmpty) {
        initial = nameSource[0].toUpperCase();
      }
    }

    Widget avatarCore = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: CircleAvatar(
        radius: screenWidth * 0.05,
        backgroundColor: AppColors.quaternaryColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            initial,
            key: ValueKey<String>(initial),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: AppColors.primaryColor.inverted,
            ),
          ),
        ),
      ),
    );

    Widget finalAvatar;

    if (_isUserSubscribed) {
      finalAvatar = AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedBorderPainter(animationValue: _borderAnimation.value),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: child,
            ),
          );
        },
        child: avatarCore,
      );
    } else {
      finalAvatar = avatarCore;
    }

    return Center(child: finalAvatar);
  }
}
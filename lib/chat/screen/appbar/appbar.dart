// appbar.dart
//
// This file defines a custom AppBar widget for the chat application.
// The widget is responsible for rendering the navigation bar, displaying
// title information, and handling actions such as exit and account tap.
// It now delegates chat-specific title rendering to the ChatTitle widget.

import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../../extensions.dart';
import '../../../theme.dart';
import '../../chat.dart';
import 'chat.dart';
import 'credits.dart';

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
    required this.appBarModeNotifier,
  }) : super(key: key);

  @override
  State<Appbar> createState() => _AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarState extends State<Appbar> with SingleTickerProviderStateMixin { // MODIFIED: TickerProviderStateMixin is enough now.
  final GlobalKey<CreditsBarState> _creditsBarKey = GlobalKey<CreditsBarState>();

  // NEW: A key to communicate with the ChatTitle child widget's state.
  final GlobalKey<ChatTitleState> _chatTitleKey = GlobalKey<ChatTitleState>();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(Appbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasInChatMode = oldWidget.appBarModeNotifier.value == AppBarMode.modelSelected;
    final bool isInChatMode = widget.appBarModeNotifier.value == AppBarMode.modelSelected;

    // If we just entered chat mode and the model has extensions, tell the
    // ChatTitle widget to show its info panel.
    if (!wasInChatMode && isInChatMode && widget.extensions.currentExtensions.isNotEmpty) {
      _chatTitleKey.currentState?.showExtensionInfoIfNeeded();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _creditsBarKey.currentState?.hideCreditsInfo(isDisposing: true);
    _chatTitleKey.currentState?.hideExtensionInfo(isDisposing: true);
    super.dispose();
  }

  /// Hides any open panels (extensions or credits info)
  void closeAllPanels() {
    if (widget.extensions.isPanelVisible) {
      widget.extensions.closePanel();
    }
    _creditsBarKey.currentState?.hideCreditsInfo();
    _chatTitleKey.currentState?.hideExtensionInfo();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

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
            );
            titleContentWidget = Text(widget.appTitle,
                style: GoogleFonts.mavenPro(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.08));
            break;

          case AppBarMode.inSelection:
          case AppBarMode.modelSelected:
            leadingWidget = Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  key: const ValueKey('back_button'),
                  icon: Icon(Icons.arrow_back,
                      color: AppColors.primaryColor.inverted,
                      size: screenWidth * 0.06),
                  onPressed: widget.onExit),
            );

            titleContentWidget = mode == AppBarMode.inSelection
                ? Text(localizations.explore,
                style: GoogleFonts.mavenPro(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.08))
                : ChatTitle(
              key: _chatTitleKey,
              modelTitle: widget.modelTitle,
              extensions: widget.extensions,
              onTitleTap: widget.onTitleTap,
              extensionKey: widget.extensionKey,
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

          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            // --- THE ANIMATION FIX ---
            // Upgraded the transition to include a subtle scale animation
            // along with the fade for a more polished and modern feel.
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              key: ValueKey<AppBarMode>(mode),
              onTap: mode == AppBarMode.modelSelected ? widget.onTitleTap : null,
              child: titleContentWidget,
            ),
          ),

          actions: [
            SizedBox(
              width: screenWidth * 0.3,
              child: Stack(
                children: [
                  Positioned(
                    right: 12.0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                        key: widget.accountButtonKey,
                        onTap: widget.onAccountTap,
                        child: _buildUserAvatar(
                            context, screenWidth, screenHeight)
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds only the core content of the user avatar (the CircleAvatar)
  /// without the outer Padding widget. This allows us to position it precisely
  /// with a Positioned widget in the AppBar.
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

    return Center(
      child: Container(
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
      ),
    );
  }
}
// lib/chat/screen/appbar/appbar.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../providers/session.dart';
import '../../../../main.dart'; // To access mainScreenKey

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey exitButtonKey;
  final GlobalKey accountButtonKey;
  final VoidCallback onAccountTap;
  final VoidCallback onTitleTap; // Added: Required for anchoring dynamic panel
  final String appTitle;

  // Kept for controller compatibility
  final GlobalKey extensionKey;

  const Appbar({
    super.key,
    required this.exitButtonKey,
    required this.accountButtonKey,
    required this.onAccountTap,
    required this.onTitleTap,
    required this.appTitle,
    required this.extensionKey,
    // Optional/Legacy parameters kept for compatibility with Controller calls
    VoidCallback? onExit,
    dynamic extensions,
    dynamic modelTitle,
    dynamic modelImagePath,
    dynamic onCreditsInfoTapped,
    dynamic onShowExtensionInfoRequest,
    dynamic chatTitleKey,
  });

  @override
  State<Appbar> createState() => AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppbarState extends State<Appbar> {
  // 1. Define a GlobalKey for the Title Text
  final GlobalKey _titleKey = GlobalKey();

  // 2. Expose the Context of the Title so DynamicChatService can anchor to it
  BuildContext? get titleContext => _titleKey.currentContext;

  // Interface compatibility (simplified mode has no complex panels internally)
  bool isAPanelShowing() => false;
  void closeAnyOpenPanels() {}

  @override
  Widget build(BuildContext context) {
    // Rebuild on theme change
    context.watch<ThemeProvider>();

    // Watch session only for user details (Avatar initials)
    final sessionProvider = context.watch<ChatSessionProvider>();
    final localizations = AppLocalizations.of(context)!;

    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide > 600;

    // --- RESPONSIVE DIMENSIONS ---
    final double iconSize = isTablet ? 32.0 : 26.0;

    // UPDATED: Decreased title size
    final double titleFontSize = isTablet ? 28.0 : 29.0;

    // UPDATED: Increased avatar size
    final double avatarRadius = isTablet ? 24.0 : 20.0;
    final double avatarFontSize = isTablet ? 20.0 : 16.0;

    // Determine User Initials
    String initial = '?';
    final String? displayName = sessionProvider.displayName;
    final String? email = sessionProvider.email;
    String nameSource = "";

    if (displayName != null && displayName.isNotEmpty) {
      nameSource = displayName;
    } else if (email != null && email.isNotEmpty) {
      nameSource = email;
    } else {
      nameSource = localizations.anonymousEntity;
    }

    if (nameSource.isNotEmpty) {
      initial = nameSource[0].toUpperCase();
    }

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,

      // --- LEFT: SIDEBAR MENU ---
      leading: Center(
        child: IconButton(
          key: widget.exitButtonKey,
          icon: SvgPicture.asset(
            'assets/icons/sidebar.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted,
                BlendMode.srcIn
            ),
          ),
          onPressed: () {
            // Trigger the 3D Sidebar slide via MainScreen GlobalKey
            mainScreenKey.currentState?.toggleSidebar();
          },
        ),
      ),

      // --- CENTER: APP TITLE (INTERACTIVE) ---
      title: GestureDetector(
        onTap: widget.onTitleTap,
        behavior: HitTestBehavior.translucent, // Catches taps even on transparent areas
        child: Container(
          // Add padding to make the tap area larger and more comfortable
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Text(
            widget.appTitle,
            key: _titleKey, // Assign the Key here
            // UPDATED: Font changed to Ubuntu, weight Regular (w400)
            style: GoogleFonts.ubuntu(
              color: AppColors.primaryColor.inverted,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),

      // --- RIGHT: USER AVATAR ---
      actions: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: isTablet ? 24.0 : 16.0),
            child: GestureDetector(
              key: widget.accountButtonKey,
              onTap: widget.onAccountTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: AppColors.quaternaryColor,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: avatarFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor.inverted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
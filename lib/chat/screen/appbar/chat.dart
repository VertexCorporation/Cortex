// lib/chat/screen/appbar/chat.dart

import 'dart:math';
import 'package:cortex/extensions.dart';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme.dart';

class ChatTitle extends StatefulWidget {
  final String? modelTitle;
  final Extensions extensions;
  final VoidCallback onTitleTap;
  final GlobalKey extensionKey;
  final VoidCallback onShowInfoRequest;
  static bool extensionInfoShownThisSession = false;
  static const String extensionInfoCountKey = 'extensionInfoPanelShowCount';

  const ChatTitle({
    Key? key,
    required this.modelTitle,
    required this.extensions,
    required this.onTitleTap,
    required this.extensionKey,
    required this.onShowInfoRequest,
  }) : super(key: key);

  @override
  State<ChatTitle> createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitle> {

  /// 1. It first checks if the panel has already been shown in the current app SESSION.
  /// 2. It then checks if the TOTAL persistent show count has exceeded the limit of 3.
  /// The panel is only shown if both checks pass. It returns a bool indicating its decision.
  Future<bool> triggerExtensionInfoPanelIfNeeded() async {
    // CHECK 1: Has it already been shown in this session?
    if (ChatTitle.extensionInfoShownThisSession) {
      debugPrint("[ChatTitle] Info panel already shown THIS SESSION. Skipping.");
      return false; // Do not show, return false.
    }

    // CHECK 2: Has the total display limit (3) been reached?
    final prefs = await SharedPreferences.getInstance();
    final int showCount = prefs.getInt(ChatTitle.extensionInfoCountKey) ?? 0;

    if (showCount >= 3) {
      debugPrint("[ChatTitle] Info panel has reached the permanent display limit of 3. Disabled.");
      return false; // Do not show, return false.
    }

    // 1. Request the parent widget to display the panel.
    widget.onShowInfoRequest();

    // 2. Set the session flag to 'true' to prevent it from showing again until the app restarts.
    ChatTitle.extensionInfoShownThisSession = true;

    // 3. Increment and save the persistent total show counter.
    await prefs.setInt(ChatTitle.extensionInfoCountKey, showCount + 1);
    debugPrint("[ChatTitle] Requested parent to show info panel. Session flag set. New permanent count: ${showCount + 1}");

    return true; // A request to show the panel was made, return true.
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool hasExtensions = widget.extensions.currentExtensions.isNotEmpty;
    final double fontSize = screenWidth * 0.056;

    final Widget titleContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasExtensions)
          Opacity(
            opacity: 0.0,
            child: _buildArrowIcon(fontSize),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
          child: Text(
            widget.modelTitle ?? '',
            style: GoogleFonts.mavenPro(
              fontSize: fontSize,
              color: AppColors.primaryColor.inverted,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
        ),
        if (hasExtensions)
          _buildArrowIcon(fontSize),
      ],
    );

    return GestureDetector(
      key: widget.extensionKey,
      onTap: hasExtensions ? widget.onTitleTap : null,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.65,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: titleContent,
        ),
      ),
    );
  }

  Widget _buildArrowIcon(double fontSize) {
    final double arrowSize = fontSize;
    return Transform.rotate(
      angle: -pi / 2,
      child: SvgPicture.asset(
        'assets/icons/arrov.svg',
        width: arrowSize,
        height: arrowSize,
        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
      ),
    );
  }
}
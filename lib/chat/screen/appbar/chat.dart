// lib/chat/screen/appbar/chat.dart

import 'dart:math';
import 'package:cortex/app.dart';
import 'package:cortex/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
    super.key,
    required this.modelTitle,
    required this.extensions,
    required this.onTitleTap,
    required this.extensionKey,
    required this.onShowInfoRequest,
  });

  @override
  State<ChatTitle> createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitle> {
  @override
  Widget build(BuildContext context) {
    final bool hasExtensions = widget.extensions.currentExtensions.isNotEmpty;

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final bool isTablet = size.shortestSide > 600;

    // RESPONSIVE: On tablet, use fixed readable size. On phone, use original %.
    final double fontSize = isTablet ? screenWidth * 0.04: screenWidth * 0.056;
    final double maxContainerWidth = isTablet ? screenWidth * 0.8: screenWidth * 0.65;

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
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 8.0 : screenWidth * 0.015),
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
          maxWidth: maxContainerWidth,
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
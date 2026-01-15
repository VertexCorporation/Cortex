// lib/chat/screen/premium.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme.dart';

class PremiumButton extends StatelessWidget {
  final VoidCallback onTap;

  const PremiumButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    final double scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    final double buttonHeight = 36.0 * scale;
    final double iconSize = 14.0 * scale;
    final double fontSize = 13.0 * scale;
    final double paddingH = 14.0 * scale;
    final double gap = 6.0 * scale;
    final double borderRadius = 36.0 *
        scale;
    final double borderWidth = 0.8 * scale;

    final Color baseColor = AppColors.premium;
    final Color backgroundColor = baseColor.withValues(alpha: 0.5);
    final Color contentColor = Color.lerp(
        baseColor, AppColors.primaryColor, 0.9) ??
        baseColor;
    final Color borderColor = baseColor.withValues(alpha: 0.6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: contentColor.withValues(alpha: 0.1),
              highlightColor: contentColor.withValues(alpha: 0.05),
              child: Container(
                height: buttonHeight,
                padding: EdgeInsets.symmetric(horizontal: paddingH),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/sparkle.svg',
                      colorFilter: ColorFilter.mode(
                        contentColor,
                        BlendMode.srcIn,
                      ),
                      width: iconSize,
                      height: iconSize,
                    ),
                    SizedBox(width: gap),

                    Flexible(
                      child: Text(
                        "Cortex Premium",
                        style: GoogleFonts.ubuntu(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                          color: contentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
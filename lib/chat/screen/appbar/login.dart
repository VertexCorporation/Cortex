import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme.dart';

class LoginBubbleButton extends StatelessWidget {
  final VoidCallback onTap;

  const LoginBubbleButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final localizations = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    final double buttonHeight = 36.0 * scale;
    final double fontSize = 13.0 * scale;
    final double paddingH = 16.0 * scale;
    final double borderRadius = 36.0 * scale;
    final double borderWidth = 0.8 * scale;

    final Color backgroundColor = AppColors.primaryColor.inverted;
    final Color contentColor = AppColors.primaryColor;
    final Color borderColor = contentColor.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: contentColor.withValues(alpha: 0.1),
          highlightColor: contentColor.withValues(alpha: 0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Container(
              height: buttonHeight,
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              alignment: Alignment.center,
              child: Text(
                localizations.loginToYourAccount,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: contentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

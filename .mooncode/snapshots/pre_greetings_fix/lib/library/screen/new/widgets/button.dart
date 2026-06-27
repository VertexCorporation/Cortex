// lib/screens/models/screen/new/widgets/button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// The bottom navigation bar widget containing the primary save action button.
class CreationSaveButton extends StatelessWidget {
  final bool isEnabled;
  final bool isSaving;
  final Future<void> Function() onPressed;

  const CreationSaveButton({
    super.key,
    required this.isEnabled,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final localizations = AppLocalizations.of(context)!;
    final bool isTablet = screenWidth >= 600;

    // --- TABLET OPTIMIZATIONS ---
    final double fontSize = isTablet ? 22.0 : screenWidth * 0.04;
    final double borderRadius = isTablet ? 20.0 : screenWidth * 0.03;
    final double containerRadius = isTablet ? 32.0 : screenWidth * 0.05;

    // IMPORTANT: Match the horizontal padding of the main form (12% on tablet)
    final double horizontalPadding = screenWidth * 0.04;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(containerRadius),
            topRight: Radius.circular(containerRadius),
          ),
        ),
        child: AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEnabled
                  ? () {
                HapticFeedback.lightImpact();
                onPressed();
              }
                  : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return AppColors.senaryColor.withValues(alpha: 0.5);
                    }
                    return AppColors.senaryColor;
                  },
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                    vertical: isTablet ? 20 : screenHeight * 0.018)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Text(
                localizations.save,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

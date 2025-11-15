// lib/screens/models/screen/new/widgets/button.dart

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// The bottom navigation bar widget containing the primary save action button.
///
/// This widget handles the visual state of the save button, including enabled,
/// disabled, and loading (saving) states. It is used across both 'Create' and
/// 'Add' screens.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    // Use SafeArea to avoid system intrusions at the bottom of the screen.
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
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
          // Apply a border radius only to the top corners for a clean look.
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.05),
            topRight: Radius.circular(screenWidth * 0.05),
          ),
        ),
        child: AnimatedOpacity(
          // Fade the button to indicate it's disabled.
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEnabled ? onPressed : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    // Show a dimmer color when the button is disabled.
                    if (states.contains(WidgetState.disabled)) {
                      return AppColors.senaryColor.withValues(alpha:0.5);
                    }
                    return AppColors.senaryColor;
                  },
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(vertical: screenHeight * 0.018)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
              ),
              child: isSaving
              // Show a loading indicator when the save process is active.
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
              // Otherwise, show the button text.
                  : Text(
                localizations.save,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
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
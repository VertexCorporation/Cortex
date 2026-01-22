// lib/axon/inbox/widgets/tiles/actions/edit.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../app.dart';
import '../../../../darkener.dart';
import '../../../../theme.dart';

/// Shows the classic "Edit conversation title" dialog and returns the new title.
Future<String?> showEditTitleDialog({
  required BuildContext context,
  required String initialTitle,
}) async {
  // 1. Darken background and keep a restore callback.
  final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);

  final TextEditingController controller =
      TextEditingController(text: initialTitle);
  final localizations = AppLocalizations.of(context)!;
  final screenWidth = MediaQuery.of(context).size.width;

  // Determine tablet status to cap width
  final bool isTablet = screenWidth > 600;

  String? newTitle;

  // 2. Show the dialog with a polished transition.
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "EditConversationTitle",
    barrierColor: AppColors.primaryColor.inverted.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      // We wrap with AnimatedBuilder implicitly via showGeneralDialog's rebuilds
      // But we need to listen to keyboard metrics which happen in build time.
      return StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          final currentText = controller.text.trim();
          final bool isChanged =
              currentText.isNotEmpty && currentText != initialTitle;

          // --- KEYBOARD LOGIC ---
          final double keyboardHeight = MediaQuery.of(ctx).viewInsets.bottom;

          final double verticalOffset = keyboardHeight * 0.25;

          // We use a Column with MainAxisAlignment.center and padding for the keyboard.
          // This keeps the dialog centered in the *available* space.
          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(bottom: verticalOffset),
              child: Center(
                child: Material(
                  // This allows InkWell splashes to be visible on top of the color.
                  color: AppColors.background,
                  elevation: 10,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  // Ensures splashes don't bleed out
                  child: SizedBox(
                    // --- WIDTH LOGIC ---
                    width: isTablet ? 400 : screenWidth * 0.88,
                    // No decoration here, handled by Material above
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Header + TextField ---
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.05,
                            screenWidth * 0.05,
                            screenWidth * 0.05,
                            screenWidth * 0.03,
                          ),
                          child: Column(
                            children: [
                              Text(
                                localizations.editConversationTitle,
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                  fontSize: isTablet ? 18 : screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenWidth * 0.04),
                              TextField(
                                controller: controller,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: localizations.newTitle,
                                  labelStyle: TextStyle(
                                    color: AppColors.tertiaryColor,
                                    fontSize: 14,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor.inverted,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                  fontSize: 15,
                                ),
                                onChanged: (_) => setStateDialog(() {}),
                              ),
                            ],
                          ),
                        ),

                        // --- Divider ---
                        Divider(
                            color: AppColors.quinaryColor,
                            thickness: 0.5,
                            height: 1),

                        // --- Actions ---
                        SizedBox(
                          height: isTablet ? 50 : screenWidth * 0.12,
                          child: Row(
                            children: [
                              // Cancel
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(ctx).pop();
                                  },
                                  // Splash color visible now thanks to Material parent
                                  splashColor: AppColors.septenaryColor
                                      .withValues(alpha: 0.1),
                                  highlightColor: AppColors.septenaryColor
                                      .withValues(alpha: 0.05),
                                  child: Center(
                                    child: Text(
                                      localizations.cancel,
                                      style: TextStyle(
                                        fontSize:
                                            isTablet ? 15 : screenWidth * 0.038,
                                        color: AppColors.septenaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                  color: AppColors.quinaryColor,
                                  thickness: 0.5,
                                  width: 1),
                              // Save
                              Expanded(
                                child: InkWell(
                                  onTap: isChanged
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          final text = controller.text.trim();
                                          if (text.isNotEmpty &&
                                              text != initialTitle) {
                                            newTitle = text;
                                          }
                                          Navigator.of(ctx).pop();
                                        }
                                      : null,
                                  splashColor: AppColors.senaryColor
                                      .withValues(alpha: 0.1),
                                  highlightColor: AppColors.senaryColor
                                      .withValues(alpha: 0.05),
                                  child: Center(
                                    child: AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      opacity: isChanged ? 1.0 : 0.5,
                                      child: Text(
                                        localizations.save,
                                        style: TextStyle(
                                          fontSize: isTablet
                                              ? 15
                                              : screenWidth * 0.038,
                                          color: AppColors.senaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
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
            ),
          );
        },
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        ),
      );
    },
  );

  restoreNavBar();
  return newTitle;
}

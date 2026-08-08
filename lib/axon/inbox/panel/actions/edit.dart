// lib/axon/inbox/widgets/tiles/actions/edit.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../app.dart';
import '../../../../darkener.dart';
import '../../../../main.dart';
import '../../../../theme.dart';

/// Shows the classic "Edit conversation title" dialog and returns the new title.
Future<String?> showEditTitleDialog({
  required BuildContext context,
  required String initialTitle,
}) async {
  // 1. Darken background and keep a restore callback.
  final RestoreCallback restoreNavBar = Darkener.darken(factor: 0.5);

  // CRITICAL: Tell MainScreen a dialog is open so _forceCloseKeyboard
  // retries don't steal focus from this dialog's TextField.
  mainScreenKey.currentState?.setDialogOpen(true);

  final TextEditingController controller =
      TextEditingController(text: initialTitle);
  final localizations = AppLocalizations.of(context)!;
  final screenWidth = MediaQuery.sizeOf(context).width;

  // Determine tablet status to cap width
  final bool isTablet = screenWidth > 600;

  String? newTitle;

  void submitTitle(BuildContext navigatorContext, {required String trigger}) {
    final text = controller.text.trim();
    final canSave = text.isNotEmpty && text != initialTitle;
    debugPrint(
        "[AxonRename.Dialog] submit trigger=$trigger canSave=$canSave titleLength=${text.length}");

    if (!canSave) return;

    HapticFeedback.lightImpact();
    newTitle = text;
    Navigator.of(navigatorContext).pop();
  }

  // 2. Show the dialog with a polished transition.
  try {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "EditConversationTitle",
      // [FIX] Force a dark backdrop that works in both Light and Dark modes.
      // Using theme-inverted colors caused it to look white-ish in some dark themes.
      barrierColor: Colors.black.withValues(alpha: 0.7),
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
                    color: Colors.transparent,
                    child: Container(
                      width: isTablet ? 400 : screenWidth * 0.8,
                      decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- Header + TextField ---
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.05),
                              child: Column(
                                children: [
                                  Text(
                                    localizations.editConversationTitle,
                                    style: TextStyle(
                                      color: AppColors.primaryColor.inverted,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: screenWidth * 0.05),
                                  TextField(
                                    controller: controller,
                                    autofocus: true,
                                    maxLength: 32,
                                    decoration: InputDecoration(
                                      labelText: localizations.newTitle,
                                      labelStyle: TextStyle(
                                        color: AppColors.primaryColor.inverted,
                                        fontSize: 14,
                                      ),
                                      isDense: true,
                                      counterText: "",
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: AppColors.quinaryColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primaryColor.inverted,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: AppColors.primaryColor.inverted,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => submitTitle(ctx,
                                        trigger: 'keyboard_done'),
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
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  // Cancel
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.of(ctx).pop();
                                        },
                                        splashColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        highlightColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenWidth * 0.04),
                                          child: Text(
                                            localizations.cancel,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              color: AppColors.senaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(
                                      width: 1,
                                      thickness: 0.5,
                                      color: AppColors.quinaryColor),
                                  // Save
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: isChanged
                                            ? () => submitTitle(ctx,
                                                trigger: 'save_button')
                                            : null,
                                        splashColor: AppColors.primaryColor.inverted
                                            .withValues(alpha: 0.1),
                                        highlightColor: AppColors.primaryColor.inverted
                                            .withValues(alpha: 0.1),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenWidth * 0.04),
                                          child: AnimatedOpacity(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            opacity: isChanged ? 1.0 : 0.5,
                                            child: Text(
                                              localizations.save,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: AppColors.primaryColor.inverted,
                                              ),
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
  } finally {
    restoreNavBar();
    mainScreenKey.currentState?.setDialogOpen(false);
    debugPrint("[AxonRename.Dialog] closed returningTitle=${newTitle != null}");

    // showGeneralDialog's Future can complete while the reverse transition still
    // has one last TextField frame to build. Disposing immediately makes that
    // frame touch a dead controller.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      controller.dispose();
    });
  }

  return newTitle;
}

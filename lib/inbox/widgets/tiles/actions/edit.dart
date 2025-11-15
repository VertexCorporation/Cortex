// lib/inbox/widgets/tiles/actions/edit.dart

import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../app.dart';
import '../../../../darkener.dart';
import '../../../../theme.dart';

/// Shows the classic "Edit conversation title" dialog and returns the new title.
///
/// - Darkens the background using [Darkener].
/// - Uses the original Cortex dialog layout (width, paddings, colors).
/// - "Save" button is only active when the text actually changed.
/// - Returns `String?`:
///   * new title if user saves with a non-empty, changed value
///   * null if user cancels or dismisses.
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

  String? newTitle;

  // 2. Show the dialog with the classic fade transition.
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "EditConversationTitle",
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          final currentText = controller.text.trim();
          final bool isChanged =
              currentText.isNotEmpty && currentText != initialTitle;

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: screenWidth * 0.8,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Header + TextField ---
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          Text(
                            localizations.editConversationTitle,
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: screenWidth * 0.05,
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
                                color: AppColors.primaryColor.inverted,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                ),
                                borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor.inverted,
                                ),
                                borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                            ),
                            onChanged: (_) => setStateDialog(() {}),
                          ),
                        ],
                      ),
                    ),

                    // --- Divider between content and actions ---
                    Divider(
                      color: AppColors.quinaryColor,
                      thickness: 0.5,
                      height: 1,
                    ),

                    // --- Action buttons row (Cancel / Save) ---
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          // Cancel
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: AppColors.septenaryColor
                                    .withValues(alpha: 0.1),
                                highlightColor: AppColors.septenaryColor
                                    .withValues(alpha: 0.1),
                                onTap: () => Navigator.of(ctx).pop(),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.04,
                                  ),
                                  child: Text(
                                    localizations.cancel,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: AppColors.septenaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Vertical divider
                          VerticalDivider(
                            color: AppColors.quinaryColor,
                            thickness: 0.5,
                            width: 1,
                          ),

                          // Save
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: isChanged
                                    ? AppColors.senaryColor
                                    .withValues(alpha: 0.1)
                                    : Colors.transparent,
                                highlightColor: isChanged
                                    ? AppColors.senaryColor
                                    .withValues(alpha: 0.1)
                                    : Colors.transparent,
                                onTap: isChanged
                                    ? () {
                                  final text =
                                  controller.text.trim();
                                  if (text.isNotEmpty &&
                                      text != initialTitle) {
                                    newTitle = text;
                                  }
                                  Navigator.of(ctx).pop();
                                }
                                    : null,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.04,
                                  ),
                                  child: AnimatedOpacity(
                                    duration:
                                    const Duration(milliseconds: 250),
                                    opacity: isChanged ? 1.0 : 0.5,
                                    child: Text(
                                      localizations.save,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: AppColors.senaryColor,
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
          );
        },
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      // Classic pure fade transition (no scale), just like the old implementation.
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );

  // 3. Restore background after dialog is dismissed.
  restoreNavBar();

  // 4. Return the new title (or null if cancelled / unchanged).
  return newTitle;
}
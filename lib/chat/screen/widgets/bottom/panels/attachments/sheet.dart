// lib/chat/screen/widgets/bottom/panels/attachments/sheet.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../input/service.dart';
import 'button.dart';

void showAttachmentSheet({
  required BuildContext context,
}) {
  // Hide keyboard if open to prevent UI glitching during bottom sheet animation
  FocusScope.of(context).unfocus();

  final l10n = AppLocalizations.of(context)!;
  final inputService = InputService();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext modalContext) {
      // Re-query media query inside builder for correct dimensions if orientation changes
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;

      // DYNAMIC DIMENSIONS
      final double topRadius = screenWidth * 0.07;
      final double dragHandleWidth = screenWidth * 0.12;
      final double dragHandleHeight = 4.0;
      final double dragHandleVerticalPadding = screenHeight * 0.015;
      final double titleFontSize = screenWidth * 0.05;
      final double titleBottomPadding = screenHeight * 0.03;
      final double contentHorizontalPadding = screenWidth * 0.05;
      final double itemGap = screenWidth * 0.03;

      return Container(
        padding: EdgeInsets.only(
          bottom: mediaQuery.padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
            left: BorderSide(color: AppColors.border, width: 1.0),
            right: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Drag Handle
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: dragHandleVerticalPadding),
              child: Container(
                width: dragHandleWidth,
                height: dragHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Dynamic Title
            Padding(
              padding: EdgeInsets.only(bottom: titleBottomPadding),
              child: Text(
                l10n.attachmentSheetTitle,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor.inverted,
                ),
              ),
            ),

            // Dynamic Action Buttons Row
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: contentHorizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Camera
                  Expanded(
                    child: AttachmentSheetButton(
                      iconPath: 'assets/icons/camera.svg',
                      label: l10n.actionCamera,
                      onTap: () {
                        // Close sheet first
                        Navigator.pop(context);
                        // Trigger service (validation & logic inside)
                        inputService.pickPhoto(
                          context,
                          source: ImageSource.camera,
                          onSelectionComplete: () {},
                        );
                      },
                    ),
                  ),
                  SizedBox(width: itemGap),

                  // 2. Gallery
                  Expanded(
                    child: AttachmentSheetButton(
                      iconPath: 'assets/icons/gallery.svg',
                      label: l10n.actionGallery,
                      onTap: () {
                        Navigator.pop(context);
                        inputService.pickPhoto(
                          context,
                          source: ImageSource.gallery,
                          onSelectionComplete: () {},
                        );
                      },
                    ),
                  ),
                  SizedBox(width: itemGap),

                  // 3. File (Universal Document Picker)
                  Expanded(
                    child: AttachmentSheetButton(
                      iconPath: 'assets/icons/attachment.svg',
                      label: l10n.actionFile,
                      onTap: () {
                        Navigator.pop(context);
                        inputService.pickFile(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
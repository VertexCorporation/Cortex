// lib/chat/screen/widgets/bottom/panels/attachments/sheet.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../input/service.dart';
import 'button.dart';

import 'package:camera/camera.dart';

void showAttachmentSheet({
  required BuildContext context,
  required bool canHandleImages,
  required bool canHandleVideo,
  required bool canHandleAudio,
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
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
    ),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Drag Handle
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: dragHandleVerticalPadding),
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
            FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (futureContext, snapshot) {
                // Default to showing camera if waiting or if we can't determine (fail safe)
                // BUT user specific request: "if camera not supported... camera icon should not prevent"
                // Actually safer to assume NO camera if error/empty for this specific requirement.
                final bool hasCamera =
                    snapshot.hasData && snapshot.data!.isNotEmpty;

                // While loading, we can just show nothing or a loader.
                // But for a bottom sheet, snappy is better.
                // Let's assume false until loaded? Or true?
                // Given "required=false" in manifest, we should rely on the check.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Shimmer skeleton that matches the button layout
                  final double itemWidth = (screenWidth * 0.85) / 3;
                  final double borderRadius = screenWidth * 0.04;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: contentHorizontalPadding),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.shimmerBase,
                      highlightColor: AppColors.shimmerHighlight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) {
                          return Container(
                            width: itemWidth,
                            height:
                                itemWidth, // Square boxes like actual buttons
                            decoration: BoxDecoration(
                              color: AppColors.shimmerBase,
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: contentHorizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Camera (Conditional)
                      if (hasCamera && (canHandleImages || canHandleVideo)) ...[
                        Expanded(
                          child: AttachmentSheetButton(
                            iconPath: 'assets/icons/camera.svg',
                            label: l10n.actionCamera,
                            onTap: () {
                              Navigator.pop(futureContext);
                              inputService.pickMediaAction(
                                context,
                                source: ImageSource.camera,
                                supportImage: canHandleImages,
                                supportVideo: canHandleVideo,
                                onSelectionComplete: () {},
                              );
                            },
                          ),
                        ),
                        SizedBox(width: itemGap),
                      ],

                      // 2. Gallery
                      if (canHandleImages || canHandleVideo) ...[
                        Expanded(
                          child: AttachmentSheetButton(
                            iconPath: 'assets/icons/gallery.svg',
                            label: l10n.actionGallery,
                            onTap: () {
                              Navigator.pop(futureContext);
                              inputService.pickMediaAction(
                                context,
                                source: ImageSource.gallery,
                                supportImage: canHandleImages,
                                supportVideo: canHandleVideo,
                                onSelectionComplete: () {},
                              );
                            },
                          ),
                        ),
                        SizedBox(width: itemGap),
                      ],

                      // 3. File
                      Expanded(
                        child: AttachmentSheetButton(
                          iconPath: 'assets/icons/attachment.svg',
                          label: l10n.actionFile,
                          onTap: () {
                            Navigator.pop(futureContext);
                            inputService.pickFile(
                              context,
                              canHandleAudio: canHandleAudio,
                              canHandleVideo: canHandleVideo,
                            );
                          },
                        ),
                      ),

                      // Spacer if camera is missing to keep things nice?
                      // Row spaceEvenly handles it well, but "Expanded" will fill space.
                      // If 2 items, they take 50% each. If 3, 33% each.
                      // This meets the "centered" requirement naturally with Expanded.
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

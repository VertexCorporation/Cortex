// lib/chat/screen/selected/widgets/input/service.dart

import 'dart:io';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../panels/selection/sheet.dart';

class InputService {
  final ImagePicker _imagePicker = ImagePicker();

  // --- Image Handling (with Compression & Size Check) ---

  Future<void> pickPhoto(BuildContext context,
      {required ImageSource source,
        required VoidCallback onPhotoSelected}) async {
    try {
      // 1. Pick and compress the image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Compress to 80% quality
        maxWidth: 1920, // Resize large images to FHD
        maxHeight: 1920,
      );

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);

      // 2. Async operation: Get file size
      final int sizeInBytes = await file.length();
      const int maxPhotoSize = 10 * 1024 * 1024; // 10 MB

      // 3. Safety Check: Ensure context is still valid after the 'await' above
      if (!context.mounted) return;

      // 4. Update State
      if (sizeInBytes <= maxPhotoSize) {
        context.read<InputProvider>().selectPhoto(file);
        onPhotoSelected();
      } else {
        debugPrint("Photo ignored: Size > 10MB even after compression.");
      }
    } catch (e) {
      debugPrint("Error picking photo: $e");
    }
  }

  // --- File Selection (Check Only) ---

  Future<void> pickFile(BuildContext context) async {
    try {
      // 1. Define allowed extensions (No .exe, etc.)
      const List<String> allowedExtensions = [
        'pdf', 'doc', 'docx', 'txt', 'md', 'csv', 'xls', 'xlsx', 'json'
      ];

      // 2. Pick the file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.single.path == null) return;

      final File file = File(result.files.single.path!);

      // 3. Async operation: Get file size
      final int sizeInBytes = await file.length();
      const int maxFileSize = 10 * 1024 * 1024; // 10 MB

      // 4. Safety Check: Ensure context is still valid after the 'await' above
      if (!context.mounted) return;

      // 5. Update State
      if (sizeInBytes <= maxFileSize) {
        context.read<InputProvider>().selectPhoto(file);
      } else {
        // Silently ignore or show a local notification if preferred
        debugPrint("File ignored: Size > 10MB");
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // --- Model Selection Logic ---

  void openModelSelectionSheet(BuildContext context,
      AppLocalizations localizations) {
    final sessionProvider = context.read<ChatSessionProvider>();
    final String currentId = sessionProvider.modelId ?? '';

    showModelSelectionSheet(
      context: context,
      localizations: localizations,
      currentModelId: currentId,
      onModelSelected: (String newModelId) {
        _handleModelSwitch(context, sessionProvider, newModelId);
      },
    );
  }

  void _handleModelSwitch(BuildContext context,
      ChatSessionProvider sessionProvider, String newModelId) {
    try {
      final allModels = sessionProvider.allModels;
      ModelEntity? targetModel;

      // 1. Try finding direct match
      try {
        targetModel = allModels.firstWhere((m) => m.id == newModelId);
      } catch (_) {
        // 2. Try finding variant
        for (final parent in allModels) {
          if (parent.variants != null &&
              parent.variants!.containsKey(newModelId)) {
            final variantMap = parent.variants![newModelId];
            if (variantMap is Map<String, dynamic>) {
              final mergedMap = {
                ...parent.toMap(),
                ...variantMap,
                'id': variantMap['id'] ?? newModelId,
                'title': variantMap['title'],
              };
              mergedMap.remove('variants');
              final langCode = sessionProvider
                  .getLocale()
                  .languageCode;
              targetModel = ModelEntity.fromMap(mergedMap, langCode);
            }
            break;
          }
        }
      }

      if (targetModel != null) {
        sessionProvider.selectModel(targetModel);
      } else {
        sessionProvider.updateActiveModelVariant(newModelId);
      }
    } catch (e) {
      debugPrint("Error switching model: $e");
      sessionProvider.updateActiveModelVariant(newModelId);
    }
  }

  // --- Validation & Credit Logic ---

  int calculateRequiredCredits({
    required bool isServerSide,
    required bool isDynamicChat,
    required bool isPremium,
    required bool hasPhoto,
  }) {
    if (!isServerSide) return 0;

    if (isDynamicChat) {
      const base = 20;
      final photoCost = hasPhoto ? 30 : 0;
      return base + photoCost;
    }

    final base = isPremium ? 20 : 5;
    final photoCost = hasPhoto ? 30 : 0;
    return base + photoCost;
  }

  bool isSendButtonEnabled({
    required BuildContext context,
    required TextEditingController controller,
    required bool isServerSideModel,
    required bool isDynamicChatMode,
    required bool isLimitExceeded,
    required bool isSending,
    required bool modelMissing,
    required bool isStorageSufficient,
    required bool isPremiumModel,
    required bool isSubscribed,
    required int premiumTrialUses,
    required int totalCredits,
  }) {
    if (modelMissing || isSending || !isStorageSufficient || isLimitExceeded) {
      return false;
    }

    if (isPremiumModel && !isSubscribed && premiumTrialUses >= 3) {
      return false;
    }

    final inputProvider = context.read<InputProvider>();
    final String currentText = controller.text.trim();
    final bool hasPhoto = inputProvider.selectedPhoto != null;

    final needed = calculateRequiredCredits(
      isServerSide: isServerSideModel,
      isDynamicChat: isDynamicChatMode,
      isPremium: isPremiumModel,
      hasPhoto: hasPhoto,
    );

    if ((isDynamicChatMode || isServerSideModel) && totalCredits < needed) {
      return false;
    }

    if (inputProvider.isEditingMode) {
      final String originalText = inputProvider.originalMessageText ?? '';
      final bool textChanged = currentText != originalText;
      return (textChanged || hasPhoto) && (currentText.isNotEmpty || hasPhoto);
    }

    return currentText.isNotEmpty || hasPhoto;
  }
}
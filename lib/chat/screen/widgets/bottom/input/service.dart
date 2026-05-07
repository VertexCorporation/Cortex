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

/// Service responsible for handling input actions:
/// - Media/File selection (Validation, Limits, Compression)
/// - Model switching
/// - Credit calculation logic (updated for multi-attachments)
class InputService {
  final ImagePicker _imagePicker = ImagePicker();

  // --- Constants ---
  static const int _maxAttachmentCount = 9;
  static const int _maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB strict limit

  // Supported extensions for the file picker.
  // We exclude executables (.exe, .apk, .bat) to prevent binary/malware uploads.
  static const List<String> _allowedExtensions = [
    // Documents
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'csv',
    'txt',
    'rtf',
    'md',
    // Code / Data
    'json',
    'xml',
    'html',
    'css',
    'js',
    'ts',
    'py',
    'dart',
    'c',
    'cpp',
    'java',
    'sql'
  ];

  // --- Image Handling ---

  Future<void> pickMediaAction(BuildContext context,
      {required ImageSource source,
      required bool supportImage,
      required bool supportVideo,
      required VoidCallback onSelectionComplete}) async {
    // 1. Check Attachment Limit before opening camera/gallery
    if (!_canAddMoreAttachments(context)) return;

    try {
      XFile? pickedFile;
      if (source == ImageSource.gallery) {
        if (supportImage && supportVideo) {
          pickedFile = await _imagePicker.pickMedia(
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1920,
          );
        } else if (supportVideo) {
          pickedFile = await _imagePicker.pickVideo(source: source);
        } else {
          pickedFile = await _imagePicker.pickImage(
            source: source,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1920,
          );
        }
      } else {
        // For camera, usually we separate pickImage and pickVideo, but here we just keep pickImage for now unless video is specifically supported (camera video recording).
        if (supportImage) {
          pickedFile = await _imagePicker.pickImage(
            source: source,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1920,
          );
        } else if (supportVideo) {
          pickedFile = await _imagePicker.pickVideo(source: source);
        }
      }

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);

      // 3. Validate and Add
      if (!context.mounted) return;

      final String pathLower = file.path.toLowerCase();
      final bool isImage = ['.png', '.jpg', '.jpeg', '.webp', '.gif']
          .any((ext) => pathLower.endsWith(ext));

      await _validateAndAddAttachment(context, file, isImage: isImage);

      onSelectionComplete();
    } catch (e) {
      debugPrint("Error picking photo/video: $e");
    }
  }

  // --- File Selection ---

  Future<void> pickFile(BuildContext context,
      {bool canHandleAudio = false, bool canHandleVideo = false}) async {
    // 1. Check Attachment Limit
    if (!_canAddMoreAttachments(context)) return;

    final dynamicExtensions = List<String>.from(_allowedExtensions);
    if (canHandleAudio) {
      dynamicExtensions.addAll(['mp3', 'wav', 'm4a', 'ogg', 'aac', 'flac']);
    }
    if (canHandleVideo) {
      dynamicExtensions.addAll(['mp4', 'mov', 'avi', 'mkv', 'webm']);
    }

    try {
      // 2. Open Native File Picker
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: dynamicExtensions,
        allowMultiple: true, // Allow selecting multiple files at once
      );

      if (result == null || result.files.isEmpty) return;

      if (!context.mounted) return;

      // 3. Process each selected file
      // We loop through them to validate limits individually.
      for (final platformFile in result.files) {
        if (!context.mounted) return;
        if (platformFile.path == null) continue;

        // Stop if user tries to add more than the limit in a batch
        if (!_canAddMoreAttachments(context)) break;

        final File file = File(platformFile.path!);
        final String pathLower = file.path.toLowerCase();
        final bool isImage = ['.png', '.jpg', '.jpeg', '.webp', '.gif']
            .any((ext) => pathLower.endsWith(ext));
        await _validateAndAddAttachment(context, file, isImage: isImage);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // --- Helper: Validation & State Update ---

  /// Checks if the user has reached the maximum number of attachments (4).
  bool _canAddMoreAttachments(BuildContext context) {
    final inputProvider = context.read<InputProvider>();
    // Assuming InputProvider has an 'attachments' list getter
    if (inputProvider.attachments.length >= _maxAttachmentCount) {
      // Optional: Show a toast/snackbar here telling the user "Max 4 files".
      debugPrint("Attachment limit reached ($_maxAttachmentCount).");
      return false;
    }
    return true;
  }

  /// Validates file size and adds it to the provider if safe.
  Future<void> _validateAndAddAttachment(BuildContext context, File file,
      {required bool isImage}) async {
    try {
      // Async operation: Get file size
      final int sizeInBytes = await file.length();

      // Security Check:
      // Even if a user renames 'game.exe' (500MB) to 'game.txt',
      // this check prevents it from entering our system.
      if (sizeInBytes > _maxFileSizeInBytes) {
        debugPrint(
            "File rejected: Size (${sizeInBytes / 1024 / 1024} MB) exceeds limit.");
        // Optional: Trigger a UI notification via a helper service
        return;
      }

      // Add to provider
      if (context.mounted) {
        debugPrint(
            "InputService: File validated. Adding to provider: ${file.path}");
        // Assuming InputProvider has an 'addAttachment' method.
        // We handle both images and docs as generic attachments now.
        context.read<InputProvider>().addAttachment(file, isImage: isImage);
      } else {
        debugPrint(
            "InputService: Context not mounted after validation. Skipped.");
      }
    } catch (e) {
      debugPrint("Error validating file: $e");
    }
  }

  // --- Model Selection Logic (Existing) ---

  void openModelSelectionSheet(
      BuildContext context, AppLocalizations localizations) {
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

      try {
        targetModel = allModels.firstWhere((m) => m.id == newModelId);
      } catch (_) {
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
              final langCode = sessionProvider.getLocale().languageCode;
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

  // --- Validation & Credit Logic (Updated for Multi-Attachments) ---

  /// Calculates the total cost based on base model price + number of attachments.
  int calculateRequiredCredits({
    required bool isServerSide,
    required bool isDynamicChat,
    required bool isPremium,
    required int attachmentCount, // New Parameter: Number of files
    required bool isSearchEnabled, // Included web search cost
  }) {
    if (!isServerSide) return 0;

    // Define Costs
    const int attachmentCostPerUnit = 30;
    const int searchCost = 5;

    // Determine Base Cost
    int baseCost = 5; // Standard
    if (isDynamicChat || isPremium) {
      baseCost = 20; // Premium / Auto
    }

    if (isSearchEnabled) {
      baseCost += searchCost;
    }

    // Formula: Base + (N * 30)
    final int totalAttachmentCost = attachmentCount * attachmentCostPerUnit;

    return baseCost + totalAttachmentCost;
  }

  bool isActionPermitted({
    required BuildContext context,
    required bool isServerSideModel,
    required bool isDynamicChatMode,
    required bool isLimitExceeded,
    required bool isSending,
    required bool modelMissing,
    required bool isStorageSufficient,
    required bool isPremiumModel,
    required bool isSubscribed,
    required bool isVideoModel,
    required int userTier,
    required int premiumTrialUses,
    required int? totalCredits,
  }) {
    // 1. Basic Blockers
    if (modelMissing || isSending || !isStorageSufficient || isLimitExceeded) {
      return false;
    }

    if (isVideoModel && userTier != 3 && userTier != 6) {
      return false;
    }

    final isOfflineMode = !isDynamicChatMode && !isServerSideModel;
    if (isOfflineMode &&
        !context.read<ChatSessionProvider>().isLocalModelLoaded) {
      return false;
    }

    // 2. Trial Limits
    if (isPremiumModel && !isSubscribed && premiumTrialUses >= 3) {
      return false;
    }

    final inputProvider = context.read<InputProvider>();

    final int attachmentCount = inputProvider.attachments.length;

    // 3. Credit Check
    final needed = calculateRequiredCredits(
      isServerSide: isServerSideModel,
      isDynamicChat: isDynamicChatMode,
      isPremium: isPremiumModel,
      attachmentCount: attachmentCount,
      isSearchEnabled: inputProvider.enableWebSearch,
    );

    if ((isDynamicChatMode || isServerSideModel) && totalCredits != null && totalCredits < needed) {
      return false;
    }

    return true;
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
    required bool isVideoModel,
    required int userTier,
    required int premiumTrialUses,
    required int? totalCredits,
  }) {
    // 1. Basic Blockers
    if (modelMissing || isSending || !isStorageSufficient || isLimitExceeded) {
      return false;
    }

    if (isVideoModel && userTier != 3 && userTier != 6) {
      return false;
    }

    final isOfflineMode = !isDynamicChatMode && !isServerSideModel;
    if (isOfflineMode &&
        !context.read<ChatSessionProvider>().isLocalModelLoaded) {
      return false;
    }

    // 2. Trial Limits
    if (isPremiumModel && !isSubscribed && premiumTrialUses >= 3) {
      return false;
    }

    final inputProvider = context.read<InputProvider>();
    final String currentText = controller.text.trim();

    // UPDATED: Check list length instead of single photo
    final int attachmentCount = inputProvider.attachments.length;
    final bool hasAttachments = attachmentCount > 0;

    // 3. Credit Check
    final needed = calculateRequiredCredits(
      isServerSide: isServerSideModel,
      isDynamicChat: isDynamicChatMode,
      isPremium: isPremiumModel,
      attachmentCount: attachmentCount,
      isSearchEnabled: inputProvider.enableWebSearch,
    );

    if ((isDynamicChatMode || isServerSideModel) && totalCredits != null && totalCredits < needed) {
      return false;
    }

    // 4. Content Validation
    if (inputProvider.isEditingMode) {
      final String originalText = inputProvider.originalMessageText ?? '';
      final bool textChanged = currentText != originalText;
      // Allow send if text changed OR if there are attachments (even if text is same/empty)
      return (textChanged || hasAttachments) &&
          (currentText.isNotEmpty || hasAttachments);
    }

    // Standard Mode: Must have text OR attachments
    return currentText.isNotEmpty || hasAttachments;
  }
}

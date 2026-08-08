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
    final inputProvider = context.read<InputProvider>();
    // 1. Check Attachment Limit before opening camera/gallery
    if (!_canAddMoreAttachments(inputProvider)) return;

    try {
      if (source == ImageSource.gallery) {
        List<XFile> pickedFiles = [];
        if (supportImage) {
          pickedFiles = await _imagePicker.pickMultiImage(
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1920,
          );
        } else if (supportVideo) {
          final XFile? file = await _imagePicker.pickVideo(source: source);
          if (file != null) pickedFiles.add(file);
        }

        if (pickedFiles.isEmpty) return;

        for (final pickedFile in pickedFiles) {
          if (!_canAddMoreAttachments(inputProvider)) break;

          final File file = File(pickedFile.path);
          final String pathLower = file.path.toLowerCase();
          final bool isImage = ['.png', '.jpg', '.jpeg', '.webp', '.gif']
              .any((ext) => pathLower.endsWith(ext));

          await _validateAndAddAttachment(inputProvider, file,
              isImage: isImage);
        }
      } else {
        XFile? pickedFile;
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

        if (pickedFile == null) return;

        final File file = File(pickedFile.path);
        final String pathLower = file.path.toLowerCase();
        final bool isImage = ['.png', '.jpg', '.jpeg', '.webp', '.gif']
            .any((ext) => pathLower.endsWith(ext));

        await _validateAndAddAttachment(inputProvider, file, isImage: isImage);
      }

      onSelectionComplete();
    } catch (e) {
      debugPrint("Error picking photo/video: $e");
    }
  }

  // --- File Selection ---

  Future<void> pickFile(BuildContext context,
      {bool canHandleAudio = false, bool canHandleVideo = false}) async {
    final inputProvider = context.read<InputProvider>();
    // 1. Check Attachment Limit
    if (!_canAddMoreAttachments(inputProvider)) return;

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

      // 3. Process each selected file
      // We loop through them to validate limits individually.
      for (final platformFile in result.files) {
        if (platformFile.path == null) continue;

        // Stop if user tries to add more than the limit in a batch
        if (!_canAddMoreAttachments(inputProvider)) break;

        final File file = File(platformFile.path!);
        final String pathLower = file.path.toLowerCase();
        final bool isImage = ['.png', '.jpg', '.jpeg', '.webp', '.gif']
            .any((ext) => pathLower.endsWith(ext));
        await _validateAndAddAttachment(inputProvider, file, isImage: isImage);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // --- Helper: Validation & State Update ---

  /// Checks if the user has reached the maximum number of attachments (4).
  bool _canAddMoreAttachments(InputProvider inputProvider) {
    if (inputProvider.attachments.length >= _maxAttachmentCount) {
      // Optional: Show a toast/snackbar here telling the user "Max 4 files".
      debugPrint("Attachment limit reached ($_maxAttachmentCount).");
      return false;
    }
    return true;
  }

  /// Validates file size and adds it to the provider if safe.
  Future<void> _validateAndAddAttachment(InputProvider inputProvider, File file,
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
      debugPrint(
          "InputService: File validated. Adding to provider: ${file.path}");
      inputProvider.addAttachment(file, isImage: isImage);
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
      initialModels: sessionProvider.allModels,
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
    bool isRagEnabled = false, // Included document-chat (RAG) cost
  }) {
    if (!isServerSide) return 0;

    // Define Costs
    const int attachmentCostPerUnit = 30;
    const int searchCost = 5;
    const int ragCost = 5;

    // Determine Base Cost
    int baseCost = 5; // Standard
    if (isDynamicChat || isPremium) {
      baseCost = 20; // Premium / Auto
    }

    if (isSearchEnabled) {
      baseCost += searchCost;
    }

    if (isRagEnabled) {
      baseCost += ragCost;
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
    required int? totalCredits,
    required int? availablePredits,
    required int? availableDredits,
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

    // 2. Premium / Predits Limits
    // Dynamic chat is gated by dredits only on the client. The server may still
    // spend predits/credits after routing if it chooses a premium provider.
    if (!isDynamicChatMode && isPremiumModel && !isSubscribed) {
      if ((availablePredits ?? 0) < 10) {
        return false;
      }
    }

    // 3. Dynamic Chat / Dredits Limit
    if (isDynamicChatMode) {
      if ((availableDredits ?? 0) < 1) {
        return false;
      }
    }

    final inputProvider = context.read<InputProvider>();

    final int attachmentCount = inputProvider.attachments.length;

    // 4. Overall Credit Check
    final needed = calculateRequiredCredits(
      isServerSide: isServerSideModel,
      isDynamicChat: isDynamicChatMode,
      isPremium: isPremiumModel,
      attachmentCount: attachmentCount,
      isSearchEnabled: inputProvider.enableWebSearch,
      isRagEnabled: inputProvider.ragEnabled,
    );

    if (!isDynamicChatMode &&
        isServerSideModel &&
        totalCredits != null &&
        totalCredits < needed) {
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
    required int? totalCredits,
    required int? availablePredits,
    required int? availableDredits,
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

    // 2. Premium / Predits Limits
    // Dynamic chat must remain sendable as long as the user has dredits. Predits
    // are only a routing/cost concern after the server chooses a premium path.
    if (!isDynamicChatMode && isPremiumModel && !isSubscribed) {
      if ((availablePredits ?? 0) < 10) {
        return false;
      }
    }

    // 3. Dynamic Chat / Dredits Limit
    if (isDynamicChatMode) {
      if ((availableDredits ?? 0) < 1) {
        return false;
      }
    }

    final inputProvider = context.read<InputProvider>();
    final String currentText = controller.text.trim();

    // UPDATED: Check list length instead of single photo
    final int attachmentCount = inputProvider.attachments.length;
    final bool hasAttachments = attachmentCount > 0;

    // 4. Overall Credit Check
    final needed = calculateRequiredCredits(
      isServerSide: isServerSideModel,
      isDynamicChat: isDynamicChatMode,
      isPremium: isPremiumModel,
      attachmentCount: attachmentCount,
      isSearchEnabled: inputProvider.enableWebSearch,
      isRagEnabled: inputProvider.ragEnabled,
    );

    if (!isDynamicChatMode &&
        isServerSideModel &&
        totalCredits != null &&
        totalCredits < needed) {
      return false;
    }

    // 5. Content Validation
    if (inputProvider.isEditingMode) {
      return currentText.isNotEmpty || hasAttachments;
    }

    // Standard Mode: Must have text OR attachments
    return currentText.isNotEmpty || hasAttachments;
  }
}

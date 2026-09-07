// lib/chat/screen/selected/widgets/input/service.dart

import 'dart:io';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/credits.dart';
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
        bool pickedImages = false;
        if (supportImage) {
          pickedFiles = await _imagePicker.pickMultiImage(
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1920,
          );
          pickedImages = true;
        } else if (supportVideo) {
          final XFile? file = await _imagePicker.pickVideo(source: source);
          if (file != null) pickedFiles.add(file);
        }

        if (pickedFiles.isEmpty) return;

        for (final pickedFile in pickedFiles) {
          if (!_canAddMoreAttachments(inputProvider)) break;

          final File file = File(pickedFile.path);
          // ImagePicker already tells us which picker was used. Do not infer
          // this again from a temporary cache filename, which may have a
          // generic or missing extension on some Android/iOS devices.
          await _validateAndAddAttachment(inputProvider, file,
              isImage: pickedImages);
        }

        if (pickedImages) {
          _promoteSelectedSeriesForImage(context);
        }
      } else {
        XFile? pickedFile;
        bool pickedImage = false;
        if (supportImage) {
          pickedFile = await _imagePicker.pickImage(
            source: source,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1920,
          );
          pickedImage = true;
        } else if (supportVideo) {
          pickedFile = await _imagePicker.pickVideo(source: source);
        }

        if (pickedFile == null) return;

        final File file = File(pickedFile.path);
        await _validateAndAddAttachment(inputProvider, file,
            isImage: pickedImage);
        if (pickedImage) {
          _promoteSelectedSeriesForImage(context);
        }
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
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      // 3. Process each selected file
      for (final platformFile in result.files) {
        if (platformFile.path == null) continue;
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

  bool _canAddMoreAttachments(InputProvider inputProvider) {
    if (inputProvider.attachments.length >= _maxAttachmentCount) {
      debugPrint("Attachment limit reached ($_maxAttachmentCount).");
      return false;
    }
    return true;
  }

  /// Validates file size and adds it to the provider if safe.
  Future<void> _validateAndAddAttachment(InputProvider inputProvider, File file,
      {required bool isImage}) async {
    try {
      final int sizeInBytes = await file.length();

      if (sizeInBytes > _maxFileSizeInBytes) {
        debugPrint(
            "File rejected: Size (${sizeInBytes / 1024 / 1024} MB) exceeds limit.");
        return;
      }

      debugPrint(
          "InputService: File validated. Adding to provider: ${file.path}");
      inputProvider.addAttachment(file, isImage: isImage);
    } catch (e) {
      debugPrint("Error validating file: $e");
    }
  }

  /// If a server-side series contains a dedicated vision variant, select that
  /// concrete variant as soon as an image is attached. This keeps the visible
  /// series choice while preventing SendService from ever silently falling
  /// back to the first text-only variant for the image request.
  void _promoteSelectedSeriesForImage(BuildContext context) {
    final sessionProvider = context.read<ChatSessionProvider>();
    if (sessionProvider.isDynamicChat) return;

    final selected = sessionProvider.selectedModel;
    final variants = selected?.variants;
    if (selected == null ||
        !selected.isServerSide ||
        variants == null ||
        variants.isEmpty) {
      return;
    }

    String? fallbackVisionId;
    String? preferredVisionId;

    for (final entry in variants.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;
      final variant = Map<String, dynamic>.from(raw);
      final modalities = variant['modalities'];
      if (modalities is! Map || modalities['image'] != true) continue;

      final id = variant['id']?.toString().trim() ?? entry.key.trim();
      if (id.isEmpty || id.toLowerCase().contains('guard')) continue;

      fallbackVisionId ??= id;
      final tier = variant['tier']?.toString().toLowerCase() ?? 'free';
      final needsPaidAccess = tier == 'premium' ||
          tier == 'plus' ||
          tier == 'pro' ||
          tier == 'ultra';
      if (!needsPaidAccess || sessionProvider.isUserSubscribed) {
        preferredVisionId = id;
        break;
      }
    }

    final targetId = preferredVisionId ??
        (sessionProvider.isUserSubscribed ? fallbackVisionId : null);
    if (targetId == null || targetId == sessionProvider.modelId) return;

    debugPrint(
        "[InputService] Image attached. Promoting series '${selected.id}' to vision variant '$targetId'.");
    sessionProvider.updateActiveModelVariant(targetId);
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

      // If an image was attached before switching models, re-resolve the newly
      // selected series to its vision variant immediately.
      final inputProvider = context.read<InputProvider>();
      if (inputProvider.attachments
          .any((attachment) => attachment.type == AttachmentType.image)) {
        _promoteSelectedSeriesForImage(context);
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
    required int attachmentCount,
    required bool isSearchEnabled,
    bool isRagEnabled = false,
  }) {
    if (!isServerSide) return 0;

    const int attachmentCostPerUnit = 30;
    const int searchCost = 5;
    const int ragCost = 5;

    int baseCost = 5;
    if (isDynamicChat || isPremium) {
      baseCost = 20;
    }

    if (isSearchEnabled) {
      baseCost += searchCost;
    }

    if (isRagEnabled) {
      baseCost += ragCost;
    }

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
    if (modelMissing || isSending || !isStorageSufficient || isLimitExceeded) {
      return false;
    }

    if (isVideoModel && userTier != 3 && userTier != 6) {
      return false;
    }

    final sessionProvider = context.read<ChatSessionProvider>();
    final isOfflineMode = !isDynamicChatMode && !isServerSideModel;
    if (isOfflineMode && !sessionProvider.isLocalModelLoaded) {
      return false;
    }

    final creditsManager = context.read<CreditsManager>();
    if (!creditsManager.canSendAnything) {
      return false;
    }

    if (!creditsManager.creditsV3Notifier.value) {
      if (!isDynamicChatMode && isPremiumModel && !isSubscribed) {
        if (!creditsManager.canUsePremiumModel) {
          return false;
        }
      }

      if (isDynamicChatMode && !creditsManager.canSendDynamicChat) {
        return false;
      }
    }

    final inputProvider = context.read<InputProvider>();
    final bool hasImageAttachment = inputProvider.attachments
        .any((attachment) => attachment.type == AttachmentType.image);

    // Never allow an image to be silently sent through a model that cannot
    // consume images. Dynamic Chat is exempt because SendService routes it to a
    // vision-capable model for the request.
    if (!isDynamicChatMode &&
        hasImageAttachment &&
        !sessionProvider.canHandleImage) {
      return false;
    }

    final int attachmentCount = inputProvider.attachments.length;
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
    if (modelMissing || isSending || !isStorageSufficient || isLimitExceeded) {
      return false;
    }

    if (isVideoModel && userTier != 3 && userTier != 6) {
      return false;
    }

    final sessionProvider = context.read<ChatSessionProvider>();
    final isOfflineMode = !isDynamicChatMode && !isServerSideModel;
    if (isOfflineMode && !sessionProvider.isLocalModelLoaded) {
      return false;
    }

    final creditsManager = context.read<CreditsManager>();
    if (!creditsManager.canSendAnything) {
      return false;
    }

    if (!creditsManager.creditsV3Notifier.value) {
      if (!isDynamicChatMode && isPremiumModel && !isSubscribed) {
        if (!creditsManager.canUsePremiumModel) {
          return false;
        }
      }

      if (isDynamicChatMode && !creditsManager.canSendDynamicChat) {
        return false;
      }
    }

    final inputProvider = context.read<InputProvider>();
    final String currentText = controller.text.trim();

    final int attachmentCount = inputProvider.attachments.length;
    final bool hasAttachments = attachmentCount > 0;
    final bool hasImageAttachment = inputProvider.attachments
        .any((attachment) => attachment.type == AttachmentType.image);

    if (!isDynamicChatMode &&
        hasImageAttachment &&
        !sessionProvider.canHandleImage) {
      return false;
    }

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

    if (inputProvider.isEditingMode) {
      return currentText.isNotEmpty || hasAttachments;
    }

    return currentText.isNotEmpty || hasAttachments;
  }
}

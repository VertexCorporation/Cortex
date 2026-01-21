// utils.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';

/// A collection of static utility methods used across the application.
class Utils {
  static bool isLocalModel(
    String? modelId, {
    required String langCode,
    required ModelService modelService,
  }) =>
      !isServerSideModel(
        modelId,
        langCode: langCode,
        modelService: modelService,
      );

  static bool isServerSideModel(
    String? modelId, {
    required String langCode,
    required ModelService modelService,
  }) {
    if (modelId == null || modelId.isEmpty) {
      return true; // Default to server-side for safety if ID is invalid.
    }

    // Fetch the type-safe entity using the provided modelService.
    final model = modelService.getPreciseModelData(modelId, langCode: langCode);

    // Use the safe getter from the entity.
    return model.isServerSide;
  }

  /// It requires a `langCode` to ensure correct localization.
  static ModelEntity getModelEntityFromId(
    String targetModelId, {
    required String langCode,
    required ModelService modelService,
  }) {
    debugPrint(
        "[Utils.getModelEntityFromId] Fetching entity for '$targetModelId' using provided modelService.");
    return modelService.getPreciseModelData(targetModelId, langCode: langCode);
  }

  /// A static utility to read any file, encode it to Base64, and return its data and MIME type.
  static Future<Map<String, String>?> formatBase64File(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final fileBytes = await file.readAsBytes();
        final mimeType = lookupMimeType(filePath, headerBytes: fileBytes);

        if (mimeType == null) {
          debugPrint(
              "Unsupported file type or could not determine MIME for: $filePath");
          return null;
        }

        final base64Data = base64Encode(fileBytes);
        return {
          'mime_type': mimeType,
          'data': base64Data,
        };
      }
    } catch (e) {
      debugPrint("Error reading or encoding file: $e");
    }
    return null;
  }

  /// A static utility function to read an image file, encode it to Base64,
  /// and format it as a data URL string.
  static Future<String?> formatBase64Image(String photoPath) async {
    try {
      final imageFile = File(photoPath);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final mimeType = lookupMimeType(photoPath, headerBytes: imageBytes);

        if (mimeType == null ||
            !['image/png', 'image/jpeg', 'image/webp'].contains(mimeType)) {
          debugPrint("Unsupported image type '$mimeType' for file: $photoPath");
          return null;
        }

        final base64Image = base64Encode(imageBytes);
        return 'data:$mimeType;base64,$base64Image';
      }
    } catch (e) {
      debugPrint("Error reading or encoding photo file: $e");
    }
    return null;
  }

  /// Processes an attachment path and returns the correct OpenAI-compatible content block.
  /// - Images -> { "type": "image_url", "image_url": { "url": "..." } }
  /// - Text Files -> { "type": "text", "text": "..." }
  static Future<Map<String, dynamic>?> processAttachment(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final mimeType = lookupMimeType(path) ?? 'application/octet-stream';

      // 1. Handle Images
      if (mimeType.startsWith('image/')) {
        final base64Url = await formatBase64Image(path);
        if (base64Url != null) {
          return {
            "type": "image_url",
            "image_url": {"url": base64Url}
          };
        }
      }

      // 2. Handle Text-based files (Code, logs, txt, csv, etc.)
      // We assume anything else we allow in the picker is text-readable.
      // (The picker filters for safe extensions).
      try {
        final String content = await file.readAsString();
        final String fileName = path.split('/').last;
        return {
          "type": "text",
          "text": "[File: $fileName]\n```\n$content\n```"
        };
      } catch (e) {
        // Fallback for binary or unreadable files that slipped through
        debugPrint("[Utils] Could not read file as text: $path");
        return null;
      }
    } catch (e) {
      debugPrint("[Utils] Error processing attachment: $e");
      return null;
    }
  }
}

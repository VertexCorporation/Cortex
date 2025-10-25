// utils.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';

import '../../models/backend/data/data.dart';

class Utils {

  static bool isLocalModel(String? modelId) => !isServerSideModel(modelId);

  static bool isServerSideModel(String? modelId) {
    if (modelId == null || modelId.isEmpty) {
      return false; // An empty ID can't be a server-side model.
    }

    // This is now the ONLY logic path. It is always correct.
    final modelData = ModelData.getPreciseModelData(modelId);
    final isOffline = modelData['type'] == 'offline';

    // Return true if the model is NOT offline.
    return !isOffline;
  }

  static Map<String, dynamic> getModelDataFromId(String targetModelId) {
    debugPrint(
        "[ChatScreenState.getModelDataFromId] Fetching data for '$targetModelId' using central ModelData service.");
    return ModelData.getPreciseModelData(targetModelId);
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

        if (mimeType == null || !['image/png', 'image/jpeg', 'image/webp'].contains(mimeType)) {
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
}
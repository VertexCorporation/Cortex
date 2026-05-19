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

  /// A static utility function to read a media file (image/video/audio), encode it to Base64,
  /// and format it as a data URL string.
  static Future<String?> formatBase64Media(String mediaPath) async {
    try {
      final mediaFile = File(mediaPath);
      if (await mediaFile.exists()) {
        // Read file bytes. For very large video files this could OOM,
        // but for now we follow the existing pattern.
        final mediaBytes = await mediaFile.readAsBytes();
        final mimeType = lookupMimeType(mediaPath, headerBytes: mediaBytes) ??
            'application/octet-stream';

        // Ensure it's media (we optionally could restrict down to mp4, wav, etc.)
        if (!mimeType.startsWith('image/') &&
            !mimeType.startsWith('video/') &&
            !mimeType.startsWith('audio/')) {
          debugPrint("Unsupported media type '$mimeType' for file: $mediaPath");
          return null;
        }

        final base64Media = base64Encode(mediaBytes);
        return 'data:$mimeType;base64,$base64Media';
      }
    } catch (e) {
      debugPrint("Error reading or encoding media file: $e");
    }
    return null;
  }

  /// Processes an attachment path and returns the correct OpenAI-compatible content block.
  /// - Images -> { "type": "image_url", "image_url": { "url": "..." } }
  /// - Text Files -> { "type": "text", "text": "..." }
  /// - Binary Documents (PDF, DOCX, XLSX, etc.) -> Stored separately for tool processing
  ///
  /// Returns a map with:
  /// - Standard content fields for API
  /// - "_document": Optional document data for tool processing (binary files)
  static Future<Map<String, dynamic>?> processAttachment(String path) async {
    try {
      final lowerPath = path.toLowerCase();
      final isRemoteOrDataUrl = lowerPath.startsWith('http://') ||
          lowerPath.startsWith('https://') ||
          lowerPath.startsWith('data:');
      if (isRemoteOrDataUrl) {
        final looksLikeMediaUrl = lowerPath.startsWith('data:image/') ||
            lowerPath.startsWith('data:video/') ||
            lowerPath.startsWith('data:audio/') ||
            RegExp(
              r'\.(jpg|jpeg|png|webp|gif|bmp|heic|mp4|webm|mov|mkv|m4v|mp3|wav|m4a|aac|ogg|flac|opus)(\?|$)',
            ).hasMatch(lowerPath);
        if (looksLikeMediaUrl) {
          return {
            "type": "image_url",
            "image_url": {"url": path}
          };
        }
      }

      final file = File(path);
      if (!await file.exists()) return null;

      final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
      final String fileName = path.split('/').last;
      final String extension = fileName.split('.').last.toLowerCase();

      // 1. Handle Media (Images, Video, Audio) - send as base64 data URL
      if (mimeType.startsWith('image/') ||
          mimeType.startsWith('video/') ||
          mimeType.startsWith('audio/')) {
        final base64Url = await formatBase64Media(path);
        if (base64Url != null) {
          // OpenRouter/OpenAI structure uses "image_url" conventionally
          // Fal.ai and custom Vertex routing will pull the URL from this object
          return {
            "type": "image_url",
            "image_url": {"url": base64Url}
          };
        }
      }

      // 2. Text-based files - read directly (no tool needed)
      // These can be read as plain text and included in the message
      final textExtensions = [
        // Plain text & markup
        'txt', 'md', 'rtf',
        // Data formats
        'json', 'xml', 'csv', 'tsv',
        // Web
        'html', 'htm', 'css',
        // Code
        'js', 'ts', 'jsx', 'tsx', 'py', 'dart', 'java', 'c', 'cpp', 'h', 'hpp',
        'swift', 'kt', 'go', 'rs', 'rb', 'php', 'sh', 'bash', 'ps1',
        'sql', 'r', 'scala', 'lua', 'pl', 'pm',
        // Config
        'yaml', 'yml', 'toml', 'ini', 'cfg', 'conf', 'env',
        // Logs
        'log',
      ];

      if (textExtensions.contains(extension) || mimeType.startsWith('text/')) {
        try {
          final String content = await file.readAsString();
          // Truncate very large files to prevent token overflow
          final truncatedContent = content.length > 50000
              ? '${content.substring(0, 50000)}\n\n[... truncated, file too large ...]'
              : content;
          return {
            "type": "text",
            "text": "[File: $fileName]\n```\n$truncatedContent\n```"
          };
        } catch (e) {
          debugPrint("[Utils] Could not read file as text: $path - $e");
          // Fall through to binary handling
        }
      }

      // 3. Binary documents - need server-side processing via tool
      // These require specialized parsers (pdf-parse, mammoth for docx, xlsx, etc.)
      final binaryDocExtensions = [
        'pdf', // PDF documents
        'doc', 'docx', // Word documents
        'xls', 'xlsx', // Excel spreadsheets
        'ppt', 'pptx', // PowerPoint presentations
        'odt', 'ods', 'odp', // OpenDocument formats
      ];

      if (binaryDocExtensions.contains(extension)) {
        try {
          final bytes = await file.readAsBytes();
          final base64Data = base64Encode(bytes);

          // Determine document type for better tool instructions
          String docType = 'document';
          if (extension == 'pdf') {
            docType = 'PDF';
          } else if (['doc', 'docx', 'odt'].contains(extension)) {
            docType = 'Word document';
          } else if (['xls', 'xlsx', 'ods', 'csv'].contains(extension)) {
            docType = 'spreadsheet';
          } else if (['ppt', 'pptx', 'odp'].contains(extension)) {
            docType = 'presentation';
          }

          return {
            "type": "text",
            "text":
                "[Attached: $fileName ($docType)]\nUse the read_document tool to extract and read the contents of this file.",
            "_document": {
              "data": base64Data,
              "media_type": mimeType,
              "fileName": fileName,
              "extension": extension,
            }
          };
        } catch (e) {
          debugPrint("[Utils] Error reading binary file: $e");
          return null;
        }
      }

      // 4. Unknown/unsupported files - try text first, then report unsupported
      try {
        final String content = await file.readAsString();
        return {
          "type": "text",
          "text": "[File: $fileName]\n```\n$content\n```"
        };
      } catch (e) {
        return {
          "type": "text",
          "text":
              "[Unsupported file: $fileName ($mimeType)]\nThis file type cannot be processed directly."
        };
      }
    } catch (e) {
      debugPrint("[Utils] Error processing attachment: $e");
      return null;
    }
  }

  /// Extracts document data from processed attachments for tool execution.
  /// Returns a list of document objects that can be sent to the server for read_document tool.
  static List<Map<String, dynamic>> extractDocuments(
      List<Map<String, dynamic>> contentBlocks) {
    final documents = <Map<String, dynamic>>[];
    for (final block in contentBlocks) {
      if (block.containsKey('_document')) {
        documents.add(block['_document'] as Map<String, dynamic>);
      }
    }
    return documents;
  }

  /// Cleans content blocks by removing internal _document fields before sending to API.
  static List<Map<String, dynamic>> cleanContentBlocks(
      List<Map<String, dynamic>> contentBlocks) {
    return contentBlocks.map((block) {
      final cleaned = Map<String, dynamic>.from(block);
      cleaned.remove('_document');
      return cleaned;
    }).toList();
  }
}

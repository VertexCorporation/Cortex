// utils.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';

/// A collection of static utility methods used across the application.
class Utils {
  static const Uuid _uuid = Uuid();

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
    // Web attachments are already data: URLs — pass them through untouched.
    if (filePath.startsWith('data:')) {
      // data:<mime>;base64,<payload> — the payload is the base64 data itself.
      final commaIndex = filePath.indexOf(',');
      if (commaIndex == -1) return null;
      final mimePart = filePath.substring(5, commaIndex); // after "data:"
      final mimeType = mimePart.split(';').first.isNotEmpty
          ? mimePart.split(';').first
          : 'application/octet-stream';
      final base64Data = filePath
          .substring(commaIndex + 1)
          .replaceAll(RegExp(r'\s+'), '');
      if (base64Data.isEmpty) return null;
      return {'mime_type': mimeType, 'data': base64Data};
    }
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
    // Web attachments are already data: URLs — pass them through untouched.
    if (mediaPath.startsWith('data:')) return mediaPath;
    try {
      final mediaFile = File(mediaPath);
      if (await mediaFile.exists()) {
        // Read file bytes. For very large video files this could OOM,
        // but for now we follow the existing pattern.
        final mediaBytes = await mediaFile.readAsBytes();
        final mimeType = lookupMimeType(mediaPath, headerBytes: mediaBytes) ??
            'application/octet-stream';

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

  /// Web: turns a non-media `data:` URL attachment into a scoped document
  /// whose payload is embedded as base64. Mirrors the io binary-document
  /// contract from [processAttachment], minus the file path — the browser has
  /// none, and read_document must not attempt dart:io materialization for
  /// these entries.
  static Map<String, dynamic>? _processDataUrlDocument(String path) {
    final uri = Uri.tryParse(path);
    final uriData = uri?.data;
    if (uriData == null) {
      debugPrint("[Utils] Attachment data URL could not be parsed.");
      return null;
    }

    final bytes = uriData.contentAsBytes();
    if (bytes.isEmpty) {
      debugPrint("[Utils] Attachment data URL is empty.");
      return null;
    }

    final mimeType = uriData.mimeType.isNotEmpty
        ? uriData.mimeType
        : 'application/octet-stream';
    final extension = mimeType.split('/').isEmpty || mimeType == 'application/octet-stream'
        ? ''
        : mimeType.split('/').last.split('-').first.toLowerCase();
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

    final scope = _uuid.v4();
    return {
      "type": "text",
      "text":
          "[Attached: attachment ($docType)]\nDocument scope: $scope\nUse the read_document tool with document_scope=\"$scope\" to extract and read this file. Do not reuse a scope from another message.",
      "_document": {
        "scope": scope,
        "data": base64Encode(bytes),
        "media_type": mimeType,
        "fileName": 'attachment.${extension.isEmpty ? 'bin' : extension}',
        "extension": extension,
        "size": bytes.length,
      },
    };
  }

  /// Reads only enough bytes for MIME sniffing. Some Android/iOS picker cache
  /// files have generic or missing extensions even though they contain a valid
  /// image. Relying only on the path can therefore make a visible attachment
  /// disappear from the API payload.
  static Future<List<int>> _readMimeProbe(File file) async {
    RandomAccessFile? handle;
    try {
      handle = await file.open();
      return await handle.read(512);
    } catch (_) {
      return const <int>[];
    } finally {
      await handle?.close();
    }
  }

  /// Detects images by extension or content when picker cache paths are extensionless.
  static Future<bool> isImageAttachmentPath(String path) async {
    final lowerPath = path.toLowerCase();
    if (lowerPath.startsWith('data:image/')) return true;
    if (lowerPath.startsWith('http://') || lowerPath.startsWith('https://')) {
      return RegExp(r'\.(jpg|jpeg|png|webp|gif|bmp|heic|heif)(\?|$)')
          .hasMatch(lowerPath);
    }
    if (RegExp(r'\.(jpg|jpeg|png|webp|gif|bmp|heic|heif)$')
        .hasMatch(lowerPath)) {
      return true;
    }
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final handle = await file.open();
      late final List<int> probe;
      try {
        probe = await handle.read(512);
      } finally {
        await handle.close();
      }
      return lookupMimeType(
            path,
            headerBytes: probe.isEmpty ? null : probe,
          )?.startsWith('image/') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Processes an attachment path and returns the correct OpenAI-compatible content block.
  /// - Images -> { "type": "image_url", "image_url": { "url": "..." } }
  /// - Text Files -> { "type": "text", "text": "..." }
  /// - Binary Documents (PDF, DOCX, XLSX, etc.) -> Stored separately for tool processing
  ///
  /// Returns a map with:
  /// - Standard content fields for API
  /// - "_document": Optional scoped document metadata for tool processing
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
              r'\.(jpg|jpeg|png|webp|gif|bmp|heic|heif|mp4|webm|mov|mkv|m4v|mp3|wav|m4a|aac|ogg|flac|opus)(\?|$)',
            ).hasMatch(lowerPath);
        if (looksLikeMediaUrl) {
          final mediaType = lowerPath.startsWith('data:video/') ||
                  RegExp(r'\.(mp4|webm|mov|mkv|m4v)(\?|$)').hasMatch(lowerPath)
              ? 'video_url'
              : lowerPath.startsWith('data:audio/') ||
                      RegExp(r'\.(mp3|wav|m4a|aac|ogg|flac|opus)(\?|$)')
                          .hasMatch(lowerPath)
                  ? 'audio_url'
                  : 'image_url';
          return {
            "type": mediaType,
            mediaType: {"url": path}
          };
        }

        // Web attachments always arrive as `data:` URLs (there is no local
        // file system there). Non-media payloads (PDF, DOCX, ...) cannot
        // fall through to the dart:io File branch — File operations throw
        // on web and the attachment would be silently dropped. Instead they
        // are registered as scoped documents with their payload embedded, so
        // read_document needs no file materialization on the browser.
        if (lowerPath.startsWith('data:')) {
          return _processDataUrlDocument(path);
        }
      }

      final file = File(path);
      if (!await file.exists()) {
        debugPrint("[Utils] Attachment no longer exists: $path");
        return null;
      }

      final mimeProbe = await _readMimeProbe(file);
      final mimeType = lookupMimeType(
            path,
            headerBytes: mimeProbe.isEmpty ? null : mimeProbe,
          ) ??
          'application/octet-stream';
      final String fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : path.split('/').last;
      final int dotIndex = fileName.lastIndexOf('.');
      final String extension = dotIndex >= 0 && dotIndex < fileName.length - 1
          ? fileName.substring(dotIndex + 1).toLowerCase()
          : '';

      // 1. Handle Media (Images, Video, Audio) - send as base64 data URL.
      // MIME is sniffed from file bytes so picker-cache paths without a useful
      // extension still reach vision-capable models.
      if (mimeType.startsWith('image/') ||
          mimeType.startsWith('video/') ||
          mimeType.startsWith('audio/')) {
        final base64Url = await formatBase64Media(path);
        if (base64Url != null) {
          // OpenRouter/OpenAI structure uses "image_url" conventionally
          // Fal.ai and custom Vertex routing will pull the URL from this object
          final mediaType = mimeType.startsWith('video/')
              ? 'video_url'
              : mimeType.startsWith('audio/')
                  ? 'audio_url'
                  : 'image_url';
          return {
            "type": mediaType,
            mediaType: {"url": base64Url}
          };
        }
        debugPrint("[Utils] Failed to encode media attachment: $path");
        return null;
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

      // 3. Binary documents - parsed only if/when the model calls read_document.
      // Keeping the local path here avoids eagerly reading + base64-encoding a
      // potentially large PDF on the UI path. ToolRegistry materializes the
      // scoped file immediately before the authenticated server tool call.
      final binaryDocExtensions = [
        'pdf', // PDF documents
        'doc', 'docx', // Word documents
        'xls', 'xlsx', // Excel spreadsheets
        'ppt', 'pptx', // PowerPoint presentations
        'odt', 'ods', 'odp', // OpenDocument formats
      ];

      if (binaryDocExtensions.contains(extension)) {
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

        final scope = _uuid.v4();
        final fileSize = await file.length();
        return {
          "type": "text",
          "text":
              "[Attached: $fileName ($docType)]\nDocument scope: $scope\nUse the read_document tool with document_scope=\"$scope\" to extract and read this file. Do not reuse a scope from another message.",
          "_document": {
            "scope": scope,
            "path": path,
            "media_type": mimeType,
            "fileName": fileName,
            "extension": extension,
            "size": fileSize,
          }
        };
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

  /// Extracts scoped document metadata from processed attachments for tool execution.
  /// Returns a list of document objects that can later be materialized by read_document.
  static List<Map<String, dynamic>> extractDocuments(
      List<Map<String, dynamic>> contentBlocks) {
    final documents = <Map<String, dynamic>>[];
    for (final block in contentBlocks) {
      if (block.containsKey('_document')) {
        documents.add(
          Map<String, dynamic>.from(block['_document'] as Map<String, dynamic>),
        );
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

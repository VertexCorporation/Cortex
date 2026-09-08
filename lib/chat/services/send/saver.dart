// lib/chat/services/send/saver.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Service responsible for persisting generated media (images, audio, video)
/// either from base64 data URIs or by downloading from remote HTTP/HTTPS URLs.
class MediaSaver {
  static const Uuid _uuid = Uuid();

  static String inferMediaExtension({
    required String url,
    required List<String> allowedExtensions,
    required String fallbackExtension,
  }) {
    final mimeMatch =
        RegExp(r'^data:([^;]+);base64,', caseSensitive: false).firstMatch(url);
    if (mimeMatch != null) {
      final mime = (mimeMatch.group(1) ?? '').toLowerCase();
      final slashIndex = mime.indexOf('/');
      if (slashIndex != -1 && slashIndex < mime.length - 1) {
        final mimeExt = mime.substring(slashIndex + 1);
        if (allowedExtensions.contains(mimeExt)) {
          return mimeExt;
        }
      }
    }

    final ext =
        p.extension(url.split('?').first).toLowerCase().replaceAll('.', '');
    if (allowedExtensions.contains(ext)) {
      return ext;
    }

    return fallbackExtension;
  }

  static Future<String> persistGeneratedMedia({
    required String url,
    required String dataPrefix,
    required List<String> allowedExtensions,
    required String fallbackExtension,
  }) async {
    final ext = inferMediaExtension(
      url: url,
      allowedExtensions: allowedExtensions,
      fallbackExtension: fallbackExtension,
    );
    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/${_uuid.v4()}.$ext';

    if (url.startsWith(dataPrefix)) {
      try {
        final commaIndex = url.indexOf(',');
        if (commaIndex <= 0 || commaIndex >= url.length - 1) return url;
        final encoded = url.substring(commaIndex + 1);
        final bytes = base64Decode(encoded);
        await File(localPath).writeAsBytes(bytes);
        return localPath;
      } catch (e) {
        debugPrint("Media data URI decode failed. Falling back to raw URL: $e");
        return url;
      }
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      try {
        final request = await HttpClient().getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'Unexpected HTTP status: ${response.statusCode}',
            uri: Uri.parse(url),
          );
        }
        final bytes = await consolidateHttpClientResponseBytes(response);
        await File(localPath).writeAsBytes(bytes);
        return localPath;
      } catch (e) {
        debugPrint("Media download failed. Falling back to remote URL: $e");
        return url;
      }
    }

    return url;
  }
}

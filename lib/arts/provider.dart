// lib/arts/provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../chat/services/storage.dart';

/// Represents a single media item in the Arts gallery.
class ArtItem {
  final String path;
  final ArtType type;
  final String conversationID;
  final String? modelId;

  const ArtItem({required this.path, required this.type, required this.conversationID, this.modelId});
}

enum ArtType { image, video, audio }

/// Provider that queries the database for all AI-generated media
/// and exposes them as a flat list for the Arts gallery.
class ArtsProvider extends ChangeNotifier {
  List<ArtItem> _items = [];
  bool _isLoading = true;

  List<ArtItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  static const _imageExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'
  };
  static const _videoExtensions = {'mp4', 'webm', 'mov', 'mkv', 'm4v'};
  static const _audioExtensions = {'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'};

  /// Loads all generated media from the database.
  Future<void> loadMedia() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await ChatStorageService.getAllGeneratedMedia();
      final List<ArtItem> results = [];

      for (final row in rows) {
        final raw = row['photoPath'] as String?;
        if (raw == null || raw.isEmpty) continue;

        // photoPath can be a JSON array or a single path
        List<String> paths;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            paths = decoded.cast<String>();
          } else {
            paths = [raw];
          }
        } catch (_) {
          paths = [raw];
        }

        final conversationID = row['conversationId'] as String?;
        final modelId = row['modelId'] as String?;

        for (final filePath in paths) {
          if (filePath.isEmpty) continue;

          // Only include local files (not remote URLs)
          if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
            continue;
          }

          // Check file actually exists
          if (!File(filePath).existsSync()) continue;

          final ext = p.extension(filePath).toLowerCase().replaceAll('.', '');
          ArtType? type;

          if (_imageExtensions.contains(ext)) {
            type = ArtType.image;
          } else if (_videoExtensions.contains(ext)) {
            type = ArtType.video;
          } else if (_audioExtensions.contains(ext)) {
            type = ArtType.audio;
          }

          if (type != null) {
            results.add(ArtItem(path: filePath, type: type, conversationID: conversationID ?? '', modelId: modelId));
          }
        }
      }

      _items = results;
    } catch (e) {
      debugPrint('[ArtsProvider] Error loading media: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the gallery (e.g. after new media is generated).
  Future<void> refresh() => loadMedia();
}

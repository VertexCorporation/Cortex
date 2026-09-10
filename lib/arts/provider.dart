// lib/arts/provider.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../chat/services/storage.dart';

/// Represents a single media item in the Arts gallery.
class ArtItem {
  final String path;
  final ArtType type;
  final String conversationID;
  final String? modelId;

  const ArtItem(
      {required this.path,
      required this.type,
      required this.conversationID,
      this.modelId});
}

enum ArtType { image, video, audio }

/// Provider that queries the database for all AI-generated media
/// and exposes them as a flat list for the Arts gallery.
class ArtsProvider extends ChangeNotifier {
  List<ArtItem> _items = [];
  bool _isLoading = true;

  StreamSubscription? _msgSub;

  List<ArtItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  ArtsProvider() {
    _msgSub = ChatStorageService.lastMsgStream.listen((event) {
      if (event['photoPath'] != null &&
          event['photoPath'].toString().isNotEmpty) {
        loadMedia();
      }
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  static const _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'heic'
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

      // GENERATED MEDIA PERSISTENCE DIAGNOSTICS: distinguish the three ways
      // an item can be absent from the gallery so the next production report
      // pinpoints the exact failure mode:
      //  - remoteUrl: MediaSaver fell back to a signed CDN URL (file download
      //    failed at generation time) — renders during the session, expires
      //    after it, intentionally never shown here.
      //  - missingFile: the recorded local file is gone (external deletion).
      //  - healed: the recorded absolute path pointed into an old app
      //    container; re-rooted against the current Documents directory.
      int remoteUrlSkipped = 0;
      int missingFileSkipped = 0;
      int healedPaths = 0;

      for (final row in rows) {
        final raw = row['photoPath'] as String?;
        if (raw == null || raw.isEmpty) continue;

        List<String> paths;
        if (raw.startsWith('[')) {
          try {
            paths = (jsonDecode(raw) as List).cast<String>();
          } catch (_) {
            paths = [raw];
          }
        } else {
          paths = [raw];
        }

        final conversationID = row['conversationId'] as String?;
        final modelId = row['modelId'] as String?;

        for (final filePath in paths) {
          if (filePath.isEmpty) continue;

          if (filePath.startsWith('http://') ||
              filePath.startsWith('https://')) {
            remoteUrlSkipped++;
            continue;
          }

          final resolved = await _resolveExistingPath(filePath);
          if (resolved == null) {
            missingFileSkipped++;
            continue;
          }
          if (resolved != filePath) {
            healedPaths++;
          }

          final ext =
              p.extension(resolved).toLowerCase().replaceAll('.', '');
          ArtType? type;

          if (_imageExtensions.contains(ext)) {
            type = ArtType.image;
          } else if (_videoExtensions.contains(ext)) {
            type = ArtType.video;
          } else if (_audioExtensions.contains(ext)) {
            type = ArtType.audio;
          }

          if (type != null) {
            results.add(ArtItem(
                path: resolved,
                type: type,
                conversationID: conversationID ?? '',
                modelId: modelId));
          }
        }
      }

      _items = results;

      if (remoteUrlSkipped > 0 || missingFileSkipped > 0 || healedPaths > 0) {
        debugPrint('[ArtsProvider] loadMedia: ${results.length} shown | '
            'skipped remote-url=$remoteUrlSkipped, missing-file='
            '$missingFileSkipped | healed-stale-paths=$healedPaths');
      }
    } catch (e) {
      debugPrint('[ArtsProvider] Error loading media: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves a stored attachment path against the CURRENT app container.
  ///
  /// Absolute paths become stale when the OS relocates the app container
  /// (e.g. iOS app updates). If the file is missing at its recorded
  /// location, try the same basename under the current Documents directory
  /// before giving up — that heals entries recorded before a container move
  /// instead of dropping them from the gallery entirely.
  Future<String?> _resolveExistingPath(String filePath) async {
    if (await File(filePath).exists()) return filePath;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final basename = p.basename(filePath);
      if (basename.isEmpty) return null;
      final candidate = p.join(docsDir.path, basename);
      if (candidate != filePath && await File(candidate).exists()) {
        return candidate;
      }
    } catch (_) {}
    return null;
  }

  /// Refresh the gallery (e.g. after new media is generated).
  Future<void> refresh() => loadMedia();
}

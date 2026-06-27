import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// A service that provides fast, on-device text moderation using a
/// remotely configured and locally compiled Regex rule.
class OfflineModeratorService {
  static final OfflineModeratorService _instance = OfflineModeratorService._internal();
  factory OfflineModeratorService() => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // The compiled Regex rule. This is what makes the check super fast.
  RegExp? _compiledRegex;

  OfflineModeratorService._internal();

  /// Initializes the service, fetches the config, and prepares the Regex.
  /// This should be called once when the app starts, for example in `main.dart`.
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Fetch updates max once per hour
      ));
      await _remoteConfig.fetchAndActivate();
      _buildAndCompileRegex();

      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        _buildAndCompileRegex();
        debugPrint("[OfflineModerator] Rules updated and re-compiled.");
      }).onError((error) {
        debugPrint("[OfflineModerator] Config stream error ignored safely: $error");
      });
    } catch (e) {
      debugPrint("[OfflineModerator] Failed to initialize: $e");
      // Try to build from cache even if fetch fails
      _buildAndCompileRegex();
    }
  }

  void _buildAndCompileRegex() {
    final jsonString = _remoteConfig.getString('offline_moderation_blacklist');
    if (jsonString.isEmpty) {
      debugPrint("[OfflineModerator] Warning: Blacklist from Remote Config is empty.");
      _compiledRegex = null;
      return;
    }

    try {
      final Map<String, dynamic> config = jsonDecode(jsonString);
      final List<String> patterns = [];

      // Add exact words, surrounded by word boundaries to prevent partial matches.
      final List<String> exactWords = List<String>.from(config['exactWords'] ?? []);
      if (exactWords.isNotEmpty) {
        patterns.add(r'\b(' + exactWords.join('|') + r')\b');
      }

      // Add word roots, allowing for suffixes.
      final List<String> wordRoots = List<String>.from(config['wordRoots'] ?? []);
      if (wordRoots.isNotEmpty) {
        patterns.add(r'(' + wordRoots.join('|') + r')\w*');
      }

      // Add multi-word phrases.
      final List<String> phrases = List<String>.from(config['phrases'] ?? []);
      if (phrases.isNotEmpty) {
        patterns.add('(${phrases.map((p) => p.replaceAll(' ', r'\s+')).join('|')})');
      }

      if (patterns.isEmpty) {
        _compiledRegex = null;
        return;
      }

      // Join all patterns with '|' (OR) to create one master pattern.
      final fullPattern = patterns.join('|');

      // Compile the pattern once for maximum performance.
      _compiledRegex = RegExp(fullPattern, caseSensitive: false, unicode: true);

      debugPrint("[OfflineModerator] Regex successfully compiled.");

    } catch (e) {
      debugPrint("[OfflineModerator] Failed to parse or compile Regex: $e");
      _compiledRegex = null;
    }
  }

  /// Checks if a prompt is acceptable using the compiled Regex.
  bool isPromptAcceptable(String prompt) {
    if (_compiledRegex == null) {
      debugPrint("[OfflineModerator] Regex not available. Allowing prompt as a fallback.");
      return true; // Fail open: if the system is broken, don't block users.
    }

    // This is the single, ultra-fast check. No loops.
    if (_compiledRegex!.hasMatch(prompt)) {
      debugPrint("[OfflineModerator] Prompt rejected by on-device moderation rule.");
      return false;
    }

    return true;
  }
}
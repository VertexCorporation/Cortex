// lib/chat/services/voice_catalog.dart
//
// The set of voices Cortex can speak with, and which one this user picked.
//
// The list lives in Firestore (`server/voice`) rather than in the app, so
// voices can be added, reordered or replaced without shipping a release. The
// choice itself is local — it is a preference, not account state, and it should
// survive being offline.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tts_remote.dart';

/// One selectable voice, as published in `server/voice.voices`.
class CortexVoice {
  const CortexVoice({required this.id, required this.name, this.description});

  final String id;
  final String name;

  /// Optional one-line character note ("warm, conversational"), shown under the
  /// name so the list is scannable without playing every sample.
  final String? description;

  static CortexVoice? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || id.trim().isEmpty) return null;
    return CortexVoice(
      id: id.trim(),
      name: name is String && name.trim().isNotEmpty ? name.trim() : id.trim(),
      description: raw['description'] is String && (raw['description'] as String).trim().isNotEmpty
          ? (raw['description'] as String).trim()
          : null,
    );
  }
}

class VoiceCatalogProvider extends ChangeNotifier {
  static const String _prefsKey = 'selected_voice_id';

  List<CortexVoice> _voices = const [];
  String? _defaultVoiceId;
  String? _selectedVoiceId;
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<CortexVoice> get voices => _voices;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  /// Null until the user picks one, which is the signal to let the server
  /// decide. The distinction matters: "no choice" should follow the published
  /// default as it changes, rather than pinning whatever it happened to be.
  String? get selectedVoiceId => _selectedVoiceId;

  /// What to send with a synthesis request. Null means "server decides".
  String? get effectiveVoiceId => _selectedVoiceId ?? _defaultVoiceId;

  CortexVoice? get selectedVoice {
    final id = effectiveVoiceId;
    if (id == null) return null;
    for (final voice in _voices) {
      if (voice.id == id) return voice;
    }
    return null;
  }

  /// Reads the stored choice, then the published list. The choice is read first
  /// so a slow or failed catalog fetch does not make the settings row look
  /// unset to someone who has already chosen.
  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !force) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null && stored.trim().isNotEmpty) {
        _selectedVoiceId = stored.trim();
      }
    } catch (e) {
      debugPrint("[VoiceCatalog] Could not read stored voice: $e");
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('server')
          .doc('voice')
          .get();

      final data = snapshot.data();
      if (data != null) {
        final rawDefault = data['defaultVoiceId'];
        _defaultVoiceId = rawDefault is String && rawDefault.trim().isNotEmpty
            ? rawDefault.trim()
            : null;

        final rawList = data['voices'];
        if (rawList is List) {
          _voices = rawList
              .map(CortexVoice.fromMap)
              .whereType<CortexVoice>()
              .toList(growable: false);
        }
      }
      _hasLoaded = true;
    } catch (e) {
      // An empty catalog is a working state: the picker hides itself and the
      // server falls back to its default.
      debugPrint("[VoiceCatalog] Could not load voices: $e");
    }

    // A voice can be retired between releases. Drop a stale selection rather
    // than sending an id the provider will reject.
    if (_selectedVoiceId != null &&
        _voices.isNotEmpty &&
        !_voices.any((v) => v.id == _selectedVoiceId)) {
      debugPrint("[VoiceCatalog] Stored voice is no longer published; clearing.");
      _selectedVoiceId = null;
      unawaitedClear();
    }

    _publish();
    _isLoading = false;
    notifyListeners();
  }

  /// Voice mode reads the id off the TTS service rather than this provider, so
  /// every change has to be pushed there.
  void _publish() {
    RemoteTtsService.instance.activeVoiceId = effectiveVoiceId;
  }

  Future<void> select(String voiceId) async {
    final trimmed = voiceId.trim();
    if (trimmed.isEmpty || trimmed == _selectedVoiceId) return;

    _selectedVoiceId = trimmed;
    _publish();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, trimmed);
    } catch (e) {
      debugPrint("[VoiceCatalog] Could not persist voice: $e");
    }
  }

  /// Returns to whatever the server publishes as the default.
  Future<void> clearSelection() async {
    if (_selectedVoiceId == null) return;
    _selectedVoiceId = null;
    _publish();
    notifyListeners();
    await unawaitedClear();
  }

  Future<void> unawaitedClear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      debugPrint("[VoiceCatalog] Could not clear stored voice: $e");
    }
  }
}

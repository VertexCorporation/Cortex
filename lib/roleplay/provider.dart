// lib/roleplay/provider.dart
//
// State management for the entire Roleplay / Character AI system.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'data/characters.dart';
import 'models/character.dart';

const _kSessionsKey = 'rp_sessions_v1';
const _kUserCharsKey = 'rp_user_chars_v1';
const _uuid = Uuid();

class RoleplayProvider with ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────────

  List<RoleplayCharacter> _featured = [];
  List<RoleplayCharacter> _userCharacters = [];
  List<RoleplaySession> _sessions = [];

  CharacterCategory _selectedCategory = CharacterCategory.featured;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Active roleplay session (in chat screen)
  RoleplaySession? _activeSession;
  bool _isSendingMessage = false;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<RoleplayCharacter> get featured => _featured;
  List<RoleplayCharacter> get userCharacters => _userCharacters;
  List<RoleplaySession> get sessions => _sessions;
  CharacterCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RoleplaySession? get activeSession => _activeSession;
  bool get isSendingMessage => _isSendingMessage;

  List<RoleplayCharacter> get allCharacters =>
      [..._featured, ..._userCharacters];

  List<RoleplayCharacter> get filteredCharacters {
    var list = allCharacters;

    if (_selectedCategory != CharacterCategory.featured) {
      list = list.where((c) => c.category == _selectedCategory).toList();
    } else {
      // Featured tab shows official chars by popularity
      list = list.where((c) => c.isOfficial).toList();
      list.sort((a, b) => b.chatCount.compareTo(a.chatCount));
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.tagline.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  // ── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _featured = kFeaturedCharacters;
      await _loadUserCharacters();
      await _loadSessions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[RoleplayProvider] init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filtering / Search ───────────────────────────────────────────────────

  void setCategory(CharacterCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Session Management ───────────────────────────────────────────────────

  Future<RoleplaySession> startSession(
    RoleplayCharacter character, {
    String? userPersonaName,
  }) async {
    // Check if existing session for this character
    final existing = _sessions.where((s) => s.character.id == character.id);
    if (existing.isNotEmpty) {
      _activeSession = existing.first;
      notifyListeners();
      return _activeSession!;
    }

    final session = RoleplaySession(
      id: _uuid.v4(),
      character: character,
      messages: [],
      startedAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      userPersonaName: userPersonaName,
    );

    _sessions.insert(0, session);
    _activeSession = session;
    await _saveSessions();
    notifyListeners();
    return session;
  }

  void setActiveSession(RoleplaySession session) {
    _activeSession = session;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSession?.id == sessionId) {
      _activeSession = null;
    }
    await _saveSessions();
    notifyListeners();
  }

  Future<void> clearActiveSession() async {
    _activeSession = null;
    notifyListeners();
  }

  // ── Messaging ────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String text,
    required Future<String> Function(
      List<RoleplayMessage> history,
      RoleplayCharacter character,
    ) aiResponseFn,
  }) async {
    if (_activeSession == null || text.trim().isEmpty) return;

    final userMsg = RoleplayMessage(
      id: _uuid.v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add loading placeholder for AI
    final loadingMsg = RoleplayMessage(
      id: _uuid.v4(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    _updateSession(
      _activeSession!.copyWith(
        messages: [..._activeSession!.messages, userMsg, loadingMsg],
        lastMessageAt: DateTime.now(),
      ),
    );

    _isSendingMessage = true;
    notifyListeners();

    try {
      final response = await aiResponseFn(
        _activeSession!.messages.where((m) => !m.isLoading).toList(),
        _activeSession!.character,
      );

      final aiMsg = RoleplayMessage(
        id: loadingMsg.id,
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: false,
      );

      final updatedMessages = _activeSession!.messages
          .map((m) => m.id == loadingMsg.id ? aiMsg : m)
          .toList();

      _updateSession(
        _activeSession!.copyWith(
          messages: updatedMessages,
          lastMessageAt: DateTime.now(),
        ),
      );
    } catch (e) {
      // Replace loading with error
      final errorMsg = RoleplayMessage(
        id: loadingMsg.id,
        text: '❌ Yanıt alınamadı. Tekrar dene.',
        isUser: false,
        timestamp: DateTime.now(),
        isLoading: false,
      );
      final updatedMessages = _activeSession!.messages
          .map((m) => m.id == loadingMsg.id ? errorMsg : m)
          .toList();
      _updateSession(
        _activeSession!.copyWith(messages: updatedMessages),
      );
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }

    await _saveSessions();
  }

  // ── User Character CRUD ──────────────────────────────────────────────────

  Future<void> createCharacter(RoleplayCharacter character) async {
    _userCharacters.insert(0, character);
    await _saveUserCharacters();
    notifyListeners();
  }

  Future<void> updateCharacter(RoleplayCharacter character) async {
    final idx = _userCharacters.indexWhere((c) => c.id == character.id);
    if (idx == -1) return;
    _userCharacters[idx] = character;
    await _saveUserCharacters();
    notifyListeners();
  }

  Future<void> deleteCharacter(String characterId) async {
    _userCharacters.removeWhere((c) => c.id == characterId);
    await _saveUserCharacters();
    notifyListeners();
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  void _updateSession(RoleplaySession updated) {
    final idx = _sessions.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _sessions[idx] = updated;
    }
    if (_activeSession?.id == updated.id) {
      _activeSession = updated;
    }
  }

  Future<void> _loadUserCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kUserCharsKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _userCharacters = list
          .map((j) => RoleplayCharacter.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[RoleplayProvider] _loadUserCharacters error: $e');
    }
  }

  Future<void> _saveUserCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kUserCharsKey,
        jsonEncode(_userCharacters.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('[RoleplayProvider] _saveUserCharacters error: $e');
    }
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSessionsKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _sessions =
          list.map((j) => _sessionFromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[RoleplayProvider] _loadSessions error: $e');
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only last 50 sessions to prevent bloat
      final toSave = _sessions.take(50).toList();
      await prefs.setString(
        _kSessionsKey,
        jsonEncode(toSave.map((s) => _sessionToJson(s)).toList()),
      );
    } catch (e) {
      debugPrint('[RoleplayProvider] _saveSessions error: $e');
    }
  }

  Map<String, dynamic> _sessionToJson(RoleplaySession s) {
    return {
      'id': s.id,
      'character': s.character.toJson(),
      'messages': s.messages
          .where((m) => !m.isLoading)
          .map((m) => {
                'id': m.id,
                'text': m.text,
                'isUser': m.isUser,
                'timestamp': m.timestamp.toIso8601String(),
              })
          .toList(),
      'startedAt': s.startedAt.toIso8601String(),
      'lastMessageAt': s.lastMessageAt.toIso8601String(),
      'userPersonaName': s.userPersonaName,
    };
  }

  RoleplaySession _sessionFromJson(Map<String, dynamic> j) {
    final msgs = (j['messages'] as List<dynamic>?)
            ?.map((m) => RoleplayMessage(
                  id: m['id'] as String,
                  text: m['text'] as String,
                  isUser: m['isUser'] as bool,
                  timestamp:
                      DateTime.tryParse(m['timestamp'] as String? ?? '') ??
                          DateTime.now(),
                ))
            .toList() ??
        [];
    return RoleplaySession(
      id: j['id'] as String,
      character:
          RoleplayCharacter.fromJson(j['character'] as Map<String, dynamic>),
      messages: msgs,
      startedAt:
          DateTime.tryParse(j['startedAt'] as String? ?? '') ?? DateTime.now(),
      lastMessageAt: DateTime.tryParse(j['lastMessageAt'] as String? ?? '') ??
          DateTime.now(),
      userPersonaName: j['userPersonaName'] as String?,
    );
  }
}

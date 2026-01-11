// lib/inbox/providers/general.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../cache.dart';
import '../../chat/services/database.dart';
import '../../chat/services/storage.dart';
import '../../library/backend/data/service.dart';
import '../../notifications/introvert.dart';
import '../manager.dart';

class InboxViewModel extends ChangeNotifier {
  final ModelService _modelService;
  final IntrovertNotificationService _notificationService;

  final Map<String, ConversationManager> _conversationManagers = {};

  // Master list of all IDs (sorted by Pin -> Date)
  List<String> _allConversationIDs = [];

  // List actually displayed (filtered by search)
  List<String> _filteredConversationIDs = [];

  bool _isLoading = true;
  String _currentSearchQuery = "";
  StreamSubscription<Map<String, dynamic>>? _lastMessageSubscription;

  // IDs currently being removed with an animation.
  final Set<String> _deletingConversationIDs = {};

  String _currentLangCode = 'en';

  bool get isLoading => _isLoading;
  List<String> get conversations => _filteredConversationIDs;
  Map<String, ConversationManager> get conversationManagers => _conversationManagers;
  Set<String> get deletingConversationIDs => Set.unmodifiable(_deletingConversationIDs);

  InboxViewModel({
    required ModelService modelService,
    required IntrovertNotificationService notificationService,
  })  : _modelService = modelService,
        _notificationService = notificationService;

  Future<void> initialize(String langCode) async {
    _currentLangCode = langCode;
    _loadFromCache();
    _listenForLastMessageUpdates();
    await loadConversations(langCode: langCode);
  }

  @override
  void dispose() {
    _lastMessageSubscription?.cancel();
    for (var manager in _conversationManagers.values) {
      manager.dispose();
    }
    super.dispose();
  }

  void filterConversations(String query) {
    _currentSearchQuery = query.trim().toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    if (_currentSearchQuery.isEmpty) {
      _filteredConversationIDs = List.from(_allConversationIDs);
    } else {
      _filteredConversationIDs = _allConversationIDs.where((id) {
        final manager = _conversationManagers[id];
        if (manager == null) return false;
        return manager.conversationTitle.toLowerCase().contains(_currentSearchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void _sortConversations() {
    _allConversationIDs.sort((a, b) {
      final managerA = _conversationManagers[a];
      final managerB = _conversationManagers[b];
      if (managerA == null || managerB == null) return 0;

      // 1. Pinned items go to top
      if (managerA.isStarred != managerB.isStarred) {
        return managerA.isStarred ? -1 : 1;
      }

      // 2. Then sort by Date (Newest first)
      return managerB.lastMessageDate.compareTo(managerA.lastMessageDate);
    });

    // Re-apply filter after sort
    _applyFilter();
  }

  void _loadFromCache() {
    final cachedManagers = CacheService.get<Map<String, ConversationManager>>(CacheKey.conversationManagers);
    final cachedOrder = CacheService.get<List<String>>(CacheKey.conversationOrder);

    if (cachedManagers != null && cachedOrder != null) {
      _conversationManagers.addAll(cachedManagers);
      _allConversationIDs = cachedOrder;
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshIfNeeded() async {
    // Logic to check if reload is needed based on app state
    await loadConversations(langCode: _currentLangCode, isReload: true);
  }

  void _listenForLastMessageUpdates() {
    _lastMessageSubscription?.cancel();
    _lastMessageSubscription = ChatStorageService.lastMsgStream.listen((update) async {
      final String convId = update['convId'] as String;
      final manager = _conversationManagers[convId];

      if (manager == null) {
        await loadConversations(langCode: _currentLangCode, isReload: true);
        return;
      }

      manager.updateLastMessage(
        update['text'] as String? ?? '',
        update['photoPath'] as String? ?? '',
        DateTime.fromMillisecondsSinceEpoch(update['ts'] as int),
      );

      _sortConversations();
    });
  }

  Future<void> loadConversations({required String langCode, bool isReload = false}) async {
    if (_conversationManagers.isEmpty || isReload) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _modelService.getModels(langCode: langCode);
      final db = await DbHelper().db;
      final rows = await db.query('conversations');

      _conversationManagers.clear();
      _allConversationIDs.clear();

      for (final row in rows) {
        final convID = row['id'] as String;
        final modelId = row['modelId'] as String? ?? '';

        // Simple create logic
        final lastMsg = await ChatStorageService.getLastMessage(convID);
        final manager = ConversationManager(
          conversationID: convID,
          conversationTitle: row['title'] as String? ?? 'Untitled',
          initialModelId: modelId,
          isStarred: (row['isStarred'] as int? ?? 0) == 1,
          lastMessageDate: lastMsg?['ts'] != null
              ? DateTime.fromMillisecondsSinceEpoch(lastMsg!['ts'] as int)
              : DateTime.fromMillisecondsSinceEpoch(row['lastMessageDate'] as int? ?? 0),
          langCode: langCode,
          modelService: _modelService,
        );

        _conversationManagers[convID] = manager;
        _allConversationIDs.add(convID);
      }

      _sortConversations();
    } catch (e) {
      debugPrint("Error loading conversations: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      _updateConversationCache();
    }
  }

  Future<void> deleteConversation(String conversationID) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    _deletingConversationIDs.add(conversationID);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _conversationManagers.remove(conversationID);
    _allConversationIDs.remove(conversationID);
    _deletingConversationIDs.remove(conversationID);
    _sortConversations();

    manager.dispose();
    await ChatStorageService.deleteConversation(conversationID);
    _updateConversationCache();
  }

  Future<void> editConversation(String conversationID, String newTitle) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    await ChatStorageService.renameConversation(conversationID, newTitle);
    manager.updateConversationTitle(newTitle);
    _notificationService.showNotification(message: "Renamed", type: NotificationType.success);
  }

  Future<void> togglePinStatus(String conversationID) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    final newStatus = !manager.isStarred;
    manager.setStarred(newStatus);
    await ChatStorageService.setStarred(conversationID, newStatus);

    _sortConversations();
    _updateConversationCache();
  }

  void _updateConversationCache() {
    CacheService.set(CacheKey.conversationManagers, Map.of(_conversationManagers));
    CacheService.set(CacheKey.conversationOrder, List.of(_allConversationIDs));
  }
}
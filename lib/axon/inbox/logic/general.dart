// lib/axon/inbox/logic/general.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../cache.dart';
import '../../../chat/providers/conversation.dart';

import '../../../chat/services/storage.dart';
import '../../../l10n/app_localizations.dart';
import '../../../library/backend/data/service.dart';
import '../../../main.dart';
import '../../../notifications/introvert.dart';
import 'manager.dart';

class InboxViewModel extends ChangeNotifier {
  final ModelService _modelService;
  final IntrovertNotificationService _notificationService;

  final Map<String, ConversationManager> _conversationManagers = {};
  List<String> _allConversationIDs = [];
  List<String> _filteredConversationIDs = [];

  bool _isLoading = true;
  String _currentSearchQuery = "";
  StreamSubscription<Map<String, dynamic>>? _lastMessageSubscription;
  StreamSubscription<Map<String, String>>? _titleSubscription;
  String _currentLangCode = 'en';
  Timer? _searchDebounce;

  bool get isLoading => _isLoading;

  List<String> get conversations => _filteredConversationIDs;

  Map<String, ConversationManager> get conversationManagers =>
      _conversationManagers;

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
    _searchDebounce?.cancel();
    _lastMessageSubscription?.cancel();
    _titleSubscription?.cancel();
    for (var manager in _conversationManagers.values) {
      manager.dispose();
    }
    super.dispose();
  }

  void filterConversations(String query) {
    _currentSearchQuery = query.trim().toLowerCase();

    // Debounce search to prevent UI freezing on typing
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilter();
    });
  }

  // FEATURE: Deep Search Implementation with DB Query
  Future<void> _applyFilter() async {
    if (_currentSearchQuery.isEmpty) {
      _filteredConversationIDs = List.from(_allConversationIDs);
    } else {
      // 1. First, get IDs of conversations where messages match (Deep Search)
      final List<String> deepSearchResults =
          await ChatStorageService.searchConversations(
              query: _currentSearchQuery);

      // 2. Filter in memory (Title matches or ID is in deep search results)
      _filteredConversationIDs = _allConversationIDs.where((id) {
        final manager = _conversationManagers[id];
        if (manager == null) return false;

        final matchesTitle = manager.conversationTitle
            .toLowerCase()
            .contains(_currentSearchQuery);
        final isDeepMatch = deepSearchResults.contains(id);

        return matchesTitle || isDeepMatch;
      }).toList();
    }
    notifyListeners();
  }

  void _sortConversations() {
    // Only sort the all list; filter is derived from it.
    _allConversationIDs.sort((a, b) {
      final managerA = _conversationManagers[a];
      final managerB = _conversationManagers[b];
      if (managerA == null || managerB == null) return 0;

      // 1. Pinned items go to top
      if (managerA.isStarred != managerB.isStarred) {
        return managerA.isStarred ? -1 : 1;
      }

      // 1.1 If both are starred, sort by 'Recently Starred' (Newest Starred First)
      if (managerA.isStarred && managerB.isStarred) {
        final dateA = managerA.starredDate ?? DateTime(0);
        final dateB = managerB.starredDate ?? DateTime(0);
        // Compare dateB to dateA for descending (newest first)
        final comparison = dateB.compareTo(dateA);
        if (comparison != 0) return comparison;
      }

      // 2. Then sort by Date (Newest first)
      return managerB.lastMessageDate.compareTo(managerA.lastMessageDate);
    });

    // Re-apply filter immediately to reflect sort order changes
    if (_currentSearchQuery.isEmpty) {
      _filteredConversationIDs = List.from(_allConversationIDs);
      notifyListeners();
    } else {
      // If searching, no need to re-query DB, just re-filter in memory logic if needed
      // but easiest is to just let the existing filtered list stay or re-run filter.
      // For simplicity, we just notify unless we want real-time sort during search.
      _applyFilter();
    }
  }

  void _loadFromCache() {
    final cachedManagers = CacheService.get<Map<String, ConversationManager>>(
        CacheKey.conversationManagers);
    final cachedOrder =
        CacheService.get<List<String>>(CacheKey.conversationOrder);

    if (cachedManagers != null && cachedOrder != null) {
      _conversationManagers.addAll(cachedManagers);
      _allConversationIDs = cachedOrder;
      // Initialize filtered list with all
      _filteredConversationIDs = List.from(_allConversationIDs);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshIfNeeded() async {
    await loadConversations(langCode: _currentLangCode, isReload: true);
  }

  void _listenForLastMessageUpdates() {
    _titleSubscription?.cancel();
    _titleSubscription = ChatStorageService.titleStream.listen((update) async {
      final String convId = update["id"] as String;
      final String newTitle = update["title"] as String;
      final manager = _conversationManagers[convId];
      if (manager != null) {
        manager.updateConversationTitle(newTitle);
        // Force refresh the list view just in case the tile rebuilds based on it
        notifyListeners();
        _updateConversationCache();
      }
    });

    _lastMessageSubscription?.cancel();
    _lastMessageSubscription =
        ChatStorageService.lastMsgStream.listen((update) async {
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

  Future<void> loadConversations(
      {required String langCode, bool isReload = false}) async {
    if (_conversationManagers.isEmpty || isReload) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _modelService.getModels(langCode: langCode);

      // OPTIMIZED: Fetch everything in one go (No N+1)
      final rows = await ChatStorageService.getConversationsWithLastMessage();

      // Use a temporary map to avoid flickering if possible, but for now clear is safe
      // because we set isLoading=true.
      _conversationManagers.clear();
      // Use Set to prevent duplicates
      final Set<String> uniqueIds = {};

      for (final row in rows) {
        final convID = row['id'] as String;

        // Safety check if DB returns duplicates (unlikely with primary key but good practice)
        if (uniqueIds.contains(convID)) continue;

        uniqueIds.add(convID);
        final modelId = row['modelId'] as String? ?? '';

        // Extract last message data from the joined query
        final String? lastMsgText = row['lastMessageText'] as String?;
        final String? lastMsgPhoto = row['lastMessagePhoto'] as String?;
        final int? realLastMsgTs = row['realLastMessageTs'] as int?;

        final manager = ConversationManager(
          conversationID: convID,
          conversationTitle: row['title'] as String? ?? 'Untitled',
          initialModelId: modelId,
          persistedModelTitle: row['modelTitle'] as String?,
          persistedModelImagePath: row['modelImagePath'] as String?,
          isStarred: (row['isStarred'] as int? ?? 0) == 1,
          starredDate: row['starredDate'] != null &&
                  (row['starredDate'] as int) > 0
              ? DateTime.fromMillisecondsSinceEpoch(row['starredDate'] as int)
              : null,
          lastMessageDate: realLastMsgTs != null
              ? DateTime.fromMillisecondsSinceEpoch(realLastMsgTs)
              : DateTime.fromMillisecondsSinceEpoch(
                  row['lastMessageDate'] as int? ?? 0),
          langCode: langCode,
          modelService: _modelService,
        );

        // Pre-populate the manager with the last message snippet so it doesn't have to fetch it
        if (lastMsgText != null || lastMsgPhoto != null) {
          manager.updateLastMessage(lastMsgText ?? '', lastMsgPhoto ?? '',
              DateTime.fromMillisecondsSinceEpoch(realLastMsgTs ?? 0));
        }

        _conversationManagers[convID] = manager;

        final persistedTitle = (row['modelTitle'] as String?)?.trim() ?? '';
        final persistedImage = (row['modelImagePath'] as String?)?.trim() ?? '';
        if (persistedTitle.isEmpty || persistedImage.isEmpty) {
          await ChatStorageService.updateConversationModelSnapshot(
            convID,
            modelTitle: manager.modelTitle,
            modelImagePath: manager.modelImagePath,
          );
        }
      }

      _allConversationIDs = uniqueIds.toList();

      _sortConversations();
    } catch (e) {
      debugPrint("Error loading conversations: $e");
    } finally {
      // Logic Update: Ensure we don't flash empty state if we have items
      _isLoading = false;
      notifyListeners();
      _updateConversationCache();
    }
  }

  Future<void> deleteConversation(String conversationID) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    // 1. PROTECTION CHECK: Active conversation check
    final BuildContext? context = mainScreenKey.currentContext;
    if (context != null) {
      final activeId = Provider.of<ConversationProvider>(context, listen: false)
          .conversationID;

      if (activeId == conversationID) {
        debugPrint(
            "[InboxViewModel] Active conversation deleted. Triggering reset.");
        mainScreenKey.currentState?.startNewConversation(closeSidebar: false);
      }
    }

    // 2. Remove from internal lists IMMEDIATELY (Animation handled by Tile)
    _conversationManagers.remove(conversationID);
    _allConversationIDs.remove(conversationID);
    _filteredConversationIDs.remove(conversationID);

    // Notify to update UI
    notifyListeners();

    // 3. Dispose and delete from DB
    manager.dispose();
    await ChatStorageService.deleteConversation(conversationID);
    _updateConversationCache();
  }

  Future<void> editConversation(String conversationID, String newTitle) async {
    final manager = _conversationManagers[conversationID];
    final context = mainScreenKey.currentContext;
    final l10n = context != null ? AppLocalizations.of(context) : null;

    if (manager == null) return;

    await ChatStorageService.renameConversation(conversationID, newTitle);
    manager.updateConversationTitle(newTitle);

    final message = l10n?.renamed ?? "Renamed";

    _notificationService.showNotification(
        message: message, type: NotificationType.success);
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
    CacheService.set(
        CacheKey.conversationManagers, Map.of(_conversationManagers));
    CacheService.set(CacheKey.conversationOrder, List.of(_allConversationIDs));
  }
}

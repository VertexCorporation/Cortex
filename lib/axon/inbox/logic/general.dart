// lib/axon/inbox/logic/general.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../cache.dart';
import 'package:cortex/axon/inbox/logic/search_hit.dart';
import '../../../chat/providers/conversation.dart';

import '../../../chat/services/storage.dart';
import '../../../l10n/app_localizations.dart';
import '../../../library/backend/data/service.dart';
import '../../../main.dart';
import '../../../notifications/introvert.dart';
import '../../../arts/provider.dart';
import 'manager.dart';

class InboxViewModel extends ChangeNotifier {
  final ModelService _modelService;
  final IntrovertNotificationService _notificationService;

  final Map<String, ConversationManager> _conversationManagers = {};
  List<String> _allConversationIDs = [];
  List<String> _filteredConversationIDs = [];
  List<SearchHit> searchHits = []; // [NEW] Advanced search hits

  bool _isLoading = true;
  String _currentSearchQuery = "";
  StreamSubscription<Map<String, dynamic>>? _lastMessageSubscription;
  StreamSubscription<Map<String, String>>? _titleSubscription;
  StreamSubscription<void>? _conversationResetSubscription;
  String _currentLangCode = 'en';
  Timer? _searchDebounce;

  // Selection Mode Features
  bool _isSelectionMode = false;
  final Set<String> _selectedIDs = {};

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedIDs => _selectedIDs;

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIDs.clear();
    }
    notifyListeners();
  }

  void setSelectionMode(bool value) {
    if (_isSelectionMode == value) return;
    _isSelectionMode = value;
    if (!_isSelectionMode) {
      _selectedIDs.clear();
    }
    notifyListeners();
  }

  void toggleSelectConversation(String id) {
    if (_selectedIDs.contains(id)) {
      _selectedIDs.remove(id);
    } else {
      _selectedIDs.add(id);
    }
    notifyListeners();
  }

  void selectAllConversations() {
    _selectedIDs.addAll(_filteredConversationIDs);
    notifyListeners();
  }

  void clearSelection() {
    _selectedIDs.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedConversations() async {
    if (_selectedIDs.isEmpty) return;

    final idsToDelete = List<String>.from(_selectedIDs);

    _isSelectionMode = false;
    _selectedIDs.clear();
    notifyListeners();

    final BuildContext? context = mainScreenKey.currentContext;
    String? activeId;
    if (context != null) {
      activeId = Provider.of<ConversationProvider>(context, listen: false)
          .conversationID;
    }

    bool activeDeleted = false;

    for (final id in idsToDelete) {
      final manager = _conversationManagers[id];
      if (manager == null) continue;

      if (activeId == id) {
        activeDeleted = true;
      }

      _allConversationIDs.remove(id);
      _filteredConversationIDs.remove(id);
      manager.setDeleted(true);
    }

    notifyListeners();

    if (activeDeleted) {
      mainScreenKey.currentState?.startNewConversation(closeSidebar: false);
    }

    await Future.delayed(const Duration(milliseconds: 350));

    for (final id in idsToDelete) {
      final manager = _conversationManagers.remove(id);
      manager?.dispose();
      _cleanupMediaFiles(id);
      await ChatStorageService.deleteConversation(id);
    }

    _updateConversationCache();

    try {
      final ctx = mainScreenKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Provider.of<ArtsProvider>(ctx, listen: false).refresh();
      }
    } catch (e) {
      debugPrint('[InboxViewModel] Arts refresh after bulk delete failed: $e');
    }

    notifyListeners();
  }

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
    _conversationResetSubscription?.cancel();
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
      searchHits = [];
    } else {
      // For short queries, we still only filter titles to avoid DB spam
      if (_currentSearchQuery.length >= 2) {
        searchHits =
            await ChatStorageService.searchMessagesDeep(_currentSearchQuery);
      } else {
        searchHits = [];
      }

      // We also keep the title match functionality for the normal filtered list
      _filteredConversationIDs = _allConversationIDs.where((id) {
        final manager = _conversationManagers[id];
        if (manager == null) return false;

        return manager.conversationTitle
            .toLowerCase()
            .contains(_currentSearchQuery);
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
      debugPrint(
          "[AxonRename.Stream] title update received id=$convId hasManager=${manager != null} title='$newTitle'");
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

    _conversationResetSubscription?.cancel();
    _conversationResetSubscription =
        ChatStorageService.conversationResetStream.listen((_) {
      _clearConversationsAfterStorageReset();
    });
  }

  void _clearConversationsAfterStorageReset() {
    for (final manager in _conversationManagers.values) {
      manager.dispose();
    }

    _conversationManagers.clear();
    _allConversationIDs = [];
    _filteredConversationIDs = [];
    _isLoading = false;
    _currentSearchQuery = '';

    final context = mainScreenKey.currentContext;
    if (context != null) {
      Provider.of<ConversationProvider>(context, listen: false)
          .clearConversation();
    }

    CacheService.invalidateConversationCache();
    _updateConversationCache();
    notifyListeners();
  }

  Future<void> loadConversations(
      {required String langCode, bool isReload = false}) async {
    // PERF FIX: Only show skeleton loading if we truly have nothing to display.
    // If cache already populated the list, skip the skeleton entirely — users
    // see real data while we silently refresh from DB in the background.
    if (_conversationManagers.isEmpty && !isReload) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _modelService.getModels(langCode: langCode);

      // OPTIMIZED: Fetch everything in one go (No N+1)
      final rows = await ChatStorageService.getConversationsWithLastMessage();

      // PERF FIX: Incremental update instead of clear+rebuild.
      // Build a fresh set from DB, then reconcile with existing managers
      // to avoid destroying and recreating identical objects (prevents flicker).
      final Set<String> freshIds = {};
      final List<_SnapshotUpdate> pendingSnapshotUpdates = [];

      for (final row in rows) {
        final convID = row['id'] as String;

        // Safety check if DB returns duplicates (unlikely with primary key but good practice)
        if (freshIds.contains(convID)) continue;

        freshIds.add(convID);

        // If manager already exists, update it in place instead of recreating
        if (_conversationManagers.containsKey(convID)) {
          continue;
        }

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

        // PERF FIX: Collect snapshot updates instead of awaiting each one (N+1 → batch)
        final persistedTitle = (row['modelTitle'] as String?)?.trim() ?? '';
        final persistedImage = (row['modelImagePath'] as String?)?.trim() ?? '';
        if (persistedTitle.isEmpty || persistedImage.isEmpty) {
          pendingSnapshotUpdates.add(_SnapshotUpdate(
            convID: convID,
            modelTitle: manager.modelTitle,
            modelImagePath: manager.modelImagePath,
          ));
        }
      }

      // Remove managers for conversations that no longer exist in DB
      final staleIds = _conversationManagers.keys
          .where((id) => !freshIds.contains(id))
          .toList();
      for (final staleId in staleIds) {
        _conversationManagers[staleId]?.dispose();
        _conversationManagers.remove(staleId);
      }

      _allConversationIDs = freshIds.toList();

      _sortConversations();

      // PERF FIX: Fire-and-forget snapshot updates in background (non-blocking)
      if (pendingSnapshotUpdates.isNotEmpty) {
        Future.microtask(() async {
          for (final update in pendingSnapshotUpdates) {
            await ChatStorageService.updateConversationModelSnapshot(
              update.convID,
              modelTitle: update.modelTitle,
              modelImagePath: update.modelImagePath,
            );
          }
        });
      }
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
    _allConversationIDs.remove(conversationID);
    _filteredConversationIDs.remove(conversationID);

    // Mark as deleted so AnimatedList doesn't double-animate
    manager.setDeleted(true);

    // Notify to update UI
    notifyListeners();

    // 3. Give UI a moment to animate before deleting from memory and DB
    Future.delayed(const Duration(milliseconds: 350), () async {
      _conversationManagers.remove(conversationID);
      manager.dispose();

      // 3a. Clean up media files from disk (fire-and-forget)
      _cleanupMediaFiles(conversationID);

      await ChatStorageService.deleteConversation(conversationID);
      _updateConversationCache();

      // FIX: Refresh Arts gallery to remove media from deleted conversation
      try {
        final ctx = mainScreenKey.currentContext;
        if (ctx != null && ctx.mounted) {
          Provider.of<ArtsProvider>(ctx, listen: false).refresh();
        }
      } catch (e) {
        debugPrint('[InboxViewModel] Arts refresh after delete failed: $e');
      }
    });
  }

  /// Deletes all generated media files associated with a conversation from disk.
  void _cleanupMediaFiles(String conversationID) {
    Future.microtask(() async {
      try {
        final paths = await ChatStorageService.getMediaPathsForConversation(
            conversationID);
        for (final path in paths) {
          _deleteMediaPath(path);
        }
      } catch (e) {
        debugPrint('[InboxViewModel] Media cleanup error: $e');
      }
    });
  }

  /// Parses a media path (could be JSON array or single path) and deletes files.
  void _deleteMediaPath(String raw) {
    List<String> filePaths;
    try {
      final decoded = _tryJsonDecode(raw);
      if (decoded is List) {
        filePaths = decoded.cast<String>();
      } else {
        filePaths = [raw];
      }
    } catch (_) {
      filePaths = [raw];
    }

    for (final filePath in filePaths) {
      if (filePath.isEmpty) continue;
      if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
        continue;
      }
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('[InboxViewModel] Failed to delete file $filePath: $e');
      }
    }
  }

  static dynamic _tryJsonDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> editConversation(String conversationID, String newTitle) async {
    final trimmedTitle = newTitle.trim();
    debugPrint(
        "[AxonRename] requested id=$conversationID title='$trimmedTitle'");

    final manager = _conversationManagers[conversationID];
    final context = mainScreenKey.currentContext;
    final l10n = context != null ? AppLocalizations.of(context) : null;

    if (trimmedTitle.isEmpty) {
      debugPrint("[AxonRename] rejected empty title for id=$conversationID");
      return;
    }

    if (manager == null) {
      debugPrint("[AxonRename] manager missing for id=$conversationID");
      return;
    }

    final persisted = await ChatStorageService.renameConversation(
      conversationID,
      trimmedTitle,
      source: 'axon_manual',
    );

    if (!persisted) {
      debugPrint("[AxonRename] persist failed for id=$conversationID");
      _notificationService.showNotification(
          message:
              l10n?.requestFailed ?? "An error occurred, please try again.",
          type: NotificationType.error);
      return;
    }

    manager.updateConversationTitle(trimmedTitle);

    if (context != null && context.mounted) {
      final conversationProvider =
          Provider.of<ConversationProvider>(context, listen: false);
      if (conversationProvider.conversationID == conversationID) {
        conversationProvider.updateConversationTitle(trimmedTitle);
        debugPrint("[AxonRename] active conversation title updated in memory.");
      }
    }

    if (_currentSearchQuery.isEmpty) {
      notifyListeners();
    } else {
      await _applyFilter();
    }

    _updateConversationCache();

    final message = l10n?.renamed ?? "Renamed";

    _notificationService.showNotification(
        message: message, type: NotificationType.success);
    debugPrint("[AxonRename] completed id=$conversationID");
  }

  Future<bool> togglePinStatus(String conversationID) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return false;

    final newStatus = !manager.isStarred;

    if (newStatus) {
      int pinnedCount =
          _conversationManagers.values.where((m) => m.isStarred).length;
      if (pinnedCount >= 3) {
        return false;
      }
    }

    manager.setStarred(newStatus);
    await ChatStorageService.setStarred(conversationID, newStatus);

    _sortConversations();
    _updateConversationCache();
    return true;
  }

  void _updateConversationCache() {
    CacheService.set(
        CacheKey.conversationManagers, Map.of(_conversationManagers));
    CacheService.set(CacheKey.conversationOrder, List.of(_allConversationIDs));
  }
}

/// Lightweight data class for batching model snapshot SQL writes.
class _SnapshotUpdate {
  final String convID;
  final String modelTitle;
  final String modelImagePath;

  const _SnapshotUpdate({
    required this.convID,
    required this.modelTitle,
    required this.modelImagePath,
  });
}

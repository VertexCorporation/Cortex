// lib/inbox/providers/general.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../cache.dart';
import '../../chat/services/database.dart';
import '../../chat/services/storage.dart';
import '../../library/backend/data/service.dart';
import '../../notifications/introvert.dart';
import '../manager.dart';

/// The ViewModel for the Inbox screen.
///
/// This class acts as the "brain" for the inbox UI (`InboxScreen`). It is responsible for:
///   1. Managing the state (e.g., loading status, list of conversations).
///   2. Containing all the business logic (loading, deleting, starring conversations).
///   3. Interacting with data sources (Cache, Database, Services).
///   4. Notifying the UI of any state changes via `ChangeNotifier`.
///
/// This approach separates the UI code from the logic, making both easier to test,
/// read, and maintain.
class InboxViewModel extends ChangeNotifier {
  final ModelService _modelService;
  final IntrovertNotificationService _notificationService;

  /// Private state variables. The UI should not modify these directly.
  final Map<String, ConversationManager> _conversationManagers = {};
  final List<Map<String, dynamic>> _userModels = [];
  List<String> _conversationIDsOrder = [];
  List<String> _starredConversationIDs = [];
  bool _isLoading = true;
  bool _isCurrentlyLoading = false;
  StreamSubscription<Map<String, dynamic>>? _lastMessageSubscription;

  // IDs currently being removed with an animation.
  final Set<String> _deletingConversationIDs = {};

  String _currentLangCode = 'en';

  /// Public getters to allow the UI to read the state.
  /// The UI will rebuild when `notifyListeners()` is called.
  bool get isLoading => _isLoading;
  List<String> get orderedConversationIDs => _conversationIDsOrder;
  List<String> get starredConversationIDs => _starredConversationIDs;
  Map<String, ConversationManager> get conversationManagers =>
      _conversationManagers;
  List<Map<String, dynamic>> get userModels => List.unmodifiable(_userModels);

  /// Expose deleting IDs to the UI layer for removal animations.
  Set<String> get deletingConversationIDs =>
      Set.unmodifiable(_deletingConversationIDs);

  /// Dependencies are injected via the constructor for better testability.
  InboxViewModel({
    required ModelService modelService,
    required IntrovertNotificationService notificationService,
  })  : _modelService = modelService,
        _notificationService = notificationService;

  /// Initializes the ViewModel.
  /// Should be called once after the ViewModel is created.
  /// It loads initial data from cache and then fetches fresh data.
  Future<void> initialize(String langCode) async {
    _currentLangCode = langCode;
    _loadFromCache();
    _listenForLastMessageUpdates();
    await loadConversations(langCode: langCode);
  }

  /// Cleans up resources when the ViewModel is no longer needed.
  @override
  void dispose() {
    _lastMessageSubscription?.cancel();
    // Dispose all individual managers to prevent memory leaks
    for (var manager in _conversationManagers.values) {
      manager.dispose();
    }
    super.dispose();
  }

  /// Loads conversation data from the local cache for a fast initial display.
  void _loadFromCache() {
    final cachedManagers =
    CacheService.get<Map<String, ConversationManager>>(
        CacheKey.conversationManagers);
    final cachedOrder =
    CacheService.get<List<String>>(CacheKey.conversationOrder);
    final cachedStarred =
    CacheService.get<List<String>>(CacheKey.starredIds);
    final cachedUserModels =
    CacheService.get<List<Map<String, dynamic>>>(CacheKey.userModels);

    if (cachedManagers != null && cachedOrder != null) {
      _conversationManagers.addAll(cachedManagers);
      _conversationIDsOrder.addAll(cachedOrder);
      _starredConversationIDs.addAll(cachedStarred ?? []);
      _userModels.addAll(cachedUserModels ?? []);
      _isLoading = false;
      debugPrint("[InboxViewModel] Initialized successfully from cache.");
      notifyListeners(); // Notify UI that cached data is ready
    }
  }


  /// Checks the global app data state and triggers a reload of conversations
  /// if anything in the chat layer has changed (new chat, deleted chat, rename, star, etc).
  Future<void> refreshIfNeeded() async {
    // AppDataState.needsRefresh returns true once and then resets the flag.
    if (AppDataState().needsRefresh) {
      await loadConversations(
        langCode: _currentLangCode,
        isReload: true,
      );
    }
  }

  /// Listens to a global stream for real-time updates to the last message of any conversation.
  void _listenForLastMessageUpdates() {
    _lastMessageSubscription?.cancel();
    _lastMessageSubscription =
        ChatStorageService.lastMsgStream.listen((update) async {
          final String convId = update['convId'] as String;
          final manager = _conversationManagers[convId];

          // Trigger a soft reload so it appears instantly in the inbox.
          if (manager == null) {
            debugPrint(
              "[InboxViewModel] Detected new conversation '$convId' from lastMsgStream. Reloading conversations.",
            );
            await loadConversations(
              langCode: _currentLangCode,
              isReload: true,
            );
            return;
          }

          manager.updateLastMessage(
            update['text'] as String? ?? '',
            update['photoPath'] as String? ?? '',
            DateTime.fromMillisecondsSinceEpoch(update['ts'] as int),
          );

          _conversationIDsOrder.sort((a, b) {
            final dateA = _conversationManagers[a]!.lastMessageDate;
            final dateB = _conversationManagers[b]!.lastMessageDate;
            return dateB.compareTo(dateA);
          });

          notifyListeners();
        });
  }


  /// Fetches all conversations from the database, filters them, and updates the state.
  Future<void> loadConversations({
    required String langCode,
    bool isReload = false,
  }) async {
    if (_isCurrentlyLoading) return;
    _isCurrentlyLoading = true;

    // Reset any stale "deleting" state when doing a fresh load.
    _deletingConversationIDs.clear();

    if (_conversationManagers.isEmpty || isReload) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _modelService.getModels(langCode: langCode);
      final allUserVisibleModels = _modelService.getCachedModelsSync();
      final userVisibleModelIds = allUserVisibleModels
          .expand((model) => {model.id, ...?model.extensions?.keys})
          .toSet();

      final db = await DbHelper().db;
      final rows = await db.query(
        'conversations',
        orderBy: 'lastMessageDate DESC',
      );

      final newOrder = <String>[];
      final newStarred = <String>[];
      final Set<String> currentVisibleDbIds = {};

      for (final row in rows) {
        final modelId = row['modelId'] as String? ?? '';
        final convID = row['id'] as String;

        // Security gate: only show conversations whose models are visible to the user.
        if (userVisibleModelIds.contains(modelId) || modelId == 'dynamic') {
          currentVisibleDbIds.add(convID);
          final manager = await _updateOrCreateManager(
            row,
            convID,
            modelId,
            langCode,
          );
          _conversationManagers[convID] = manager;

          newOrder.add(convID);
          if (manager.isStarred) {
            newStarred.add(convID);
          }
        }
      }

      // Remove managers for conversations that are no longer visible.
      _conversationManagers.removeWhere((id, manager) {
        final shouldRemove = !currentVisibleDbIds.contains(id);
        if (shouldRemove) {
          manager.dispose(); // Clean up the manager before removing
        }
        return shouldRemove;
      });

      _conversationIDsOrder = newOrder;
      _starredConversationIDs = newStarred;
    } catch (e, stackTrace) {
      debugPrint(
        "FATAL: Could not load conversations. Error: $e\nStack trace: $stackTrace",
      );
    } finally {
      _isLoading = false;
      _isCurrentlyLoading = false;
      notifyListeners();
      _updateConversationCache();
    }
  }

  /// Helper method to either create a new ConversationManager or update an existing one.
  Future<ConversationManager> _updateOrCreateManager(
      Map<String, Object?> row,
      String convID,
      String modelId,
      String langCode,
      ) async {
    if (_conversationManagers.containsKey(convID)) {
      final manager = _conversationManagers[convID]!;
      manager.updateConversationTitle(row['title'] as String? ?? 'No Title');
      manager.setStarred((row['isStarred'] as int? ?? 0) == 1);
      await manager.checkForModelUpdate(langCode: langCode);
      return manager;
    } else {
      final lastMsg = await ChatStorageService.getLastMessage(convID);
      return ConversationManager(
        conversationID: convID,
        conversationTitle: row['title'] as String? ?? 'No Title',
        initialModelId: modelId,
        isStarred: (row['isStarred'] as int? ?? 0) == 1,
        lastMessageDate: lastMsg?['ts'] != null
            ? DateTime.fromMillisecondsSinceEpoch(lastMsg!['ts'] as int)
            : DateTime.fromMillisecondsSinceEpoch(
          row['lastMessageDate'] as int? ?? 0,
        ),
        lastMessageText: lastMsg?['text'] as String? ?? '',
        lastMessagePhotoPath: lastMsg?['photoPath'] as String? ?? '',
        langCode: langCode,
        modelService: _modelService,
      );
    }
  }

  /// Handles the logic for deleting a conversation **with animation support**.
  ///
  /// The flow:
  /// 1. Mark the conversation ID as "deleting" so the UI can animate it out.
  /// 2. Wait for the animation duration.
  /// 3. Remove it from in-memory state and notify listeners.
  /// 4. Perform background cleanup (DB + cache + dispose).
  Future<void> deleteConversation(
      String conversationID,
      String successMessage,
      ) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    // Show success notification immediately for responsive UX.
    _notificationService.showNotification(
      message: successMessage,
      type: NotificationType.success,
    );

    // Mark this ID as being deleted so the list can play a shrink/fade animation.
    _deletingConversationIDs.add(conversationID);
    notifyListeners();

    // Give the UI time to animate the removal.
    await Future.delayed(const Duration(milliseconds: 300));

    // If a reload happened in between, we might already be in a different state.
    if (!_conversationManagers.containsKey(conversationID)) {
      _deletingConversationIDs.remove(conversationID);
      notifyListeners();
      return;
    }

    // Remove from state.
    _conversationManagers.remove(conversationID);
    _conversationIDsOrder.remove(conversationID);
    _starredConversationIDs.remove(conversationID);
    _deletingConversationIDs.remove(conversationID);
    notifyListeners();

    // Background cleanup.
    manager.dispose();
    await ChatStorageService.deleteConversation(conversationID);
    _updateConversationCache();
  }

  /// Handles the logic for renaming a conversation.
  Future<void> editConversation(
      String conversationID,
      String newTitle,
      String successMessage,
      ) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    await ChatStorageService.renameConversation(conversationID, newTitle);

    // The manager will notify the ConversationTile of the title change directly.
    manager.updateConversationTitle(newTitle);

    _notificationService.showNotification(
      message: successMessage,
      type: NotificationType.success,
    );
  }

  /// Toggles the starred status of a conversation.
  Future<void> toggleStarStatus(String conversationID) async {
    final manager = _conversationManagers[conversationID];
    if (manager == null) return;

    final newStarredStatus = !manager.isStarred;
    manager.setStarred(newStarredStatus);
    await ChatStorageService.setStarred(conversationID, newStarredStatus);

    if (!newStarredStatus) {
      _deletingConversationIDs.add(conversationID);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      _deletingConversationIDs.remove(conversationID);
    }

    _starredConversationIDs = _conversationIDsOrder
        .where((id) => _conversationManagers[id]?.isStarred == true)
        .toList();

    notifyListeners();
    _updateConversationCache();
  }

  /// Updates the local cache with the current state of conversations.
  void _updateConversationCache() {
    CacheService.set(
      CacheKey.conversationManagers,
      Map.of(_conversationManagers),
    );
    CacheService.set(
      CacheKey.conversationOrder,
      List.of(_conversationIDsOrder),
    );
    CacheService.set(
      CacheKey.starredIds,
      List.of(_starredConversationIDs),
    );
    CacheService.set(
      CacheKey.userModels,
      List.of(_userModels),
    );
    debugPrint("[InboxViewModel] Conversation cache updated.");
  }
}
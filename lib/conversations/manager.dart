import 'dart:async';
import 'package:cortex/models/backend/data.dart';
import 'package:flutter/foundation.dart';
import '../chat/services/storage.dart';
import '../chat/services/database.dart';

class ConversationManager extends ChangeNotifier {
  final String conversationID;
  String conversationTitle;
  bool isStarred;
  bool isDeleted = false;

  late Map<String, dynamic> _modelData;

  String get modelId => _modelData['id'] as String? ?? '';
  String get modelTitle {
    // If it's a dynamic chat, the title is handled by the UI layer.
    // The manager itself doesn't know the localized text.
    if (_modelData['id'] == 'dynamic') {
      // We can return the hardcoded English text as a last-resort fallback.
      return _modelData['title'] as String? ?? 'Dynamic Chat';
    }
    // For all other models, return their actual title.
    return _modelData['title'] as String? ?? 'Unknown Model';
  }
  String get modelImagePath => _modelData['imagePath'] as String? ?? 'assets/icons/self.svg';
  String get modelDescription => _modelData['description'] as String? ?? '';
  String get modelProducer => _modelData['producer'] as String? ?? 'Unknown';
  bool get canHandleImage => _modelData['canHandleImage'] as bool? ?? false;
  String? get role => _modelData['role'] as String?;
  String? get modelPath => _modelData['path'] as String?;
  String? get modelCategory => _modelData['category'] as String?;
  bool get isServerSide => (_modelData['type'] as String? ?? 'online') != 'offline';

  DateTime _lastMessageDate;
  String _lastMessageText;
  String _lastMessagePhotoPath;

  late final StreamSubscription<Map<String, dynamic>> _sub;

  ConversationManager({
    required this.conversationID,
    required this.conversationTitle,
    required String initialModelId,
    required this.isStarred,
    required DateTime lastMessageDate,
    String lastMessageText = '',
    String lastMessagePhotoPath = '',
  })  : _lastMessageText = lastMessageText,
        _lastMessageDate = lastMessageDate,
        _lastMessagePhotoPath = lastMessagePhotoPath {

    // --- DYNAMIC CHAT IDENTIFICATION LOGIC ---
    // If the ID from the database is 'dynamic', we create a special
    // placeholder model data map for it. This ensures it has a consistent
    // and recognizable appearance in the inbox.
    if (initialModelId == 'dynamic') {
      _modelData = {
        'id': 'dynamic',
        'title': 'Dynamic Chat',
        'imagePath': 'assets/cortex.svg', // Special icon for dynamic chats
        'producer': 'Cortex',
        'canHandleImage': true, // Assume capable for UI purposes
        'type': 'online',
        'category': 'dynamic',
      };
    } else {
      // For any other ID, use the standard method to get real model data.
      _modelData = ModelData.getPreciseModelData(initialModelId);
    }

    _sub = ChatStorageService.lastMsgStream
        .where((e) => e['convId'] == conversationID)
        .listen((e) async {
      _lastMessageText = e['text'] as String;
      _lastMessageDate = DateTime.fromMillisecondsSinceEpoch(e['ts'] as int);

      final bool modelChanged = await checkForModelUpdate();

      if (modelChanged || e.containsKey('text')) {
        notifyListeners();
      }
    });
  }

  DateTime get lastMessageDate => _lastMessageDate;
  String get lastMessageText => _lastMessageText;
  String get lastMessagePhotoPath => _lastMessagePhotoPath;

  Future<bool> checkForModelUpdate() async {
    try {
      final db = await DbHelper().db;
      final List<Map<String, dynamic>> result = await db.query(
        'conversations',
        columns: ['modelId'],
        where: 'id = ?',
        whereArgs: [conversationID],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final latestModelId = result.first['modelId'] as String?;
        if (latestModelId != null && latestModelId != this.modelId) {
          debugPrint("[ConversationManager] Model ID for '$conversationID' changed from '${this.modelId}' to '$latestModelId'. Refreshing details.");
          _modelData = ModelData.getPreciseModelData(latestModelId);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("[ConversationManager] Error checking for model update: $e");
    }
    return false;
  }

  Future<void> updateLastMessageTextOnly() async {
    final lastMsg = await ChatStorageService.getLastMessage(conversationID);
    bool needsNotify = false;

    final newText = lastMsg?['text'] as String? ?? '';
    if (_lastMessageText != newText) {
      _lastMessageText = newText;
      needsNotify = true;
    }

    final newPhotoPath = lastMsg?['photoPath'] as String? ?? '';
    if (_lastMessagePhotoPath != newPhotoPath) {
      _lastMessagePhotoPath = newPhotoPath;
      needsNotify = true;
    }

    final bool modelChanged = await checkForModelUpdate();
    if (needsNotify || modelChanged) {
      notifyListeners();
    }
  }

  void updateConversationTitle(String newTitle) {
    if (conversationTitle != newTitle) {
      conversationTitle = newTitle;
      notifyListeners();
    }
  }

  void setStarred(bool val) {
    if (isStarred != val) {
      isStarred = val;
      notifyListeners();
    }
  }

  /// Updates the last message date.
  /// This is used by the inbox to trigger re-sorting without a full reload.
  void updateLastMessageDate(DateTime newDate) {
    if (_lastMessageDate != newDate) {
      _lastMessageDate = newDate;
    }
  }

  void setDeleted(bool val) {
    isDeleted = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
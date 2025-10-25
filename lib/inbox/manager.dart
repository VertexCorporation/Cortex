// lib/conversations/manager.dart

import 'dart:async';
import 'package:cortex/models/backend/data/data.dart';
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
    // This logic ensures that even if a model is not immediately available in the cache,
    // we still have valid fallback data, and we correctly handle the special 'dynamic' case.

    if (initialModelId == 'dynamic') {
      // Case 1: The conversation is a "Dynamic Chat".
      // We create a special placeholder map for its UI representation.
      _modelData = {
        'id': 'dynamic',
        'title': 'Dynamic Chat', // This can be localized in the UI layer later
        'imagePath': 'assets/cortex.svg',
        'producer': 'Cortex',
        'canHandleImage': true,
        'type': 'online',
        'category': 'dynamic',
      };
    } else {
      // Case 2: It's a standard model conversation.
      // We fetch the data using the reliable static method.
      final data = ModelData.getPreciseModelData(initialModelId);

      // If, for some reason (e.g., race condition at startup), the model data is not found,
      // we create a fallback map to prevent crashes and show "Unknown Model".
      if (data.isEmpty) {
        _modelData = {
          'id': initialModelId,
          'title': 'Unknown Model',
          'imagePath': 'assets/icons/self.svg', // A safe default icon
        };
        debugPrint(
            "Warning: Could not find precise data for model '$initialModelId' during ConversationManager init. Using fallback.");
      } else {
        _modelData = data;
      }
    }
  }

  DateTime get lastMessageDate => _lastMessageDate;
  String get lastMessageText => _lastMessageText;
  String get lastMessagePhotoPath => _lastMessagePhotoPath;

  static Future<ConversationManager?> fromId(String conversationId) async {
    try {
      final db = await DbHelper().db;

      // 1. Fetch the main conversation data.
      final List<Map<String, dynamic>> convData = await db.query(
        'conversations',
        where: 'id = ?',
        whereArgs: [conversationId],
        limit: 1,
      );

      if (convData.isEmpty) {
        debugPrint("[ConversationManager] No conversation found in DB for ID: $conversationId");
        return null;
      }
      final convRow = convData.first;

      // 2. Fetch the last message data to initialize the manager.
      final lastMsg = await ChatStorageService.getLastMessage(conversationId);

      // 3. Create and return the new instance using the default constructor.
      return ConversationManager(
        conversationID: conversationId,
        conversationTitle: convRow['title'] as String? ?? 'Untitled',
        initialModelId: convRow['modelId'] as String? ?? '',
        isStarred: (convRow['isStarred'] as int? ?? 0) == 1,
        lastMessageDate: lastMsg?['ts'] != null
            ? DateTime.fromMillisecondsSinceEpoch(lastMsg!['ts'] as int)
            : DateTime.fromMillisecondsSinceEpoch(convRow['lastMessageDate'] as int? ?? 0),
        lastMessageText: lastMsg?['text'] as String? ?? '',
        lastMessagePhotoPath: lastMsg?['photoPath'] as String? ?? '',
      );
    } catch (e) {
      debugPrint("[ConversationManager] Error creating instance from ID '$conversationId': $e");
      return null;
    }
  }


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
        if (latestModelId != null && latestModelId != modelId) {
          debugPrint("[ConversationManager] Model ID for '$conversationID' changed from '$modelId' to '$latestModelId'. Refreshing details.");
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

  /// Updates the last message details from an external source (like a stream).
  /// Notifies listeners only if there's an actual change.
  void updateLastMessage(String newText, String newPhotoPath, DateTime newDate) {
    bool needsNotify = false;
    if (_lastMessageText != newText) {
      _lastMessageText = newText;
      needsNotify = true;
    }
    if (_lastMessagePhotoPath != newPhotoPath) {
      _lastMessagePhotoPath = newPhotoPath;
      needsNotify = true;
    }
    if (_lastMessageDate != newDate) {
      _lastMessageDate = newDate;
      needsNotify = true;
    }

    if (needsNotify) {
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
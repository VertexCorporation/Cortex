// lib/conversations/manager.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../chat/services/storage.dart';
import '../chat/services/database.dart';
import '../library/backend/data/entity.dart';
import '../library/backend/data/service.dart';

class ConversationManager extends ChangeNotifier {
  final String conversationID;
  String conversationTitle;
  bool isStarred;
  bool isDeleted = false;
  late ModelEntity _model;
  final ModelService _modelService;
  ModelEntity get model => _model; // Public getter for the UI
  String get modelId => _model.id;
  String get modelTitle => _model.displayTitle;
  String get modelImagePath => _modelService.getModelImagePath(_model);
  String get modelDescription => _model.displayDescription;
  String get modelProducer => _model.producer;
  bool get canHandleImage => _model.modalities['image'] == true;
  String? get role => _model.role;
  String? get modelPath => null; // This info is not in ModelEntity
  String get modelCategory => _model.category;
  bool get isServerSide => _model.isServerSide;

  DateTime _lastMessageDate;
  String _lastMessageText;
  String _lastMessagePhotoPath;

  ConversationManager({
    required this.conversationID,
    required this.conversationTitle,
    required String initialModelId,
    required this.isStarred,
    required DateTime lastMessageDate,
    required String langCode,
    String lastMessageText = '',
    String lastMessagePhotoPath = '',
    required ModelService modelService,
  })  : _lastMessageText = lastMessageText,
        _lastMessageDate = lastMessageDate,
        _lastMessagePhotoPath = lastMessagePhotoPath,
        _modelService = modelService {

    if (initialModelId == 'dynamic') {
      _model = ModelEntity.fromMap({
        'id': 'dynamic',
        'title': 'Dynamic Chat',
        'imagePath': 'assets/cortex.svg',
        'producer': 'Cortex',
        'modalities': {'image': true},
        'type': 'online',
        'category': 'dynamic',
      }, langCode);
    } else {
      // getPreciseModelData now requires langCode and always returns a valid entity.
      _model = _modelService.getPreciseModelData(initialModelId, langCode: langCode);
    }
  }

  DateTime get lastMessageDate => _lastMessageDate;
  String get lastMessageText => _lastMessageText;
  String get lastMessagePhotoPath => _lastMessagePhotoPath;

  static Future<ConversationManager?> fromId(String conversationId, {required String langCode, required ModelService modelService, }) async {
    try {
      final db = await DbHelper().db;
      final List<Map<String, dynamic>> convData = await db.query(
          'conversations', where: 'id = ?', whereArgs: [conversationId], limit: 1);

      if (convData.isEmpty) return null;
      final convRow = convData.first;

      final lastMsg = await ChatStorageService.getLastMessage(conversationId);

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
        langCode: langCode,
        modelService: modelService,
      );
    } catch (e) {
      debugPrint("[ConversationManager] Error creating instance from ID '$conversationId': $e");
      return null;
    }
  }

  Future<bool> checkForModelUpdate({required String langCode}) async {
    try {
      final db = await DbHelper().db;
      final List<Map<String, dynamic>> result = await db.query(
          'conversations', columns: ['modelId'], where: 'id = ?', whereArgs: [conversationID], limit: 1);

      if (result.isNotEmpty) {
        final latestModelId = result.first['modelId'] as String?;
        if (latestModelId != null && latestModelId != modelId) {
          _model = _modelService.getPreciseModelData(latestModelId, langCode: langCode);
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
}
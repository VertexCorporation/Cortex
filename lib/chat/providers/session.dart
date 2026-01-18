// lib/chat/providers/session.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
import '../services/storage.dart';

class ChatSessionProvider with ChangeNotifier {
  // ===========================================================================
  // SECTION 1: PRIVATE STATE VARIABLES
  // ===========================================================================

  final ModelService _modelService;
  ModelLocalStateProvider? _localStateProvider;

  // -------------------- Session State --------------------
  bool _isFluxMode = false;

  bool _isExitingChat = false;
  ModelEntity? _lastExitedModel;

  // -------------------- Model List State --------------------
  ModelEntity? _selectedModel;

  // -------------------- User & Subscription State --------------------
  bool _isUserSubscribed = false;
  int _premiumTrialUses = 0;
  ChatLimitManager? _chatLimitManager;
  String? _displayName;
  String? _email;
  Locale _currentLocale = const Locale('en');
  static const String _prefDefaultModelKey = 'cortex';

  // -------------------- Session-wide UI Flags --------------------
  bool _isStorageSufficient = true;

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================

  bool get isModelSelected => _selectedModel != null;

  bool get isDynamicChat =>
      _selectedModel == null || _selectedModel?.id == 'cortex/auto';

  bool get isExitingChat => _isExitingChat;

  List<ModelEntity> get allModels => _modelService.getCachedModelsSync();

  bool get areModelsLoading => _modelService.isLoading;

  bool get modelsLoadError => _modelService.hasError;

  String? get modelId => _selectedModel?.id ?? 'cortex/auto';

  String? get modelTitle {
    final currentModel = _isExitingChat ? _lastExitedModel : _selectedModel;

    if (currentModel == null) {
      return null;
    }

    final langCode = _currentLocale.languageCode;
    final baseId = _modelService.getBaseIdFromFullId(
        currentModel.id, langCode: langCode);

    if (baseId == currentModel.id) {
      return currentModel.displayTitle;
    }

    try {
      final seriesModel = _modelService.getPreciseModelData(
          baseId, langCode: langCode);
      return seriesModel.displayTitle;
    } catch (e) {
      return currentModel.displayTitle;
    }
  }

  String? get modelImagePath {
    final model = _isExitingChat ? _lastExitedModel : _selectedModel;
    return model?.imagePath;
  }

  String? get role => _selectedModel?.role;

  String? get modelPath {
    if (_selectedModel == null || _selectedModel!.isServerSide) {
      return null;
    }
    return _localStateProvider?.getFilePathById(_selectedModel!.id);
  }

  bool get canHandleImage => _selectedModel?.modalities['image'] == true;

  bool _isLocalModelLoaded = false;

  bool get isLocalModelLoaded => _isLocalModelLoaded;

  bool get isUserSubscribed => _isUserSubscribed;

  int get premiumTrialUses => _premiumTrialUses;

  ChatLimitManager? get chatLimitManager => _chatLimitManager;

  String? get displayName => _displayName;

  String? get email => _email;

  bool get isCurrentModelPremium {
    final model = _isExitingChat ? _lastExitedModel : _selectedModel;
    return model?.isPremium ?? false;
  }

  bool get isStorageSufficient => _isStorageSufficient;

  bool get isFluxMode => _isFluxMode;

  Locale getLocale() => _currentLocale;

  // ===========================================================================
  // SECTION 3: CONSTRUCTOR
  // ===========================================================================

  ChatSessionProvider({required ModelService modelService})
      : _modelService = modelService;

  // ===========================================================================
  // SECTION 4: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  void setFluxMode(bool value) {
    _isFluxMode = value;
    notifyListeners();
  }

  /// Selects a specific model entity for the session.
  /// [savePreference]: If true, remembers this model as the default for future new chats.
  void selectModel(ModelEntity entity, {bool savePreference = true}) {
    _isExitingChat = false;
    _selectedModel = entity;

    if (!entity.isServerSide) {
      _isLocalModelLoaded = false;
    }

    if (savePreference) {
      _savePreference(entity.id);
    }

    notifyListeners();
  }

  /// Initializes the session based on the user's last selected preference.
  /// This is called when the app starts or "New Chat" is clicked.
  Future<void> initializeDefaultSession() async {
    final prefs = await SharedPreferences.getInstance();
    String savedId = prefs.getString(_prefDefaultModelKey) ?? 'cortex/auto';

    if (savedId == 'dynamic') savedId = 'cortex/auto';

    final langCode = _currentLocale.languageCode;
    try {
      final entity = _modelService.getPreciseModelData(
          savedId, langCode: langCode);
      selectModel(entity, savePreference: false);
    } catch (e) {
      startDynamicConversation(savePreference: false);
    }
  }

  /// Sets up the session for Dynamic Chat (Implicitly cortex/auto).
  /// This effectively just sets selectedModel to null.
  void startDynamicConversation({bool savePreference = true}) {
    _isExitingChat = false;
    _selectedModel = null;
    _isLocalModelLoaded = false;

    if (savePreference) {
      _savePreference('cortex/auto');
    }

    notifyListeners();
  }

  /// Updates the variant of the currently active model.
  void updateActiveModelVariant(String newModelId,
      {bool savePreference = true}) {
    final langCode = _currentLocale.languageCode;
    _selectedModel =
        _modelService.getPreciseModelData(newModelId, langCode: langCode);

    if (savePreference) {
      _savePreference(newModelId);
    }

    notifyListeners();
  }

  Future<void> _savePreference(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefDefaultModelKey, value);
    } catch (e) {
      debugPrint("Failed to save model preference: $e");
    }
  }

  void configureForStandardChat({
    required ModelEntity model,
    required bool isPremium,
  }) {
    selectModel(model, savePreference: false);
  }

  /// Resets session flags (Flux etc) but DOES NOT close the chat view.
  /// Used when starting a new conversation to clear temporary states.
  void resetSessionState() {
    _lastExitedModel = _selectedModel;
    _isExitingChat = true;

    // Reset flags
    _isLocalModelLoaded = false;
    _isFluxMode = false;
    ChatStorageService.isFluxMode = false;

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_isExitingChat) {
        _isExitingChat = false;
        _lastExitedModel = null;
        notifyListeners();
      }
    });
  }

  void setDependencies(ModelLocalStateProvider localStateProvider) {
    _localStateProvider ??= localStateProvider;
  }

  void setLocalModelLoaded(bool isLoaded) {
    if (_isLocalModelLoaded != isLoaded) {
      _isLocalModelLoaded = isLoaded;
      notifyListeners();
    }
  }

  void updateUserData(Map<String, dynamic> data) {
    final int subscriptionLevel = data['hasCortexSubscription'] ?? 0;
    _isUserSubscribed = subscriptionLevel > 0;

    final dynamic lastResetValue = data['premiumModelTrialLastReset'];
    Timestamp? lastResetTimestamp;
    if (lastResetValue is Timestamp) {
      lastResetTimestamp = lastResetValue;
    } else if (lastResetValue is String) {
      final parsedDate = DateTime.tryParse(lastResetValue);
      if (parsedDate != null) {
        lastResetTimestamp = Timestamp.fromDate(parsedDate);
      }
    }

    int trialUses = data['premiumModelTrialUses'] as int? ?? 0;
    if (lastResetTimestamp != null) {
      final lastResetDate = lastResetTimestamp.toDate();
      final now = DateTime.now();
      if (lastResetDate.year != now.year || lastResetDate.month != now.month ||
          lastResetDate.day != now.day) {
        trialUses = 0;
      }
    }
    _premiumTrialUses = trialUses;

    _displayName =
        data['displayName'] as String? ?? data['username'] as String?;
    _email = data['email'] as String?;

    final dynamic expiresValue = data['subscriptionExpiresAt'];
    Timestamp? subscriptionExpiresAt;
    if (expiresValue is Timestamp) {
      subscriptionExpiresAt = expiresValue;
    } else if (expiresValue is String) {
      final parsedDate = DateTime.tryParse(expiresValue);
      if (parsedDate != null) {
        subscriptionExpiresAt = Timestamp.fromDate(parsedDate);
      }
    }

    _chatLimitManager = ChatLimitManager(
      cortexSubscription: subscriptionLevel,
      subscriptionExpiresAt: subscriptionExpiresAt,
    );

    notifyListeners();
  }

  void setStorageSufficient(bool isSufficient) {
    if (_isStorageSufficient != isSufficient) {
      _isStorageSufficient = isSufficient;
      notifyListeners();
    }
  }
}
// lib/chat/providers/session.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
import '../services/dynamic.dart';

enum AppBarMode {
  notSelected,
  inSelection,
  modelSelected,
  dynamicChat,
}

class ChatSessionProvider with ChangeNotifier {
  // ===========================================================================
  // SECTION 1: PRIVATE STATE VARIABLES
  // ===========================================================================

  final ModelService _modelService;
  ModelLocalStateProvider? _localStateProvider;

  // -------------------- Session & UI Mode State --------------------
  AppBarMode _appBarMode = AppBarMode.notSelected;
  bool _isModelSelected = false;
  bool _isPersistentlyDynamic = false;
  bool _isExitingChat = false;
  bool _wasDynamicOnExit = false;

  // -------------------- Model List State --------------------
  // --- All selected model data is now encapsulated in a single, nullable entity. ---
  ModelEntity? _selectedModel;
  ModelEntity? _lastExitedModel; // To preserve data during exit animations.

  // -------------------- User & Subscription State --------------------
  bool _isUserSubscribed = false;
  int _premiumTrialUses = 0;
  ChatLimitManager? _chatLimitManager;
  String? _displayName;
  String? _email;
  Locale _currentLocale = const Locale('en'); // Default to English.

  // -------------------- Session-wide UI Flags --------------------
  bool _showDisclaimer = false;
  bool _showPremiumBanner = false;
  bool _isStorageSufficient = true;
  static bool _hasDismissedDisclaimerThisSession = false;
  bool _hasDismissedPremiumBannerThisSession = false;

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================

  AppBarMode get appBarMode => _appBarMode;
  bool get isModelSelected => _isModelSelected;
  bool get isDynamicChat => _isPersistentlyDynamic;
  bool get isChatActive => _isModelSelected || _isPersistentlyDynamic;
  bool get isExitingChat => _isExitingChat;
  bool get wasDynamicOnExit => _wasDynamicOnExit;
  List<ModelEntity> get allModels => _modelService.getCachedModelsSync();
  bool get areModelsLoading => _modelService.isLoading;
  bool get modelsLoadError => _modelService.hasError;

  String? get modelId => _selectedModel?.id;

  String? get modelTitle {
    final currentModel = _isExitingChat ? _lastExitedModel : _selectedModel;
    if (currentModel == null) {
      return null;
    }

    final langCode = _currentLocale.languageCode;
    final baseId = _modelService.getBaseIdFromFullId(currentModel.id, langCode: langCode);

    if (baseId == currentModel.id) {
      return currentModel.displayTitle;
    }

    try {
      final seriesModel = _modelService.getPreciseModelData(baseId, langCode: langCode);
      return seriesModel.displayTitle;
    } catch (e) {
      // Fallback remains the same, which is robust.
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

  // Local model loading state is transient and remains separate.
  bool _isLocalModelLoaded = false;
  bool get isLocalModelLoaded => _isLocalModelLoaded;

  bool get isUserSubscribed => _isUserSubscribed;
  int get premiumTrialUses => _premiumTrialUses;
  ChatLimitManager? get chatLimitManager => _chatLimitManager;
  String? get displayName => _displayName;
  String? get email => _email;
  bool get showDisclaimer => isChatActive && _showDisclaimer && !_hasDismissedDisclaimerThisSession;
  bool get showPremiumBanner => _showPremiumBanner;
  bool get isCurrentModelPremium {
    final model = _isExitingChat ? _lastExitedModel : _selectedModel;
    return model?.isPremium ?? false;
  }
  bool get isStorageSufficient => _isStorageSufficient;

  // Returns the current locale used by the session for localization.
  Locale getLocale() => _currentLocale;

  // ===========================================================================
  // SECTION 3: CONSTRUCTOR
  // ===========================================================================

  ChatSessionProvider({required ModelService modelService}) : _modelService = modelService;
  
  // ===========================================================================
  // SECTION 4: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  /// Sets the current locale for the session, required for localization.
  void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  void selectModel(ModelEntity entity) {
    _isModelSelected = true;
    _isPersistentlyDynamic = false;
    _appBarMode = AppBarMode.modelSelected;
    _isExitingChat = false;
    _selectedModel = entity;

    if (!entity.isServerSide) {
      _isLocalModelLoaded = false;
    }

    updatePremiumBannerVisibility(entity.isPremium);
    notifyListeners();
  }

  void configureForStandardChat({
    required ModelEntity model,
    required bool isPremium,
  }) {
    _isExitingChat = false;
    _isPersistentlyDynamic = false;
    _isModelSelected = true;
    _appBarMode = AppBarMode.modelSelected;

    _selectedModel = model;

    if (!model.isServerSide) {
      _isLocalModelLoaded = false;
    }

    _showPremiumBanner = isPremium && !_isUserSubscribed;
    notifyListeners();
  }

  Future<void> startDynamicConversation() async {
    _isModelSelected = false;
    _isPersistentlyDynamic = true;
    _appBarMode = AppBarMode.dynamicChat;
    _isExitingChat = false;
    _selectedModel = null;
    _isLocalModelLoaded = false;
    _showPremiumBanner = false;
    notifyListeners();
    final dynamicChatService = DynamicChatService(this);
    await dynamicChatService.loadDynamicAssistantPreference(
      langCode: _currentLocale.languageCode,
      modelService: _modelService,
    );
  }

  void resetSessionState() {
    if (!_isExitingChat) {
      _isExitingChat = true;
      _wasDynamicOnExit = _isPersistentlyDynamic;
    }
    _lastExitedModel = _selectedModel;

    _isModelSelected = false;
    _isPersistentlyDynamic = false;
    _appBarMode = AppBarMode.notSelected;
    _selectedModel = null;
    _isLocalModelLoaded = false;
    _showPremiumBanner = false;
    _hasDismissedPremiumBannerThisSession = false;

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_isExitingChat) {
        _isExitingChat = false;
        _lastExitedModel = null;
      }
    });
  }

  /// Sets the required dependency for local model state management.
  /// This must be called by the ProxyProvider in main.dart.
  void setDependencies(ModelLocalStateProvider localStateProvider) {
    _localStateProvider ??= localStateProvider;
  }

  void setLocalModelLoaded(bool isLoaded) {
    if (_isLocalModelLoaded != isLoaded) {
      _isLocalModelLoaded = isLoaded;
      notifyListeners();
    }
  }

  void updateActiveModelExtension(String newModelId) {
    final langCode = _currentLocale.languageCode;
    _selectedModel = _modelService.getPreciseModelData(newModelId, langCode: langCode);
    updatePremiumBannerVisibility(_selectedModel?.isPremium ?? false);
    notifyListeners();
  }

  void pinDynamicAssistant(String modelId) {
    final langCode = _currentLocale.languageCode;
    final entity = _modelService.getPreciseModelData(modelId, langCode: langCode);

    _isPersistentlyDynamic = true;
    _isModelSelected = false;
    _appBarMode = AppBarMode.dynamicChat;
    _selectedModel = entity;

    updatePremiumBannerVisibility(entity.isPremium);
    notifyListeners();
  }

  void unpinDynamicAssistant() {
    _isPersistentlyDynamic = true;
    _isModelSelected = false;
    _appBarMode = AppBarMode.dynamicChat;
    _selectedModel = null;

    updatePremiumBannerVisibility(false);
    notifyListeners();
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
      if (parsedDate != null) lastResetTimestamp = Timestamp.fromDate(parsedDate);
    }

    int trialUses = data['premiumModelTrialUses'] as int? ?? 0;
    if (lastResetTimestamp != null) {
      final lastResetDate = lastResetTimestamp.toDate();
      final now = DateTime.now();
      if (lastResetDate.year != now.year || lastResetDate.month != now.month || lastResetDate.day != now.day) {
        trialUses = 0;
      }
    }
    _premiumTrialUses = trialUses;

    _displayName = data['displayName'] as String? ?? data['username'] as String?;
    _email = data['email'] as String?;

    final dynamic expiresValue = data['subscriptionExpiresAt'];
    Timestamp? subscriptionExpiresAt;
    if (expiresValue is Timestamp) {
      subscriptionExpiresAt = expiresValue;
    } else if (expiresValue is String) {
      final parsedDate = DateTime.tryParse(expiresValue);
      if (parsedDate != null) subscriptionExpiresAt = Timestamp.fromDate(parsedDate);
    }

    _chatLimitManager = ChatLimitManager(
      cortexSubscription: subscriptionLevel,
      subscriptionExpiresAt: subscriptionExpiresAt,
    );

    if (_selectedModel != null) {
      updatePremiumBannerVisibility(_selectedModel!.isPremium);
    }
    notifyListeners();
  }

  void updatePremiumBannerVisibility(bool isPremiumModel) {
    final shouldShow = isPremiumModel && !_isUserSubscribed && !_hasDismissedPremiumBannerThisSession;

    if (_showPremiumBanner != shouldShow) {
      _showPremiumBanner = shouldShow;
      notifyListeners();
    }
  }

  /// Checks if the disclaimer should be shown based on time elapsed since last shown.
  /// If 3 days (72 hours) have passed, it sets the flag to true.
  Future<void> triggerDisclaimer() async {
    if (_hasDismissedDisclaimerThisSession || _showDisclaimer) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      const String key = 'last_disclaimer_shown_ts';
      final int? lastShownTs = prefs.getInt(key);
      final DateTime now = DateTime.now();

      bool shouldShow = false;

      if (lastShownTs == null) {
        shouldShow = true;
      } else {
        final DateTime lastShownDate = DateTime.fromMillisecondsSinceEpoch(lastShownTs);
        final Duration diff = now.difference(lastShownDate);

        if (diff.inDays >= 3) {
          shouldShow = true;
        }
      }

      if (shouldShow) {
        _showDisclaimer = true;
        notifyListeners();

        await prefs.setInt(key, now.millisecondsSinceEpoch);
      }
    } catch (e) {
      debugPrint("Disclaimer check error: $e");
    }
  }

  void dismissDisclaimer() {
    if (_hasDismissedDisclaimerThisSession) return;
    _hasDismissedDisclaimerThisSession = true;
    notifyListeners();
  }

  void dismissPremiumBanner() {
    if (!_hasDismissedPremiumBannerThisSession) {
      _hasDismissedPremiumBannerThisSession = true;
      _showPremiumBanner = false;
      notifyListeners();
    }
  }

  void setStorageSufficient(bool isSufficient) {
    if (_isStorageSufficient != isSufficient) {
      _isStorageSufficient = isSufficient;
      notifyListeners();
    }
  }

  void setAppBarMode(AppBarMode mode) {
    if (_appBarMode != mode) {
      _appBarMode = mode;
      notifyListeners();
    }
  }
}
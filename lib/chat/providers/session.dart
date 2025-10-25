// lib/chat/providers/session.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:flutter/foundation.dart';
import 'package:cortex/models/backend/data/data.dart';

import '../../models/backend/data/info.dart';
import '../screen/selected/dynamic.dart';

/// Defines the visual and functional state of the AppBar in the ChatScreen.
enum AppBarMode {
  notSelected,      // Default view: "Cortex" title, credits bar.
  inSelection,      // "Explore All Models" view: "Explore" title, back button.
  modelSelected,    // Active chat with a standard model: Model name, back button.
  dynamicChat,      // Active dynamic chat: "Cortex" title, back button.
}

/// A dedicated provider responsible for managing the state of the overall chat session.
class ChatSessionProvider with ChangeNotifier {
  // ===========================================================================
  // SECTION 1: PRIVATE STATE VARIABLES
  // ===========================================================================

  // -------------------- Session & UI Mode State --------------------
  AppBarMode _appBarMode = AppBarMode.notSelected;
  bool _isModelSelected = false;
  // Tracks if the session is in "Dynamic Chat" mode, regardless of whether
  // it's currently purely random or has a pinned assistant.
  bool _isPersistentlyDynamic = false;
  bool _isExitingChat = false;
  bool _wasDynamicOnExit = false;

  // -------------------- Model List State --------------------
  List<ModelInfo> _allModels = [];
  bool _areModelsLoading = true;
  bool _modelsLoadError = false;

  // -------------------- Selected Model State --------------------
  String? _modelId;
  String? _modelTitle;
  String? _modelImagePath;
  String? _modelProducer;
  String? _modelPath;
  String? _role;
  bool _canHandleImage = false;
  bool _isLocalModelLoaded = false;
  String? _lastModelTitle;
  String? _lastModelImagePath;

  // -------------------- User & Subscription State --------------------
  bool _isUserSubscribed = false;
  int _premiumTrialUses = 0;
  ChatLimitManager? _chatLimitManager;
  String? _displayName;
  String? _email;

  // -------------------- Session-wide UI Flags --------------------
  bool _showDisclaimer = false;
  bool _showPremiumBanner = false;
  bool _isStorageSufficient = true;
  static bool _hasDismissedDisclaimerThisSession = false;

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================

  // -------------------- Session & UI Mode State --------------------
  AppBarMode get appBarMode => _appBarMode;
  bool get isModelSelected => _isModelSelected;
  /// Returns true if we are in the Dynamic Chat feature (either random or pinned).
  bool get isDynamicChat => _isPersistentlyDynamic;
  /// Returns true if ANY chat is active, keeping the ChatController in the active view.
  bool get isChatActive => _isModelSelected || _isPersistentlyDynamic;
  bool get isExitingChat => _isExitingChat;
  bool get wasDynamicOnExit => _wasDynamicOnExit;

  // -------------------- Model List State --------------------
  List<ModelInfo> get allModels => _allModels;
  bool get areModelsLoading => _areModelsLoading;
  bool get modelsLoadError => _modelsLoadError;

  // -------------------- Selected Model State --------------------
  String? get modelId => _modelId;
  String? get modelTitle => _isExitingChat ? _lastModelTitle : _modelTitle;
  String? get modelImagePath => _isExitingChat ? _lastModelImagePath : _modelImagePath;
  String? get role => _role;
  String? get modelPath => _modelPath;
  bool get canHandleImage => _canHandleImage;
  bool get isLocalModelLoaded => _isLocalModelLoaded;

  // -------------------- User & Subscription State --------------------
  bool get isUserSubscribed => _isUserSubscribed;
  int get premiumTrialUses => _premiumTrialUses;
  ChatLimitManager? get chatLimitManager => _chatLimitManager;
  String? get displayName => _displayName;
  String? get email => _email;

  // -------------------- Session-wide UI Flags --------------------
  bool get showDisclaimer {
    return isChatActive && !_hasDismissedDisclaimerThisSession;
  }
  bool get showPremiumBanner => _showPremiumBanner;
  bool get isStorageSufficient => _isStorageSufficient;

  // ===========================================================================
  // SECTION 3: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  // -------------------- Model List Actions --------------------

  void setModelsLoading() {
    _areModelsLoading = true;
    _modelsLoadError = false;
    notifyListeners();
  }

  void setModelsLoadSuccess(List<ModelInfo> loadedModels) {
    _areModelsLoading = false;
    _modelsLoadError = false;
    _allModels = loadedModels;
    notifyListeners();
  }

  void setModelsLoadError() {
    _areModelsLoading = false;
    _modelsLoadError = true;
    notifyListeners();
  }

  // -------------------- Chat Session Lifecycle Actions --------------------

  void selectModel(ModelInfo model, {Map<String, dynamic>? preciseData}) {
    final data = preciseData ?? ModelData.getPreciseModelData(model.id);

    _isModelSelected = true;
    _isPersistentlyDynamic = false;
    _appBarMode = AppBarMode.modelSelected;
    _isExitingChat = false;

    _modelId = model.id;
    _modelTitle = model.title;
    _modelImagePath = model.imagePath;
    _modelProducer = model.producer;
    _modelPath = data['path'] as String?;
    _role = data['role'] as String?;
    _canHandleImage = ModelData.hasModality(model.id, 'image');

    updatePremiumBannerVisibility((data['tier'] as String? ?? 'free') == 'premium');

    notifyListeners();
  }

  /// Intelligently starts a new dynamic chat session by first checking for a
  /// pinned assistant preference. This is now the single source of truth for
  /// beginning a dynamic chat.
  /// Intelligently starts a new dynamic chat session by first checking for a
  /// pinned assistant preference. This is now the single source of truth for
  /// beginning a dynamic chat.
  Future<void> startDynamicConversation() async {
    // 1. Set the basic dynamic chat state immediately. This ensures the UI
    // transitions to the active chat view without delay.
    _isModelSelected = false;
    _isPersistentlyDynamic = true;
    _appBarMode = AppBarMode.dynamicChat;
    _isExitingChat = false;
    // Notify listeners for the initial UI change, but without model details yet.
    notifyListeners();

    // 2. Asynchronously check for a saved assistant preference.
    final dynamicChatService = DynamicChatService(this);
    await dynamicChatService.loadDynamicAssistantPreference();
  }

  void resetSessionState() {
    if (!_isExitingChat) {
      _isExitingChat = true;
      _wasDynamicOnExit = _isPersistentlyDynamic;
    }

    _lastModelTitle = _modelTitle;
    _lastModelImagePath = _modelImagePath;

    _isModelSelected = false;
    _isPersistentlyDynamic = false;
    _appBarMode = AppBarMode.notSelected;
    _modelId = null;
    _modelTitle = null;
    _modelImagePath = null;
    _modelProducer = null;
    _modelPath = null;
    _role = null;
    _canHandleImage = false;
    _isLocalModelLoaded = false;
    _showPremiumBanner = false;

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (_isExitingChat) {
        _isExitingChat = false;
        _lastModelTitle = null;
        _lastModelImagePath = null;
      }
    });
  }

  void configureForDynamicConversation() {
    _isExitingChat = false;
    _isModelSelected = false;
    _isPersistentlyDynamic = true;
    _appBarMode = AppBarMode.dynamicChat;
    _modelId = null;
    _modelTitle = null;
    _modelImagePath = null;
    _modelProducer = null;
    _modelPath = null;
    _role = null;
    _canHandleImage = true;
    _isLocalModelLoaded = false;
    _showPremiumBanner = false;

    notifyListeners();
  }

  void configureForStandardConversation({
    required ModelInfo modelInfo,
    required bool isPremium,
  }) {
    _isExitingChat = false;
    _isPersistentlyDynamic = false;

    _isModelSelected = true;
    _appBarMode = AppBarMode.modelSelected;
    _modelId = modelInfo.id;
    _modelTitle = modelInfo.title;
    _modelImagePath = modelInfo.imagePath;
    _modelProducer = modelInfo.producer;
    _modelPath = modelInfo.path;
    _role = modelInfo.role;
    _canHandleImage = ModelData.hasModality(modelInfo.id, 'image');
    _showPremiumBanner = isPremium && !_isUserSubscribed;
    _isLocalModelLoaded = false;

    notifyListeners();
  }

  // -------------------- Selected Model & Dynamic Chat Actions --------------------

  void setLocalModelLoaded(bool isLoaded) {
    if (_isLocalModelLoaded != isLoaded) {
      _isLocalModelLoaded = isLoaded;
      notifyListeners();
    }
  }

  void updateActiveModelExtension(String newModelId) {
    final preciseData = ModelData.getPreciseModelData(newModelId);

    _modelId = newModelId;
    _role = preciseData['role'] as String? ?? _role;
    _canHandleImage = ModelData.hasModality(newModelId, 'image');

    final seriesData = ModelData.getPreciseModelData(ModelData.getBaseIdFromFullId(newModelId));
    _modelTitle = seriesData['title'] as String? ?? _modelTitle;
    _modelImagePath = ModelData.getModelImagePath(seriesData);
    _modelProducer = seriesData['producer'] as String? ?? _modelProducer;

    final bool isPremium = (preciseData['tier'] as String? ?? 'free') == 'premium';
    updatePremiumBannerVisibility(isPremium);

    notifyListeners();
  }

  /// Configures the state to use a specific, "pinned" model WITHIN the Dynamic Chat mode.
  void pinDynamicAssistant(String modelId) {
    final preciseData = ModelData.getPreciseModelData(modelId);

    // CRITICAL FIX: We MUST remain in persistently dynamic mode so `isChatActive`
    // remains true and the ChatController doesn't exit the view.
    _isPersistentlyDynamic = true;
    _isModelSelected = false;
    _appBarMode = AppBarMode.dynamicChat;

    _modelId = modelId;
    _role = preciseData['role'] as String?;
    _canHandleImage = ModelData.hasModality(modelId, 'image');

    _modelTitle = preciseData['title'] as String?;
    _modelImagePath = preciseData['imagePath'] as String?;
    _modelProducer = preciseData['producer'] as String?;

    final bool isPremium = (preciseData['tier'] as String? ?? 'free') == 'premium';
    updatePremiumBannerVisibility(isPremium);

    notifyListeners();
  }

  /// Resets the Dynamic Chat to its default "ask anything" (random) mode.
  void unpinDynamicAssistant() {
    // CRITICAL FIX: Ensure we stay in dynamic mode.
    _isPersistentlyDynamic = true;
    _isModelSelected = false;
    _appBarMode = AppBarMode.dynamicChat;

    _modelId = null;
    _role = null;
    _canHandleImage = true; // Default capability for generic mode.
    _modelTitle = null;
    _modelImagePath = null;
    _modelProducer = null;

    updatePremiumBannerVisibility(false);
    notifyListeners();
  }

  // -------------------- User & UI Flag Actions --------------------

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
      if (parsedDate != null) {
        subscriptionExpiresAt = Timestamp.fromDate(parsedDate);
      }
    }

    _chatLimitManager = ChatLimitManager(
      cortexSubscription: subscriptionLevel,
      subscriptionExpiresAt: subscriptionExpiresAt,
    );

    if (_isModelSelected && modelId != null) {
      final modelData = ModelData.getPreciseModelData(modelId!);
      updatePremiumBannerVisibility((modelData['tier'] as String? ?? 'free') == 'premium');
    }

    notifyListeners();
  }

  void updatePremiumBannerVisibility(bool isPremiumModel) {
    final shouldShow = isPremiumModel && !_isUserSubscribed;
    if (_showPremiumBanner != shouldShow) {
      _showPremiumBanner = shouldShow;
      notifyListeners();
    }
  }

  void triggerDisclaimer() {
    if (!_showDisclaimer) {
      _showDisclaimer = true;
      notifyListeners();
    }
  }

  void dismissDisclaimer() {
    if (_hasDismissedDisclaimerThisSession) return;
    _hasDismissedDisclaimerThisSession = true;
    notifyListeners();
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
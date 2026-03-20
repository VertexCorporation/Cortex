// lib/chat/providers/session.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/utils.dart';
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
  ModelEntity? get selectedModel => _selectedModel;

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

    // If using a stub entity with empty title, return null to trigger fallback display
    if (currentModel.displayTitle.isEmpty) {
      return null;
    }

    final langCode = _currentLocale.languageCode;
    final baseId =
        _modelService.getBaseIdFromFullId(currentModel.id, langCode: langCode);

    // [FIX] Absolute Hardening: "Unknown Model"
    // The user wants to NEVER see "Unknown Model", even for a split second.
    // If the data returns that string, we MUST fallback to "Cortex" or the stub title.

    String resolvedTitle = currentModel.displayTitle;

    // Try to get precise data if possible
    if (baseId != currentModel.id) {
      try {
        final seriesModel =
            _modelService.getPreciseModelData(baseId, langCode: langCode);
        resolvedTitle = seriesModel.displayTitle;
      } catch (_) {
        // Keep using currentModel.displayTitle
      }
    }

    if (resolvedTitle == 'Unknown Model' || resolvedTitle.isEmpty) {
      // Fallback hierarchy:
      // 1. "Cortex" (if it's the auto model)
      // 2. The Model ID capitalized (better than "Unknown")

      if (baseId == 'cortex/auto' || baseId == 'dynamic') {
        return 'Cortex';
      }

      // Return a cleaner version of ID if title is missing
      return ModelDataUtils.formatModelName(baseId.split('/').last);
    }

    return resolvedTitle;
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

  // Track pending model ID that needs resolution when catalog loads
  String? _pendingModelId;

  ChatSessionProvider({
    required ModelService modelService,
    String initialModelId = 'cortex/auto',
    String initialModelTitle = '', // [NEW] Cached title
    Locale initialLocale = const Locale('en'),
  }) : _modelService = modelService {
    try { FirebaseAuth.instance.authStateChanges().listen((User? user) { if (user == null) { resetForLogout(); } }); } catch (e) { /* Ignore in tests */ }

    // Optimistic Initialization
    _currentLocale = initialLocale;

    // We try to load the model immediately.
    // NOTE: ModelService might not have full catalog yet, but basic logic might work
    // or we can fall back gracefully without setting it to null (which implies dynamic).

    // If we can't find it immediately, we store it to resolve later?
    // Actually, initializeDefaultSession() was doing async prefs read.
    // Now we have the ID.

    // Listen to ModelService updates to resolve pending model when catalog loads
    _modelService.addListener(_onModelServiceUpdate);

    // IMMEDIATE CHECK: In case it's already loaded or loading finished before listener attach
    debugPrint(
        "[ChatSessionProvider] Constructor: Attaching listener. Initial isLoading: ${_modelService.isLoading}");
    if (!_modelService.isLoading) {
      _onModelServiceUpdate();
    }

    // CRITICAL FIX: Check if cache is empty FIRST.
    // If we call getPreciseModelData while cache is empty, ModelService returns a generic "Unknown Model" entity
    // instead of throwing. This bypasses our catch block where we would use the cached title.
    // So we must manually check cache state.
    final bool isCacheEmpty = _modelService.getCachedModelsSync().isEmpty;

    if (isCacheEmpty) {
      debugPrint(
          "[ChatSessionProvider] Cache is empty. Using cached title: '$initialModelTitle' for ID: $initialModelId");
      _initializeWithStub(initialModelId, ModelDataUtils.formatModelName(initialModelTitle));
    } else {
      try {
        final langCode = initialLocale.languageCode;
        final entity = _modelService.getPreciseModelData(initialModelId,
            langCode: langCode);
        selectModel(entity, savePreference: false);
      } catch (e) {
        // Fallback to stub if exact lookup fails even with cache present
        _initializeWithStub(initialModelId, ModelDataUtils.formatModelName(initialModelTitle));
      }
    }
  }

  void _initializeWithStub(String modelId, String title) {
    if (modelId == 'cortex/auto' || modelId == 'dynamic') {
      startDynamicConversation(savePreference: false);
    } else {
      debugPrint(
          "[ChatSessionProvider] Initialization fallback. Storing pending ID: $modelId");

      // [FIX] Ensure title is never empty for the stub
      String effectiveTitle = title;
      if (effectiveTitle.isEmpty) {
        if (modelId == 'cortex/auto') {
          effectiveTitle = 'Cortex';
        } else {
          // Try to make it look decent
          effectiveTitle = 'Cortex';
        }
      }

      // Store for later resolution when catalog loads
      _pendingModelId = modelId;

      // Create stub with valid title if cached, otherwise empty
      final stubEntity = ModelEntity(
        id: modelId,
        displayTitle: effectiveTitle,
        producer: 'Vertex',
        displaySummary: '',
        displayDescription: '',
        type: 'online',
        category: 'general',
        tier: 'free',
        modalities: {'text': true},
        outputs: {'text': true},
        isFullyLocalized: true,
      );
      selectModel(stubEntity, savePreference: false);
    }
  }

  void _onModelServiceUpdate() {
    // Debug log to trace service updates
    // debugPrint("[ChatSessionProvider] _onModelServiceUpdate. isLoading: ${_modelService.isLoading}, pendingId: $_pendingModelId");

    // If models are loaded and we have a pending ID, try to resolve it
    if (!_modelService.isLoading && _pendingModelId != null) {
      refreshModelAfterCatalogLoad();
    }
  }

  @override
  void dispose() {
    _modelService.removeListener(_onModelServiceUpdate);
    super.dispose();
  }

  /// Called when model catalog finishes loading to resolve pending model
  void refreshModelAfterCatalogLoad() {
    if (_pendingModelId == null) return;

    final pendingId = _pendingModelId!;
    debugPrint(
        "[ChatSessionProvider] refreshModelAfterCatalogLoad: Attempting to resolve pending ID: $pendingId");

    final langCode = _currentLocale.languageCode;
    try {
      // Check if service actually has data now
      if (_modelService.getCachedModelsSync().isEmpty) {
        debugPrint(
            "[ChatSessionProvider] refreshModelAfterCatalogLoad: Service cache still empty. Aborting.");
        return;
      }

      final entity =
          _modelService.getPreciseModelData(pendingId, langCode: langCode);

      // Clear pending ID first so selectModel doesn't get confused or we don't retry unnecessarily
      _pendingModelId = null;

      selectModel(entity, savePreference: false);
      debugPrint(
          "[ChatSessionProvider] Successfully resolved pending model: ${entity.displayTitle}");
    } catch (e) {
      debugPrint(
          "[ChatSessionProvider] Failed to resolve pending model: $pendingId. Error: $e");
      // Keep pending ID to try again next update? Or give up?
      // If it failed despite cache being present, it might be an invalid ID.
    }
  }

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
      _savePreference(entity.id, entity.displayTitle);
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
      final entity =
          _modelService.getPreciseModelData(savedId, langCode: langCode);
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
      _savePreference('cortex/auto', '');
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
      _selectedModel =
          _modelService.getPreciseModelData(newModelId, langCode: langCode);
      _savePreference(newModelId, _selectedModel!.displayTitle);
    }

    notifyListeners();
  }

  Future<void> _savePreference(String id, String title) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefDefaultModelKey, id);
      await prefs.setString('${_prefDefaultModelKey}_title', title);
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

  /// A complete state wipe out for when the user logs out.
  void resetForLogout() {
    _isExitingChat = false;
    _lastExitedModel = null;
    _selectedModel = null;
    _isUserSubscribed = false;
    _premiumTrialUses = 0;
    _chatLimitManager = null;
    _displayName = null;
    _email = null;
    _isLocalModelLoaded = false;
    _isFluxMode = false;
    ChatStorageService.isFluxMode = false;
    _pendingModelId = null;
    notifyListeners();
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
      if (lastResetDate.year != now.year ||
          lastResetDate.month != now.month ||
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

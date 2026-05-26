// lib/chat/providers/session.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/utils.dart';
import '../../library/providers/local.dart';
import '../../variants.dart';
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

    if (baseId == 'cortex/auto' || baseId == 'dynamic') {
      return 'Cortex';
    }

    // SERIES NAME PRIORITY: If the current model belongs to a series,
    // always show the series name instead of the individual variant title.
    // The user should never see the underlying model technicalities like
    // "GPT-4o" — they should only see the series name like "ChatGPT".
    try {
      final parentSeries = ModelDataUtils.findParentSeriesData(
        currentModel.id,
        langCode: langCode,
        modelService: _modelService,
      );
      final isRealVariantSeries = parentSeries != null &&
          parentSeries.variants != null &&
          parentSeries.variants!.isNotEmpty;
      if (isRealVariantSeries) {
        final seriesTitle = parentSeries.series ?? parentSeries.displayTitle;
        if (seriesTitle.isNotEmpty && seriesTitle != 'Unknown Model') {
          return seriesTitle;
        }
      }
    } catch (_) {
      // Fall through to legacy resolution
    }

    String resolvedTitle = currentModel.displayTitle;

    // Try to get precise data to ensure title is localized properly
    try {
      final seriesModel = _modelService.getPreciseModelData(currentModel.id,
          langCode: langCode);
      resolvedTitle = seriesModel.displayTitle;
    } catch (_) {
      // Keep using currentModel.displayTitle if precise fetch fails
    }

    if (resolvedTitle == 'Unknown Model' || resolvedTitle.isEmpty) {
      // Return a cleaner version of ID if title is missing
      return ModelDataUtils.formatModelName(baseId.split('/').last);
    }

    final seriesTitle = currentModel.series;
    if (_looksLikeRawId(resolvedTitle, currentModel.id) &&
        seriesTitle != null &&
        seriesTitle.isNotEmpty &&
        !_looksLikeRawId(seriesTitle, currentModel.id)) {
      return seriesTitle;
    }

    return resolvedTitle;
  }

  static bool _looksLikeRawId(String value, String id) {
    String normalize(String input) =>
        input.replaceAll(RegExp(r'[\s_\-/]+'), '').toLowerCase();
    return normalize(value) == normalize(id);
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
    final localState = _localStateProvider;
    if (localState == null ||
        !localState.isInitialized ||
        !localState.hasResolvedFilesDirectory) {
      return null;
    }
    return localState.getFilePathById(_selectedModel!.id);
  }

  bool _checkModality(String modality) {
    if (_selectedModel == null) return false;
    if (_selectedModel!.modalities[modality] == true) return true;
    
    final isCharacter = _selectedModel!.category == 'roleplay' || _selectedModel!.category == 'self';
    if (isCharacter && _selectedModel!.baseModelId != null && _selectedModel!.baseModelId!.isNotEmpty) {
      try {
        final baseModel = _modelService.getPreciseModelData(
          _selectedModel!.baseModelId!, 
          langCode: _currentLocale.languageCode
        );
        return baseModel.modalities[modality] == true;
      } catch (_) {}
    }
    return false;
  }

  bool get canHandleImage => _checkModality('image');
  bool get canHandleVideo => _checkModality('video');
  bool get canHandleAudio => _checkModality('audio');

  bool _isLocalModelLoaded = false;

  bool get isLocalModelLoaded => _isLocalModelLoaded;

  bool get isUserSubscribed => _isUserSubscribed;

  ChatLimitManager? get chatLimitManager => _chatLimitManager;

  String? get displayName => _displayName;

  String? get email => _email;

  bool get isCurrentModelPremium {
    final model = _isExitingChat ? _lastExitedModel : _selectedModel;
    if (model == null) return false;

    // Check if it's a series (it has variants)
    // If it's a series, it is premium ONLY IF ALL its variants are premium.
    if (model.variants != null && model.variants!.isNotEmpty) {
      bool allPremium = true;
      for (final variantMap in model.variants!.values) {
        if (variantMap is! Map) continue;
        final tier = variantMap['tier']?.toString();
        final source = variantMap['source']?.toString();
        final isVariantPremium = (tier == 'plus' ||
            tier == 'pro' ||
            tier == 'ultra' ||
            source == 'fal');
        if (!isVariantPremium) {
          allPremium = false;
          break;
        }
      }
      return allPremium;
    }

    // Explicitly treat Fal models as premium on the client side
    if (model.source == 'fal') return true;
    if (model.isPremium) return true;

    if (model.baseModelId != null) {
      try {
        final baseModel = _modelService.getPreciseModelData(model.baseModelId!,
            langCode: _currentLocale.languageCode);
        if (baseModel.source == 'fal') return true;
        return baseModel.isPremium;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  bool get isStorageSufficient => _isStorageSufficient;

  bool get isFluxMode => _isFluxMode;

  Locale getLocale() => _currentLocale;

  // ===========================================================================
  // SECTION 3: CONSTRUCTOR
  // ===========================================================================

  // Track pending model ID that needs resolution when catalog loads
  String? _pendingModelId;

  // PERF: Cache the SharedPreferences instance to avoid platform channel
  // round-trips on every model preference save.
  SharedPreferences? _prefs;
  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  ChatSessionProvider({
    required ModelService modelService,
    String initialModelId = 'cortex/auto',
    String initialModelTitle = '', // [NEW] Cached title
    Locale initialLocale = const Locale('en'),
  }) : _modelService = modelService {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          resetForLogout();
        }
      });
    } catch (e) {/* Ignore in tests */}

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
      _initializeWithStub(
          initialModelId, ModelDataUtils.formatModelName(initialModelTitle));
    } else {
      final langCode = initialLocale.languageCode;
      if (_modelService.hasModelInCache(initialModelId)) {
        try {
          final entity = _modelService.getPreciseModelData(initialModelId,
              langCode: langCode);
          selectModel(entity, savePreference: false);
        } catch (e) {
          // Fallback to stub if exact lookup fails even with cache present
          _initializeWithStub(initialModelId,
              ModelDataUtils.formatModelName(initialModelTitle));
        }
      } else {
        // The saved model was removed from catalog. Default to dynamic chat.
        startDynamicConversation(savePreference: true);
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
          effectiveTitle = ModelDataUtils.formatModelName(modelId);
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
        source: 'openrouter',
        category: 'general',
        tier: 'free',
        modalities: {'text': true},
        outputs: {'text': true},
        isFullyLocalized: true,
        toolUse: false,
      );
      selectModel(stubEntity, savePreference: false);
    }
  }

  void _onModelServiceUpdate() {
    // Debug log to trace service updates
    // debugPrint("[ChatSessionProvider] _onModelServiceUpdate. isLoading: ${_modelService.isLoading}, pendingId: $_pendingModelId");

    // If models are loaded and we have a pending ID, try to resolve it
    if (!_modelService.isLoading && _pendingModelId != null) {
      unawaited(refreshModelAfterCatalogLoad());
    }
  }

  @override
  void dispose() {
    _modelService.removeListener(_onModelServiceUpdate);
    super.dispose();
  }

  /// Called when model catalog finishes loading to resolve pending model
  Future<void> refreshModelAfterCatalogLoad() async {
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

      if (!_modelService.hasModelInCache(pendingId)) {
        debugPrint(
            "[ChatSessionProvider] Pending model '$pendingId' no longer exists. Falling back to dynamic.");
        _pendingModelId = null;
        startDynamicConversation(savePreference: true);
        return;
      }

      final entity = await _resolveRestorableModelEntity(pendingId, langCode);

      // Clear pending ID first so selectModel doesn't get confused or we don't retry unnecessarily
      _pendingModelId = null;

      if (!_canUseRestoredModel(entity)) {
        debugPrint(
            "[ChatSessionProvider] Pending model '$pendingId' is unavailable on this device. Falling back to dynamic.");
        startDynamicConversation(savePreference: true);
        return;
      }

      selectModel(entity, savePreference: false);
      debugPrint(
          "[ChatSessionProvider] Successfully resolved pending model: ${entity.displayTitle}");
    } catch (e) {
      debugPrint(
          "[ChatSessionProvider] Failed to resolve pending model: $pendingId. Error: $e");
      _pendingModelId = null;
      startDynamicConversation(savePreference: true);
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
    final bool isSameModel = _selectedModel?.id == entity.id;
    _isExitingChat = false;
    _selectedModel = entity;

    if (!entity.isServerSide && !isSameModel) {
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
      final bool isCacheEmpty = _modelService.getCachedModelsSync().isEmpty;

      // If cache is empty, we must wait for catalog to load before making a final decision.
      if (isCacheEmpty) {
        String savedTitle =
            prefs.getString('${_prefDefaultModelKey}_title') ?? '';
        _initializeWithStub(savedId, savedTitle);
        return;
      }

      if (!_modelService.hasModelInCache(savedId)) {
        startDynamicConversation(savePreference: true);
        return;
      }

      final entity = await _resolveRestorableModelEntity(savedId, langCode);
      if (!_canUseRestoredModel(entity)) {
        startDynamicConversation(savePreference: true);
        return;
      }
      selectModel(entity, savePreference: false);
    } catch (e) {
      startDynamicConversation(savePreference: true);
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
      _savePreference(newModelId, _selectedModel!.displayTitle);
    }

    notifyListeners();
  }

  Future<void> _savePreference(String id, String title) async {
    try {
      final prefs = await _sharedPrefs;
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

    // Reset flags (Do not reset _isLocalModelLoaded here, it is tied to the physical cpp model instance)
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
    _localStateProvider = localStateProvider;
    unawaited(_reconcileSelectedModelAvailability());
  }

  bool get _hasResolvedLocalModelState {
    final localState = _localStateProvider;
    return localState != null &&
        localState.isInitialized &&
        localState.hasResolvedFilesDirectory;
  }

  bool _isOfflineModelAvailableById(String id) {
    final localState = _localStateProvider;
    if (localState == null || !_hasResolvedLocalModelState) {
      // Local file state is still booting. Defer the final decision so a
      // valid saved offline selection does not briefly get overwritten.
      return true;
    }

    if (localState.downloadCompleted[id] == true) {
      return true;
    }

    final path = localState.getFilePathById(id);
    return localState.isModelOnDisk(path);
  }

  bool _canUseRestoredModel(ModelEntity entity) {
    if (entity.id == 'cortex/auto' || entity.id == 'dynamic') return true;
    if (entity.isServerSide) return true;

    final variants = entity.variants;
    if (variants != null && variants.isNotEmpty) {
      return variants.keys.any(_isOfflineModelAvailableById);
    }

    return _isOfflineModelAvailableById(entity.id);
  }

  Future<ModelEntity> _resolveRestorableModelEntity(
    String savedId,
    String langCode,
  ) async {
    final entity =
        _modelService.getPreciseModelData(savedId, langCode: langCode);

    final variants = entity.variants;
    if (entity.isServerSide || variants == null || variants.isEmpty) {
      return entity;
    }

    final candidateIds = <String>[];
    final lastUsedId = await Variants.getLastSelectedVariant(entity.id);
    if (lastUsedId.isNotEmpty && variants.containsKey(lastUsedId)) {
      candidateIds.add(lastUsedId);
    }
    candidateIds.addAll(variants.keys.where((id) => id != lastUsedId));

    for (final candidateId in candidateIds) {
      if (_isOfflineModelAvailableById(candidateId)) {
        return _modelService.getPreciseModelData(
          candidateId,
          langCode: langCode,
        );
      }
    }

    return entity;
  }

  Future<void> _reconcileSelectedModelAvailability() async {
    final model = _selectedModel;
    if (model == null || model.isServerSide || !_hasResolvedLocalModelState) {
      return;
    }

    final langCode = _currentLocale.languageCode;
    final resolved = await _resolveRestorableModelEntity(model.id, langCode);

    if (!_canUseRestoredModel(resolved)) {
      debugPrint(
          "[ChatSessionProvider] Saved offline model '${model.id}' is no longer available. Falling back to Dynamic Chat.");
      startDynamicConversation(savePreference: true);
      return;
    }

    if (resolved.id != model.id) {
      selectModel(resolved, savePreference: true);
    }
  }

  void setLocalModelLoaded(bool isLoaded) {
    if (_isLocalModelLoaded != isLoaded) {
      _isLocalModelLoaded = isLoaded;
      notifyListeners();
    }
  }

  void updateUserData(Map<String, dynamic> data) {
    final int subscriptionLevel = _activeSubscriptionLevelFrom(data);
    _isUserSubscribed = subscriptionLevel > 0;

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

  int _parseSubscriptionLevel(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Timestamp? _parseSubscriptionTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is String) {
      final parsedDate = DateTime.tryParse(value);
      if (parsedDate != null) {
        return Timestamp.fromDate(parsedDate);
      }
    }
    return null;
  }

  int _activeSubscriptionLevelFrom(Map<String, dynamic> data) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous =
        (user?.isAnonymous ?? false) || data['accountType'] == 'anonymous';
    if (isAnonymous) return 0;

    final level = _parseSubscriptionLevel(data['hasCortexSubscription']);
    if (level <= 0) return 0;

    final expiry = _parseSubscriptionTimestamp(data['subscriptionExpiresAt']);
    if (expiry == null) return level >= 4 && level <= 6 ? level : 0;
    return expiry.toDate().isAfter(DateTime.now()) ? level : 0;
  }

  void setStorageSufficient(bool isSufficient) {
    if (_isStorageSufficient != isSufficient) {
      _isStorageSufficient = isSufficient;
      notifyListeners();
    }
  }
}

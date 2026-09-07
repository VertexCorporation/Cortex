// lib/chat/providers/session.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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
  StreamSubscription? _authSub;
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
    final selected = _selectedModel;
    if (selected == null) return false;
    if (selected.modalities[modality] == true) return true;

    // A selected catalog entry can represent an entire series. The send layer
    // resolves that series to a concrete variant for each request, so the UI
    // capability check must use the same aggregate view. Previously this only
    // inspected the parent map, causing the attachment UI and actual routing
    // logic to disagree about whether a Claude/Llama/etc. series supported
    // images, audio or video.
    final variants = selected.variants;
    if (variants != null && variants.isNotEmpty) {
      for (final rawVariant in variants.values) {
        if (rawVariant is! Map) continue;
        final variant = Map<String, dynamic>.from(rawVariant);
        final modalities = variant['modalities'];
        if (modalities is Map && modalities[modality] == true) {
          return true;
        }
      }
    }

    final isCharacter = selected.category == 'roleplay' ||
        selected.category == 'self';
    if (isCharacter &&
        selected.baseModelId != null &&
        selected.baseModelId!.isNotEmpty) {
      try {
        final baseModel = _modelService.getPreciseModelData(
            selected.baseModelId!,
            langCode: _currentLocale.languageCode);
        if (baseModel.modalities[modality] == true) return true;
        final baseVariants = baseModel.variants;
        if (baseVariants != null) {
          for (final rawVariant in baseVariants.values) {
            if (rawVariant is! Map) continue;
            final variantModalities = rawVariant['modalities'];
            if (variantModalities is Map &&
                variantModalities[modality] == true) {
              return true;
            }
          }
        }
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
    ModelLocalStateProvider? localStateProvider,
  })  : _modelService = modelService,
        _localStateProvider = localStateProvider {
    _listenToAuth();
  }

  void _listenToAuth() {
    try {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          resetForLogout();
        }
      });
    } catch (_) {
      // Ignore during tests
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // SECTION 4: STATE MUTATION & MODEL SELECTION
  // ===========================================================================

  Future<void> initialize() async {
    final prefs = await _sharedPrefs;
    final savedModelId = prefs.getString(_prefDefaultModelKey);
    if (savedModelId != null && savedModelId.isNotEmpty) {
      _pendingModelId = savedModelId;
    }
  }

  void updateDependencies({ModelLocalStateProvider? localStateProvider}) {
    if (localStateProvider != null) {
      _localStateProvider = localStateProvider;
    }
  }

  /// Selects a model and persists the user's preferred model ID.
  void selectModel(ModelEntity model) {
    _selectedModel = model;
    _pendingModelId = null;
    _savePreferredModelId(model.id);
    _updateLocalModelLoadedState();
    notifyListeners();
  }

  /// Updates only the active variant ID while preserving the current series.
  /// This is used by selectors where the series is already active but a concrete
  /// backend variant is chosen.
  void updateActiveModelVariant(String modelId) {
    try {
      final langCode = _currentLocale.languageCode;
      final precise =
          _modelService.getPreciseModelData(modelId, langCode: langCode);
      _selectedModel = precise;
    } catch (_) {
      if (_selectedModel != null) {
        _selectedModel = _selectedModel!.copyWith(id: modelId);
      }
    }
    _pendingModelId = null;
    _savePreferredModelId(modelId);
    _updateLocalModelLoadedState();
    notifyListeners();
  }

  void clearModelSelection() {
    _selectedModel = null;
    _pendingModelId = null;
    _savePreferredModelId('cortex/auto');
    _updateLocalModelLoadedState();
    notifyListeners();
  }

  Future<void> _savePreferredModelId(String id) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_prefDefaultModelKey, id);
    } catch (_) {}
  }

  /// Re-resolves the currently selected model after the catalog is refreshed.
  /// Important when Synapse metadata (modalities/variants/titles) changes.
  void refreshSelectedModelFromCatalog() {
    final currentId = _selectedModel?.id ?? _pendingModelId;
    if (currentId == null || currentId.isEmpty || currentId == 'cortex/auto') {
      return;
    }
    try {
      _selectedModel = _modelService.getPreciseModelData(currentId,
          langCode: _currentLocale.languageCode);
      _pendingModelId = null;
      _updateLocalModelLoadedState();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshModelAfterCatalogLoad() async {
    final id = _pendingModelId ?? _selectedModel?.id;
    if (id == null || id.isEmpty || id == 'cortex/auto') return;
    try {
      _selectedModel = _modelService.getPreciseModelData(id,
          langCode: _currentLocale.languageCode);
      _pendingModelId = null;
      _updateLocalModelLoadedState();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setUserSubscribed(bool value) async {
    if (_isUserSubscribed == value) return;
    _isUserSubscribed = value;
    notifyListeners();
  }

  Future<void> updateLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    // Re-resolve selected model so localized title/description stays correct.
    refreshSelectedModelFromCatalog();
    notifyListeners();
  }

  // ===========================================================================
  // SECTION 5: LOCAL MODEL STATE
  // ===========================================================================

  void _updateLocalModelLoadedState() {
    final selected = _selectedModel;
    final local = _localStateProvider;
    if (selected == null || selected.isServerSide) {
      _isLocalModelLoaded = false;
      return;
    }

    if (local == null ||
        !local.isInitialized ||
        !local.hasResolvedFilesDirectory) {
      _isLocalModelLoaded = false;
      return;
    }

    // For a series entry, consider it loaded if any local variant is on disk.
    if (selected.variants != null && selected.variants!.isNotEmpty) {
      _isLocalModelLoaded = selected.variants!.keys.any((variantId) {
        final path = local.getFilePathById(variantId);
        return local.isModelOnDisk(path);
      });
      return;
    }

    final path = local.getFilePathById(selected.id);
    _isLocalModelLoaded = local.isModelOnDisk(path);
  }

  // ===========================================================================
  // SECTION 6: CHAT SESSION HYDRATION / STORAGE
  // ===========================================================================

  Future<void> hydrateFromConversationModel(String? modelId) async {
    if (modelId == null || modelId.isEmpty || modelId == 'cortex/auto') {
      clearModelSelection();
      return;
    }
    try {
      final precise = _modelService.getPreciseModelData(modelId,
          langCode: _currentLocale.languageCode);
      _selectedModel = precise;
      _pendingModelId = null;
    } catch (_) {
      _pendingModelId = modelId;
    }
    _updateLocalModelLoadedState();
    notifyListeners();
  }

  void restoreSelectionWithoutPersistence(String? modelId) {
    if (modelId == null || modelId.isEmpty || modelId == 'cortex/auto') {
      _selectedModel = null;
      _pendingModelId = null;
    } else {
      try {
        _selectedModel = _modelService.getPreciseModelData(modelId,
            langCode: _currentLocale.languageCode);
        _pendingModelId = null;
      } catch (_) {
        _pendingModelId = modelId;
      }
    }
    _updateLocalModelLoadedState();
    notifyListeners();
  }

  // ===========================================================================
  // SECTION 7: FLAGS / RESET
  // ===========================================================================

  void setStorageSufficient(bool value) {
    if (_isStorageSufficient == value) return;
    _isStorageSufficient = value;
    notifyListeners();
  }

  void setFluxMode(bool value) {
    if (_isFluxMode == value) return;
    _isFluxMode = value;
    notifyListeners();
  }

  void setExitingChat(bool value) {
    _isExitingChat = value;
    if (value) {
      _lastExitedModel = _selectedModel;
    } else {
      _lastExitedModel = null;
    }
    notifyListeners();
  }

  void resetForLogout() {
    _selectedModel = null;
    _pendingModelId = null;
    _isUserSubscribed = false;
    _displayName = null;
    _email = null;
    _isStorageSufficient = true;
    _isFluxMode = false;
    _isExitingChat = false;
    _lastExitedModel = null;
    _isLocalModelLoaded = false;
    notifyListeners();
  }

  void setProfile({String? displayName, String? email}) {
    _displayName = displayName;
    _email = email;
    notifyListeners();
  }
}

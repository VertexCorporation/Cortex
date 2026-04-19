// lib/library/providers/details.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import '../../../../l10n/app_localizations.dart';
import '../../language.dart';
import '../../notifications/introvert.dart';
import '../../server/user.dart';
import '../backend/data/entity.dart';
import '../backend/data/service.dart';
import '../backend/download/download.dart';
import 'catalog.dart';
import 'local.dart';
import '../backend/data/defaults.dart';

/// Manages the state and business logic for the Model Detail Page.
///
/// This provider is architected to be self-contained and robust, eliminating
/// dangerous dependencies on stored `BuildContext`. It fetches and processes all
/// data for a specific model, manages UI state, and handles user interactions
/// by listening reactively to its dependencies.
class ModelDetailProvider extends ChangeNotifier {
  //================================================================================
  // Dependencies (Injected via constructor)
  //================================================================================

  final String _modelId;
  final ModelService _modelService;
  final ModelLocalStateProvider _localStateProvider;
  final UserProvider _userProvider;
  final IntrovertNotificationService _notificationService;
  final DownloadManager? _downloadManager;
  final LocaleProvider _localeProvider;

  //================================================================================
  // Public State Properties (for UI consumption)
  //================================================================================

  // --- Core Model Data ---
  ModelEntity? _mainModel;

  ModelEntity? get mainModel => _mainModel;

  ModelEntity? _currentCapabilitiesSource;

  ModelEntity? get currentCapabilitiesSource => _currentCapabilitiesSource;

  // --- Display-Ready Data ---
  String displayTitle = '';
  String displayProducer = '';
  String displayImagePath = 'assets/icons/self.svg';
  String displaySummary = '';
  String displayDescription = '';
  String displayContext = '';
  String displayModality = '';

  List<String> parsedFeatures = [];
  List<ModelEntity> availableBaseModels = [];

  // --- UI State ---
  bool isLoading = true;
  bool isButtonLocked = false;
  bool isDeleting = false;
  bool isDescriptionExpanded = false;
  bool isBaseModelPanelExpanded = false;
  bool didBaseModelChange = false;
  bool _isDisposed = false;

  // --- Selection State ---
  String? selectedBaseModelId;
  ModelEntity? selectedBaseModel;
  String? selectedVariantName;
  ModelEntity? selectedVariant;
  bool _isUserSubscribed = false;

  // --- Dynamic Getters ---
  bool get isDownloaded =>
      _localStateProvider.downloadCompleted[_modelId] ?? false;

  bool get isDownloading => _downloadManager?.isDownloading ?? false;

  bool get isPaused => _downloadManager?.isPaused ?? false;

  double get downloadProgress => _downloadManager?.progress ?? 0.0;

  bool get isPremiumModelSelected =>
      _currentCapabilitiesSource?.isPremium ?? false;

  bool get isUserCreatedModel => _mainModel?.category == 'self';

  bool get isCharacterModel =>
      _mainModel?.category == 'roleplay' || _mainModel?.category == 'self';

  bool get shouldShowPremiumWarning =>
      isPremiumModelSelected && !_isUserSubscribed;

  bool get isPluralModel =>
      _mainModel?.isServerSide == true &&
      (_mainModel?.variants?.isNotEmpty ?? false);

  //================================================================================
  // Initialization & Lifecycle
  //================================================================================

  ModelDetailProvider({
    required String modelId,
    required BuildContext context,
    required DownloadManager? downloadManager,
  })  : _modelId = modelId,
        _downloadManager = downloadManager,
        _modelService = context.read<ModelService>(),
        _localStateProvider = context.read<ModelLocalStateProvider>(),
        _userProvider = context.read<UserProvider>(),
        _localeProvider = context.read<LocaleProvider>(),
        _notificationService = context.read<IntrovertNotificationService>() {
    _initialize();
  }

  /// The main initialization sequence.
  Future<void> _initialize() async {
    dev.log("[ModelDetailProvider] Initializing for ID '$_modelId'",
        name: 'ModelDetail');

    _isUserSubscribed = _userProvider.isSubscriptionActive;

    await _loadAndProcessData();

    _downloadManager?.addListener(_onDownloadStateChanged);
    _userProvider.addListener(_onUserStatusChanged);

    isLoading = false;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// It fetches the model, loads localizations, and processes all display data.
  Future<void> _loadAndProcessData() async {
    final locale = _localeProvider.locale;
    final langCode = locale.languageCode;
    _mainModel =
        _modelService.getPreciseModelData(_modelId, langCode: langCode);

    if (_mainModel == null) {
      dev.log(
          "[ModelDetailProvider] CRITICAL: Could not load main model entity for ID '$_modelId'",
          name: 'ModelDetail');
      return;
    }

    selectedBaseModelId = _mainModel!.baseModelId;
    if (_mainModel!.variants?.isNotEmpty ?? false) {
      selectedVariantName = _mainModel!.variants!.keys.first;
    }

    availableBaseModels = _modelService.getCachedModelsSync().where((model) {
      final isCharacter =
          model.category == 'roleplay' || model.category == 'self';
      return model.isServerSide && !isCharacter;
    }).toList();

    final localizations = await AppLocalizations.delegate.load(locale);

    // Add Dynamic Chat as a base model option
    // Add Dynamic Chat as a base model option
    final dynamicModel =
        ModelEntity.fromMap(ModelDefaults.cortexDynamicChatData, langCode)
            .copyWith(
      displayTitle: localizations.alwaysBest,
      variants: {
        'cortex/auto': {
          'id': 'cortex/auto',
          'title': localizations.alwaysBest,
          'tier': 'free',
        }
      },
    );

    availableBaseModels.insert(0, dynamicModel);

    // --- DEFAULT SELECTION LOGIC ---
    // If no base model is selected (or it is null), default to 'cortex/auto' (Always Best).
    if (selectedBaseModelId == null || selectedBaseModelId!.isEmpty) {
      selectedBaseModelId = 'cortex/auto';
    }

    _processData(localizations);
  }

  @override
  void dispose() {
    _isDisposed = true;
    dev.log("[ModelDetailProvider] Disposing for ID '$_modelId'",
        name: 'ModelDetail');
    _downloadManager?.removeListener(_onDownloadStateChanged);
    _userProvider.removeListener(_onUserStatusChanged);
    super.dispose();
  }

  //================================================================================
  // Public Actions (Called by the UI)
  //================================================================================

  void toggleDescriptionExpanded() {
    isDescriptionExpanded = !isDescriptionExpanded;
    notifyListeners();
  }

  void toggleBaseModelPanelExpanded() {
    isBaseModelPanelExpanded = !isBaseModelPanelExpanded;
    notifyListeners();
  }

  Future<void> selectBaseModel(
      BuildContext context, String newBaseModelId) async {
    if (isButtonLocked) return;
    isButtonLocked = true;
    notifyListeners();

    final localizations = AppLocalizations.of(context)!;

    try {
      final langCode = localizations.localeName;
      // Only fetch precise data if it's NOT the dynamic virtual model
      if (newBaseModelId != 'dynamic') {
        _modelService.getPreciseModelData(newBaseModelId, langCode: langCode);
      }

      final success =
          await _modelService.updateBaseModel(_modelId, newBaseModelId);
      if (!success) {
        _notificationService.showNotification(
            message: localizations.anErrorOccurred,
            type: NotificationType.error);
        return;
      }

      didBaseModelChange = true;
      selectedBaseModelId = newBaseModelId;
      _processData(localizations); // Re-process all data with the new selection
    } catch (e) {
      dev.log("[ModelDetailProvider] Error changing base model: $e",
          name: 'ModelDetail');
      _notificationService.showNotification(
          message: localizations.anErrorOccurred, type: NotificationType.error);
    } finally {
      isButtonLocked = false;
      isBaseModelPanelExpanded = false;
      notifyListeners();
    }
  }

  void selectVariant(BuildContext context, String newVariantName) {
    selectedVariantName = newVariantName;
    final localizations = AppLocalizations.of(context)!;
    _processData(localizations); // Re-process data based on the new selection
    notifyListeners();
  }

  Future<bool> removeModel(BuildContext context) async {
    if (_mainModel == null) return false;

    final localizations = AppLocalizations.of(context)!;

    isDeleting = true;
    isButtonLocked = true;
    if (!_isDisposed) {
      notifyListeners();
    }

    bool success = false;
    try {
      final catalogProvider = context.read<ModelCatalogProvider>();
      success = await catalogProvider.removeModel(context, _mainModel!);
    } catch (e) {
      dev.log("[ModelDetailProvider] Error during model removal call: $e",
          name: 'ModelDetail');
      _notificationService.showNotification(
        message: localizations.anErrorOccurred,
        type: NotificationType.error,
      );
      success = false;
    } finally {
      isDeleting = false;
      isButtonLocked = false;

      if (!_isDisposed) {
        notifyListeners();
      }
    }

    return success;
  }

  //================================================================================
  // Private Logic & Listeners
  //================================================================================

  /// Reactive listener for download state changes.
  void _onDownloadStateChanged() {
    if (_isDisposed) return;
    notifyListeners();
  }

  /// Reactive listener for user subscription status changes.
  void _onUserStatusChanged() {
    if (_isDisposed) return;
    final newSubscriptionStatus = _userProvider.isSubscriptionActive;
    if (_isUserSubscribed != newSubscriptionStatus) {
      _isUserSubscribed = newSubscriptionStatus;
      dev.log(
          "[ModelDetailProvider] User subscription status changed to: $_isUserSubscribed",
          name: 'ModelDetail');
      notifyListeners();
    }
  }

  void _processData(AppLocalizations localizations) {
    if (_mainModel == null) return;
    final langCode = localizations.localeName;

    _updateSourceEntities(langCode);

    displayTitle = _mainModel!.displayTitle;
    displayImagePath = _mainModel!.imagePath ?? 'assets/icons/self.svg';
    displayProducer = _mainModel!.producer == '_USER_'
        ? localizations.you
        : _mainModel!.producer;

    _updateComputedDisplayStrings(localizations);
    parsedFeatures = _parseFeaturesData();
  }

  void _updateSourceEntities(String langCode) {
    if (_mainModel == null) return;

    if (isCharacterModel) {
      if (selectedBaseModelId != null && selectedBaseModelId!.isNotEmpty) {
        // --- LOOKUP LOGIC ---
        // 1. Try to find the model in the local available list (Includes 'dynamic')
        try {
          selectedBaseModel = availableBaseModels.firstWhere(
            (m) => m.variants?.containsKey(selectedBaseModelId) ?? false,
          );
        } catch (_) {
          // 2. If not found locally, try fetching from the service (Server-side models)
          selectedBaseModel = _modelService.getPreciseModelData(
            selectedBaseModelId!,
            langCode: langCode,
          );
        }
      } else {
        selectedBaseModel = null;
      }

      _currentCapabilitiesSource = selectedBaseModel ?? _mainModel;
    } else if (isPluralModel) {
      selectedVariant =
          (selectedVariantName != null && selectedVariantName!.isNotEmpty)
              ? _modelService.getPreciseModelData(selectedVariantName!,
                  langCode: langCode)
              : null;
      _currentCapabilitiesSource = selectedVariant ?? _mainModel;
    } else {
      _currentCapabilitiesSource = _mainModel;
    }
  }

  void _updateComputedDisplayStrings(AppLocalizations localizations) {
    if (_mainModel == null) return;

    if (isPluralModel) {
      displaySummary =
          selectedVariant?.displaySummary ?? _mainModel!.displaySummary;
      displayDescription =
          selectedVariant?.displayDescription ?? _mainModel!.displayDescription;
    } else if (isCharacterModel) {
      displaySummary = _mainModel!.displaySummary;
      displayDescription = _mainModel!.displayDescription;
      if (displaySummary.trim().isEmpty) {
        displaySummary = selectedBaseModel?.displaySummary ?? '';
      }
      if (displayDescription.trim().isEmpty) {
        displayDescription = selectedBaseModel?.displayDescription ?? '';
      }
    } else {
      displaySummary = _mainModel!.displaySummary;
      displayDescription = _mainModel!.displayDescription;
    }

    final dataEntity = _currentCapabilitiesSource ?? _mainModel;
    
    if (dataEntity?.context != null) {
      if (dataEntity!.context == '8192' || dataEntity.context == '0') {
        displayContext = '≈ 8192';
      } else {
        displayContext = dataEntity.context!;
      }
    } else {
      displayContext = '...';
    }

    displayModality = (dataEntity?.modalities['image'] == true)
        ? localizations.multimodal
        : localizations.text;
  }

  List<String> _parseFeaturesData() {
    if (_mainModel == null) return [];
    final capabilities = _currentCapabilitiesSource ?? _mainModel!;
    final features = <String>[];
    if (_mainModel!.category == 'roleplay' || _mainModel!.category == 'self') {
      features.add('roleplay');
    }
    if (!_mainModel!.isServerSide) features.add('offline');
    if (isPluralModel) features.add('plural');
    
    // Modalities (Input/Recognition)
    if (capabilities.modalities['image'] == true) features.add('image_recognition');
    if (capabilities.modalities['video'] == true) features.add('video_recognition');
    if (capabilities.modalities['audio'] == true) features.add('audio_recognition');
    if (capabilities.modalities['file'] == true || capabilities.modalities['document'] == true) features.add('document');
    
    // Outputs (Generation)
    if (capabilities.outputs['image'] == true) features.add('image_generation');
    if (capabilities.outputs['video'] == true) features.add('video_generation');
    if (capabilities.outputs['audio'] == true) features.add('audio_generation');
    
    if (capabilities.toolUse) features.add('tool_use');

    return features;
  }
}

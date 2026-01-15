// lib/library/providers/new.dart

import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../../../internet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../backend/data/database.dart';
import '../backend/data/entity.dart';
import '../backend/data/service.dart';
import '../utils.dart';

/// Manages the state and business logic for the model creation process.
///
/// This provider centralizes the logic for both the 'Create' (roleplay) and
/// 'Add' (offline) screens. It replaces the need for a singleton cache by
/// holding the form state itself. It should be provided at a level above
/// both screens to persist state during navigation between them.
class ModelCreationProvider extends ChangeNotifier {
  //================================================================================
  // Dependencies & Services
  //================================================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
      region: 'europe-west1');
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ModelService _modelService;

  //================================================================================
  // Private State Properties
  //================================================================================

  // --- Form State for BOTH screens ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController modelExplanationController = TextEditingController();
  File? _pickedImage;
  List<ModelEntity> _availableBaseModels = [];

  // --- 'Create' (Roleplay) Screen Specific State ---
  final TextEditingController aiPromptController = TextEditingController();
  String? _selectedBaseModelId;
  String? _selectedBaseModelDisplayTitle;

  // --- 'Add' (Offline) Screen Specific State ---
  File? _ggufFile;

  // --- UI & Interaction State ---
  bool _isSaving = false;
  bool _isSubscriptionLoading = true;
  int _subscriptionTier = 0; // 0: Free, 3/6: Ultra
  bool _isBaseModelPanelExpanded = false; // UI state for the dropdown
  bool _isPickerActive = false;

  // Shake animation controllers for validation feedback
  late final AnimationController nameShakeController;
  late final AnimationController summaryShakeController;

  //================================================================================
  // Public Getters for UI Consumption
  //================================================================================

  File? get pickedImage => _pickedImage;

  File? get ggufFile => _ggufFile;

  String? get selectedBaseModelId => _selectedBaseModelId;

  String? get selectedBaseModelDisplayTitle => _selectedBaseModelDisplayTitle;

  bool get isBaseModelPanelExpanded => _isBaseModelPanelExpanded;

  bool get isSaving => _isSaving;

  bool get isSubscriptionLoading => _isSubscriptionLoading;

  List<ModelEntity> get availableBaseModels => _availableBaseModels;

  bool get isCreateSaveEnabled =>
      nameController.text
          .trim()
          .isNotEmpty &&
          _selectedBaseModelId != null &&
          !_isSaving;

  bool get isAddSaveEnabled =>
      nameController.text
          .trim()
          .isNotEmpty &&
          _ggufFile != null &&
          !_isSaving;

  bool get isPickerActive => _isPickerActive;

  //================================================================================
  // Initialization & Lifecycle
  //================================================================================

  ModelCreationProvider(TickerProvider vsync,
      BuildContext context,
      List<ModelEntity> baseModels, {
        required ModelService modelService,
      }) : _modelService = modelService {
    nameShakeController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));
    summaryShakeController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));
    nameController.addListener(notifyListeners);

    _availableBaseModels = baseModels;

    // This safely initializes the default model without calling notifyListeners during a build.
    if (_selectedBaseModelId == null && baseModels.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // This code runs after the create phase is complete.
        _initializeDefaultBaseModel(context, baseModels);
        // Now it's safe to notify listeners if a change was made.
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    dev.log("[ModelCreationProvider] Disposing.", name: 'ModelCreation');
    nameController.dispose();
    summaryController.dispose();
    modelExplanationController.dispose();
    aiPromptController.dispose();
    nameShakeController.dispose();
    summaryShakeController.dispose();
    super.dispose();
  }

  Future<void> fetchUserSubscription() async {
    _isSubscriptionLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _subscriptionTier = 3; // Simulate Ultra tier
    _isSubscriptionLoading = false;
    notifyListeners();
  }

  //================================================================================
  // Public Actions (UI Callbacks)
  //================================================================================

  void toggleBaseModelPanel() {
    _isBaseModelPanelExpanded = !_isBaseModelPanelExpanded;
    notifyListeners();
  }

  void selectBaseModel(String modelId, String displayTitle) {
    _selectedBaseModelId = modelId;

    _selectedBaseModelDisplayTitle = ModelDataUtils.cleanTitle(displayTitle);
    _isBaseModelPanelExpanded = false;
    notifyListeners();
  }


  void clearCreateForm() {
    nameController.clear();
    summaryController.clear();
    aiPromptController.clear();
    modelExplanationController.clear();
    _pickedImage = null;
    _selectedBaseModelId = null;
    _selectedBaseModelDisplayTitle = null;
    notifyListeners();
  }

  void clearAddForm() {
    nameController.clear();
    summaryController.clear();
    modelExplanationController.clear();
    _pickedImage = null;
    _ggufFile = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    if (_isPickerActive) return;

    try {
      _isPickerActive = true;
      notifyListeners();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
      }
    } finally {
      _isPickerActive = false;
      notifyListeners();
    }
  }

  void removeImage() {
    _pickedImage = null;
    notifyListeners();
  }

  /// Picks a file from the device storage.
  Future<void> pickGgufFile(BuildContext context) async {
    if (_isPickerActive) return;

    final notificationService = Provider.of<IntrovertNotificationService>(
        context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final ggufErrorMessage = localizations.errorGGUF;

    try {
      _isPickerActive = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (filePath.toLowerCase().endsWith('.gguf')) {
          _ggufFile = File(filePath);
        } else {
          notificationService.showNotification(
              message: ggufErrorMessage, type: NotificationType.error);
        }
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'already_active') {
        dev.log(
            "[ModelCreationProvider] File picker already active. Ignoring double tap.",
            name: 'ModelCreation');
      } else {
        dev.log("[ModelCreationProvider] Error picking file: $e",
            name: 'ModelCreation');
        notificationService.showNotification(
            message: localizations.anErrorOccurred,
            type: NotificationType.error);
      }
    } finally {
      _isPickerActive = false;
      notifyListeners();
    }
  }

  //================================================================================
  // Core Business Logic: Saving Models
  //================================================================================

  /// Saves a new roleplay (server-side logic) model.
  /// This method performs server-side authorization before saving locally.
  Future<bool> saveRoleplayModel(BuildContext context) async {
    if (!isCreateSaveEnabled) return false;

    _isSaving = true;
    notifyListeners();

    final localizations = AppLocalizations.of(context)!;
    final notificationService = Provider.of<IntrovertNotificationService>(
        context, listen: false);
    final internetService = InternetService();
    final user = _auth.currentUser;

    if (!internetService.currentStatus || user == null) {
      notificationService.showNotification(
          message: localizations.noInternetConnection,
          type: NotificationType.success);
      _isSaving = false;
      notifyListeners();
      return false;
    }

    final modelId = 'self_${user.uid}_${DateTime
        .now()
        .millisecondsSinceEpoch}';

    try {
      dev.log(
          "[ModelCreationProvider] Authorizing roleplay model with server...",
          name: "ModelCreation");
      final String? base64Image = await _imageFileToBase64(_pickedImage);

      // --- STEP 1: Server-Side Authorization & Moderation ---
      final HttpsCallable authCallable = _functions.httpsCallable(
        'createCustomModel',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );

      await authCallable.call({
        'modelType': 'roleplay',
        'name': nameController.text.trim(),
        'summary': summaryController.text.trim(),
        'description': modelExplanationController.text.trim(),
        'prompt': aiPromptController.text.trim(),
        'base64Image': base64Image,
        'clientModelId': modelId,
      });

      dev.log(
          "[ModelCreationProvider] Server authorization successful. Saving to local DB.",
          name: "ModelCreation");

      // --- STEP 2: Persist Image to App Documents ---
      // We must copy the image from the temporary cache (ImagePicker) to the
      // app's permanent storage, otherwise the OS will delete it later.
      String? permanentImagePath;
      if (_pickedImage != null) {
        try {
          final appDocsDir = await getApplicationDocumentsDirectory();
          final userModelsDir = Directory(
              p.join(appDocsDir.path, 'user_models', modelId));

          if (!await userModelsDir.exists()) {
            await userModelsDir.create(recursive: true);
          }

          final fileName = p.basename(_pickedImage!.path);
          final permanentFile = await _pickedImage!.copy(
              p.join(userModelsDir.path, fileName));
          permanentImagePath = permanentFile.path;

          dev.log(
              "[ModelCreationProvider] Image copied to persistent storage: $permanentImagePath",
              name: "ModelCreation");
        } catch (e) {
          dev.log(
              "[ModelCreationProvider] Failed to copy image to permanent storage. Fallback to temp path: $e",
              name: "ModelCreation");
          permanentImagePath = _pickedImage?.path;
        }
      }

      // --- STEP 3: Local Database Creation ---
      // This only runs if the server call succeeds.
      final Map<String, dynamic> modelData = {
        'id': modelId,
        'title': nameController.text.trim(),
        'summary': summaryController.text.trim(),
        'description': modelExplanationController.text.trim(),
        'role': aiPromptController.text.trim(),
        'baseModelId': _selectedBaseModelId,
        'imagePath': permanentImagePath, // Use the permanent path here
        'type': 'roleplay',
        'category': 'self',
        'producer': '_USER_',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insert('models', {
        'id': modelId,
        'producer': modelData['producer'],
        'title': modelData['title'],
        'is_server_side': 0, // Custom models are managed locally
        'type': modelData['type'],
        'raw_json': json.encode(modelData),
      },
        conflictAlgorithm: ConflictAlgorithm.replace,
        userId: user.uid,
      );

      // --- STEP 4: Update In-Memory State ---
      _modelService.addModelToEntityCache(
          ModelEntity.fromMap(modelData, localizations.localeName));
      notificationService.showNotification(
          message: localizations.modelCreatedSuccess,
          type: NotificationType.success);
      clearCreateForm();
      return true;
    } on FirebaseFunctionsException catch (e) {
      dev.log("[ModelCreationProvider] Firebase Functions Error: ${e.code} - ${e
          .message}", name: "ModelCreation");
      String errorMessage = e.message ?? localizations.anErrorOccurred;

      if (e.code == 'deadline-exceeded') {
        errorMessage = localizations.anErrorOccurred;
      }
      if (e.code == 'resource-exhausted') {
        errorMessage = localizations.errorRateLimit;
      }
      if (e.code == 'invalid-argument') {
        errorMessage = localizations.errorContentFlagged;
      }
      if (e.code == 'permission-denied') nameShakeController.forward(from: 0.0);

      notificationService.showNotification(
          message: errorMessage, type: NotificationType.error);
      return false;
    } catch (e) {
      dev.log(
          "[ModelCreationProvider] Unexpected error saving roleplay model: $e",
          name: "ModelCreation", error: e);
      notificationService.showNotification(
          message: localizations.errorCreatingModel,
          type: NotificationType.error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Saves a new offline (GGUF) model.
  /// This method copies user-selected files to permanent storage and saves locally.
  Future<bool> saveOfflineModel(BuildContext context) async {
    if (!isAddSaveEnabled) return false;

    final localizations = AppLocalizations.of(context)!;
    final notificationService = Provider.of<IntrovertNotificationService>(
        context, listen: false);
    final user = _auth.currentUser;

    if (user == null) return false;

    if (![3, 6].contains(_subscriptionTier)) {
      notificationService.showNotification(
          message: localizations.ultraFeatureOnly,
          type: NotificationType.error);
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final modelId = 'local_${user.uid}_${DateTime
          .now()
          .millisecondsSinceEpoch}';

      // --- STEP 1: Copy files to permanent app storage ---
      // This prevents data loss if the system clears the cache where picked files reside.
      final appDocsDir = await getApplicationDocumentsDirectory();
      final userModelsDir = Directory(
          p.join(appDocsDir.path, 'user_models', modelId));
      await userModelsDir.create(recursive: true);

      // Copy GGUF file
      final ggufFileName = p.basename(_ggufFile!.path);
      final permanentGgufFile = await _ggufFile!.copy(
          p.join(userModelsDir.path, ggufFileName));

      // Copy Image file (if provided)
      String? permanentImagePath;
      if (_pickedImage != null) {
        final imageFileName = p.basename(_pickedImage!.path);
        final permanentImageFile = await _pickedImage!.copy(
            p.join(userModelsDir.path, imageFileName));
        permanentImagePath = permanentImageFile.path;
      }

      dev.log(
          "[ModelCreationProvider] Copied offline model files to ${userModelsDir
              .path}", name: "ModelCreation");

      // --- STEP 2: Local Database Creation ---
      final Map<String, dynamic> modelData = {
        'id': modelId,
        'title': nameController.text.trim(),
        'summary': summaryController.text.trim(),
        'description': modelExplanationController.text.trim(),
        'imagePath': permanentImagePath,
        'ggufPath': permanentGgufFile.path, // Store the permanent path
        'type': 'offline',
        'category': 'self',
        'producer': '_USER_',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insert('models', {
        'id': modelId,
        'producer': modelData['producer'],
        'title': modelData['title'],
        'is_server_side': 0,
        'type': modelData['type'],
        'raw_json': json.encode(modelData),
      },
        conflictAlgorithm: ConflictAlgorithm.replace,
        userId: user.uid,
      );

      // --- STEP 3: Update In-Memory State ---
      _modelService.addModelToEntityCache(
          ModelEntity.fromMap(modelData, localizations.localeName));
      notificationService.showNotification(
          message: localizations.modelCreatedSuccess,
          type: NotificationType.success);
      clearAddForm();
      return true;
    } catch (e) {
      dev.log(
          "[ModelCreationProvider] Unexpected error saving offline model: $e",
          name: "ModelCreation", error: e);
      notificationService.showNotification(
          message: localizations.errorCreatingModel,
          type: NotificationType.error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  //================================================================================
  // Private Helper Methods
  //================================================================================

  /// Sets a default base model when the provider is first created.
  void _initializeDefaultBaseModel(BuildContext context,
      List<ModelEntity> availableBaseModels) {
    final modelMaps = availableBaseModels.map((e) => e.toMap()).toList();
    final defaultId = _modelService.findDefaultBaseModel(modelMaps);

    if (defaultId != null) {
      final langCode = Localizations
          .localeOf(context)
          .languageCode;
      final modelEntity = _modelService.getPreciseModelData(
          defaultId, langCode: langCode);

      _selectedBaseModelId = defaultId;

      String displayTitle = modelEntity.displayTitle;
      _selectedBaseModelDisplayTitle = ModelDataUtils.cleanTitle(displayTitle);
    }
  }


  /// Converts an image file to a base64 data URL string for JSON transport.
  Future<String?> _imageFileToBase64(File? imageFile) async {
    if (imageFile == null) return null;
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      // Using a generic image type is sufficient for the server.
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      dev.log("Error converting image to base64: $e", name: "ModelCreation");
      return null;
    }
  }
}
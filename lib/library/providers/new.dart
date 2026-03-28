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
import '../backend/data/defaults.dart';
import '../backend/data/service.dart';
import '../utils.dart';

class ModelCreationProvider extends ChangeNotifier {
  //================================================================================
  // Dependencies & Services
  //================================================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ModelService _modelService;

  //================================================================================
  // Private State Properties
  //================================================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController modelExplanationController =
      TextEditingController();
  File? _pickedImage;
  List<ModelEntity> _availableBaseModels = [];

  final TextEditingController aiPromptController = TextEditingController();
  String? _selectedBaseModelId;
  String? _selectedBaseModelDisplayTitle;

  File? _ggufFile;

  bool _isSaving = false;
  bool _isSubscriptionLoading = true;
  int _subscriptionTier = 0;
  bool _isBaseModelPanelExpanded = false;
  bool _isPickerActive = false;

  late final AnimationController nameShakeController;
  late final AnimationController summaryShakeController;

  //================================================================================
  // Public Getters
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
      nameController.text.trim().isNotEmpty &&
      _selectedBaseModelId != null &&
      !_isSaving;

  bool get isAddSaveEnabled =>
      nameController.text.trim().isNotEmpty && _ggufFile != null && !_isSaving;

  bool get isPickerActive => _isPickerActive;

  //================================================================================
  // Initialization & Lifecycle
  //================================================================================

  ModelCreationProvider(
    TickerProvider vsync,
    List<ModelEntity> baseModels, {
    required ModelService modelService,
    required String localeName,
    required AppLocalizations localizations,
  }) : _modelService = modelService {
    // Initialize Animation Controllers
    nameShakeController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));
    summaryShakeController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));

    nameController.addListener(notifyListeners);

    // --- SYNCHRONOUS INITIALIZATION ---
    // Instead of using context to get localizations later, use the passed values immediately.

    // 1. Prepare Dynamic Chat Model
    final dynamicModel =
        ModelEntity.fromMap(ModelDefaults.cortexDynamicChatData, localeName)
            .copyWith(
      displayTitle: localizations.alwaysBest,
      variants: {
        'dynamic': {
          'id': 'dynamic',
          'title': localizations.alwaysBest,
          'tier': 'free',
        }
      },
    );

    _availableBaseModels = List.from(baseModels);
    _availableBaseModels.insert(0, dynamicModel);

    // 2. Set Default Base Model (Synchronously)
    // This avoids calling notifyListeners() inside the constructor/create phase.
    if (_selectedBaseModelId == null && _availableBaseModels.isNotEmpty) {
      _initializeDefaultBaseModelSync(localeName);
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
    _subscriptionTier = 3;
    _isSubscriptionLoading = false;
    notifyListeners();
  }

  //================================================================================
  // Public Actions
  //================================================================================

  void toggleBaseModelPanel() {
    _isBaseModelPanelExpanded = !_isBaseModelPanelExpanded;
    notifyListeners();
  }

  void selectBaseModel(String modelId, String displayTitle) {
    _selectedBaseModelId = modelId;
    // Find the parent series to get the series title (not variant title)
    final parentSeries = _availableBaseModels.firstWhere(
      (series) => series.variants?.containsKey(modelId) ?? false,
      orElse: () => _availableBaseModels.first,
    );
    _selectedBaseModelDisplayTitle =
        ModelDataUtils.cleanTitle(parentSeries.displayTitle);
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

  Future<void> pickGgufFile(BuildContext context) async {
    if (_isPickerActive) return;

    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

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
              message: localizations.errorGGUF, type: NotificationType.error);
        }
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'already_active') {
        // Ignore
      } else {
        notificationService.showNotification(
            message: localizations.anErrorOccurred,
            type: NotificationType.error);
      }
    } finally {
      _isPickerActive = false;
      notifyListeners();
    }
  }

  Future<bool> saveRoleplayModel(BuildContext context) async {
    if (!isCreateSaveEnabled) return false;

    _isSaving = true;
    notifyListeners();

    final localizations = AppLocalizations.of(context)!;
    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
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

    final modelId = 'self_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final String? base64Image = await _imageFileToBase64(_pickedImage);

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

      String? permanentImagePath;
      if (_pickedImage != null) {
        try {
          final appDocsDir = await getApplicationDocumentsDirectory();
          final userModelsDir =
              Directory(p.join(appDocsDir.path, 'user_models', modelId));

          if (!await userModelsDir.exists()) {
            await userModelsDir.create(recursive: true);
          }
          final fileName = p.basename(_pickedImage!.path);
          final permanentFile =
              await _pickedImage!.copy(p.join(userModelsDir.path, fileName));
          permanentImagePath = permanentFile.path;
        } catch (e) {
          permanentImagePath = _pickedImage?.path;
        }
      }

      final Map<String, dynamic> modelData = {
        'id': modelId,
        'title': nameController.text.trim(),
        'summary': summaryController.text.trim(),
        'description': modelExplanationController.text.trim(),
        'role': aiPromptController.text.trim(),
        'baseModelId': _selectedBaseModelId,
        'imagePath': permanentImagePath,
        'type': 'roleplay',
        'category': 'self',
        'producer': '_USER_',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insert(
        'models',
        {
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

      _modelService.addModelToEntityCache(
          ModelEntity.fromMap(modelData, localizations.localeName));
      notificationService.showNotification(
          message: localizations.modelCreatedSuccess,
          type: NotificationType.success);
      clearCreateForm();
      return true;
    } on FirebaseFunctionsException catch (e) {
      String errorMessage = e.message ?? localizations.anErrorOccurred;
      if (e.code == 'resource-exhausted') {
        errorMessage = localizations.errorRateLimit;
      }
      if (e.code == 'invalid-argument') {
        errorMessage = localizations.errorContentFlagged;
      }
      if (e.code == 'permission-denied') {
        nameShakeController.forward(from: 0.0);
      }
      notificationService.showNotification(
          message: errorMessage, type: NotificationType.error);
      return false;
    } catch (e) {
      notificationService.showNotification(
          message: localizations.errorCreatingModel,
          type: NotificationType.error);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveOfflineModel(BuildContext context) async {
    if (!isAddSaveEnabled) return false;

    final localizations = AppLocalizations.of(context)!;
    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
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
      final modelId =
          'local_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      final appDocsDir = await getApplicationDocumentsDirectory();
      final userModelsDir =
          Directory(p.join(appDocsDir.path, 'user_models', modelId));
      await userModelsDir.create(recursive: true);

      final ggufFileName = p.basename(_ggufFile!.path);
      final permanentGgufFile =
          await _ggufFile!.copy(p.join(userModelsDir.path, ggufFileName));

      String? permanentImagePath;
      if (_pickedImage != null) {
        final imageFileName = p.basename(_pickedImage!.path);
        final permanentImageFile =
            await _pickedImage!.copy(p.join(userModelsDir.path, imageFileName));
        permanentImagePath = permanentImageFile.path;
      }

      final Map<String, dynamic> modelData = {
        'id': modelId,
        'title': nameController.text.trim(),
        'summary': summaryController.text.trim(),
        'description': modelExplanationController.text.trim(),
        'imagePath': permanentImagePath,
        'ggufPath': permanentGgufFile.path,
        'type': 'offline',
        'category': 'self',
        'producer': '_USER_',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insert(
        'models',
        {
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

      _modelService.addModelToEntityCache(
          ModelEntity.fromMap(modelData, localizations.localeName));
      notificationService.showNotification(
          message: localizations.modelCreatedSuccess,
          type: NotificationType.success);
      clearAddForm();
      return true;
    } catch (e) {
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
  // Helpers
  //================================================================================

  void _initializeDefaultBaseModelSync(String langCode) {
    // Default to 'dynamic' (cortex/auto) which is the Dynamic Chat / AlwaysBest option
    if (_availableBaseModels.isNotEmpty) {
      final dynamicModel = _availableBaseModels.firstWhere(
        (m) => m.variants?.containsKey('dynamic') ?? false,
        orElse: () => _availableBaseModels.first,
      );
      _selectedBaseModelId = 'dynamic';
      _selectedBaseModelDisplayTitle =
          ModelDataUtils.cleanTitle(dynamicModel.displayTitle);
    }
  }

  Future<String?> _imageFileToBase64(File? imageFile) async {
    if (imageFile == null) return null;
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      return null;
    }
  }
}

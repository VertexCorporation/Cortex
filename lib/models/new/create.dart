// create.dart

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/main.dart';
import 'package:cortex/models/new/add.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mime/mime.dart';
import 'package:sqflite/sqflite.dart';

import '../../darkener.dart';
import '../../internet.dart';
import '../../notifications.dart';
import '../../theme.dart';
import '../backend/data.dart';

/// A singleton cache to preserve form state between the Add and Create screens.
/// This solves the data loss issue when using `pushReplacement` for navigation.
class ModelCreationCache {
  static final ModelCreationCache _instance = ModelCreationCache._internal();
  factory ModelCreationCache() => _instance;
  ModelCreationCache._internal();

  // Create screen data
  String createName = '';
  String createSummary = '';
  String createAiPrompt = '';
  String createModelExplanation = '';
  File? createPickedImage;
  String? createSelectedBaseModelId;
  String? createSelectedBaseModelDisplayTitle;

  // Add screen data
  String addName = '';
  String addSummary = '';
  String addAiPrompt = '';
  String addModelExplanation = '';
  File? addPickedImage;
  File? addGgufFile;

  void clearCreateData() {
    createName = '';
    createSummary = '';
    createAiPrompt = '';
    createModelExplanation = '';
    createPickedImage = null;
    createSelectedBaseModelId = null;
    createSelectedBaseModelDisplayTitle = null;
  }

  void clearAddData() {
    addName = '';
    addSummary = '';
    addAiPrompt = '';
    addModelExplanation = '';
    addPickedImage = null;
    addGgufFile = null;
  }
}


class CreateScreen extends StatefulWidget {
  final List<Map<String, dynamic>> availableBaseModels;

  const CreateScreen({
    Key? key,
    required this.availableBaseModels
  }) : super(key: key);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> with TickerProviderStateMixin {
  final _cache = ModelCreationCache();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _summaryController;
  late final TextEditingController _aiPromptController;
  late final TextEditingController _modelExplanationController;

  // State
  File? _pickedImage;
  String? _selectedBaseModelId;
  String? _selectedBaseModelDisplayTitle;
  bool _isBaseModelPanelExpanded = false;
  bool _isSaving = false;
  // NOTE: _hasCortexSubscription is kept for potential future use or consistency, but not used for navigation logic anymore.
  int _hasCortexSubscription = 0;

  // Shake animations
  late AnimationController _nameShakeController;
  late AnimationController _summaryShakeController;

  bool get _isSaveEnabled =>
      _nameController.text.trim().isNotEmpty &&
          _selectedBaseModelId != null &&
          !_isSaving;

  bool _isSubscriptionLoading = true;

  @override
  void initState() {
    super.initState();
    // (Most of initState is unchanged)
    _nameShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _summaryShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _nameController = TextEditingController(text: _cache.createName);
    _summaryController = TextEditingController(text: _cache.createSummary);
    _aiPromptController = TextEditingController(text: _cache.createAiPrompt);
    _modelExplanationController = TextEditingController(text: _cache.createModelExplanation);
    _pickedImage = _cache.createPickedImage;
    _selectedBaseModelId = _cache.createSelectedBaseModelId;
    _selectedBaseModelDisplayTitle = _cache.createSelectedBaseModelDisplayTitle;
    _nameController.addListener(() { _cache.createName = _nameController.text; if (mounted) setState(() {}); });
    _summaryController.addListener(() => _cache.createSummary = _summaryController.text);
    _aiPromptController.addListener(() => _cache.createAiPrompt = _aiPromptController.text);
    _modelExplanationController.addListener(() => _cache.createModelExplanation = _modelExplanationController.text);

    // This now uses the passed-in data, which is guaranteed to be available.
    if (_selectedBaseModelId == null) {
      _initializeDefaultBaseModel();
    }

    _fetchUserSubscription();
  }

  Future<void> _fetchUserSubscription() async {
    // This method can remain to keep the UI consistent (e.g., dimming button while loading)
    // but its result (_hasCortexSubscription) is no longer used to block navigation.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isSubscriptionLoading = false);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        _hasCortexSubscription = userDoc.data()?['hasCortexSubscription'] ?? 0;
      }
    } catch (e) {
      debugPrint("Error fetching user subscription: $e");
    } finally {
      if (mounted) setState(() => _isSubscriptionLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _summaryController.dispose();
    _aiPromptController.dispose();
    _modelExplanationController.dispose();
    _nameShakeController.dispose();
    _summaryShakeController.dispose();
    super.dispose();
  }

// Helper function to convert an image File to a base64 data URL
  Future<String?> _imageFileToBase64(File? imageFile) async {
    if (imageFile == null) return null;
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      // Use the mime package to get the correct content type
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint("Error converting image to base64: $e");
      return null;
    }
  }

  /// This function now performs these steps:
  /// 1.  **Authorize**: Calls the `createCustomModel` Cloud Function to reserve a slot
  ///     on the server by incrementing the user's counter. This requires an internet connection.
  /// 2.  **Create Locally**: If authorization succeeds, it creates the model data and
  ///     saves it DIRECTLY to the local SQLite database. NO model data is written
  ///     to Firestore.
  /// 3.  **Recover on Failure**: If the local SQLite write fails, it immediately
  ///     calls `deleteCustomModel` to roll back the server counter, keeping the
  ///     system synchronized. This also requires an internet connection.
  ///
  Future<void> _saveModel() async {
    if (!_isSaveEnabled) return;

    if (mounted) setState(() => _isSaving = true);
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final internetService = Provider.of<InternetService>(context, listen: false);

    if (!internetService.currentStatus) {
      notificationService.showNotification(message: localizations.noInternetConnection, isSuccess: false);
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    if (user == null) {
      notificationService.showNotification(message: localizations.anErrorOccurred, isSuccess: false);
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    try {
      debugPrint("[CreateScreen] Preparing model data for authorization and moderation...");
      final String? base64Image = await _imageFileToBase64(_pickedImage);

      final authCallable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('createCustomModel');
      await authCallable.call({
        'modelType': 'roleplay',
        'name': _nameController.text.trim(),
        'summary': _summaryController.text.trim(),
        'description': _modelExplanationController.text.trim(),
        'prompt': _aiPromptController.text.trim(),
        'base64Image': base64Image,
      });

      debugPrint("[CreateScreen] Authorization successful. Proceeding with local DB creation.");

      try {
        final dbHelper = DatabaseHelper.instance;
        final modelId = 'self_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
        final String? imagePath = _pickedImage?.path;
        final Map<String, dynamic> modelData = {
          'id': modelId,
          'title': _nameController.text.trim(),
          'summary': _summaryController.text.trim(),
          'description': _modelExplanationController.text.trim(),
          'role': _aiPromptController.text.trim(),
          'baseModelId': _selectedBaseModelId,
          'imagePath': imagePath,
          'type': 'roleplay',
          'category': 'self',
          'producer': '_USER_',
          'createdAt': DateTime.now().toIso8601String(),
        };
        await dbHelper.insert('models', {
          'id': modelId, 'producer': modelData['producer'], 'title': modelData['title'],
          'is_server_side': 0, 'type': modelData['type'], 'raw_json': json.encode(modelData),
        },
          conflictAlgorithm: ConflictAlgorithm.replace,
          userId: user.uid,
        );

        debugPrint("[CreateScreen] Successfully saved new model to local SQLite DB with ID: $modelId");
        notificationService.showNotification(message: localizations.modelCreatedSuccess, isSuccess: true);
        _cache.clearCreateData();
        ModelData.addModelToCache(modelData);
        if (mounted) Navigator.pop(context, true);

      } catch (localDbError) {
        debugPrint("[CreateScreen] CRITICAL: Local SQLite write failed. Rolling back server counter. Error: $localDbError");
        notificationService.showNotification(message: localizations.errorCreatingModel, isSuccess: false);
        final rollbackCallable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('deleteCustomModel');
        await rollbackCallable.call({'modelType': 'roleplay'});
        debugPrint("[CreateScreen] Server counter successfully rolled back.");
      }

    } on FirebaseFunctionsException catch (e) {
      debugPrint("[CreateScreen] Firebase Functions Error: ${e.code} - ${e.message}");

      // --- THE FIX: Safer error handling and more specific user messages ---
      String errorMessage = e.message ?? localizations.anErrorOccurred;

      // Check for our custom error codes first.
      if (e.code == 'resource-exhausted') {
        errorMessage = localizations.errorRateLimit; // "You have created too many models recently."
      } else if (e.code == 'invalid-argument') {
        // This is our moderation error.
        errorMessage = localizations.errorContentFlagged; // "The content was flagged as inappropriate."
      } else if (e.code == 'permission-denied') {
        // This is the user limit error.
        _nameShakeController.forward(from: 0.0);
        // The default e.message is good here ("You have reached your limit...").
      }

      notificationService.showNotification(message: errorMessage, isSuccess: false);
      // --- END OF FIX ---

    } catch (e) {
      notificationService.showNotification(message: localizations.errorCreatingModel, isSuccess: false);
      debugPrint("[CreateScreen] Unexpected error during model saving process: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- THE FIX: This function now uses the guaranteed data from the widget ---
  void _initializeDefaultBaseModel() {
    // It no longer calls ModelData.getCachedModelsSync(), which was the source of the race condition.
    final allModels = widget.availableBaseModels;
    final defaultId = ModelData.findDefaultBaseModel(allModels);

    if (defaultId != null) {
      // getPreciseModelData is safe because it uses the cache, which is guaranteed to be
      // populated by the time ModelsScreen could navigate here.
      final modelData = ModelData.getPreciseModelData(defaultId);
      if (mounted) {
        setState(() {
          _selectedBaseModelId = defaultId;
          _selectedBaseModelDisplayTitle = modelData['title'] as String? ?? defaultId;
          _cache.createSelectedBaseModelId = _selectedBaseModelId;
          _cache.createSelectedBaseModelDisplayTitle = _selectedBaseModelDisplayTitle;
        });
      }
    }
  }

  // --- THE FIX: This widget also uses the guaranteed data now ---
  Widget _buildBaseModelSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    // Use the passed-in list and filter it, instead of fetching from the cache.
    final availableBaseModels = widget.availableBaseModels
        .where((model) => model['type'] == 'online' && model['extensions'] is Map && (model['extensions'] as Map).isNotEmpty)
        .toList();

    if (availableBaseModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            border: Border.all(color: AppColors.border.withOpacity(0.5))
        ),
        child: Text(
          localizations.selectBaseModel,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.038),
        ),
      );
    }

    // The rest of the widget's rendering logic is unchanged, as it now operates on a reliable list.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.baseModelTitle, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(localizations.baseModelDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        const SizedBox(height: 15),
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
          child: InkWell(
            onTap: () => setState(() => _isBaseModelPanelExpanded = !_isBaseModelPanelExpanded),
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedBaseModelDisplayTitle ?? localizations.selectBaseModel,
                      style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.04),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isBaseModelPanelExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor.inverted),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isBaseModelPanelExpanded
              ? Container(
            margin: const EdgeInsets.only(top: 8),
            height: 200,
            decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(screenWidth * 0.025)),
            child: ListView(
              children: availableBaseModels.expand<Widget>((series) {
                final extensions = series['extensions'] as Map<String, dynamic>;
                return extensions.entries.map((ext) {
                  final modelId = ext.key;
                  final modelTitle = ext.value['title'] ?? modelId;
                  final String imagePath = ModelData.getModelImagePath(series);
                  final ImageProvider imageProvider = imagePath.startsWith('assets/') ? AssetImage(imagePath) as ImageProvider : FileImage(File(imagePath));
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: imageProvider, backgroundColor: Colors.transparent),
                    title: Text(modelTitle, style: TextStyle(color: AppColors.primaryColor.inverted)),
                    onTap: () {
                      setState(() {
                        _selectedBaseModelId = modelId;
                        _selectedBaseModelDisplayTitle = modelTitle;
                        _isBaseModelPanelExpanded = false;
                        _cache.createSelectedBaseModelId = modelId;
                        _cache.createSelectedBaseModelDisplayTitle = modelTitle;
                      });
                    },
                  );
                });
              }).toList(),
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _pickedImage = File(pickedFile.path);
          _cache.createPickedImage = _pickedImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    // This wrapper prevents back navigation and blocks UI touches when saving.
    return WillPopScope(
      onWillPop: () async => !_isSaving,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(localizations.create, style: TextStyle(color: AppColors.primaryColor.inverted)),
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.primaryColor.inverted),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // Disable the back button if saving.
              onPressed: _isSaving ? null : () => Navigator.pop(context),
            ),
            actions: [
              Opacity(
                opacity: _isSubscriptionLoading || _isSaving ? 0.5 : 1.0,
                child: IconButton(
                  icon: SvgPicture.asset('assets/icons/transition.svg', width: screenWidth * 0.06, height: screenWidth * 0.06, color: AppColors.primaryColor.inverted),
                  // Disable the transition button if loading or saving.
                  onPressed: (_isSubscriptionLoading || _isSaving) ? null : () async {
                    final bool? shouldPopImmediately = await Navigator.push<bool>(
                      context,
                      FadeRoute(page: const AddScreen()),
                    );
                    if (shouldPopImmediately == true && mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildBaseModelSection(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildAiPromptSection(),
                  SizedBox(height: screenHeight * 0.02),
                  _buildModelExplanationSection(),
                ],
              ),
            ),
          ),
            bottomNavigationBar: SafeArea(
            top: false,
    right: false,
    left: false,
    child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, -2))],
              borderRadius: BorderRadius.only(topLeft: Radius.circular(screenWidth * 0.05), topRight: Radius.circular(screenWidth * 0.05)),
            ),
            child: AnimatedOpacity(
              opacity: _isSaveEnabled ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Disable button when not enabled or while saving.
                  onPressed: _isSaveEnabled ? _saveModel : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return AppColors.senaryColor.withOpacity(0.5);
                        }
                        return AppColors.senaryColor;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: screenHeight * 0.015)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03))),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : FittedBox(fit: BoxFit.scaleDown, child: Text(localizations.save, maxLines: 1, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ),
            ),
        ),
      ),
    );
  }

  // --- OMITTED WIDGETS FOR BREVITY, NO CHANGES WERE MADE TO THEM ---
  // _buildProfileHeader, _confirmRemovePhoto, _buildConfirmationDialog,
  // _buildDialogButton, _buildBaseModelSection, _buildAiPromptSection,
  // _buildModelExplanationSection are identical to your original code.
  // I'm including them here so you can copy-paste the whole file.

  Widget _buildProfileHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    double avatarSize = screenWidth * 0.3;
    double spacing = screenWidth * 0.02;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImageFromGallery,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: avatarSize / 2.2,
                  backgroundColor: AppColors.secondaryColor,
                  backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                  child: _pickedImage == null ? Icon(Icons.broken_image, size: avatarSize / 2.5, color: AppColors.primaryColor.inverted) : null,
                ),
                Positioned(
                  top: 4, left: 4,
                  child: GestureDetector(
                    onTap: _pickedImage == null ? _pickImageFromGallery : _confirmRemovePhoto,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      opacity: 1.0,
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        turns: _pickedImage == null ? 0.0 : 0.121,
                        child: SvgPicture.asset('assets/icons/plus.svg', width: avatarSize * 0.2, height: avatarSize * 0.2, color: AppColors.primaryColor.inverted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: spacing / 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: (avatarSize - spacing) / 1.5,
                  child: ShakeWidget(
                    controller: _nameShakeController,
                    child: TextField(
                      controller: _nameController,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9çÇğĞıİöÖşŞüÜ\s]'))],
                      style: TextStyle(color: AppColors.primaryColor.inverted),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.nameLabel,
                        labelStyle: TextStyle(color: AppColors.primaryColor.inverted),
                        filled: true,
                        fillColor: AppColors.primaryColor,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: (avatarSize - spacing) / 1.5,
                  child: TextField(
                    controller: _summaryController,
                    maxLength: 40,
                    style: TextStyle(color: AppColors.primaryColor.inverted),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.summaryLabel,
                      labelStyle: TextStyle(color: AppColors.primaryColor.inverted),
                      filled: true,
                      fillColor: AppColors.primaryColor,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmRemovePhoto() async {
    final localizations = AppLocalizations.of(context)!;

    final restoreNavBar = Darkener.darken();

    final bool? confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'RemovePhoto',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) => _buildConfirmationDialog(ctx, localizations),
      transitionBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    );

    restoreNavBar();

    if (confirm == true) {
      if (mounted) {
        setState(() {
          _pickedImage = null;
          _cache.createPickedImage = null;
        });
      }
    }
  }

  Widget _buildConfirmationDialog(BuildContext ctx, AppLocalizations localizations) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.8,
          decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(localizations.removePhotoTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(localizations.confirmRemovePhoto, style: TextStyle(color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildDialogButton(ctx, localizations.cancel, AppColors.senaryColor, () => Navigator.of(ctx).pop(false)),
                      VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                      _buildDialogButton(ctx, localizations.remove, AppColors.septenaryColor, () => Navigator.of(ctx).pop(true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(BuildContext ctx, String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.1),
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(text, style: TextStyle(color: color, fontSize: 16), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _buildAiPromptSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.preInputTitle, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
        SizedBox(height: screenHeight * 0.005),
        Text(AppLocalizations.of(context)!.preInputDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        SizedBox(height: screenHeight * 0.02),
        TextField(
          controller: _aiPromptController,
          maxLength: 200,
          style: TextStyle(color: AppColors.primaryColor.inverted),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.preInputTitle,
            hintStyle: TextStyle(color: AppColors.quinaryColor),
            filled: true,
            fillColor: AppColors.primaryColor,
            counterText: '',
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
          ),
        ),
      ],
    );
  }

  Widget _buildModelExplanationSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.aiExplanationTitle, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
        SizedBox(height: screenHeight * 0.005),
        Text(AppLocalizations.of(context)!.aiExplanationDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        SizedBox(height: screenHeight * 0.02),
        TextField(
          controller: _modelExplanationController,
          maxLength: 1000,
          style: TextStyle(color: AppColors.primaryColor.inverted),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.aiExplanationTitle,
            hintStyle: TextStyle(color: AppColors.quinaryColor),
            filled: true,
            fillColor: AppColors.primaryColor,
            counterText: '',
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
          ),
        ),
      ],
    );
  }
}

// Dummy ShakeWidget to prevent compilation errors.
class ShakeWidget extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  const ShakeWidget({Key? key, required this.child, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) => child;
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
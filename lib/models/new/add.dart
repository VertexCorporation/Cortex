// add.dart

import 'dart:convert';
import 'dart:io';
import 'package:cortex/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path/path.dart' as path;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../../darkener.dart';
import '../../internet.dart';
import '../../notifications.dart';
import '../../theme.dart';
import '../backend/utils.dart';
import 'create.dart';
import '../backend/data.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> with TickerProviderStateMixin {
  final _cache = ModelCreationCache();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _summaryController;
  late final TextEditingController _aiPromptController;
  late final TextEditingController _modelExplanationController;
  late final TextEditingController _serverLinkController; // For "Coming Soon" section

  // State
  File? _pickedImage;
  File? _ggufFile;
  bool _showServerSection = true;
  bool _isSaving = false;

  // ADDED: State for subscription check
  int _hasCortexSubscription = 0;
  bool _isSubscriptionLoading = true;

  // Shake animations
  late AnimationController _nameShakeController;
  late AnimationController _summaryShakeController;

  // UPDATED: Save is also disabled while subscription status is loading
  bool get _isSaveEnabled =>
      _nameController.text.trim().isNotEmpty &&
          _pickedImage != null &&
          _ggufFile != null &&
          !_isSaving &&
          !_isSubscriptionLoading;

  @override
  void initState() {
    super.initState();
    _nameShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _summaryShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _serverLinkController = TextEditingController();

    // Load state from cache
    _nameController = TextEditingController(text: _cache.addName);
    _summaryController = TextEditingController(text: _cache.addSummary);
    _aiPromptController = TextEditingController(text: _cache.addAiPrompt);
    _modelExplanationController = TextEditingController(text: _cache.addModelExplanation);
    _pickedImage = _cache.addPickedImage;
    _ggufFile = _cache.addGgufFile;
    _showServerSection = _ggufFile == null;

    // Add listeners to save state to cache on change
    _nameController.addListener(() {
      _cache.addName = _nameController.text;
      if (mounted) setState(() {});
    });
    _summaryController.addListener(() => _cache.addSummary = _summaryController.text);
    _aiPromptController.addListener(() => _cache.addAiPrompt = _aiPromptController.text);
    _modelExplanationController.addListener(() => _cache.addModelExplanation = _modelExplanationController.text);

    // ADDED: Fetch subscription status when screen initializes
    _fetchUserSubscription();
  }

  // ADDED: Method to fetch subscription status from Firestore
  Future<void> _fetchUserSubscription() async {
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
      debugPrint("Error fetching user subscription on AddScreen: $e");
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
    _serverLinkController.dispose();
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
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint("Error converting image to base64: $e");
      return null;
    }
  }

  Future<void> _saveModel() async {
    final localizations = AppLocalizations.of(context)!;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final internetService = Provider.of<InternetService>(context, listen: false);

    if (!internetService.currentStatus) {
      notificationService.showNotification(message: localizations.noInternetConnection, isSuccess: false);
      return;
    }
    final bool isUltra = [3, 6].contains(_hasCortexSubscription);
    if (!isUltra) {
      notificationService.showNotification(message: localizations.ultraFeatureOnly, isSuccess: false);
      return;
    }
    if (!_isSaveEnabled) return;

    if (mounted) setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      notificationService.showNotification(message: localizations.anErrorOccurred, isSuccess: false);
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    File? finalGgufFile;
    String? modelId;
    final dbHelper = DatabaseHelper.instance;

    try {
      debugPrint("[AddScreen] Starting background file copy...");
      final appDir = await getApplicationDocumentsDirectory();
      final ggufFileName = path.basename(_ggufFile!.path);
      final destinationPath = path.join(appDir.path, ggufFileName);

      final copiedFilePath = await compute(copyFileInIsolate, {
        'sourcePath': _ggufFile!.path,
        'destPath': destinationPath,
      });
      finalGgufFile = File(copiedFilePath);
      debugPrint("[AddScreen] File copy successful. Path: ${finalGgufFile.path}");

      modelId = 'local_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      final Map<String, dynamic> modelData = {
        'id': modelId,
        'title': _nameController.text.trim(),
        'summary': _summaryController.text.trim(),
        'description': _modelExplanationController.text.trim(),
        'imagePath': _pickedImage?.path,
        'path': finalGgufFile.path,
        'type': 'offline',
        'category': 'self',
        'producer': '_USER_',
        'createdAt': DateTime.now().toIso8601String(),
      };
      await dbHelper.insert('models', {
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
      debugPrint("[AddScreen] Successfully saved model to local DB with ID: $modelId. Now contacting server.");

      final String? base64Image = await _imageFileToBase64(_pickedImage);
      final authCallable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('createCustomModel');
      await authCallable.call({
        'modelType': 'offline',
        'name': _nameController.text.trim(),
        'summary': _summaryController.text.trim(),
        'description': _modelExplanationController.text.trim(),
        'prompt': '',
        'base64Image': base64Image,
      });
      debugPrint("[AddScreen] Server authorization successful. Process complete.");

      notificationService.showNotification(message: localizations.modelCreatedSuccess, isSuccess: true);
      _cache.clearAddData();
      ModelData.addModelToCache(modelData);
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      debugPrint("[AddScreen] An error occurred during the save process: $e");

      if (finalGgufFile != null && await finalGgufFile.exists()) {
        await finalGgufFile.delete();
        debugPrint("[AddScreen] Rollback: Deleted copied file.");
      }
      if (modelId != null) {
        await dbHelper.delete('models', where: 'id = ?', whereArgs: [modelId]);
        debugPrint("[AddScreen] Rollback: Deleted DB entry.");
      }

      String errorMessage = localizations.errorCreatingModel;
      if (e is FirebaseFunctionsException) {
        if (e.code == 'resource-exhausted') {
          errorMessage = localizations.errorRateLimit;
        } else if (e.code == 'invalid-argument') {
          errorMessage = localizations.errorContentFlagged;
        } else {
          errorMessage = e.message ?? localizations.anErrorOccurred;
        }
      }
      notificationService.showNotification(message: errorMessage, isSuccess: false, oneLine: false);

    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _pickedImage = File(pickedFile.path);
          _cache.addPickedImage = _pickedImage;
        });
      }
    }
  }

  Future<void> _pickGgufFile() async {
    final localizations = AppLocalizations.of(context)!;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath != null && filePath.toLowerCase().endsWith('.gguf')) {
        if (mounted) {
          setState(() {
            _ggufFile = File(filePath);
            _cache.addGgufFile = _ggufFile;
            _showServerSection = false;
          });
        }
      } else {
        notificationService.showNotification(message: localizations.errorGGUF, isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // This wrapper prevents back navigation and blocks UI touches when saving.
    return WillPopScope(
      onWillPop: () async => !_isSaving,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(AppLocalizations.of(context)!.add, style: TextStyle(color: AppColors.primaryColor.inverted)),
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.primaryColor.inverted),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // Disable the back button if saving.
              onPressed: _isSaving ? null : () {
                Navigator.pop(context, true);
              },
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset('assets/icons/transition.svg', width: screenWidth * 0.06, height: screenWidth * 0.06, color: AppColors.primaryColor.inverted),
                // Disable the transition button if saving.
                onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                  SizedBox(height: screenHeight * 0.03),
                  _buildModelUploadSection(),
                  SizedBox(height: screenHeight * 0.03),
                  _buildAddServerSection(),
                  SizedBox(height: screenHeight * 0.03),
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
                      : FittedBox(fit: BoxFit.scaleDown, child: Text(AppLocalizations.of(context)!.save, maxLines: 1, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold))),
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
  // The rest of the build methods (_buildProfileHeader, _buildModelUploadSection, etc.)
  // are identical to your original code. I am including them for easy copy-paste.

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
          _cache.addPickedImage = null;
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

  Widget _buildModelUploadSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.modelUploadTitle, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
        SizedBox(height: screenHeight * 0.005),
        Text(AppLocalizations.of(context)!.modelUploadDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        SizedBox(height: screenHeight * 0.02),
        InkWell(
          onTap: _pickGgufFile,
          child: Container(
            width: double.infinity,
            height: screenHeight * 0.25,
            decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 2), borderRadius: BorderRadius.circular(screenWidth * 0.02)),
            child: Center(
              child: _ggufFile != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.senaryColor, size: screenWidth * 0.1),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      path.basename(_ggufFile!.path),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.035),
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/upload.svg', width: screenWidth * 0.1, height: screenWidth * 0.1, color: AppColors.primaryColor.inverted),
                  SizedBox(height: screenHeight * 0.005),
                  Text(AppLocalizations.of(context)!.modelUploadTitle, style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.04)),
                  Text(AppLocalizations.of(context)!.modelUploadShortDescription, textAlign: TextAlign.center, style: TextStyle(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
                ],
              ),
            ),
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

  Widget _buildAddServerSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedOpacity(
      opacity: _showServerSection ? 0.6 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: _showServerSection
          ? GestureDetector(
        onTap: _showComingSoonMessage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.addServerTitle, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
            SizedBox(height: screenHeight * 0.005),
            Text(AppLocalizations.of(context)!.addServerDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
            SizedBox(height: screenHeight * 0.02),
            AbsorbPointer(
              absorbing: true,
              child: TextField(
                controller: _serverLinkController,
                style: TextStyle(color: AppColors.primaryColor.inverted),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serverLink,
                  hintText: AppLocalizations.of(context)!.enterURL,
                  filled: true,
                  fillColor: AppColors.primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                ),
              ),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  void _showComingSoonMessage() {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    notificationService.showNotification(
      message: AppLocalizations.of(context)!.comingSoon,
      bottomOffset: 0.1,
      duration: const Duration(seconds: 1),
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
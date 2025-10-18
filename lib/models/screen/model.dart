// model.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cortex/main.dart';
import 'package:cortex/models/widgets/cancel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../darkener.dart';
import '../../extensions.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../funds/funds.dart';
import '../../internet.dart';
import '../../navigation.dart';
import '../../notifications.dart';
import '../../theme.dart';
import 'package:shimmer/shimmer.dart';

import '../backend/data.dart';
import '../backend/download.dart';
import '../backend/remove.dart';
import 'dart:developer' as dev;

class ModelDetailPage extends StatefulWidget {
  final String id;
  // Note: These initial properties are used only as fallbacks or for non-localized data.
  // The UI will be driven by the internal state fetched from ModelData.
  final String title;
  final String description;
  final String summary;
  final String imagePath;
  final String producer;
  final bool isDownloaded;
  final bool isDownloading;
  final CompatibilityStatus compatibilityStatus;
  final bool isServerSide;
  final Future<bool> Function()? onDownloadPressed;
  final Future<bool> Function()? onRemovePressed;
  final Future<void> Function()? onChatPressed;
  final VoidCallback? onCancelPressed;
  final DownloadManager? downloadManager;
  final String category;
  final Map<String, dynamic> modalities;
  final String context;
  final Map<String, Map<String, dynamic>>? extensions;
  final String? baseModelId;
  final int? size;
  final int? ram;
  final bool isFullyLocalized;

  const ModelDetailPage({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.size,
    required this.ram,
    required this.producer,
    required this.isDownloaded,
    required this.isDownloading,
    required this.compatibilityStatus,
    required this.isServerSide,
    this.onDownloadPressed,
    this.onRemovePressed,
    this.onChatPressed,
    this.onCancelPressed,
    this.downloadManager,
    required this.category,
    this.modalities = const {},
    this.context = '',
    this.extensions,
    required this.summary,
    this.baseModelId,
    required this.isFullyLocalized,
  }) : super(key: key ?? const ValueKey('ModelDetailPage'));

  @override
  _ModelDetailPageState createState() => _ModelDetailPageState();
}

class _ModelDetailPageState extends State<ModelDetailPage>
    with TickerProviderStateMixin {
  // --- STATE VARIABLES ---
  // We initialize all 'late' fields with safe, non-null default values.
  // This prevents any LateInitializationError, regardless of the data flow.
  Map<String, dynamic> _modelData = {};
  String _displayTitle = '';
  String _displayProducer = '';
  String _displayImagePath = 'assets/icons/self.svg'; // A safe fallback path
  bool _isFullyLocalized = true;
  bool _isDownloaded = false;
  bool _isDownloading = false;

  // --- CRITICAL FIX: Initialize all 'late' fields to prevent any errors ---
  late final AnimationController _fadeController;
  String _selectedExtensionName = ''; // Safe default
  Map<String, dynamic> _selectedExtensionData = {}; // Safe default

  // Other state variables
  bool _isButtonLocked = false;
  List<String> _parsedFeatures = [];
  Map<int, int> _starCounts = {};
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;
  bool _isDeleting = false;
  String? _selectedBaseModelId;
  Map<String, dynamic>? _selectedBaseModelData;
  bool _isBaseModelPanelExpanded = false;
  bool _didBaseModelChange = false;
  List<Map<String, dynamic>> _availableBaseModels = [];
  bool _isInitialized = false;

  bool _isPremiumModelSelected = false;
  late final AnimationController _rgbController;

  @override
  void initState() {
    super.initState();
    dev.log("[ModelDetailPage.initState] Initializing for ID '${widget.id}'", name: 'ModelDetail');

    _isDownloaded = widget.isDownloaded;
    _isDownloading = widget.isDownloading;

    dev.log("[ModelDetailPage.initState] Initial state has been set from widget props. _isDownloaded: $_isDownloaded, _isDownloading: $_isDownloading", name: 'ModelDetail');

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    widget.downloadManager?.addListener(_onDownloadStateChanged);

    _rgbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Speed of one full color cycle
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use a flag to ensure this heavy logic runs only once after initState.
    if (!_isInitialized) {
      debugPrint("[ModelDetailPage] didChangeDependencies: Performing all data setup.");
      _loadAndProcessData(); // A single, unified setup method.

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  void _loadAndProcessData() {
    dev.log("[ModelDetailPage._loadAndProcessData] Loading display data. The crucial `_isDownloaded` state is NOT changed here. It remains: $_isDownloaded", name: 'ModelDetail');
    _modelData = ModelData.getPreciseModelData(widget.id);

    final localizations = AppLocalizations.of(context)!;
    final langCode = localizations.localeName;
    _displayTitle = ModelData.getLocalizedText(_modelData, 'title', langCode);

    _displayImagePath = ModelData.getModelImagePath(_modelData);
    _isFullyLocalized = _modelData['isFullyLocalized'] as bool? ?? true;

    final rawProducer = _modelData['producer'] as String? ?? 'Unknown';
    if (rawProducer == '_USER_') {
      _displayProducer = localizations.you;
    } else {
      _displayProducer = rawProducer;
    }

    final isSelfOrRoleplay = ['self', 'roleplay'].contains((_modelData['category'] as String?)?.toLowerCase());

    Map<String, dynamic>? capabilitiesSource;
    Map<String, dynamic>? dataSourceForTierCheck; // This will hold the model data used to determine 'tier'

    // Determine the source of capabilities and the data for tier check.
    if (isSelfOrRoleplay) {
      _selectedBaseModelId = _modelData['baseModelId'] as String?;
      if (_selectedBaseModelId != null && _selectedBaseModelId!.isNotEmpty) {
        _selectedBaseModelData = ModelData.getPreciseModelData(_selectedBaseModelId!);
        capabilitiesSource = _selectedBaseModelData; // Capabilities from base model
        dataSourceForTierCheck = _selectedBaseModelData; // Tier from base model
      } else {
        // If no base model is selected for a character, its own tier isn't really relevant
        // for chat capabilities, so we default to free or main model's tier if available.
        dataSourceForTierCheck = _modelData;
      }
    } else if (_modelData['type'] == 'online' && _modelData['extensions'] is Map && (_modelData['extensions'] as Map).isNotEmpty) {
      final extensions = _modelData['extensions'] as Map<String, dynamic>;
      final firstKey = extensions.keys.first;
      _selectedExtensionName = firstKey;
      _selectedExtensionData = extensions[firstKey] ?? {};
      capabilitiesSource = _selectedExtensionData; // Capabilities from selected extension
      dataSourceForTierCheck = _selectedExtensionData; // Tier from selected extension
    } else {
      // For single online/offline models without extensions, the tier comes from the model itself
      dataSourceForTierCheck = _modelData;
    }

    // --- UPDATED: Set the premium status based on the determined data source ---
    _isPremiumModelSelected = (dataSourceForTierCheck?['tier'] as String? ?? 'free') == 'premium';
    dev.log("[ModelDetailPage._loadAndProcessData] Initial _isPremiumModelSelected: $_isPremiumModelSelected (from ID: ${dataSourceForTierCheck?['id'] ?? 'N/A'})", name: 'ModelDetail');


    // Now, call the new parse function with the correct data.
    _parsedFeatures = _parseFeaturesData(_modelData, capabilitiesSource);

    // This part remains for the UI to build the selection panel.
    _availableBaseModels = ModelData.getCachedModelsSync()
        .where((model) => model['type'] == 'online' && model['extensions'] is Map && (model['extensions'] as Map).isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _extensionOverlayEntry?.remove();
    _extensionOverlayEntry = null;
    widget.downloadManager?.removeListener(_onDownloadStateChanged);
    _fadeController.dispose();
    _extensionOverlayController?.dispose();
    _rgbController.dispose();
    super.dispose();
  }

  void _onDownloadStateChanged() {
    if (mounted && widget.downloadManager != null) {
      final manager = widget.downloadManager!;
      final bool newIsDownloading = manager.isDownloading || manager.isPaused;

      if (_isDownloading != newIsDownloading) {
        setState(() {
          dev.log("[ModelDetailPage.Listener] Download TRANSIENT state changed. isDownloading=${manager.isDownloading}, isPaused=${manager.isPaused}. Updating local UI.", name: 'ModelDetail');
          _isDownloading = newIsDownloading;
        });
      }
    }
  }

  /// Parses model features based on a SPECIFIC data source.
  /// This function is now a pure utility, making it predictable and testable.
  List<String> _parseFeaturesData(Map<String, dynamic> mainModelData, Map<String, dynamic>? sourceForCapabilities) {
    // Determine the primary source for capability checks (modalities, outputs).
    // If a specific source is provided (like a base model or an extension), use it.
    // Otherwise, fall back to the main model's own data.
    final capabilitiesData = sourceForCapabilities ?? mainModelData;

    final modalities = capabilitiesData['modalities'] as Map<String, dynamic>? ?? {};
    final outputs = capabilitiesData['outputs'] as Map<String, dynamic>? ?? {};

    dev.log("[ModelDetailPage] Parsing features using capabilities from: '${capabilitiesData['title'] ?? capabilitiesData['id']}'", name: 'ModelDetail');

    // --- Build the final feature list ---
    List<String> features = [];

    // 1. Add general features based on the MAIN model's properties.
    final category = mainModelData['category']?.toString().toLowerCase() ?? '';
    if (category == 'roleplay' || category == 'self') {
      features.add('roleplay');
    }

    final isServerSide = mainModelData['type'] != 'offline';
    if (!isServerSide) {
      features.add('offline');
    }

    final extensions = mainModelData['extensions'] as Map?;
    if (isServerSide && extensions != null && extensions.isNotEmpty) {
      features.add('plural');
    }

    // 2. Add specific capability features from the determined source data.
    if (modalities['image'] == true) features.add('photo');
    if (modalities['file'] == true) features.add('document');
    if (modalities['audio'] == true) features.add('audio');
    if (outputs['image'] == true) features.add('image_generation');

    return features;
  }

  /// Orchestrates the entire base model change process.
  /// Provides an instant UI update, handles background persistence, and locks the UI.
  /// Now also updates the premium status based on the new base model's tier.
  Future<void> _handleBaseModelChange(String newBaseModelId) async {
    if (_isButtonLocked) return;
    setState(() => _isButtonLocked = true);

    try {
      final newBaseModelData = ModelData.getPreciseModelData(newBaseModelId);
      if (newBaseModelData['title'] == 'Unknown Model') {
        debugPrint(
            "[ModelDetailPage] ERROR: Could not get data for new base model '$newBaseModelId'. Aborting.");
        if (mounted) {
          Provider.of<NotificationService>(context, listen: false).showNotification(
              message: AppLocalizations.of(context)!.anErrorOccurred,
              isSuccess: false
          );
        }
        return;
      }

      // First, update the local state for an immediate UI response.
      setState(() {
        _selectedBaseModelId = newBaseModelId;
        _selectedBaseModelData = newBaseModelData;
        _modelData['baseModelId'] = newBaseModelId; // Update the internal _modelData
        _didBaseModelChange = true;
        _isBaseModelPanelExpanded = false;

        // --- ADDED: Update premium status based on the new base model's tier ---
        _isPremiumModelSelected = (newBaseModelData['tier'] as String? ?? 'free') == 'premium';
        dev.log("[ModelDetailPage._handleBaseModelChange] New base model '$newBaseModelId' is premium: $_isPremiumModelSelected", name: 'ModelDetail');

        // Re-parse features based on the new base model's capabilities.
        // For characters, capabilities come from the base model, not _selectedExtensionData.
        _parsedFeatures = _parseFeaturesData(_modelData, newBaseModelData);
      });

      await _updateBaseModelInDatabase(widget.id, newBaseModelId);
      ModelData.updateCachedModel(_modelData); // Update the cache with the new _modelData

    } finally {
      if (mounted) {
        setState(() => _isButtonLocked = false);
      }
    }
  }

  /// Persists the base model change to the database.
  /// NOTE: This function was already correct from our previous interactions,
  /// but it is included here for completeness as it's part of the change logic.
  Future<void> _updateBaseModelInDatabase(
      String modelId, String newBaseModelId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results =
      await db.query('models', where: 'id = ?', whereArgs: [modelId]);

      if (results.isNotEmpty) {
        final rawJsonString = results.first['raw_json'] as String;
        final currentUser = FirebaseAuth.instance.currentUser;
        final bool isCustomModel = modelId.startsWith('self_') || modelId.startsWith('local_');

        String finalJsonToSave;

        if (isCustomModel) {
          // This is a user-created model, so we must decrypt, update, and re-encrypt.
          if (currentUser == null) {
            throw Exception("User not logged in, cannot update an encrypted model.");
          }
          String? decryptedJsonString = CryptoHelper.decrypt(rawJsonString, currentUser.uid);
          if (decryptedJsonString == null) {
            throw Exception("Failed to decrypt model data for '$modelId' before updating.");
          }
          Map<String, dynamic> updatedJson = json.decode(decryptedJsonString);
          updatedJson['baseModelId'] = newBaseModelId;
          String? encryptedJson = CryptoHelper.encrypt(json.encode(updatedJson), currentUser.uid);
          if (encryptedJson == null) {
            throw Exception("Failed to re-encrypt model data for '$modelId' after updating.");
          }
          finalJsonToSave = encryptedJson;
          dev.log("[ModelDetailPage] Persisting base model change for ENCRYPTED model '$modelId'.", name: 'ModelDetail');
        } else {
          // This is a public model. The JSON is not encrypted.
          Map<String, dynamic> updatedJson = json.decode(rawJsonString);
          updatedJson['baseModelId'] = newBaseModelId;
          finalJsonToSave = json.encode(updatedJson);
          dev.log("[ModelDetailPage] Persisting base model change for PUBLIC model '$modelId'.", name: 'ModelDetail');
        }

        await db.update(
          'models',
          {'raw_json': finalJsonToSave},
          where: 'id = ?',
          whereArgs: [modelId],
        );
        debugPrint(
            "[ModelDetailPage] Successfully persisted baseModelId for '$modelId' to '$newBaseModelId'.");
      }
    } catch (e) {
      debugPrint(
          "[ModelDetailPage] CRITICAL ERROR persisting base model change to DB: $e");
      if (mounted) {
        Provider.of<NotificationService>(context, listen: false).showNotification(
            message: AppLocalizations.of(context)!.anErrorOccurred,
            isSuccess: false
        );
      }
    }
  }

  // This function is now updated to handle navigation correctly.
  Future<void> _startChatWithModel() async {
    if (widget.onChatPressed == null) return;

    // Trigger the chat creation logic owned by the parent screen.
    // Thanks to our fix in `_handleBaseModelChange`, this will now use the LATEST model data.
    await widget.onChatPressed!();

    if (mounted && Navigator.canPop(context)) {
      // --- THE FIX ---
      // After starting the chat, pop this detail screen.
      // It's crucial to pass back the 'model_updated' signal if a change was
      // made. This tells the ModelsScreen to refresh its own UI to reflect the
      // change (e.g., an updated model description or property).
      Navigator.of(context).pop(_didBaseModelChange ? 'model_updated' : null);
    }
  }

  /// Handles the back button press, ensuring safe navigation.
  /// This is the single source of truth for all "back" actions.
  Future<void> _onBackButtonPressed() async {
    // If the extension panel is open, handle the combined dismissal.
    if (_extensionOverlayEntry != null) {
      // First, wait for the panel to finish its closing animation.
      await _dismissExtensionOverlay();

      // IMPORTANT: After an await, always check if the widget is still in the tree.
      if (!mounted) return;

      // Then, pop the page. This creates a seamless sequential animation
      // that feels like a single action to the user.
      Navigator.pop(context, _didBaseModelChange ? 'model_updated' : null);
      return;
    }

    // If a model save is in progress, block navigation.
    if (_isButtonLocked) {
      debugPrint("[ModelDetailPage] Back navigation blocked: async save in progress.");
      return;
    }

    // Default case: If the panel is not open, just pop the page immediately.
    Navigator.pop(context, _didBaseModelChange ? 'model_updated' : null);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkTheme = AppColors.currentTheme == 'dark';
    final langCode = localizations.localeName;

    // Dynamic content resolution logic (remains correct)
    final String displaySummary = ModelData.getLocalizedText(
        _selectedExtensionData.isNotEmpty ? _selectedExtensionData : _modelData,
        'summary',
        langCode
    );
    String displayDescription = ModelData.getLocalizedText(
        _selectedExtensionData.isNotEmpty ? _selectedExtensionData : _modelData,
        'description',
        langCode
    );
    if (displayDescription.trim().isEmpty && _selectedBaseModelData != null) {
      displayDescription = ModelData.getLocalizedText(_selectedBaseModelData!, 'description', langCode);
    }

    final bool hasSummary = displaySummary.trim().isNotEmpty;
    final bool isSelfOrRoleplay = ['self', 'roleplay']
        .contains((_modelData['category'] as String?)?.toLowerCase());
    final bool hasDescription = displayDescription.trim().isNotEmpty;
    final bool hasRatings = !isSelfOrRoleplay && _starCounts.isNotEmpty;
    final bool hasFeatures = _parsedFeatures.isNotEmpty;

    // --- [THE FIX, PART 1] ---
    // Calculate the number of warnings and the necessary bottom padding for the scroll view.
    // This ensures that the scrollable content does not get hidden behind the fixed warning banners.
    final warningCount =
        (!_isFullyLocalized ? 1 : 0) +
            (!widget.isServerSide ? 1 : 0) +
            (_isPremiumModelSelected ? 1 : 0);

    // Estimate the height needed for the warning banners.
    // Approx. 60px per banner + 8px spacing between them + 12px margin from the bottom.
    final double requiredPaddingForWarnings = warningCount > 0
        ? (warningCount * 60.0) + ((warningCount - 1) * 8.0) + 12.0
        : 0.0;

    // The total bottom padding for the SingleChildScrollView.
    final double scrollViewBottomPadding = screenWidth * 0.04 + requiredPaddingForWarnings;

    return WillPopScope(
      onWillPop: () async {
        // Delegate all back navigation logic to our improved, async method.
        await _onBackButtonPressed();

        // Always return 'false'. This prevents the system's default back action.
        // Our method now handles everything, including the final Navigator.pop().
        return false;
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBarWrapper(localizations, isDarkTheme, screenWidth),
      bottomNavigationBar: _buildBottomActionButtons(
          localizations, isDarkTheme, screenWidth, screenHeight),
      body: SafeArea(
        bottom: false,
        child: Stack(
        children: [
            // Layer 1: The scrollable content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _isLoading
                  ? _buildShimmerScreen(screenWidth, screenHeight,
                  isDarkTheme: isDarkTheme, key: const ValueKey('shimmer'))
                  : SingleChildScrollView(
                key: const ValueKey('model_detail_scroll_view'),
                // Apply the calculated padding to prevent content from being obscured.
                padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.04,
                    screenWidth * 0.04,
                    screenWidth * 0.04,
                    scrollViewBottomPadding), // Use the new calculated padding
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        axisAlignment: -1.0,
                        sizeFactor: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey('${_selectedExtensionName}_${_selectedBaseModelId ?? ''}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModelHeader(
                          localizations, isDarkTheme, screenWidth),
                      SizedBox(height: screenHeight * 0.02),
                      if (hasSummary) ...[
                        _buildSummarySection(
                            localizations, isDarkTheme, screenWidth, summaryText: displaySummary),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                      if (isSelfOrRoleplay) ...[
                        _buildBaseModelSelectionSection(
                            localizations, screenWidth),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                      if (hasDescription) ...[
                        _buildDescriptionSection(
                            localizations, isDarkTheme, screenWidth, descriptionText: displayDescription),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                      if (hasRatings) ...[
                        _buildRatingsSection(
                            localizations, isDarkTheme, screenWidth),
                        SizedBox(height: screenHeight * 0.02),
                      ],

                      if (hasFeatures) ...[
                        _buildFeaturesSection(
                            localizations, isDarkTheme, screenWidth),
                      ],
                      if (hasRatings) ...[
                        SizedBox(height: screenHeight * 0.02),
                        Center(
                            child: Text(
                                localizations.allEvaluationsByTestTeam,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.quinaryColor,
                                    fontSize: screenWidth * 0.028))),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // --- [THE FIX, PART 3] ---
            // Layer 2: The fixed warning banners.
            // This is now outside the SingleChildScrollView and will not move.
            _buildWarningOverlayDispatcher(localizations),
          ],
        ),
      ),
      ),
    );
  }

  /// Builds the main header, now using fully resolved and localized data.
  Widget _buildModelHeader(
      AppLocalizations localizations, bool isDarkTheme, double screenWidth) {
    final category = (_modelData['category'] as String?)?.toLowerCase();
    final isSelfOrRoleplay = ['self', 'roleplay'].contains(category);

    // --- THE FIX: All values are now resolved dynamically on every build ---
    String contextValue;
    String modalityValue;

    // These already came from the model, but for consistency, we keep them here.
    final sizeInt = _modelData['size'] as int?;
    final ramInt = _modelData['ram'] as int?;
    String sizeValue = sizeInt != null ? '$sizeInt MB' : localizations.notAvailable;
    String ramValue = ramInt != null ? '$ramInt MB' : localizations.notAvailable;

    // Check if it's a custom model and if a base model is selected
    if (isSelfOrRoleplay && _selectedBaseModelData != null) {
      // If so, get context and modality from the CURRENT base model
      final baseModel = _selectedBaseModelData!;
      contextValue = baseModel['context']?.toString() ?? '...';
      final baseModalities = baseModel['modalities'] as Map<String, dynamic>? ?? {};
      modalityValue = baseModalities.isNotEmpty
          ? localizations.multimodal
          : localizations.text;
    } else {
      // Otherwise, get data from the primary model or its extension
      final currentData = _selectedExtensionData.isNotEmpty ? _selectedExtensionData : _modelData;
      contextValue = currentData['context']?.toString() ?? '';
      final modelModalities = currentData['modalities'] as Map<String, dynamic>? ?? {};
      modalityValue = (modelModalities['image'] == true)
          ? localizations.multimodal
          : localizations.text;
    }

    // The rest of the image rendering logic is unchanged and correct.
    final svgColorFilter = ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn);
    final fallbackPaddedImage = Padding(
      padding: const EdgeInsets.all(12.0),
      child: SvgPicture.asset(
        'assets/icons/self.svg',
        fit: BoxFit.contain,
        colorFilter: svgColorFilter,
      ),
    );
    Widget imageWidget;
    final bool isSvg = _displayImagePath.toLowerCase().endsWith('.svg');
    if (isSvg) {
      final file = File(_displayImagePath);
      Widget? svgContent;
      if (_displayImagePath.startsWith('assets/')) {
        svgContent = SvgPicture.asset(_displayImagePath, fit: BoxFit.contain, colorFilter: svgColorFilter);
      } else if (file.existsSync()) {
        svgContent = SvgPicture.file(file, fit: BoxFit.contain, colorFilter: svgColorFilter);
      }
      imageWidget = svgContent != null ? Padding(padding: const EdgeInsets.all(12.0), child: svgContent) : fallbackPaddedImage;
    } else {
      final file = File(_displayImagePath);
      ImageProvider provider = _displayImagePath.startsWith('assets/')
          ? AssetImage(_displayImagePath)
          : (file.existsSync() ? FileImage(file) as ImageProvider : const AssetImage('assets/icons/transparent.png'));
      imageWidget = Image(image: provider, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallbackPaddedImage);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 3,
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        color: AppColors.secondaryColor),
                    child: imageWidget))),
        SizedBox(width: screenWidth * 0.05),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_displayTitle,
                  style: GoogleFonts.poppins(
                      color: AppColors.primaryColor.inverted,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: screenWidth * 0.01),
              Text(_displayProducer,
                  style: GoogleFonts.poppins(
                      color: AppColors.quinaryColor,
                      fontSize: screenWidth * 0.04)),
              SizedBox(height: screenWidth * 0.02),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Column(
                  key: ValueKey(_selectedBaseModelId ?? 'local'), // Keyed for smooth animation
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isServerSide) ...[
                      _buildInfoRow(localizations.storage, sizeValue,
                          'assets/icons/storage.svg', screenWidth),
                      SizedBox(height: screenWidth * 0.02),
                      _buildInfoRow(localizations.ram, ramValue,
                          'assets/icons/memory.svg', screenWidth),
                    ] else ...[
                      // These rows now display the dynamically calculated values
                      _buildInfoRow(localizations.modality, modalityValue,
                          'assets/icons/transition.svg', screenWidth),
                      SizedBox(height: screenWidth * 0.02),
                      _buildInfoRow(localizations.context, contextValue,
                          'assets/icons/context.svg', screenWidth),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// This section is now updated to show the sparkle icon next to premium base models.
  Widget _buildBaseModelSelectionSection(
      AppLocalizations localizations, double screenWidth) {
    final category = (_modelData['category'] as String?)?.toLowerCase();
    final bool isVisible = ['self', 'roleplay'].contains(category);

    if (!isVisible || _availableBaseModels.isEmpty) {
      return const SizedBox.shrink();
    }

    String selectedModelDisplayTitle = localizations.selectBaseModel;
    if (_selectedBaseModelData != null) {
      selectedModelDisplayTitle =
          _selectedBaseModelData!['title'] as String? ?? _selectedBaseModelId!;
    } else if (_selectedBaseModelId != null) {
      final modelData = ModelData.getPreciseModelData(_selectedBaseModelId!);
      selectedModelDisplayTitle =
          modelData['title'] as String? ?? _selectedBaseModelId!;
    }

    // --- ADDED: Check if the currently selected base model is premium ---
    final bool isCurrentlySelectedBaseModelPremium = (_selectedBaseModelData?['tier'] as String? ?? 'free') == 'premium';


    return _buildSectionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
              localizations, 'baseModelSection', true, screenWidth),
          SizedBox(height: screenWidth * 0.01),
          Text(localizations.baseModelForCharacterDescription,
              style: TextStyle(
                  color: AppColors.quinaryColor,
                  fontSize: screenWidth * 0.035)),
          SizedBox(height: screenWidth * 0.02),
          Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: InkWell(
              onTap: () => setState(
                      () => _isBaseModelPanelExpanded = !_isBaseModelPanelExpanded),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(selectedModelDisplayTitle,
                            style: TextStyle(
                                color: AppColors.primaryColor.inverted,
                                fontSize: screenWidth * 0.04),
                            overflow: TextOverflow.ellipsis)),
                    // --- ADDED: Sparkle icon for currently selected premium base model ---
                    if (isCurrentlySelectedBaseModelPremium)
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: SvgPicture.asset(
                          'assets/icons/sparkle.svg',
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.inverted.withOpacity(0.8),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    AnimatedRotation(
                        turns: _isBaseModelPanelExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down,
                            color: AppColors.primaryColor.inverted)),
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
              margin: EdgeInsets.only(top: screenWidth * 0.02),
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius:
                  BorderRadius.circular(screenWidth * 0.02)),
              child: ListView(
                shrinkWrap: true,
                children: _availableBaseModels.expand((series) {
                  final extensions =
                  series['extensions'] as Map<String, dynamic>;
                  return extensions.entries.map((ext) {
                    final variantId = ext.key;
                    final variantData = ext.value; // Get the full variant data
                    final variantTitle = variantData['title'] as String? ?? variantId;
                    final imagePath = ModelData.getModelImagePath(series);
                    final imageProvider = imagePath.startsWith('assets/')
                        ? AssetImage(imagePath) as ImageProvider
                        : FileImage(File(imagePath));

                    // --- ADDED: Check if this specific variant is premium ---
                    final bool isVariantPremium = (variantData['tier'] as String? ?? 'free') == 'premium';

                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage: imageProvider,
                          backgroundColor: Colors.transparent),
                      title: Text(variantTitle,
                          style: TextStyle(
                              color: AppColors.primaryColor.inverted)),
                      // --- ADDED: Show sparkle icon for premium variants in the list ---
                      trailing: isVariantPremium
                          ? SvgPicture.asset(
                        'assets/icons/sparkle.svg',
                        width: screenWidth * 0.05,
                        height: screenWidth * 0.05,
                        colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.inverted.withOpacity(0.8),
                          BlendMode.srcIn,
                        ),
                      )
                          : null,
                      onTap: () {
                        _handleBaseModelChange(variantId);
                        setState(() {
                          _isBaseModelPanelExpanded = false; // Close panel after selection
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
      ),
      true,
      screenWidth,
    );
  }

  OverlayEntry? _extensionOverlayEntry;
  AnimationController? _extensionOverlayController;

  void _showExtensionOverlayPanel() {
    _extensionOverlayEntry?.remove();
    _extensionOverlayController?.dispose();
    _extensionOverlayEntry = null;
    _extensionOverlayController = null;

    // This aligns with the new data structure required by buildExtensionPanelWidget.
    // We iterate through the values of the extensions map and ensure each is a valid map.
    final List<Map<String, dynamic>> options =
        widget.extensions?.values.toList() ?? [];

    if (options.isEmpty) return; // Do not show the panel if there are no valid options.

    final overlay = Overlay.of(context, rootOverlay: true);
    _extensionOverlayController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    final scaleAnimation = CurvedAnimation(
        parent: _extensionOverlayController!, curve: Curves.easeOut);

    double calcPanelWidth() {
      final w = MediaQuery.of(context).size.width;
      final iconPx = w * .04, padPx = w * .04, spacePx = padPx * .5;
      double longest = 0;
      final ts = TextStyle(fontSize: w * .04, fontFamily: 'Roboto');
      for (final optionData in options) {
        final text = optionData['title'] as String? ?? optionData['id'];
        final tp = TextPainter(
            text: TextSpan(text: text, style: ts),
            maxLines: 1,
            textDirection: TextDirection.ltr)
          ..layout();
        if (tp.width > longest) longest = tp.width;
      }
      return (iconPx + spacePx + longest + padPx * 2).clamp(200.0, w * .9);
    }

    final screenW = MediaQuery.of(context).size.width;
    final panelW = calcPanelWidth();
    final marginPx = screenW * .02;
    final topPx = MediaQuery.of(context).size.height * .12;
    final bool overflowRight = (marginPx + panelW) > (screenW - marginPx);

    void dismiss() {
      _extensionOverlayController!.reverse().then((_) {
        _extensionOverlayEntry?.remove();
        _extensionOverlayEntry = null;
        _extensionOverlayController?.dispose();
        _extensionOverlayController = null;
      });
    }

    _extensionOverlayEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(child: GestureDetector(onTap: dismiss)),
            Positioned(
              top: topPx,
              left: overflowRight ? null : marginPx,
              right: overflowRight ? marginPx : null,
              child: GestureDetector(
                onTap: () {}, // Prevents taps inside the panel from dismissing it.
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: SizedBox(
                    width: panelW,
                    child: Extensions.buildExtensionPanelWidget(
                      context: context,
                      // --- FIX: Pass the correctly typed list ---
                      options: options,
                      selectedExtension: _selectedExtensionName,
                      modelTitle: widget.title,
                      onDismiss: dismiss,
                      // --- MODIFIED: The 'selectedOption' parameter is now a Map ---
                      onSelect: (selectedOption) {
                        setState(() {
                          // Access 'id' from the map to get the extension name.
                          _selectedExtensionName = selectedOption['id'] as String;

                          // The 'selectedOption' map itself is the new extension data.
                          _selectedExtensionData = selectedOption;

                          // Re-parse features with the newly selected data.
                          _parsedFeatures = _parseFeaturesData(_modelData, _selectedExtensionData);

                          _isPremiumModelSelected = (selectedOption['tier'] as String? ?? 'free') == 'premium';
                        });
                        dismiss();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    overlay.insert(_extensionOverlayEntry!);
    _extensionOverlayController!.forward();
  }

  Future<void> _dismissExtensionOverlay() async {
    if (_extensionOverlayEntry != null && _extensionOverlayController != null) {
      await _extensionOverlayController!.reverse();
      _extensionOverlayEntry!.remove();
      _extensionOverlayEntry = null;
      _extensionOverlayController!.dispose();
      _extensionOverlayController = null;
    }
  }

  Widget _buildTitleWidget(double screenWidth) {
    String displayExtensionName =
        _selectedExtensionData['title'] as String? ?? _selectedExtensionName;
    if (widget.isServerSide &&
        widget.extensions != null &&
        widget.extensions!.isNotEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showExtensionOverlayPanel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_displayTitle,
                style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false, overscroll: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                axisAlignment: -1.0,
                                child: child)),
                        child: Text(displayExtensionName,
                            key: ValueKey(displayExtensionName),
                            style: TextStyle(
                                color: AppColors.quinaryColor,
                                fontSize: screenWidth * 0.04),
                            maxLines: 1)),
                    Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.015),
                        child: Transform.rotate(
                            angle: -1.57075,
                            child: SvgPicture.asset('assets/icons/arrov.svg',
                                width: screenWidth * 0.04,
                                height: screenWidth * 0.04,
                                colorFilter: ColorFilter.mode(
                                    AppColors.quinaryColor, BlendMode.srcIn)))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(_displayTitle,
          style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold));
    }
  }

  BuildContext? _exitButtonContext;
  bool _isTapInsideWidget(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    return globalPosition.dx >= position.dx &&
        globalPosition.dx <= position.dx + size.width &&
        globalPosition.dy >= position.dy &&
        globalPosition.dy <= position.dy + size.height;
  }

  PreferredSizeWidget _buildAppBarWrapper(
      AppLocalizations localizations, bool isDarkTheme, double screenWidth) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (PointerDownEvent event) {
              if (_extensionOverlayEntry != null &&
                  _exitButtonContext != null &&
                  !_isTapInsideWidget(_exitButtonContext!, event.position)) {
                _dismissExtensionOverlay();
              }
            },
            child: _buildAppBar(localizations, isDarkTheme, screenWidth)));
  }

  PreferredSizeWidget _buildAppBar(
      AppLocalizations localizations, bool isDarkTheme, double screenWidth) {
    Widget titleWidget = _buildTitleWidget(screenWidth);
    final leadingButton = Builder(builder: (context) {
      _exitButtonContext = context;
      return IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppColors.primaryColor.inverted, size: screenWidth * 0.07),
          onPressed: _onBackButtonPressed);
    });
    if (widget.downloadManager != null) {
      return AppBar(
        scrolledUnderElevation: 0,
        leading: leadingButton,
        title: AnimatedBuilder(
            animation: widget.downloadManager!,
            builder: (context, _) {
              String downloadStatus = '';
              if (widget.downloadManager!.isDownloading) {
                downloadStatus = widget.downloadManager!.progress >= 95
                    ? localizations.finalPreparation
                    : localizations.downloaded(
                    widget.downloadManager!.progress.toStringAsFixed(0));
              } else if (widget.downloadManager!.isPaused) {
                downloadStatus = localizations.downloadPaused;
              }
              return Row(children: [
                Expanded(child: titleWidget),
                SizedBox(
                    width: screenWidth * 0.25,
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: downloadStatus.isNotEmpty
                            ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(downloadStatus,
                                key: ValueKey<String>(downloadStatus),
                                style: TextStyle(
                                    color: AppColors.quinaryColor,
                                    fontSize: screenWidth * 0.035),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis))
                            : Opacity(
                            key: const ValueKey('empty'),
                            opacity: 0.0,
                            child: Text('',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.035)))))
              ]);
            }),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
            color: AppColors.primaryColor.inverted, size: screenWidth * 0.07),
        actions: const [],
      );
    } else {
      return AppBar(
          scrolledUnderElevation: 0,
          leading: leadingButton,
          title: titleWidget,
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(
              color: AppColors.primaryColor.inverted, size: screenWidth * 0.07),
          actions: const []);
    }
  }

  /// Used for non-removable server-side models (e.g., online, roleplay).
  Widget _buildChatOnlyButton(AppLocalizations localizations, double screenWidth) {
    return Container(
      key: const ValueKey('chatOnly'),
      height: screenWidth * 0.125,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      child: InkWell(
        onTap: _isDeleting ? null : _startChatWithModel,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.senaryColor, // Color for the chat button
              borderRadius: BorderRadius.circular(screenWidth * 0.03)
          ),
          child: Text(
              localizations.chat,
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)
          ),
        ),
      ),
    );
  }

// This is the master function that decides which set of action buttons to display
// at the bottom of the screen. It correctly identifies user-created models,
// downloadable offline models, and server-side models.
  Widget _buildBottomActionButtons(AppLocalizations localizations,
      bool isDarkTheme, double screenWidth, double screenHeight) {

    // First, determine the model's type with top priority.
    final bool isUserCreatedModel = widget.id.startsWith('self_') || widget.id.startsWith('local_');

    // This handles the state for downloadable offline models.
    final bool isEffectivelyDownloaded = _isDownloaded || (widget.downloadManager?.isDownloaded ?? false);

    // Helper to build the standard container for the bottom bar.
    Widget buildContainer(Widget child) {
      return SafeArea(
        top: false,
        right: false,
        left: false,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
          decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
              ],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.05),
                  topRight: Radius.circular(screenWidth * 0.05))),
          child: child,
        ),
      );
    }

    // -> Always show "Remove / Chat" buttons.
    if (isUserCreatedModel) {
      dev.log("[ModelDetailPage.buildBottomButtons] -> Result: Showing 'Remove/Chat' for user-created model.", name: 'ModelDetail');
      return buildContainer(
        _buildRemoveOrChatButtons(localizations, isDarkTheme, screenWidth),
      );
    }
    // CASE 2: Is it a downloadable (offline) model?
    // -> Show buttons based on its download state.
    else if (!widget.isServerSide) {
      dev.log("[ModelDetailPage.buildBottomButtons] -> Result: Showing AnimatedSwitcher for offline model. isDownloaded: $isEffectivelyDownloaded.", name: 'ModelDetail');
      return buildContainer(
        AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: isEffectivelyDownloaded
                ? _buildRemoveOrChatButtons(localizations, isDarkTheme, screenWidth)
                : _buildDownloadOrCancelButtons(localizations, isDarkTheme, screenWidth, screenHeight)),
      );
    }
    // CASE 3: It must be a non-removable, server-side model (online/roleplay).
    // -> Show ONLY the "Chat" button.
    else {
      dev.log("[ModelDetailPage.buildBottomButtons] -> Result: Showing 'Chat Only' for server-side model.", name: 'ModelDetail');
      return buildContainer(
        _buildChatOnlyButton(localizations, screenWidth),
      );
    }
  }

// This function builds the specific "Remove / Chat" button row.
// It correctly wires the "Remove" button's onTap to the new _handleRemoveModel logic.
  Widget _buildRemoveOrChatButtons(AppLocalizations localizations, bool isDarkTheme, double screenWidth) {
    final String removeText = localizations.remove;

    return Container(
      key: const ValueKey('removeAndChat'),
      height: screenWidth * 0.125,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      child: _isDeleting
      // Show a spinner while the async deletion/uninstallation is in progress.
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor.inverted, strokeWidth: 2.0))
      // Otherwise, show the action buttons.
          : Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _isDeleting ? null : _handleRemoveModel, // FIX: Calls the unified handler
              borderRadius: BorderRadius.only(topLeft: Radius.circular(screenWidth * 0.03), bottomLeft: Radius.circular(screenWidth * 0.03)),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.septenaryColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(screenWidth * 0.03), bottomLeft: Radius.circular(screenWidth * 0.03))),
                child: Text(removeText, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
              ),
            ),
          ),
          Container(width: 1.0, color: AppColors.border), // Visual separator
          Expanded(
            child: InkWell(
              onTap: _isDeleting ? null : _startChatWithModel,
              borderRadius: BorderRadius.only(topRight: Radius.circular(screenWidth * 0.03), bottomRight: Radius.circular(screenWidth * 0.03)),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.senaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(screenWidth * 0.03), bottomRight: Radius.circular(screenWidth * 0.03))),
                child: Text(localizations.chat, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
              ),
            ),
          ),
        ],
      ),
    );
  }

// This is the core logic that executes when the "Remove" button is pressed.
// It handles the confirmation dialog and calls the correct service from remove.dart.
// Most importantly, it updates its own local state (`_isDownloaded`, `_isDeleting`)
// to provide instant UI feedback upon successful uninstallation.
  Future<void> _handleRemoveModel() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;
    final internetService = InternetService();

    // Determine model type and prepare dialog texts using the safely loaded `_displayTitle`
    final bool isCustomModel = widget.id.startsWith('self_') || widget.id.startsWith('local_');
    final String dialogTitle = localizations.removeModel;
    final String dialogMessage = localizations.confirmRemoveModel(_displayTitle); // Safe to use now
    final String confirmButtonText = localizations.remove;

    // Pre-flight check for custom models
    if (isCustomModel && !internetService.currentStatus) {
      Provider.of<NotificationService>(context, listen: false).showNotification(message: localizations.noInternetConnection, isSuccess: false);
      return;
    }

    // Show confirmation dialog
    final restoreNavBar = Darkener.darken();
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'RemoveModel',
      barrierDismissible: true,
      pageBuilder: (dialogCtx, _, __) {
        return Center(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 16), child: Column(children: [
                        Text(dialogTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(dialogMessage, style: TextStyle(color: AppColors.primaryColor.inverted.withOpacity(0.8)), textAlign: TextAlign.center),
                      ])),
                      Divider(color: AppColors.border, thickness: 0.5, height: 0.5),
                      IntrinsicHeight(child: Row(children: [
                        Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.of(dialogCtx).pop(false), child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 16), child: Text(localizations.cancel, style: TextStyle(color: AppColors.senaryColor, fontSize: 16)))))),
                        VerticalDivider(color: AppColors.border, thickness: 0.5),
                        Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.of(dialogCtx).pop(true), child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 16), child: Text(confirmButtonText, style: TextStyle(color: AppColors.septenaryColor, fontSize: 16)))))),
                      ])),
                    ]),
                  ),
                ),
              ),
            ));
        },
    );
    restoreNavBar();

    if (confirmed != true) return;
    if (mounted) setState(() => _isDeleting = true); // Show spinner

    try {
      bool success;
      if (isCustomModel) {
        // --- SCENARIO A: PERMANENT DELETION ---
        success = await ModelRemoveService.deleteCustomModel(
          id: widget.id,
          title: _displayTitle, // Pass the safe title
          context: context,
        );
        if (success && mounted) {
          // The model is gone. Pop the page. The parent screen will refresh via its listener.
          Navigator.of(context).pop();
        }
      } else {
        // --- SCENARIO B: UNINSTALLATION ---
        success = await ModelRemoveService.uninstallDownloadedModel(
          id: widget.id,
          title: _displayTitle, // Pass the safe title
          context: context,
        );

        if (success && mounted) {
          // The model file is gone, but the model entry still exists.
          // Update the local state for an INSTANT UI change on this page.
          // The "Remove" button will immediately become a "Download" button.
          setState(() {
            dev.log("[ModelDetailPage._handleRemoveModel] Uninstall successful. Forcing local state to _isDownloaded = false for instant UI feedback.", name: 'ModelDetail');
            _isDownloaded = false;
            _isDeleting = false; // Hide spinner
            widget.downloadManager?.setDownloaded(false); // Also reset the live manager
          });
          // The parent screen will also be notified by the service and will update itself.
        }
      }

      // If any operation failed, just hide the spinner. The service shows the error notification.
      if (!success && mounted) {
        setState(() => _isDeleting = false);
      }
    } catch (e) {
      dev.log("[ModelDetailPage._handleRemoveModel] Error during removal: $e", name: 'ModelDetail');
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _buildDownloadOrCancelButtons(AppLocalizations localizations,
      bool isDarkTheme, double screenWidth, double screenHeight) {
    return Row(
      key: ValueKey(_isDownloading ? 'cancel' : 'download'),
      children: [
        Expanded(
          child: _isDownloading
          // The "Cancel" button logic remains unchanged as it's correct.
              ? AnimatedCancelButton(
              key: const ValueKey('cancelButton'),
              onPressed: () {
                widget.onCancelPressed?.call();
              },
              width: double.infinity,
              height: screenHeight * 0.058,
              borderRadius: screenWidth * 0.03,
              borderColor: AppColors.primaryColor.inverted,
              text: localizations.cancel,
              fontSize: screenWidth * 0.04,
              strokeFactor: 0.004)
          // --- THE FIX: The Download button is now wrapped in a StreamBuilder ---
              : StreamBuilder<bool>(
            stream: InternetService().onConnectivityChanged,
            initialData: InternetService().currentStatus,
            builder: (context, snapshot) {
              final hasInternet = snapshot.data ?? false;
              final isCompatible =
                  widget.compatibilityStatus == CompatibilityStatus.compatible;

              String buttonText;
              // Determine button text based on priority:
              // 1. No Internet, 2. Compatibility, 3. Default Download
              if (!hasInternet) {
                buttonText = localizations.noInternetConnection;
              } else if (isCompatible) {
                buttonText = localizations.download;
              } else {
                buttonText = widget.compatibilityStatus ==
                    CompatibilityStatus.insufficientRAM
                    ? localizations.insufficientRAM
                    : localizations.insufficientStorage;
              }

              // The button is only truly enabled if all conditions are met.
              final bool isButtonEnabled =
                  hasInternet && isCompatible && widget.onDownloadPressed != null;

              return ElevatedButton(
                onPressed: isButtonEnabled && !_isButtonLocked
                    ? () async {
                  // This is the original, correct async press handler
                  setState(() => _isButtonLocked = true);
                  try {
                    await widget.onDownloadPressed!();
                  } finally {
                    if (mounted) {
                      setState(() => _isButtonLocked = false);
                    }
                  }
                }
                    : null, // The button is disabled if conditions are not met
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.inverted,
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(screenWidth * 0.03))),
                child: Text(
                  buttonText,
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: screenWidth * 0.04),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(AppLocalizations localizations, bool isDarkTheme,
      double screenWidth, {required String summaryText}) =>
      _buildSectionContainer(
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(localizations.summary,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: screenWidth * 0.02),
            // Use the passed-in text
            Text(summaryText,
                style: TextStyle(
                    color: AppColors.quinaryColor,
                    fontSize: screenWidth * 0.04,
                    height: 1.6))
          ]),
          isDarkTheme,
          screenWidth);

  Widget _buildDescriptionSection(
      AppLocalizations localizations, bool isDarkTheme, double screenWidth, {required String descriptionText}) {
    // This function now receives the final, correct description.
    // No more complex logic is needed inside it.
    final String fullDescription = descriptionText;

    if (fullDescription.trim().isEmpty) return const SizedBox.shrink();

    final collapsedHeight = screenWidth * 0.25;
    final textStyle = TextStyle(
        color: AppColors.quinaryColor,
        fontSize: screenWidth * 0.04,
        height: 1.6);
    final textPainter = TextPainter(
        text: TextSpan(text: fullDescription, style: textStyle),
        maxLines: null,
        textDirection: TextDirection.ltr)
      ..layout(
          maxWidth: MediaQuery.of(context).size.width - (screenWidth * 0.08));
    final bool isOverflowing = textPainter.height > collapsedHeight;
    final normalStyle = textStyle;
    final linkStyle =
    textStyle.copyWith(color: Colors.blue, fontWeight: FontWeight.w600);
    Widget collapsedChild = isOverflowing
        ? ConstrainedBox(
        constraints: BoxConstraints(maxHeight: collapsedHeight),
        child: _buildLinkedText(fullDescription, normalStyle, linkStyle))
        : _buildLinkedText(fullDescription, normalStyle, linkStyle);

    return _buildSectionContainer(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildSectionTitle(
                localizations, 'descriptionSection', isDarkTheme, screenWidth),
            if (isOverflowing)
              GestureDetector(
                  onTap: () => setState(
                          () => _isDescriptionExpanded = !_isDescriptionExpanded),
                  child: AnimatedRotation(
                      turns: _isDescriptionExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset('assets/icons/arrov.svg',
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          color: AppColors.quinaryColor)))
          ]),
          SizedBox(height: screenWidth * 0.02),
          AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isDescriptionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: collapsedChild,
              secondChild:
              _buildLinkedText(fullDescription, normalStyle, linkStyle))
        ]),
        isDarkTheme,
        screenWidth);
  }

  Widget _buildLinkedText(
      String fullText, TextStyle normalStyle, TextStyle linkStyle) {
    final linkRegExp =
    RegExp(r'\[([^\]]+)\]\(([^)]+)\)|(https?://\S+)|(www\.\S+)|(/\S+)');
    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final match in linkRegExp.allMatches(fullText)) {
      if (match.start > lastEnd)
        spans.add(TextSpan(
            text: fullText.substring(lastEnd, match.start),
            style: normalStyle));
      String label, rawLink;
      if (match.group(1) != null && match.group(2) != null) {
        label = match.group(1)!;
        rawLink = match.group(2)!;
      } else {
        rawLink = match.group(3) ?? match.group(4) ?? match.group(5)!;
        label = rawLink;
      }
      String cleaned = rawLink.startsWith('/') ? rawLink.substring(1) : rawLink;
      String href = cleaned.startsWith(RegExp(r'https?://'))
          ? cleaned
          : 'https://$cleaned';
      spans.add(TextSpan(
          text: label,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(href);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                Provider.of<NotificationService>(context, listen: false)
                    .showNotification(
                    message: AppLocalizations.of(context)!.anErrorOccurred,
                    isSuccess: false,
                    bottomOffset: 0.1,
                    fontSize: 0.032);
              }
            }));
      lastEnd = match.end;
    }
    if (lastEnd < fullText.length)
      spans
          .add(TextSpan(text: fullText.substring(lastEnd), style: normalStyle));
    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildInfoRow(
      String label, String value, String iconPath, double screenWidth) =>
      FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(children: [
            SvgPicture.asset(iconPath,
                width: screenWidth * 0.05,
                height: screenWidth * 0.05,
                color: AppColors.quinaryColor),
            SizedBox(width: screenWidth * 0.02),
            Text('$label: $value',
                style: GoogleFonts.poppins(
                    color: AppColors.quinaryColor,
                    fontSize: screenWidth * 0.04))
          ]));
  Widget _buildShimmerScreen(double screenWidth, double screenHeight,
      {required Key key, required bool isDarkTheme}) =>
      SingleChildScrollView(
          key: key,
          padding: EdgeInsets.all(screenWidth * 0.04),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Shimmer.fromColors(
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                  child: Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(screenWidth * 0.04)))),
              SizedBox(width: screenWidth * 0.05),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                            baseColor: AppColors.shimmerBase,
                            highlightColor: AppColors.shimmerHighlight,
                            child: Container(
                                width: screenWidth * 0.5,
                                height: screenWidth * 0.05,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4)))),
                        SizedBox(height: screenWidth * 0.02),
                        Shimmer.fromColors(
                            baseColor: AppColors.shimmerBase,
                            highlightColor: AppColors.shimmerHighlight,
                            child: Container(
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.04,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4)))),
                        SizedBox(height: screenWidth * 0.02),
                        Shimmer.fromColors(
                            baseColor: AppColors.shimmerBase,
                            highlightColor: AppColors.shimmerHighlight,
                            child: Container(
                                width: double.infinity,
                                height: screenWidth * 0.04,
                                margin: EdgeInsets.only(top: screenWidth * 0.02),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4)))),
                        SizedBox(height: screenWidth * 0.02),
                        Shimmer.fromColors(
                            baseColor: AppColors.shimmerBase,
                            highlightColor: AppColors.shimmerHighlight,
                            child: Container(
                                width: double.infinity,
                                height: screenWidth * 0.04,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4))))
                      ]))
            ]),
            SizedBox(height: screenHeight * 0.02),
            _buildShimmerSectionPlaceholder(
                isDarkTheme: isDarkTheme,
                lineCount: 3,
                height: screenWidth * 0.04,
                screenWidth: screenWidth),
            SizedBox(height: screenHeight * 0.02),
            _buildShimmerSectionPlaceholder(
                isDarkTheme: isDarkTheme,
                title: true,
                lineCount: 1,
                height: screenWidth * 0.05,
                screenWidth: screenWidth),
            SizedBox(height: screenWidth * 0.02),
            _buildShimmerSectionPlaceholder(
                isDarkTheme: isDarkTheme,
                title: true,
                lineCount: 4,
                height: screenWidth * 0.04,
                screenWidth: screenWidth)
          ]));
  Widget _buildShimmerSectionPlaceholder(
      {required bool isDarkTheme,
        bool title = false,
        int lineCount = 1,
        double height = 16.0,
        required double screenWidth}) {
    List<Widget> children = [];
    if (title) {
      children.add(Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.05,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4)))));
      children.add(SizedBox(height: screenWidth * 0.02));
    }
    for (int i = 0; i < lineCount; i++) {
      children.add(Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
              width: double.infinity,
              height: height,
              margin: EdgeInsets.only(top: screenWidth * 0.02),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4)))));
      children.add(SizedBox(height: screenWidth * 0.02));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildWarningOverlayDispatcher(AppLocalizations localizations) {
    if (_isLoading) return const SizedBox.shrink();

    final warningWidgets = <Widget>[];

    // --- ADDED: Premium banner is added first to appear at the top of the stack ---
    if (_isPremiumModelSelected) {
      warningWidgets.add(_buildPremiumWarningBanner(localizations));
    }
    if (!_isFullyLocalized) {
      warningWidgets.add(_buildLocalizationWarningBanner(localizations));
    }
    if (!widget.isServerSide) {
      warningWidgets.add(_buildExperimentalWarningBanner(localizations));
    }

    if (warningWidgets.isEmpty) return const SizedBox.shrink();

    return Positioned(
        bottom: 12,
        left: 16,
        right: 16,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
                warningWidgets.length,
                    (index) => Padding(
                    padding: EdgeInsets.only(top: index > 0 ? 8.0 : 0.0),
                    child: warningWidgets[index]))));
  }

  /// This method has been modified to make the premium banner tappable,
  /// navigating the user to the premium screen, just like the banner in the AppBar.
  /// The visual style with the animated RGB border is preserved.
  Widget _buildPremiumWarningBanner(AppLocalizations localizations) {
    // Get the screen width once to use for all calculations.
    final screenWidth = MediaQuery.of(context).size.width;

    // --- DYNAMIC SIZING CONSTANTS ---
    final double borderRadius = screenWidth * 0.025; // e.g., ~10px on a 400px wide screen
    final double borderThickness = screenWidth * 0.005; // e.g., ~2px
    final double internalPaddingVertical = screenWidth * 0.03; // e.g., ~12px
    final double internalPaddingHorizontal = screenWidth * 0.04; // e.g., ~16px
    final double iconSize = screenWidth * 0.07; // e.g., ~28px
    final double gapBetweenIconAndText = screenWidth * 0.03; // e.g., ~12px
    final double gapBetweenTitleAndDesc = screenWidth * 0.01; // e.g., ~4px
    final double titleFontSize = screenWidth * 0.038; // e.g., ~15px
    final double descriptionFontSize = screenWidth * 0.033; // e.g., ~13px

    return AnimatedBuilder(
      animation: _rgbController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(borderThickness), // Padding for the border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0.0,
              endAngle: 6.28, // 2 * PI
              colors: const [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.cyan,
                Colors.blue,
                Colors.purple,
                Colors.red,
              ],
              transform: GradientRotation(_rgbController.value * 6.28), // 2 * PI
            ),
          ),
          child: child,
        );
      },
      child: Material(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(borderRadius * 0.8),
        child: InkWell(
          onTap: () {
            navigateToScreen(context, FundsScreen(), direction: const Offset(0.0, 1.0));
          },
          borderRadius: BorderRadius.circular(borderRadius * 0.8),
          splashColor: AppColors.primaryColor.withOpacity(0.1),
          highlightColor: AppColors.primaryColor.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: internalPaddingVertical,
              horizontal: internalPaddingHorizontal,
            ),
            // The decoration is now on the Material widget for the InkWell to work correctly.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/sparkle.svg',
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                  width: iconSize,
                  height: iconSize,
                ),
                SizedBox(width: gapBetweenIconAndText),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.premiumModelNoticeTitle,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor.inverted,
                        ),
                      ),
                      SizedBox(height: gapBetweenTitleAndDesc),
                      Text(
                        localizations.premiumModelNoticeDescription,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: AppColors.primaryColor.inverted.withOpacity(0.8),
                        ),
                      ),
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

  Widget _buildLocalizationWarningBanner(AppLocalizations localizations) =>
      Material(
          type: MaterialType.transparency,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]),
              child: Row(children: [
                SvgPicture.asset('assets/icons/warning.svg',
                    colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted, BlendMode.srcIn),
                    width: 24,
                    height: 24),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(localizations.localizationWarning,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor.inverted)))
              ])));
  Widget _buildExperimentalWarningBanner(AppLocalizations localizations) =>
      Material(
          type: MaterialType.transparency,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]),
              child: Row(children: [
                SvgPicture.asset('assets/icons/warning.svg',
                    colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted, BlendMode.srcIn),
                    width: 24,
                    height: 24),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(localizations.experimentalOfflineWarning,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor.inverted)))
              ])));
  Widget _buildRatingsSection(
      AppLocalizations localizations, bool isDarkTheme, double screenWidth) {
    if ((_modelData['category'] as String?)?.toLowerCase() == 'roleplay' ||
        _starCounts.isEmpty) return const SizedBox.shrink();
    return _buildSectionContainer(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildSectionTitle(
                localizations, 'ratingSection', isDarkTheme, screenWidth)
          ]),
          SizedBox(height: screenWidth * 0.02),
          _buildStarRatingChart(isDarkTheme, screenWidth)
        ]),
        isDarkTheme,
        screenWidth);
  }

  Widget _buildStarRatingChart(bool isDarkTheme, double screenWidth) {
    if (_starCounts.isEmpty)
      return Text(AppLocalizations.of(context)!.noRatingDataFound,
          style: TextStyle(
              color: AppColors.quinaryColor, fontSize: screenWidth * 0.04));
    final totalCount = _starCounts.values.isNotEmpty
        ? _starCounts.values.reduce((a, b) => a + b)
        : 1;
    return Column(
        children: [5, 4, 3, 2, 1].map((star) {
          final count = _starCounts[star] ?? 0;
          final ratio = totalCount > 0 ? count / totalCount : 0.0;
          return Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
              child: Row(children: [
                Stack(alignment: Alignment.center, children: [
                  SvgPicture.asset('assets/icons/star.svg',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      color: AppColors.primaryColor.inverted),
                  Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.008),
                      child: Text('$star',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold)))
                ]),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: ratio),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, animatedValue, child) =>
                                LinearProgressIndicator(
                                    value: animatedValue,
                                    minHeight: screenWidth * 0.02,
                                    backgroundColor: AppColors.border,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor.inverted)))))
              ]));
        }).toList());
  }

  Widget _buildFeaturesSection(
      AppLocalizations localizations, bool isDarkTheme, double screenWidth) {
    if (_parsedFeatures.isEmpty) return const SizedBox.shrink();

    // --- NEW: Add new keys and map them to the new ARB strings ---
    final featureTitles = {
      'photo': localizations.featurePhotoTitle,
      'offline': localizations.featureOfflineTitle,
      'roleplay': localizations.featureRoleplayTitle,
      'plural': localizations.featurePluralTitle,
      'document': localizations.featureDocumentTitle,
      'audio': localizations.featureAudioTitle,
      'image_generation': localizations.featureImageGenerationTitle,
      // Existing optional features
      'supermodel': localizations.featureSupermodelTitle,
      'indulgent': localizations.featureIndulgentTitle,
      'wise': localizations.featureWiseTitle,
      'researcher': localizations.featureResearcherTitle
    };
    final featureDescriptions = {
      'photo': localizations.featurePhotoDescription,
      'offline': localizations.featureOfflineDescription,
      'roleplay': localizations.featureRoleplayDescription,
      'plural': localizations.featurePluralDescription,
      'document': localizations.featureDocumentDescription,
      'audio': localizations.featureAudioDescription,
      'image_generation': localizations.featureImageGenerationDescription,
      // Existing optional features
      'supermodel': localizations.featureSupermodelDescription,
      'indulgent': localizations.featureIndulgentDescription,
      'wise': localizations.featureWiseDescription,
      'researcher': localizations.featureResearcherDescription
    };
    // The rest of the function remains unchanged as it's data-driven.
    List<Widget> items = [];
    for (int i = 0; i < _parsedFeatures.length; i++) {
      final featureKey = _parsedFeatures[i];
      if (!featureTitles.containsKey(featureKey)) continue;
      items.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(featureTitles[featureKey] ?? '',
            style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500)),
        SizedBox(height: screenWidth * 0.01),
        Text(featureDescriptions[featureKey] ?? '',
            style: TextStyle(
                color: AppColors.quinaryColor, fontSize: screenWidth * 0.035))
      ]));
      if (i < _parsedFeatures.length - 1) {
        items.add(SizedBox(height: screenWidth * 0.02));
        items.add(Divider(color: AppColors.border, thickness: 1));
        items.add(SizedBox(height: screenWidth * 0.02));
      } else {
        items.add(SizedBox(height: screenWidth * 0.02));
      }
    }
    return _buildSectionContainer(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSectionTitle(
              localizations, 'featuresSection', isDarkTheme, screenWidth),
          SizedBox(height: screenWidth * 0.02),
          ...items
        ]),
        isDarkTheme,
        screenWidth);
  }

  Widget _buildSectionTitle(AppLocalizations localizations, String sectionKey,
      bool isDarkTheme, double screenWidth) {
    String sectionTitle;
    switch (sectionKey) {
      case 'descriptionSection':
        sectionTitle = localizations.descriptionSection;
        break;
      case 'ratingSection':
        sectionTitle = localizations.ratingsSection;
        break;
      case 'featuresSection':
        sectionTitle = localizations.capabilitiesSection;
        break;
      case 'baseModelSection':
        sectionTitle = localizations.baseModelTitle;
        break;
      default:
        sectionTitle = '';
    }
    return Text(sectionTitle,
        style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600));
  }

  Widget _buildSectionContainer(
      Widget child, bool isDarkTheme, double screenWidth) =>
      Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(screenWidth * 0.04)),
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: child);
}
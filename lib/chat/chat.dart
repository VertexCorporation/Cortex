// chat.dart
//
// This file defines the ChatScreen widget, which manages all chat-related functionality.
// Displaying/sending/editing messages, model loading, response management, and UI state control are handled here.
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow
// wow

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/screen/appbar/appbar.dart';
import 'package:cortex/chat/screen/selected/input/input.dart';
import 'package:cortex/chat/screen/selected/input/panels/briefing.dart';
import 'package:cortex/chat/screen/selected/input/panels/edit.dart';
import 'package:cortex/chat/screen/selected/screen.dart';
import 'package:cortex/chat/screen/unselected/screen/screen.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/load.dart';
import 'package:cortex/chat/services/read.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../banner.dart';
import '../cache.dart';
import '../errorview.dart';
import '../extensions.dart';
import '../funds/subscriptions/subscriptions.dart';
import '../invite.dart';
import '../models/backend/data.dart';
import '../models/backend/download.dart';
import '../models/backend/system_info.dart';
import '../navigation.dart';
import '../server/credits.dart';
import '../settings/settings.dart';
import '../main.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'messages/options.dart';
import 'messages/report.dart';
import 'services/api.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'services/limit.dart';
import 'messages/messages.dart';

/// The ChatScreen widget builds the chat UI and manages its state.
class ChatScreen extends StatefulWidget {
  String? conversationID;
  String? conversationTitle;

  final String? modelTitle;
  final String? modelDescription;
  final String? modelImagePath;
  final String? modelProducer;
  final String? modelPath;
  final String? role;
  final String? modelId;
  final void Function(bool isSelected)? onModelSelectionChanged;

  ChatScreen({
    super.key,
    this.conversationID,
    this.conversationTitle,
    this.modelId,
    this.modelTitle,
    this.modelDescription,
    this.modelImagePath,
    this.modelProducer,
    this.modelPath,
    this.role,
    this.onModelSelectionChanged,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

/// ChatScreenState manages the state for the ChatScreen widget.
class ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController searchController = TextEditingController();

  List<Message> messages = [];

  final TextEditingController controller = TextEditingController();

  bool isModelLoaded = false, isSendButtonVisible = false;

  final ValueNotifier<bool> isWaitingForResponseNotifier =
      ValueNotifier<bool>(false);

  bool get isWaitingForResponse => isWaitingForResponseNotifier.value;

  final uuid = const Uuid();
  String? conversationID, conversationTitle;
  final FocusNode textFieldFocusNode = FocusNode();
  bool _isSending = false, canHandleImage = false, responseStopped = false;
  int? editingMessageIndex;
  String? originalMessageText;
  List<String> roleplayModels = [], serverSideModels = [];
  String? modelId;
  bool _showInappropriateMessageWarning = false;

  bool shouldAutofocus = true;

  bool _modelsLoadError = false;
  bool _areModelsLoading = true; // Start in loading state.

  late AnimationController _warningAnimationController,
      _searchAnimationController;
  late Animation<double> _warningFadeAnimation;

  late VoidCallback _downloadedModelsListener;
  String? selectedModelCategory;

  bool isCurrentModelServerSide = false;
  bool currentModelHasWise = false;

  bool showScrollDownButtonByPosition = false;
  bool hasInternetConnection = true;
  late StreamSubscription<InternetStatus> _internetSubscription;
  Map<String, dynamic>? _userData;
  Timer? chunkTimer;
  final List<String> responseChunksQueue = [];
  bool isModelSelected = false;
  bool isStorageSufficient = true;
  static const int requiredSizeMB = 1024;
  SystemInfoData? _systemInfo;
  String? modelTitle,
      modelDescription,
      modelImagePath,
      modelProducer,
      modelPath,
      role;
  static bool languageHasJustChanged = false;
  bool _isPhotoLoading = false;
  set isWaitingForResponse(bool newValue) {
    if (isWaitingForResponseNotifier.value != newValue) {
      isWaitingForResponseNotifier.value = newValue;
      if (mounted) {
        setState(() {});
      }
    }
  }

  final GlobalKey _exitButtonKey = GlobalKey();
  final GlobalKey _accountButtonKey = GlobalKey();
  static const MethodChannel llamaChannel =
      MethodChannel('com.vertex.cortex/llama');
  final ScrollController _scrollController = ScrollController();
  bool _conversationLimitReached = false, openedFromMenu = false;
  StreamSubscription<DocumentSnapshot>? _creditsSubscription;
  String selectedExtensionLabel = '';
  final GlobalKey _extensionKey = GlobalKey();
  GlobalKey<InputFieldState> inputFieldKey = GlobalKey<InputFieldState>();
  final GlobalKey _inputSectionKey = GlobalKey();
  final GlobalKey _briefingOverlayKey = GlobalKey();
  double _inputSectionHeight = 0.0;
  late CreditsManager creditsManager;
  bool isEditingMode = false;
  late AnimationController editPanelController;
  late Animation<Offset> _slideAnimation;
  DownloadedModelsManager? _downloadedModelsManager;
  ValueNotifier<bool> streamingNotifier = ValueNotifier<bool>(false);

  late final Extensions extensions;
  late final LoadService loadService;
  late final SendService sendService;
  late final ReadService readService;
  late final SelectionService selectionService;
  late final ScrollService scrollService;
  late final RegenerateService regenerateService;
  late final StopService stopService;
  late final EditService editService;
  late final ContextService contextService;
  late final ResponseService responseService;
  late ChatLimitManager chatLimitManager;
  late ApiService apiService;

  int editSessionCounter = 0;

  Locale? _currentLocale;

  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  bool _showInviteBanner = false;

  // A static flag to track if the disclaimer has been shown in the current app session.
  static bool _disclaimerHasBeenShownThisSession = false;

  // A non-static flag to control the visibility in the current widget instance.
  bool _showDisclaimerOverlay = false;

  // --- NEW STATE FLAG ---
  // A flag to determine if the photo warning should be shown.
  bool _showPhotoWarningOverlay = false;

  // This flag ensures the heavy context-dependent setup runs only once.
  bool _isInitialSetupComplete = false;

  // --- NEW STATE for Premium Banner ---
  bool showPremiumBriefing = false;

  bool isUserSubscribed = false;
  int premiumTrialUses = 0;
  
  // This listener now correctly handles data changes by re-syncing its local
  // state from the single source of truth (ModelData), bypassing any stale caches.
  void _handleModelDataChange() {
    debugPrint(
        "[ChatScreenState] Received a data change notification from ModelData.");
    if (mounted) {
      debugPrint(
          "[ChatScreenState] Re-initializing model list from the definitive source (ModelData).");

      loadService.initializeFromCache();

      setState(() {
        debugPrint(
            "[ChatScreenState] UI rebuild triggered. The selection screen will now show the new model.");
      });
    }
  }

  Future<bool> willInfoPanelShowOnNextSelect() async {
    if (Appbar.extensionInfoShownThisSession) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      int showCount = prefs.getInt(Appbar.extensionInfoCountKey) ?? 0;
      return showCount < 3;
    } catch (e) {
      debugPrint("SharedPreferences error: $e");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // --- 1. NON-CONTEXT-DEPENDENT INITIALIZATION ---
    // All of these are safe to run in initState because they don't use `context`.

    ModelData.addListener(_handleModelDataChange);

    // Initialize services
    creditsManager = Provider.of<CreditsManager>(context, listen: false);
    _downloadedModelsManager = Provider.of<DownloadedModelsManager>(context,
        listen: false);
    chatLimitManager = const ChatLimitManager(
      cortexSubscription: 0,
      subscriptionExpiresAt: null,
    );
    extensions = Extensions(vsync: this);
    scrollService = ScrollService(scrollController: _scrollController);
    stopService = StopService(this);
    editService = EditService(state: this);
    contextService = ContextService(this);
    regenerateService = RegenerateService(state: this);
    selectionService = SelectionService(state: this);
    sendService = SendService(this);
    readService = ReadService(this);
    responseService = ResponseService(this);
    // Initialize the LoadService and attempt a synchronous cache load.
    loadService = LoadService(this);
    loadService.initializeFromCache();

    // Initialize controllers and listeners
    searchController.addListener(_onSearchChanged);
    _initializeAnimationControllers();
    _initializeListeners();

    // Initialize state from widget properties
    _initializeFromWidget();
    _checkAndTriggerInviteBanner();

    // --- FIX IS APPLIED HERE ---
    // The call to the now-robust function ensures premium status is checked correctly on initial load.
    _updatePremiumBriefingVisibility(widget.modelId);
  }

  /// --- THE DEFINITIVE FIX ---
  /// This function now robustly checks if a model is premium, correctly handling
  /// character models by inspecting their base model's tier. This logic is now
  /// consistent with SelectionService, fixing the bug where the banner wouldn't
  /// show when opening conversations from the inbox.
  void _updatePremiumBriefingVisibility(String? modelIdToCheck) {
    if (modelIdToCheck == null) {
      if (showPremiumBriefing) setState(() => showPremiumBriefing = false);
      return;
    }

    bool isPremium = false; // Default to not premium
    final preciseModelData = ModelData.getPreciseModelData(modelIdToCheck);
    final category = preciseModelData['category'] as String?;

    if (category == 'self' || category == 'roleplay') {
      // For characters, premium status is determined by their base model.
      final String? baseModelId = preciseModelData['baseModelId'] as String?;
      if (baseModelId != null && baseModelId.isNotEmpty) {
        final Map<String, dynamic> baseModelData = ModelData.getPreciseModelData(baseModelId);
        isPremium = (baseModelData['tier'] as String? ?? 'free') == 'premium';
        debugPrint("[ChatScreen] Character model detected. Premium status based on base model '$baseModelId': $isPremium");
      }
    } else {
      // For all other models, check the tier of the model/extension itself.
      isPremium = (preciseModelData['tier'] as String? ?? 'free') == 'premium';
    }

    // Only call setState if the value has actually changed to avoid unnecessary rebuilds.
    if (isPremium != showPremiumBriefing) {
      setState(() {
        showPremiumBriefing = isPremium;
      });
    }
  }

  void _navigateToPremiumScreen() {
    if (extensions.isPanelVisible) {
      extensions.closePanel();
    }
    FocusScope.of(context).unfocus();
    navigateToScreen(
      context,
      PremiumScreen(),
      direction: const Offset(0.0, 1.0),
    );
  }

  Future<void> _checkAndTriggerInviteBanner() async {
    const String key = 'inviteBannerLastShownTimestamp';
    const int showIntervalInHours = 24;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? lastShownTimestamp = prefs.getInt(key);

      if (lastShownTimestamp == null) {
        debugPrint("[Banner Logic] No dismissal timestamp found. Displaying banner.");
        _displayBanner();
        return;
      }

      final DateTime lastDismissalTime = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
      final Duration difference = DateTime.now().difference(lastDismissalTime);

      if (difference.inHours >= showIntervalInHours) {
        debugPrint("[Banner Logic] More than 24 hours have passed since last dismissal. Showing again.");
        _displayBanner();
      } else {
        debugPrint("[Banner Logic] Banner was dismissed within the last 24 hours. Skipping.");
      }
    } catch (e) {
      debugPrint("[Banner Logic] SharedPreferences error: $e");
    }
  }

  void _displayBanner() {
    if (mounted && !_showInviteBanner) {
      setState(() {
        _showInviteBanner = true;
      });
      debugPrint("[Banner Logic] Banner visibility set to true.");
    }
  }

  Future<void> _startTimestampCooldown() async {
    try {
      const String key = 'inviteBannerLastShownTimestamp';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
      debugPrint("[Banner Logic] Dismissal confirmed. 24-hour cooldown timestamp has been set.");
    } catch (e) {
      debugPrint("[Banner Logic] Failed to set cooldown timestamp: $e");
    }
  }

  /// A public method to allow external widgets (like the Appbar) to request the banner to be shown.
  /// It respects the "already shown" logic by only setting the state if the banner is not already visible.
  void showInviteBanner() {
    if (mounted && !_showInviteBanner) {
      debugPrint("[ChatScreen] A manual request was made to show the invite banner.");
      setState(() {
        _showInviteBanner = true;
      });
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);

    // Run the main setup only once, the first time this method is called.
    if (!_isInitialSetupComplete) {
      debugPrint(
          "[ChatScreenState] didChangeDependencies: Running initial context-aware setup.");
      _currentLocale = newLocale; // Set the initial locale.

      // Initialize services that need AppLocalizations
      apiService = ApiService(localizations: AppLocalizations.of(context)!);

      // Trigger the main asynchronous data loading process.
      _performInitialAsyncSetup();

      _isInitialSetupComplete = true;
      return; // Exit after initial setup.
    }

    // On subsequent runs, if the new locale is different from the one we have
    // stored, it means the user has changed the language in settings.
    if (_currentLocale != null && _currentLocale != newLocale) {
      debugPrint(
          "[ChatScreenState] Language change detected via locale. From '$_currentLocale' to '$newLocale'.");
      _currentLocale = newLocale;

      ModelData.clearCache();

      _reloadAllModelsForLanguageChange();
    }
  }

  /// This function is now safely called from `didChangeDependencies`.
  /// It now correctly returns a Future<void>.
  Future<void> _performInitialAsyncSetup() async {

    if (loadService.modelsLoaded) {
      debugPrint(
          "[ChatScreenState] Models already loaded from cache. UI is ready.");
      if (mounted) {
        setState(() {
          _areModelsLoading = false;
        });
      }
    } else {
      debugPrint(
          "[ChatScreenState] Cache was empty. Performing full model load.");
      // This 'await' is now valid because the function returns a Future.
      await _reloadAllModelsForLanguageChange();
    }

    // Other async setup tasks can run after models are loaded
    await Future.wait([
      _updateInternetStatus(),
      _fetchSystemInfo(),
      _loadUserData(),
    ]);
  }

  /// A central function to reload all model data with robust state handling.
  /// It now returns a Future<void> to be properly await-able.
  Future<void> _reloadAllModelsForLanguageChange() async {
    debugPrint(
        "[ChatScreen] Reloading all models due to a trigger (e.g., download complete, language change, retry button).");

    if (mounted) {
      setState(() {
        _areModelsLoading = true;
        _modelsLoadError = false;
      });
    }

    try {
      // The loadService will internally get the correct, current language from the context.
      await loadService.loadModels();
      if (!mounted) return;

      setState(() {
        _areModelsLoading = false;
        _modelsLoadError = loadService.allModels.isEmpty;

        if (!_modelsLoadError && isModelSelected && modelId != null) {
          loadService.updateModelDataFromId();
        }
      });
    } catch (e) {
      debugPrint("[ChatScreen.reload] Critical error on reload: $e");
      if (mounted) {
        setState(() {
          _areModelsLoading = false;
          _modelsLoadError = true;
        });
      }
    }
  }

  void _initializeListeners() {
    // Define what the listener does: simply calls the main reload function.
    _downloadedModelsListener = () async {
      debugPrint(
          "[ChatScreen] DownloadedModelsManager listener triggered. Reloading models UI.");
      await _reloadAllModelsForLanguageChange();
    };
    // Attach the listener to the manager.
    _downloadedModelsManager?.addListener(_downloadedModelsListener);

    Provider.of<FileDownloadHelper>(context, listen: false)
        .addListener(() async {
      await loadService.loadModels();
    });

    _scrollController.addListener(_scrollListener);
    _internetSubscription =
        InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(
            () => hasInternetConnection = status == InternetStatus.connected);
      }
    });

    _warningAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _showInappropriateMessageWarning = false);
      }
    });

    llamaChannel.setMethodCallHandler(_methodCallHandler);
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        // The filtering logic now lives in the build method.
        // This just tells Flutter that the state has changed and a rebuild is needed.
      });
    }
  }

  void _initializeAnimationControllers() {
    _warningAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _warningFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _warningAnimationController, curve: Curves.easeIn));

    _searchAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    editPanelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: editPanelController, curve: Curves.easeOut));
  }

  void _initializeFromWidget() {
    conversationID = widget.conversationID;
    conversationTitle = widget.conversationTitle;
    modelId = widget.modelId;
    modelTitle = widget.modelTitle;
    modelDescription = widget.modelDescription;
    modelImagePath = widget.modelImagePath;
    modelProducer = widget.modelProducer;
    modelPath = widget.modelPath;

    debugPrint(
        "🤔 [LOG 3 - chat.dart] Initializing from widget. The 'widget.role' passed during navigation is: '${widget.role ?? 'NULL'}'");

    if (widget.modelId != null) {
      debugPrint(
          "✅ [LOG 3 - chat.dart] Model ID '${widget.modelId}' exists. Re-fetching precise model data to ensure role is loaded.");
      final preciseModelData = ModelData.getPreciseModelData(widget.modelId!);

      role = preciseModelData['role'] as String?;
      debugPrint(
          "✅ [LOG 3 - chat.dart] Role re-fetched. The correct role is: ${role != null ? "'${role?.substring(0, (role!.length > 40) ? 40 : role?.length)}...'" : "NULL"}");
    } else {
      role = widget.role;
    }

    if (widget.modelId != null) {
      isModelSelected = true;
      canHandleImage = ModelData.hasModality(widget.modelId!, 'image');
      final modelData = ModelData.getPreciseModelData(widget.modelId!);
      if (modelData['type'] != 'offline') {
        isModelLoaded = true; // Server-side models are always "loaded".
      } else if (modelData['path'] != null) {
        loadService.loadModel(); // Trigger local model loading.
      }
    }

    if (widget.conversationID != null) {
      readService.loadPreviousMessages(widget.conversationID!);
    }
  }

  /// Instead of a one-time fetch, it subscribes to the user's document in Firestore.
  /// It now also parses and manages the state for daily premium trials and subscription status.
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _userDataSubscription?.cancel();

    _userDataSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data();
        setState(() {
          _userData = data;
          final int subscriptionLevel = data?['hasCortexSubscription'] ?? 0;
          final Timestamp? expiresAt =
          data?['subscriptionExpiresAt'] as Timestamp?;

          isUserSubscribed = subscriptionLevel > 0;

          final Timestamp? lastResetTimestamp = data?['premiumModelTrialLastReset'] as Timestamp?;
          int trialUses = data?['premiumModelTrialUses'] as int? ?? 0;

          if (lastResetTimestamp != null) {
            final lastResetDate = lastResetTimestamp.toDate();
            final now = DateTime.now();
            if (lastResetDate.year != now.year ||
                lastResetDate.month != now.month ||
                lastResetDate.day != now.day) {
              trialUses = 0;
            }
          }
          premiumTrialUses = trialUses;
          debugPrint("[ChatScreen] User data updated. Subscribed: $isUserSubscribed, Trials used: $premiumTrialUses");

          chatLimitManager = ChatLimitManager(
            cortexSubscription: subscriptionLevel,
            subscriptionExpiresAt: expiresAt,
          );
        });
      }
    }, onError: (error) {
      debugPrint("Error listening to user data: $error");
    });
  }

  Future<void> _fetchSystemInfo() async {
    try {
      SystemInfoData info = await SystemInfoProvider.fetchSystemInfo();

      if (!mounted) return; // If not, exit the function immediately.

      setState(() {
        _systemInfo = info;
        isStorageSufficient = _systemInfo!.freeStorage >= requiredSizeMB;
      });
    } catch (e) {
      print("Error fetching system info: $e");
      if (!mounted) return;

      setState(() {
        isStorageSufficient = false;
      });
    }
  }


  /// Listener for the scroll controller.
  /// This now ONLY updates the state based on scroll position.
  /// The final decision to show the button is made in the `build` method.
  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    // Determine if the button should be shown based purely on scroll position
    final bool shouldShowBasedOnPosition =
        !scrollService.isUserAtBottom() && messages.length > 1;

    // Only call setState if the positional visibility changes to avoid unnecessary rebuilds
    if (showScrollDownButtonByPosition != shouldShowBasedOnPosition) {
      setState(() {
        showScrollDownButtonByPosition = shouldShowBasedOnPosition;
      });
    }
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (!mounted) return;

    switch (call.method) {
      case 'onMessageResponse':
        final String token = call.arguments as String? ?? '';
        if (token.isNotEmpty) {
          responseService.onMessageResponse(token);
        }
        break;

      case 'onMessageComplete':
        debugPrint(
            "[ChatScreen] Received onMessageComplete signal from native. Finalizing response.");
        // Delegate finalization to the centralized ResponseService.
        responseService.finalizeResponse();
        break;

      case 'onModelLoaded':
        debugPrint("[ChatScreen] Received onModelLoaded signal.");
        setState(() {
          isModelLoaded = true;
        });
        break;

      default:
        debugPrint("[ChatScreen] Received unknown method call: ${call.method}");
        break;
    }
  }

  bool isLocalModel(String? modelId) => !isServerSideModel(modelId);

  bool isServerSideModel(String? modelId) {
    if (modelId != null && modelId == this.modelId) {
      return isCurrentModelServerSide;
    }
    if (modelId == null || modelId.isEmpty) {
      return false;
    }
    final modelData = ModelData.getPreciseModelData(modelId);
    return modelData['type'] != 'offline';
  }

  bool get hasWise {
    return currentModelHasWise;
  }

  Future<void> resetConversation({bool resetModel = false}) async {
    setState(() {
      messages.clear();
      conversationID = null;
      conversationTitle = null;
      widget.conversationID = null;
      widget.conversationTitle = null;
      isWaitingForResponse = false;
      isSendButtonVisible = false;
      responseStopped = false;
      if (resetModel) {
        isModelSelected = false;
        isModelLoaded = false;
      }
    });
  }

  Map<String, dynamic> getModelDataFromId(String targetModelId) {
    debugPrint(
        "[ChatScreenState.getModelDataFromId] Fetching data for '$targetModelId' using central ModelData service.");
    return ModelData.getPreciseModelData(targetModelId);
  }

  bool isSelfModel(String? modelId) => selectedModelCategory == 'self';

  void markMessageAsReported(String aiMessage) {
    final index =
        messages.indexWhere((m) => !m.isUserMessage && m.text == aiMessage);
    if (index == -1) return;
    setState(() {
      messages[index].isReported = true;
    });
    ChatStorageService.updateStoredMessage(
        conversationID!, messages[index], index);
  }

  Future<void> _handleExit() async {
    dismissCurrentMessageOptions();

    if (extensions.isPanelVisible) {
      extensions.closePanel();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await resetConversation(resetModel: true);

    // We are exiting model selection, so we send 'false'.
    widget.onModelSelectionChanged?.call(false);
    debugPrint(
        "[ChatScreen._handleExit] Callback called with 'false' to show BottomAppBar.");

    if (openedFromMenu) {
      mainScreenKey.currentState?.onItemTapped(2);
    }
    // The direct call to mainScreenKey.currentState?.updateBottomAppBarVisibility is no longer needed.

    setState(() {
      isModelSelected = false;
      isModelLoaded = false;
      modelTitle = null;
      modelImagePath = null;
      modelProducer = null;
      modelPath = null;
      role = null;
      openedFromMenu = false;
      showPremiumBriefing = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (isModelSelected) {
      await _handleExit();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    ModelData.removeListener(_handleModelDataChange);
    if (isModelSelected && isLocalModel(modelId)) {
      llamaChannel.invokeMethod('unloadModel');
    }
    _userDataSubscription?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    extensions.dispose();
    isWaitingForResponseNotifier.dispose();

    _downloadedModelsManager?.removeListener(_downloadedModelsListener);

    WidgetsBinding.instance.removeObserver(this); // Stop observing
    _creditsSubscription?.cancel();
    controller.dispose();
    CacheService.startModelCacheTimer(
      onClear: () {
        debugPrint("Model cache cleared from ChatScreen dispose.");
      },
    );
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _warningAnimationController.dispose();
    _searchAnimationController.dispose();
    llamaChannel.setMethodCallHandler(null);
    _internetSubscription.cancel();
    textFieldFocusNode.unfocus();
    textFieldFocusNode.dispose();
    showScrollDownButtonByPosition = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("[ChatScreen] AppLifecycle: resumed.");
        _updateInternetStatus();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (isModelSelected && isLocalModel(modelId)) {
          debugPrint(
              "[ChatScreen] AppLifecycle: $state. Yerel model için 'unloadModel' komutu gönderiliyor.");
          llamaChannel.invokeMethod('unloadModel');
        }
        break;
    }
  }

  /// This method is called by the `WidgetsBindingObserver` whenever the app's
  /// metrics change, which includes when the keyboard appears or disappears.
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  void _updateInputSectionHeight() {
    final RenderBox? box =
        _inputSectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final newHeight = box.size.height;
      if (_inputSectionHeight != newHeight) {
        setState(() {
          _inputSectionHeight = newHeight;
        });
      }
    }
  }

  // --- NEW & BULLETPROOF ---
  /// Triggers the disclaimer overlay to be shown if it hasn't been already in this session.
  /// This method is called by services when a chat becomes active.
  void triggerDisclaimer() {
    if (!mounted) return;
    // Only show if it hasn't been shown before in this session.
    if (!_disclaimerHasBeenShownThisSession) {
      // Use a post-frame callback to ensure setState is not called during a build,
      // which can happen if a service calls this method during a state update.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showDisclaimerOverlay = true;
          });
        }
      });
    }
  }

// This allows external services like ReadService to report an error
// without violating encapsulation by accessing private variables.
  void showModelLoadError() {
    if (mounted) {
      setState(() {
        _modelsLoadError = true;
        isModelSelected = false; // Ensure we fall back to the selection screen
      });
    }
  }

  /// This is the single, authoritative function for changing an extension within an active chat.
  /// Its responsibilities are now refined:
  /// 1. Update the active chat's state for the NEXT message.
  /// 2. Persist the user's choice as the NEW GLOBAL DEFAULT for the model series.
  /// It NO LONGER writes to the conversation's database record.
  /// This is the single, authoritative function for changing an extension within an active chat.
  Future<void> _handleChangeModelExtension(String newFullModelId) async {
    final String logPrefix = "[ChatScreen._handleChangeModelExtension]";
    final String? currentModelId = modelId;

    if (currentModelId == newFullModelId) {
      if (extensions.isPanelVisible) extensions.closePanel();
      return;
    }
    debugPrint(
        "$logPrefix Changing active model from '$currentModelId' to '$newFullModelId'");

    // --- IMMEDIATE UI RESPONSE ---
    extensions.animateExtensionChange(newFullModelId);
    if (extensions.isPanelVisible) extensions.closePanel();

    await loadService.loadModels();

    final parentModelInfo = loadService.allModels.firstWhere((modelInfo) {
      final modelData = ModelData.getPreciseModelData(modelInfo.id);
      final extensionsMap = modelData['extensions'] as Map<String, dynamic>?;
      return extensionsMap?.containsKey(newFullModelId) ?? false;
    }, orElse: () {
      debugPrint(
          "$logPrefix CRITICAL: Could not find any parent model series for '$newFullModelId'.");
      return ModelInfo(
          id: "fallback", title: "Unknown", imagePath: "", producer: "");
    });

    if (parentModelInfo.id == "fallback") return;

    await Extensions.setLastSelectedExtension(
        parentModelInfo.id, newFullModelId);
    debugPrint(
        "$logPrefix SUCCESS: Set '$newFullModelId' as the new default for series '${parentModelInfo.id}'.");

    final preciseModelData = ModelData.getPreciseModelData(newFullModelId);
    final bool definitiveCanHandleImage =
    ModelData.hasModality(newFullModelId, 'image');

    setState(() {
      modelId = newFullModelId;
      role = preciseModelData['role'] as String? ?? role;
      canHandleImage = definitiveCanHandleImage;
    });

    _updatePremiumBriefingVisibility(newFullModelId);

    debugPrint(
        "$logPrefix Active chat state transiently updated to use '$newFullModelId'.");
  }

  final InviteService _inviteService = InviteService();
  bool _isSharingLink = false;

  Future<void> _generateAndShareInviteLink() async {
    if (_isSharingLink) return;

    setState(() { _isSharingLink = true; });

    try {
      await _inviteService.createAndShareReferralLink(context);
    } catch (e) {
      debugPrint('[ChatScreen] Error for invite system: $e');
    } finally {
      if (mounted) {
        setState(() { _isSharingLink = false; });
      }
    }
  }

  /// Builds the main UI for the ChatScreen.
  ///
  /// This method uses a `Stack` as its core layout to allow for overlaying widgets
  /// like the scroll-down button, informational banners, and credit displays on top
  /// of the main chat content.
  ///
  @override
  Widget build(BuildContext context) {
    debugPrint("[ChatScreen Build] Starting UI build process.");

    // --- Dynamic UI State Calculation ---
    // These variables are calculated on every build to ensure the UI reacts
    // correctly to changes like keyboard visibility or new messages.
    final screenWidth = MediaQuery.of(context).size.width;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // The final decision for the scroll-down button depends on both scroll position AND keyboard visibility.
    final bool showScrollDownButtonFinal = showScrollDownButtonByPosition && !isKeyboardVisible;
    debugPrint('[ChatScreen Build] Rendering UI. Scroll button will be ${showScrollDownButtonFinal ? 'visible' : 'hidden'}.');

    // Determine if the photo warning overlay should be shown. It appears only when a photo is present
    // AND the main disclaimer isn't already taking precedence.
    final bool isPhotoPresentInChat = messages.any((m) => m.photoPath != null && m.photoPath!.isNotEmpty) || (sendService.selectedPhoto != null);
    _showPhotoWarningOverlay = isPhotoPresentInChat && !_showDisclaimerOverlay;

    // Filter the list of models based on the search controller's text for the selection screen.
    final List<ModelInfo> filteredModels = searchController.text.isEmpty
        ? loadService.allModels
        : loadService.allModels
        .where((model) => model.title.toLowerCase().startsWith(searchController.text.toLowerCase()))
        .toList();

    // Ensure the input section height is measured after the frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateInputSectionHeight());

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        appBar: Appbar(
          isModelSelected: isModelSelected,
          modelTitle: modelTitle,
          modelImagePath: modelImagePath,
          exitButtonKey: _exitButtonKey,
          accountButtonKey: _accountButtonKey,
          userData: _userData,
          extensionKey: _extensionKey,
          onExit: () async {
            if (extensions.isPanelVisible) {
              extensions.closePanel();
              await Future.delayed(const Duration(milliseconds: 300));
            }
            await _handleExit();
          },
          onAccountTap: () async {
            if (extensions.isPanelVisible) {
              extensions.closePanel();
              await Future.delayed(const Duration(milliseconds: 300));
            }
            FocusScope.of(context).unfocus();
            navigateToScreen(
              context,
              SettingsScreen(isFromActiveChat: isModelSelected),
              direction: const Offset(1.0, 0.0),
            );
          },
          onInfoPanelWillShow: () {
            FocusScope.of(context).unfocus();
          },
          onInfoPanelDidHide: () {
            textFieldFocusNode.requestFocus();
          },
          onTitleTap: () async {
            if (!extensions.isPanelVisible) {
              extensions.showExtensionPanel(
                context: context,
                extensionKey: _extensionKey,
                modelTitle: modelTitle ?? "",
                updateModelId: (selectedEntryKey) async {
                  await _handleChangeModelExtension(selectedEntryKey);
                },
              );
            } else {
              extensions.closePanel();
            }
          },
          onExtensionTap: () async {
            if (!extensions.isPanelVisible) {
              extensions.showExtensionPanel(
                context: context,
                extensionKey: _extensionKey,
                modelTitle: modelTitle ?? "",
                updateModelId: (selectedEntryKey) async {
                  await _handleChangeModelExtension(selectedEntryKey);
                },
              );
            } else {
              extensions.closePanel();
            }
          },
          appTitle: AppLocalizations.of(context)!.appTitle,
          extensions: extensions,
          onCreditsInfoTapped: showInviteBanner,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // --- LAYER 1: Main Content Column ---
              // This Column holds the core content that scrolls (messages) and the input field.
              // It is the base layer of our Stack.
              Column(
                children: [
                  // This is the main content area that expands to fill available space.
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: !isModelSelected
                          ? _modelsLoadError
                          ? ErrorView(
                        key: const ValueKey('chat_error'),
                        title: AppLocalizations.of(context)!.errorLoadingTitle,
                        message: AppLocalizations.of(context)!.errorLoadingMessage,
                        buttonText: AppLocalizations.of(context)!.retry,
                        onRetry: _reloadAllModelsForLanguageChange,
                      )
                          : SelectionScreen(
                        key: const ValueKey('selection'),
                        isLoading: _areModelsLoading,
                        searchController: searchController,
                        allModels: loadService.allModels,
                        filteredModels: filteredModels,
                        onReloadModels: _reloadAllModelsForLanguageChange,
                        hasInternetConnection: hasInternetConnection,
                        conversationLimitReached: _conversationLimitReached,
                        onSelectModel: selectionService.selectModel,
                        onScrollToBottom: scrollService.scrollToBottom,
                        localizations: AppLocalizations.of(context)!,
                        isServerSideModel: isServerSideModel(modelId),
                      )
                          : (!readService.areMessagesLoaded
                          ? readService.buildSkeletonChatMessages()
                          : SelectedScreen(
                        key: const ValueKey('selected'),
                        messages: messages,
                        scrollController: _scrollController,
                        isEditingMode: isEditingMode,
                        editingMessageIndex: editingMessageIndex,
                        streamingNotifier: streamingNotifier,
                        modelImagePath: modelImagePath,
                        modelTitle: modelTitle,
                        selectedModelCategory: selectedModelCategory,
                        modelId: modelId,
                        onStop: stopService.stopResponse,
                        onEdit: (index) => editService.startEditingMessage(index),
                        onFadeOutComplete: (index) {
                          setState(() {
                            messages.removeAt(index);
                          });
                        },
                        onRegenerate: (index) => regenerateService.onRegenerate(index),
                        onChangeModel: (index, newFullId) async {
                          await regenerateService.onRegenerate(
                            index,
                            newModelId: newFullId,
                          );
                        },
                        onReport: (index) {
                          final String messageToReport = messages[index].text;
                          final String? currentModelId = modelId;
                          if (currentModelId == null) return;
                          ReportDialog.show(
                            context,
                            aiMessage: messageToReport,
                            modelId: currentModelId,
                            onReportSuccess: () {
                              if (mounted) {
                                setState(() {
                                  messages[index].isReported = true;
                                });
                                ChatStorageService.updateStoredMessage(
                                  conversationID!,
                                  messages[index],
                                  index,
                                );
                              }
                            },
                          );
                        },
                        localizations: AppLocalizations.of(context)!,
                      )),
                    ),
                  ),

                  // The input section at the very bottom of the column.
                  NotificationListener<SizeChangedLayoutNotification>(
                    onNotification: (notification) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateInputSectionHeight();
                      });
                      return true;
                    },
                    child: SizeChangedLayoutNotifier(
                      key: _inputSectionKey,
                      child: _buildInputSection(),
                    ),
                  ),
                ],
              ),

              PremiumModelBanner(
                isVisible: showPremiumBriefing && isModelSelected && !isUserSubscribed,
                onTap: _navigateToPremiumScreen,
              ),

              // --- OVERLAYS (Positioned on top of the Column) ---
              // These widgets are direct children of the Stack, allowing them to be
              // placed anywhere on the screen, independent of the Column's flow.

              // OVERLAY 1: The scroll-down button.
              if (isModelSelected && messages.isNotEmpty)
                scrollService.buildScrollDownButton(
                  screenWidth: screenWidth,
                  inputFieldHeight: _inputSectionHeight,
                  showScrollDownButton: showScrollDownButtonFinal,
                ),

              // OVERLAY 2: Credits, warnings, and disclaimers.
              if (isModelSelected)
                BriefingOverlay(
                  key: _briefingOverlayKey,
                  inputFieldHeight: _inputSectionHeight,
                  availableCredits: creditsManager.totalCreditsNotifier.value,
                  photoSelected: sendService.selectedPhoto != null,
                  isOfflineModel: isLocalModel(modelId),
                  modelPath: modelPath,
                  inappropriate: _showInappropriateMessageWarning,
                  isPremiumModel: showPremiumBriefing,
                  limitReached: chatLimitManager.isLimitExceeded(messages),
                  isStorageSufficient: isStorageSufficient,
                  showDisclaimer: _showDisclaimerOverlay,
                  showPhotoWarning: _showPhotoWarningOverlay,
                  isSubscribed: isUserSubscribed,
                  premiumTrialUses: premiumTrialUses,
                  onDisclaimerDismissed: () {
                    if (mounted) {
                      debugPrint("[ChatScreen] Disclaimer overlay dismissed by user.");
                      setState(() {
                        _showDisclaimerOverlay = false;
                        _disclaimerHasBeenShownThisSession = true;
                      });
                    }
                  },
                ),

              // --- OVERLAY 3: The Floating Banner (DEFINITIVE FIX) ---
              // By using a simple `if` condition, the `FloatingInfoBanner` is only added
              // to the widget tree when `_showInviteBanner` is true. When it is added,
              // it becomes a DIRECT child of the `Stack`, which is the correct way
              // to use the `AnimatedPositioned` inside it. All wrapper animation
              // widgets have been removed.
              if (_showInviteBanner && !isModelSelected)
                FloatingInfoBanner(
                  key: const ValueKey('invite_banner'), // Add a key for stability
                  bannerType: BannerType.inviteCredits,
                  // The banner will call this function AFTER its exit animation completes.
                  onDismissed: () {
                    _startTimestampCooldown();

                    if (mounted) {
                      debugPrint("[ChatScreen] Banner dismissed. Removing from tree.");
                      setState(() {
                        _showInviteBanner = false;
                      });
                    }
                  },
                  onTap: _generateAndShareInviteLink,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    final bool isOffline = !isServerSideModel(modelId);
    final bool modelMissing =
        isOffline && !loadService.isModelOnDisk(modelPath);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEditingMode)
          SlideTransition(
            position: _slideAnimation,
            child: EditPanelWidget(
              slideAnimation: _slideAnimation,
              onCancel: () {
                setState(() {
                  editService.cancelEditingMode();
                  inputFieldKey = GlobalKey<InputFieldState>();
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  inputFieldKey.currentState?.clearPhotoPanel();
                });
              },
            ),
          ),
        Container(
          padding: EdgeInsets.zero,
          child: InputField(
            key: inputFieldKey,
            localizations: AppLocalizations.of(context)!,
            autofocus: shouldAutofocus,
            isModelSelected: isModelSelected,
            isLimitExceeded: chatLimitManager.isLimitExceeded(messages),
            controller: controller,
            textFieldFocusNode: textFieldFocusNode,
            onTextChanged: (text) {
              setState(() {
                isSendButtonVisible =
                    text.isNotEmpty || sendService.selectedPhoto != null;
              });
            },
            onSend: () async {
              if ((inputFieldKey.currentState?.isSendButtonEnabled ?? false) &&
                  !_isSending) {
                if (chatLimitManager.isLimitExceeded(messages)) return;
                if (isEditingMode) {
                  await editService.applyEditedMessage();
                } else {
                  sendService.sendMessage();
                }
              }
            },
            onApplyEditedMessage: () async =>
            await editService.applyEditedMessage(),
            isPhotoLoading: _isPhotoLoading,
            slideAnimation: _slideAnimation,
            fadeAnimation: _warningFadeAnimation,
            isOffline: !hasInternetConnection,
            isSending: isWaitingForResponse,
            onStop: stopService.stopResponse,
            onPhotoSelected: (photo) {
              setState(() {
                sendService.selectedPhoto = photo;
                if (isEditingMode && editingMessageIndex != null) {
                  messages[editingMessageIndex!].photoPath = photo?.path;
                }
              });
            },
            canHandleImage: canHandleImage,
            isEditingMode: isEditingMode,
            originalMessageText: originalMessageText,
            preselectedPhoto: (isEditingMode &&
                editingMessageIndex != null &&
                messages[editingMessageIndex!].photoPath != null)
                ? File(messages[editingMessageIndex!].photoPath!)
                : null,
            isStorageSufficient: isStorageSufficient,
            totalCredits: creditsManager.totalCreditsNotifier.value,
            isServerSideModel: isServerSideModel(modelId),
            editSessionCounter: editSessionCounter,
            modelMissing: modelMissing,
            wiseEnabled: hasWise,
            role: role,
            isPremiumModel: showPremiumBriefing,
            isSubscribed: isUserSubscribed,
            premiumTrialUses: premiumTrialUses,
          ),
        ),
      ],
    );
  }

  Future<void> _updateInternetStatus() async {
    bool connection = await InternetConnection().hasInternetAccess;
    if (!mounted) return;
    setState(() {
      hasInternetConnection = connection;
    });
  }
}
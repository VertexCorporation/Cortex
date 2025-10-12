// chat.dart
//
// This file defines the ChatScreen widget, which manages all chat-related functionality.
// Displaying/sending/editing messages, model loading, response management, and UI state control are handled here.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/chat/screen/appbar/appbar.dart';
import 'package:cortex/chat/screen/appbar/chat.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
import 'package:cortex/chat/screen/selected/input/input.dart';
import 'package:cortex/chat/screen/selected/input/panels/briefing.dart';
import 'package:cortex/chat/screen/selected/input/panels/edit.dart';
import 'package:cortex/chat/screen/selected/screen.dart';
import 'package:cortex/chat/screen/selected/dynamic.dart';
import 'package:cortex/chat/screen/unselected/news.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../banner.dart';
import '../cache.dart';
import '../errorview.dart';
import '../extensions.dart';
import '../funds/funds.dart';
import '../initialization.dart';
import '../models/backend/data.dart';
import '../models/backend/download.dart';
import '../models/backend/system_info.dart';
import '../navigation.dart';
import '../notifications.dart';
import '../server/credits.dart';
import '../server/fetch.dart';
import '../settings/settings.dart';
import '../main.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../theme.dart';
import 'messages/options.dart';
import 'messages/report.dart';
import 'services/api.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'services/limit.dart';
import 'messages/messages.dart';

enum AppBarMode {
  notSelected,      // Shows "Cortex" and Credits Bar
  inSelection,      // Shows "Explore" and a Back Button
  modelSelected,    // Shows Model Name and a Back Button
  dynamicChat,      // Shows "Cortex" and a Back Button
}

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
  final GlobalKey<InputFieldState> inputFieldKey = GlobalKey<InputFieldState>();
  final GlobalKey _inputSectionKey = GlobalKey();
  final GlobalKey _briefingOverlayKey = GlobalKey();
  double _inputSectionHeight = 0.0;
  late CreditsManager creditsManager;
  bool isEditingMode = false;
  late AnimationController editPanelController;
  late Animation<Offset> _slideAnimation;
  DownloadedModelsManager? _downloadedModelsManager;
  ValueNotifier<bool> streamingNotifier = ValueNotifier<bool>(false);
  final GlobalKey<SelectionScreenState> selectionScreenKey = GlobalKey<SelectionScreenState>();
  final GlobalKey<ChatTitleState> chatTitleKey = GlobalKey<ChatTitleState>();

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
  late final DynamicChatService dynamicChatService;
  late ChatLimitManager chatLimitManager;
  late ApiService apiService;
  late final BannerService _bannerService;

  int editSessionCounter = 0;

  Locale? _currentLocale;

  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  bool _showInviteBanner = false;

  // A static flag to track if the disclaimer has been shown in the current app session.
  static bool _disclaimerHasBeenShownThisSession = false;

  // A non-static flag to control the visibility in the current widget instance.
  bool _showDisclaimerOverlay = false;

  // This flag now controls the visibility of the "Extension Info" banner.
  bool _showExtensionInfoBanner = false;

  // A flag to determine if the photo warning should be shown.
  bool _showPhotoWarningOverlay = false;

  // This flag ensures the heavy context-dependent setup runs only once.
  bool _isInitialSetupComplete = false;

  // --- NEW STATE for Premium Banner ---
  bool showPremiumBriefing = false;

  bool isUserSubscribed = false;
  int premiumTrialUses = 0;

  List<ModelInfo> _recentModels = [];

  static bool _hasShownDynamicChatThisSession = false;

  // This flag is set when a dynamic chat session starts and persists
  // until the user exits the chat, ensuring its identity is maintained.
  bool isPersistentlyDynamic = false;

  final ValueNotifier<AppBarMode> appBarModeNotifier =
  ValueNotifier<AppBarMode>(AppBarMode.notSelected);

  /// This notifier will directly control the AppBar's appearance, solving
  /// the state synchronization issue between ChatScreen and AppBar.
  /// `true` = Show Model Title & Exit Button
  /// `false` = Show "Explore" & Credits Bar
  final ValueNotifier<bool> isAppBarInChatModeNotifier = ValueNotifier<bool>(false);

  // Add this new state variable at the top of your ChatScreenState class
  Timer? _userDataFetchTimer;

  bool isDynamicChatMode = false;

  // This listener now correctly handles data changes by re-syncing its local
  // state from the single source of truth (ModelData), bypassing any stale caches.
  void _handleModelDataChange() {
    debugPrint("[ChatScreenState] Received a data change notification from ModelData.");
    if (mounted) {
      debugPrint("[ChatScreenState] Re-initializing model list from the definitive source (ModelData).");

      loadService.initializeFromCache();

      _loadRecentModels();

      setState(() {
        debugPrint("[ChatScreenState] UI rebuild triggered. The selection screen will now show the new model.");
      });
    }
  }

  /// It checks conditions and decides whether to set the `_showExtensionInfoBanner` flag,
  /// which will cause the `FloatingInfoBanner` to be rendered in the build method.
  Future<void> triggerExtensionInfoPanelIfNeeded() async {
    // Prevent re-showing if already shown in this session.
    if (ChatTitle.extensionInfoShownThisSession) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int showCount = prefs.getInt(ChatTitle.extensionInfoCountKey) ?? 0;

    if (showCount < 3) {
      if (mounted) {
        setState(() {
          _showExtensionInfoBanner = true;
        });
        await prefs.setInt(ChatTitle.extensionInfoCountKey, showCount + 1);
        ChatTitle.extensionInfoShownThisSession = true;
      }
    }
  }

  @override
  void initState() {
    debugPrint("--- GlobalKey Forensics Report (ChatScreen) ---");
    debugPrint("exitButtonKey: $_exitButtonKey");
    debugPrint("accountButtonKey: $_accountButtonKey");
    debugPrint("extensionKey: $_extensionKey");
    debugPrint("inputFieldKey: $inputFieldKey");
    debugPrint("inputSectionKey: $_inputSectionKey");
    debugPrint("briefingOverlayKey: $_briefingOverlayKey");
    debugPrint("selectionScreenKey: $selectionScreenKey");
    debugPrint("----------------------------------------------");
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    isDynamicChatMode = widget.modelId == null &&
        widget.conversationID == null &&
        !_hasShownDynamicChatThisSession;

    // If we start in dynamic mode, set the persistent flag.
    if (isDynamicChatMode) {
      isPersistentlyDynamic = true;
    }

    if (CacheService.cachedRecentModels != null) {
      _recentModels = CacheService.cachedRecentModels!;
      _areModelsLoading = false;
    }

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
    _bannerService = BannerService();
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
    dynamicChatService = DynamicChatService(this);
    // Initialize the LoadService and attempt a synchronous cache load.
    loadService = LoadService(this);
    loadService.initializeFromCache();

    // Synchronously initialize user data from the fast cache to prevent the '?' flicker on avatar.
    // The live data will still be fetched by _loadUserData later.
    _initializeUserDataFromCache();

    // Initialize controllers and listeners
    searchController.addListener(_onSearchChanged);
    _initializeAnimationControllers();
    _initializeListeners();

    // Initialize state from widget properties
    _initializeFromWidget();
    _bannerService.checkAndTriggerBanner();

    if (widget.modelId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onModelSelectionChanged?.call(true);
      });
    }

    if (isDynamicChatMode) {
      isModelSelected = false;
      appBarModeNotifier.value = AppBarMode.dynamicChat;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        mainScreenKey.currentState?.updateBottomAppBarVisibility(true);
      });

    } else if (widget.modelId != null) {
      isModelSelected = true;
      appBarModeNotifier.value = AppBarMode.modelSelected;
    } else {
      isModelSelected = false;
      appBarModeNotifier.value = AppBarMode.notSelected;
    }

    if (isDynamicChatMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mainScreenKey.currentState?.updateBottomAppBarVisibility(true);
      });
    }

    // The call to the now-robust function ensures premium status is checked correctly on initial load.
    _updatePremiumBriefingVisibility(widget.modelId);
    isAppBarInChatModeNotifier.value = widget.modelId != null;
  }

  // Now robustly focuses the keyboard after the frame is built.
  void resetAndStartDynamicConversation() {
    setState(() {
      messages.clear();
      conversationID = null;
      conversationTitle = null;
      widget.conversationID = null;
      widget.conversationTitle = null;
      isWaitingForResponse = false;
      isSendButtonVisible = false;
      responseStopped = false;
      isModelSelected = false; // Remains false
      isModelLoaded = false;   // Remains false
      isDynamicChatMode = true; // This is the view-mode trigger
      isPersistentlyDynamic = true; // This is the session identity
      appBarModeNotifier.value = AppBarMode.dynamicChat;
    });

    mainScreenKey.currentState?.updateBottomAppBarVisibility(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        textFieldFocusNode.requestFocus();
      }
    });
  }

  /// It ensures that if the user has previously exited the dynamic chat,
  /// they are returned to the model selection screen, not back to the dynamic chat.
  void onReactivated() {
    debugPrint("[ChatScreen] Reactivated. Checking dynamic chat session status.");
    if (_hasShownDynamicChatThisSession && isDynamicChatMode) {
      debugPrint("[ChatScreen] Dynamic chat was previously shown this session. Forcing return to model selection.");
      _handleExit();
    }
  }

  // _handleExit now also ensures the bottom app bar is correctly shown
  // when returning to the model selection screen.
  Future<void> _handleExit() async {
    // If exiting from dynamic chat, set the flag so it doesn't reopen automatically in this session.
    if (appBarModeNotifier.value == AppBarMode.dynamicChat) {
      _hasShownDynamicChatThisSession = true;
      debugPrint("[ChatScreen] Exiting dynamic chat. Session flag set to true.");
    }

    unawaited(refreshRecentModels());
    dismissCurrentMessageOptions();

    if (extensions.isPanelVisible) {
      extensions.closePanel();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // This call resets internal message/conversation state.
    await resetConversation(resetModel: true);

    widget.onModelSelectionChanged?.call(false);

    if (openedFromMenu) {
      mainScreenKey.currentState?.onItemTapped(2);
    }

    searchController.clear();

    // --- TACTICAL FIX ---
    // All state changes are bundled into a single setState call.
    // This ensures that when the widget rebuilds, isModelSelected is definitively false,
    // which prevents _buildChatContent from attempting to render with stale data.
    setState(() {
      isModelSelected = false;
      isModelLoaded = false;
      isDynamicChatMode = false;
      modelId = null; // Explicitly nullify modelId
      modelTitle = null;
      modelImagePath = null;
      modelProducer = null;
      modelPath = null;
      role = null;
      openedFromMenu = false;
      showPremiumBriefing = false;
      isPersistentlyDynamic = false;
    });

    appBarModeNotifier.value = AppBarMode.notSelected;
    // CRITICAL: Explicitly show the bottom navigation bar when returning to the selection screen.
    mainScreenKey.currentState?.updateBottomAppBarVisibility(false);
  }

  /// Initializes user data from the local cache for an instant UI update.
  /// This prevents the avatar from flickering back to '?' on rebuilds.
  Future<void> _initializeUserDataFromCache() async {
    // Use the existing FetchService to load data from SharedPreferences.
    final cachedData = await FetchService.loadCachedUserData();
    if (cachedData != null && mounted) {
      setState(() {
        _userData = cachedData;
      });
      debugPrint("[ChatScreen] Avatar data initialized instantly from cache.");
    }
  }

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
      const FundsScreen(),
      direction: const Offset(0.0, 1.0),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);

    // Run the main setup only once, the first time this method is called.
    if (!_isInitialSetupComplete) {
      debugPrint("[ChatScreenState] didChangeDependencies: Running initial context-aware setup.");
      _currentLocale = newLocale; // Set the initial locale.

      apiService = ApiService(localizations: AppLocalizations.of(context)!);
      _performInitialAsyncSetup();

      _isInitialSetupComplete = true;
      return; // Exit after initial setup.
    }

    // On subsequent runs, if the new locale is different from the one we have stored...
    if (_currentLocale != null && _currentLocale != newLocale) {
      debugPrint("[ChatScreenState] Language change detected via locale. From '$_currentLocale' to '$newLocale'.");
      _currentLocale = newLocale;

      ModelData.clearCache();
      CacheService.invalidateRecentModelsCache();
      _reloadAllModelsForLanguageChange();
      Provider.of<NewsService>(context, listen: false).forceRefresh(context);
    }
  }

  Future<void> _performInitialAsyncSetup() async {
    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;
    debugPrint("[ChatScreenState] Core services are ready. Proceeding with data fetch.");

    if (!loadService.modelsLoaded) {
      debugPrint("[ChatScreenState] Cache was empty. Performing full model load.");
      await _reloadAllModelsForLanguageChange();
    } else {
      debugPrint("[ChatScreenState] Models already loaded from cache. UI is ready.");
      if (mounted) setState(() => _areModelsLoading = false);
    }

    if (isDynamicChatMode || isPersistentlyDynamic) {
      // --- MODIFIED CALL ---
      await dynamicChatService.loadDynamicAssistantPreference();
    }

    if (mounted && isDynamicChatMode) {
      debugPrint("[ChatScreen] Initial setup and model load complete. Now focusing keyboard.");
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          textFieldFocusNode.requestFocus();
        }
      });
    }

    await _loadRecentModels();

    await Future.wait([
      _updateInternetStatus(),
      _fetchSystemInfo(),
      _loadUserData(),
    ]);
  }

  /// Fetches the most recent model series IDs from storage and maps them
  /// to full ModelInfo objects from the main model list.
  Future<void> _loadRecentModels() async {
    // 1. Check the cache first. If data exists, use it and exit.
    if (CacheService.cachedRecentModels != null) {
      if (mounted) {
        setState(() {
          _recentModels = CacheService.cachedRecentModels!;
        });
      }
      return;
    }

    // 2. If cache is empty, fetch from the database.
    final recentIds = await ChatStorageService.getRecentModelSeriesIds();
    final loadedRecentModels = <ModelInfo>[];

    // 3. --- LOGIC FIX ---
    // The 'recentIds' list now contains correct series IDs (e.g., 'gemini').
    // We can now do a simple, direct lookup.
    for (final id in recentIds) {
      try {
        // Find the model in our main list whose ID exactly matches the recent ID.
        final model = loadService.allModels.firstWhere((m) => m.id == id);
        loadedRecentModels.add(model);
      } catch (e) {
        // This log is now more accurate if a model is truly missing.
        debugPrint("[ChatScreen] Could not find a loaded model for recent ID: '$id'. It might have been uninstalled or is not available.");
      }
    }

    // 4. Update the cache and the UI state.
    CacheService.cachedRecentModels = loadedRecentModels;
    CacheService.startRecentModelsCacheTimer();
    if (mounted) {
      setState(() {
        _recentModels = loadedRecentModels;
      });
    }
  }

  /// A public method that can be called from other services (like SendService)
  /// to trigger a refresh of the recent models list.
  /// It now correctly returns a Future, making it compatible with `unawaited`.
  Future<void> refreshRecentModels() async {
    await _loadRecentModels();
  }

  /// A central function to reload all model data with robust state handling.
  /// It now returns a Future<void> to be properly await-able.
  Future<void> _reloadAllModelsForLanguageChange() async {
    debugPrint(
        "[ChatScreen] Reloading all models due to a trigger (e.g., download complete, language change, retry button).");

    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;
    debugPrint("[ChatScreen.reload] Core services are ready. Proceeding with model load.");

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

    // --- MODIFICATION START ---
    // Cancel any existing timer and start a new one.
    _userDataFetchTimer?.cancel();
    _userDataFetchTimer = Timer(const Duration(seconds: 7), _handleUserDataTimeout);
    // --- MODIFICATION END ---

    await _userDataSubscription?.cancel();

    _userDataSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        // --- MODIFICATION START ---
        // Data has arrived successfully, so cancel the timeout timer.
        _userDataFetchTimer?.cancel();
        // --- MODIFICATION END ---

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
      // --- MODIFICATION START ---
      // If there's an error, also cancel the timer.
      _userDataFetchTimer?.cancel();
      // --- MODIFICATION END ---
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
    if (modelId == null || modelId.isEmpty) {
      return false; // An empty ID can't be a server-side model.
    }

    // This is now the ONLY logic path. It is always correct.
    final modelData = ModelData.getPreciseModelData(modelId);
    final isOffline = modelData['type'] == 'offline';

    // Return true if the model is NOT offline.
    return !isOffline;
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
        isPersistentlyDynamic = false;
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

  // --- REWRITTEN: This logic now correctly handles the three-stage navigation flow. ---
  Future<bool> _onWillPop() async {
    // If we are in a chat (either with a selected model or in a dynamic session),
    // the back button should take us to the main selection screen.
    if (appBarModeNotifier.value == AppBarMode.modelSelected ||
        appBarModeNotifier.value == AppBarMode.dynamicChat) {
      await _handleExit();
      return false; // Prevent the app from closing.
    }
    // If we are in the model grid view (pushed via Navigator), this WillPopScope won't be triggered.
    // The Navigator's own back button handling will work.
    // If we are on the main screen, allow the app to close.
    return true;
  }

  @override
  void dispose() {
    ModelData.removeListener(_handleModelDataChange);
    // Ensure the timer is cancelled when the widget is disposed to prevent memory leaks.
    _userDataFetchTimer?.cancel();
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
    appBarModeNotifier.dispose();
    _bannerService.dispose();
    super.dispose();
  }

  void _handleUserDataTimeout() {
    // Check if the widget is still in the tree and if user data is still missing.
    if (mounted && _userData == null) {
      debugPrint("[ChatScreen] User data fetch timed out. Showing notification.");
      // The method is named 'showNotification', not 'show'.
      // The parameter for error is 'isSuccess', which we set to 'false'.
      Provider.of<NotificationService>(context, listen: false).showNotification(
        message: AppLocalizations.of(context)!.checkYourInternet,
        isSuccess: false, // Use 'isSuccess: false' for an error state
      );
    }
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

  @override
  Widget build(BuildContext context) {
    debugPrint("[ChatScreen Build] Starting UI build process.");
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: Appbar(
          modelTitle: modelTitle,
          modelImagePath: modelImagePath,
          exitButtonKey: _exitButtonKey,
          accountButtonKey: _accountButtonKey,
          userData: _userData,
          extensionKey: _extensionKey,
          onExit: () async {
            if (appBarModeNotifier.value == AppBarMode.modelSelected ||
                appBarModeNotifier.value == AppBarMode.dynamicChat) {
              await _handleExit();
            } else if (appBarModeNotifier.value == AppBarMode.inSelection) {
              selectionScreenKey.currentState?.showSelectionView();
            }
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
          onTitleTap: () {
            final mode = appBarModeNotifier.value;
            debugPrint("[ChatScreen] Title tapped in mode: $mode");

            if (mode == AppBarMode.modelSelected) {
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
            } else if (mode == AppBarMode.dynamicChat) {
              dynamicChatService.showDynamicAssistantPanel();
            }
          },
          appTitle: localizations.appTitle,
          extensions: extensions,
          onCreditsInfoTapped: _bannerService.triggerBannerManually,
          appBarModeNotifier: appBarModeNotifier,
          chatTitleKey: chatTitleKey,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: isModelSelected || isDynamicChatMode ? AppColors.background : null,
            gradient: !(isModelSelected || isDynamicChatMode)
                ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.background.withOpacity(0.0),
              ],
              stops: const [0.12, 0.20],
            )
                : null,
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: isModelSelected || isDynamicChatMode
                            ? _buildChatContent(localizations)
                            : _buildModelSelectionContent(localizations),
                      ),
                    ),
                    _buildInputSectionWrapper(),
                  ],
                ),
                PremiumModelBanner(
                  isVisible: showPremiumBriefing && isModelSelected &&
                      !isUserSubscribed,
                  onTap: _navigateToPremiumScreen,
                ),
                _buildScrollDownButton(screenWidth),
                // It will not be shown if the extensions panel is visible,
                // preventing the two UI elements from overlapping incorrectly.
                if ((isModelSelected || isDynamicChatMode) && !extensions.isPanelVisible)
                  BriefingOverlay(
                    key: _briefingOverlayKey,
                    inputFieldHeight: _inputSectionHeight,
                    availableCredits: creditsManager.totalCreditsNotifier
                        .value ?? 0,
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
                        setState(() {
                          _showDisclaimerOverlay = false;
                          _disclaimerHasBeenShownThisSession = true;
                        });
                      }
                    },
                  ),
                ValueListenableBuilder<bool>(
                  valueListenable: _bannerService.showInviteBannerNotifier,
                  builder: (context, showBanner, child) {
                    if (showBanner && !isModelSelected && !isDynamicChatMode) {
                      return FloatingInfoBanner(
                        key: const ValueKey('invite_banner'),
                        bannerType: BannerType.inviteCredits,
                        onDismissed: () {
                          _bannerService.startCooldown();
                        },
                        onTap: () {
                          _bannerService.generateAndShareInviteLink(context);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                if (_showExtensionInfoBanner)
                  FloatingInfoBanner(
                    key: const ValueKey('extension_info_banner'),
                    bannerType: BannerType.extensionInfo,
                    anchorKey: chatTitleKey,
                    onDismissed: () {
                      if (mounted) {
                        setState(() => _showExtensionInfoBanner = false);
                        textFieldFocusNode.requestFocus();
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the content for when a model is NOT selected.
  Widget _buildModelSelectionContent(AppLocalizations localizations) {
    if (_modelsLoadError) {
      return ErrorView(
        key: const ValueKey('chat_error'),
        title: localizations.errorLoadingTitle,
        message: localizations.errorLoadingMessage,
        buttonText: localizations.retry,
        onRetry: _reloadAllModelsForLanguageChange,
      );
    }

    return SelectionScreen(
      key: selectionScreenKey,
      isLoading: _areModelsLoading,
      searchController: searchController,
      allModels: loadService.allModels,
      recentModels: _recentModels,
      onReloadModels: _reloadAllModelsForLanguageChange,
      hasInternetConnection: hasInternetConnection,
      conversationLimitReached: _conversationLimitReached,
      onSelectModel: (model) {
        selectionService.selectModel(model);
        appBarModeNotifier.value = AppBarMode.modelSelected;
      },
      onScrollToBottom: scrollService.scrollToBottom,
      localizations: localizations,
      userData: _userData,
      onViewModeChanged: (isShowingAllModels) {
        setState(() {
          appBarModeNotifier.value = isShowingAllModels
              ? AppBarMode.inSelection
              : AppBarMode.notSelected;
        });
      },
    );
  }

  /// Builds the content for when a model IS selected.
  Widget _buildChatContent(AppLocalizations localizations) {
    // --- TACTICAL FIX & GUARD CLAUSE ---
    // This check is the primary fix. When _handleExit is called, it sets isModelSelected
    // and isDynamicChatMode to false. On the very next frame, this build method runs.
    // This condition will now be true, and we return an empty box with a unique key.
    // This prevents the rest of the function from trying to render content with a null modelId,
    // which was the cause of the "Unknown Model" flicker.
    if (!isModelSelected && !isDynamicChatMode) {
      return const SizedBox.shrink(key: ValueKey('exiting_chat_content'));
    }
    // --- END OF FIX ---

    if (isDynamicChatMode && messages.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/cortex.svg',
              width: screenWidth * 0.2,
              colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
            ),
            SizedBox(height: screenHeight * 0.001),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Text(
                localizations.selectionScreenGreetingGeneric,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor.inverted.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!readService.areMessagesLoaded) {
      return readService.buildSkeletonChatMessages();
    }

    return SelectedScreen(
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
        ReportDialog.show(
          context,
          aiMessage: messages[index].text,
          modelId: modelId!,
          onReportSuccess: () {
            if (mounted) {
              setState(() => messages[index].isReported = true);
              ChatStorageService.updateStoredMessage(conversationID!, messages[index], index);
            }
          },
        );
      },
      localizations: localizations,
    );
  }

  /// Wraps the input section with listeners needed for layout updates.
  Widget _buildInputSectionWrapper() {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        // Use a post frame callback to avoid setState during build.
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateInputSectionHeight());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        key: _inputSectionKey,
        child: _buildInputSection(),
      ),
    );
  }

  /// Builds the scroll-down button, now with its visibility logic self-contained.
  Widget _buildScrollDownButton(double screenWidth) {
    // This is a ValueListenableBuilder listening to keyboard visibility
    // to decide whether to show the button, making it more efficient.
    return ValueListenableBuilder<bool>(
      valueListenable: ValueNotifier(MediaQuery.of(context).viewInsets.bottom > 0),
      builder: (context, isKeyboardVisible, child) {
        final bool showScrollDownButtonFinal = showScrollDownButtonByPosition && !isKeyboardVisible;
        if (isModelSelected && messages.isNotEmpty) {
          return scrollService.buildScrollDownButton(
            screenWidth: screenWidth,
            inputFieldHeight: _inputSectionHeight,
            showScrollDownButton: showScrollDownButtonFinal,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInputSection() {
    final bool isOffline = !isServerSideModel(modelId);
    final bool modelMissing =
        !isDynamicChatMode && isOffline && !loadService.isModelOnDisk(modelPath);

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
            isDynamicChatMode: isDynamicChatMode,
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
            // In dynamic mode, we assume image capability until a model is chosen.
            canHandleImage: isDynamicChatMode ? true : canHandleImage,
            isEditingMode: isEditingMode,
            originalMessageText: originalMessageText,
            preselectedPhoto: (isEditingMode &&
                editingMessageIndex != null &&
                messages[editingMessageIndex!].photoPath != null)
                ? File(messages[editingMessageIndex!].photoPath!)
                : null,
            isStorageSufficient: isStorageSufficient,
            totalCredits: creditsManager.totalCreditsNotifier.value ?? 0,
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
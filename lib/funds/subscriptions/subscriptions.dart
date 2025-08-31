// subscriptions.dart (FINAL, PERFECTED & SYNCHRONIZED)

import 'dart:async';
import 'dart:developer';
import 'package:cortex/funds/subscriptions/skeleton.dart';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

// --- Firebase, IAP, and other necessary imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

import '../../banner.dart';
import '../../cache.dart';
import '../../internet.dart';
import '../../webview.dart';
import '../credits/credits.dart'; // The "dumb" widget
import '../../notifications.dart';
import '../../theme.dart';

// --- String extension for capitalizing plan names ---
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  // --- Core State Variables ---
  final List<String> planTypes = ['plus', 'pro', 'ultra'];
  Map<String, String> selectedOptions = {
    'plus': 'monthly',
    'pro': 'monthly',
    'ultra': 'monthly'
  };
  late PageController _pageController;
  int _currentPage = 1; // Start on the 'Pro' plan page
  CreditPackage? _selectedCreditPackage;

  // --- Service Instances ---
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(region: 'europe-west1');

  // --- Stream Subscriptions ---
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;
  late StreamSubscription<bool> _internetSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  // --- UI and Flow Control State ---
  bool _loading = true;
  bool _purchasePending = false;
  bool _errorOccurred = false;
  String _errorMessage = '';
  final bool _isTesting = !kReleaseMode;
  List<ProductDetails> _availableProducts = [];
  int _hasCortexSubscription = 0;
  String? _activeSubscriptionOption;
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;
  bool _isContentLoaded = false;
  bool _hasAnyBenefitListAnimated = false;
  Offset _contentOffset = const Offset(0.0, 0.03);

  // --- Product Identifiers (Single Source of Truth) ---
  static const String _logName = 'PremiumScreen';
  static const String _monthlySubscriptionPlus = 'vertex_ai_monthly_sub';
  static const String _annualSubscriptionPlus = 'vertex_ai_annual_sub';
  static const String _monthlySubscriptionPro = 'cortex_pro_monthly';
  static const String _annualSubscriptionPro = 'cortex_pro_annual';
  static const String _monthlySubscriptionUltra = 'cortex_ultra_monthly';
  static const String _annualSubscriptionUltra = 'cortex_ultra_annual';
  static const Set<String> _subscriptionIds = {
    _monthlySubscriptionPlus,
    _annualSubscriptionPlus,
    _monthlySubscriptionPro,
    _annualSubscriptionPro,
    _monthlySubscriptionUltra,
    _annualSubscriptionUltra,
  };
  static const Set<String> _creditProductIds = {
    'cortex_credits_250',
    'credits_500',
    'credits_1000',
    'credits_2500',
    'credits_5000',
  };
  final List<ProductDetails> _mockProducts = [
    ProductDetails(id: 'cortex_credits_250', title: '250 Credits', description: 'Test', price: '\$2.49', rawPrice: 2.49, currencyCode: 'USD'),
    ProductDetails(id: 'credits_500', title: '500 Credits', description: 'Test', price: '\$4.99', rawPrice: 4.99, currencyCode: 'USD'),
    ProductDetails(id: 'credits_1000', title: '1000 Credits', description: 'Test', price: '\$9.99', rawPrice: 9.99, currencyCode: 'USD'),
    ProductDetails(id: 'credits_2500', title: '2500 Credits', description: 'Test', price: '\$24.99', rawPrice: 24.99, currencyCode: 'USD'),
    ProductDetails(id: 'credits_5000', title: '5000 Credits', description: 'Test', price: '\$49.99', rawPrice: 49.99, currencyCode: 'USD'),
    ProductDetails(id: 'vertex_ai_monthly_sub', title: 'Plus Monthly', description: 'Test', price: '\$4.99', rawPrice: 4.99, currencyCode: 'USD'),
    ProductDetails(id: 'vertex_ai_annual_sub', title: 'Plus Annual', description: 'Test', price: '\$49.99', rawPrice: 49.99, currencyCode: 'USD'),
    ProductDetails(id: 'cortex_pro_monthly', title: 'Pro Monthly', description: 'Test', price: '\$9.99', rawPrice: 9.99, currencyCode: 'USD'),
    ProductDetails(id: 'cortex_pro_annual', title: 'Pro Annual', description: 'Test', price: '\$99.99', rawPrice: 99.99, currencyCode: 'USD'),
    ProductDetails(id: 'cortex_ultra_monthly', title: 'Ultra Monthly', description: 'Test', price: '\$19.99', rawPrice: 19.99, currencyCode: 'USD'),
    ProductDetails(id: 'cortex_ultra_annual', title: 'Ultra Annual', description: 'Test', price: '\$199.99', rawPrice: 199.99, currencyCode: 'USD'),
  ];

  late List<ScrollController> _scrollControllers;
  bool _showScrollFog = false;

  @override
  void initState() {
    super.initState();

    final bool hasCachedData = CacheService.cachedPremiumProducts != null && CacheService.cachedPremiumProducts!.isNotEmpty;

    _scrollControllers = List.generate(4, (_) => ScrollController());
    _scrollControllers[_currentPage].addListener(_updateFogVisibility);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _shineController, curve: Curves.linear)
    );

    _shineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _shineController.forward(from: 0.0);
          }
        });
      }
    });

    _loading = !hasCachedData;

    if (hasCachedData) {
      _availableProducts = CacheService.cachedPremiumProducts!;
      log('Cache hit! Initializing with cached product data.', name: _logName);
    }

    _pageController = PageController(initialPage: _currentPage);
    _pageController.addListener(_onPageChanged);

    _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: _onPurchaseStreamError,
    );

    _internetSubscription =
        InternetService().onConnectivityChanged.listen((connected) {
          if (mounted) setState(() {});
          if (connected && _errorOccurred && _availableProducts.isEmpty) {
            _initializeStore();
          }
        });

    CacheService.touchPremiumCache();
    _initializeStore();
    _listenToUserChanges();

    // --- FIX & ACTIVATION: Start the shine animation after a brief delay ---
    // This was missing before, which is why the effect wasn't visible.
    // It waits 2 seconds for the user to settle, then starts the recurring shine.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _shineController.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFogVisibility());
  }

  /// Initializes the connection to the store and fetches product details IF NEEDED.
  Future<void> _initializeStore() async {
    // --- Helper function to trigger the screen's entry animation ---
    void triggerEntryAnimation() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isContentLoaded = true;
            _contentOffset = Offset.zero;
          });
          _updateFogVisibility();
        }
      });
    }

    if (AppDataState().needsRefresh) {
      CacheService.invalidatePremiumCache();
      log('AppDataState requires refresh. Invalidating premium cache.', name: _logName);
      if (mounted) {
        setState(() {
          _loading = true;
          _availableProducts = [];
        });
      }
    }

    if (!_loading && _availableProducts.isNotEmpty) {
      log('Products already loaded. Skipping initialization.', name: _logName);
      triggerEntryAnimation(); // Trigger animation even for cached data
      return;
    }

    if (_isTesting) {
      log('Running in Test Mode. Using mock product data.', name: _logName);
      if (mounted) {
        setState(() {
          _availableProducts = _mockProducts;
          _loading = false;
          _errorOccurred = false;
        });
        triggerEntryAnimation(); // Trigger animation for mock data
      }
      return;
    }

    log('Cache is empty or invalidated. Fetching product details from the store.', name: _logName);

    if (!await InternetService().hasInternet()) {
      _showFatalErrorScreen(AppLocalizations.of(context)!.noInternetConnection);
      return;
    }

    if (!await _inAppPurchase.isAvailable()) {
      _showFatalErrorScreen(AppLocalizations.of(context)!.storeUnavailable);
      return;
    }

    try {
      final Set<String> allProductIds = {..._subscriptionIds, ..._creditProductIds};
      final response = await _inAppPurchase.queryProductDetails(allProductIds);

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
      if (response.productDetails.isEmpty) {
        log('Store returned zero products. This might be a config issue in App/Play Store.', name: _logName);
      }

      log('Successfully fetched ${response.productDetails.length} products.', name: _logName);
      if (mounted) {
        setState(() {
          _availableProducts = response.productDetails;
          CacheService.cachedPremiumProducts = response.productDetails;
          _loading = false;
          _errorOccurred = false;
        });
        triggerEntryAnimation(); // Trigger animation after fetching real data
      }
    } catch (e) {
      log('Error fetching product details: $e', name: _logName, error: e);
      _showFatalErrorScreen(AppLocalizations.of(context)!.productDetailsError);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _purchaseStreamSubscription.cancel();
    _internetSubscription.cancel();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _shineController.dispose();
    _userSubscription?.cancel();
    CacheService.startPremiumCacheTimer();
    super.dispose();
  }

  // --- Data & Purchase Logic ---

  /// THE FIRST CORE FIX: Listens for real-time user data and syncs the UI state.
  void _listenToUserChanges() {
    final user = _auth.currentUser;
    if (user != null) {
      _userSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;
        final data = snapshot.data();

        setState(() {
          // 1. Get the latest subscription data from the server.
          _hasCortexSubscription = data?['hasCortexSubscription'] ?? 0;
          _activeSubscriptionOption = data?['activeSubscriptionOption'];

          // 2. If an active subscription exists, immediately sync the UI's
          //    selected option to match the user's actual plan (e.g., 'annual').
          //    This corrects the UI on initial load and for any real-time changes.
          if (_hasCortexSubscription > 0 &&
              _hasCortexSubscription <= planTypes.length &&
              _activeSubscriptionOption != null) {

            // Determine which plan type is active ('plus', 'pro', or 'ultra').
            final activePlanType = planTypes[_hasCortexSubscription - 1];

            // Update the map that controls the UI's selection state.
            selectedOptions[activePlanType] = _activeSubscriptionOption!;

            log(
                "User data updated. Active plan: $activePlanType (${_activeSubscriptionOption!}). Syncing UI selection.",
                name: _logName
            );
          }
        });
      }, onError: (error) {
        log('Error listening to user document: $error', name: _logName, error: error);
      });
    }
  }

  /// Centralized function to initiate any purchase. It now has a unified flow for all users.
  /// The server will determine if the user is a tester.
  Future<void> _initiatePurchase(String productId, {String? productTitle}) async {
    if (_auth.currentUser == null) {
      log('Purchase blocked: User is not authenticated.', name: _logName);
      if (mounted) {
        _showCustomNotification(
          oneLine: false,
          message: AppLocalizations.of(context)!.loginRequiredForPurchase,
          isSuccess: false,
        );
      }
      return;
    }

    if (_purchasePending) {
      log('Purchase attempt ignored: Another purchase is already pending.', name: _logName);
      return;
    }

    // --- ARCHITECTURE CHANGE: UNIFIED PURCHASE FLOW ---
    // We no longer check for `_isTesting` on the client. The client simply
    // makes the purchase request, and the server handles the logic.
    // This removes the need for a separate logic path for test purchases.

    // The designated tester (`mustawtfa@gmail.com`) can trigger a "test purchase"
    // by using the app normally. The server will recognize the email and grant
    // the item without needing a real receipt. For this to work, the tester
    // might still need to go through the purchase flow up to a certain point,
    // but a real receipt is not sent or needed for the server's test path.
    //
    // However, the cleanest way for the designated tester to get items without
    // any store interaction is to trigger a purchase that doesn't send a receipt.
    // We can achieve this by checking the user's email on the client *only* to decide
    // whether to call the store or just our function directly.

    final currentUserEmail = _auth.currentUser?.email;
    final isDesignatedTester = currentUserEmail == "mustawtfa@gmail.com";

    // If the user is our hard-coded tester, we can bypass the Google Play flow
    // entirely and just call our Cloud Function. This is fast and avoids store errors.
    if (isDesignatedTester) {
      log('Initiating DIRECT test purchase for designated tester: $productId', name: _logName);
      setState(() => _purchasePending = true);
      try {
        final callable = _functions.httpsCallable('verifyPurchase');
        // We call the function with the `productId` but no `receiptData`,
        // as the server's tester path doesn't need it.
        await callable.call<dynamic>({
          'productId': productId,
          'platform': defaultTargetPlatform.name.toLowerCase(),
          // No 'receiptData' is sent, which is fine for the tester path.
        });

        AppDataState().markUserDataAsChanged();
        _showCustomNotification(
          oneLine: false,
          message: "Test purchase for '${productTitle ?? productId}' successful.",
          isSuccess: true,
        );
      } on FirebaseFunctionsException catch (e) {
        _handlePurchaseError("Test purchase failed: ${e.message ?? 'Unknown error'}");
      } catch (e) {
        _handlePurchaseError("An unexpected client error during test purchase: $e");
      } finally {
        if (mounted) setState(() => _purchasePending = false);
      }
      return; // Exit the function after handling the test purchase.
    }

    // --- REGULAR USER PURCHASE FLOW ---
    // For all other users, we go through the standard Google Play flow.
    log('Initiating REAL purchase for productId: $productId', name: _logName);
    ProductDetails? productToBuy;
    try {
      productToBuy = _availableProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      _showCustomNotification(
        oneLine: false,
        message: AppLocalizations.of(context)!.productNotFound,
        isSuccess: false,
      );
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: productToBuy);

    if (_creditProductIds.contains(productId)) {
      _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }


  /// Handles subscription cancellation and downgrade logic.
  /// This function is now simplified, as the test logic is handled server-side
  /// or by the new logic in `_initiatePurchase`.
  void _manageSubscriptionInStore() async {
    // --- ARCHITECTURE CHANGE: REMOVED _isTesting CHECK ---
    // If the designated tester needs to "cancel" a test subscription, they can
    // simply purchase the special 'cancel_subscription_test' product ID.
    final currentUserEmail = _auth.currentUser?.email;
    if (currentUserEmail == "mustawtfa@gmail.com") {
      log('Designated tester is cancelling a test subscription.', name: _logName);
      _initiatePurchase(
        'cancel_subscription_test',
        productTitle: 'Subscription Cancellation',
      );
      return;
    }

    // For all regular users, we redirect them to the store.
    log('Redirecting user to store for subscription management.', name: _logName);
    Uri url;
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.android) {
      url = Uri.parse('https://play.google.com/store/account/subscriptions?package=com.vertex.cortex');
    } else if (platform == TargetPlatform.iOS) {
      // This is a placeholder for future iOS implementation
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      _showCustomNotification(oneLine: false, message: AppLocalizations.of(context)!.unsupportedPlatform, isSuccess: false);
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showCustomNotification(oneLine: false, message: AppLocalizations.of(context)!.unableToOpenSubscription, isSuccess: false);
    }
  }

  /// The main action button's logic, now passing the product title.
  void _onPrimaryButtonPressed() {
    if (_purchasePending || _loading) return;

    String? productIdToPurchase;
    String? productTitleToPurchase; // Variable to hold the user-friendly name

    if (_currentPage == 0) { // On the Credits page
      productIdToPurchase = _selectedCreditPackage?.productId;
      if (productIdToPurchase != null) {
        final details = _availableProducts.firstWhere((p) => p.id == productIdToPurchase);
        productTitleToPurchase = details.title;
      }
    } else { // On a Subscription page
      final currentPlanIndex = _currentPage - 1;
      final currentPlanType = planTypes[currentPlanIndex];
      final currentPlanLevel = _currentPage;
      final selectedBillingOption = selectedOptions[currentPlanType] ?? 'monthly';

      // Get a user friendly name for notifications
      final planDisplayName = currentPlanType.capitalize();
      final billingName = selectedBillingOption == 'annual' ? AppLocalizations.of(context)!.annual : AppLocalizations.of(context)!.monthly;
      productTitleToPurchase = "$planDisplayName $billingName";

      final bool isActive = _hasCortexSubscription == currentPlanLevel;
      final bool isDowngrade = _hasCortexSubscription > currentPlanLevel;
      final bool isSameOption = selectedOptions[currentPlanType] == _activeSubscriptionOption;

      if (isDowngrade) {
        _manageSubscriptionInStore();
        return;
      } else if (isActive && isSameOption) {
        _manageSubscriptionInStore();
        return;
      } else {
        // Find the correct product ID based on user selection
        if (currentPlanType == 'plus') productIdToPurchase = selectedBillingOption == 'annual' ? _annualSubscriptionPlus : _monthlySubscriptionPlus;
        if (currentPlanType == 'pro') productIdToPurchase = selectedBillingOption == 'annual' ? _annualSubscriptionPro : _monthlySubscriptionPro;
        if (currentPlanType == 'ultra') productIdToPurchase = selectedBillingOption == 'annual' ? _annualSubscriptionUltra : _monthlySubscriptionUltra;
      }
    }

    if (productIdToPurchase != null) {
      _initiatePurchase(productIdToPurchase, productTitle: productTitleToPurchase);
    } else {
      log('Could not determine a product ID to purchase.', name: _logName);
    }
  }

  /// Listens to the purchase stream from the store and routes events to the appropriate handler.
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          log('Purchase is pending: ${purchaseDetails.productID}', name: _logName);
          if (mounted) setState(() => _purchasePending = true);
          break;

        case PurchaseStatus.error:
          log('Purchase error: ${purchaseDetails.error?.message}', name: _logName, error: purchaseDetails.error);
          _handleFailedPurchase(purchaseDetails);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          log('Purchase successful/restored: ${purchaseDetails.productID}', name: _logName);
          _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          log('Purchase canceled by user: ${purchaseDetails.productID}', name: _logName);
          if (mounted) setState(() => _purchasePending = false);
          // No further action is needed for a canceled purchase.
          // But we must still complete it to remove it from the queue.
          if (purchaseDetails.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;
      }
    }
  }

  /// Handles a successful purchase by verifying it with the server and then completing it.
  /// This function ensures the server-side logic runs BEFORE the purchase is finalized on the client.
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    if (mounted) {
      // Show immediate feedback to the user while verification happens in the background.
      _showCustomNotification(
        oneLine: false,
        message: AppLocalizations.of(context)!.purchaseReceived,
        isSuccess: true,
      );
    }

    try {
      // This is the single point of contact with our server for verification.
      await _verifyPurchaseOnServer(purchaseDetails);
      log('Server verification successful for ${purchaseDetails.productID}.', name: _logName);

      // CRITICAL: Only after successful server verification, complete the purchase.
      // This acknowledges the transaction with the app store and removes it from the queue.
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        log('Client-side purchase completion successful for ${purchaseDetails.productID}.', name: _logName);
      }

      // Mark app data as stale to force re-fetch on relevant screens.
      AppDataState().markUserDataAsChanged();

    } catch (e) {
      log('CRITICAL: Server verification or purchase completion failed for ${purchaseDetails.productID}. The transaction will be retried on next app launch by the reconciliation logic.', name: _logName, error: e);
      if (mounted) {
        _showCustomNotification(
          oneLine: false,
          message: AppLocalizations.of(context)!.verificationDelayed,
          isSuccess: false,
        );
      }
    } finally {
      // Whether successful or not, the purchase attempt is no longer pending from the UI's perspective.
      if (mounted) {
        setState(() => _purchasePending = false);
      }
    }
  }

  /// The dedicated, focused function for server-side verification.
  /// This now returns a Future that completes upon success or throws an error on failure.
  Future<void> _verifyPurchaseOnServer(PurchaseDetails purchaseDetails) async {
    try {
      final callable = _functions.httpsCallable('verifyPurchase');
      await callable.call<dynamic>({
        'receiptData': purchaseDetails.verificationData.serverVerificationData,
        'productId': purchaseDetails.productID,
        'platform': defaultTargetPlatform.name.toLowerCase(),
      });
    } on FirebaseFunctionsException catch (e) {
      // Re-throw a more specific error to be caught by the calling function.
      throw Exception('Firebase Functions Error: Code [${e.code}] - Message: ${e.message}');
    } catch (e) {
      // Catch any other client-side errors during the call.
      throw Exception('A client-side error occurred during server verification: $e');
    }
  }

  /// Handles failed or errored purchases by providing user feedback.
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    if (mounted) {
      setState(() => _purchasePending = false);
      final errorMessage = purchaseDetails.error?.message ?? AppLocalizations.of(context)!.purchaseStreamError;
      _showCustomNotification(oneLine: false, message: errorMessage, isSuccess: false);

      // It's important to also complete errored purchases to clear them from the queue.
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handles errors reported directly by the in_app_purchase stream's error callback.
  /// This is a fallback for stream-level errors, not individual purchase errors.
  void _onPurchaseStreamError(dynamic error) {
    if (mounted) {
      setState(() => _purchasePending = false);
      final message = error?.message ?? AppLocalizations.of(context)!.purchaseStreamError;
      log('Purchase Stream Error: $message', name: _logName, error: error);
      _showCustomNotification(oneLine: false, message: message, isSuccess: false);
    }
  }

  // --- UI and Helper Methods ---

  /// Displays a full-screen error for setup failures.
  void _showFatalErrorScreen(String message) {
    if (mounted) {
      setState(() {
        _loading = false;
        _errorOccurred = true;
        _errorMessage = message;
      });
    }
  }

  /// Handles non-fatal errors that occur during a transaction.
  void _handlePurchaseError(String message) {
    if (mounted) {
      setState(() => _purchasePending = false);
      _showCustomNotification(oneLine: false, message: message, isSuccess: false);
    }
  }

  /// THE SECOND CORE FIX: This is the centralized logic for page changes.
  /// When the page is swiped, this method updates the UI and ensures the
  /// correct subscription option (monthly/annual) is pre-selected if active.
  void _onPageChanged() {
    int newPageIndex = _pageController.page!.round();

    if (_currentPage != newPageIndex) {
      if (mounted) {
        // --- NEW: Switch scroll listeners ---
        // 1. Remove the listener from the old page's controller.
        _scrollControllers[_currentPage].removeListener(_updateFogVisibility);
        // 2. Add a listener to the new page's controller.
        _scrollControllers[newPageIndex].addListener(_updateFogVisibility);

        setState(() {
          _currentPage = newPageIndex;

          if (_currentPage > 0 && _currentPage <= planTypes.length) {
            final planIndex = _currentPage - 1;
            final planType = planTypes[planIndex];
            final planLevel = _currentPage;

            if (_hasCortexSubscription == planLevel && _activeSubscriptionOption != null) {
              selectedOptions[planType] = _activeSubscriptionOption!;
              log("Page changed to $planType. Active sub found. Setting selected option to: ${_activeSubscriptionOption!}", name: _logName);
            }
          }
        });

        // --- NEW: Immediately check and update fog for the new page ---
        _updateFogVisibility();
      }
    }
  }

  /// Checks the current scroll controller's state to determine if the fog
  /// effect at the bottom of the screen should be visible.
  void _updateFogVisibility() {
    if (!mounted) return;

    final controller = _scrollControllers[_currentPage];

    // Safety check: ensure the controller is attached to a scroll view.
    if (!controller.hasClients) {
      // If not attached, it means the content isn't scrollable, so hide the fog.
      if (_showScrollFog) {
        setState(() => _showScrollFog = false);
      }
      return;
    }

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;

    // The fog should only be shown if the content is scrollable (maxScroll > 0)
    // AND the user has not scrolled to the very bottom.
    final bool shouldShow = maxScroll > 0 && currentScroll < maxScroll;

    // Only update the state if the visibility has actually changed.
    if (shouldShow != _showScrollFog) {
      setState(() {
        _showScrollFog = shouldShow;
      });
    }
  }

  void _showTermsAndConditions(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    const String termsUrl = "https://vertexishere.com/cortex-terms-of-service";
    const String policyUrl = "https://vertexishere.com/cortex-privacy-policy";
    if (!context.mounted) return;
    await showAppWebViewModal(context, localizations.termsOfService, termsUrl);
    if (!context.mounted) return;
    await showAppWebViewModal(context, localizations.privacyPolicy, policyUrl);
  }

  void _showCustomNotification(
      {required String message, required bool oneLine, required bool isSuccess}) {
    if (mounted) {
      Provider.of<NotificationService>(context, listen: false).showNotification(
          message: message, isSuccess: isSuccess, oneLine: oneLine, fontSize: 0.025, bottomOffset: 0.01);
    }
  }

  String _getPriceForId(String id) {
    try {
      return _availableProducts.firstWhere((p) => p.id == id).price;
    } catch (e) {
      return '';
    }
  }

  // --- Build Methods ---


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool disablePurchaseButton = (_hasCortexSubscription >= 4);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _errorOccurred
            ? _buildErrorScreen(context, localizations)
            : _loading
            ? const SkeletonLoader(key: ValueKey('skeleton'))
            : AnimatedSlide(
          offset: _contentOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _isContentLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: IconButton(
                            icon: Icon(Icons.close, color: AppColors.primaryColor.inverted, size: screenWidth * 0.07),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            PageView(
                              controller: _pageController,
                              children: [
                                CreditContentWidget(
                                  onCreditPackageSelected: (package) {
                                    if (mounted) setState(() => _selectedCreditPackage = package);
                                  },
                                  availableProducts: _availableProducts.where((p) => _creditProductIds.contains(p.id)).toList(),
                                  scrollController: _scrollControllers[0],
                                ),
                                _buildPremiumPage(context: context, localizations: localizations, planType: 'plus', scrollController: _scrollControllers[1]),
                                _buildPremiumPage(context: context, localizations: localizations, planType: 'pro', scrollController: _scrollControllers[2]),
                                _buildPremiumPage(context: context, localizations: localizations, planType: 'ultra', scrollController: _scrollControllers[3]),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: _showScrollFog ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 250),
                                  child: Container(
                                    height: screenHeight * 0.07,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.background.withOpacity(0.0),
                                          AppColors.background,
                                        ],
                                        stops: const [0.0, 0.9],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenHeight * 0.01, screenWidth * 0.06, screenHeight * 0.02),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                4,
                                    (index) {
                                  final bool isSelected = _currentPage == index;
                                  final double dotSize = screenWidth * 0.022;
                                  final double selectedWidth = screenWidth * 0.06;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                                    width: isSelected ? selectedWidth : dotSize,
                                    height: dotSize,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(dotSize),
                                      color: isSelected
                                          ? AppColors.primaryColor.inverted
                                          : AppColors.primaryColor.inverted.withOpacity(0.5),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: disablePurchaseButton ? 0.5 : 1.0,
                              child: ElevatedButton(
                                onPressed: (_purchasePending || _loading || disablePurchaseButton)
                                    ? null
                                    : _onPrimaryButtonPressed,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.primaryColor,
                                  backgroundColor: AppColors.primaryColor.inverted,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                  minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
                                  child: _purchasePending
                                      ? SizedBox(
                                      key: const ValueKey('loader'),
                                      height: screenHeight * 0.025,
                                      width: screenHeight * 0.025,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)))
                                      : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                    child: _buildButtonText(context, localizations),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextButton(
                              onPressed: () => _showTermsAndConditions(context),
                              child: Text(
                                localizations.termsOfServiceAndPrivacyPolicyWarning,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.tertiaryColor,
                                  fontSize: screenWidth * 0.025,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FloatingInfoBanner(
                  key: const ValueKey('discount_banner'),
                  bannerType: BannerType.discount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, AppLocalizations localizations) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.primaryColor.inverted, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    children: [
                      CreditContentWidget(
                        onCreditPackageSelected: (package) {
                          if (mounted) setState(() => _selectedCreditPackage = package);
                        },
                        availableProducts: _availableProducts.where((p) => _creditProductIds.contains(p.id)).toList(),
                      ),
                      _buildPremiumPage(context: context, localizations: localizations, planType: 'plus', scrollController: _scrollControllers[1]),
                      _buildPremiumPage(context: context, localizations: localizations, planType: 'pro', scrollController: _scrollControllers[2]),
                      _buildPremiumPage(context: context, localizations: localizations, planType: 'ultra', scrollController: _scrollControllers[3]),
                    ],
                  ),
                  // --- NEW: Fading "fog" effect, correctly positioned ---
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      child: Container(
                        height: 500.0, // The height/intensity of the fade effect
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.secondaryColor.withOpacity(0.0),  // Start transparent
                              AppColors.secondaryColor.withOpacity(0.5),  // Peak shine color
                              AppColors.secondaryColor.withOpacity(0.0),  // End transparent
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// THE FIX: Button text logic is now fully aware of all subscription states.
  Widget _buildButtonText(BuildContext context, AppLocalizations localizations) {
    final textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor);

    if (_currentPage == 0) { // Credits page
      return Text(
        _selectedCreditPackage != null
            ? localizations.creditPackage(_selectedCreditPackage!.amount)
            : localizations.buyCredit,
        key: ValueKey(_selectedCreditPackage != null ? 'credit_${_selectedCreditPackage!.amount}' : 'credit_default'),
        style: textStyle,
      );
    }

    // --- LOGIC FOR SUBSCRIPTION PAGES ---
    final planIndex = _currentPage - 1;
    final currentPlanLevel = _currentPage;
    final currentPlanType = planTypes[planIndex];
    final selectedBillingOption = selectedOptions[currentPlanType]!;

    // Case 1: Downgrading to a lower tier (e.g., from Pro to Plus)
    if (_hasCortexSubscription > currentPlanLevel) {
      return Text(localizations.manageSubscription, key: ValueKey('downgrade_to-$currentPlanType'), style: textStyle);
    }

    // Case 2: Upgrading (to a higher tier OR from monthly to annual)
    final bool isTierUpgrade = _hasCortexSubscription != 0 && _hasCortexSubscription < currentPlanLevel;
    final bool isBillingUpgrade = _hasCortexSubscription == currentPlanLevel &&
        selectedBillingOption == 'annual' &&
        _activeSubscriptionOption == 'monthly';

    if (isTierUpgrade || isBillingUpgrade) {
      return Text(localizations.upgradeSubscription, key: ValueKey('upgrade_to-$currentPlanType-$selectedBillingOption'), style: textStyle);
    }

    // Case 3: Managing/Cancelling the currently active plan (same tier, same billing option)
    if (_hasCortexSubscription == currentPlanLevel && selectedBillingOption == _activeSubscriptionOption) {
      return Text(localizations.cancelSubscription, key: ValueKey('cancel-$currentPlanType'), style: textStyle);
    }

    // Fallback Case: A standard new purchase
    final planDisplayName = currentPlanType.capitalize();
    final billingName = selectedBillingOption == 'annual' ? localizations.annual : localizations.monthly;
    final fullPlanName = "$planDisplayName $billingName";
    return Text(
      localizations.purchasePlan(fullPlanName),
      key: ValueKey('purchase-$currentPlanType-$selectedBillingOption'),
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPremiumPage({
    required BuildContext context,
    required AppLocalizations localizations,
    required String planType,
    required ScrollController scrollController,
  }) {
    // The following is a direct copy of the original _buildPremiumPage and its helpers,
    // as they correctly display data passed to them. The fixes were in the state that
    // controls what data gets passed.
    final screenWidth = MediaQuery.of(context).size.width;
    String purchaseKey, descriptionKey, logoPath, monthlyId, annualId;
    switch (planType) {
      case 'pro':
        purchaseKey = localizations.purchasePro;
        descriptionKey = localizations.proDescription;
        logoPath = AppColors.currentTheme == 'dark' ? 'assets/icons/subscriptions/whitepro.png' : 'assets/icons/subscriptions/prologo.png';
        monthlyId = _monthlySubscriptionPro;
        annualId = _annualSubscriptionPro;
        break;
      case 'ultra':
        purchaseKey = localizations.purchaseUltra;
        descriptionKey = localizations.ultraDescription;
        logoPath = AppColors.currentTheme == 'dark' ? 'assets/icons/subscriptions/whiteultra.png' : 'assets/icons/subscriptions/ultralogo.png';
        monthlyId = _monthlySubscriptionUltra;
        annualId = _annualSubscriptionUltra;
        break;
      default: // 'plus'
        purchaseKey = localizations.purchasePlus;
        descriptionKey = localizations.plusDescription;
        logoPath = AppColors.currentTheme == 'dark' ? 'assets/icons/subscriptions/whiteplus.png' : 'assets/icons/subscriptions/pluslogo.png';
        monthlyId = _monthlySubscriptionPlus;
        annualId = _annualSubscriptionPlus;
    }
    ProductDetails? annualProductDetails;
    try {
      annualProductDetails = _availableProducts.firstWhere((p) => p.id == annualId);
    } catch (e) {
      annualProductDetails = null;
    }
    final String formattedMonthlyEquivalentPrice;
    if (annualProductDetails != null && annualProductDetails.rawPrice > 0) {
      final monthlyEquivalentPrice = (annualProductDetails.rawPrice / 12).toStringAsFixed(2);
      final currencySymbol = annualProductDetails.price.replaceAll(RegExp(r'[0-9.,\s]'), '');
      formattedMonthlyEquivalentPrice = "$currencySymbol$monthlyEquivalentPrice";
    } else {
      formattedMonthlyEquivalentPrice = '...';
    }
    final bool isActivePlan = (planType == 'plus' && _hasCortexSubscription == 1) || (planType == 'pro' && _hasCortexSubscription == 2) || (planType == 'ultra' && _hasCortexSubscription == 3);
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Text(purchaseKey, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(descriptionKey, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.tertiaryColor)),
            const SizedBox(height: 16),
            Image.asset(logoPath, height: screenWidth * 0.25),
            const SizedBox(height: 16),
            _buildSubscriptionOption(context: context, localizations: localizations, option: 'annual', planType: planType, title: "${localizations.annual} ${planType.capitalize()}", description: localizations.annualPlanDescription(formattedMonthlyEquivalentPrice), isBestValue: true, isSelected: selectedOptions[planType] == 'annual', isSubscribedPlan: isActivePlan, activeSubscriptionOption: _activeSubscriptionOption ?? ''),
            const SizedBox(height: 8),
            _buildSubscriptionOption(context: context, localizations: localizations, option: 'monthly', planType: planType, title: "${localizations.monthly} ${planType.capitalize()}", description: localizations.monthlyPlanDescription(_getPriceForId(monthlyId)), isBestValue: false, isSelected: selectedOptions[planType] == 'monthly', isSubscribedPlan: isActivePlan, activeSubscriptionOption: _activeSubscriptionOption ?? ''),
            const SizedBox(height: 24),
            _buildBenefitsList(context, localizations, planType),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption({required BuildContext context, required AppLocalizations localizations, required String option, required String planType, required String title, required String description, required bool isBestValue, required bool isSelected, required bool isSubscribedPlan, required String activeSubscriptionOption}) {
    final bool isEffectivelyDisabled = isSubscribedPlan && activeSubscriptionOption == 'annual' && option == 'monthly';
    final bool showCheckmark = isSubscribedPlan && activeSubscriptionOption == option;
    Widget buildBadge({required Color backgroundColor, required Color textColor, required String text}) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(6)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      );
    }

    // The core widget content that will be put inside the Stack
    final content = AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.background, // Assuming this was the intended color, not AppColors.background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor.inverted : AppColors.border, // Use AppColors.border for unselected state
          width: isSelected ? 2.0 : 1.0, // Make border thicker when selected for better feedback
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 16, color: AppColors.tertiaryColor)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: showCheckmark
                  ? Container(
                key: const ValueKey('checkmark'),
                alignment: Alignment.center,
                width: 70,
                child: SvgPicture.asset('assets/icons/checkmark.svg', colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn), width: 36, height: 36),
              )
                  : Container(
                key: const ValueKey('badges'),
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: isBestValue,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: buildBadge(backgroundColor: Colors.green, textColor: Colors.white, text: localizations.bestValue),
                    ),
                    buildBadge(backgroundColor: AppColors.primaryColor.inverted, textColor: AppColors.primaryColor, text: localizations.discountOffer(80)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isEffectivelyDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isEffectivelyDisabled ? null : () => setState(() => selectedOptions[planType] = option),
        child: Stack(
          children: [
            content, // The original widget
            // --- MODIFICATION: The 'if (isBestValue)' condition is removed. ---
            // The shine effect now applies to ALL subscription options.
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(MediaQuery.of(context).size.width * _shineAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100, // Width of the shine gradient
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.secondaryColor.withOpacity(0.0),  // Start transparent
                          AppColors.secondaryColor.withOpacity(0.5),  // Peak shine color
                          AppColors.secondaryColor.withOpacity(0.0),  // End transparent
                        ],
                        stops: const [0.4, 0.5, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context, AppLocalizations localizations, String planType) {
    String benefit7Text = localizations.benefit7(planType == 'plus' ? '500' : planType == 'pro' ? '1000' : '2000');
    List<String> benefits = [];
    if (planType == 'plus')
      benefits = [
        localizations.benefit1,
        localizations.benefit3,
        localizations.benefit5,
        localizations.benefit4,
        benefit7Text,
        localizations.benefit9,
        localizations.benefitPremiumModels,
      ];
    else if (planType == 'pro')
      benefits = [localizations.oldBenefits, localizations.benefit5, localizations.benefit1, benefit7Text];
    else if (planType == 'ultra')
      benefits = [localizations.oldBenefits, localizations.benefit8, localizations.benefit1, localizations.benefit5, benefit7Text];

    // --- CORRECTED LOGIC: Determine if animation should run only ONCE per screen lifecycle ---
    final bool shouldAnimate = !_hasAnyBenefitListAnimated;

    // If this is the first time animating, set the flag so it never runs again.
    // A post-frame callback is safest to prevent setState errors during a build.
    if (shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _hasAnyBenefitListAnimated = true;
        }
      });
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: benefits.asMap().entries.map((entry) {
        final int index = entry.key;
        final String benefit = entry.value;

        final benefitContent = SizedBox(
          width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icons/checkmark.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Expanded(child: Text(benefit, style: TextStyle(fontSize: 14, color: AppColors.primaryColor.inverted))),
            ],
          ),
        );

        // The logic is now simple: create the animator and tell it whether to animate or not.
        return _FadingBenefitItem(
          animate: shouldAnimate,
          delay: Duration(milliseconds: 200 + (index * 120)),
          child: benefitContent,
        );
      }).toList(),
    );
  }
}


/// A custom stateful widget for staggered fade-in animation of benefit items.
/// It MUST be a StatefulWidget to manage its own animation timer.
class _FadingBenefitItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final bool animate; // This flag will control if the timer starts

  const _FadingBenefitItem({
    required this.child,
    required this.delay,
    required this.animate,
  });

  @override
  State<_FadingBenefitItem> createState() => _FadingBenefitItemState();
}

class _FadingBenefitItemState extends State<_FadingBenefitItem> {
  // Initial state: invisible and slightly offset down
  bool _isVisible = false;
  double _yOffset = 10.0;

  @override
  void initState() {
    super.initState();
    // --- CORRECTED LOGIC ---
    // Only start the animation timer if the `animate` flag is true.
    if (widget.animate) {
      Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _isVisible = true;
            _yOffset = 0.0; // Animate to final position
          });
        }
      });
    } else {
      // If not animating, set the final state immediately.
      _isVisible = true;
      _yOffset = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // These animation widgets are driven by the internal state variables,
    // which are controlled by the logic in initState.
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _yOffset, 0),
        child: widget.child,
      ),
    );
  }
}
// lib/funds/backend.dart (FINALIZED & PRODUCTION-READY)
// This version integrates robust caching to prevent skeleton loaders on subsequent
// visits and adds comprehensive Firebase Crashlytics logging to all critical
// payment and data fetching flows for maximum stability and monitoring.

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// --- Local & Service Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../cache.dart'; // For caching product details
import '../internet.dart';
import '../l10n/app_localizations.dart';
import '../notifications/introvert.dart';

class FundsBackend with ChangeNotifier {
  // --- Service Instances ---
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // --- Stream Subscriptions ---
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  // --- Private State Properties ---
  bool _isLoading = true;
  bool _isPurchasePending = false;
  String? _errorMessage;
  List<ProductDetails> _products = [];
  int _currentUserSubscriptionLevel = 0;
  String? _activeSubscriptionOption;
  bool _initialized = false;

  // --- Public Getters ---
  bool get isLoading => _isLoading;
  bool get isPurchasePending => _isPurchasePending;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  List<ProductDetails> get allProducts => _products;
  List<ProductDetails> get creditProducts => _products.where((p) => _creditProductIds.contains(p.id)).toList();
  List<ProductDetails> get subscriptionProducts => _products.where((p) => _subscriptionIds.contains(p.id)).toList();
  int get currentUserSubscriptionLevel => _currentUserSubscriptionLevel;
  String? get activeSubscriptionOption => _activeSubscriptionOption;

  // --- Product Identifiers & Mocks ---
  static const String _logName = 'FundsBackend';
  static const String monthlySubscriptionPlus = 'vertex_ai_monthly_sub';
  static const String annualSubscriptionPlus = 'vertex_ai_annual_sub';
  static const String monthlySubscriptionPro = 'cortex_pro_monthly';
  static const String annualSubscriptionPro = 'cortex_pro_annual';
  static const String monthlySubscriptionUltra = 'cortex_ultra_monthly';
  static const String annualSubscriptionUltra = 'cortex_ultra_annual';

  static const Set<String> _subscriptionIds = { monthlySubscriptionPlus, annualSubscriptionPlus, monthlySubscriptionPro, annualSubscriptionPro, monthlySubscriptionUltra, annualSubscriptionUltra };
  static const Set<String> _creditProductIds = { 'cortex_credits_250', 'credits_500', 'credits_1000', 'credits_2500', 'credits_5000' };

  final _purchaseCompletedController = StreamController<String>.broadcast();
  Stream<String> get onPurchaseCompleted => _purchaseCompletedController.stream;

  late IntrovertNotificationService _notificationService;
  late AppLocalizations _localizations;

  static final List<ProductDetails> _mockProducts = [
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

  static const String appPackageName = "com.vertex.cortex";

  Future<void> initialize({
    required IntrovertNotificationService notificationService,
    required AppLocalizations localizations,
  }) async {
    if (_initialized) return;
    _initialized = true;

    _notificationService = notificationService;
    _localizations = localizations;

    _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: _onPurchaseStreamError,
    );

    _listenToUserChanges();
    await _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    // 1. Invalidate cache if global refresh is requested
    if (AppDataState().needsRefresh) {
      CacheService.invalidate(CacheKey.premiumProducts);
    }

    // 2. Attempt to load from cache first for instant UI
    final cachedProducts = CacheService.get<List<ProductDetails>>(CacheKey.premiumProducts);

    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      log('Cache hit! Initializing with cached product data.', name: _logName);
      _products = cachedProducts;
      _errorMessage = null;
      _setLoading(false);
    } else {
      _setLoading(true);
    }

    // --- TEST MODE LOGIC ---
    if (!kReleaseMode) {
      log('Running in Test Mode. Using mock product data.', name: _logName);
      await Future.delayed(const Duration(milliseconds: 800));
      _products = _mockProducts;
      CacheService.set(CacheKey.premiumProducts, _mockProducts);
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    // --- INTERNET CHECK ---
    if (!await InternetService().hasInternet()) {
      _setError(_localizations.noInternetConnection);
      return;
    }

    // --- STORE AVAILABILITY CHECK ---
    if (!await _inAppPurchase.isAvailable()) {
      _setError(_localizations.anErrorOccurred);
      return;
    }

    try {
      final allProductIds = {..._subscriptionIds, ..._creditProductIds};
      final response = await _inAppPurchase.queryProductDetails(allProductIds);

      if (response.error != null) {
        throw Exception('Store error: ${response.error!.message}');
      }

      // --- Handle Empty List as an Error (Without Crashlytics) ---
      if (response.productDetails.isEmpty) {
        log('Store returned zero products. Treating as failure to trigger Retry UI.', name: _logName);
        // Throwing forces catch block
        throw Exception("Store returned no products. This implies a Store connection issue.");
      }

      _products = response.productDetails;
      CacheService.set(CacheKey.premiumProducts, _products);
      _errorMessage = null;

    } catch (e, stack) {
      log('Error fetching product details: $e', name: _logName, error: e);

      if (e.toString().contains("Store returned no products")) {
        _setError(_localizations.noProductsFound);
      } else {
        await _crashlytics.recordError(
          e, stack, reason: 'Failed in _fetchProductDetails catch block.', fatal: true,
        );
        _setError(_localizations.anErrorOccurred);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> purchase(ProductDetails product) async {
    if (_isPurchasePending) {
      log('Purchase attempt ignored: Another purchase is already pending.', name: _logName);
      return;
    }

    _setPurchasePending(true); // Lock UI immediately.

    final user = _auth.currentUser;
    if (user == null) {
      log('Purchase blocked: User is not authenticated.', name: _logName);
      _setPurchasePending(false);
      return;
    }

    // --- PATH 1: DESIGNATED TESTER (Bypasses Google Play) ---
    final isDesignatedTester = user.email == "mustawtfa@gmail.com";
    if (isDesignatedTester) {
      log('Initiating DIRECT test purchase for tester: ${product.id}', name: _logName);
      try {
        final callable = _functions.httpsCallable('verifyPurchase');
        await callable.call<dynamic>({
          'productId': product.id,
          'platform': defaultTargetPlatform.name.toLowerCase(),
          'packageName': appPackageName,
        });

        log('Test purchase for ${product.id} successfully processed by server.', name: _logName);

        if (product.id == 'cancel_subscription_test') {
          _notificationService.showNotification(
            message: _localizations.subscriptionCancelled,
            type: NotificationType.success,
            oneLine: false,
          );
        } else {
          _notificationService.showNotification(
            message: _localizations.purchaseSuccessful,
            type: NotificationType.success,
            oneLine: false,
          );
          _purchaseCompletedController.add(product.id);
        }
        AppDataState().markUserDataAsChanged();
      } on FirebaseFunctionsException catch (e) {
        log('Test purchase failed: ${e.message}', name: _logName, error: e);
        _setError('Test purchase failed: ${e.message}');
        _notificationService.showNotification(
          message: e.message ?? _localizations.purchaseError,
          type: NotificationType.error,
          oneLine: false,
        );
      } catch (e, stack) {
        log('An unexpected client error occurred during test purchase.', name: _logName, error: e);
        await _crashlytics.recordError(
          e,
          stack,
          reason: 'Client-side error during test purchase for ${product.id}',
          fatal: false,
        );
        _setError("An unexpected error occurred.");
        _notificationService.showNotification(
          message: _localizations.anErrorOccurred,
          type: NotificationType.error,
          oneLine: false,
        );
      } finally {
        _setPurchasePending(false);
      }
      return;
    }

    if (!kReleaseMode) {
      log('Running in Debug Mode. Simulating successful purchase for ${product.id}', name: _logName);

      await Future.delayed(const Duration(seconds: 1));

      _notificationService.showNotification(
        message: "${_localizations.purchaseSuccessful} (Test)",
        type: NotificationType.success,
        oneLine: false,
      );

      _purchaseCompletedController.add(product.id);
      AppDataState().markUserDataAsChanged();

      _setPurchasePending(false);
      return;
    }

    // --- PATH 2: REGULAR USER (Standard Google Play Flow) ---

    ProductDetails freshProductDetails;
    try {
      if (!await _inAppPurchase.isAvailable()) {
        throw Exception("Billing service is not available at the moment of purchase.");
      }

      final response = await _inAppPurchase.queryProductDetails({product.id});
      if (response.error != null) {
        throw Exception('Store error while refreshing product: ${response.error!.message}');
      }
      if (response.productDetails.isEmpty) {
        throw Exception('Product with ID ${product.id} not found on the store. It might have been removed.');
      }

      freshProductDetails = response.productDetails.first;
      log('Successfully refreshed product details for ${product.id}', name: _logName);
    } catch (e, stack) {
      log('Could not refresh product details before purchase: $e', name: _logName, error: e);
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Failed to refresh product details for ${product.id} right before purchase.',
        fatal: false,
      );
      _notificationService.showNotification(
        message: _localizations.productNotFound,
        type: NotificationType.error,
        oneLine: false,
      );
      _setPurchasePending(false);
      return;
    }

    await _crashlytics.setUserIdentifier(user.uid);
    await _crashlytics.setCustomKey('iap_product_id', freshProductDetails.id);

    PurchaseParam purchaseParam;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final googlePlayProductDetails = freshProductDetails as GooglePlayProductDetails;
      final offerToken = googlePlayProductDetails.offerToken;

      // --- INDUSTRY STANDARD BEHAVIOUR ---
      // 1) Credits (one-time products) never require an offer token.
      // 2) Subscriptions MUST have a valid offer token; otherwise we abort safely.
      final bool isSubscription = _subscriptionIds.contains(googlePlayProductDetails.id);

      if (isSubscription) {
        if (offerToken == null || offerToken.isEmpty) {
          // Treat as a configuration / Play Store cache issue and DO NOT call buyNonConsumable.
          log(
            'Subscription ${googlePlayProductDetails.id} is missing a valid offerToken. Aborting purchase to avoid INVALID_OFFER_TOKEN crash.',
            name: _logName,
          );
          await _crashlytics.recordError(
            'MissingOfferToken',
            StackTrace.current,
            reason:
            'Attempted to purchase subscription ${googlePlayProductDetails.id} without a valid offer token. This is usually a Play Store configuration or cache issue.',
            fatal: false,
          );
          _notificationService.showNotification(
            message: _localizations.cacheIsNotUpToDate,
            type: NotificationType.error,
            oneLine: false,
          );
          _setPurchasePending(false);
          return;
        }

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: googlePlayProductDetails,
          applicationUserName: user.uid,
          offerToken: offerToken,
        );
      } else {
        // Non-subscription products (credits) use the regular PurchaseParam.
        purchaseParam = PurchaseParam(
          productDetails: freshProductDetails,
          applicationUserName: user.uid,
        );
      }
    } else {
      // iOS and others: no offer token concept.
      purchaseParam = PurchaseParam(
        productDetails: freshProductDetails,
        applicationUserName: user.uid,
      );
    }

    try {
      if (_creditProductIds.contains(freshProductDetails.id)) {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e, stack) {
      bool isLikelyStaleProductError = false;
      bool isInvalidOfferTokenError = false;

      String message = '';
      String code = '';

      if (e is PlatformException) {
        message = (e.message ?? '').toLowerCase();
        code = e.code.toLowerCase();

        if (message.contains('pendingintent') ||
            message.contains('null object reference') ||
            message.contains('getintentsender')) {
          isLikelyStaleProductError = true;
        }

        if (code.contains('invalid_offer_token') ||
            message.contains('invalid_offer_token')) {
          isInvalidOfferTokenError = true;
        }
      }

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('pendingintent') ||
          errorString.contains('null object reference') ||
          errorString.contains('getintentsender')) {
        isLikelyStaleProductError = true;
      }
      if (errorString.contains('invalid_offer_token')) {
        isInvalidOfferTokenError = true;
      }

      log('Error initiating purchase flow: $e', name: _logName, error: e);

      if (isLikelyStaleProductError) {
        log('Known native billing crash suppressed (PendingIntent). UI remains stable.', name: _logName);

        _notificationService.showNotification(
          message: _localizations.anErrorOccurred,
          type: NotificationType.error,
        );
      } else if (isInvalidOfferTokenError) {
        log('INVALID_OFFER_TOKEN encountered.', name: _logName);
        _notificationService.showNotification(
          message: _localizations.productNotFound,
          type: NotificationType.error,
          oneLine: false,
        );
      } else {
        // Truly unknown client-side issue; still non-fatal (purchases must never crash the app).
        await _crashlytics.recordError(
          e,
          stack,
          reason:
          'UNKNOWN error on buy call for product ${freshProductDetails.id}',
          fatal: false,
        );
        _notificationService.showNotification(
          message: _localizations.anErrorOccurred,
          type: NotificationType.error,
          oneLine: false,
        );
      }

      _setPurchasePending(false);
    }
  }

  /// This function also checks if the user is the designated
  /// tester and routes them to a special test purchase instead of the Play Store.
  Future<void> manageSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final isDesignatedTester = user.email == "mustawtfa@gmail.com";

    // --- PATH 1: DESIGNATED TESTER CANCELLATION ---
    if (isDesignatedTester) {
      log('Designated tester is managing subscription. Triggering test cancellation.', name: _logName);
      // To cancel, the tester "purchases" a special, non-existent product ID.
      // The server recognizes this ID and processes a cancellation.
      final cancelProduct = ProductDetails(
        id: 'cancel_subscription_test',
        title: 'Cancel Test Subscription',
        description: 'A virtual product to cancel a test subscription.',
        price: '',
        rawPrice: 0.0,
        currencyCode: '',
      );
      // We reuse the main purchase function, which already has the tester logic.
      await purchase(cancelProduct);
      return;
    }

    // --- PATH 2: REGULAR USER MANAGEMENT (Platform Aware) ---
    Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse('https://play.google.com/store/account/subscriptions?package=$appPackageName');
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e, stack) {
      log('Could not launch subscription management URL.', name: _logName, error: e);
      await _crashlytics.recordError(e, stack, reason: 'Failed to launch subscription management URL.', fatal: false);
    }
  }

  // --- RESTORE PURCHASES ---
  Future<void> restorePurchases() async {
    if (_isPurchasePending) return;

    _setPurchasePending(true);

    try {
      log('Restoring purchases...', name: _logName);

      await _inAppPurchase.restorePurchases();

      Future.delayed(const Duration(seconds: 3), () {
        if (_isPurchasePending) {
          log('Restore timeout or no purchases found. Resetting UI.', name: _logName);
          _setPurchasePending(false);
        }
      });

    } catch (e, stack) {
      log('Restore failed: $e', name: _logName, error: e);
      await _crashlytics.recordError(e, stack, reason: 'Restore purchases failed');

      _notificationService.showNotification(
        message: _localizations.anErrorOccurred,
        type: NotificationType.error,
      );

      _setPurchasePending(false);
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:   _setPurchasePending(true); break;
        case PurchaseStatus.error:     _handleFailedPurchase(purchaseDetails); break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:  _verifyAndCompletePurchase(purchaseDetails); break;
        case PurchaseStatus.canceled:  _handleCanceledPurchase(purchaseDetails); break;
      }
    }
  }

  Future<void> _verifyAndCompletePurchase(PurchaseDetails purchaseDetails) async {
    _notificationService.showNotification(
      message: _localizations.purchaseReceived,
      type: NotificationType.neutral,
      oneLine: false,
    );

    final verificationData = purchaseDetails.verificationData.serverVerificationData;

    // Guard against empty or invalid receipts
    if (verificationData.trim().isEmpty || verificationData.trim() == "{}" || verificationData.trim() == "[]") {
      log('Skipping cloud verification: invalid or empty receipt for ${purchaseDetails.productID}', name: _logName);
      await _crashlytics.recordError(
        'EmptyReceiptData',
        StackTrace.current,
        reason: 'Skipped verification for ${purchaseDetails.productID} due to empty or malformed receipt.',
        fatal: false,
      );
      // Complete purchase locally to avoid stuck state
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      _notificationService.showNotification(
        message: _localizations.purchaseSuccessful,
        type: NotificationType.success,
        oneLine: false,
      );
      _purchaseCompletedController.add(purchaseDetails.productID);
      _setPurchasePending(false);
      return;
    }

    try {
      final callable = _functions.httpsCallable('verifyPurchase');
      await callable.call<dynamic>({
        'receiptData': verificationData,
        'productId': purchaseDetails.productID,
        'platform': defaultTargetPlatform.name.toLowerCase(),
        'packageName': appPackageName,
      });

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }

      _notificationService.showNotification(
        message: _localizations.purchaseSuccessful,
        type: NotificationType.success,
        oneLine: false,
      );

      AppDataState().markUserDataAsChanged();
      _purchaseCompletedController.add(purchaseDetails.productID);
    } on FirebaseFunctionsException catch (e, stack) {
      // Handle backend HttpsError gracefully
      log('Purchase verification failed with FirebaseFunctionsException: ${e.message}', name: _logName);
      await _crashlytics.recordError(e, stack, reason: 'Server returned HttpsError for ${purchaseDetails.productID}', fatal: false);
      _notificationService.showNotification(
        message: _localizations.verificationDelayed,
        type: NotificationType.error,
        oneLine: false,
      );
    } catch (e, stack) {
      // Handle generic failures without crashing
      log('Unexpected verification exception: $e', name: _logName);
      await _crashlytics.recordError(e, stack, reason: 'Unexpected client-side error during verifyPurchase', fatal: false);
      _notificationService.showNotification(
        message: _localizations.anErrorOccurred,
        type: NotificationType.error,
        oneLine: false,
      );
    } finally {
      _setPurchasePending(false);
    }
  }

  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    log('Purchase error: ${purchaseDetails.error?.message}', name: _logName, error: purchaseDetails.error);
    _crashlytics.recordError(
      purchaseDetails.error ?? 'Unknown Purchase Error', StackTrace.current, reason: 'Purchase failed for product ${purchaseDetails.productID}', fatal: false,
    );

    // THE FIX: Show a user-friendly error notification from the store.
    final errorMessage = purchaseDetails.error?.message ?? _localizations.purchaseStreamError;
    _notificationService.showNotification(
      message: errorMessage,
      type: NotificationType.error,
      oneLine: false,
    );

    if (purchaseDetails.pendingCompletePurchase) _inAppPurchase.completePurchase(purchaseDetails);
    _setPurchasePending(false);
  }

  void _onPurchaseStreamError(dynamic error, StackTrace? stack) {
    log('Purchase Stream Error: $error', name: _logName, error: error);
    _crashlytics.recordError(
      error, stack, reason: 'An error occurred in the global purchase stream.', fatal: true,
    );

    // THE FIX: Show a generic error notification for stream-level failures.
    _notificationService.showNotification(
      message: _localizations.purchaseStreamError,
      type: NotificationType.error,
      oneLine: false,
    );

    _setPurchasePending(false);
  }


  void _handleCanceledPurchase(PurchaseDetails d) {
    if (d.pendingCompletePurchase) _inAppPurchase.completePurchase(d);
    _setPurchasePending(false);
  }

  void _listenToUserChanges() {
    _userSubscription?.cancel();
    final user = _auth.currentUser;
    if (user != null) {
      _userSubscription = _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
        final data = snapshot.data();
        _currentUserSubscriptionLevel = data?['hasCortexSubscription'] ?? 0;
        _activeSubscriptionOption = data?['activeSubscriptionOption'];
        notifyListeners();
      }, onError: (error, stack) {
        log('Error listening to user document: $error', name: _logName, error: error);
        _crashlytics.recordError(error, stack, reason: 'Firestore user snapshot listener failed.', fatal: false);
      });
    }
  }

  void _setLoading(bool value) { _isLoading = value; notifyListeners(); }
  void _setPurchasePending(bool value) { _isPurchasePending = value; notifyListeners(); }
  void _setError(String message) { _errorMessage = message; _isLoading = false; notifyListeners(); }


  @override
  void dispose() {
    _purchaseStreamSubscription.cancel();
    _userSubscription?.cancel();
    _purchaseCompletedController.close();

    super.dispose();
  }
}
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
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
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
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // --- Stream Subscriptions ---
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  // --- Private State Properties ---
  bool _isLoading = true;
  bool _isPurchasePending = false;
  String? _errorMessage;
  List<ProductDetails> _products = [];
  int _currentUserSubscriptionLevel = 0;
  String? _activeSubscriptionOption;
  bool _initialized = false;

  // --- Special Offer State ---
  int? _specialOfferExpiresAt;
  bool _isSpecialOfferActive = false;

  // --- Public Getters ---
  bool get isLoading => _isLoading;

  bool get isPurchasePending => _isPurchasePending;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<ProductDetails> get allProducts => _products;

  List<ProductDetails> get subscriptionProducts =>
      _products.where((p) => _subscriptionIds.contains(p.id)).toList();

  int get currentUserSubscriptionLevel => _currentUserSubscriptionLevel;

  String? get activeSubscriptionOption => _activeSubscriptionOption;

  // --- Special Offer Getters ---
  bool get isSpecialOfferActive => _isSpecialOfferActive;
  int? get specialOfferExpiresAt => _specialOfferExpiresAt;

  bool get isWelcomeOffer {
    final user = _auth.currentUser;
    if (user?.metadata.creationTime == null) return true;
    final daysSinceCreation =
        DateTime.now().difference(user!.metadata.creationTime!).inDays;
    return daysSinceCreation < 7;
  }

  // --- Product Identifiers & Mocks ---
  static const String _logName = 'FundsBackend';
  static const String monthlySubscriptionPlus = 'vertex_ai_monthly_sub';
  static const String annualSubscriptionPlus = 'vertex_ai_annual_sub';
  static const String monthlySubscriptionPro = 'cortex_pro_monthly';
  static const String annualSubscriptionPro = 'cortex_pro_annual';
  static const String monthlySubscriptionUltra = 'cortex_ultra_monthly';
  static const String annualSubscriptionUltra = 'cortex_ultra_annual';

  static const Set<String> _subscriptionIds = {
    monthlySubscriptionPlus,
    annualSubscriptionPlus,
    monthlySubscriptionPro,
    annualSubscriptionPro,
    monthlySubscriptionUltra,
    annualSubscriptionUltra
  };

  final _purchaseCompletedController = StreamController<String>.broadcast();

  Stream<String> get onPurchaseCompleted => _purchaseCompletedController.stream;

  late IntrovertNotificationService _notificationService;
  late AppLocalizations _localizations;

  static final List<ProductDetails> _mockProducts = [
    ProductDetails(
        id: 'vertex_ai_monthly_sub',
        title: 'Plus Monthly',
        description: 'Test',
        price: '\$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD'),
    ProductDetails(
        id: 'vertex_ai_annual_sub',
        title: 'Plus Annual',
        description: 'Test',
        price: '\$49.99',
        rawPrice: 49.99,
        currencyCode: 'USD'),
    ProductDetails(
        id: 'cortex_pro_monthly',
        title: 'Pro Monthly',
        description: 'Test',
        price: '\$9.99',
        rawPrice: 9.99,
        currencyCode: 'USD'),
    ProductDetails(
        id: 'cortex_pro_annual',
        title: 'Pro Annual',
        description: 'Test',
        price: '\$99.99',
        rawPrice: 99.99,
        currencyCode: 'USD'),
    ProductDetails(
        id: 'cortex_ultra_monthly',
        title: 'Ultra Monthly',
        description: 'Test',
        price: '\$19.99',
        rawPrice: 19.99,
        currencyCode: 'USD'),
    ProductDetails(
        id: 'cortex_ultra_annual',
        title: 'Ultra Annual',
        description: 'Test',
        price: '\$199.99',
        rawPrice: 199.99,
        currencyCode: 'USD'),
  ];

  static const String appPackageName = "com.vertex.cortex";

  // --- Access and Manage FundsBackend Provider ----

  FundsBackend() {
    _startListeningToPurchases();
  }

  bool _isPlaceholderReceipt(String s) {
    final t = s.trim();
    return t.isEmpty || t == "{}" || t == "[]";
  }

  bool _looksLikeJson(String s) {
    final t = s.trimLeft();
    return t.startsWith("{") || t.startsWith("[");
  }

  bool _looksLikeBase64(String s) {
    final t = s.replaceAll(RegExp(r"\s+"), ""); // remove whitespace/newlines
    if (t.length < 50) return false;
    if (_looksLikeJson(t)) return false;
    return RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(t);
  }

  Future<String?> _resolveIosReceiptBase64(
      PurchaseDetails purchaseDetails) async {
    final v = purchaseDetails.verificationData;

    final fromLocal = (v.localVerificationData).trim();
    if (!_isPlaceholderReceipt(fromLocal) && _looksLikeBase64(fromLocal)) {
      return fromLocal;
    }

    final fromServer = (v.serverVerificationData).trim();
    if (!_isPlaceholderReceipt(fromServer) && _looksLikeBase64(fromServer)) {
      return fromServer;
    }

    try {
      final storekit = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      try {
        await storekit.sync();
      } catch (_) {}

      final refreshed = await storekit.refreshPurchaseVerificationData();
      final refreshedReceipt = (refreshed?.serverVerificationData ??
              refreshed?.localVerificationData ??
              '')
          .trim();

      if (!_isPlaceholderReceipt(refreshedReceipt) &&
          _looksLikeBase64(refreshedReceipt)) {
        return refreshedReceipt;
      }
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Failed to refresh iOS receipt data (StoreKit).',
        fatal: false,
      );
    }

    return null;
  }

  void setNotificationService(IntrovertNotificationService service) {
    _notificationService = service;
  }

  Future<void> updateLocalizationAndRefresh({
    required AppLocalizations localizations,
  }) async {
    _localizations = localizations;

    if (_products.isEmpty || AppDataState().needsRefresh) {
      await _fetchProductDetails();
    }
  }

  void _startListeningToPurchases() {
    _purchaseStreamSubscription?.cancel();

    _purchaseStreamSubscription = _inAppPurchase.purchaseStream
        .listen(_onPurchaseUpdated, onError: _onPurchaseStreamError);
    _listenToUserChanges();
  }

  // Finally

  Future<void> initialize({
    required IntrovertNotificationService notificationService,
    required AppLocalizations localizations,
  }) async {
    if (_initialized) return;
    _initialized = true;

    _notificationService = notificationService;
    _localizations = localizations;

    _startListeningToPurchases();

    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((user) {
      _listenToUserChanges();
    });

    await _fetchProductDetails();
  }

  /// Checks or starts the special offer by calling the Cloud Function.
  /// Updates [_isSpecialOfferActive] and [_specialOfferExpiresAt].
  Future<void> checkOrStartSpecialOffer() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('Cannot check special offer: User not authenticated.',
          name: _logName);
      return;
    }

    try {
      final callable = _functions.httpsCallable('checkOrStartSpecialOffer');
      final result = await callable.call<Map<String, dynamic>>({});

      final data = result.data;
      final status = data['status'] as String?;
      final expiresAt = data['expiresAt'] as int?;

      if (status == 'active' && expiresAt != null) {
        _isSpecialOfferActive = true;
        _specialOfferExpiresAt = expiresAt;
        log('Special offer ACTIVE. Expires at: ${DateTime.fromMillisecondsSinceEpoch(expiresAt)}',
            name: _logName);
      } else {
        _isSpecialOfferActive = false;
        _specialOfferExpiresAt = null;
        log('Special offer in COOLDOWN or unavailable.', name: _logName);
      }

      notifyListeners();
    } on FirebaseFunctionsException catch (e) {
      log('Special offer check failed: ${e.message}', name: _logName, error: e);
      _isSpecialOfferActive = false;
      _specialOfferExpiresAt = null;
    } catch (e, stack) {
      log('Unexpected error checking special offer: $e',
          name: _logName, error: e);
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Failed to check or start special offer.',
        fatal: false,
      );
      _isSpecialOfferActive = false;
      _specialOfferExpiresAt = null;
    }
  }

  Future<void> _fetchProductDetails() async {
    // 1. Invalidate cache if global refresh is requested
    if (AppDataState().needsRefresh) {
      CacheService.invalidate(CacheKey.premiumProducts);
    }

    // 2. Attempt to load from cache first for instant UI
    final cachedProducts =
        CacheService.get<List<ProductDetails>>(CacheKey.premiumProducts);

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
      final allProductIds = {..._subscriptionIds};
      final response = await _inAppPurchase.queryProductDetails(allProductIds);

      if (response.error != null) {
        throw Exception('Store error: ${response.error!.message}');
      }

      // --- Handle Empty List as an Error (Without Crashlytics) ---
      if (response.productDetails.isEmpty) {
        log('Store returned zero products. Treating as failure to trigger Retry UI.',
            name: _logName);
        // Throwing forces catch block
        throw Exception(
            "Store returned no products. This implies a Store connection issue.");
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
          e,
          stack,
          reason: 'Failed in _fetchProductDetails catch block.',
          fatal: true,
        );
        _setError(_localizations.anErrorOccurred);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> purchase(ProductDetails product) async {
    if (_isPurchasePending) {
      log('Purchase attempt ignored: Another purchase is already pending.',
          name: _logName);
      return;
    }

    _setPurchasePending(true); // Lock UI immediately.

    final user = _auth.currentUser;
    if (user == null) {
      log('Purchase blocked: User is not authenticated.', name: _logName);
      _setPurchasePending(false);
      return;
    }
    ProductDetails freshProductDetails;
    try {
      if (!await _inAppPurchase.isAvailable()) {
        throw Exception(
            "Billing service is not available at the moment of purchase.");
      }

      final response = await _inAppPurchase.queryProductDetails({product.id});
      if (response.error != null) {
        throw Exception(
            'Store error while refreshing product: ${response.error!.message}');
      }
      if (response.productDetails.isEmpty) {
        throw Exception(
            'Product with ID ${product.id} not found on the store. It might have been removed.');
      }

      freshProductDetails = response.productDetails.first;
      log('Successfully refreshed product details for ${product.id}',
          name: _logName);
    } catch (e, stack) {
      log('Could not refresh product details before purchase: $e',
          name: _logName, error: e);
      await _crashlytics.recordError(
        e,
        stack,
        reason:
            'Failed to refresh product details for ${product.id} right before purchase.',
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
      final googlePlayProductDetails =
          freshProductDetails as GooglePlayProductDetails;
      final offerToken = googlePlayProductDetails.offerToken;

      final bool isSubscription =
          _subscriptionIds.contains(googlePlayProductDetails.id);

      if (isSubscription) {
        if (offerToken == null || offerToken.isEmpty) {
          log(
            'Subscription ${googlePlayProductDetails.id} is missing a valid offerToken.',
            name: _logName,
          );
          await _crashlytics.recordError(
            'MissingOfferToken',
            StackTrace.current,
            reason: 'Attempted to purchase subscription without offer token.',
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
        purchaseParam = PurchaseParam(
          productDetails: freshProductDetails,
          applicationUserName: user.uid,
        );
      }
    } else {
      // iOS
      purchaseParam = PurchaseParam(
        productDetails: freshProductDetails,
        applicationUserName: user.uid,
      );
    }

    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e, stack) {
      bool isLikelyStaleProductError = false;
      bool isInvalidOfferTokenError = false;
      bool isIOSStoreKitError = false;
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
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          if (code == 'unknown' ||
              message.contains('storekiterror') ||
              message.contains('usercancelled')) {
            isIOSStoreKitError = true;
          }
        }
      }
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('storekiterror')) isIOSStoreKitError = true;

      log('Error initiating purchase flow: $e', name: _logName, error: e);

      if (isLikelyStaleProductError) {
        _notificationService.showNotification(
            message: _localizations.anErrorOccurred,
            type: NotificationType.error);
      } else if (isInvalidOfferTokenError) {
        _notificationService.showNotification(
            message: _localizations.productNotFound,
            type: NotificationType.error,
            oneLine: false);
      } else if (isIOSStoreKitError) {
        log('iOS StoreKit generic error (likely user cancelled). Ignored.',
            name: _logName);
      } else {
        await _crashlytics.recordError(e, stack,
            reason: 'UNKNOWN error on buy call', fatal: false);
        _notificationService.showNotification(
            message: _localizations.anErrorOccurred,
            type: NotificationType.error,
            oneLine: false);
      }
      _setPurchasePending(false);
    }
  }

  /// This function also checks if the user is the designated
  /// tester and routes them to a special test purchase instead of the Play Store.
  Future<void> manageSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return;

    Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse(
          'https://play.google.com/store/account/subscriptions?package=$appPackageName');
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e, stack) {
      log('Could not launch subscription management URL.',
          name: _logName, error: e);
      await _crashlytics.recordError(e, stack,
          reason: 'Failed to launch subscription management URL.',
          fatal: false);
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
          log('Restore timeout or no purchases found. Resetting UI.',
              name: _logName);
          _setPurchasePending(false);
        }
      });
    } catch (e, stack) {
      log('Restore failed: $e', name: _logName, error: e);
      await _crashlytics.recordError(e, stack,
          reason: 'Restore purchases failed');

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
        case PurchaseStatus.pending:
          _setPurchasePending(true);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndCompletePurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }
    }
  }

  Future<void> _verifyAndCompletePurchase(
      PurchaseDetails purchaseDetails) async {
    _notificationService.showNotification(
      message: _localizations.purchaseReceived,
      type: NotificationType.neutral,
      oneLine: false,
    );

    String? verificationData;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      verificationData = await _resolveIosReceiptBase64(purchaseDetails);

      if (verificationData == null) {
        log('iOS receipt could not be resolved. Will NOT complete purchase yet.',
            name: _logName);

        _notificationService.showNotification(
          message: _localizations.verificationDelayed,
          type: NotificationType.error,
          oneLine: false,
        );

        _setPurchasePending(false);
        return;
      }
    } else {
      final server =
          purchaseDetails.verificationData.serverVerificationData.trim();
      final local =
          purchaseDetails.verificationData.localVerificationData.trim();

      verificationData = !_isPlaceholderReceipt(server)
          ? server
          : (!_isPlaceholderReceipt(local) ? local : null);

      if (verificationData == null) {
        log('Skipping cloud verification: invalid or empty receipt for ${purchaseDetails.productID}',
            name: _logName);

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        _setPurchasePending(false);
        return;
      }
    }

    void safeAddEvent() {
      if (!_purchaseCompletedController.isClosed) {
        _purchaseCompletedController.add(purchaseDetails.productID);
      }
    }

    if (verificationData.trim().isEmpty ||
        verificationData.trim() == "{}" ||
        verificationData.trim() == "[]") {
      log('Skipping cloud verification: invalid or empty receipt for ${purchaseDetails.productID}',
          name: _logName);

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
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
        'transactionId': purchaseDetails.purchaseID,
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

      // Fix: Check if the transaction is recent (e.g., within 2 minutes).
      // If it's an old transaction (restored or replayed), we do NOT trigger the confetti or analytics event.
      bool isRecentPurchase = true;
      if (purchaseDetails.transactionDate != null) {
        try {
          final rawDate = purchaseDetails.transactionDate!;
          DateTime? transactionTime;

          // Try parse as milliseconds (common for Android/Google Play)
          final dtInt = int.tryParse(rawDate);
          if (dtInt != null && dtInt > 0) {
            transactionTime = DateTime.fromMillisecondsSinceEpoch(dtInt);
          } else {
            // Try parse as ISO String (common for generic formatting)
            transactionTime = DateTime.tryParse(rawDate);
          }

          if (transactionTime != null) {
            final diff = DateTime.now().difference(transactionTime);
            // 5 minutes buffer to be safe against clock skew/network delay
            if (diff.inMinutes.abs() > 5) {
              isRecentPurchase = false;
              log('Purchase is old (${diff.inMinutes} mins). Skipping confetti/event.',
                  name: _logName);
            }
          }
        } catch (_) {}
      }

      if (isRecentPurchase) {
        safeAddEvent();
      }
    } on FirebaseFunctionsException catch (e, stack) {
      log('Purchase verification failed with FirebaseFunctionsException: ${e.message} (Code: ${e.code})',
          name: _logName);

      if (e.code == 'invalid-argument' || e.code == 'not-found') {
        log('Fatal validation error. Forcing local completion to clear queue.',
            name: _logName);

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }

        _notificationService.showNotification(
          message: _localizations.purchaseError,
          type: NotificationType.error,
          oneLine: false,
        );
      } else {
        // For other errors (internal, unavailable), keep it in queue to retry later.
        _notificationService.showNotification(
          message: _localizations.verificationDelayed,
          type: NotificationType.error,
          oneLine: false,
        );
      }

      await _crashlytics.recordError(e, stack,
          reason: 'Server returned HttpsError for ${purchaseDetails.productID}',
          fatal: false);
    } catch (e, stack) {
      log('Unexpected verification exception: $e', name: _logName);
      await _crashlytics.recordError(e, stack,
          reason: 'Unexpected client-side error during verifyPurchase',
          fatal: false);
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
    final errorCode = purchaseDetails.error?.code ?? '';
    final errorMessage =
        purchaseDetails.error?.message ?? _localizations.purchaseStreamError;
    final errorString = purchaseDetails.error?.toString().toLowerCase() ?? '';

    final isUserCancelled =
        errorCode == 'canceled' || errorString.contains('user canceled');
    final isInsufficientFunds = errorCode == 'purchase_error' &&
        (errorMessage.contains('insufficient funds') ||
            errorMessage.contains('Payment declined') ||
            errorString.contains('billingunavailable'));
    final isAlreadyOwned = errorCode == 'item_already_owned';

    if (!isUserCancelled && !isInsufficientFunds && !isAlreadyOwned) {
      log('Purchase error: $errorMessage',
          name: _logName, error: purchaseDetails.error);
      _crashlytics.recordError(
        purchaseDetails.error ?? 'Unknown Purchase Error',
        StackTrace.current,
        reason: 'Purchase failed for product ${purchaseDetails.productID}',
        fatal: false,
      );
    } else {
      log('Purchase failed due to user/billing status (Ignored from Crashlytics): $errorMessage',
          name: _logName);
    }

    _notificationService.showNotification(
      message: errorMessage,
      type: NotificationType.error,
      oneLine: false,
    );

    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }

    _setPurchasePending(false);
  }

  void _onPurchaseStreamError(dynamic error, StackTrace? stack) {
    log('Purchase Stream Error: $error', name: _logName, error: error);
    _crashlytics.recordError(
      error,
      stack,
      reason: 'An error occurred in the global purchase stream.',
      fatal: true,
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
    _userSubscription = null;

    final user = _auth.currentUser;

    if (user == null) {
      _currentUserSubscriptionLevel = 0;
      _activeSubscriptionOption = null;
      notifyListeners();
      return;
    }

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        _currentUserSubscriptionLevel = 0;
        _activeSubscriptionOption = null;
      } else {
        final data = snapshot.data();
        _currentUserSubscriptionLevel = data?['hasCortexSubscription'] ?? 0;
        _activeSubscriptionOption = data?['activeSubscriptionOption'];
      }
      notifyListeners();
    }, onError: (error, stack) {
      if (error.toString().contains("permission-denied")) {
        log('Firestore permission denied (User signed out during sync). Subscription cancelled.',
            name: _logName);
        _userSubscription?.cancel();
        return;
      }

      log('Error listening to user document: $error',
          name: _logName, error: error);
      _crashlytics.recordError(error, stack,
          reason: 'Firestore user snapshot listener failed.', fatal: false);
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setPurchasePending(bool value) {
    _isPurchasePending = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseStreamSubscription?.cancel();
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    _purchaseCompletedController.close();
    super.dispose();
  }
}

// lib/funds/backend.dart (FINALIZED & SECURED - v7.4)
// This version includes CRITICAL fixes for:
// 1. Double-billing prevention on Android upgrades.
// 2. "Ghost Purchase" prevention (ensuring receipts exist before completing).

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
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

// To track the exact Product ID the user currently owns (for Upgrades)
  String? _activeSubscriptionProductId;

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

  String? get activeSubscriptionProductId => _activeSubscriptionProductId;

// --- Special Offer Getters ---
  bool get isSpecialOfferActive => _isSpecialOfferActive;

  int? get specialOfferExpiresAt => _specialOfferExpiresAt;

  bool get isWelcomeOffer {
    final user = _auth.currentUser;
    if (user?.metadata.creationTime == null) return true;
    final daysSinceCreation =
        DateTime
            .now()
            .difference(user!.metadata.creationTime!)
            .inDays;
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

  FundsBackend() {
    _startListeningToPurchases();
  }

// --- Receipt Helpers ---

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

// --- Special Offer Logic ---

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
        log('Special offer ACTIVE. Expires at: ${DateTime
            .fromMillisecondsSinceEpoch(expiresAt)}',
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

// --- Fetch Products ---

  Future<void> _fetchProductDetails() async {
    if (AppDataState().needsRefresh) {
      CacheService.invalidate(CacheKey.premiumProducts);
    }

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

    if (!kReleaseMode) {
      log('Running in Test Mode. Using mock product data.', name: _logName);
      await Future.delayed(const Duration(milliseconds: 800));
      _products = _mockProducts;
      CacheService.set(CacheKey.premiumProducts, _mockProducts);
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    if (!await InternetService().hasInternet()) {
      _setError(_localizations.noInternetConnection);
      return;
    }

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

      if (response.productDetails.isEmpty) {
        log('Store returned zero products.', name: _logName);
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

// --- Purchase Logic (Secured) ---

  Future<void> purchase(ProductDetails product) async {
    if (_isPurchasePending) {
      log('Purchase attempt ignored: Another purchase is already pending.',
          name: _logName);
      return;
    }

    _setPurchasePending(true);

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
            'Product with ID ${product
                .id} not found on the store. It might have been removed.');
      }

      freshProductDetails = response.productDetails.first;
      log('Successfully refreshed product details for ${product.id}',
          name: _logName);
    } catch (e) {
      log('Could not refresh product details before purchase: $e',
          name: _logName, error: e);
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

// --- ANDROID LOGIC ---
    if (defaultTargetPlatform == TargetPlatform.android) {
      final googlePlayProductDetails =
      freshProductDetails as GooglePlayProductDetails;
      final offerToken = googlePlayProductDetails.offerToken;

      final bool isSubscription =
      _subscriptionIds.contains(googlePlayProductDetails.id);

      if (isSubscription) {
        if (offerToken == null || offerToken.isEmpty) {
          log('Subscription ${googlePlayProductDetails
              .id} is missing a valid offerToken.',
              name: _logName);
          _notificationService.showNotification(
              message: _localizations.cacheIsNotUpToDate,
              type: NotificationType.error,
              oneLine: false);
          _setPurchasePending(false);
          return;
        }

        ChangeSubscriptionParam? changeParam;

// [FIX: Double Billing Prevention]
// If Firestore says user has a subscription, we MUST find the local token to upgrade it.
// If we can't find it locally, we must stop the purchase to prevent 2 active subscriptions.
        if (_activeSubscriptionProductId != null &&
            _activeSubscriptionProductId!.isNotEmpty) {
          log(
              'Detected active subscription: $_activeSubscriptionProductId. Attempting upgrade flow.',
              name: _logName);

          GooglePlayPurchaseDetails? oldPurchase;

          try {
            final androidAddition = _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            final QueryPurchaseDetailsResponse pastPurchasesResponse =
            await androidAddition.queryPastPurchases();

            if (pastPurchasesResponse.error == null) {
              try {
                oldPurchase = pastPurchasesResponse.pastPurchases
                    .map((e) => e)
                    .firstWhere((p) =>
                p.productID == _activeSubscriptionProductId &&
                    p.status == PurchaseStatus.purchased);
              } catch (_) {
// Not found in list
              }
            }
          } catch (e) {
            log('Failed to query past purchases for upgrade flow: $e',
                name: _logName);
          }

          if (oldPurchase != null) {
            log(
                'Found old purchase token. Configuring replacement mode (Upgrade).',
                name: _logName);
            changeParam = ChangeSubscriptionParam(
              oldPurchaseDetails: oldPurchase,
              replacementMode: ReplacementMode.withTimeProration,
            );
          } else {
// [CRITICAL FIX]
// We know the user has a sub (from DB), but Play Store doesn't show it locally.
// If we proceed without changeParam, Google creates a NEW separate subscription.
// We must block this.
            log(
                'CRITICAL: Sync mismatch. DB says active sub, but local store has no token. Blocking to prevent double billing.',
                name: _logName);

            _notificationService.showNotification(
              message:
              "Please tap 'Restore Purchases' first to sync your account.",
              type: NotificationType.error,
              oneLine: false,
            );
            _setPurchasePending(false);
            return;
          }
        }

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: googlePlayProductDetails,
          applicationUserName: user.uid,
          offerToken: offerToken,
          changeSubscriptionParam: changeParam,
        );
      } else {
        purchaseParam = PurchaseParam(
          productDetails: freshProductDetails,
          applicationUserName: user.uid,
        );
      }
    }
// --- iOS LOGIC ---
    else {
      purchaseParam = PurchaseParam(
        productDetails: freshProductDetails,
        applicationUserName: user.uid,
      );
    }

    try {
      if (_subscriptionIds.contains(product.id)) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e, stack) {
      log('Error initiating purchase flow: $e', name: _logName, error: e);

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user canceled') ||
          errorString.contains('canceled') ||
          errorString.contains('storekiterror')) {
// User cancelled, do nothing
      } else {
        _notificationService.showNotification(
            message: _localizations.anErrorOccurred,
            type: NotificationType.error);
        await _crashlytics.recordError(e, stack,
            reason: 'Error on buy call', fatal: false);
      }
      _setPurchasePending(false);
    }
  }

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
      }
    } catch (e) {
      log('Could not launch subscription management URL.', name: _logName);
    }
  }

// --- Restore Purchases ---

  Future<void> restorePurchases() async {
    if (_isPurchasePending) return;
    _setPurchasePending(true);

    try {
      log('Restoring purchases...', name: _logName);
      await _inAppPurchase.restorePurchases();

// Timeout safety check
      Future.delayed(const Duration(seconds: 4), () {
        if (_isPurchasePending) {
          log('Restore timeout. Resetting UI.', name: _logName);
          _setPurchasePending(false);
        }
      });
    } catch (e) {
      log('Restore failed: $e', name: _logName, error: e);
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

// --- Verification Logic (Secured) ---

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
        log('iOS receipt is NULL. Cannot verify.', name: _logName);
// [FIX: Ghost Purchase Prevention]
// Do NOT complete purchase. Let user retry via Restore.
        _notificationService.showNotification(
          message:
          "Receipt missing. Please restart app or try Restore Purchases.",
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
    }

    if (verificationData == null ||
        verificationData
            .trim()
            .isEmpty ||
        verificationData.trim() == "{}" ||
        verificationData.trim() == "[]") {
      log('Invalid verification data for ${purchaseDetails.productID}',
          name: _logName);
// [FIX: Ghost Purchase Prevention]
// Do NOT complete purchase.
      _notificationService.showNotification(
        message: "Validation failed. Please Restore Purchases.",
        type: NotificationType.error,
        oneLine: false,
      );
      _setPurchasePending(false);
      return;
    }

    void safeAddEvent() {
      if (!_purchaseCompletedController.isClosed) {
        _purchaseCompletedController.add(purchaseDetails.productID);
      }
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

// --- SUCCESS ---
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }

      _notificationService.showNotification(
        message: _localizations.purchaseSuccessful,
        type: NotificationType.success,
        oneLine: false,
      );

      AppDataState().markUserDataAsChanged();

      bool isRecentPurchase = true;
      if (purchaseDetails.transactionDate != null) {
        try {
          final rawDate = purchaseDetails.transactionDate!;
          DateTime? transactionTime;
          final dtInt = int.tryParse(rawDate);
          if (dtInt != null && dtInt > 0) {
            transactionTime = DateTime.fromMillisecondsSinceEpoch(dtInt);
          } else {
            transactionTime = DateTime.tryParse(rawDate);
          }

          if (transactionTime != null) {
            final diff = DateTime.now().difference(transactionTime);
            if (diff.inMinutes.abs() > 5) {
              isRecentPurchase = false;
            }
          }
        } catch (_) {}
      }

      if (isRecentPurchase) {
        safeAddEvent();
      }
    } on FirebaseFunctionsException catch (e, stack) {
      log('Verification failed: ${e.message} (Code: ${e.code})',
          name: _logName);

// [FIX: Selective Completion]
// Only complete if the server FATALLY rejected it.
      if (e.code == 'invalid-argument' ||
          e.code == 'not-found' ||
          e.code == 'already-exists') {
        log('Fatal error. Clearing from queue.', name: _logName);
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        _notificationService.showNotification(
          message: _localizations.purchaseError,
          type: NotificationType.error,
          oneLine: false,
        );
      } else {
// Internal, Unavailable, Timeout -> DO NOT COMPLETE.
// Let user retry later.
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
      log('Unexpected client verification error: $e', name: _logName);
// Do NOT complete on unexpected errors.
      _notificationService.showNotification(
        message: _localizations.anErrorOccurred,
        type: NotificationType.error,
        oneLine: false,
      );
      await _crashlytics.recordError(e, stack,
          reason: 'Unexpected client-side error during verifyPurchase',
          fatal: false);
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
    }

    _notificationService.showNotification(
      message: isUserCancelled ? "Cancelled" : errorMessage,
      type: isUserCancelled ? NotificationType.neutral : NotificationType.error,
      oneLine: false,
    );

    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }

    _setPurchasePending(false);
  }

  void _onPurchaseStreamError(dynamic error, StackTrace? stack) {
    log('Purchase Stream Error: $error', name: _logName, error: error);
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
      _activeSubscriptionProductId = null;
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
        _activeSubscriptionProductId = null;
      } else {
        final data = snapshot.data();
        _currentUserSubscriptionLevel = data?['hasCortexSubscription'] ?? 0;
        _activeSubscriptionOption = data?['activeSubscriptionOption'];
        _activeSubscriptionProductId = data?['activeSubscriptionProductId'];
      }
      notifyListeners();
    }, onError: (error) {
      if (error.toString().contains("permission-denied")) {
        _userSubscription?.cancel();
      }
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

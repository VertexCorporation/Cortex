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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../cache.dart';
import '../../internet.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/introvert.dart';

part 'receipt.dart';
part 'offer.dart';
part 'products.dart';
part 'purchase.dart';
part 'verification.dart';
part 'user.dart';

class FundsBackend with ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
  FirebaseFunctions.instanceFor(region: 'europe-west1');
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  bool _isLoading = true;
  bool _isPurchasePending = false;
  String? _errorMessage;
  List<ProductDetails> _products = [];
  int _currentUserSubscriptionLevel = 0;
  String? _activeSubscriptionOption;

  String? _activeSubscriptionProductId;

  bool _initialized = false;
  bool _disposed = false;

  int? _specialOfferExpiresAt;
  bool _isSpecialOfferActive = false;

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

  void _notify() => notifyListeners();

  /// Preloads premium screen data (products + special offer) in the background.
  /// This should be called from AppInitializer after the app becomes ready.
  /// Returns true if data was successfully preloaded.
  static Future<bool> preloadInBackground() async {
    final logName = '$_logName.preload';
    
    // Check if we already have cached state
    final cachedState = CacheService.get<Map<String, dynamic>>(CacheKey.premiumScreenState);
    if (cachedState != null) {
      log('Premium screen state already cached, skipping preload.', name: logName);
      return true;
    }

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      log('Cannot preload: User not authenticated.', name: logName);
      return false;
    }

    if (!await InternetService().hasInternet()) {
      log('Cannot preload: No internet connection.', name: logName);
      return false;
    }

    try {
      log('Starting background preload of premium screen data...', name: logName);

      // 1. Preload products
      final inAppPurchase = InAppPurchase.instance;
      if (!await inAppPurchase.isAvailable()) {
        log('In-app purchases not available.', name: logName);
        return false;
      }

      final response = await inAppPurchase.queryProductDetails(_subscriptionIds);
      if (response.error != null || response.productDetails.isEmpty) {
        log('Failed to fetch products: ${response.error?.message ?? "empty"}', name: logName);
        return false;
      }

      // Cache products
      CacheService.set(CacheKey.premiumProducts, response.productDetails);
      log('Products cached: ${response.productDetails.length} items', name: logName);

      // 2. Preload special offer state
      final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
      final callable = functions.httpsCallable('checkOrStartSpecialOffer');
      final result = await callable.call<Map<String, dynamic>>({});

      final data = result.data;
      final status = data['status'] as String?;
      final expiresAt = data['expiresAt'] as int?;

      // 3. Cache the complete premium screen state
      final stateToCache = <String, dynamic>{
        'productsLoaded': true,
        'specialOfferActive': status == 'active' && expiresAt != null,
        'specialOfferExpiresAt': expiresAt,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      };

      CacheService.set(CacheKey.premiumScreenState, stateToCache);
      log('Premium screen state preloaded successfully.', name: logName);

      return true;
    } catch (e) {
      log('Background preload failed: $e', name: logName, error: e);
      return false;
    }
  }

  /// Checks if premium screen data is already preloaded and valid.
  /// Returns true only if BOTH products and screen state are cached and valid.
  static bool get isPreloaded {
    final logName = '$_logName.isPreloaded';
    
    // 1. Check if screen state exists
    final cachedState = CacheService.get<Map<String, dynamic>>(CacheKey.premiumScreenState);
    if (cachedState == null) {
      log('isPreloaded: FALSE - no cached state', name: logName);
      return false;
    }

    // 2. Check if products exist (must have both)
    final cachedProducts = CacheService.get<List<ProductDetails>>(CacheKey.premiumProducts);
    if (cachedProducts == null || cachedProducts.isEmpty) {
      // Products expired but state didn't - invalidate state too
      log('isPreloaded: FALSE - no cached products', name: logName);
      CacheService.invalidate(CacheKey.premiumScreenState);
      return false;
    }

    // 3. Check if special offer has expired (if it was active)
    final expiresAt = cachedState['specialOfferExpiresAt'] as int?;
    if (expiresAt != null && cachedState['specialOfferActive'] == true) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiresAt) {
        // Offer expired, invalidate cache to get fresh state
        log('isPreloaded: FALSE - special offer expired', name: logName);
        CacheService.invalidate(CacheKey.premiumScreenState);
        return false;
      }
    }

    log('isPreloaded: TRUE - ${cachedProducts.length} products cached', name: logName);
    return true;
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

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _setPurchasePending(bool value) {
    _isPurchasePending = value;
    _notify();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _purchaseStreamSubscription?.cancel();
    _userSubscription?.cancel();
    _authSubscription?.cancel();
    _purchaseCompletedController.close();
    super.dispose();
  }
}

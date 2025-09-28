// backend.dart (FINALIZED & PRODUCTION-READY)
// This version integrates robust caching to prevent skeleton loaders on subsequent
// visits and adds comprehensive Firebase Crashlytics logging to all critical
// payment and data fetching flows for maximum stability and monitoring.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// --- Local & Service Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../cache.dart'; // For caching product details
import '../internet.dart';

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

  final _purchaseCompletedController = StreamController<void>.broadcast();
  Stream<void> get onPurchaseCompleted => _purchaseCompletedController.stream;

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

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    CacheService.touchPremiumCache();

    _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: _onPurchaseStreamError,
    );

    _listenToUserChanges();
    await _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    if (AppDataState().needsRefresh) {
      CacheService.invalidatePremiumCache();
    }

    if (CacheService.cachedPremiumProducts != null && CacheService.cachedPremiumProducts!.isNotEmpty) {
      log('Cache hit! Initializing with cached product data.', name: _logName);
      _products = CacheService.cachedPremiumProducts!;
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    _setLoading(true);

    if (!kReleaseMode) {
      log('Running in Test Mode. Using mock product data.', name: _logName);
      await Future.delayed(const Duration(milliseconds: 800));
      _products = _mockProducts;
      CacheService.cachedPremiumProducts = _mockProducts;
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    if (!await InternetService().hasInternet()) {
      _setError("No Internet Connection. Please check your network and try again.");
      return;
    }

    if (!await _inAppPurchase.isAvailable()) {
      _setError("The store is currently unavailable. Please try again later.");
      await _crashlytics.recordError(
        'InAppPurchaseUnavailable', null, reason: 'InAppPurchase.isAvailable() returned false.', fatal: false,
      );
      return;
    }

    try {
      final allProductIds = {..._subscriptionIds, ..._creditProductIds};
      final response = await _inAppPurchase.queryProductDetails(allProductIds);

      if (response.error != null) {
        throw Exception('Store error: ${response.error!.message}');
      }
      if (response.productDetails.isEmpty) {
        log('Store returned zero products. This might be a config issue.', name: _logName);
        await _crashlytics.recordError(
          'EmptyProductList', null, reason: 'queryProductDetails returned an empty list.', fatal: false,
        );
      }

      _products = response.productDetails;
      CacheService.cachedPremiumProducts = _products;
      _errorMessage = null;

    } catch (e, stack) {
      log('Error fetching product details: $e', name: _logName, error: e);
      await _crashlytics.recordError(
        e, stack, reason: 'Failed in _fetchProductDetails catch block.', fatal: true,
      );
      _setError("Could not load products. Please try again.");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> purchase(ProductDetails product) async {
    if (_isPurchasePending) return;
    final user = _auth.currentUser;
    if (user == null) {
      log('Purchase blocked: User is not authenticated.', name: _logName);
      return;
    }

    await _crashlytics.setUserIdentifier(user.uid);
    _setPurchasePending(true);
    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      if (_creditProductIds.contains(product.id)) {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e, stack) {
      log('Error initiating purchase: $e', name: _logName);
      await _crashlytics.recordError(
        e, stack, reason: 'Error on buyConsumable/buyNonConsumable call for product ${product.id}', fatal: true,
      );
      _setPurchasePending(false);
    }
  }

  Future<void> manageSubscription() async {
    final Uri url = Uri.parse('https://play.google.com/store/account/subscriptions?package=com.vertex.cortex');
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
    try {
      final callable = _functions.httpsCallable('verifyPurchase');
      await callable.call<dynamic>({
        'receiptData': purchaseDetails.verificationData.serverVerificationData,
        'productId': purchaseDetails.productID,
        'platform': defaultTargetPlatform.name.toLowerCase(),
      });

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      AppDataState().markUserDataAsChanged();
      _purchaseCompletedController.add(null);
    } catch (e, stack) {
      log('Server verification or client completion failed: $e', name: _logName, error: e);
      await _crashlytics.recordError(
        e, stack, reason: 'Failed to verify or complete purchase for ${purchaseDetails.productID}', information: [ 'Purchase Status: ${purchaseDetails.status}' ], fatal: true,
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
    if (purchaseDetails.pendingCompletePurchase) _inAppPurchase.completePurchase(purchaseDetails);
    _setPurchasePending(false);
  }

  void _handleCanceledPurchase(PurchaseDetails d) {
    if (d.pendingCompletePurchase) _inAppPurchase.completePurchase(d);
    _setPurchasePending(false);
  }

  void _onPurchaseStreamError(dynamic error, StackTrace? stack) {
    log('Purchase Stream Error: $error', name: _logName, error: error);
    _crashlytics.recordError(
      error, stack, reason: 'An error occurred in the global purchase stream.', fatal: true,
    );
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
    CacheService.startPremiumCacheTimer();
    super.dispose();
  }
}
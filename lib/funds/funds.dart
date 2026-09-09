import 'package:cortex/design.dart';
// funds.dart

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:cortex/analytics/service.dart';
import 'package:cortex/app.dart';
import 'package:cortex/funds/skeleton.dart';
import 'package:cortex/funds/widgets/subscriptions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

// Local Imports
import '../../webview.dart';
import '../appbar.dart';
import '../login/upgrade.dart';
import '../navigation.dart';
import '../notifications/introvert.dart';
import '../server/user.dart';
import '../server/subscription.dart';
import '../theme.dart';
import 'backend.dart';

class FundsScreen extends StatelessWidget {
  /// Optionally pre-select a plan tier when opening the screen.
  /// 'plus' | 'pro' | 'ultra'. Defaults to 'pro'.
  final String? initialPlanType;

  const FundsScreen({super.key, this.initialPlanType});

  @override
  Widget build(BuildContext context) {
    return FundsScreenView(initialPlanType: initialPlanType);
  }
}

class FundsScreenView extends StatefulWidget {
  final String? initialPlanType;

  const FundsScreenView({super.key, this.initialPlanType});

  @override
  State<FundsScreenView> createState() => _FundsScreenViewState();
}

class _FundsScreenViewState extends State<FundsScreenView> {
  // --- UI State ---
  final List<String> _planTypes = ['plus', 'pro', 'ultra'];
  late final PageController _pageController;

  // Initial page 1 maps to "Pro" (0=Plus, 1=Pro, 2=Ultra)
  int _currentPage = 1;

  late final Map<String, String> _selectedBillingOptions = {
    'plus': 'monthly',
    'pro': 'monthly',
    'ultra': 'monthly',
  };

  late final List<ScrollController> _scrollControllers;

  bool _isContentLoaded = false;

  // Start with no offset - content visible immediately when data is ready
  Offset _contentOffset = Offset.zero;

  bool _hasAnyBenefitListAnimated = false;
  late final ConfettiController _confettiController;
  StreamSubscription? _purchaseCompletedSubscription;
  StreamSubscription? _testGrantCompletedSubscription;

  SubscriptionEntitlement _uiSubscription = SubscriptionEntitlement.none;

  /// Plan index of the currently active tier (0 free, 1 plus, 2 pro, 3 ultra).
  int get _uiActiveSubscriptionLevel =>
      _uiSubscription.effectiveTier.planIndex;

  /// Billing cadence of the active plan; the 'monthly' fallback mirrors the
  /// old inference for paid grants without a stored billing period.
  String? get _uiActiveSubscriptionOption => _uiSubscription.isPaid
      ? (_uiSubscription.billingPeriod?.value ?? 'monthly')
      : null;

  /// Whether the active entitlement is a lifetime grant.
  bool get _uiIsLifetime =>
      _uiSubscription.isActive &&
      _uiSubscription.mode == SubscriptionMode.lifetime;

  late FundsBackend _backend;
  bool _isEmulator = false;

  // --- Special Offer Countdown State ---
  Timer? _countdownTimer;
  final ValueNotifier<String> _countdownNotifier = ValueNotifier<String>('');
  bool _isSpecialOfferChecked = false;

  Future<void> _checkIfEmulator() async {
    final deviceInfo = DeviceInfoPlugin();
    bool isEm = false;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        isEm = !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        isEm = !iosInfo.isPhysicalDevice;
      }
    } catch (e) {
      log("Error checking device: $e");
    }
    if (mounted) setState(() => _isEmulator = isEm);
  }

  @override
  void initState() {
    super.initState();

    // If opened with an explicit plan, jump there; default remains Pro (index 1).
    final initialType = widget.initialPlanType;
    if (initialType != null) {
      final idx = _planTypes.indexOf(initialType);
      if (idx >= 0) _currentPage = idx;
    }

    // Access the provider synchronously — safe in initState with listen: false.
    _backend = Provider.of<FundsBackend>(context, listen: false);

    // If the backend already has products in memory or the cache is warm,
    // skip the skeleton immediately. This prevents shimmer flicker when
    // revisiting the screen after the first load.
    final hasData = _backend.allProducts.isNotEmpty ||
        !_backend.isLoading ||
        FundsBackend.isPreloaded;
    if (hasData) {
      _isSpecialOfferChecked = true;
      _isContentLoaded = true;
      log('[FundsScreen] Data ready (warm), skipping skeleton');
    } else {
      _isSpecialOfferChecked = false;
      _isContentLoaded = false;
      log('[FundsScreen] Data cold, will show skeleton');
    }

    _checkIfEmulator();
    _pageController = PageController(initialPage: _currentPage);
    _scrollControllers =
        List.generate(_planTypes.length, (_) => ScrollController());
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // Log screen view
    AnalyticsService().logFundsScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _backend = Provider.of<FundsBackend>(context, listen: false);

      final localizations = AppLocalizations.of(context)!;
      await _backend.updateLocalizationAndRefresh(localizations: localizations);
      if (!mounted) return;

      _backend.addListener(_onBackendUpdate);
      _initializeUiStateFromBackend();

      _purchaseCompletedSubscription =
          _backend.onPurchaseCompleted.listen((String purchasedProductId) {
        if (mounted) {
          _confettiController.play();
          _updateUiAfterPurchase(purchasedProductId);
          // Log successful purchase
          AnalyticsService().logPurchaseSuccess(
            productId: purchasedProductId,
            productType: 'subscription',
            value: 0.0, // Backend doesn't expose price here
            currency: 'USD',
          );
        }
      });

      // Simulated (test) purchases complete through the same UX path so the
      // whole lifecycle is exercised identically to a real store purchase.
      _testGrantCompletedSubscription =
          _backend.onTestGrantCompleted.listen((String productId) {
        if (mounted) {
          _confettiController.play();
          _updateUiAfterTestGrant(productId);
          AnalyticsService().logPurchaseSuccess(
            productId: productId,
            productType: 'subscription',
            value: 0.0, // Simulated purchase — no real charge.
            currency: 'USD',
          );
        }
      });

      // Check if data is already preloaded (from background)
      // This covers: cache exists OR backend already has products loaded
      if (FundsBackend.isPreloaded || _backend.allProducts.isNotEmpty) {
        log('[FundsScreen] Data ready - loading from cache/backend');
        // Load from cache if backend is empty but cache exists
        if (_backend.allProducts.isEmpty && FundsBackend.isPreloaded) {
          log('[FundsScreen] Loading from cache...');
          _backend.loadFromCache();
        }
        setState(() {
          _isSpecialOfferChecked = true;
          _isContentLoaded = true;
          _contentOffset = Offset.zero;
        });
        if (_backend.isSpecialOfferEligible && !_backend.isSpecialOfferActive) {
          _backend.checkOrStartSpecialOffer().whenComplete(() {
            if (mounted) {
              _startCountdownTimer();
            }
          });
        } else {
          _startCountdownTimer();
        }
      } else {
        // PERF: Background preload may have just started (parallel with heavy libs).
        // Poll briefly (max 2.5s, 250ms intervals) before falling back to server fetch.
        // This avoids showing the skeleton when data arrives shortly after.
        log('[FundsScreen] Waiting briefly for background preload to complete...');
        _waitForPreloadOrFetch(localizations);
      }
    });
  }

  /// Polls for background preload completion with a short timeout.
  /// If data arrives within [maxWaitMs], shows it instantly (no skeleton).
  /// Falls back to a direct server fetch if the timeout expires.
  void _waitForPreloadOrFetch(
    AppLocalizations localizations, {
    int elapsedMs = 0,
    int intervalMs = 200,
    int maxWaitMs = 2000,
  }) {
    if (!mounted) return;

    if (FundsBackend.isPreloaded || _backend.allProducts.isNotEmpty) {
      // Preload finished while we were waiting — use cached data immediately
      log('[FundsScreen] Preload arrived after ${elapsedMs}ms, skipping skeleton');
      if (_backend.allProducts.isEmpty && FundsBackend.isPreloaded) {
        _backend.loadFromCache();
      }
      if (mounted) {
        setState(() {
          _isSpecialOfferChecked = true;
          _isContentLoaded = true;
          _contentOffset = Offset.zero;
        });
      }
      if (_backend.isSpecialOfferEligible && !_backend.isSpecialOfferActive) {
        _backend.checkOrStartSpecialOffer().whenComplete(() {
          if (mounted) _startCountdownTimer();
        });
      } else {
        _startCountdownTimer();
      }
      return;
    }

    if (elapsedMs >= maxWaitMs) {
      // Timeout — fall back to standard server fetch (will show skeleton)
      log('[FundsScreen] Preload timeout after ${elapsedMs}ms, fetching from server...');
      _backend.checkOrStartSpecialOffer().whenComplete(() {
        if (mounted) {
          log('[FundsScreen] Server fetch complete');
          setState(() {
            _isSpecialOfferChecked = true;
          });
          _startCountdownTimer();
        }
      });
      return;
    }

    // Still waiting — check again after interval
    Future.delayed(Duration(milliseconds: intervalMs), () {
      _waitForPreloadOrFetch(
        localizations,
        elapsedMs: elapsedMs + intervalMs,
        intervalMs: intervalMs,
        maxWaitMs: maxWaitMs,
      );
    });
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _updateCountdown(); // Initial update
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (!mounted) return;

    if (_uiActiveSubscriptionLevel > 0) {
      if (_countdownNotifier.value.isNotEmpty) {
        _countdownNotifier.value = '';
      }
      return;
    }

    final expiresAt = _backend.specialOfferExpiresAt;

    // If logic says offer is inactive (null expiry or inactive flag)
    if (expiresAt == null || !_backend.isSpecialOfferActive) {
      if (_countdownNotifier.value.isNotEmpty) {
        _countdownNotifier.value = '';
      }
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = expiresAt - now;

    // --- CRITICAL CHANGE: Handle expiration cleanly ---
    if (remaining <= 0) {
      // Time is up!
      if (_countdownNotifier.value.isNotEmpty) {
        // Clear text immediately to trigger badge removal animation
        // and revert benefits colors.
        _countdownNotifier.value = '';
      }
      _countdownTimer?.cancel();
      return;
    }

    final duration = Duration(milliseconds: remaining);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    _countdownNotifier.value = '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownNotifier.dispose();
    _backend.removeListener(_onBackendUpdate);
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _purchaseCompletedSubscription?.cancel();
    _testGrantCompletedSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeUiStateFromBackend() {
    if (!mounted) return;
    final backend = Provider.of<FundsBackend>(context, listen: false);
    setState(() {
      _uiSubscription = backend.subscription;
      final userLevel = _uiActiveSubscriptionLevel;
      final activeOption = _uiActiveSubscriptionOption;

      if (userLevel > 0 &&
          activeOption != null &&
          userLevel - 1 < _planTypes.length) {
        final activePlanType = _planTypes[userLevel - 1];
        _selectedBillingOptions[activePlanType] = activeOption;
      }
    });
  }

  void _onBackendUpdate() {
    if (!mounted) return;
    final backend = Provider.of<FundsBackend>(context, listen: false);
    final newSubscription = backend.subscription;
    if (newSubscription != _uiSubscription) {
      setState(() {
        _uiSubscription = newSubscription;
        final userLevel = _uiActiveSubscriptionLevel;
        final activeOption = _uiActiveSubscriptionOption;
        if (userLevel > 0 &&
            activeOption != null &&
            userLevel - 1 < _planTypes.length) {
          final activePlanType = _planTypes[userLevel - 1];
          _selectedBillingOptions[activePlanType] = activeOption;
        }
      });
    }
  }

  void _updateUiAfterPurchase(String purchasedProductId) {
    String? planType;
    String? billingOption;
    int? planLevel;

    switch (purchasedProductId) {
      case FundsBackend.monthlySubscriptionPlus:
        planType = 'plus';
        billingOption = 'monthly';
        planLevel = 1;
        break;
      case FundsBackend.annualSubscriptionPlus:
        planType = 'plus';
        billingOption = 'annual';
        planLevel = 1;
        break;
      case FundsBackend.monthlySubscriptionPro:
        planType = 'pro';
        billingOption = 'monthly';
        planLevel = 2;
        break;
      case FundsBackend.annualSubscriptionPro:
        planType = 'pro';
        billingOption = 'annual';
        planLevel = 2;
        break;
      case FundsBackend.monthlySubscriptionUltra:
        planType = 'ultra';
        billingOption = 'monthly';
        planLevel = 3;
        break;
      case FundsBackend.annualSubscriptionUltra:
        planType = 'ultra';
        billingOption = 'annual';
        planLevel = 3;
        break;
    }

    if (planType != null && billingOption != null && planLevel != null) {
      setState(() {
        _selectedBillingOptions[planType!] = billingOption!;
        // Optimistic entitlement so the UI reflects the purchase immediately;
        // the backend's authoritative write replaces it on the next update.
        _uiSubscription = SubscriptionEntitlement(
          tier: SubscriptionTier.values[planLevel!],
          mode: SubscriptionMode.renewable,
          status: SubscriptionStatus.active,
          expiresAt: DateTime.now().add(const Duration(days: 370)),
          billingPeriod: billingOption == 'annual'
              ? SubscriptionBillingPeriod.annual
              : SubscriptionBillingPeriod.monthly,
        );
      });
    }
  }

  /// Optimistic entitlement after a simulated purchase: mirrors what the
  /// server wrote (short-lived promotional `internal_test` grant), so the
  /// UI is accurate even before the Firestore listener catches up.
  void _updateUiAfterTestGrant(String productId) {
    final SubscriptionTier tier;
    switch (productId) {
      case FundsBackend.monthlySubscriptionPlus:
      case FundsBackend.annualSubscriptionPlus:
        tier = SubscriptionTier.plus;
        break;
      case FundsBackend.monthlySubscriptionPro:
      case FundsBackend.annualSubscriptionPro:
        tier = SubscriptionTier.pro;
        break;
      case FundsBackend.monthlySubscriptionUltra:
      case FundsBackend.annualSubscriptionUltra:
        tier = SubscriptionTier.ultra;
        break;
      default:
        return;
    }

    setState(() {
      _uiSubscription = SubscriptionEntitlement(
        tier: tier,
        mode: SubscriptionMode.promotional,
        status: SubscriptionStatus.active,
        expiresAt: DateTime.now().add(
            const Duration(minutes: FundsBackend.testGrantDurationMinutes)),
        source: SubscriptionSource.internalTest,
        testGrant: true,
      );
    });
  }

  /// Maps a (plan, billing) selection to the store product ID.
  String? _resolveSubscriptionProductId(String planType, String billingOption) {
    final bool isAnnual = billingOption == 'annual';
    if (planType == 'plus') {
      return isAnnual
          ? FundsBackend.annualSubscriptionPlus
          : FundsBackend.monthlySubscriptionPlus;
    }
    if (planType == 'pro') {
      return isAnnual
          ? FundsBackend.annualSubscriptionPro
          : FundsBackend.monthlySubscriptionPro;
    }
    if (planType == 'ultra') {
      return isAnnual
          ? FundsBackend.annualSubscriptionUltra
          : FundsBackend.monthlySubscriptionUltra;
    }
    return null;
  }

  void _onPrimaryButtonPressed() {
    final backend = Provider.of<FundsBackend>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final isAnonymous = context.read<UserProvider>().isAnonymous;

    if (isAnonymous) {
      navigateToScreen(const UpgradeAccountScreen(),
          direction: const Offset(0.0, 1.0));
      FocusScope.of(context).unfocus();
      return;
    }
    if (backend.isPurchasePending) return;

    // Debug test accounts replace the store checkout with the simulated one
    // (server-verified via `isVertex`; see FundsTestGrants). Products may be
    // empty on emulators — the simulated flow does not need store details.
    if (backend.isTestPurchaseAvailable) {
      _onTestModePrimaryButtonPressed();
      return;
    }

    if (backend.allProducts.isEmpty) {
      _showCustomNotification(
          message: localizations.productNotFound,
          isSuccess: NotificationType.error);
      return;
    }

    final planType = _planTypes[_currentPage];
    final int planLevel = _currentPage + 1;
    final billingOption = _selectedBillingOptions[planType]!;
    final int activePlanLevel = _uiActiveSubscriptionLevel;

    if (activePlanLevel > planLevel ||
        (activePlanLevel == planLevel &&
            (_uiIsLifetime ||
                billingOption == _uiActiveSubscriptionOption))) {
      backend.manageSubscription();
      return;
    }

    final String? productIdToPurchase =
        _resolveSubscriptionProductId(planType, billingOption);

    if (productIdToPurchase != null) {
      try {
        final productDetails =
            backend.allProducts.firstWhere((p) => p.id == productIdToPurchase);
        // Log purchase initiated
        AnalyticsService().logPurchaseInitiated(
          productId: productIdToPurchase,
          productType: 'subscription',
        );
        backend.purchase(productDetails);
      } catch (e) {
        log('Attempted to purchase a product not found: $productIdToPurchase',
            name: 'FundsScreen', error: e);
        // Log purchase failure
        AnalyticsService().logPurchaseFailure(
          productId: productIdToPurchase,
          productType: 'subscription',
          error: 'product_not_found',
        );
        _showCustomNotification(
            message: localizations.productNotFound,
            isSuccess: NotificationType.error);
      }
    }
  }

  void _showTermsAndConditions() async {
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    const String termsUrl = "https://vertexishere.com/cortex-terms-of-service";
    const String policyUrl = "https://vertexishere.com/cortex-privacy-policy";
    await showAppWebViewModal(context, localizations.termsOfService, termsUrl);
    if (!mounted) return;
    await showAppWebViewModal(context, localizations.privacyPolicy, policyUrl);
  }

  /// Primary button behavior while the simulated (test) flow is active:
  /// an active test entitlement is "managed" by revoking it — the store's
  /// management page is meaningless for test grants.
  void _onTestModePrimaryButtonPressed() {
    final backend = Provider.of<FundsBackend>(context, listen: false);

    if (_uiSubscription.isTestEntitlement && _uiSubscription.isActive) {
      HapticFeedback.lightImpact();
      backend.revokeTestSubscription();
      return;
    }

    final planType = _planTypes[_currentPage];
    final billingOption = _selectedBillingOptions[planType]!;
    _showTestPurchaseSheet(planType, billingOption);
  }

  /// Opens the simulated checkout sheet: plan/period/price plus an explicit
  /// "no real charge" disclosure. Confirming calls the Fulcrum test grant.
  Future<void> _showTestPurchaseSheet(
      String planType, String billingOption) async {
    final backend = Provider.of<FundsBackend>(context, listen: false);
    final productId = _resolveSubscriptionProductId(planType, billingOption);
    if (productId == null) return;

    // Price is displayed when store products are available (physical debug
    // devices); on emulators the sheet falls back to plan/period only.
    ProductDetails? product;
    for (final p in backend.allProducts) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return TestPurchaseSheet(
          planType: planType,
          billingOption: billingOption,
          price: product?.price,
          onConfirmed: () => backend.purchaseTestSubscription(productId),
        );
      },
    );
  }

  void _showCustomNotification(
      {required String message, required NotificationType isSuccess}) {
    if (mounted) {
      Provider.of<IntrovertNotificationService>(context, listen: false)
          .showNotification(
              message: message,
              type: isSuccess,
              oneLine: false,
              fontSize: 0.025,
              bottomOffset: 0.01);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FundsBackend>(
      builder: (context, backend, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              extendBodyBehindAppBar: true,
              appBar: CortexAppBar(
                leadingMode: CortexLeadingMode.back,
                title: ValueListenableBuilder<String>(
                  valueListenable: _countdownNotifier,
                  builder: (context, countdownText, _) {
                    return _buildFixedDiscountBadge(context,
                        MediaQuery.of(context).size.width, countdownText);
                  },
                ),
              ),
              body: Stack(
                children: [
                  if (!backend.hasError) _buildMainContent(context, backend),
                  // AnimatedSwitcher fully removes the skeleton from the tree
                  // after fade-out, stopping the internal Shimmer animation and
                  // preventing render-object lifecycle conflicts.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _isContentLoaded
                        ? const SizedBox.shrink(
                            key: ValueKey('skeleton_gone'))
                        : const FundsSkeletonLoader(
                            key: ValueKey('skeleton')),
                  ),
                  if (backend.hasError)
                    _buildErrorScreen(context, backend.errorMessage!),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 25,
                gravity: 0.2,
                emissionFrequency: 0.03,
                maxBlastForce: 20,
                minBlastForce: 8,
                particleDrag: 0.05,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    return Container(
      color: AppColors.background,
      child: SafeArea(
        key: const ValueKey('error_screen'),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.01),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      height: CortexDesign.icon,
                      'assets/icons/warning.svg',
                      width: CortexDesign.icon,
                      colorFilter: ColorFilter.mode(
                          AppColors.septenaryColor, BlendMode.srcIn),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.05),
                      child: Text(
                        message,
                        style: TextStyle(
                            color: AppColors.primaryColor.inverted,
                            fontSize: screenSize.width * 0.045,
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.1),
                        foregroundColor: AppColors.primaryColor.inverted,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.1,
                            vertical: screenSize.height * 0.018),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        final backend =
                            Provider.of<FundsBackend>(context, listen: false);
                        final notificationService =
                            Provider.of<IntrovertNotificationService>(context,
                                listen: false);
                        await backend.initialize(
                            notificationService: notificationService,
                            localizations: localizations);
                      },
                      child: Text(localizations.retry,
                          style: TextStyle(
                              fontSize: screenSize.width * 0.04,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, FundsBackend backend) {
    final localizations = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final double topPadding = MediaQuery.paddingOf(context).top;

    if (!backend.isLoading && _isSpecialOfferChecked && !_isContentLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isContentLoaded = true;
            _contentOffset = Offset.zero;
          });
        }
      });
    }

    // Determine visual active state locally to ensure instant UI update when timer hits 0
    // even if backend state lags slightly.
    final bool isOfferVisuallyActive =
        !backend.subscription.isPaid &&
            backend.isSpecialOfferActive &&
            _countdownNotifier.value.isNotEmpty;

    return AnimatedSlide(
      key: const ValueKey('main_content'),
      offset: _contentOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _isContentLoaded ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            SizedBox(height: topPadding + kToolbarHeight),
            SizedBox(height: screenHeight * 0.015),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  for (int i = 0; i < _planTypes.length; i++)
                    SubscriptionContentWidget(
                      planType: _planTypes[i],
                      availableProducts: backend.subscriptionProducts,
                      selectedBillingOption:
                          _selectedBillingOptions[_planTypes[i]]!,
                      subscription: _uiSubscription,
                      onBillingOptionChanged: (newOption) {
                        setState(() {
                          _selectedBillingOptions[_planTypes[i]] = newOption;
                        });
                      },
                      scrollController: _scrollControllers[i],
                      animateBenefits: !_hasAnyBenefitListAnimated,
                      onBenefitsAnimated: () {
                        if (!_hasAnyBenefitListAnimated) {
                          setState(() {
                            _hasAnyBenefitListAnimated = true;
                          });
                        }
                      },
                      // Pass visual state so children revert colors when timer dies
                      isSpecialOfferActive: isOfferVisuallyActive,
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.06,
                  screenHeight * 0.01,
                  screenWidth * 0.06,
                  screenHeight * 0.02 + MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPageIndicator(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    transformAlignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scaleByDouble(
                        backend.isPurchasePending ? 0.98 : 1.0,
                        backend.isPurchasePending ? 0.98 : 1.0,
                        backend.isPurchasePending ? 0.98 : 1.0,
                        1.0,
                      ),
                    child: ElevatedButton(
                      onPressed: (backend.isPurchasePending ||
                              (_isEmulator && !backend.isTestPurchaseAvailable))
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _onPrimaryButtonPressed();
                            },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        backgroundColor: AppColors.primaryColor.inverted,
                        disabledBackgroundColor: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.6),
                        disabledForegroundColor:
                            AppColors.primaryColor.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        minimumSize: Size(double.infinity, screenHeight * 0.06),
                        splashFactory: backend.isPurchasePending
                            ? NoSplash.splashFactory
                            : InkSplash.splashFactory,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (backend.isPurchasePending)
                            SizedBox(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            )
                          else ...[
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              child: _buildButtonText(
                                  context, backend, screenWidth),
                            ),
                            if (backend.isTestPurchaseAvailable) ...[
                              SizedBox(height: screenHeight * 0.002),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    localizations.testModeInfo,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (_isEmulator) ...[
                              SizedBox(height: screenHeight * 0.002),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    localizations.emulatorModeWarning,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ]
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.002),
                  TextButton(
                    onPressed: backend.isPurchasePending
                        ? null
                        : () async {
                            HapticFeedback.lightImpact();
                            await backend.restorePurchases();
                          },
                    child: Text(
                      localizations.restorePurchases,
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.002),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showTermsAndConditions();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                          .termsOfServiceAndPrivacyPolicyWarning,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.tertiaryColor,
                          fontSize: screenWidth * 0.027),
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

  Widget _buildFixedDiscountBadge(
      BuildContext context, double screenWidth, String countdownText) {
    final backend = Provider.of<FundsBackend>(context, listen: false);
    // Rely on countdown text being present to show special offer badge
    final bool showSpecialOffer = !backend.subscription.isPaid &&
        backend.isSpecialOfferActive &&
        countdownText.isNotEmpty;

    bool showFreeTrialBadge = false;
    if (!showSpecialOffer &&
        !_isEmulator &&
        !backend.subscription.isPaid) {
      try {
        final proMonthly = backend.subscriptionProducts
            .firstWhere((p) => p.id == FundsBackend.monthlySubscriptionPro);
        if (getTrialInfo(proMonthly) != null) {
          showFreeTrialBadge = true;
        } else {
          final proAnnual = backend.subscriptionProducts
              .firstWhere((p) => p.id == FundsBackend.annualSubscriptionPro);
          if (getTrialInfo(proAnnual) != null) {
            showFreeTrialBadge = true;
          }
        }
      } catch (_) {}
    }

    final bool showBadge = showSpecialOffer || showFreeTrialBadge;

    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);
    final badgeHeight = 36.0 * scale;
    final fontSize = 13.0 * scale;
    final paddingH = 14.0 * scale;
    final gap = 6.0 * scale;
    final borderRadius = 36.0 * scale;
    final borderWidth = 0.8 * scale;

    final baseColor = AppColors.premium.withValues(alpha: 0.15);
    final contentColor = AppColors.premium;
    final borderColor = baseColor.withValues(alpha: 0.8);
    final localizations = AppLocalizations.of(context)!;
    final String badgeText = showSpecialOffer
        ? (backend.isWelcomeOffer
            ? localizations.welcomeOfferBadge(countdownText)
            : localizations.exclusiveOfferBadge(countdownText))
        : localizations.freePlan('Pro');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutBack,
      // More dramatic exit when time runs out
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: showBadge
          ? ClipRRect(
              key: const ValueKey('welcomeOfferBadge'),
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                height: badgeHeight,
                padding: EdgeInsets.symmetric(horizontal: paddingH),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/sparkle.svg',
                      colorFilter:
                          ColorFilter.mode(contentColor, BlendMode.srcIn),
                      width: CortexDesign.icon,
                      height: CortexDesign.icon,
                    ),
                    SizedBox(width: gap),
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                        child: Text(
                          badgeText,
                          // Key changes every second for fade effect
                          key: ValueKey(showSpecialOffer
                              ? countdownText
                              : 'freeTrialBadge'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            color: contentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }

  void _onPageChanged(int newPageIndex) {
    if (_currentPage != newPageIndex) {
      setState(() {
        _currentPage = newPageIndex;
      });
    }
  }

  Widget _buildPageIndicator(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_planTypes.length, (index) {
        final bool isSelected = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          width: isSelected ? screenWidth * 0.06 : screenWidth * 0.022,
          height: screenWidth * 0.022,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.022),
            color: isSelected
                ? AppColors.primaryColor.inverted
                : AppColors.primaryColor.inverted.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }

  Widget _buildButtonText(
      BuildContext context, FundsBackend backend, double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    final textStyle = TextStyle(
        fontSize: screenWidth * 0.042,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor);

    final planIndex = _currentPage;
    final currentPlanLevel = _currentPage + 1;
    final currentPlanType = _planTypes[planIndex];
    final selectedBillingOption = _selectedBillingOptions[currentPlanType]!;

    // Simulated flow: an active test entitlement on the exact matching plan
    // card is cancelled immediately. Lower-tier cards must NOT show the test
    // cancel CTA — they fall through to normal purchase / manage text.
    if (backend.isTestPurchaseAvailable &&
        _uiSubscription.isTestEntitlement &&
        _uiSubscription.isActive &&
        _uiActiveSubscriptionLevel == currentPlanLevel) {
      return Text(localizations.testSubscriptionManage,
          key: ValueKey('test-cancel-$currentPlanType'), style: textStyle);
    }

    if (_uiActiveSubscriptionLevel > currentPlanLevel) {
      return Text(localizations.manageSubscription,
          key: ValueKey('downgrade-$currentPlanType'), style: textStyle);
    }

    final isTierUpgrade = _uiActiveSubscriptionLevel != 0 &&
        _uiActiveSubscriptionLevel < currentPlanLevel;
    final isBillingUpgrade = _uiActiveSubscriptionLevel == currentPlanLevel &&
        selectedBillingOption == 'annual' &&
        _uiActiveSubscriptionOption == 'monthly';

    if (isTierUpgrade || isBillingUpgrade) {
      return Text(localizations.upgradeSubscription,
          key: ValueKey('upgrade-$currentPlanType-$selectedBillingOption'),
          style: textStyle);
    }
    if (_uiActiveSubscriptionLevel == currentPlanLevel &&
        selectedBillingOption == _uiActiveSubscriptionOption) {
      return Text(localizations.manageSubscription,
          key: ValueKey('cancel-$currentPlanType'), style: textStyle);
    }

    final planDisplayName = currentPlanType.capitalize();
    final billingName = selectedBillingOption == 'annual'
        ? localizations.annual
        : localizations.monthly;
    final fullPlanName = "$planDisplayName $billingName";
    return Text(
      localizations.purchasePlan(fullPlanName),
      key: ValueKey('purchase-$currentPlanType-$selectedBillingOption'),
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }
}

/// Simulated checkout sheet shown in place of the store payment sheet while
/// the debug-only test purchase flow is active. Its single job is informed
/// consent: show what would be "bought", that no real charge happens and how
/// long the test access lasts.
class TestPurchaseSheet extends StatefulWidget {
  const TestPurchaseSheet({
    super.key,
    required this.planType,
    required this.billingOption,
    required this.onConfirmed,
    this.price,
  });

  /// 'plus' | 'pro' | 'ultra'.
  final String planType;

  /// 'monthly' | 'annual'.
  final String billingOption;

  /// Formatted store price when available; null on emulators without store
  /// access.
  final String? price;

  /// Runs the simulated purchase (calls the Fulcrum test grant).
  final Future<bool> Function() onConfirmed;

  @override
  State<TestPurchaseSheet> createState() => _TestPurchaseSheetState();
}

class _TestPurchaseSheetState extends State<TestPurchaseSheet> {
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    if (_isSubmitting) return;
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    await widget.onConfirmed();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final planDisplayName = widget.planType.capitalize();
    final billingName = widget.billingOption == 'annual'
        ? localizations.annual
        : localizations.monthly;
    final fullPlanName = "$planDisplayName $billingName";
    final durationText = localizations
        .testDurationMinutes(FundsBackend.testGrantDurationMinutes);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: EdgeInsets.fromLTRB(
          screenWidth * 0.06,
          screenHeight * 0.015,
          screenWidth * 0.06,
          screenHeight * 0.02 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.012,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildTitleRow(context, localizations, screenWidth),
          SizedBox(height: screenHeight * 0.025),
          _buildPlanRow(context, localizations, screenWidth, fullPlanName),
          SizedBox(height: screenHeight * 0.02),
          Text(
            localizations.testPurchaseNotice(fullPlanName, durationText),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.034,
              height: 1.4,
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          _buildConfirmButton(context, localizations, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.01),
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(
      BuildContext context, AppLocalizations localizations, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            localizations.testPurchaseTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor.inverted,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenWidth * 0.006),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            localizations.testPurchaseBadge,
            style: TextStyle(
              fontSize: screenWidth * 0.022,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanRow(BuildContext context, AppLocalizations localizations,
      double screenWidth, String fullPlanName) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.035),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.inverted.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              fullPlanName,
              style: TextStyle(
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor.inverted,
              ),
            ),
          ),
          if (widget.price != null) ...[
            SizedBox(width: screenWidth * 0.03),
            Text(
              widget.price!,
              style: TextStyle(
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor.inverted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context,
      AppLocalizations localizations, double screenWidth, double screenHeight) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _confirm,
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        backgroundColor: AppColors.primaryColor.inverted,
        disabledBackgroundColor:
            AppColors.primaryColor.inverted.withValues(alpha: 0.6),
        disabledForegroundColor:
            AppColors.primaryColor.withValues(alpha: 0.6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
        minimumSize: Size(double.infinity, screenHeight * 0.055),
      ),
      child: _isSubmitting
          ? SizedBox(
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            )
          : Text(
              localizations.testPurchaseConfirm,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}


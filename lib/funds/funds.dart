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
import 'package:provider/provider.dart';

// Local Imports
import '../../webview.dart';
import '../appbar.dart';
import '../login/upgrade.dart';
import '../navigation.dart';
import '../notifications/introvert.dart';
import '../server/user.dart';
import '../theme.dart';
import 'backend.dart';

class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FundsScreenView();
  }
}

class FundsScreenView extends StatefulWidget {
  const FundsScreenView({super.key});

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

  int _uiActiveSubscriptionLevel = 0;
  String? _uiActiveSubscriptionOption;
  late FundsBackend _backend;
  bool _isEmulator = false;

  // --- Special Offer Countdown State ---
  Timer? _countdownTimer;
  String _countdownText = '';
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
    
    // Check if data is already preloaded BEFORE first frame
    // If preloaded: skip skeleton entirely
    // If not preloaded: show skeleton until data loads
    final isPreloaded = FundsBackend.isPreloaded;
    log('[FundsScreen] initState - isPreloaded: $isPreloaded');
    
    if (isPreloaded) {
      _isSpecialOfferChecked = true;
      _isContentLoaded = true;
      log('[FundsScreen] Data preloaded, skipping skeleton');
    } else {
      // Will show skeleton until data loads
      _isSpecialOfferChecked = false;
      _isContentLoaded = false;
      log('[FundsScreen] Data NOT preloaded, will show skeleton');
    }
    
    _checkIfEmulator();
    _pageController = PageController(initialPage: _currentPage);
    _scrollControllers =
        List.generate(_planTypes.length, (_) => ScrollController());
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // Log screen view
    AnalyticsService().logFundsScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backend = Provider.of<FundsBackend>(context, listen: false);

      final localizations = AppLocalizations.of(context)!;
      _backend.updateLocalizationAndRefresh(localizations: localizations);

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
        _startCountdownTimer();
      } else {
        // Fallback: load normally with skeleton
        // This handles: first app launch with no cache
        log('[FundsScreen] No preloaded data, fetching from server...');
        _backend.checkOrStartSpecialOffer().whenComplete(() {
          if (mounted) {
            log('[FundsScreen] Server fetch complete');
            setState(() {
              _isSpecialOfferChecked = true;
            });
            _startCountdownTimer();
          }
        });
      }
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
      if (_countdownText.isNotEmpty) {
        setState(() => _countdownText = '');
      }
      return;
    }

    final expiresAt = _backend.specialOfferExpiresAt;

    // If logic says offer is inactive (null expiry or inactive flag)
    if (expiresAt == null || !_backend.isSpecialOfferActive) {
      if (_countdownText.isNotEmpty) {
        setState(() => _countdownText = '');
      }
      return;
    }

    final now = DateTime
        .now()
        .millisecondsSinceEpoch;
    final remaining = expiresAt - now;

    // --- CRITICAL CHANGE: Handle expiration cleanly ---
    if (remaining <= 0) {
      // Time is up!
      if (_countdownText.isNotEmpty) {
        // Clear text immediately to trigger badge removal animation
        // and revert benefits colors.
        setState(() => _countdownText = '');
      }
      _countdownTimer?.cancel();
      return;
    }

    final duration = Duration(milliseconds: remaining);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    setState(() => _countdownText = '$hours:$minutes:$seconds');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _backend.removeListener(_onBackendUpdate);
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _purchaseCompletedSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeUiStateFromBackend() {
    if (!mounted) return;
    final backend = Provider.of<FundsBackend>(context, listen: false);
    setState(() {
      _uiActiveSubscriptionLevel = backend.currentUserSubscriptionLevel;
      _uiActiveSubscriptionOption = backend.activeSubscriptionOption;
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
    final newLevel = backend.currentUserSubscriptionLevel;
    final newOption = backend.activeSubscriptionOption;
    final bool hasDataChanged = newLevel != _uiActiveSubscriptionLevel ||
        newOption != _uiActiveSubscriptionOption;
    if (hasDataChanged) {
      setState(() {
        _uiActiveSubscriptionLevel = newLevel;
        _uiActiveSubscriptionOption = newOption;
        if (newLevel > 0 &&
            newOption != null &&
            newLevel - 1 < _planTypes.length) {
          final activePlanType = _planTypes[newLevel - 1];
          _selectedBillingOptions[activePlanType] = newOption;
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
        _uiActiveSubscriptionLevel = planLevel!;
        _uiActiveSubscriptionOption = billingOption;
      });
    }
  }

  void _onPrimaryButtonPressed() {
    final backend = Provider.of<FundsBackend>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final isAnonymous = context
        .read<UserProvider>()
        .isAnonymous;

    if (isAnonymous) {
      navigateToScreen(const UpgradeAccountScreen(),
          direction: const Offset(0.0, 1.0));
      FocusScope.of(context).unfocus();
      return;
    }
    if (backend.isPurchasePending) return;
    if (backend.allProducts.isEmpty) {
      _showCustomNotification(
          message: localizations.productNotFound,
          isSuccess: NotificationType.error);
      return;
    }

    final planType = _planTypes[_currentPage];
    final int planLevel = _currentPage + 1;
    final billingOption = _selectedBillingOptions[planType]!;

    String? productIdToPurchase;

    if (_uiActiveSubscriptionLevel > planLevel ||
        (_uiActiveSubscriptionLevel == planLevel &&
            billingOption == _uiActiveSubscriptionOption)) {
      backend.manageSubscription();
      return;
    }

    final isAnnual = billingOption == 'annual';
    if (planType == 'plus') {
      productIdToPurchase = isAnnual
          ? FundsBackend.annualSubscriptionPlus
          : FundsBackend.monthlySubscriptionPlus;
    }
    if (planType == 'pro') {
      productIdToPurchase = isAnnual
          ? FundsBackend.annualSubscriptionPro
          : FundsBackend.monthlySubscriptionPro;
    }
    if (planType == 'ultra') {
      productIdToPurchase = isAnnual
          ? FundsBackend.annualSubscriptionUltra
          : FundsBackend.monthlySubscriptionUltra;
    }

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
                title: _buildFixedDiscountBadge(
                    context, MediaQuery
                    .of(context)
                    .size
                    .width),
              ),
              body: Stack(
                children: [
                  if (!backend.hasError) _buildMainContent(context, backend),
                  IgnorePointer(
                    ignoring: _isContentLoaded,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _isContentLoaded ? 0.0 : 1.0,
                      curve: Curves.easeOutCubic,
                      child:
                      const FundsSkeletonLoader(key: ValueKey('skeleton')),
                    ),
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
    final screenSize = MediaQuery
        .of(context)
        .size;
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
                      'assets/icons/warning.svg',
                      width: screenSize.width * 0.25,
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
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final backend =
                        Provider.of<FundsBackend>(context, listen: false);
                        final notificationService =
                        Provider.of<IntrovertNotificationService>(context,
                            listen: false);
                        backend.initialize(
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final double topPadding = MediaQuery
        .of(context)
        .padding
        .top;

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
        backend.currentUserSubscriptionLevel == 0 &&
            backend.isSpecialOfferActive &&
            _countdownText.isNotEmpty;

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
                      activeSubscriptionLevel: _uiActiveSubscriptionLevel,
                      activeSubscriptionOption: _uiActiveSubscriptionOption,
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
                  screenHeight * 0.02 + MediaQuery
                      .of(context)
                      .padding
                      .bottom),
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
                        backend.isPurchasePending ? 0.98 : 1.0,
                      ),
                    child: ElevatedButton(
                      onPressed: (backend.isPurchasePending || _isEmulator)
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
                          else
                            ...[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _buildButtonText(
                                    context, backend, screenWidth),
                              ),
                              if (_isEmulator) ...[
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

  Widget _buildFixedDiscountBadge(BuildContext context, double screenWidth) {
    final backend = Provider.of<FundsBackend>(context, listen: false);
    // Rely on countdown text being present to show badge
    final bool showSpecialOffer =
        backend.currentUserSubscriptionLevel == 0 &&
            backend.isSpecialOfferActive &&
            _countdownText.isNotEmpty;

    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);
    final badgeHeight = 36.0 * scale;
    final iconSize = 14.0 * scale;
    final fontSize = 13.0 * scale;
    final paddingH = 14.0 * scale;
    final gap = 6.0 * scale;
    final borderRadius = 36.0 * scale;
    final borderWidth = 0.8 * scale;

    final baseColor = AppColors.premium.withValues(alpha: 0.15);
    final contentColor = AppColors.premium;
    final borderColor = baseColor.withValues(alpha: 0.8);
    final localizations = AppLocalizations.of(context)!;
    final String badgeText = backend.isWelcomeOffer
        ? localizations.welcomeOfferBadge(_countdownText)
        : localizations.exclusiveOfferBadge(_countdownText);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutBack,
      // More dramatic exit when time runs out
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: showSpecialOffer
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
                width: iconSize,
                height: iconSize,
              ),
              SizedBox(width: gap),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                  child: Text(
                    badgeText,
                    // Key changes every second for fade effect
                    key: ValueKey(_countdownText),
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
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

  Widget _buildButtonText(BuildContext context, FundsBackend backend,
      double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    final textStyle = TextStyle(
        fontSize: screenWidth * 0.042,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor);

    final planIndex = _currentPage;
    final currentPlanLevel = _currentPage + 1;
    final currentPlanType = _planTypes[planIndex];
    final selectedBillingOption = _selectedBillingOptions[currentPlanType]!;

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
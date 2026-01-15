// funds.dart (FINAL & UNIFIED BRAIN ARCHITECTURE)
// This version establishes _FundsScreenViewState as the single source of truth for the UI,
// eliminating all race conditions and ensuring instant, consistent UI updates.
// Refactored: Removed all Credit functionality.

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:cortex/app.dart';
import 'package:cortex/funds/widgets/subscriptions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// Local Imports
import '../../banner.dart';
import '../../webview.dart';
import '../login/upgrade.dart';
import '../navigation.dart';
import '../notifications/introvert.dart';
import '../server/user.dart';
import '../settings/skeleton.dart';
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
    'plus': 'monthly', 'pro': 'monthly', 'ultra': 'monthly',
  };

  // Reduced to 3 for the 3 subscription plans
  late final List<ScrollController> _scrollControllers;

  bool _isContentLoaded = false;
  Offset _contentOffset = const Offset(0.0, 0.03);
  bool _hasAnyBenefitListAnimated = false;
  late final ConfettiController _confettiController;
  StreamSubscription? _purchaseCompletedSubscription;

  // These local variables hold the active subscription state for the entire UI.
  // They are updated INSTANTLY by proactive updates and LATER confirmed by backend syncs.
  // This ensures the checkmark and the selection border are ALWAYS consistent.
  int _uiActiveSubscriptionLevel = 0;
  String? _uiActiveSubscriptionOption;
  late FundsBackend _backend;
  bool _isEmulator = false;

  // Checks emulator
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
    _checkIfEmulator();
    // Initialize page controller to start at 'Pro' (Index 1)
    _pageController = PageController(initialPage: _currentPage);
    _scrollControllers =
        List.generate(_planTypes.length, (_) => ScrollController());
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

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
            }
          });
    });
  }

  @override
  void dispose() {
    _backend.removeListener(_onBackendUpdate);
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _purchaseCompletedSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  /// Runs ONCE on init. It populates our local "UI Brain" variables from the backend.
  void _initializeUiStateFromBackend() {
    if (!mounted) return;
    final backend = Provider.of<FundsBackend>(context, listen: false);
    setState(() {
      _uiActiveSubscriptionLevel = backend.currentUserSubscriptionLevel;
      _uiActiveSubscriptionOption = backend.activeSubscriptionOption;
      final userLevel = _uiActiveSubscriptionLevel;
      final activeOption = _uiActiveSubscriptionOption;

      // Map user level to plan type. Level 1=Plus(0), 2=Pro(1), 3=Ultra(2)
      if (userLevel > 0 && activeOption != null &&
          userLevel - 1 < _planTypes.length) {
        final activePlanType = _planTypes[userLevel - 1];
        _selectedBillingOptions[activePlanType] = activeOption;
      }
    });
  }

  /// Listens for REAL data changes from Firestore and syncs our "UI Brain".
  /// This IGNORES temporary state changes like `isPurchasePending`.
  void _onBackendUpdate() {
    if (!mounted) return;
    final backend = Provider.of<FundsBackend>(context, listen: false);
    final newLevel = backend.currentUserSubscriptionLevel;
    final newOption = backend.activeSubscriptionOption;
    final bool hasDataChanged = newLevel != _uiActiveSubscriptionLevel ||
        newOption != _uiActiveSubscriptionOption;
    if (hasDataChanged) {
      log(
          "Real backend data change detected. Syncing UI Brain. New state: L$newLevel '$newOption'.",
          name: "FundsScreenView");
      setState(() {
        _uiActiveSubscriptionLevel = newLevel;
        _uiActiveSubscriptionOption = newOption;
        if (newLevel > 0 && newOption != null &&
            newLevel - 1 < _planTypes.length) {
          final activePlanType = _planTypes[newLevel - 1];
          _selectedBillingOptions[activePlanType] = newOption;
        }
      });
    }
  }

  /// This function now updates BOTH the selection border AND the checkmark state INSTANTLY.
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
      log(
          "Proactive UI Update: Purchase of '$purchasedProductId' detected. Updating UI Brain.",
          name: "FundsScreenView");
      setState(() {
        // 1. Update the selection map (for the blue border)
        _selectedBillingOptions[planType!] = billingOption!;
        // 2. Update the local active subscription state (for the checkmark ✅)
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
      navigateToScreen(
          const UpgradeAccountScreen(), direction: const Offset(0.0, 1.0));
      FocusScope.of(context).unfocus();
      return;
    }
    if (backend.isPurchasePending) return;
    if (backend.allProducts.isEmpty) {
      log('Purchase blocked: Product details are not loaded yet.',
          name: 'FundsScreen');
      _showCustomNotification(message: localizations.productNotFound,
          isSuccess: NotificationType.error);
      return;
    }

    // New logic: _currentPage maps directly to indices [0, 1, 2] corresponding to [plus, pro, ultra]
    // Plan Levels are 1-based: Plus=1, Pro=2, Ultra=3.
    final planType = _planTypes[_currentPage];
    final int planLevel = _currentPage + 1;
    final billingOption = _selectedBillingOptions[planType]!;

    String? productIdToPurchase;

    // Use the local UI state for button logic to be consistent.
    if (_uiActiveSubscriptionLevel > planLevel ||
        (_uiActiveSubscriptionLevel == planLevel &&
            billingOption == _uiActiveSubscriptionOption)) {
      backend.manageSubscription();
      return;
    }

    final isAnnual = billingOption == 'annual';
    if (planType == 'plus') {
      productIdToPurchase =
      isAnnual ? FundsBackend.annualSubscriptionPlus : FundsBackend
          .monthlySubscriptionPlus;
    }
    if (planType == 'pro') {
      productIdToPurchase =
      isAnnual ? FundsBackend.annualSubscriptionPro : FundsBackend
          .monthlySubscriptionPro;
    }
    if (planType == 'ultra') {
      productIdToPurchase =
      isAnnual ? FundsBackend.annualSubscriptionUltra : FundsBackend
          .monthlySubscriptionUltra;
    }

    if (productIdToPurchase != null) {
      try {
        final productDetails = backend.allProducts.firstWhere((p) =>
        p.id == productIdToPurchase);
        backend.purchase(productDetails);
      } catch (e) {
        log('Attempted to purchase a product not found: $productIdToPurchase',
            name: 'FundsScreen', error: e);
        _showCustomNotification(message: localizations.productNotFound,
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
      Provider
          .of<IntrovertNotificationService>(context, listen: false)
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
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: backend.hasError
                    ? _buildErrorScreen(context, backend.errorMessage!)
                    : backend.isLoading
                    ? const SkeletonLoader(key: ValueKey('skeleton'))
                    : _buildMainContent(context, backend),
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
    return SafeArea(
      key: const ValueKey('error_screen'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05,
            vertical: screenSize.height * 0.01),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.primaryColor.inverted,
                    size: screenSize.width * 0.07),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
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
                      style: TextStyle(color: AppColors.primaryColor.inverted,
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
                      final backend = Provider.of<FundsBackend>(
                          context, listen: false);
                      final notificationService = Provider.of<
                          IntrovertNotificationService>(context, listen: false);
                      backend.initialize(
                          notificationService: notificationService,
                          localizations: localizations);
                    },
                    child: Text(localizations.retry, style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
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

    if (!backend.isLoading && !_isContentLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isContentLoaded = true;
            _contentOffset = Offset.zero;
          });
        }
      });
    }

    return AnimatedSlide(
      key: const ValueKey('main_content'),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                        icon: Icon(
                            Icons.close, color: AppColors.primaryColor.inverted,
                            size: screenWidth * 0.07),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        for (int i = 0; i < _planTypes.length; i++)
                          SubscriptionContentWidget(
                            planType: _planTypes[i],
                            availableProducts: backend.subscriptionProducts,
                            selectedBillingOption: _selectedBillingOptions[_planTypes[i]]!,
                            activeSubscriptionLevel: _uiActiveSubscriptionLevel,
                            activeSubscriptionOption: _uiActiveSubscriptionOption,
                            onBillingOptionChanged: (newOption) {
                              setState(() {
                                _selectedBillingOptions[_planTypes[i]] =
                                    newOption;
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
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.06, screenHeight * 0.01,
                        screenWidth * 0.06, screenHeight * 0.02),
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
                              backend.isPurchasePending ? 0.95 : 1.0,
                              backend.isPurchasePending ? 0.95 : 1.0,
                              backend.isPurchasePending ? 0.95 : 1.0,
                              backend.isPurchasePending ? 0.95 : 1.0,
                            ),
                          child: ElevatedButton(
                            onPressed: (backend.isPurchasePending ||
                                _isEmulator) ? null : _onPrimaryButtonPressed,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              backgroundColor: AppColors.primaryColor.inverted,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.018),
                              minimumSize: Size(
                                  double.infinity, screenHeight * 0.06),
                              splashFactory: backend.isPurchasePending
                                  ? NoSplash.splashFactory
                                  : InkSplash.splashFactory,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // --- RESTORE BUTTON ---
                        TextButton(
                          onPressed: backend.isPurchasePending
                              ? null
                              : () async {
                            await backend.restorePurchases();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            localizations.restorePurchases,
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              decorationColor: AppColors.primaryColor.inverted
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        TextButton(
                          onPressed: _showTermsAndConditions,
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
                                fontSize: screenWidth * 0.026
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const FloatingInfoBanner(
              key: ValueKey('discount_banner'),
              bannerType: BannerType.discount,
            ),
          ],
        ),
      ),
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
            color: isSelected ? AppColors.primaryColor.inverted : AppColors
                .primaryColor.inverted.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }

  Widget _buildButtonText(BuildContext context, FundsBackend backend,
      double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    final textStyle = TextStyle(fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor);

    // Current page is 0, 1, or 2 (Plus, Pro, Ultra).
    // Plan Levels are 1, 2, 3.
    final planIndex = _currentPage;
    final currentPlanLevel = _currentPage + 1;
    final currentPlanType = _planTypes[planIndex];
    final selectedBillingOption = _selectedBillingOptions[currentPlanType]!;

    // Use the local UI state for button text logic as well for consistency.
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
// funds.dart (FINAL & UNIFIED BRAIN ARCHITECTURE)
// This version establishes _FundsScreenViewState as the single source of truth for the UI,
// eliminating all race conditions and ensuring instant, consistent UI updates.

import 'dart:async';
import 'dart:developer';
import 'package:confetti/confetti.dart';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// Local Imports
import '../../banner.dart';
import '../../webview.dart';
import '../notifications/introvert.dart';
import '../theme.dart';
import 'backend.dart';
import 'credits/credits.dart';
import 'subscriptions/subscriptions.dart';
import 'subscriptions/skeleton.dart';

class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (context) => FundsBackend()
        ..initialize(
          notificationService: Provider.of<IntrovertNotificationService>(context, listen: false),
          localizations: localizations,
        ),
      child: const FundsScreenView(),
    );
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
  int _currentPage = 1;
  CreditPackage? _selectedCreditPackage;
  late final Map<String, String> _selectedBillingOptions = {
    'plus': 'monthly', 'pro': 'monthly', 'ultra': 'monthly',
  };
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _scrollControllers = List.generate(4, (_) => ScrollController());
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backend = Provider.of<FundsBackend>(context, listen: false);
      _backend.addListener(_onBackendUpdate);
      _initializeUiStateFromBackend();
      _purchaseCompletedSubscription = _backend.onPurchaseCompleted.listen((String purchasedProductId) {
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
      if (userLevel > 0 && activeOption != null && userLevel - 1 < _planTypes.length) {
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
    final bool hasDataChanged = newLevel != _uiActiveSubscriptionLevel || newOption != _uiActiveSubscriptionOption;
    if (hasDataChanged) {
      log("Real backend data change detected. Syncing UI Brain. New state: L$newLevel '$newOption'.", name: "FundsScreenView");
      setState(() {
        _uiActiveSubscriptionLevel = newLevel;
        _uiActiveSubscriptionOption = newOption;
        if (newLevel > 0 && newOption != null && newLevel - 1 < _planTypes.length) {
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
        planType = 'plus'; billingOption = 'monthly'; planLevel = 1; break;
      case FundsBackend.annualSubscriptionPlus:
        planType = 'plus'; billingOption = 'annual'; planLevel = 1; break;
      case FundsBackend.monthlySubscriptionPro:
        planType = 'pro'; billingOption = 'monthly'; planLevel = 2; break;
      case FundsBackend.annualSubscriptionPro:
        planType = 'pro'; billingOption = 'annual'; planLevel = 2; break;
      case FundsBackend.monthlySubscriptionUltra:
        planType = 'ultra'; billingOption = 'monthly'; planLevel = 3; break;
      case FundsBackend.annualSubscriptionUltra:
        planType = 'ultra'; billingOption = 'annual'; planLevel = 3; break;
    }

    if (planType != null && billingOption != null && planLevel != null) {
      log("Proactive UI Update: Purchase of '$purchasedProductId' detected. Updating UI Brain.", name: "FundsScreenView");
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
    if (backend.isPurchasePending) return;
    if (backend.allProducts.isEmpty) {
      log('Purchase blocked: Product details are not loaded yet.', name: 'FundsScreen');
      _showCustomNotification(message: localizations.productNotFound, isSuccess: NotificationType.error);
      return;
    }
    String? productIdToPurchase;
    int planLevel = _currentPage;
    if (_currentPage == 0) {
      productIdToPurchase = _selectedCreditPackage?.productId;
    } else {
      final planType = _planTypes[_currentPage - 1];
      final billingOption = _selectedBillingOptions[planType]!;
      // Use the local UI state for button logic to be consistent.
      if (_uiActiveSubscriptionLevel > planLevel ||
          (_uiActiveSubscriptionLevel == planLevel && billingOption == _uiActiveSubscriptionOption)) {
        backend.manageSubscription();
        return;
      }
      final isAnnual = billingOption == 'annual';
      if (planType == 'plus') productIdToPurchase = isAnnual ? FundsBackend.annualSubscriptionPlus : FundsBackend.monthlySubscriptionPlus;
      if (planType == 'pro') productIdToPurchase = isAnnual ? FundsBackend.annualSubscriptionPro : FundsBackend.monthlySubscriptionPro;
      if (planType == 'ultra') productIdToPurchase = isAnnual ? FundsBackend.annualSubscriptionUltra : FundsBackend.monthlySubscriptionUltra;
    }
    if (productIdToPurchase != null) {
      try {
        final productDetails = backend.allProducts.firstWhere((p) => p.id == productIdToPurchase);
        backend.purchase(productDetails);
      } catch (e) {
        log('Attempted to purchase a product not found: $productIdToPurchase', name: 'FundsScreen', error: e);
        _showCustomNotification(message: localizations.productNotFound, isSuccess: NotificationType.error);
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

  void _showCustomNotification({required String message, required NotificationType isSuccess}) {
    if (mounted) {
      Provider.of<IntrovertNotificationService>(context, listen: false).showNotification(
          message: message, type: isSuccess, oneLine: false, fontSize: 0.025, bottomOffset: 0.01);
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
                  Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
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
    return SafeArea(
      key: const ValueKey('error_screen'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: screenSize.height * 0.01),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.primaryColor.inverted, size: screenSize.width * 0.07),
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
                    colorFilter: ColorFilter.mode(AppColors.septenaryColor, BlendMode.srcIn),
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                    child: Text(
                      message,
                      style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenSize.width * 0.045, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primaryColor.inverted,
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1, vertical: screenSize.height * 0.018),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () {
                      final backend = Provider.of<FundsBackend>(context, listen: false);
                      final notificationService = Provider.of<IntrovertNotificationService>(context, listen: false);
                      backend.initialize(notificationService: notificationService, localizations: localizations);
                    },
                    child: Text(localizations.retry, style: TextStyle(fontSize: screenSize.width * 0.04, fontWeight: FontWeight.bold)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (!backend.isLoading && !_isContentLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _isContentLoaded = true; _contentOffset = Offset.zero; });
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
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        CreditContentWidget(
                          availableProducts: backend.creditProducts,
                          onCreditPackageSelected: (package) => setState(() => _selectedCreditPackage = package),
                          scrollController: _scrollControllers[0],
                        ),
                        for (int i = 0; i < _planTypes.length; i++)
                          SubscriptionContentWidget(
                            planType: _planTypes[i],
                            availableProducts: backend.subscriptionProducts,
                            selectedBillingOption: _selectedBillingOptions[_planTypes[i]]!,
                            activeSubscriptionLevel: _uiActiveSubscriptionLevel,
                            activeSubscriptionOption: _uiActiveSubscriptionOption,
                            onBillingOptionChanged: (newOption) {
                              setState(() { _selectedBillingOptions[_planTypes[i]] = newOption; });
                            },
                            scrollController: _scrollControllers[i + 1],
                            animateBenefits: !_hasAnyBenefitListAnimated,
                            onBenefitsAnimated: () {
                              if (!_hasAnyBenefitListAnimated) {
                                setState(() { _hasAnyBenefitListAnimated = true; });
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenHeight * 0.01, screenWidth * 0.06, screenHeight * 0.02),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPageIndicator(screenWidth),
                        SizedBox(height: screenHeight * 0.02),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          transformAlignment: Alignment.center,
                          transform: Matrix4.identity()..scaleByDouble(
                            backend.isPurchasePending ? 0.98 : 1.0,
                            backend.isPurchasePending ? 0.98 : 1.0,
                            backend.isPurchasePending ? 0.98 : 1.0,
                            backend.isPurchasePending ? 0.98 : 1.0,
                          ),
                          child: Opacity(
                            opacity: backend.isPurchasePending ? 0.7 : 1.0,
                            child: ElevatedButton(
                              onPressed: backend.isPurchasePending ? null : _onPrimaryButtonPressed,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                                backgroundColor: AppColors.primaryColor.inverted,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                                minimumSize: Size(double.infinity, screenHeight * 0.06),
                                splashFactory: backend.isPurchasePending ? NoSplash.splashFactory : InkSplash.splashFactory,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _buildButtonText(context, backend, screenWidth),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextButton(
                          onPressed: _showTermsAndConditions,
                          child: Text(
                            AppLocalizations.of(context)!.termsOfServiceAndPrivacyPolicyWarning,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.tertiaryColor, fontSize: screenWidth * 0.028),
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
      children: List.generate(4, (index) {
        final bool isSelected = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          width: isSelected ? screenWidth * 0.06 : screenWidth * 0.022,
          height: screenWidth * 0.022,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.022),
            color: isSelected ? AppColors.primaryColor.inverted : AppColors.primaryColor.inverted.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }

  Widget _buildButtonText(BuildContext context, FundsBackend backend, double screenWidth) {
    final localizations = AppLocalizations.of(context)!;
    final textStyle = TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: AppColors.primaryColor);

    if (_currentPage == 0) {
      return Text(
        _selectedCreditPackage != null ? localizations.creditPackage(_selectedCreditPackage!.amount) : localizations.buyCredit,
        key: ValueKey('credits-${_selectedCreditPackage?.amount ?? 'default'}'),
        style: textStyle,
      );
    }

    final planIndex = _currentPage - 1;
    final currentPlanLevel = _currentPage;
    final currentPlanType = _planTypes[planIndex];
    final selectedBillingOption = _selectedBillingOptions[currentPlanType]!;

    // Use the local UI state for button text logic as well for consistency.
    if (_uiActiveSubscriptionLevel > currentPlanLevel) {
      return Text(localizations.manageSubscription, key: ValueKey('downgrade-$currentPlanType'), style: textStyle);
    }
    final isTierUpgrade = _uiActiveSubscriptionLevel != 0 && _uiActiveSubscriptionLevel < currentPlanLevel;
    final isBillingUpgrade = _uiActiveSubscriptionLevel == currentPlanLevel && selectedBillingOption == 'annual' && _uiActiveSubscriptionOption == 'monthly';

    if (isTierUpgrade || isBillingUpgrade) {
      return Text(localizations.upgradeSubscription, key: ValueKey('upgrade-$currentPlanType-$selectedBillingOption'), style: textStyle);
    }
    if (_uiActiveSubscriptionLevel == currentPlanLevel && selectedBillingOption == _uiActiveSubscriptionOption) {
      return Text(localizations.manageSubscription, key: ValueKey('cancel-$currentPlanType'), style: textStyle);
    }

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
}
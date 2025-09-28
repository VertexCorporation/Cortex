// funds.dart (FINALIZED & PRODUCTION-READY)
// The UI layer is now fully responsive, with all dimensions, font sizes, and
// paddings calculated dynamically based on the screen size. It correctly uses
// the custom SkeletonLoader and manages the one-time benefit animation state.

import 'dart:async';
import 'dart:developer';
import 'package:confetti/confetti.dart';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// Local Imports
import '../../banner.dart';
import '../../notifications.dart';
import '../../webview.dart';
import '../theme.dart';
import 'backend.dart';
import 'credits/credits.dart';
import 'subscriptions/subscriptions.dart';
import 'subscriptions/skeleton.dart';

class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FundsBackend()..initialize(),
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
  final Map<String, String> _selectedBillingOptions = {
    'plus': 'monthly', 'pro': 'monthly', 'ultra': 'monthly',
  };

  late final List<ScrollController> _scrollControllers;
  bool _showScrollFog = false;
  bool _isContentLoaded = false;
  Offset _contentOffset = const Offset(0.0, 0.03);
  bool _hasAnyBenefitListAnimated = false;

  late final ConfettiController _confettiController;
  StreamSubscription? _purchaseCompletedSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _scrollControllers = List.generate(4, (_) => ScrollController());
    _scrollControllers[_currentPage].addListener(_updateFogVisibility);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUiStateWithBackend();
      _updateFogVisibility();
      final backend = Provider.of<FundsBackend>(context, listen: false);
      _purchaseCompletedSubscription = backend.onPurchaseCompleted.listen((_) {
        if (mounted) {
          _confettiController.play();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _purchaseCompletedSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _syncUiStateWithBackend() {
    if (!mounted) return;
    final backend = Provider.of<FundsBackend>(context, listen: false);
    final userLevel = backend.currentUserSubscriptionLevel;
    final activeOption = backend.activeSubscriptionOption;
    if (userLevel > 0 && activeOption != null) {
      if (userLevel - 1 < _planTypes.length) {
        final activePlanType = _planTypes[userLevel - 1];
        if (_selectedBillingOptions[activePlanType] != activeOption) {
          setState(() => _selectedBillingOptions[activePlanType] = activeOption);
        }
      }
    }
  }

  void _onPageChanged(int newPageIndex) {
    if (_currentPage != newPageIndex) {
      _scrollControllers[_currentPage].removeListener(_updateFogVisibility);
      _scrollControllers[newPageIndex].addListener(_updateFogVisibility);
      setState(() { _currentPage = newPageIndex; });
      _syncUiStateWithBackend();
      _updateFogVisibility();
    }
  }

  void _updateFogVisibility() {
    if (!mounted) return;
    final controller = _scrollControllers[_currentPage];
    if (!controller.hasClients) {
      if (_showScrollFog) setState(() => _showScrollFog = false);
      return;
    }
    final bool shouldShow = controller.position.maxScrollExtent > 0 &&
        controller.position.pixels < controller.position.maxScrollExtent - 10;
    if (shouldShow != _showScrollFog) {
      setState(() => _showScrollFog = shouldShow);
    }
  }

  void _onPrimaryButtonPressed() {
    final backend = Provider.of<FundsBackend>(context, listen: false);
    if (backend.isPurchasePending) return;
    final localizations = AppLocalizations.of(context)!;
    String? productIdToPurchase;
    int planLevel = _currentPage;
    if (_currentPage == 0) {
      productIdToPurchase = _selectedCreditPackage?.productId;
    } else {
      final planType = _planTypes[_currentPage - 1];
      final billingOption = _selectedBillingOptions[planType]!;
      if (backend.currentUserSubscriptionLevel > planLevel ||
          (backend.currentUserSubscriptionLevel == planLevel && billingOption == backend.activeSubscriptionOption)) {
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
        log('Attempted to purchase a product not found in backend list: $productIdToPurchase', name: 'FundsScreen', error: e);
        _showCustomNotification(message: localizations.productNotFound, isSuccess: false);
      }
    }
  }

  void _showTermsAndConditions() async {
    final localizations = AppLocalizations.of(context)!;
    const String termsUrl = "https://vertexishere.com/cortex-terms-of-service";
    const String policyUrl = "https://vertexishere.com/cortex-privacy-policy";
    if (!context.mounted) return;
    await showAppWebViewModal(context, localizations.termsOfService, termsUrl);
    if (!context.mounted) return;
    await showAppWebViewModal(context, localizations.privacyPolicy, policyUrl);
  }

  void _showCustomNotification({required String message, bool isSuccess = true}) {
    if (mounted) {
      Provider.of<NotificationService>(context, listen: false).showNotification(
          message: message, isSuccess: isSuccess, oneLine: false, fontSize: 0.025, bottomOffset: 0.01);
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
              alignment: Alignment.topRight,
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
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: screenSize.width * 0.045,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.inverted.withOpacity(0.1),
                      foregroundColor: AppColors.primaryColor.inverted,
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1, vertical: screenSize.height * 0.018),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () => Provider.of<FundsBackend>(context, listen: false).initialize(),
                    child: Text(
                      localizations.retry,
                      style: TextStyle(fontSize: screenSize.width * 0.04, fontWeight: FontWeight.bold),
                    ),
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
                    child: Stack(
                      children: [
                        PageView(
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
                                activeSubscriptionLevel: backend.currentUserSubscriptionLevel,
                                activeSubscriptionOption: backend.activeSubscriptionOption,
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
                                    colors: [ AppColors.background.withOpacity(0.0), AppColors.background ],
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
                        _buildPageIndicator(screenWidth),
                        SizedBox(height: screenHeight * 0.02),
                        // This AnimatedContainer handles the press/pending effect (scaling and opacity)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()..scale(backend.isPurchasePending ? 0.98 : 1.0),
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
                              // The AnimatedSwitcher is restored to handle text transitions,
                              // but it no longer shows a CircularProgressIndicator.
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
            color: isSelected ? AppColors.primaryColor.inverted : AppColors.primaryColor.inverted.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildButtonText(BuildContext context, FundsBackend backend, double screenWidth) {
    // This method is now back to its original, robust form.
    // The ValueKey is crucial for AnimatedSwitcher to detect text changes.
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

    if (backend.currentUserSubscriptionLevel > currentPlanLevel) {
      return Text(localizations.manageSubscription, key: ValueKey('downgrade-$currentPlanType'), style: textStyle);
    }
    final isTierUpgrade = backend.currentUserSubscriptionLevel != 0 && backend.currentUserSubscriptionLevel < currentPlanLevel;
    final isBillingUpgrade = backend.currentUserSubscriptionLevel == currentPlanLevel && selectedBillingOption == 'annual' && backend.activeSubscriptionOption == 'monthly';

    if (isTierUpgrade || isBillingUpgrade) {
      return Text(localizations.upgradeSubscription, key: ValueKey('upgrade-$currentPlanType-$selectedBillingOption'), style: textStyle);
    }
    if (backend.currentUserSubscriptionLevel == currentPlanLevel && selectedBillingOption == backend.activeSubscriptionOption) {
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
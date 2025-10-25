// subscriptions.dart (FINALIZED & PRODUCTION-READY)
// This version fixes the 'horizontalPadding' scope bug, ensuring all dynamic
// calculations are correct within their respective methods.

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'dart:async';
import '../../theme.dart';
import '../backend.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class SubscriptionContentWidget extends StatefulWidget {
  final String planType;
  final List<ProductDetails> availableProducts;
  final String selectedBillingOption;
  final int activeSubscriptionLevel;
  final String? activeSubscriptionOption;
  final ValueChanged<String> onBillingOptionChanged;
  final ScrollController? scrollController;
  final bool animateBenefits;
  final VoidCallback onBenefitsAnimated;

  const SubscriptionContentWidget({
    super.key,
    required this.planType,
    required this.availableProducts,
    required this.selectedBillingOption,
    required this.activeSubscriptionLevel,
    this.activeSubscriptionOption,
    required this.onBillingOptionChanged,
    this.scrollController,
    required this.animateBenefits,
    required this.onBenefitsAnimated,
  });

  @override
  State<SubscriptionContentWidget> createState() =>
      _SubscriptionContentWidgetState();
}

class _SubscriptionContentWidgetState extends State<SubscriptionContentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(CurvedAnimation(parent: _shineController, curve: Curves.linear));

    _shineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _shineController.forward(from: 0.0);
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shineController.forward();
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  String _getPriceForId(String id) {
    try {
      return widget.availableProducts.firstWhere((p) => p.id == id).price;
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final double horizontalPadding = screenWidth * 0.06;
    final double verticalSpacingSmall = screenHeight * 0.01;
    final double verticalSpacingMedium = screenHeight * 0.02;
    final double verticalSpacingLarge = screenHeight * 0.03;
    final double logoHeight = screenWidth * 0.25;

    String purchaseKey, descriptionKey, logoPath, monthlyId, annualId;
    int currentPlanLevel;

    switch (widget.planType) {
      case 'pro':
        purchaseKey = localizations.purchasePro; descriptionKey = localizations.proDescription;
        logoPath = AppColors.currentTheme == 'dark' ? 'assets/icons/subscriptions/whitepro.png' : 'assets/icons/subscriptions/prologo.png';
        monthlyId = FundsBackend.monthlySubscriptionPro; annualId = FundsBackend.annualSubscriptionPro; currentPlanLevel = 2;
        break;
      case 'ultra':
        purchaseKey = localizations.purchaseUltra; descriptionKey = localizations.ultraDescription;
        logoPath = AppColors.currentTheme == 'dark' ? 'assets/icons/subscriptions/whiteultra.png' : 'assets/icons/subscriptions/ultralogo.png';
        monthlyId = FundsBackend.monthlySubscriptionUltra; annualId = FundsBackend.annualSubscriptionUltra; currentPlanLevel = 3;
        break;
      default: // 'plus'
        purchaseKey = localizations.purchasePlus; descriptionKey = localizations.plusDescription;
        logoPath = AppColors.currentTheme == 'dark' ? 'assets/icons/subscriptions/whiteplus.png' : 'assets/icons/subscriptions/pluslogo.png';
        monthlyId = FundsBackend.monthlySubscriptionPlus; annualId = FundsBackend.annualSubscriptionPlus; currentPlanLevel = 1;
    }

    ProductDetails? annualProductDetails;
    try {
      annualProductDetails = widget.availableProducts.firstWhere((p) => p.id == annualId);
    } catch (e) {
      annualProductDetails = null;
    }

    final String formattedMonthlyEquivalentPrice;
    if (annualProductDetails != null && annualProductDetails.rawPrice > 0) {
      final currencySymbol = annualProductDetails.price.replaceAll(RegExp(r'[\d.,\s]'), '');
      final monthlyPrice = (annualProductDetails.rawPrice / 12).toStringAsFixed(2);
      formattedMonthlyEquivalentPrice = "$currencySymbol$monthlyPrice";
    } else {
      formattedMonthlyEquivalentPrice = '...';
    }

    final bool isActivePlan = widget.activeSubscriptionLevel == currentPlanLevel;

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            Text(purchaseKey, style: TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
            SizedBox(height: verticalSpacingSmall),
            Text(descriptionKey, textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.035, color: AppColors.tertiaryColor)),
            SizedBox(height: verticalSpacingMedium),
            Image.asset(logoPath, height: logoHeight),
            SizedBox(height: verticalSpacingMedium),
            _buildSubscriptionOption(
              context: context, localizations: localizations, option: 'annual',
              title: "${localizations.annual} ${widget.planType.capitalize()}",
              description: localizations.annualPlanDescription(formattedMonthlyEquivalentPrice),
              isBestValue: true, isSelected: widget.selectedBillingOption == 'annual',
              isSubscribedPlan: isActivePlan, activeSubscriptionOption: widget.activeSubscriptionOption ?? '',
            ),
            SizedBox(height: verticalSpacingSmall),
            _buildSubscriptionOption(
              context: context, localizations: localizations, option: 'monthly',
              title: "${localizations.monthly} ${widget.planType.capitalize()}",
              description: localizations.monthlyPlanDescription(_getPriceForId(monthlyId)),
              isBestValue: false, isSelected: widget.selectedBillingOption == 'monthly',
              isSubscribedPlan: isActivePlan, activeSubscriptionOption: widget.activeSubscriptionOption ?? '',
            ),
            SizedBox(height: verticalSpacingLarge),
            _buildBenefitsList(context, localizations, widget.planType),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption({ required BuildContext context, required AppLocalizations localizations, required String option, required String title, required String description, required bool isBestValue, required bool isSelected, required bool isSubscribedPlan, required String activeSubscriptionOption, }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final bool isEffectivelyDisabled = isSubscribedPlan && activeSubscriptionOption == 'annual' && option == 'monthly';
    final bool showCheckmark = isSubscribedPlan && activeSubscriptionOption == option;

    Widget buildBadge({required Color backgroundColor, required Color textColor, required String text}) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005, horizontal: screenWidth * 0.02),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(6)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: screenWidth * 0.025, fontWeight: FontWeight.bold),
            maxLines: 1, softWrap: false,
          ),
        ),
      );
    }

    final content = AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.background, borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor.inverted : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted)),
                  SizedBox(height: screenHeight * 0.005),
                  // THE FIX: Wrap the description in a FittedBox to prevent it from
                  // wrapping to a new line when the card's border gets thicker.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      description,
                      style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.tertiaryColor),
                      maxLines: 1, // Ensure it stays on a single line
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
              child: showCheckmark
                  ? Container( key: const ValueKey('checkmark'), alignment: Alignment.center, width: screenWidth * 0.17, child: SvgPicture.asset('assets/icons/checkmark.svg', color: AppColors.primaryColor.inverted, width: screenWidth * 0.09, height: screenWidth * 0.09),)
                  : SizedBox(
                key: const ValueKey('badges'),
                width: screenWidth * 0.17,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Visibility( visible: isBestValue, maintainSize: true, maintainAnimation: true, maintainState: true, child: buildBadge(backgroundColor: Colors.green, textColor: Colors.white, text: localizations.bestValue), ),
                    buildBadge(backgroundColor: AppColors.primaryColor.inverted, textColor: AppColors.primaryColor, text: localizations.discountOffer(80)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isEffectivelyDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isEffectivelyDisabled ? null : () => widget.onBillingOptionChanged(option),
        child: Stack(
          children: [
            content,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, child) => Transform.translate( offset: Offset(MediaQuery.of(context).size.width * _shineAnimation.value, 0), child: child, ),
                  child: Container(
                    width: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
                        colors: [ AppColors.secondaryColor.withValues(alpha: 0.0), AppColors.secondaryColor.withValues(alpha: 0.5), AppColors.secondaryColor.withValues(alpha: 0.0), ],
                        stops: const [0.4, 0.5, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context, AppLocalizations localizations, String planType) {
    final screenWidth = MediaQuery.of(context).size.width;

    // THE FIX: Define horizontalPadding here so it's in the correct scope.
    final double horizontalPadding = screenWidth * 0.06;

    String benefit7Text = localizations.benefit7(planType == 'plus' ? '500' : planType == 'pro' ? '1000' : '2000');
    List<String> benefits = [];
    if (planType == 'plus') {
      benefits = [ localizations.benefit1, localizations.benefit3, localizations.benefit5, localizations.benefit4, benefit7Text, localizations.benefit9, localizations.benefitPremiumModels, ];
    } else if (planType == 'pro') {
      benefits = [localizations.oldBenefits, localizations.benefit5, localizations.benefit1, benefit7Text];
    } else if (planType == 'ultra') {
      benefits = [localizations.oldBenefits, localizations.benefit8, localizations.benefit1, localizations.benefit5, benefit7Text];
    }

    final bool shouldAnimate = widget.animateBenefits;

    if (shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onBenefitsAnimated();
      });
    }

    return Wrap(
      spacing: screenWidth * 0.02,
      runSpacing: screenWidth * 0.02,
      children: benefits.asMap().entries.map((entry) {
        final int index = entry.key;
        final String benefit = entry.value;
        final double iconSize = screenWidth * 0.05;

        final benefitContent = SizedBox(
          // Now this calculation works correctly.
          width: (screenWidth - (horizontalPadding * 2) - (screenWidth * 0.02)) / 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icons/checkmark.svg', width: iconSize, height: iconSize, color: AppColors.primaryColor.inverted),
              SizedBox(width: screenWidth * 0.02),
              Expanded(child: Text(benefit, style: TextStyle(fontSize: screenWidth * 0.035, color: AppColors.primaryColor.inverted))),
            ],
          ),
        );

        return _FadingBenefitItem(
          animate: shouldAnimate,
          delay: Duration(milliseconds: 200 + (index * 120)),
          child: benefitContent,
        );
      }).toList(),
    );
  }
}

class _FadingBenefitItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final bool animate;

  const _FadingBenefitItem({
    required this.child,
    required this.delay,
    required this.animate,
  });

  @override
  State<_FadingBenefitItem> createState() => _FadingBenefitItemState();
}

class _FadingBenefitItemState extends State<_FadingBenefitItem> {
  bool _isVisible = false;
  double _yOffset = 10.0;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      Timer(widget.delay, () {
        if (mounted) {
          setState(() { _isVisible = true; _yOffset = 0.0; });
        }
      });
    } else {
      _isVisible = true;
      _yOffset = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _yOffset, 0),
        child: widget.child,
      ),
    );
  }
}
// credits.dart (FINAL, POLISHED, AND STATELESS)

import 'dart:developer';
import 'package:cortex/main.dart'; // Assuming this is for theme/app-wide constants
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../theme.dart';
import 'skeleton.dart';

class CreditPackage {
  final int amount;
  final String productId;
  final String price;

  CreditPackage({
    required this.amount,
    required this.productId,
    required this.price,
  });
}

/// A "dumb" widget that only displays credit packages based on the data it receives.
/// All logic for fetching and buying is handled by the parent widget.
class CreditContentWidget extends StatefulWidget {
  final ValueChanged<CreditPackage>? onCreditPackageSelected;
  final List<ProductDetails> availableProducts;
  final ScrollController? scrollController;

  const CreditContentWidget({
    Key? key,
    this.onCreditPackageSelected,
    required this.availableProducts,
    this.scrollController,
  }) : super(key: key);

  @override
  State<CreditContentWidget> createState() => _CreditContentWidgetState();
}

class _CreditContentWidgetState extends State<CreditContentWidget> with SingleTickerProviderStateMixin {
  int? _selectedCardIndex;
  final List<CreditPackage> _creditPackages = [];
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  // --- REMOVED: InAppPurchase instance and purchase logic ---
  // This widget is now purely for presentation. The parent handles all purchases.

  final bool _isTesting = !kReleaseMode;
  static const String _logName = 'CreditContentWidget';

  @override
  void initState() {
    super.initState();

    // --- NEW: Initialize the shine animation ---
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slower, more subtle shine
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _shineController, curve: Curves.linear)
    );

    _shineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait for a few seconds before the next shine
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _shineController.forward(from: 0.0);
          }
        });
      }
    });

    // Start the first animation after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _shineController.forward();
      }
    });


    _buildPackagesFromProps();
    _selectedCardIndex = 0;

    // After the first frame is built, notify the parent of the default selection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.onCreditPackageSelected != null && _creditPackages.isNotEmpty) {
        widget.onCreditPackageSelected!(_creditPackages[0]);
      }
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CreditContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Use listEquals from foundation.dart for a more robust comparison.
    if (!listEquals(widget.availableProducts, oldWidget.availableProducts)) {
      setState(() {
        _buildPackagesFromProps();
      });
    }
  }

  /// Rebuilds the internal list of [CreditPackage]s from the product details
  /// passed in via the widget's properties.
  void _buildPackagesFromProps() {
    _creditPackages.clear();

    // Create a mutable copy to sort
    final sortedProducts = List<ProductDetails>.from(widget.availableProducts);

    // Sort the products by amount to ensure a consistent list order.
    sortedProducts.sort((a, b) {
      final amountA = int.tryParse(a.title.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final amountB = int.tryParse(b.title.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return amountA.compareTo(amountB);
    });

    for (var productDetail in sortedProducts) {
      final amountString = productDetail.title.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.tryParse(amountString) ?? 0;
      if (amount > 0) {
        _creditPackages.add(CreditPackage(
          amount: amount,
          productId: productDetail.id,
          price: productDetail.price,
        ));
      }
    }
  }

  // --- REMOVED: buyCreditPackage and _showCustomNotification methods ---
  // All logic is now handled by the parent widget.

  @override
  Widget build(BuildContext context) {
    // If we're in a real build and the parent hasn't passed any products,
    // show a loader. This is a good fallback for when products are fetching.
    if (_creditPackages.isEmpty && !_isTesting) {
      return const SkeletonLoader(key: ValueKey('creditLoader'));
    }
    return _buildCreditContent(context);
  }

  Widget _buildCreditContent(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // --- DYNAMIC SIZING & LAYOUT CONSTANTS ---
    final double horizontalPadding = screenWidth * 0.04;
    final double spacingAfterTitle = screenHeight * 0.01;
    final double spacingAfterDescription = screenHeight * 0.02;
    final double cardMarginVertical = screenHeight * 0.0075;
    final double cardInnerPadding = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.1;
    final double spacingBetweenIconAndText = screenWidth * 0.04;
    final double spacingInCardText = screenHeight * 0.005;

    // --- DYNAMIC FONT SIZES ---
    final double titleFontSize = screenWidth * 0.07;
    final double descriptionFontSize = screenWidth * 0.035;
    final double cardTitleFontSize = screenWidth * 0.045;
    final double cardPriceFontSize = screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        key: const ValueKey('creditContent'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            localizations.buyCredits,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor.inverted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingAfterTitle),
          Text(
            localizations.selectCreditPackageDescription,
            style: TextStyle(
              fontSize: descriptionFontSize,
              color: AppColors.tertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingAfterDescription),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _creditPackages.length,
              itemBuilder: (context, index) {
                final package = _creditPackages[index];
                final isSelected = _selectedCardIndex == index;

                ProductDetails? productDetail;
                try {
                  productDetail = widget.availableProducts.firstWhere((p) => p.id == package.productId);
                } catch (e) {
                  log(
                    'Could not find ProductDetails for ${package.productId}. Using fallback data.',
                    name: _logName,
                  );
                  productDetail = null;
                }

                final String title = productDetail?.title ?? localizations.creditPackage(package.amount);
                final String price = productDetail?.price ?? package.price;

                final cardContent = AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(cardInnerPadding),
                  decoration: BoxDecoration(
                    // --- MODIFIED VALUES ---
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor.inverted : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/credit.svg',
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                      ),
                      SizedBox(width: spacingBetweenIconAndText),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: cardTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor.inverted,
                              ),
                            ),
                            SizedBox(height: spacingInCardText),
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: cardPriceFontSize,
                                color: AppColors.tertiaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );

                return GestureDetector(
                  onTap: () {
                    if (mounted) setState(() => _selectedCardIndex = index);
                    widget.onCreditPackageSelected?.call(package);
                  },
                  // --- WRAP with Margin & Stack for Shine Effect ---
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: cardMarginVertical),
                    child: Stack(
                      children: [
                        cardContent,
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: AnimatedBuilder(
                              animation: _shineAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(MediaQuery.of(context).size.width * _shineAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: Container(
                                width: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      AppColors.secondaryColor.withOpacity(0.0),
                                      AppColors.secondaryColor.withOpacity(0.5),
                                      AppColors.secondaryColor.withOpacity(0.0),
                                    ],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
// credits.dart (FINAL, CORRECTED, AND PERFORMATIVE)
// This version isolates the scroll fog logic into a dedicated StatefulWidget (_ScrollableListWithFog)
// to prevent entire widget rebuilds on scroll, fixing the Sliver assertion crash and improving performance.

import 'package:cortex/main.dart';
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

class _CreditContentWidgetState extends State<CreditContentWidget> {
  int? _selectedCardIndex;
  final List<CreditPackage> _creditPackages = [];

  final bool _isTesting = !kReleaseMode;

  @override
  void initState() {
    super.initState();
    _buildPackagesFromProps();
    // Default to the first package if available.
    if (_creditPackages.isNotEmpty) {
      _selectedCardIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.onCreditPackageSelected != null) {
          widget.onCreditPackageSelected!(_creditPackages[0]);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant CreditContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.availableProducts, oldWidget.availableProducts)) {
      setState(() {
        _buildPackagesFromProps();
        // After rebuilding packages, ensure a selection is still valid.
        if (_creditPackages.isNotEmpty &&
            (_selectedCardIndex == null || _selectedCardIndex! >= _creditPackages.length)) {
          _selectedCardIndex = 0;
          widget.onCreditPackageSelected?.call(_creditPackages[0]);
        }
      });
    }
  }

  void _buildPackagesFromProps() {
    _creditPackages.clear();
    final sortedProducts = List<ProductDetails>.from(widget.availableProducts);

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

  @override
  Widget build(BuildContext context) {
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

    final double horizontalPadding = screenWidth * 0.04;
    final double spacingAfterTitle = screenHeight * 0.01;
    final double spacingAfterDescription = screenHeight * 0.02;

    final double titleFontSize = screenWidth * 0.07;
    final double descriptionFontSize = screenWidth * 0.035;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        key: const ValueKey('creditContent'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            localizations.buyCredits,
            style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingAfterTitle),
          Text(
            localizations.selectCreditPackageDescription,
            style: TextStyle(fontSize: descriptionFontSize, color: AppColors.tertiaryColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingAfterDescription),
          Expanded(
            // <<< DEĞİŞİKLİK: Ayrı bir stateful widget'a taşıdık >>>
            child: _ScrollableListWithFog(
              scrollController: widget.scrollController,
              creditPackages: _creditPackages,
              availableProducts: widget.availableProducts,
              selectedCardIndex: _selectedCardIndex,
              onCardSelected: (index, package) {
                setState(() => _selectedCardIndex = index);
                widget.onCreditPackageSelected?.call(package);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// <<< YENİ WIDGET: Scroll ve Fog mantığını yöneten lokal stateful widget >>>
class _ScrollableListWithFog extends StatefulWidget {
  final ScrollController? scrollController;
  final List<CreditPackage> creditPackages;
  final List<ProductDetails> availableProducts;
  final int? selectedCardIndex;
  final Function(int, CreditPackage) onCardSelected;

  const _ScrollableListWithFog({
    required this.scrollController,
    required this.creditPackages,
    required this.availableProducts,
    required this.selectedCardIndex,
    required this.onCardSelected,
  });

  @override
  State<_ScrollableListWithFog> createState() => _ScrollableListWithFogState();
}

class _ScrollableListWithFogState extends State<_ScrollableListWithFog> with SingleTickerProviderStateMixin {
  bool _showBottomScrollFog = false;
  bool _showTopScrollFog = false;
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_updateFogVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFogVisibility());

    _shineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(CurvedAnimation(parent: _shineController, curve: Curves.linear));
    _shineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _shineController.forward(from: 0.0);
        });
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _shineController.forward();
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_updateFogVisibility);
    _shineController.dispose();
    super.dispose();
  }

  void _updateFogVisibility() {
    if (!mounted || widget.scrollController == null) return;
    final controller = widget.scrollController!;

    if (!controller.hasClients) {
      if (_showBottomScrollFog || _showTopScrollFog) {
        setState(() {
          _showBottomScrollFog = false;
          _showTopScrollFog = false;
        });
      }
      return;
    }

    final bool shouldShowTop = controller.position.pixels > 10;
    final bool shouldShowBottom =
        controller.position.maxScrollExtent > 0 && controller.position.pixels < controller.position.maxScrollExtent - 10;

    if (shouldShowTop != _showTopScrollFog || shouldShowBottom != _showBottomScrollFog) {
      // Bu setState SADECE bu küçük widget'ı yeniden çizer, performansı etkilemez.
      setState(() {
        _showTopScrollFog = shouldShowTop;
        _showBottomScrollFog = shouldShowBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context)!;

    final double cardMarginVertical = screenHeight * 0.0075;
    final double cardInnerPadding = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.1;
    final double spacingBetweenIconAndText = screenWidth * 0.04;
    final double spacingInCardText = screenHeight * 0.005;
    final double cardTitleFontSize = screenWidth * 0.045;
    final double cardPriceFontSize = screenWidth * 0.04;

    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          itemCount: widget.creditPackages.length,
          itemBuilder: (context, index) {
            final package = widget.creditPackages[index];
            final isSelected = widget.selectedCardIndex == index;

            ProductDetails? productDetail;
            try {
              productDetail = widget.availableProducts.firstWhere((p) => p.id == package.productId);
            } catch (e) {
              productDetail = null;
            }

            final String title = productDetail?.title ?? localizations.creditPackage(package.amount);
            final String price = productDetail?.price ?? package.price;

            final cardContent = AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(cardInnerPadding),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor.inverted : AppColors.border,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/credit.svg', width: iconSize, height: iconSize, colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn)),
                  SizedBox(width: spacingBetweenIconAndText),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: cardTitleFontSize, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted)),
                        SizedBox(height: spacingInCardText),
                        Text(price, style: TextStyle(fontSize: cardPriceFontSize, color: AppColors.tertiaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
            );

            return GestureDetector(
              onTap: () => widget.onCardSelected(index, package),
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
                          builder: (context, child) => Transform.translate(offset: Offset(screenWidth * _shineAnimation.value, 0), child: child),
                          child: Container(
                            width: screenWidth * 0.25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft, end: Alignment.centerRight,
                                colors: [ AppColors.secondaryColor.withOpacity(0.0), AppColors.secondaryColor.withOpacity(0.5), AppColors.secondaryColor.withOpacity(0.0)],
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
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showTopScrollFog ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                height: screenHeight * 0.04,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [AppColors.background.withOpacity(0.0), AppColors.background],
                    stops: const [0.0, 0.9],
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showBottomScrollFog ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                height: screenHeight * 0.07,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.background.withOpacity(0.0), AppColors.background],
                    stops: const [0.0, 0.9],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// credits.dart (FINAL & REFINED ARCHITECTURE)
// This version uses the central ScrollFog widget internally to apply fog
// ONLY to the scrollable list, not the static header text. This resolves
// the UI issue while maintaining a clean, modular architecture.

import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../fog.dart';
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
    super.key,
    this.onCreditPackageSelected,
    required this.availableProducts,
    this.scrollController,
  });

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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        key: const ValueKey('creditContent'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Static Header Content (No Fog Here) ---
          Text(
            localizations.buyCredits,
            style: TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            localizations.selectCreditPackageDescription,
            style: TextStyle(fontSize: screenWidth * 0.035, color: AppColors.tertiaryColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.02),

          // --- Scrollable Area (Fog Applied Here) ---
          Expanded(
            // The central ScrollFog widget now wraps ONLY the list view.
            child: ScrollFog(
              scrollController: widget.scrollController!,
              fogColor: AppColors.background,
              topFogHeight: screenHeight * 0.04,
              bottomFogHeight: screenHeight * 0.07,
              child: _CreditPackageListView(
                creditPackages: _creditPackages,
                availableProducts: widget.availableProducts,
                selectedCardIndex: _selectedCardIndex,
                scrollController: widget.scrollController,
                onCardSelected: (index, package) {
                  setState(() => _selectedCardIndex = index);
                  widget.onCreditPackageSelected?.call(package);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// This widget is now responsible ONLY for rendering the list and its internal animations (like the shine effect).
// All fog logic has been removed and is now handled by the parent ScrollFog widget.
class _CreditPackageListView extends StatefulWidget {
  final ScrollController? scrollController;
  final List<CreditPackage> creditPackages;
  final List<ProductDetails> availableProducts;
  final int? selectedCardIndex;
  final Function(int, CreditPackage) onCardSelected;

  const _CreditPackageListView({
    required this.scrollController,
    required this.creditPackages,
    required this.availableProducts,
    required this.selectedCardIndex,
    required this.onCardSelected,
  });

  @override
  State<_CreditPackageListView> createState() => _CreditPackageListViewState();
}

class _CreditPackageListViewState extends State<_CreditPackageListView> with SingleTickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
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
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context)!;

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: widget.creditPackages.length,
      padding: EdgeInsets.only(bottom: screenHeight * 0.02), // Add padding for better scroll end
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
          padding: EdgeInsets.all(screenWidth * 0.04),
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
              SvgPicture.asset(
                'assets/icons/credit.svg',
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
                colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      price,
                      style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.tertiaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return GestureDetector(
          onTap: () => widget.onCardSelected(index, package),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.0075),
            child: Stack(
              children: [
                cardContent,
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: AnimatedBuilder(
                      animation: _shineAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(screenWidth * _shineAnimation.value, 0),
                        child: child,
                      ),
                      child: Container(
                        width: screenWidth * 0.25,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.secondaryColor.withValues(alpha: 0.0),
                              AppColors.secondaryColor.withValues(alpha: 0.5),
                              AppColors.secondaryColor.withValues(alpha: 0.0),
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
    );
  }
}
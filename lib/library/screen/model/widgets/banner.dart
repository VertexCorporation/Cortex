// lib/library/screen/model/widgets/banner.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../funds/funds.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../navigation.dart';
import '../../../../../theme.dart';
import '../../../providers/details.dart';

/// A widget that displays a stack of warning banners.
/// It is a `StatefulWidget` to manage the animation controller and the
/// session-long dismissal state of the experimental banner.
class WarningOverlays extends StatefulWidget {
  final ModelDetailProvider provider;

  const WarningOverlays({
    super.key,
    required this.provider,
  });

  @override
  State<WarningOverlays> createState() => _WarningOverlaysState();
}

class _WarningOverlaysState extends State<WarningOverlays>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rgbController;

  // Static variable to track dismissal across all model pages for the current app session.
  static bool _experimentalBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _rgbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of one full color cycle
    )..repeat();
  }

  @override
  void dispose() {
    _rgbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = widget.provider;
    final mainModel = provider.mainModel;
    final warningWidgets = <Widget>[];

    // Populate the list of warnings based on the current model state.
    if (!provider.isLoading && mainModel != null) {
      if (provider.shouldShowPremiumWarning) {
        warningWidgets.add(_buildPremiumWarningBanner(localizations));
      }
      if (!mainModel.isFullyLocalized) {
        warningWidgets.add(_buildLocalizationWarningBanner(localizations));
      }
      // Only show the experimental banner if it hasn't been dismissed this session.
      if (!mainModel.isServerSide && !_experimentalBannerDismissed) {
        warningWidgets.add(_buildExperimentalWarningBanner(localizations));
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        if (child.key == const ValueKey('empty')) {
          return FadeTransition(opacity: animation, child: child);
        }
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: warningWidgets.isEmpty
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04),
        child: Column(
          key: const ValueKey('warnings'),
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            warningWidgets.length,
                (index) => Padding(
              padding: EdgeInsets.only(top: index > 0 ? 8.0 : 0.0),
              child: warningWidgets[index],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the tappable premium banner with an animated RGB border.
  Widget _buildPremiumWarningBanner(AppLocalizations localizations) {
    final screenWidth = MediaQuery.of(context).size.width;

    const double borderThickness = 2.0;
    final double borderRadius = screenWidth * 0.025;
    final double internalPaddingVertical = screenWidth * 0.03;
    final double internalPaddingHorizontal = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.07;
    final double titleFontSize = screenWidth * 0.038;
    final double descriptionFontSize = screenWidth * 0.033;

    return AnimatedBuilder(
      animation: _rgbController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(borderThickness),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              transform: GradientRotation(_rgbController.value * 2 * 3.14159),
              colors: const [
                Color(0xFFFF0000), Color(0xFFFF7F00), Color(0xFFFFFF00),
                Color(0xFF00FF00), Color(0xFF0000FF), Color(0xFF4B0082),
                Color(0xFF9400D3), Color(0xFFFF0000),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Material(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(borderRadius - borderThickness),
        child: InkWell(
          onTap: () => navigateToScreen(const FundsScreen(), direction: const Offset(0.0, 1.0)),
          borderRadius: BorderRadius.circular(borderRadius - borderThickness),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: internalPaddingVertical,
              horizontal: internalPaddingHorizontal,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/sparkle.svg',
                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                  width: iconSize,
                ),
                SizedBox(width: internalPaddingHorizontal),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.premiumModelNoticeTitle,
                        style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.premiumModelNoticeDescription,
                        style: TextStyle(fontSize: descriptionFontSize, color: AppColors.primaryColor.inverted.withValues(alpha:0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a generic warning banner with a consistent, responsive design.
  Widget _buildWarningBanner(AppLocalizations localizations, String text) {
    final screenWidth = MediaQuery.of(context).size.width;

    const double borderThickness = 1.0;
    final double borderRadius = screenWidth * 0.025;
    final double internalPaddingVertical = screenWidth * 0.03;
    final double internalPaddingHorizontal = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.06;
    final double textFontSize = screenWidth * 0.035;

    return Container(
      padding: const EdgeInsets.all(borderThickness),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: borderThickness,
        ),
      ),
      child: Material(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(borderRadius - borderThickness),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: internalPaddingVertical,
            horizontal: internalPaddingHorizontal,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/warning.svg',
                colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                width: iconSize,
              ),
              SizedBox(width: internalPaddingHorizontal),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: textFontSize,
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the specific banner for localization warnings.
  Widget _buildLocalizationWarningBanner(AppLocalizations localizations) {
    return _buildWarningBanner(localizations, localizations.localizationWarning);
  }

  /// Builds the specific banner for experimental offline models, wrapped in a Dismissible and GestureDetector.
  Widget _buildExperimentalWarningBanner(AppLocalizations localizations) {
    return Dismissible(
      key: const ValueKey('experimental_banner'),
      direction: DismissDirection.down,
      onDismissed: (direction) {
        if (mounted) {
          setState(() {
            _experimentalBannerDismissed = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          if (mounted) {
            setState(() {
              _experimentalBannerDismissed = true;
            });
          }
        },
        child: _buildWarningBanner(localizations, localizations.experimentalOfflineWarning),
      ),
    );
  }
}
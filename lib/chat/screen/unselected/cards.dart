// lib/chat/screen/unselected/cards.dart

import 'dart:io';

import 'package:cortex/main.dart';

import 'package:cortex/models/backend/data.dart';
import 'package:cortex/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

/// A robust card widget that displays a single model, designed to prevent UI overflows.
///
/// This card uses a combination of dynamic sizing and flexible widgets (`Flexible`, `FittedBox`)
/// to ensure its content gracefully adapts to all screen sizes, aspect ratios, and
/// user-defined font scaling settings.
class ModelCard extends StatelessWidget {
  final ModelInfo model;
  final VoidCallback? onTap;
  final bool hasInternet;

  const ModelCard({
    super.key,
    required this.model,
    required this.hasInternet,
    this.onTap,
  });

  /// Resolves the definitive image path for the model.
  String _resolveImagePath() {
    return ModelData.getModelImagePath({
      'id': model.id,
      'title': model.title,
      'imagePath': model.imagePath,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isServerModel = model.path == null;
    final double offlineAlpha = (isServerModel && !hasInternet) ? 0.5 : 1.0;

    final String imagePath = _resolveImagePath();
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    // --- Dynamic Layout Calculations for Robustness ---
    final screenWidth = MediaQuery.of(context).size.width;
    // These values must match the parent GridView for accurate calculations.
    final totalHorizontalScreenPadding = screenWidth * 0.04 * 2;
    final gridCrossAxisSpacing = screenWidth * 0.03;
    final totalHorizontalGridSpacing = gridCrossAxisSpacing * 2; // 2 gaps for 3 columns
    final cardWidth = (screenWidth - totalHorizontalScreenPadding - totalHorizontalGridSpacing) / 3;

    // Use a fixed aspect ratio defined by the parent grid to calculate height.
    const childAspectRatio = 1.1;
    final cardHeight = cardWidth / childAspectRatio;
    final imageSize = cardWidth * 0.45;
    final titleSize = cardWidth * 0.12;
    // --- End of Layout Calculations ---

    // --- Robust Image Rendering Logic ---
    final fallbackImage = SvgPicture.asset(
      'assets/icons/self.svg',
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
    );

    Widget imageWidget;
    if (imagePath.endsWith('self.svg')) {
      imageWidget = fallbackImage;
    } else {
      if (isSvg) {
        if (imagePath.startsWith('assets/')) {
          imageWidget = SvgPicture.asset(imagePath, width: imageSize, height: imageSize, fit: BoxFit.contain);
        } else {
          final file = File(imagePath);
          imageWidget = file.existsSync()
              ? SvgPicture.file(file, width: imageSize, height: imageSize, fit: BoxFit.contain)
              : fallbackImage;
        }
      } else {
        ImageProvider provider;
        if (imagePath.startsWith('assets/')) {
          provider = AssetImage(imagePath);
        } else {
          final file = File(imagePath);
          provider = file.existsSync()
              ? FileImage(file) as ImageProvider
              : const AssetImage('assets/icons/transparent.png');
        }
        imageWidget = Image(
          image: provider,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallbackImage,
        );
      }
    }
    // --- End of Image Rendering Logic ---

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: offlineAlpha,
        child: Container(
          padding: EdgeInsets.all(cardWidth * 0.1), // Dynamic padding
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Image Container ---
              Container(
                width: imageSize,
                height: imageSize,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(imageSize * 0.3),
                ),
                alignment: Alignment.center,
                child: imageWidget,
              ),
              // --- Dynamic Spacer ---
              SizedBox(height: cardHeight * 0.08),
              // --- BULLETPROOF TEXT WIDGET ---
              // This combination ensures the text never overflows.
              // `Flexible` gives it a bounded space, and `FittedBox`
              // scales the text down if it's too large for that space.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    model.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: titleSize, // This acts as the max font size.
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A centralized, reusable grid for displaying a list of models.
class ModelGridView extends StatelessWidget {
  final List<ModelInfo> models;
  final bool hasInternetConnection;
  final bool conversationLimitReached;
  final Function(ModelInfo) onSelectModel;
  final Key? gridKey;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  const ModelGridView({
    super.key,
    required this.models,
    required this.hasInternetConnection,
    required this.conversationLimitReached,
    required this.onSelectModel,
    this.gridKey,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      key: gridKey,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: screenWidth * 0.03, // Consistent spacing
        mainAxisSpacing: screenWidth * 0.03,  // Consistent spacing
        childAspectRatio: 1.1, // A balanced aspect ratio
      ),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        final isServerModel = model.path == null;
        return ModelCard(
          model: model,
          hasInternet: hasInternetConnection,
          onTap: () {
            if (conversationLimitReached) return;

            if (isServerModel && !hasInternetConnection) {
              notificationService.showNotification(
                message: localizations.internetRequired,
                isSuccess: false,
              );
            } else {
              onSelectModel(model);
            }
          },
        );
      },
    );
  }
}

/// A shimmer placeholder that mimics the appearance of a [ModelCard].
class ShimmerModelCard extends StatelessWidget {
  final bool isDetailed;
  const ShimmerModelCard({super.key, this.isDetailed = true});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(isDetailed ? 16 : 24),
        ),
        child: isDetailed
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 12),
            Container(height: 14, width: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(height: 12, width: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          ],
        )
            : null,
      ),
    );
  }
}

/// A reusable shimmer grid placeholder for loading states.
class ShimmerModelGridView extends StatelessWidget {
  final int itemCount;
  final bool isDetailed;
  final bool shrinkWrap;
  final Key? gridKey;

  const ShimmerModelGridView({
    super.key,
    required this.itemCount,
    this.isDetailed = true,
    this.shrinkWrap = false,
    this.gridKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GridView.builder(
      key: gridKey,
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: screenWidth * 0.03, // Consistent spacing
        mainAxisSpacing: screenWidth * 0.03,  // Consistent spacing
        childAspectRatio: isDetailed ? 0.75 : 1.1, // Consistent aspect ratio
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerModelCard(isDetailed: isDetailed),
    );
  }
}
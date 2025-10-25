// lib/chat/screen/unselected/cards.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../internet.dart';
import '../../../library/backend/data/entity.dart';
import '../../../library/backend/data/service.dart';

/// A robust card widget that displays a single model, designed to prevent UI overflows.
class ModelCard extends StatelessWidget {
  final ModelEntity model;
  final VoidCallback? onTap;

  const ModelCard({
    super.key,
    required this.model,
    this.onTap,
  });

  /// Resolves the definitive image path for the model by passing the entity.
  String _resolveImagePath(ModelService modelService) {
    return modelService.getModelImagePath(model);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasInternet = context.watch<InternetProvider>().isConnected;
    final bool isServerModel = model.isServerSide;
    final double offlineAlpha = (isServerModel && !hasInternet) ? 0.5 : 1.0;
    final modelService = context.read<ModelService>();

    final String imagePath = _resolveImagePath(modelService);
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    final screenWidth = MediaQuery.of(context).size.width;
    final totalHorizontalScreenPadding = screenWidth * 0.04 * 2;
    final gridCrossAxisSpacing = screenWidth * 0.03;
    final totalHorizontalGridSpacing = gridCrossAxisSpacing * 2;
    final cardWidth = (screenWidth - totalHorizontalScreenPadding - totalHorizontalGridSpacing) / 3;

    const childAspectRatio = 1.1;
    final cardHeight = cardWidth / childAspectRatio;
    final imageSize = cardWidth * 0.45;
    final titleSize = cardWidth * 0.12;

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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: offlineAlpha,
        child: Container(
          padding: EdgeInsets.all(cardWidth * 0.1),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              SizedBox(height: cardHeight * 0.08),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    model.displayTitle, // Use the pre-localized title from the entity.
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: titleSize,
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
/// REFACTORED: Now operates on a list of [ModelEntity].
class ModelGridView extends StatelessWidget {
  final List<ModelEntity> models;
  final bool conversationLimitReached;
  final Function(ModelEntity) onSelectModel;
  final Key? gridKey;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  const ModelGridView({
    super.key,
    required this.models,
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
    final bool isConnected = context.watch<InternetProvider>().isConnected;

    return GridView.builder(
      key: gridKey,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
        childAspectRatio: 1.1,
      ),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        final isServerModel = model.isServerSide;
        return ModelCard(
          model: model, // Pass the entity directly.
          onTap: () {
            if (conversationLimitReached) return;
            if (isServerModel && !isConnected) {
              notificationService.showNotification(
                message: localizations.internetRequired,
                isSuccess: false,
              );
            } else {
              onSelectModel(model); // The callback correctly passes the entity.
            }
          },
        );
      },
    );
  }
}

/// A shimmer placeholder that perfectly mimics the layout and proportions of a [ModelCard].
class ShimmerModelCard extends StatelessWidget {
  const ShimmerModelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final imageSize = cardWidth * 0.45;

          return Container(
            padding: EdgeInsets.all(cardWidth * 0.1),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(imageSize * 0.3),
                  ),
                ),
                const Spacer(flex: 2),
                Container(
                  height: cardWidth * 0.12,
                  width: cardWidth * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A reusable shimmer grid placeholder for loading states.
class ShimmerModelGridView extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final Key? gridKey;

  const ShimmerModelGridView({
    super.key,
    required this.itemCount,
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
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
        childAspectRatio: 1.1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerModelCard(),
    );
  }
}
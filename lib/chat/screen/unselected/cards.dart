// lib/chat/screen/unselected/cards.dart

import 'dart:io';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../models/backend/data.dart';

/// A card widget that displays a single model in the selection grid.
///
/// This widget is responsible for displaying the model's image, title, and producer.
/// It uses a robust image-handling mechanism to display local assets, downloaded files,
/// or a fallback SVG icon, all while correctly handling internet connectivity status for server-side models.
class ModelCard extends StatelessWidget {
  final ModelInfo model;
  final VoidCallback? onTap;
  final bool hasInternet;

  const ModelCard({
    Key? key,
    required this.model,
    required this.hasInternet,
    this.onTap,
  }) : super(key: key);

  /// Resolves the definitive image path for the model.
  ///
  /// This delegates the complex logic of finding the correct image to the
  /// `ModelData.getModelImagePath` function, which acts as the single source of truth
  /// for all model images in the application. This ensures consistency and simplifies
  /// the UI code.
  String _resolveImagePath() {
    return ModelData.getModelImagePath({
      'id': model.id,
      'title': model.title,
      'imagePath': model.imagePath,
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bool isServerModel = model.path == null;
    // Reduce opacity for server-side models when there's no internet to indicate they are unavailable.
    final double offlineAlpha = (isServerModel && !hasInternet) ? 0.5 : 1.0;

    final String imagePath = _resolveImagePath();
    final bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    // Localize the producer name if it's the special `_USER_` key.
    String displayProducer = model.producer;
    if (model.producer == '_USER_') {
      displayProducer = localizations.you;
    }

    // --- Responsive Layout Calculations ---
    // These calculations ensure the card scales gracefully on different screen sizes.
    final totalHorizontalPadding = 12.0 * 2;
    final totalHorizontalSpacing = 8.0 * 2;
    final w = (MediaQuery.of(context).size.width - totalHorizontalPadding - totalHorizontalSpacing) / 3;
    final imgSize = w * 0.7;
    final radiusOuter = imgSize * 0.15;
    final radiusInner = imgSize * 0.10;
    final borderW = w * 0.01;
    final gapBig = imgSize * 0.10;
    final gapSmall = imgSize * 0.05;
    final titleSize = imgSize * 0.165;
    final producerSize = imgSize * 0.15;
    // --- End of Layout Calculations ---

    // --- Robust Image Rendering Logic ---
    // This block ensures that a valid image is always displayed, with multiple fallbacks.

    // 1. Create the correctly colored fallback image ONCE to be reused.
    // This is the ultimate fallback if any other image loading fails.
    final fallbackImage = SvgPicture.asset(
      'assets/icons/self.svg',
      width: imgSize,
      height: imgSize,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
    );

    Widget imageWidget;

    // 2. Check if the final resolved path is our specific fallback SVG.
    // This avoids unnecessary file checks for a known asset.
    if (imagePath.endsWith('self.svg')) {
      imageWidget = fallbackImage;
    } else {
      // 3. For any other path, attempt to load it.
      if (isSvg) {
        // Handle vector graphics (SVG).
        if (imagePath.startsWith('assets/')) {
          imageWidget = SvgPicture.asset(imagePath, width: imgSize, height: imgSize, fit: BoxFit.contain);
        } else {
          final file = File(imagePath);
          imageWidget = file.existsSync()
              ? SvgPicture.file(file, width: imgSize, height: imgSize, fit: BoxFit.contain)
              : fallbackImage; // Use fallback if the SVG file is missing.
        }
      } else {
        // Handle raster graphics (PNG, JPG, etc.).
        ImageProvider provider;
        if (imagePath.startsWith('assets/')) {
          provider = AssetImage(imagePath);
        } else {
          final file = File(imagePath);
          // Use a transparent image as an intermediate fallback before the errorBuilder is called.
          provider = file.existsSync()
              ? FileImage(file) as ImageProvider
              : const AssetImage('assets/icons/transparent.png');
        }
        imageWidget = Image(
          image: provider,
          width: imgSize,
          height: imgSize,
          fit: BoxFit.cover,
          // The `errorBuilder` is the final safety net for raster images,
          // ensuring the fallback is shown if loading fails for any reason.
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
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(radiusOuter),
            border: Border.all(color: AppColors.border, width: borderW),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: imgSize,
                height: imgSize,
                clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radiusInner),
                ),
                alignment: Alignment.center,
                child: imageWidget, // The final, resolved image widget is placed here.
              ),
              SizedBox(height: gapBig),
              Text(
                model.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: gapSmall),
              Text(
                displayProducer,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted.withOpacity(.6),
                  fontSize: producerSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
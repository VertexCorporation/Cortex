// lib/library/screen/model/widgets/header.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../providers/details.dart';

/// The header section of the Model Detail screen.
///
/// Displays the model's image, title, producer, and key technical specs
/// like RAM, size, context window, and modality. It gets all its data
/// directly from the `ModelDetailProvider`.
class ModelHeader extends StatelessWidget {
  final ModelDetailProvider provider;

  const ModelHeader({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final mainModel = provider.mainModel!;

    final capabilitiesSource = provider.currentCapabilitiesSource ?? mainModel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Model Image ---
        Expanded(
          flex: 3,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                color: AppColors.secondaryColor,
              ),
              child: _buildImage(provider.displayImagePath),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.05),

        // --- Model Title and Info ---
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.displayTitle,
                style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                provider.displayProducer,
                style: TextStyle(
                  color: AppColors.quinaryColor,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Column(
                  key: ValueKey(provider.selectedBaseModelId ?? 'local'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!capabilitiesSource.isServerSide) ...[
                      _InfoRow(
                        label: localizations.storage,
                        value: capabilitiesSource.size != null ? '${capabilitiesSource.size} MB' : localizations.notAvailable,
                        iconPath: 'assets/icons/storage.svg',
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      _InfoRow(
                        label: localizations.ram,
                        value: capabilitiesSource.ram != null ? '${capabilitiesSource.ram} MB' : localizations.notAvailable,
                        iconPath: 'assets/icons/memory.svg',
                      ),
                    ] else ...[
                      _InfoRow(
                        label: localizations.modality,
                        value: provider.displayModality,
                        iconPath: 'assets/icons/transition.svg',
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      _InfoRow(
                        label: localizations.context,
                        value: provider.displayContext,
                        iconPath: 'assets/icons/context.svg',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the appropriate image widget based on the file path (SVG or raster).
  Widget _buildImage(String imagePath) {
    final svgColorFilter = ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn);

    final fallbackImage = Padding(
      padding: const EdgeInsets.all(12.0),
      child: SvgPicture.asset(
        'assets/icons/self.svg',
        fit: BoxFit.contain,
        colorFilter: svgColorFilter,
      ),
    );

    if (imagePath.toLowerCase().endsWith('.svg')) {
      if (imagePath.startsWith('assets/')) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(imagePath, fit: BoxFit.contain, colorFilter: svgColorFilter),
        );
      }
      final file = File(imagePath);
      if (file.existsSync()) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.file(file, fit: BoxFit.contain, colorFilter: svgColorFilter),
        );
      }
    } else {
      ImageProvider provider;
      if (imagePath.startsWith('assets/')) {
        provider = AssetImage(imagePath);
      } else {
        final file = File(imagePath);
        provider = file.existsSync() ? FileImage(file) as ImageProvider : const AssetImage('assets/icons/transparent.png');
      }
      return Image(
        image: provider,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallbackImage,
      );
    }
    return fallbackImage;
  }
}

/// A private helper widget to display a row of information with an icon, label, and value.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String iconPath;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: screenWidth * 0.05,
          height: screenWidth * 0.05,
          colorFilter: ColorFilter.mode(AppColors.quinaryColor, BlendMode.srcIn),
        ),
        SizedBox(width: screenWidth * 0.02),
        // Use Expanded to prevent text overflow issues with long values.
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              color: AppColors.quinaryColor,
              fontSize: screenWidth * 0.04,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
// lib/inbox/widgets/tiles/avatar.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app.dart';
import '../../../../theme.dart';

/// A widget that displays the avatar for a conversation tile.
class TileAvatar extends StatelessWidget {
  final String imagePath;
  final double size;

  const TileAvatar({
    super.key,
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(size * 0.125),
      ),
      clipBehavior: Clip.hardEdge, // PERFORMANCE: hardEdge avoids saveLayer
      alignment: Alignment.center,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    final String pathLower = imagePath.toLowerCase();
    final bool isAsset = imagePath.startsWith('assets/');
    final File imageFile = isAsset ? File('') : File(imagePath);

    if (pathLower.endsWith('.svg')) {
      return _buildSvgImage(isAsset, imageFile);
    } else if (pathLower.endsWith('.png')) {
      return _buildPngImage(isAsset, imageFile);
    } else {
      return _buildRasterImage(isAsset, imageFile);
    }
  }

  Widget _buildSvgImage(bool isAsset, File file) {
    final String pathLower = imagePath.toLowerCase();
    final bool isSelfIcon = pathLower.endsWith('self.svg');
    final bool isCortexIcon = pathLower.endsWith('cortex.svg');

    final double iconSize = (isSelfIcon || isCortexIcon) ? size * 0.8 : size;

    ColorFilter? colorFilter;

    colorFilter =
        ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn);

    if (isAsset) {
      return SvgPicture.asset(
        imagePath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: colorFilter,
      );
    } else if (!kIsWeb && file.existsSync()) {
      return SvgPicture.file(
        file as dynamic,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: colorFilter,
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildPngImage(bool isAsset, File file) {
    return Padding(
      padding: EdgeInsets.all(size * 0.15),
      child: isAsset
          ? Image.asset(imagePath, fit: BoxFit.contain)
          : (!kIsWeb && file.existsSync()
              ? Image.file(file, fit: BoxFit.contain)
              : _buildFallbackIcon()),
    );
  }

  Widget _buildRasterImage(bool isAsset, File file) {
    final String variant = imagePath.split('.').last.toLowerCase();
    final bool isValidImage =
        ['jpg', 'jpeg', 'webp', 'bmp', 'gif'].contains(variant);

    if (!isValidImage && !isAsset) {
      return _buildFallbackIcon();
    }

    return isAsset
        ? Image.asset(imagePath, width: size, height: size, fit: BoxFit.cover)
        : (!kIsWeb && file.existsSync()
            ? Image.file(file, width: size, height: size, fit: BoxFit.cover)
            : _buildFallbackIcon());
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.image_not_supported_rounded,
      color: AppColors.tertiaryColor,
      size: size * 0.6,
    );
  }
}

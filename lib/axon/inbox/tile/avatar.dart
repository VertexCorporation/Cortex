import 'package:cortex/design.dart';
// lib/inbox/widgets/tiles/avatar.dart

import 'dart:io';
import 'package:cortex/performance/file_probe_cache.dart';
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
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    final pathLower = imagePath.toLowerCase();
    final isAsset = imagePath.startsWith('assets/');
    final imageFile = isAsset ? File('') : File(imagePath);

    if (pathLower.endsWith('.svg')) {
      return _buildSvgImage(isAsset, imageFile);
    } else if (pathLower.endsWith('.png')) {
      return _buildPngImage(isAsset, imageFile);
    } else {
      return _buildRasterImage(isAsset, imageFile);
    }
  }

  bool _localExists(bool isAsset) =>
      !isAsset && !kIsWeb && FileProbeCache.shared.existsSync(imagePath);

  Widget _buildSvgImage(bool isAsset, File file) {
    final pathLower = imagePath.toLowerCase();
    final isSelfIcon = pathLower.endsWith('self.svg');
    final isCortexIcon = pathLower.endsWith('cortex.svg');
    final iconSize = (isSelfIcon || isCortexIcon) ? size * 0.8 : size;
    final colorFilter =
        ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn);

    if (isAsset) {
      return SvgPicture.asset(
        imagePath,
        width: CortexDesign.icon,
        height: CortexDesign.icon,
        fit: BoxFit.contain,
        colorFilter: colorFilter,
      );
    } else if (_localExists(isAsset)) {
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
          ? Image.asset(imagePath, fit: BoxFit.contain, cacheWidth: 120)
          : (_localExists(isAsset)
              ? Image.file(file, fit: BoxFit.contain, cacheWidth: 120)
              : _buildFallbackIcon()),
    );
  }

  Widget _buildRasterImage(bool isAsset, File file) {
    final variant = imagePath.split('.').last.toLowerCase();
    final isValidImage =
        ['jpg', 'jpeg', 'webp', 'bmp', 'gif'].contains(variant);

    if (!isValidImage && !isAsset) return _buildFallbackIcon();

    return isAsset
        ? Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: 120,
          )
        : (_localExists(isAsset)
            ? Image.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: 120,
              )
            : _buildFallbackIcon());
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.image_not_supported_rounded,
      color: AppColors.tertiaryColor,
      size: CortexDesign.icon,
    );
  }
}

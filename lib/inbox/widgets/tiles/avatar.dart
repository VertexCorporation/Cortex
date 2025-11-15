// lib/inbox/widgets/tiles/avatar.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app.dart';
import '../../../theme.dart';

/// A widget that displays the avatar for a conversation tile.
///
/// It intelligently handles different image types and sources:
/// - SVG or PNG files.
/// - Images from local assets or the device's file system.
/// - Applies specific color filters or padding based on the image type.
/// - Provides a fallback icon if the image path is invalid or the file is not found.
class TileAvatar extends StatelessWidget {
  /// The path to the image resource. Can be an asset path (e.g., 'assets/icons/model.svg')
  /// or a file path from the device's storage.
  final String imagePath;

  /// The size (width and height) of the avatar container.
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
        // The background color provides a consistent look, especially for transparent PNGs.
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(size * 0.125), // Responsive corner radius
      ),
      // Clip.antiAlias ensures the child image respects the container's rounded corners.
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: _buildImageWidget(),
    );
  }

  /// Determines the correct image widget to build based on the file extension and path.
  Widget _buildImageWidget() {
    final String pathLower = imagePath.toLowerCase();
    final bool isAsset = imagePath.startsWith('assets/');
    final File imageFile = isAsset ? File('') : File(imagePath);

    if (pathLower.endsWith('.svg')) {
      return _buildSvgImage(isAsset, imageFile);
    } else if (pathLower.endsWith('.png')) {
      return _buildPngImage(isAsset, imageFile);
    } else {
      // Fallback for other image types like .jpg, .jpeg, etc.
      return _buildRasterImage(isAsset, imageFile);
    }
  }

  /// Builds an [SvgPicture] from either assets or a local file.
  Widget _buildSvgImage(bool isAsset, File file) {
    // Apply special styling for specific icons, e.g., 'self.svg'.
    final isSelfIcon = imagePath.toLowerCase().endsWith('self.svg');
    final double iconSize = isSelfIcon ? size * 0.6 : size;
    final ColorFilter? colorFilter = isSelfIcon
        ? ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn)
        : null; // No filter for other SVGs unless specified

    if (isAsset) {
      return SvgPicture.asset(
        imagePath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: colorFilter,
      );
    } else if (file.existsSync()) {
      return SvgPicture.file(
        file,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: colorFilter,
      );
    }

    return _buildFallbackIcon();
  }

  /// Builds a padded [Image] widget for PNG files.
  Widget _buildPngImage(bool isAsset, File file) {
    // PNGs, especially logos, often look better with some padding.
    return Padding(
      padding: EdgeInsets.all(size * 0.15),
      child: isAsset
          ? Image.asset(imagePath, fit: BoxFit.contain)
          : (file.existsSync()
          ? Image.file(file, fit: BoxFit.contain)
          : _buildFallbackIcon()),
    );
  }

  /// Builds a standard [Image] widget for other raster formats (jpg, etc.).
  Widget _buildRasterImage(bool isAsset, File file) {
    return isAsset
        ? Image.asset(imagePath, width: size, height: size, fit: BoxFit.cover)
        : (file.existsSync()
        ? Image.file(file, width: size, height: size, fit: BoxFit.cover)
        : _buildFallbackIcon());
  }

  /// Returns a fallback icon to display when an image cannot be loaded.
  Widget _buildFallbackIcon() {
    return Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.tertiaryColor,
      size: size * 0.6,
    );
  }
}
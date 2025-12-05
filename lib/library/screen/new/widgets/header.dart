// lib/screens/models/screen/new/widgets/header.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../darkener.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// A widget for the profile header section in the model creation process.
class CreationProfileHeader extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController summaryController;
  final File? pickedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final AnimationController nameShakeController;

  const CreationProfileHeader({
    super.key,
    required this.nameController,
    required this.summaryController,
    required this.pickedImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.nameShakeController,
  });

  Future<void> _confirmRemovePhoto(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final restoreNavBar = Darkener.darken();

    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'RemovePhoto',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) => _buildConfirmationDialog(ctx, localizations),
      transitionBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    );

    restoreNavBar();

    if (confirmed == true) {
      onRemoveImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    // --- TABLET OPTIMIZATIONS ---
    // Make Avatar substantially larger on tablet (180px)
    final double avatarSize = isTablet ? 180.0 : screenWidth * 0.3;
    final double spacing = isTablet ? 32.0 : screenWidth * 0.02;
    final double borderRadius = isTablet ? 16.0 : screenWidth * 0.025;
    final double inputTextSize = isTablet ? 18.0 : 16.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Avatar Section ---
        _AvatarPicker(
          size: avatarSize,
          image: pickedImage,
          onPickImage: onPickImage,
          onRemoveImage: () => _confirmRemovePhoto(context),
        ),
        SizedBox(width: spacing),

        // --- Text Fields Section ---
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : spacing / 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: (avatarSize - spacing) / 1.5,
                  child: ShakeWidget(
                    controller: nameShakeController,
                    child: TextField(
                      controller: nameController,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9çÇğĞıİöÖşŞüÜ\s]'))],
                      style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: inputTextSize),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.nameLabel,
                        labelStyle: TextStyle(color: AppColors.primaryColor.inverted, fontSize: inputTextSize),
                        filled: true,
                        fillColor: AppColors.primaryColor,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isTablet ? 16 : 8),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(borderRadius)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(borderRadius)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: (avatarSize - spacing) / 1.5,
                  child: TextField(
                    controller: summaryController,
                    maxLength: 40,
                    style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: inputTextSize),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.summaryLabel,
                      labelStyle: TextStyle(color: AppColors.primaryColor.inverted, fontSize: inputTextSize),
                      filled: true,
                      fillColor: AppColors.primaryColor,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isTablet ? 16 : 8),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(borderRadius)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor.inverted), borderRadius: BorderRadius.circular(borderRadius)),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationDialog(BuildContext ctx, AppLocalizations localizations) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(ctx).size.width >= 600 ? 500 : MediaQuery.of(ctx).size.width * 0.8,
          decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(localizations.removePhotoTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(localizations.confirmRemovePhoto, style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: 16), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildDialogButton(ctx, localizations.cancel, AppColors.senaryColor, () => Navigator.of(ctx).pop(false)),
                      VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
                      _buildDialogButton(ctx, localizations.remove, AppColors.septenaryColor, () => Navigator.of(ctx).pop(true)),
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

  Widget _buildDialogButton(BuildContext ctx, String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.1),
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(text, style: TextStyle(color: color, fontSize: 18), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final double size;
  final File? image;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _AvatarPicker({
    required this.size,
    this.image,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: size / 2,
              backgroundColor: AppColors.secondaryColor,
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null
                  ? Icon(Icons.broken_image, size: size / 2.5, color: AppColors.primaryColor.inverted)
                  : null,
            ),
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: image == null ? onPickImage : onRemoveImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: image == null ? 0.0 : 0.125,
                    child: SvgPicture.asset(
                      'assets/icons/plus.svg',
                      width: size * 0.18,
                      colorFilter: ColorFilter.mode(
                        image == null ? AppColors.primaryColor.inverted : AppColors.septenaryColor,
                        BlendMode.srcIn,
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
  }
}

class ShakeWidget extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  const ShakeWidget({super.key, required this.child, required this.controller});
  @override
  Widget build(BuildContext context) => child;
}
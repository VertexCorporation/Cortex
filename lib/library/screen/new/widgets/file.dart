// lib/screens/models/screen/new/widgets/file.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;

import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// A widget for picking a GGUF model file, used in the 'Add' (offline) screen.
class GgufFilePicker extends StatelessWidget {
  final File? ggufFile;
  final VoidCallback onPickFile;

  const GgufFilePicker({
    super.key,
    required this.ggufFile,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;
    final bool isTablet = screenWidth >= 600;

    // --- TABLET OPTIMIZATIONS ---
    final double titleSize = isTablet ? 26.0 : screenWidth * 0.05;
    final double descSize = isTablet ? 18.0 : screenWidth * 0.035;
    final double borderRadius = isTablet ? 16.0 : screenWidth * 0.02;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title & Description ---
        Text(
          localizations.modelUploadTitle,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          localizations.modelUploadDescription,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: descSize,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        // --- Tappable File Picker Area ---
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onPickFile();
            },
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: double.infinity,
              // Make it taller on tablet for easier drag/drop feel
              height: isTablet ? 320 : screenHeight * 0.25,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: ggufFile != null
                    ? _buildFileSelectedView(
                        context, isTablet, screenWidth, screenHeight)
                    : _buildFilePickerPrompt(context, isTablet, screenWidth,
                        screenHeight, localizations),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelectedView(
      BuildContext context, bool isTablet, double w, double h) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded,
            color: AppColors.senaryColor, size: isTablet ? 80.0 : w * 0.1),
        SizedBox(height: h * 0.01),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            path.basename(ggufFile!.path),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: isTablet ? 20.0 : w * 0.035,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerPrompt(BuildContext context, bool isTablet, double w,
      double h, AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/upload.svg',
          width: isTablet ? 80.0 : w * 0.1,
          colorFilter: ColorFilter.mode(
              AppColors.primaryColor.inverted.withValues(alpha: 0.8),
              BlendMode.srcIn),
        ),
        SizedBox(height: h * 0.01),
        Text(
          loc.selectGGUFFile,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: isTablet ? 24.0 : w * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: h * 0.005),
        Text(
          loc.modelUploadShortDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: isTablet ? 18.0 : w * 0.035,
          ),
        ),
      ],
    );
  }
}

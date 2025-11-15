// lib/screens/models/screen/new/widgets/file.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;

import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// A widget for picking a GGUF model file, used in the 'Add' (offline) screen.
///
/// It displays a large tappable area for the user to select a file. Once a
/// file is selected, it shows a confirmation icon and the file's name.
/// All state and file picking logic is handled by the parent provider.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title & Description ---
        Text(
          localizations.modelUploadTitle,
          style: GoogleFonts.roboto(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          localizations.modelUploadDescription,
          style: GoogleFonts.roboto(
            color: AppColors.quinaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),

        // --- Tappable File Picker Area ---
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPickFile,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Center(
                child: ggufFile != null
                    ? _buildFileSelectedView(context)
                    : _buildFilePickerPrompt(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The view to display when a file has been successfully selected.
  Widget _buildFileSelectedView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, color: AppColors.senaryColor, size: screenWidth * 0.1),
        SizedBox(height: screenHeight * 0.01),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            path.basename(ggufFile!.path), // Show only the file name
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }

  /// The view to display when no file has been selected yet.
  Widget _buildFilePickerPrompt(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/upload.svg',
          width: screenWidth * 0.1,
          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withValues(alpha:0.8), BlendMode.srcIn),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          localizations.selectGGUFFile,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          localizations.modelUploadShortDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.quinaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ],
    );
  }
}
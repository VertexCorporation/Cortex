// screen.dart

import 'dart:io';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/chat/screen/selected/tiles.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../../theme.dart';
import '../../messages/messages.dart';

class SelectedScreen extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;
  final bool isEditingMode;
  final int? editingMessageIndex;
  final ValueNotifier<bool> streamingNotifier;
  final String? modelImagePath;
  final String? modelTitle;
  final String? selectedModelCategory;
  final String? modelId;
  final VoidCallback onStop;
  final Function(int index) onEdit;
  final Function(int index) onFadeOutComplete;
  final Function(int index) onRegenerate;
  final Function(int index, String newExtension) onChangeModel;
  final Function(int index) onReport;
  final AppLocalizations localizations;

  const SelectedScreen({
    Key? key,
    required this.messages,
    required this.scrollController,
    required this.isEditingMode,
    required this.editingMessageIndex,
    required this.streamingNotifier,
    required this.modelImagePath,
    required this.modelTitle,
    required this.selectedModelCategory,
    required this.modelId,
    required this.onStop,
    required this.onEdit,
    required this.onFadeOutComplete,
    required this.onRegenerate,
    required this.onChangeModel,
    required this.onReport,
    required this.localizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (messages.isEmpty) {
      final double imageSize = screenWidth * 0.25;

      // --- THE CORRECT FIX, FAITHFULLY REPLICATING cards.dart LOGIC ---

      // 1. Create the correctly colored fallback image ONCE. This is our goal for 'self.svg'.
      final fallbackImage = SvgPicture.asset(
        'assets/icons/self.svg',
        fit: BoxFit.contain,
        // This colorFilter is the key to making the SVG visible in any theme.
        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
      );

      Widget imageWidget;
      final path = modelImagePath;

      // 2. The critical check: If the path is null, empty, OR specifically 'self.svg',
      //    we must use our prepared `fallbackImage` with the color filter.
      if (path == null || path.isEmpty || path.endsWith('self.svg')) {
        imageWidget = fallbackImage;
      }
      // 3. For ALL OTHER paths, attempt to load them normally.
      else {
        final bool isSvg = path.toLowerCase().endsWith('.svg');
        if (isSvg) {
          // Handle OTHER SVGs (which don't need a color filter)
          if (path.startsWith('assets/')) {
            imageWidget = SvgPicture.asset(path, fit: BoxFit.contain);
          } else {
            final file = File(path);
            imageWidget = file.existsSync() ? SvgPicture.file(file, fit: BoxFit.contain) : fallbackImage;
          }
        } else {
          // Handle raster images (PNG, JPG, etc.)
          ImageProvider provider;
          if (path.startsWith('assets/')) {
            provider = AssetImage(path);
          } else {
            final file = File(path);
            provider = file.existsSync()
                ? FileImage(file) as ImageProvider
                : const AssetImage('assets/icons/transparent.png'); // Safe default
          }
          imageWidget = Image(
            image: provider,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallbackImage, // Use fallback on any loading error
          );
        }
      }
      // --- END OF FIX ---

      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: AppColors.secondaryColor,
                  ),
                  child: imageWidget, // Use the correctly chosen widget
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              if (modelTitle != null)
                Text(
                  modelTitle!,
                  style: GoogleFonts.heebo(
                    fontSize: screenWidth * 0.05,
                    color: AppColors.primaryColor.inverted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      );
    } else {
      // This part remains the same
      return Column(
        children: [
          Expanded(
            child: Tiles.buildMessagesList(
              context: context,
              messages: messages,
              scrollController: scrollController,
              isEditingMode: isEditingMode,
              editingMessageIndex: editingMessageIndex,
              streamingNotifier: streamingNotifier,
              modelId: modelId ?? '',
              onStop: onStop,
              onEdit: onEdit,
              onFadeOutComplete: onFadeOutComplete,
              onRegenerate: onRegenerate,
              onChangeModel: onChangeModel,
              onReport: onReport,
            ),
          ),
        ],
      );
    }
  }
}
// lib/axon/widgets/menu.dart

import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';

// Components
import 'item.dart';

class AxonMenu extends StatelessWidget {
  final double referenceWidth;
  final double screenHeight;
  final int activeTab;
  final VoidCallback onLibraryTap;
  final VoidCallback onCreateAITap;
  final VoidCallback onArtsTap;
  final VoidCallback onNewsTap;

  const AxonMenu({
    super.key,
    required this.referenceWidth,
    required this.screenHeight,
    required this.activeTab,
    required this.onLibraryTap,
    required this.onCreateAITap,
    required this.onArtsTap,
    required this.onNewsTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // --- Layout Constants ---
    final double horizontalPadding = referenceWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.005;

    // Match footer padding for consistent horizontal alignment
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.8),
      child: Column(
        children: [
          // --- 1. LIBRARY ---
          AxonItem(
            label: localizations.library,
            iconPath: 'assets/icons/library.svg',
            onTap: onLibraryTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: activeTab == 1,
          ),
          SizedBox(height: verticalSpacing),

          // --- 2. CREATE AI ---
          AxonItem(
            label: localizations.createAI,
            iconPath: 'assets/icons/intelligence.svg',
            onTap: onCreateAITap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: activeTab == 3,
          ),
          SizedBox(height: verticalSpacing),

          // --- 3. ARTS ---
          AxonItem(
            label: localizations.arts,
            iconPath: 'assets/icons/art.svg',
            onTap: onArtsTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: activeTab == 4,
          ),
          SizedBox(height: verticalSpacing),

          // --- 4. NEWS ---
          AxonItem(
            label: localizations.news,
            iconPath: 'assets/icons/news.svg',
            onTap: onNewsTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: activeTab == 2,
          ),

          // Bottom Spacing before the list starts
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
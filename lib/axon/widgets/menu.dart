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
  final VoidCallback onDocumentsTap;
  final VoidCallback onCreateAITap;
  final VoidCallback onArtsTap;
  final VoidCallback onRoleplayTap;
  final VoidCallback onNewsTap;
  final VoidCallback onArchivedTap;

  const AxonMenu({
    super.key,
    required this.referenceWidth,
    required this.screenHeight,
    required this.activeTab,
    required this.onLibraryTap,
    required this.onDocumentsTap,
    required this.onCreateAITap,
    required this.onArtsTap,
    required this.onRoleplayTap,
    required this.onNewsTap,
    required this.onArchivedTap,
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

          // --- 1.5 DOCUMENT CHAT (RAG) ---
          AxonItem(
            label: localizations.ragFeatureTitle,
            iconPath: 'assets/icons/attachment.svg',
            onTap: onDocumentsTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: false,
          ),
          SizedBox(height: verticalSpacing),

          // --- 2. ARTS ---
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

          // --- 3. CREATE AI ---
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
          SizedBox(height: verticalSpacing),

          // --- 5. ARCHIVED ---
          AxonItem(
            label: localizations.archive,
            iconPath: 'assets/icons/download.svg',
            onTap: onArchivedTap,
            screenHeight: screenHeight,
            referenceWidth: referenceWidth,
            reduceIconSize: true,
            isActive: false,
          ),

          // Bottom Spacing before the list starts
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}

// lib/update.dart

import 'package:cortex/app.dart';
import 'package:cortex/initialization.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen that informs the user that a mandatory update is required.
///
/// This screen's architecture is built on a `Stack` layout to ensure a
/// robust and visually stable presentation, regardless of screen size or content length.
/// This approach guarantees a non-scrollable screen, with a fixed background
/// image and a content area that intelligently handles overflow.
///
/// Key Architectural Features:
/// 1.  **Stack-Based Layout:** The foundation is a `Stack`, which layers the
///     background image and the foreground content. This prevents the image from
///     being pushed off-screen by long content.
/// 2.  **Internal Scrolling:** The main screen does not scroll. Instead, the "What's New"
///     section is placed within a `Flexible` widget, giving it a bounded height.
///     If the release notes are too long, only that specific container becomes
///     scrollable internally, preserving the overall layout.
/// 3.  **Proportional & Adaptive UI:** Sizing for fonts and spacing is calculated
///     relative to the screen dimensions, ensuring a consistent and readable
///     experience across all devices, from small phones to large tablets.
/// 4.  **Polished Animations:** A subtle fade and slide animation provides a
///     smooth and professional entrance for the content, enhancing the user experience.
class UpdateRequiredScreen extends StatefulWidget {
  const UpdateRequiredScreen({super.key});

  @override
  State<UpdateRequiredScreen> createState() => _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends State<UpdateRequiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // The Stack is the core of the new layout.
          return Stack(
            children: [
              // Layer 1: The background image, always positioned at the bottom.
              _buildBackgroundImage(constraints),

              // Layer 2: The animated content, safely padded and structured.
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContentColumn(context, constraints),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the background image, positioned at the bottom of the screen.
  Widget _buildBackgroundImage(BoxConstraints constraints) {
    // Make the image height proportional to the screen width for consistency.
    final double imageHeight = constraints.maxWidth * 0.9;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: Image.asset(
          'assets/neuro/yum.webp',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          color: AppColors.background,
          colorBlendMode: BlendMode.dstATop,
        ),
      ),
    );
  }

  /// Builds the main content column that sits on top of the background image.
  Widget _buildContentColumn(BuildContext context, BoxConstraints constraints) {
    final l10n = AppLocalizations.of(context)!;
    final appInitializer = context.read<AppInitializer>();

    appInitializer.configureUpgrader(l10n);
    final upgrader = appInitializer.upgrader;

    final safeArea = MediaQuery.paddingOf(context);
    final screenHeight = constraints.maxHeight;

    return Padding(
      // Use SafeArea and responsive padding to avoid system UI and screen edges.
      padding: EdgeInsets.only(
        left: constraints.maxWidth * 0.1,
        right: constraints.maxWidth * 0.1,
        top: safeArea.top + (screenHeight * 0.05),
        bottom: safeArea.bottom + (screenHeight * 0.025),
      ),
      child: Column(
        children: [
          // Header takes up its required space.
          _buildHeader(context, l10n, constraints),
          SizedBox(height: screenHeight * 0.04),

          // THIS IS THE KEY: The release notes are inside a Flexible widget.
          // It takes up all available remaining space, providing a bounded
          // height for its child, which can then scroll internally if needed.
          Flexible(
            child: _buildReleaseNotes(
                context, l10n, constraints, upgrader.releaseNotes),
          ),

          SizedBox(height: screenHeight * 0.03),
          // Button takes up its required space.
          _buildUpdateButton(
              context, l10n, constraints, upgrader.currentAppStoreListingURL),
        ],
      ),
    );
  }

  /// Builds the "Update Required" title and descriptive message.
  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final titleFontSize = (screenWidth * 0.07).clamp(26.0, 42.0);
    final messageFontSize = (screenWidth * 0.04).clamp(15.0, 20.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.updateRequiredTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor.inverted,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          l10n.updateRequiredMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: messageFontSize,
            color: AppColors.tertiaryColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Builds the "What's New" section with internal scrolling.
  Widget _buildReleaseNotes(BuildContext context, AppLocalizations l10n,
      BoxConstraints constraints, String? releaseNotes) {
    if (releaseNotes == null || releaseNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final headingFontSize = (screenWidth * 0.045).clamp(16.0, 22.0);
    final notesFontSize = (screenWidth * 0.035).clamp(14.0, 18.0);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.whatIsNew,
            style: TextStyle(
              fontSize: headingFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor.inverted,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                releaseNotes,
                style: TextStyle(
                  fontSize: notesFontSize,
                  color: AppColors.tertiaryColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Update Now" button.
  Widget _buildUpdateButton(BuildContext context, AppLocalizations l10n,
      BoxConstraints constraints, String? storeUrlString) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final buttonFontSize = (screenWidth * 0.04).clamp(15.0, 20.0);

    return ElevatedButton(
      onPressed: () async {
        if (storeUrlString != null && storeUrlString.isNotEmpty) {
          final url = Uri.parse(storeUrlString);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        backgroundColor: AppColors.primaryColor.inverted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.05),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.06,
        ),
        minimumSize: Size(double.infinity, screenHeight * 0.065),
      ),
      child: Text(
        l10n.updateNowButton,
        style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}

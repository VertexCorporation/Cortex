import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/app.dart';
import 'package:cortex/initialization.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Checks whether the server is currently in maintenance mode.
///
/// Returns `true` if maintenance is active, otherwise `false`.
Future<bool> checkMaintenanceMode() async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('getServerStatus');

    final result = await callable.call();
    return result.data['isUnderMaintenance'] ?? false;
  } catch (e) {
    debugPrint(
      "Could not check maintenance mode, assuming it's off. Error: $e",
    );
    return false;
  }
}

/// A screen that informs the user that the app is temporarily down for maintenance.
///
/// This screen's architecture is built on a `Stack` layout to ensure a
/// robust and visually stable presentation, perfectly consistent with other
/// blocking screens like the 'Update Required' page. This approach guarantees
/// a non-scrollable screen with a fixed background image.
///
/// Key Architectural Features:
/// 1.  **Stack-Based Layout:** The foundation is a `Stack`, which layers the
///     background image (at the bottom) and the foreground content (on top).
///     This prevents any potential layout shifts or clipping of the image.
/// 2.  **Vertical Centering:** The content is wrapped in a `Column` with `Spacer`
///     widgets. This ensures the text is perfectly centered in the available
///     space above the background image, creating a balanced and professional look.
/// 3.  **Proportional & Adaptive UI:** Sizing for fonts and spacing is calculated
///     relative to the screen dimensions, ensuring a consistent and readable
///     experience across all devices.
/// 4.  **Polished Animations:** A subtle fade and slide animation provides a
///     smooth and professional entrance for the content, enhancing the user experience.
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
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
          // The Stack is the core of our robust layout.
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
    final double imageHeight = constraints.maxWidth * 0.9;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: Image.asset(
          'assets/neuro/unamused.webp',
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
    final safeArea = MediaQuery.of(context).padding;
    final screenHeight = constraints.maxHeight;

    return Padding(
      // Use SafeArea and responsive padding for better aesthetics on all devices.
      padding: EdgeInsets.only(
        left: constraints.maxWidth * 0.1,
        right: constraints.maxWidth * 0.1,
        top: safeArea.top + (screenHeight * 0.05),
        bottom: safeArea.bottom + (screenHeight * 0.025),
      ),
      child: Column(
        children: [
          // This Spacer pushes the content down, helping to center it vertically
          // in the space *above* the background image.
          const Spacer(flex: 2),

          _buildHeader(context, l10n, constraints),

          SizedBox(height: screenHeight * 0.04),

          _buildContinueButton(context, l10n, constraints),

          // This Spacer takes up the remaining space, completing the centering effect.
          const Spacer(flex: 6),
        ],
      ),
    );
  }

  /// Builds the "Under Maintenance" title and descriptive message.
  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    // Use clamp to ensure font sizes are responsive but within reasonable limits.
    final titleFontSize = (screenWidth * 0.08).clamp(28.0, 44.0);
    final messageFontSize = (screenWidth * 0.045).clamp(16.0, 21.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.maintenanceTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor.inverted,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          l10n.maintenanceMessage,
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

  Widget _buildContinueButton(
      BuildContext context, AppLocalizations l10n, BoxConstraints constraints) {
    return TextButton(
      onPressed: () {
        context.read<AppInitializer>().bypassMaintenanceMode();
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.tertiaryColor,
        textStyle: TextStyle(
          fontSize: (constraints.maxWidth * 0.04).clamp(14.0, 18.0),
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(l10n.continueInOfflineMode),
    );
  }
}

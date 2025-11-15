// lib/settings/sections/header.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../theme.dart';
import '../providers/general.dart';

/// A self-contained, animated painter for creating a rotating gradient border.
/// It is used by `ProfileHeaderSection` to indicate a subscription status.
class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;

  AnimatedBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.5;
    final Rect rect = Offset.zero & size;
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: AppColors.animatedBorderGradientColors,
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(animationValue),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// A widget that displays the user's profile header by consuming data from `SettingsGeneralProvider`.
///
/// This component is responsible for displaying the user's avatar, name, email,
/// and any subscription or special status badges. It manages its own animation for the
/// subscriber border, starting and stopping it based on changes in the user's
/// active subscription status sourced directly from the provider.
class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({super.key});

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isAnimationInitialized = false;

  /// Stores the last known active level to detect when the animation state needs to change.
  /// This variable is a side-effect manager, not a data source for the UI.
  int _lastKnownActiveLevel = 0;

  @override
  void initState() {
    super.initState();
    // Animation is initialized in `didChangeDependencies` to ensure the provider
    // is available when the initial check is performed.
  }

  /// Manages the animation's lifecycle as a side-effect of provider data changes.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final generalProvider = Provider.of<SettingsGeneralProvider>(context);

    // Read the definitive active level directly from the provider's smart getter.
    final int newActiveLevel = generalProvider.activeSubscriptionLevel;

    // Compare with the last known state to decide if the animation needs to change.
    if (newActiveLevel != _lastKnownActiveLevel) {
      if (newActiveLevel >= 1 && !_isAnimationInitialized) {
        _initializeAnimation(); // User is now an active subscriber.
      } else if (newActiveLevel == 0 && _isAnimationInitialized) {
        _disposeAnimation(); // Subscription is no longer active.
      }
      // Update the state detector for the next change.
      _lastKnownActiveLevel = newActiveLevel;
    }
  }

  void _initializeAnimation() {
    if (_isAnimationInitialized) return;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_animationController);
    // Use `setState` only to rebuild and show the animation.
    if(mounted) setState(() => _isAnimationInitialized = true);
  }

  void _disposeAnimation() {
    if (_isAnimationInitialized) {
      _animationController.dispose();
      if(mounted) setState(() => _isAnimationInitialized = false);
    }
  }

  @override
  void dispose() {
    // Ensure the animation controller is disposed to prevent memory leaks.
    if (_isAnimationInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }

  String _getSubscriptionLabel(int activeLevel) {
    switch (activeLevel) {
      case 1: case 4: return "Plus";
      case 2: case 5: return "Pro";
      case 3: case 6: return "Ultra";
      default: return "";
    }
  }

  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenHeight * 0.006,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryColor.inverted, size: screenWidth * 0.045),
          SizedBox(width: screenWidth * 0.015),
          Text(label, style: GoogleFonts.poppins(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.032, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    // Use `context.watch` to listen for changes and get the latest data.
    final generalProvider = context.watch<SettingsGeneralProvider>();

    // The UI is now driven directly by the provider's state, ensuring it is always up-to-date.
    final userData = generalProvider.userData;
    final activeLevel = generalProvider.activeSubscriptionLevel;

    // Safely extract data with fallbacks.
    final displayName = userData?['username'] as String? ?? 'User';
    final email = generalProvider.isVerified ? (userData?['email'] as String? ?? '...') : 'Unverified';
    final isAlphaUser = userData?['alphaUser'] as bool? ?? false;

    final screenWidth = MediaQuery.of(context).size.width;
    final double avatarSize = screenWidth * 0.25;

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      padding: const EdgeInsets.all(3.0),
      child: CircleAvatar(
        radius: avatarSize / 2.2,
        backgroundColor: AppColors.secondaryColor,
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
          style: TextStyle(fontSize: avatarSize / 2.5, color: AppColors.primaryColor.inverted, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // Conditionally wrap the avatar with the animation if the subscription is active.
    if (activeLevel >= 1 && _isAnimationInitialized) {
      avatar = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedBorderPainter(animationValue: _animation.value),
            child: child,
          );
        },
        child: avatar,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: avatarSize * 0.05),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(displayName, style: GoogleFonts.poppins(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.06, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(email, style: GoogleFonts.poppins(color: AppColors.quinaryColor, fontSize: screenWidth * 0.04, fontWeight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: [
                      if (activeLevel >= 1)
                        _buildBadge(context, Icons.star_rounded, _getSubscriptionLabel(activeLevel)),
                      if (activeLevel >= 1 && isAlphaUser)
                        SizedBox(width: screenWidth * 0.02),
                      if (isAlphaUser)
                        _buildBadge(context, Icons.explore, "Alpha"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
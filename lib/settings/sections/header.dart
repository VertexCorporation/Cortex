// header.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/app.dart';
import 'package:cortex/theme.dart'; // For AppColors
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts

/// A self-contained, animated painter for creating a rotating gradient border.
/// It is used by ProfileHeaderSection to indicate a subscription status.
class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;

  AnimatedBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.5; // Slightly thicker for better visibility
    final Rect rect = Offset.zero & size;
    final double radius = size.width / 2;

    // The paint object configures the shader and stroke properties.
    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: AppColors.animatedBorderGradientColors, // Assumes this is defined in your theme.
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(animationValue),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw the circle with the gradient paint.
    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) {
    // Repaint only if the animation value has changed to optimize performance.
    return oldDelegate.animationValue != animationValue;
  }
}

/// A widget that displays the user's profile header.
///
/// This widget is now a StatefulWidget to manage its own animation controller,
/// ensuring the animation only runs when the widget is visible. This optimizes
/// performance and prevents GPU glitches.
class ProfileHeaderSection extends StatefulWidget {
  final String displayName;
  final String email;
  final int userSubscriptionLevel;
  final bool isAlphaUser;
  final Timestamp? subscriptionExpiresAt; // <<< NEW PARAMETER

  const ProfileHeaderSection({
    super.key,
    required this.displayName,
    required this.email,
    required this.userSubscriptionLevel,
    required this.isAlphaUser,
    this.subscriptionExpiresAt, // Now accepts the expiration date
  });

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isControllerInitialized = false;

  /// Internal, reliable getter that checks both the subscription level
  /// and the expiration date to determine the true active status.
  int get _activeLevel {
    final level = widget.userSubscriptionLevel;

    if (level >= 4) {
      return level;
    }

    if (level == 0) return 0;
    if (widget.subscriptionExpiresAt == null) return 0;
    if (widget.subscriptionExpiresAt!.toDate().isBefore(DateTime.now())) return 0;

    return level;
  }

  /// Helper to initialize the animation controller.
  void _initializeAnimation() {
    if (_isControllerInitialized) return;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_animationController);
    _isControllerInitialized = true;
  }

  /// Helper to safely dispose of the animation controller.
  void _disposeAnimation() {
    if (_isControllerInitialized) {
      _animationController.dispose();
      _isControllerInitialized = false;
    }
  }

  /// Helper function for didUpdateWidget to calculate the old active level.
  int _calculateActiveLevel(int level, Timestamp? expiresAt) {
    if (level == 0) return 0;
    if (expiresAt == null) return 0;
    if (expiresAt.toDate().isBefore(DateTime.now())) return 0;
    return level;
  }

  @override
  void initState() {
    super.initState();
    // Start animation based on the reliable `_activeLevel`.
    if (_activeLevel >= 1) {
      _initializeAnimation();
    }
  }

  /// --- UPDATED LIFECYCLE METHOD ---
  /// Handles dynamic changes to the subscription status while the widget is visible.
  @override
  void didUpdateWidget(covariant ProfileHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldActiveLevel = _calculateActiveLevel(
        oldWidget.userSubscriptionLevel, oldWidget.subscriptionExpiresAt);
    final newActiveLevel = _activeLevel;

    // If the active status has changed, update the animation state.
    if (oldActiveLevel != newActiveLevel) {
      if (newActiveLevel >= 1 && !_isControllerInitialized) {
        _initializeAnimation(); // User just subscribed
      } else if (newActiveLevel < 1 && _isControllerInitialized) {
        _disposeAnimation(); // Subscription just expired
      }
      // Trigger a rebuild to reflect the change visually.
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _disposeAnimation();
    super.dispose();
  }

  /// Returns the subscription label based on the reliable `_activeLevel`.
  String _getSubscriptionLabel() {
    switch (_activeLevel) {
      case 1:
      case 4: return "Plus";
      case 2:
      case 5: return "Pro";
      case 3:
      case 6: return "Ultra";
      default: return "";
    }
  }

  /// Builds a badge widget with an icon and a label.
  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double iconSize = screenWidth * 0.045;
    double fontSize = screenWidth * 0.032;

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
          Icon(icon, color: AppColors.primaryColor.inverted, size: iconSize),
          SizedBox(width: screenWidth * 0.015),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.primaryColor.inverted,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double avatarSize = screenWidth * 0.25;
    double fontSizeName = screenWidth * 0.06;
    double fontSizeEmail = screenWidth * 0.04;
    double spacing = screenWidth * 0.04;

    if (kDebugMode) {
      print('[ProfileHeaderSection] Building widget. Active Level: $_activeLevel');
    }

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      padding: const EdgeInsets.all(3.0),
      child: CircleAvatar(
        radius: avatarSize / 2.2,
        backgroundColor: AppColors.secondaryColor,
        child: Text(
          widget.displayName.isNotEmpty ? widget.displayName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: avatarSize / 2.5,
            color: AppColors.primaryColor.inverted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Apply animated border based on the reliable `_activeLevel`.
    if (_activeLevel >= 1) {
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
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: avatarSize * 0.05),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.displayName,
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryColor.inverted,
                        fontSize: fontSizeName,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.email,
                      style: GoogleFonts.poppins(
                        color: AppColors.quinaryColor,
                        fontSize: fontSizeEmail,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      // Display badges based on the reliable `_activeLevel`.
                      if (_activeLevel >= 1)
                        _buildBadge(context, Icons.star_rounded, _getSubscriptionLabel()),
                      if (_activeLevel >= 1 && widget.isAlphaUser)
                        SizedBox(width: screenWidth * 0.02),
                      if (widget.isAlphaUser)
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
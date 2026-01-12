// lib/chat/screen/widgets empty.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// --- Internal Imports ---
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/chat/providers/session.dart';

import '../../../app.dart';

class ChatEmptyState extends StatefulWidget {
  const ChatEmptyState({super.key});

  @override
  State<ChatEmptyState> createState() => _ChatEmptyStateState();
}

class _ChatEmptyStateState extends State<ChatEmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // --- 1. DYNAMIC CHAT MODE (CORTEX LOGO) ---
    if (sessionProvider.isDynamicChat ||
        (sessionProvider.isExitingChat && sessionProvider.wasDynamicOnExit)) {
      return _buildDynamicEmptyState(context, screenWidth, screenHeight);
    }

    // --- 2. SPECIFIC MODEL MODE (MODEL IMAGE) ---
    return _buildModelEmptyState(context, screenWidth, screenHeight, sessionProvider);
  }

  Widget _buildDynamicEmptyState(BuildContext context, double screenWidth, double screenHeight) {
    final bool isDarkBackground = AppColors.background.computeLuminance() < 0.5;

    final ColorFilter? smartCortexFilter = isDarkBackground
        ? const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ])
        : null;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: SvgPicture.asset(
                    'assets/cortex.svg',
                    fit: BoxFit.contain,
                    colorFilter: smartCortexFilter,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Text(
                AppLocalizations.of(context)!.selectionScreenGreetingGeneric,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  color: AppColors.primaryColor.inverted,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildModelEmptyState(BuildContext context, double screenWidth, double screenHeight, ChatSessionProvider sessionProvider) {
    final double imageSize = screenWidth * 0.25;

    final fallbackImage = SvgPicture.asset(
      'assets/icons/self.svg',
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
    );

    Widget imageWidget;
    final path = sessionProvider.modelImagePath;

    if (path == null || path.isEmpty || path.endsWith('self.svg')) {
      imageWidget = fallbackImage;
    } else {
      final bool isSvg = path.toLowerCase().endsWith('.svg');

      if (isSvg) {
        imageWidget = path.startsWith('assets/')
            ? SvgPicture.asset(path, fit: BoxFit.contain)
            : SvgPicture.file(File(path), fit: BoxFit.contain, placeholderBuilder: (_) => fallbackImage);
      } else {
        final provider = path.startsWith('assets/')
            ? AssetImage(path) as ImageProvider
            : FileImage(File(path));

        imageWidget = Image(
          image: provider,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackImage,
        );
      }
    }

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
                  color: AppColors.background,
                ),
                child: imageWidget,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (sessionProvider.modelTitle != null)
              Text(
                sessionProvider.modelTitle!,
                style: TextStyle(
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
  }
}
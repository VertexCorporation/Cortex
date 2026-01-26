// lib/chat/screen/widgets/tts_player.dart
//
// Floating TTS player that appears below the AppBar when reading a message.

import 'package:cortex/app.dart';
import 'package:cortex/chat/services/tts.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class TtsPlayerOverlay extends StatefulWidget {
  const TtsPlayerOverlay({super.key});

  @override
  State<TtsPlayerOverlay> createState() => _TtsPlayerOverlayState();
}

class _TtsPlayerOverlayState extends State<TtsPlayerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: TtsService(),
      child: Consumer<TtsService>(
        builder: (context, ttsService, child) {
          final bool isActive = ttsService.state != TtsState.idle ||
              ttsService.currentText.isNotEmpty;

          // Animate in/out based on state
          if (isActive && !_slideController.isCompleted) {
            _slideController.forward();
          } else if (!isActive && _slideController.value > 0) {
            _slideController.reverse();
          }

          return SlideTransition(
            position: _slideAnimation,
            child: AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _TtsPlayerBar(
                onClose: () => ttsService.stop(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TtsPlayerBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TtsPlayerBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;

    final double height = screenHeight * 0.055;
    final double horizontalMargin = isTablet ? 24.0 : 16.0;
    final double borderRadius = isTablet ? 16.0 : 12.0;
    final double iconSize = isTablet ? 24.0 : 20.0;
    final double buttonPadding = isTablet ? 12.0 : 10.0;

    final ttsService = context.watch<TtsService>();
    final bool isPlaying = ttsService.state == TtsState.playing;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Row(
              children: [
                // Play/Stop Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (isPlaying) {
                        ttsService.stop();
                      }
                      // Note: Play is initiated from message options, not here
                    },
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(buttonPadding),
                      child: SvgPicture.asset(
                        isPlaying
                            ? 'assets/icons/stop.svg'
                            : 'assets/icons/play.svg',
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.inverted,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),

                // Progress Bar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Track
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.border.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Progress
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              height: 4,
                              width: constraints.maxWidth * ttsService.progress,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.inverted,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Close Button (Arrow rotated 180 degrees = pointing up)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(buttonPadding),
                      child: Transform.rotate(
                        angle: 3.14159, // 180 degrees in radians
                        child: SvgPicture.asset(
                          'assets/icons/arrow.svg',
                          width: iconSize,
                          height: iconSize,
                          colorFilter: ColorFilter.mode(
                            AppColors.tertiaryColor.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/chat/screen/widgets/player.dart
//
// Floating TTS player that appears below the AppBar when reading a message.

import 'package:cortex/app.dart';
import 'package:cortex/chat/services/tts.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'dart:async'; // [NEW] For timer

class TtsPlayerOverlay extends StatefulWidget {
  const TtsPlayerOverlay({super.key});

  @override
  State<TtsPlayerOverlay> createState() => _TtsPlayerOverlayState();
}

class _TtsPlayerOverlayState extends State<TtsPlayerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _closeTimer?.cancel();
    super.dispose();
  }

  bool _dismissingDown = false;

  // [NEW] Logic to handle auto-closing
  void _manageVisibility(TtsService ttsService) {
    bool hasText = ttsService.currentText.isNotEmpty;
    bool isActive = ttsService.state != TtsState.idle || hasText;

    if (isActive) {
      if (!_slideController.isCompleted && !_slideController.isAnimating) {
        // Prepare for entry (Slide Down from Top)
        if (_dismissingDown) {
          // If we were dismissing down, reset so we can slide in properly?
          // Actually, standard entry is always from Top (-1).
          // We should reset the animation to standard entry.
          _dismissingDown = false;
        }
        _slideController.forward();
      }
      _closeTimer?.cancel();
    } else {
      if (_closeTimer == null || !_closeTimer!.isActive) {
        _closeTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            // Auto close goes UP (standard)
            _dismissingDown = false;
            _slideController.reverse();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: TtsService(),
      child: Consumer<TtsService>(
        builder: (context, ttsService, child) {
          _manageVisibility(ttsService);

          // Dynamic Slide Animation based on direction
          // Standard (Entry/Exit Up): begin(0, -1) -> end(0, 0)
          // Exit Down: begin(0, 1) -> end(0, 0) ??
          // Wait, if controller is at 1.0 (visible), reverse() goes to begin.
          // If we want to exit DOWN, we want target to be (0, 1).
          // So if dismissingDown is true, we want 'begin' to be (0, 1).

          Animation<Offset> currentAnimation = Tween<Offset>(
            begin: _dismissingDown ? const Offset(0, 1) : const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          ));

          return FadeTransition(
            opacity: _slideController,
            child: SlideTransition(
              position: currentAnimation,
              child: _TtsPlayerBar(
                  key: const ValueKey('tts_bar'),
                  onDismiss: (direction) {
                    ttsService.stop();
                    setState(() {
                      _dismissingDown = direction == DismissDirection.down;
                    });
                    _slideController.reverse();
                  },
                  onInteraction: () {
                    if (_closeTimer?.isActive == true) {
                      _closeTimer?.cancel();
                      _closeTimer = Timer(const Duration(seconds: 2), () {
                        if (mounted) {
                          _dismissingDown = false;
                          _slideController.reverse();
                        }
                      });
                    }
                  }),
            ),
          );
        },
      ),
    );
  }
}

class _TtsPlayerBar extends StatelessWidget {
  final Function(DismissDirection) onDismiss;
  final VoidCallback onInteraction;

  const _TtsPlayerBar({
    super.key,
    required this.onDismiss,
    required this.onInteraction,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Layout constants same as before)
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
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          double delta = details.primaryDelta ?? 0;
          if (delta < -5) {
            onDismiss(DismissDirection.up);
          } else if (delta > 5) {
            onDismiss(DismissDirection.down);
          }
        },
        onHorizontalDragUpdate: (details) {
          onDismiss(
              DismissDirection.up); // Default horizontal to up? Or keep it?
        },
        // [REMOVED] Dismissible widget entirely to fix crash
        child: GestureDetector(
          onTap: onInteraction,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(borderRadius),
                // ... decoration
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
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Play/Pause Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onInteraction();
                            if (isPlaying) {
                              ttsService.pause();
                            } else if (ttsService.state == TtsState.paused) {
                              ttsService.resume();
                            } else {
                              // Resume/Replay Logic
                              // Prioritize currentText (if paused/interrupted)
                              if (ttsService.currentText.isNotEmpty) {
                                ttsService
                                    .resume(); // Use resume as it handles offset?
                                // Actually speak() starts over. resume() continues.
                                // If we are IDLE, we want to REPLAY or RESUME?
                                // If paused, Resume.
                                // If Idle (finished), Replay?
                                // But `currentText` might be cleared if IDLE.
                                // If `originalText` exists, speak(originalText).
                              }
                              // Correct logic:
                              if (ttsService.originalText.isNotEmpty) {
                                ttsService.speak(ttsService.originalText);
                              }
                            }
                          },
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(borderRadius),
                            bottomLeft: Radius.circular(borderRadius),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding:
                                EdgeInsets.symmetric(horizontal: buttonPadding),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: SvgPicture.asset(
                                isPlaying
                                    ? 'assets/icons/stop.svg'
                                    : 'assets/icons/play.svg',
                                key: ValueKey(isPlaying),
                                width: iconSize * 0.75,
                                height: iconSize * 0.75,
                                colorFilter: ColorFilter.mode(
                                  AppColors.primaryColor.inverted,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.border,
                        indent: height * 0.2,
                        endIndent: height * 0.2,
                      ),

                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: SliderComponentShape.noThumb,
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10.0),
                            activeTrackColor: AppColors.primaryColor.inverted,
                            inactiveTrackColor:
                                AppColors.border.withValues(alpha: 0.5),
                            overlayColor: AppColors.primaryColor.inverted
                                .withValues(alpha: 0.1),
                          ),
                          child: Slider(
                            value: ttsService.progress,
                            onChanged: (value) {
                              onInteraction();
                              ttsService.seek(value);
                            },
                          ),
                        ),
                      ),

                      SizedBox(width: horizontalMargin * 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

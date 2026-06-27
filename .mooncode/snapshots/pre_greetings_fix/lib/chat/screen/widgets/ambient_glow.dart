import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';

class AmbientGlow extends StatefulWidget {
  final double height;
  const AmbientGlow({super.key, this.height = 300});

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
            builder: (context, child) {
        // Smoother curved animation (Sine wave) to prevent robotic linear stops
        final curve = Curves.easeInOutSine.transform(_controller.value);
        
        // Very subtle breathing scales and offsets (no layout changes)
        final scale1 = 1.0 + (curve * 0.08); // 8% scale pulse
        final scale2 = 1.0 + ((1 - curve) * 0.08);
        
        final offsetX1 = curve * 15.0;
        final offsetY1 = curve * -10.0;
        
        final offsetX2 = (1 - curve) * -15.0;
        final offsetY2 = (1 - curve) * -10.0;

        // Color & Visibility Logic
        final bool isChatActive = context.watch<ConversationProvider>().messages.isNotEmpty;
        final session = context.watch<ChatSessionProvider>();
        
        final double targetAlpha = 0.15;
        
        Color targetColor;
        if (session.isFluxMode) {
          targetColor = const Color(0xFFFFEBEE); 
        } else {
          targetColor = AppColors.primaryColor.inverted;
        }
        
        final Color baseColor = targetColor.withValues(alpha: targetAlpha);

        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1500),
            opacity: isChatActive ? 0.0 : 1.0,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bottom Left Fog
                  Positioned(
                    bottom: -150,
                    left: -100,
                    child: Transform.translate(
                      offset: Offset(offsetX1, offsetY1),
                      child: Transform.scale(
                        scale: scale1,
                        child: Container(
                          width: 400.0,
                          height: 400.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                baseColor,
                                baseColor.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Right Fog
                  Positioned(
                    bottom: -150,
                    right: -100,
                    child: Transform.translate(
                      offset: Offset(offsetX2, offsetY2),
                      child: Transform.scale(
                        scale: scale2,
                        child: Container(
                          width: 400.0,
                          height: 400.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                baseColor,
                                baseColor.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 1.0],
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
        );
      },
    );
  }
}
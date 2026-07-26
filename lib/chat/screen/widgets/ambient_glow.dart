import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';

class AmbientGlow extends StatefulWidget {
  final double height;
  const AmbientGlow({super.key, this.height = 300});

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isChatActive =
        context.watch<ConversationProvider>().messages.isNotEmpty;
    final session = context.watch<ChatSessionProvider>();
    final bool isFlux = session.isFluxMode;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOutSine.transform(_controller.value);

        Color baseColor;
        if (isFlux) {
          baseColor = const Color(0xFFFFCDD2);
        } else {
          baseColor = Colors.white;
        }

        final alpha = (0.07 + (t * 0.03)).clamp(0.0, 1.0);
        final fadeAlpha = (0.05 + ((1.0 - t) * 0.03)).clamp(0.0, 1.0);

        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 2000),
            opacity: isChatActive ? 0.0 : 1.0,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120.0, sigmaY: 120.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -80,
                    left: -60,
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: widget.height * 0.8,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            baseColor.withValues(alpha: alpha),
                            baseColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    right: -60,
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: widget.height * 0.8,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [
                            baseColor.withValues(alpha: fadeAlpha),
                            baseColor.withValues(alpha: 0.0),
                          ],
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

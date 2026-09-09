import 'dart:math' as math;
import 'package:cortex/app.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

/// Stable generation label over evenly spaced, independently pulsing dots.
class MediaShimmerPlaceholder extends StatefulWidget {
  const MediaShimmerPlaceholder({super.key, required this.type});
  final MediaGenerationType type;
  @override
  State<MediaShimmerPlaceholder> createState() =>
      _MediaShimmerPlaceholderState();
}

class _MediaShimmerPlaceholderState extends State<MediaShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == MediaGenerationType.none) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final (label, icon) = switch (widget.type) {
      MediaGenerationType.image => (
          l10n.generationImageLabel,
          Icons.image_outlined
        ),
      MediaGenerationType.video => (
          l10n.generationVideoLabel,
          Icons.videocam_outlined
        ),
      MediaGenerationType.audio => (
          l10n.generationAudioLabel,
          Icons.graphic_eq_rounded
        ),
      MediaGenerationType.document => (
          l10n.generationDocumentLabel,
          Icons.description_outlined
        ),
      MediaGenerationType.none => ('', Icons.hourglass_empty),
    };
    final width = math.min(MediaQuery.sizeOf(context).width * 0.65, 340.0);
    final foreground = AppColors.primaryColor.inverted;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        label: label,
        liveRegion: true,
        child: ExcludeSemantics(
            child: Container(
          width: width,
          height: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border)),
          child: Stack(fit: StackFit.expand, children: [
            CustomPaint(
                painter: _GenerationDots(animation: _pulse, color: foreground)),
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: 34, color: foreground),
                      const SizedBox(height: 12),
                      Text(label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: foreground)),
                    ]))),
          ]),
        )),
      ),
    );
  }
}

class _GenerationDots extends CustomPainter {
  _GenerationDots({required this.animation, required this.color})
      : super(repaint: animation);
  final Animation<double> animation;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    const gap = 22.0;
    final paint = Paint();
    for (var row = 0; row * gap + 12 < size.height; row++) {
      for (var col = 0; col * gap + 12 < size.width; col++) {
        final wave =
            (math.sin(animation.value * math.pi * 2 + row * 1.7 + col * 2.3) +
                    1) /
                2;
        paint.color = color.withValues(alpha: 0.025 + wave * 0.11);
        canvas.drawCircle(Offset(12 + col * gap, 12 + row * gap), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GenerationDots oldDelegate) =>
      oldDelegate.color != color || oldDelegate.animation != animation;
}

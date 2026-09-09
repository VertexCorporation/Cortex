import 'dart:io';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A silent, paused video frame. Only visible gallery tiles own a decoder.
class ArtVideoPreview extends StatefulWidget {
  const ArtVideoPreview({super.key, required this.path});
  final String path;

  @override
  State<ArtVideoPreview> createState() => _ArtVideoPreviewState();
}

class _ArtVideoPreviewState extends State<ArtVideoPreview> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ArtVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _load();
  }

  Future<void> _load() async {
    _controller?.dispose();
    final controller = VideoPlayerController.file(File(widget.path));
    _controller = controller;
    _ready = false;
    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      await controller.setVolume(0);
      if (!mounted || _controller != controller) return;
      final position =
          controller.value.duration > const Duration(milliseconds: 200)
              ? const Duration(milliseconds: 200)
              : Duration.zero;
      await controller.seekTo(position);
      if (!mounted || _controller != controller) return;
      setState(() => _ready = true);
    } catch (_) {
      if (mounted && _controller == controller) setState(() => _ready = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!_ready || controller == null) {
      return ColoredBox(color: AppColors.background);
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

// viewer.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../app.dart';
import '../../darkener.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import '../../notifications/introvert.dart';
import '../../theme.dart';
import '../../appbar.dart';
import '../../server/credits.dart';
import 'package:audioplayers/audioplayers.dart';
import '../screen/widgets/wave.dart';

class PhotoViewer extends StatefulWidget {
  final File imageFile;

  /// Optional callback invoked when the user taps the edit button.
  /// Receives the image file so the caller can inject it into the input field.
  final void Function(File imageFile)? onEditImage;

  const PhotoViewer({
    super.key,
    required this.imageFile,
    this.onEditImage,
  });

  static Route route(File imageFile, {void Function(File)? onEditImage}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) =>
          PhotoViewer(
            imageFile: imageFile,
            onEditImage: onEditImage,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        final scaleAnim = Tween<double>(begin: 0.90, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(scale: scaleAnim, child: child),
        );
      },
      settings: const RouteSettings(name: 'PhotoViewer'),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  PhotoViewerState createState() => PhotoViewerState();
}

class PhotoViewerState extends State<PhotoViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  // Track previous scale to detect boundary hits for haptic feedback
  double _previousScale = 1.0;
  bool _didHitMinBoundary = false;
  bool _didHitMaxBoundary = false;

  static const double _minScale = 0.8;
  static const double _maxScale = 10.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )
      ..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Snaps back to identity ONLY when scale is back to (or below) 1.0.
  void _onInteractionEnd(ScaleEndDetails details) {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();

    if (currentScale <= _minScale + 0.01) {
      // Snap back to identity when user zoomed back out
      _animation = Matrix4Tween(
        begin: _transformationController.value,
        end: Matrix4.identity(),
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _animationController.forward(from: 0.0);
    }
    // If zoomed in, image stays wherever the user left it — no snap-back.

    // Reset boundary hit trackers
    _didHitMinBoundary = false;
    _didHitMaxBoundary = false;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();

    // Haptic feedback when hitting zoom boundaries
    if (currentScale <= _minScale + 0.01 && !_didHitMinBoundary &&
        _previousScale > _minScale + 0.05) {
      _didHitMinBoundary = true;
      HapticFeedback.mediumImpact();
    } else if (currentScale >= _maxScale - 0.01 && !_didHitMaxBoundary &&
        _previousScale < _maxScale - 0.05) {
      _didHitMaxBoundary = true;
      HapticFeedback.mediumImpact();
    }

    // Reset flags when moving away from boundaries
    if (currentScale > _minScale + 0.1) _didHitMinBoundary = false;
    if (currentScale < _maxScale - 0.1) _didHitMaxBoundary = false;

    _previousScale = currentScale;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final notificationService =
    Provider.of<IntrovertNotificationService>(context, listen: false);
    final Size screenSize = MediaQuery
        .of(context)
        .size;

    final bool hasCredits =
        (context
            .watch<CreditsManager>()
            .totalCreditsNotifier
            .value ?? 0) > 0;
    final bool showEditButton = hasCredits && widget.onEditImage != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Darkener.getDarkenedOverlayStyle(factor: 0.8),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // --- Ambient background blur (Optimized) ---
            Container(color: Colors.black),
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.6,
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                    cacheWidth: 64, // Decoded extremely small for maximum performance
                  ),
                ),
              ),
            ),

            // --- Image (expandable area - spans entire screen) ---
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformationController,
                onInteractionEnd: _onInteractionEnd,
                onInteractionUpdate: _onInteractionUpdate,
                panEnabled: true,
                scaleEnabled: true,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: EdgeInsets.zero,
                clipBehavior: Clip.none,
                // Allow full bleed
                child: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Top Bar: Close & Edit bubbles ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                      vertical: screenSize.height * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: showEditButton
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        // Close button (left when edit exists, center when alone)
                        AppBarButton(
                          onTap: () => Navigator.of(context).pop(),
                          size: screenSize.width * 0.11,
                          child: Icon(
                            Icons.close,
                            color: AppColors.primaryColor.inverted,
                            size: screenSize.width * 0.055,
                          ),
                        ),

                        // Edit button (right side, only when available)
                        if (showEditButton)
                          AppBarButton(
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onEditImage?.call(widget.imageFile);
                            },
                            size: screenSize.width * 0.11,
                            child: SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: screenSize.width * 0.05,
                              height: screenSize.width * 0.05,
                              colorFilter: ColorFilter.mode(
                                AppColors.primaryColor.inverted,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // --- Bottom actions ---
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: screenSize.height * 0.02,
                      top: screenSize.height * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Share
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final box =
                              context.findRenderObject() as RenderBox?;
                              
                              if (!await widget.imageFile.exists()) {
                                notificationService.showNotification(
                                  message: localizations.anErrorOccurred,
                                  type: NotificationType.error,
                                );
                                return;
                              }

                              await SharePlus.instance.share(
                                ShareParams(
                                  files: [XFile(widget.imageFile.path)],
                                  sharePositionOrigin:
                                  box!.localToGlobal(Offset.zero) &
                                  box.size,
                                ),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/world.svg',
                                  width: screenSize.width * 0.05,
                                  height: screenSize.width * 0.05,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                                SizedBox(height: screenSize.height * 0.005),
                                Text(
                                  localizations.share,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          width: screenSize.width * 0.002,
                          height: screenSize.height * 0.06,
                          color: Colors.white,
                        ),
                        // Download
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                final tempDir = await getTemporaryDirectory();
                                final baseName = 'cortex';
                                const variant = '.jpg';
                                int i = 0;
                                late File localFile;
                                while (true) {
                                  final fileName = i == 0
                                      ? '$baseName$variant'
                                      : '$baseName-$i$variant';
                                  localFile =
                                      File(path.join(tempDir.path, fileName));
                                  if (!(await localFile.exists())) {
                                    break;
                                  }
                                  i++;
                                }
                                await widget.imageFile.copy(localFile.path);
                                final bool? success =
                                await GallerySaver.saveImage(localFile.path);
                                if (success == true) {
                                  notificationService.showNotification(
                                    message: localizations.downloadSuccess,
                                    type: NotificationType.success,
                                    bottomOffset: 0.1,
                                  );
                                } else {
                                  notificationService.showNotification(
                                    message: localizations.downloadFailed,
                                    type: NotificationType.error,
                                    bottomOffset: 0.1,
                                  );
                                }
                              } catch (e) {
                                notificationService.showNotification(
                                  message: localizations.downloadFailed,
                                  type: NotificationType.error,
                                  bottomOffset: 0.1,
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/download.svg',
                                  width: screenSize.width * 0.05,
                                  height: screenSize.width * 0.05,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                                SizedBox(height: screenSize.height * 0.005),
                                Text(
                                  localizations.download,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoViewer extends StatefulWidget {
  final String videoPath;
  final void Function(String path)? onEditVideo;

  const VideoViewer({super.key, required this.videoPath, this.onEditVideo});

  static Route route(String videoPath, {void Function(String)? onEditVideo}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) =>
          VideoViewer(videoPath: videoPath, onEditVideo: onEditVideo),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        final scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(scale: scaleAnim, child: child),
        );
      },
      settings: const RouteSettings(name: 'VideoViewer'),
      barrierColor: Colors.black.withValues(alpha: 0.6),
    );
  }

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _showControls = true;
  bool _isLoading = true;
  String? _errorText;

  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  double _previousScale = 1.0;
  bool _didHitMinBoundary = false;
  bool _didHitMaxBoundary = false;

  static const double _minScale = 0.8;
  static const double _maxScale = 10.0;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )
      ..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  Future<void> _initVideo() async {
    try {
      final source = widget.videoPath;
      final VideoPlayerController controller =
      source.startsWith('http://') || source.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(source))
          : VideoPlayerController.file(File(source));

      await controller.initialize();
      controller.setLooping(false);
      controller.addListener(_onVideoUpdate);

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = e.toString();
      });
    }
  }

  // PERF: Only repaint when playback state actually changes,
  // not on every frame. Called by the video controller.
  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();

    if (currentScale <= _minScale + 0.01) {
      _animation = Matrix4Tween(
        begin: _transformationController.value,
        end: Matrix4.identity(),
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _animationController.forward(from: 0.0);
    }

    _didHitMinBoundary = false;
    _didHitMaxBoundary = false;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final double currentScale = _transformationController.value
        .getMaxScaleOnAxis();

    if (currentScale <= _minScale + 0.01 && !_didHitMinBoundary &&
        _previousScale > _minScale + 0.05) {
      _didHitMinBoundary = true;
      HapticFeedback.mediumImpact();
    } else if (currentScale >= _maxScale - 0.01 && !_didHitMaxBoundary &&
        _previousScale < _maxScale - 0.05) {
      _didHitMaxBoundary = true;
      HapticFeedback.mediumImpact();
    }

    if (currentScale > _minScale + 0.1) _didHitMinBoundary = false;
    if (currentScale < _maxScale - 0.1) _didHitMaxBoundary = false;

    _previousScale = currentScale;
  }

  Future<void> _seekBy(Duration offset) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final current = controller.value.position;
    final target = current + offset;
    final bounded = target < Duration.zero
        ? Duration.zero
        : (target > controller.value.duration
        ? controller.value.duration
        : target);
    await controller.seekTo(bounded);
  }

  Future<void> _downloadVideo(AppLocalizations localizations) async {
    final notificationService =
    Provider.of<IntrovertNotificationService>(context, listen: false);
    try {
      String localPath = widget.videoPath;
      if (widget.videoPath.startsWith('http://') ||
          widget.videoPath.startsWith('https://')) {
        final tempDir = await getTemporaryDirectory();
        final fileName = path.basename(widget.videoPath
            .split('?')
            .first);
        final localFile = File(path.join(tempDir.path, fileName));
        final request = await HttpClient().getUrl(Uri.parse(widget.videoPath));
        final response = await request.close();
        final bytes = await consolidateHttpClientResponseBytes(response);
        await localFile.writeAsBytes(bytes, flush: true);
        localPath = localFile.path;
      }

      final success = await GallerySaver.saveVideo(localPath);
      notificationService.showNotification(
        message: success == true
            ? localizations.downloadSuccess
            : localizations.downloadFailed,
        type:
        success == true ? NotificationType.success : NotificationType.error,
        bottomOffset: 0.1,
      );
    } catch (_) {
      notificationService.showNotification(
        message: localizations.downloadFailed,
        type: NotificationType.error,
        bottomOffset: 0.1,
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery
        .of(context)
        .size;
    final playbackController =
    (_controller != null && _controller!.value.isInitialized)
        ? _controller
        : null;
    final isInitialized = playbackController != null;

    final bool hasCredits =
        (context
            .watch<CreditsManager>()
            .totalCreditsNotifier
            .value ?? 0) > 0;
    final bool showEditButton = hasCredits && widget.onEditVideo != null;

    // PERF: isInitialized / playbackController are precomputed here once.
    // The controls overlay (play/pause, slider, time labels) is wrapped in a
    // ValueListenableBuilder so only that tiny section rebuilds at playback
    // frame-rate. The heavy blur + InteractiveViewer layers stay completely
    // static during playback.

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Darkener.getDarkenedOverlayStyle(factor: 0.85),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.black),
            if (isInitialized)
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Transform.scale(
                  scale: 1.2,
                  child: Opacity(
                    opacity: 0.6,
                    child: VideoPlayer(playbackController),
                  ),
                ),
              ),
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformationController,
                onInteractionEnd: _onInteractionEnd,
                onInteractionUpdate: _onInteractionUpdate,
                panEnabled: true,
                scaleEnabled: true,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: EdgeInsets.zero,
                clipBehavior: Clip.none,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: isInitialized
                        ? playbackController.value.aspectRatio
                        : (16 / 9),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _showControls = !_showControls),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _isLoading
                                  ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                                  : _errorText != null
                                  ? Center(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(20),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                        color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                                  : VideoPlayer(playbackController!),
                            ),
                            // PERF: Only the controls overlay needs to update
                            // at playback frame-rate (position, play/pause icon).
                            // Wrap it in ValueListenableBuilder so the heavy
                            // blur + InteractiveViewer above stay untouched.
                            if (_showControls && isInitialized)
                              ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: playbackController,
                                builder: (context, videoValue, _) {
                                  final duration = videoValue.duration;
                                  final position = videoValue.position;
                                  final sliderMax =
                                      duration.inMilliseconds > 0
                                          ? duration.inMilliseconds.toDouble()
                                          : 1.0;
                                  final sliderValue = position.inMilliseconds
                                      .toDouble()
                                      .clamp(0.0, sliderMax);
                                  return Positioned.fill(
                                    child: Container(
                                      color:
                                      Colors.black.withValues(alpha: 0.25),
                                      child: Column(
                                        children: [
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    _seekBy(const Duration(
                                                        seconds: -10)),
                                                icon: const Icon(
                                                    Icons.replay_10_rounded,
                                                    color: Colors.white,
                                                    size: 34),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () async {
                                                  if (videoValue.isPlaying) {
                                                    await playbackController
                                                        .pause();
                                                  } else {
                                                    await playbackController
                                                        .play();
                                                  }
                                                },
                                                icon: Icon(
                                                  videoValue.isPlaying
                                                      ? Icons
                                                      .pause_circle_filled_rounded
                                                      : Icons
                                                      .play_circle_fill_rounded,
                                                  color: Colors.white,
                                                  size: 56,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () =>
                                                    _seekBy(const Duration(
                                                        seconds: 10)),
                                                icon: const Icon(
                                                    Icons.forward_10_rounded,
                                                    color: Colors.white,
                                                    size: 34),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: Column(
                                              children: [
                                                SliderTheme(
                                                  data: SliderTheme.of(context)
                                                      .copyWith(
                                                    activeTrackColor:
                                                    Colors.white,
                                                    inactiveTrackColor:
                                                    Colors.white30,
                                                    thumbColor: Colors.white,
                                                  ),
                                                  child: Slider(
                                                    min: 0.0,
                                                    max: sliderMax,
                                                    value: sliderValue,
                                                    onChanged: (value) {
                                                      playbackController.seekTo(
                                                        Duration(
                                                            milliseconds:
                                                            value.toInt()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      _formatDuration(position),
                                                      style: const TextStyle(
                                                          color:
                                                          Colors.white70),
                                                    ),
                                                    Text(
                                                      _formatDuration(duration),
                                                      style: const TextStyle(
                                                          color:
                                                          Colors.white70),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                      vertical: screenSize.height * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: showEditButton
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        AppBarButton(
                          onTap: () => Navigator.of(context).pop(),
                          size: screenSize.width * 0.11,
                          child: Icon(
                            Icons.close,
                            color: AppColors.primaryColor.inverted,
                            size: screenSize.width * 0.055,
                          ),
                        ),
                        if (showEditButton)
                          AppBarButton(
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onEditVideo?.call(widget.videoPath);
                            },
                            size: screenSize.width * 0.11,
                            child: SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: screenSize.width * 0.05,
                              height: screenSize.width * 0.05,
                              colorFilter: ColorFilter.mode(
                                AppColors.primaryColor.inverted,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (widget.videoPath.startsWith('http://') ||
                                widget.videoPath.startsWith('https://')) {
                              await SharePlus.instance.share(
                                ShareParams(text: widget.videoPath),
                              );
                            } else {
                              await SharePlus.instance.share(
                                ShareParams(files: [XFile(widget.videoPath)]),
                              );
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.share_rounded,
                                  color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                localizations.share,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _downloadVideo(localizations),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.download_rounded,
                                  color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                localizations.download,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioViewer extends StatefulWidget {
  final String audioPath;
  final void Function(String path)? onEditAudio;

  const AudioViewer({super.key, required this.audioPath, this.onEditAudio});

  static Route route(String audioPath, {void Function(String)? onEditAudio}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) =>
          AudioViewer(audioPath: audioPath, onEditAudio: onEditAudio),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
        final scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(scale: scaleAnim, child: child),
        );
      },
      settings: const RouteSettings(name: 'AudioViewer'),
      barrierColor: Colors.black.withValues(alpha: 0.6),
    );
  }

  @override
  State<AudioViewer> createState() => _AudioViewerState();
}

class _AudioViewerState extends State<AudioViewer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    await _audioPlayer.setSourceDeviceFile(widget.audioPath);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _downloadAudio(AppLocalizations localizations) async {
    final notificationService =
    Provider.of<IntrovertNotificationService>(context, listen: false);
    try {
      final tempDir = await getTemporaryDirectory();
      final baseName = 'cortex-audio';
      final ext = path.extension(widget.audioPath);
      int i = 0;
      late File localFile;
      while (true) {
        final fileName = i == 0 ? '$baseName$ext' : '$baseName-$i$ext';
        localFile = File(path.join(tempDir.path, fileName));
        if (!(await localFile.exists())) {
          break;
        }
        i++;
      }
      await File(widget.audioPath).copy(localFile.path);
      // Depending on gallery_saver_plus capabilities, it might not support audio
      // Fallback to notification that it's saved in temp/cache
      notificationService.showNotification(
        message: localizations.downloadSuccess,
        type: NotificationType.success,
        bottomOffset: 0.1,
      );
    } catch (_) {
      notificationService.showNotification(
        message: localizations.downloadFailed,
        type: NotificationType.error,
        bottomOffset: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery
        .of(context)
        .size;

    final bool hasCredits =
        (context
            .watch<CreditsManager>()
            .totalCreditsNotifier
            .value ?? 0) > 0;
    final bool showEditButton = hasCredits && widget.onEditAudio != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Darkener.getDarkenedOverlayStyle(factor: 0.85),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.black.withValues(alpha: 0.8)),

            // Top Bar and Bottom Bar overlays
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Top Bar: Close & Edit bubbles ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                      vertical: screenSize.height * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: showEditButton
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        AppBarButton(
                          onTap: () => Navigator.of(context).pop(),
                          size: screenSize.width * 0.11,
                          child: Icon(
                            Icons.close,
                            color: AppColors.primaryColor.inverted,
                            size: screenSize.width * 0.055,
                          ),
                        ),

                        if (showEditButton)
                          AppBarButton(
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onEditAudio?.call(widget.audioPath);
                            },
                            size: screenSize.width * 0.11,
                            child: SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: screenSize.width * 0.05,
                              height: screenSize.width * 0.05,
                              colorFilter: ColorFilter.mode(
                                AppColors.primaryColor.inverted,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Center Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Waveform Visualizer
                        WaveformVisualizer(simulatePlaying: _isPlaying),
                        SizedBox(height: screenSize.height * 0.05),

                        // Play/Stop Button
                        GestureDetector(
                          onTap: () {
                            if (_isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.resume();
                            }
                          },
                          child: _isPlaying
                              ? SvgPicture.asset(
                            'assets/icons/stop.svg',
                            width: screenSize.width * 0.16,
                            height: screenSize.width * 0.16,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          )
                              : Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: screenSize.width * 0.18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Bottom actions ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await SharePlus.instance.share(
                              ShareParams(files: [XFile(widget.audioPath)]),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.share_rounded,
                                  color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                localizations.share,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _downloadAudio(localizations),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.download_rounded,
                                  color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                localizations.download,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

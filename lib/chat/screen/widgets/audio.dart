import 'package:cortex/app.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:cortex/sheet.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cortex/l10n/app_localizations.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final bool isUser;
  final double screenWidth;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    required this.isUser,
    required this.screenWidth,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      if (widget.audioPath.startsWith('http')) {
        await _audioPlayer.setSourceUrl(widget.audioPath);
      } else {
        await _audioPlayer.setSourceDeviceFile(widget.audioPath);
      }
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _showDownloadMenu(BuildContext context) {
    if (widget.audioPath.startsWith('http')) return;

    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ScaledBottomSheet(
            child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                leading: Icon(Icons.share_rounded,
                    color: AppColors.primaryColor.inverted),
                title: Text(l10n.download,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  SharePlus.instance
                      .share(ShareParams(files: [XFile(widget.audioPath)]));
                },
                ),
                ), // Material
              ],
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.screenWidth >= 600;
    final double playerWidth =
        isTablet ? widget.screenWidth * 0.5 : widget.screenWidth * 0.7;
    final double padding = isTablet ? widget.screenWidth * 0.015 : 14.0;
    final l10n = AppLocalizations.of(context)!;
    final String extension =
        widget.audioPath.split('/').last.split('.').last.toUpperCase();

    return GestureDetector(
      onLongPress: () => _showDownloadMenu(context),
      child: Container(
        width: playerWidth,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: widget.isUser
              ? AppColors.secondaryColor.withValues(alpha: 0.5)
              : AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title + Download Menu Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/voice.svg',
                    width: isTablet ? 18 : 14,
                    height: isTablet ? 18 : 14,
                    colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.featureCreateAudioTitle,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? widget.screenWidth * 0.018 : 13,
                        ),
                      ),
                      Text(
                        "$extension Audio",
                        style: TextStyle(
                          color: AppColors.quinaryColor,
                          fontSize: isTablet ? widget.screenWidth * 0.012 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDownloadMenu(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: isTablet ? 22 : 18,
                      color: AppColors.primaryColor.inverted
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 14),
            // Player Row: Play/Pause Button + Slider + Timestamps
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.resume();
                    }
                  },
                  child: Container(
                    width: isTablet ? 40 : 36.0,
                    height: isTablet ? 40 : 36.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.inverted,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.primaryColor,
                        size: isTablet ? 28 : 22.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14.0),
                          activeTrackColor: AppColors.primaryColor.inverted
                              .withValues(alpha: 0.8),
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.primaryColor.inverted,
                        ),
                        child: Slider(
                          min: 0.0,
                          max: _duration.inMilliseconds.toDouble() > 0
                              ? _duration.inMilliseconds.toDouble()
                              : 1.0,
                          value: _position.inMilliseconds.toDouble().clamp(
                              0.0,
                              _duration.inMilliseconds.toDouble() > 0
                                  ? _duration.inMilliseconds.toDouble()
                                  : 1.0),
                          onChanged: (value) async {
                            final position =
                                Duration(milliseconds: value.toInt());
                            await _audioPlayer.seek(position);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(
                                color: AppColors.quinaryColor,
                                fontSize:
                                    isTablet ? widget.screenWidth * 0.015 : 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(
                                color: AppColors.quinaryColor,
                                fontSize:
                                    isTablet ? widget.screenWidth * 0.015 : 10,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}

import 'package:cortex/app.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.screenWidth >= 600;
    final double playerWidth = isTablet ? widget.screenWidth * 0.4 : widget.screenWidth * 0.6;
    final double padding = isTablet ? widget.screenWidth * 0.015 : 12.0;

    return Container(
      width: playerWidth,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.isUser ? AppColors.secondaryColor : AppColors.tertiaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(padding * 1.5),
        border: widget.isUser ? null : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                await _audioPlayer.resume();
              }
            },
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: AppColors.primaryColor.inverted,
              size: isTablet ? widget.screenWidth * 0.04 : 36.0,
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
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    activeTrackColor: AppColors.primaryColor.inverted,
                    inactiveTrackColor: AppColors.primaryColor.inverted.withValues(alpha: 0.3),
                    thumbColor: AppColors.primaryColor.inverted,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                    value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0),
                    onChanged: (value) async {
                      final position = Duration(milliseconds: value.toInt());
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
                          color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                          fontSize: isTablet ? widget.screenWidth * 0.015 : 10,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                          fontSize: isTablet ? widget.screenWidth * 0.015 : 10,
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
    );
  }
}

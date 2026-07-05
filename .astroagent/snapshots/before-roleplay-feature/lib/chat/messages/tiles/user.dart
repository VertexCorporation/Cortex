// chat/messages/tiles/user.dart

import 'package:cortex/app.dart';
import 'package:cortex/recognizer.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import '../options/manager.dart';
import '../messages.dart';

class UserMessageTile extends StatefulWidget {
  final Message message;
  final VoidCallback? onFadeOutComplete;
  final VoidCallback? onEdit;

  const UserMessageTile({
    super.key,
    required this.message,
    this.onFadeOutComplete,
    this.onEdit,
  });

  @override
  UserMessageTileState createState() => UserMessageTileState();
}

class UserMessageTileState extends State<UserMessageTile>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    if (widget.message.opacity == 1.0) {
      _fadeController.forward(from: 0.0);
    } else {
      _fadeController.value = widget.message.opacity;
      if (widget.message.opacity == 0.0) _fadeController.reverse();
    }

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          widget.message.opacity == 0.0) {
        widget.onFadeOutComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(UserMessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.opacity != oldWidget.message.opacity) {
      if (widget.message.opacity == 1.0) {
        _fadeController.forward();
      } else if (widget.message.opacity == 0.0) {
        _fadeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLongPress(BuildContext context, Offset tapPosition) {
    showMessageOptions(
      context: context,
      tapPosition: tapPosition,
      message: widget.message,
      onEdit: widget.onEdit,
    );
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 800;
    final scale = isDesktop ? 1.0 : (screenWidth / 400).clamp(0.8, 1.2);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RawGestureDetector(
        gestures: {
          ShortLongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              ShortLongPressGestureRecognizer>(
            () => ShortLongPressGestureRecognizer(
                debugOwner: this,
                shortPressDuration: const Duration(milliseconds: 330)),
            (instance) {
              instance.onLongPressStart = (details) =>
                  _handleLongPress(context, details.globalPosition);
            },
          ),
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(24 * scale),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24 * scale),
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                      padding: EdgeInsets.all(12 * scale),
                      child: Text(
                        widget.message.text,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: 16 * scale,
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
  }
}

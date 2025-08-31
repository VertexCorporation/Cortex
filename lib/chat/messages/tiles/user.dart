import 'package:cortex/main.dart';
import 'package:flutter/material.dart';

import '../../../recognizer.dart';
import '../../../theme.dart';
import '../../chat.dart';
import '../options.dart';

class UserMessageTile extends StatefulWidget {
  final String text;
  final double opacity;
  final VoidCallback? onFadeOutComplete;
  final VoidCallback? onEdit;

  const UserMessageTile({
    Key? key,
    required this.text,
    required this.opacity,
    this.onFadeOutComplete,
    this.onEdit,
  }) : super(key: key);

  @override
  _UserMessageTileState createState() => _UserMessageTileState();
}

class _UserMessageTileState extends State<UserMessageTile> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    if (widget.opacity == 1.0) {
      _fadeController.value = 0.0;
      _fadeController.forward();
    } else {
      _fadeController.value = 1.0;
      _fadeController.reverse();
    }

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && widget.opacity == 0.0) {
        widget.onFadeOutComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(UserMessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.opacity != oldWidget.opacity) {
      if (widget.opacity == 1.0) {
        _fadeController.forward();
      } else if (widget.opacity == 0.0) {
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
    final chatState = context.findAncestorStateOfType<ChatScreenState>();
    if (chatState == null) return;
    bool conversationHasPhoto =
        chatState.messages.any((msg) => msg.photoPath != null && msg.photoPath!.isNotEmpty);

    showMessageOptions(
      context: context,
      tapPosition: tapPosition,
      messageText: widget.text,
      options: [MessageOption.copy, MessageOption.edit, MessageOption.select],
      onEdit: widget.onEdit,
      conversationHasPhoto: conversationHasPhoto,
      isSubscribed: chatState.isUserSubscribed,
      premiumTrialUses: chatState.premiumTrialUses,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RawGestureDetector(
        gestures: {
          ShortLongPressGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<ShortLongPressGestureRecognizer>(
                () => ShortLongPressGestureRecognizer(
              debugOwner: this,
              shortPressDuration: const Duration(milliseconds: 330),
            ),
                (instance) {
              instance.onLongPressStart = (details) {
                _handleLongPress(context, details.globalPosition);
              };
            },
          ),
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: 16,
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
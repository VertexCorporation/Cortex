// lib/inbox/widgets/tiles/content.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app.dart';
import '../../../overflow.dart';
import '../../../theme.dart';
import '../../manager.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// Displays the main content of a conversation tile.
///
/// This widget is responsible for arranging the title (with animation),
/// the model's name, the last message snippet, the date, and the action button.
/// It is a `StatefulWidget` to manage its own animation controllers and to
/// react to changes from the provided [ConversationManager].
class TileContent extends StatefulWidget {
  final ConversationManager manager;
  final VoidCallback onShowActionsPressed;
  final GlobalKey actionButtonKey;

  const TileContent({
    super.key,
    required this.manager,
    required this.onShowActionsPressed,
    required this.actionButtonKey,
  });

  @override
  State<TileContent> createState() => _TileContentState();
}

class _TileContentState extends State<TileContent>
    with TickerProviderStateMixin {
  // State for the title animation
  late AnimationController _fadeOutController;
  late AnimationController _fadeInController;
  String _displayedTitle = "";
  String _oldTitle = "";
  bool _isTitleUpdating = false;

  @override
  void initState() {
    super.initState();
    _displayedTitle = widget.manager.conversationTitle;

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() => setState(() {}));

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() => setState(() {}));

    // Listen to the manager for any data changes.
    widget.manager.addListener(_onManagerChanged);
  }

  @override
  void didUpdateWidget(covariant TileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent widget provides a new manager instance, we need to
    // stop listening to the old one and start listening to the new one.
    if (widget.manager != oldWidget.manager) {
      oldWidget.manager.removeListener(_onManagerChanged);
      widget.manager.addListener(_onManagerChanged);
      // Immediately update title if it's different to avoid showing stale data.
      if (widget.manager.conversationTitle != _displayedTitle) {
        setState(() {
          _displayedTitle = widget.manager.conversationTitle;
        });
      }
    }
  }

  @override
  void dispose() {
    // Always remove the listener and dispose controllers to prevent memory leaks.
    widget.manager.removeListener(_onManagerChanged);
    _fadeOutController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  /// Listener that triggers rebuilds and animations when the manager's data changes.
  void _onManagerChanged() {
    // If only the title has changed, trigger the custom animation.
    if (widget.manager.conversationTitle != _displayedTitle) {
      if (!mounted) return;

      _isTitleUpdating = true;
      _oldTitle = _displayedTitle;

      _fadeOutController
          .forward(from: 0.0)
          .whenComplete(() {
        if (!mounted) return;
        setState(() {
          _displayedTitle = widget.manager.conversationTitle;
        });
        _fadeInController
            .forward(from: 0.0)
            .whenComplete(() {
          if (!mounted) return;
          setState(() => _isTitleUpdating = false);
        });
      });
    }

    // For any other change (last message, etc.), just trigger a general rebuild.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final manager = widget.manager;
    final displayModelTitle = manager.modelId == 'dynamic'
        ? AppLocalizations.of(context)!.selectionScreenFeatureDynamicChat
        : manager.modelTitle;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAnimatedTitleWidget(),
              ),
              SizedBox(width: screenWidth * 0.02),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.003),
                child: Text(
                  _formatDate(manager.lastMessageDate),
                  style: TextStyle(
                    color: AppColors.tertiaryColor.withValues(alpha: 0.8),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.001),
          Text(
            displayModelTitle,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: screenHeight * 0.001),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _getLastMessageSnippet(
                  manager.lastMessageText,
                  manager.lastMessagePhotoPath,
                ),
              ),
              GestureDetector(
                key: widget.actionButtonKey,
                onTap: widget.onShowActionsPressed,
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: screenWidth * 0.055,
                  color: AppColors.tertiaryColor.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitleWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final textStyle = TextStyle(
      fontSize: screenWidth * 0.045,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: AppColors.primaryColor.inverted,
    );

    if (_isTitleUpdating) {
      return Stack(
        children: [
          _buildAnimatedTitle(
            _oldTitle,
            _fadeOutController,
            isFadingOut: true,
          ),
          _buildAnimatedTitle(
            _displayedTitle,
            _fadeInController,
            isFadingOut: false,
          ),
        ],
      );
    }

    return OverflowText(
      text: _displayedTitle,
      style: textStyle,
      maxLines: 1,
    );
  }

  /// Letter-by-letter fade animation for the title,
  /// matching the behavior of the original implementation.
  Widget _buildAnimatedTitle(
      String text,
      AnimationController controller, {
        required bool isFadingOut,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    const double lineHeight = 1.2;
    final double fixedHeight = fontSize * lineHeight;

    final int length = text.length;
    final double delayNormalized =
    length > 8 ? 0.8 / (length - 1) : 0.05;

    final List<InlineSpan> spans = [];

    for (int i = 0; i < length; i++) {
      double start;
      double end;

      if (isFadingOut) {
        final int j = length - 1 - i;
        start = j * delayNormalized;
        end = start + 0.2;
      } else {
        start = i * delayNormalized;
        end = start + 0.2;
      }

      final double t = controller.value;
      double opacity;

      if (!isFadingOut) {
        if (t < start) {
          opacity = 0.0;
        } else if (t > end) {
          opacity = 1.0;
        } else {
          opacity = (t - start) / (end - start);
        }
      } else {
        if (t < start) {
          opacity = 1.0;
        } else if (t > end) {
          opacity = 0.0;
        } else {
          opacity = 1.0 - (t - start) / (end - start);
        }
      }

      spans.add(
        TextSpan(
          text: text[i],
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            height: lineHeight,
            color: AppColors.primaryColor.inverted.withValues(
              alpha: opacity,
            ),
          ),
        ),
      );
    }

    final richTextWidget = SizedBox(
      height: fixedHeight,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          SizedBox(height: fixedHeight),
          RichText(
            text: TextSpan(children: spans),
            maxLines: 1,
            overflow: TextOverflow.clip,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
        ],
      ),
    );

    return FadeTransition(
      opacity: controller,
      child: richTextWidget,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final localizations = AppLocalizations.of(context)!;

    if (difference.inDays == 0 && now.day == date.day) {
      return localizations.today;
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != date.day)) {
      return localizations.yesterday;
    } else {
      return DateFormat('MMM d, yyyy', localizations.localeName)
          .format(date);
    }
  }

  Widget _getLastMessageSnippet(
      String lastMessageText,
      String lastPhotoPath,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final messageStyle = TextStyle(
      color: AppColors.tertiaryColor,
      fontSize: screenWidth * 0.03,
    );

    if (lastPhotoPath.isNotEmpty) {
      return Row(
        children: [
          SvgPicture.asset(
            'assets/icons/image.svg',
            width: screenWidth * 0.04,
            height: screenWidth * 0.04,
            colorFilter: ColorFilter.mode(
              AppColors.tertiaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: screenWidth * 0.01),
          if (lastMessageText.trim().isNotEmpty)
            Expanded(
              child: OverflowText(
                text: lastMessageText,
                style: messageStyle,
                maxLines: 1,
              ),
            ),
        ],
      );
    } else {
      return OverflowText(
        text: lastMessageText.replaceAll('\n', ' '),
        style: messageStyle,
        maxLines: 1,
      );
    }
  }
}